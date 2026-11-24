import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/config/app_info.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';
import 'package:aura/features/access/domain/repositories/access_repository.dart';

class AccessState extends Equatable {
  const AccessState({
    this.status = AccessStatus.open,
    this.loading = false,
    this.failure,
    this.resolved = false,
    this.context = const AccessContext(),
  });

  final AccessStatus status;
  final bool loading;
  final Failure? failure;

  /// O servidor (ou a autorização offline) já respondeu para esta conta.
  /// Enquanto false, o roteador mostra a tela de verificação em vez de
  /// piscar o conteúdo ou o paywall.
  final bool resolved;

  /// Motivo do bloqueio (só orienta o texto do paywall).
  final AccessContext context;

  AccessState copyWith({
    AccessStatus? status,
    bool? loading,
    Failure? failure,
    bool? resolved,
    AccessContext? context,
  }) => AccessState(
    status: status ?? this.status,
    loading: loading ?? this.loading,
    failure: failure,
    resolved: resolved ?? this.resolved,
    context: context ?? this.context,
  );

  @override
  List<Object?> get props => [status, loading, failure, resolved, context];
}

/// Estado central de papéis e acesso Premium e ÚNICO lugar que decide para
/// onde o app deve estar ([gate]). Telas e roteador leem daqui em vez de
/// verificar assinatura por conta própria. Atualiza no login, na abertura,
/// ao voltar do segundo plano, ao reconectar, quando o servidor responde 402
/// e quando o acesso (ou a autorização offline) vence durante a sessão.
/// Com o modelo desligado (enforced=false) nunca bloqueia.
class AccessCubit extends Cubit<AccessState> {
  AccessCubit(this._repository, {DateTime Function()? clock, String? version})
    : _clock = clock ?? DateTime.now,
      _version = version ?? AppInfo.version,
      super(const AccessState());

  final AccessRepository _repository;
  final DateTime Function() _clock;
  final String _version;

  static const _minGap = Duration(seconds: 60);
  DateTime? _last;
  Future<void>? _running;
  Timer? _expiry;

  Future<void> refresh({bool force = false}) {
    final last = _last;
    if (!force && state.resolved && last != null && _clock().difference(last) < _minGap) {
      return Future.value();
    }
    return _running ??= _run().whenComplete(() => _running = null);
  }

  Future<void> _run() async {
    emit(state.copyWith(loading: true));
    final result = await _repository.refresh();
    _last = _clock();
    if (isClosed) return;
    if (result is Success<AccessStatus>) {
      final status = result.data;
      // O motivo só é buscado quando há bloqueio com conexão (online).
      final ctx = status.isBlocked && !status.needsConnection && !status.fromOfflineGrant
          ? await _repository.loadContext()
          : const AccessContext();
      if (isClosed) return;
      emit(AccessState(status: status, resolved: true, context: ctx));
      _armExpiry(status);
    } else if (result is Error<AccessStatus>) {
      // Erro que não é falta de conexão (ex.: 5xx): mantém o último estado
      // conhecido. A decisão real é do servidor (o gate barra o conteúdo);
      // o app não inventa bloqueio por falha técnica.
      emit(AccessState(status: state.status, resolved: true, failure: result.failure, context: state.context));
    }
  }

  /// Reavalia no instante em que o acesso (ou a autorização offline) vence,
  /// sem depender de o usuário navegar: o paywall (ou a tela "conecte-se")
  /// aparece sozinho.
  void _armExpiry(AccessStatus status) {
    _expiry?.cancel();
    if (!status.enforced || !status.allowed || status.isStaff && status.indefinite) return;
    final ends = [
      status.accessUntil,
      status.authorizationExpiresAt,
    ].whereType<DateTime>().fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
    if (ends == null) return;
    var wait = ends.difference(_clock()) + const Duration(seconds: 2);
    if (wait < const Duration(seconds: 5)) wait = const Duration(seconds: 5);
    if (wait > const Duration(hours: 12)) wait = const Duration(hours: 12);
    _expiry = Timer(wait, () => unawaited(refresh(force: true)));
  }

  /// Saída da conta: esquece tudo da conta anterior.
  Future<void> reset() async {
    _last = null;
    _expiry?.cancel();
    await _repository.clear();
    if (!isClosed) emit(const AccessState());
  }

  String get _platform =>
      kIsWeb ? 'web' : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');

  /// O servidor pediu uma versão mais nova. Só orienta a UI: a proteção real
  /// é o gate do servidor (versões antigas publicadas não têm esta tela).
  bool get updateRequired =>
      state.status.enforced && isVersionBelow(_version, state.status.minVersion[_platform]);

  /// Para onde o app deve estar. Ordem: versão → conexão → paywall.
  AccessGate get gate {
    if (!state.resolved) return AccessGate.resolving;
    if (updateRequired) return AccessGate.updateRequired;
    if (state.status.needsConnection) return AccessGate.connectionRequired;
    if (state.status.isBlocked) return AccessGate.paywall;
    return AccessGate.open;
  }

  @override
  Future<void> close() {
    _expiry?.cancel();
    return super.close();
  }
}

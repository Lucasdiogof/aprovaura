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
  });

  final AccessStatus status;
  final bool loading;
  final Failure? failure;

  AccessState copyWith({AccessStatus? status, bool? loading, Failure? failure}) =>
      AccessState(
        status: status ?? this.status,
        loading: loading ?? this.loading,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, loading, failure];
}

/// Estado central de papéis e acesso Premium. Telas leem `state.status`
/// (isBlocked, isAdmin, isPartner...) em vez de verificar assinatura cada uma
/// por conta própria. Atualiza no login, na abertura, ao voltar do segundo
/// plano, ao reconectar e quando o servidor responde 402 (ver
/// injection_container.wireAccessSupport). Com o modelo desligado
/// (enforced=false) nunca bloqueia.
class AccessCubit extends Cubit<AccessState> {
  AccessCubit(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(const AccessState());

  final AccessRepository _repository;
  final DateTime Function() _clock;

  static const _minGap = Duration(seconds: 60);
  DateTime? _last;
  Future<void>? _running;

  Future<void> refresh({bool force = false}) {
    final last = _last;
    if (!force && last != null && _clock().difference(last) < _minGap) {
      return Future.value();
    }
    return _running ??= _run().whenComplete(() => _running = null);
  }

  Future<void> _run() async {
    emit(state.copyWith(status: state.status, loading: true));
    final result = await _repository.refresh();
    _last = _clock();
    if (isClosed) return;
    if (result is Success<AccessStatus>) {
      emit(AccessState(status: result.data));
    } else if (result is Error<AccessStatus>) {
      emit(AccessState(status: state.status, failure: result.failure));
    }
  }

  /// Saída da conta: esquece tudo da conta anterior.
  Future<void> reset() async {
    _last = null;
    await _repository.clear();
    if (!isClosed) emit(const AccessState());
  }

  /// O servidor pediu uma versão mais nova (só orientação de UI).
  bool get updateRequired {
    final platform = kIsWeb
        ? 'web'
        : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');
    return state.status.enforced &&
        isVersionBelow(AppInfo.version, state.status.minVersion[platform]);
  }
}

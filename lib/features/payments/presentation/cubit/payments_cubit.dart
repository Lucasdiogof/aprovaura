import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/payments/data/payments_repository_impl.dart';
import 'package:aura/features/payments/domain/payments.dart';

enum PayPhase { idle, loading, ready, purchasing, pending, validating, success, cancelled, conflict, failed }

class PaymentsState extends Equatable {
  const PaymentsState({
    this.phase = PayPhase.idle,
    this.config = const PurchaseConfig(),
    this.plans = const [],
    this.overview = const SubscriptionOverview(),
    this.charge,
    this.failure,
  });
  final PayPhase phase;
  final PurchaseConfig config;
  final List<StorePlan> plans;
  final SubscriptionOverview overview;
  final PixCharge? charge;
  final Failure? failure;

  /// A compra só abre quando o provedor foi liberado no servidor (decisão de lançamento).
  bool canBuy(PayProvider p) => config.isEnabled(p);

  /// Assinatura vigente em outro provedor → oferecer gerenciar, nunca comprar de novo.
  SubscriptionInfo? get current => overview.current;

  PaymentsState copyWith({
    PayPhase? phase,
    PurchaseConfig? config,
    List<StorePlan>? plans,
    SubscriptionOverview? overview,
    PixCharge? charge,
    bool clearCharge = false,
    Failure? failure,
  }) => PaymentsState(
    phase: phase ?? this.phase,
    config: config ?? this.config,
    plans: plans ?? this.plans,
    overview: overview ?? this.overview,
    charge: clearCharge ? null : (charge ?? this.charge),
    failure: failure,
  );

  @override
  List<Object?> get props => [phase, config, plans, overview, charge, failure];
}

/// Orquestra compra/restauração/consulta. "Sucesso" do cliente nunca é prova:
/// após cada desfecho o estado oficial é relido (overview + AccessCubit).
class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._repo, this._access) : super(const PaymentsState()) {
    _sub = _repo.outcomes.listen(_onOutcome);
  }

  final PaymentsRepository _repo;
  final AccessCubit _access;
  StreamSubscription<StoreOutcome>? _sub;

  PayProvider get provider => _repo.nativeProvider;

  Future<void> load() async {
    emit(state.copyWith(phase: PayPhase.loading));
    final cfg = await _repo.config();
    if (cfg is Error<PurchaseConfig>) {
      return emit(state.copyWith(phase: PayPhase.failed, failure: cfg.failure));
    }
    final config = (cfg as Success<PurchaseConfig>).data;
    final plans = await _repo.storePlans(config); // preços REAIS da loja
    final ov = await _repo.overview();
    emit(state.copyWith(
      phase: PayPhase.ready,
      config: config,
      plans: plans is Success<List<StorePlan>> ? plans.data : const [],
      overview: ov is Success<SubscriptionOverview> ? ov.data : null,
      charge: ov is Success<SubscriptionOverview> ? ov.data.pending : null,
      clearCharge: ov is Success<SubscriptionOverview> && ov.data.pending == null,
    ));
  }

  Future<void> buy(StorePlan plan) async {
    if (!state.canBuy(plan.offer.provider) || state.current != null) return;
    emit(state.copyWith(phase: PayPhase.purchasing));
    final r = await _repo.buy(plan);
    if (r is Error<void>) emit(state.copyWith(phase: PayPhase.failed, failure: r.failure));
  }

  Future<void> restore() async {
    emit(state.copyWith(phase: PayPhase.validating));
    final r = await _repo.restore();
    if (r is Error<void>) emit(state.copyWith(phase: PayPhase.failed, failure: r.failure));
  }

  Future<void> _onOutcome(StoreOutcome o) async {
    switch (o) {
      case StoreOutcome.validated:
        await _refreshAccess();
        emit(state.copyWith(phase: PayPhase.success));
      case StoreOutcome.pending:
        emit(state.copyWith(phase: PayPhase.pending));
      case StoreOutcome.cancelled:
        emit(state.copyWith(phase: PayPhase.cancelled));
      case StoreOutcome.conflict:
        emit(state.copyWith(phase: PayPhase.conflict));
      case StoreOutcome.failed:
        emit(state.copyWith(phase: PayPhase.failed));
    }
  }

  Future<void> _refreshAccess() async {
    final ov = await _repo.overview();
    await _access.refresh(force: true);
    if (ov is Success<SubscriptionOverview>) emit(state.copyWith(overview: ov.data));
  }

  // ---- Web / Mercado Pago ----

  Future<void> createCharge(PayPlan plan, String method) async {
    if (!state.canBuy(PayProvider.mercadopago)) return;
    emit(state.copyWith(phase: PayPhase.purchasing));
    final r = await _repo.createCharge(plan, method);
    switch (r) {
      case Success<PixCharge?>(:final data):
        emit(state.copyWith(phase: PayPhase.pending, charge: data));
      case Error<PixCharge?>(:final failure):
        emit(state.copyWith(
          phase: failure is AlreadySubscribedFailure ? PayPhase.conflict : PayPhase.failed,
          failure: failure,
        ));
    }
  }

  /// "Verificar pagamento": o servidor relê o Mercado Pago (não confia no cliente).
  Future<String> checkCharge() async {
    final r = await _repo.chargeStatus();
    final st = r is Success<String> ? r.data : 'pending';
    if (st == 'approved') {
      await _refreshAccess();
      emit(state.copyWith(phase: PayPhase.success, clearCharge: true));
    } else if (st == 'expired' || st == 'rejected') {
      emit(state.copyWith(phase: PayPhase.ready, clearCharge: true));
    }
    return st;
  }

  Future<void> cancelCard() async {
    final r = await _repo.cancelCard();
    if (r is Success<void>) await _refreshAccess();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import 'package:aura/core/error/result.dart';

enum PayPlan { monthly, annual }

enum PayProvider { apple, google, mercadopago }

PayPlan? _plan(Object? v) => v == 'monthly'
    ? PayPlan.monthly
    : v == 'annual'
    ? PayPlan.annual
    : null;

PayProvider? _provider(Object? v) => switch (v) {
  'apple' => PayProvider.apple,
  'google' => PayProvider.google,
  'mercadopago' => PayProvider.mercadopago,
  _ => null,
};

/// Produto do catálogo (ids de loja). O preço aqui é só REFERÊNCIA — o app
/// exibe o preço real devolvido pela loja (ou pelo servidor, no Mercado Pago).
class PlanOffer extends Equatable {
  const PlanOffer(this.plan, this.provider, this.productId, this.basePlanId, [this.priceCents]);
  final PayPlan plan;
  final PayProvider provider;
  final String productId;
  final String? basePlanId;

  /// Valor do catálogo do servidor. Só é o preço mostrado no Mercado Pago
  /// (o servidor cobra exatamente isto); Apple/Google mostram o preço da loja.
  final int? priceCents;
  @override
  List<Object?> get props => [plan, provider, productId, basePlanId, priceCents];
}

/// Configuração pública: o que está liberado e o catálogo (nada secreto).
class PurchaseConfig extends Equatable {
  const PurchaseConfig({this.enabled = const {}, this.catalog = const []});
  final Map<PayProvider, bool> enabled;
  final List<PlanOffer> catalog;

  bool isEnabled(PayProvider p) => enabled[p] ?? false;

  factory PurchaseConfig.fromJson(Map<String, dynamic> j) => PurchaseConfig(
    enabled: {
      for (final e in (j['enabled'] as Map? ?? {}).entries)
        if (_provider(e.key) != null) _provider(e.key)!: e.value == true,
    },
    catalog: [
      for (final c in (j['catalog'] as List? ?? []))
        if (_plan((c as Map)['plan']) != null && _provider(c['provider']) != null)
          PlanOffer(
            _plan(c['plan'])!,
            _provider(c['provider'])!,
            c['product_id'] as String,
            c['base_plan_id'] as String?,
            (c['reference_price_cents'] as num?)?.toInt(),
          ),
    ],
  );
  @override
  List<Object?> get props => [enabled, catalog];
}

/// Plano com o preço REAL já formatado pela loja (ex.: "R$ 19,90").
class StorePlan extends Equatable {
  const StorePlan(this.offer, this.priceLabel, this.handle, [this.value]);
  final PlanOffer offer;
  final String priceLabel;

  /// Valor numérico da loja (só para calcular a economia do anual).
  final double? value;

  /// Objeto opaco da loja (ProductDetails) para iniciar a compra.
  final Object handle;
  @override
  List<Object?> get props => [offer, priceLabel];
}

class SubscriptionInfo extends Equatable {
  const SubscriptionInfo({
    required this.provider,
    required this.plan,
    required this.state,
    this.periodEnd,
    this.autoRenew,
    this.sandbox = false,
    this.since,
  });
  final PayProvider provider;
  final PayPlan plan;

  /// pending/active/grace/canceled/expired/refunded/revoked (do servidor).
  final String state;
  final DateTime? periodEnd;
  final bool? autoRenew;
  final bool sandbox;
  final DateTime? since;

  bool get isLive =>
      ['active', 'grace', 'canceled'].contains(state) &&
      (periodEnd == null || periodEnd!.isAfter(DateTime.now()));

  static SubscriptionInfo? fromJson(Map<dynamic, dynamic> j) {
    final p = _provider(j['provider']), pl = _plan(j['plan']);
    if (p == null || pl == null) return null;
    return SubscriptionInfo(
      provider: p,
      plan: pl,
      state: j['state'] as String,
      periodEnd: DateTime.tryParse('${j['period_end']}'),
      autoRenew: j['auto_renew'] as bool?,
      sandbox: j['sandbox'] == true,
      since: DateTime.tryParse('${j['since']}'),
    );
  }

  @override
  List<Object?> get props => [provider, plan, state, periodEnd, autoRenew];
}

/// Cobrança web pendente (Pix: QR + copia-e-cola; cartão: checkout hospedado).
class PixCharge extends Equatable {
  const PixCharge({
    required this.id,
    required this.plan,
    required this.method,
    required this.amountCents,
    this.qrCode,
    this.qrBase64,
    this.checkoutUrl,
    this.expiresAt,
    this.status = 'pending',
  });
  final String id;
  final PayPlan plan;
  final String method;
  final int amountCents;
  final String? qrCode;
  final String? qrBase64;
  final String? checkoutUrl;
  final DateTime? expiresAt;
  final String status;

  bool get expired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  static PixCharge? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final pl = _plan(raw['plan']);
    if (pl == null) return null;
    return PixCharge(
      id: '${raw['id']}',
      plan: pl,
      method: '${raw['method']}',
      amountCents: (raw['amount_cents'] as num).toInt(),
      qrCode: raw['qr_code'] as String?,
      qrBase64: raw['qr_base64'] as String?,
      checkoutUrl: raw['checkout_url'] as String?,
      expiresAt: DateTime.tryParse('${raw['expires_at']}'),
      status: '${raw['status'] ?? 'pending'}',
    );
  }

  @override
  List<Object?> get props => [id, status, qrCode, expiresAt];
}

class SubscriptionOverview extends Equatable {
  const SubscriptionOverview({this.subscriptions = const [], this.pending});
  final List<SubscriptionInfo> subscriptions;
  final PixCharge? pending;

  SubscriptionInfo? get current {
    for (final s in subscriptions) {
      if (s.isLive) return s;
    }
    return null;
  }

  @override
  List<Object?> get props => [subscriptions, pending];
}

/// Linha do histórico de pagamentos do próprio usuário (valor bruto pago).
class PaymentRecord extends Equatable {
  const PaymentRecord({
    required this.provider,
    required this.plan,
    required this.amountCents,
    required this.status,
    required this.paidAt,
  });
  final PayProvider provider;
  final PayPlan plan;
  final int amountCents;
  final String status;
  final DateTime paidAt;

  static PaymentRecord? fromJson(Map<dynamic, dynamic> j) {
    final p = _provider(j['provider']), pl = _plan(j['plan']);
    final at = DateTime.tryParse('${j['paid_at']}');
    if (p == null || pl == null || at == null) return null;
    return PaymentRecord(
      provider: p,
      plan: pl,
      amountCents: (j['amount_cents'] as num).toInt(),
      status: '${j['status']}',
      paidAt: at,
    );
  }

  @override
  List<Object?> get props => [provider, plan, amountCents, status, paidAt];
}

/// Resultado de uma compra nativa já tratada pelo servidor.
enum StoreOutcome { validated, pending, cancelled, conflict, failed }

abstract class PaymentsRepository {
  PayProvider get nativeProvider; // plataforma atual (web => mercadopago)
  Future<Result<PurchaseConfig>> config();
  Future<Result<SubscriptionOverview>> overview();
  Future<Result<List<PaymentRecord>>> history();

  /// Preços reais da loja (nunca valores fixos).
  Future<Result<List<StorePlan>>> storePlans(PurchaseConfig config);

  /// Inicia a compra nativa; o resultado chega por [outcomes].
  Future<Result<void>> buy(StorePlan plan);
  Future<Result<void>> restore();
  Stream<StoreOutcome> get outcomes;

  Future<Result<PixCharge?>> createCharge(PayPlan plan, String method);
  Future<Result<String>> chargeStatus();
  Future<Result<void>> cancelCard();
}

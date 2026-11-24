import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/features/payments/domain/payments.dart';

/// Pagamentos. Regra de ouro: o app NUNCA concede acesso — ele só entrega o
/// comprovante da loja ao backend, que valida (assinatura Apple / Developer
/// API Google) e grava o entitlement. Mercado Pago só na Web/Portal.
class PaymentsRepositoryImpl implements PaymentsRepository {
  PaymentsRepositoryImpl(this._client);

  final SupabaseClient _client;
  final _out = StreamController<StoreOutcome>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _sub;

  @override
  Stream<StoreOutcome> get outcomes => _out.stream;

  @override
  PayProvider get nativeProvider {
    if (kIsWeb) return PayProvider.mercadopago;
    return defaultTargetPlatform == TargetPlatform.iOS
        ? PayProvider.apple
        : PayProvider.google;
  }

  bool get _native => !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Future<Result<PurchaseConfig>> config() async {
    try {
      final r = await _client.rpc<dynamic>('get_purchase_config').withRequestTimeout();
      return Success(PurchaseConfig.fromJson(Map<String, dynamic>.from(r as Map)));
    } catch (e) {
      return Error(failureFromError(e));
    }
  }

  @override
  Future<Result<SubscriptionOverview>> overview() async {
    try {
      final r = Map<String, dynamic>.from(
        await _client.rpc<dynamic>('get_my_subscription').withRequestTimeout() as Map,
      );
      return Success(SubscriptionOverview(
        subscriptions: [
          for (final s in (r['subscriptions'] as List? ?? []))
            if (SubscriptionInfo.fromJson(s as Map) != null) SubscriptionInfo.fromJson(s)!,
        ],
        pending: PixCharge.fromJson(r['pending_charge']),
      ));
    } catch (e) {
      return Error(failureFromError(e));
    }
  }

  @override
  Future<Result<List<StorePlan>>> storePlans(PurchaseConfig config) async {
    if (!_native) return const Success([]);
    try {
      final iap = InAppPurchase.instance;
      if (!await iap.isAvailable()) return const Success([]);
      final offers = config.catalog.where((o) => o.provider == nativeProvider).toList();
      final res = await iap.queryProductDetails({for (final o in offers) o.productId});
      final plans = <StorePlan>[];
      for (final o in offers) {
        for (final d in res.productDetails.where((d) => d.id == o.productId)) {
          // Google: um ProductDetails por base plan/oferta — escolhe o do plano certo.
          if (d is GooglePlayProductDetails) {
            final i = d.subscriptionIndex;
            final base = i == null ? null : d.productDetails.subscriptionOfferDetails?[i].basePlanId;
            if (base != o.basePlanId) continue;
          }
          plans.add(StorePlan(o, d.price, d));
          break;
        }
      }
      return Success(plans);
    } catch (e) {
      return Error(failureFromError(e));
    }
  }

  void _listen() {
    _sub ??= InAppPurchase.instance.purchaseStream.listen(_onPurchases,
        onError: (_) => _out.add(StoreOutcome.failed));
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _out.add(StoreOutcome.pending);
        case PurchaseStatus.canceled:
          _out.add(StoreOutcome.cancelled);
          if (p.pendingCompletePurchase) await InAppPurchase.instance.completePurchase(p);
        case PurchaseStatus.error:
          _out.add(StoreOutcome.failed);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final ok = await _validate(p);
          if (ok == StoreOutcome.validated && p.pendingCompletePurchase) {
            // Só encerra a transação na loja DEPOIS que o servidor validou e gravou.
            await InAppPurchase.instance.completePurchase(p);
          }
          _out.add(ok);
      }
    }
  }

  Future<StoreOutcome> _validate(PurchaseDetails p) async {
    try {
      final apple = nativeProvider == PayProvider.apple;
      final r = await _client.functions.invoke(
        apple ? 'payments-apple' : 'payments-google',
        body: apple
            ? {'signedTransaction': p.verificationData.serverVerificationData}
            : {'purchaseToken': p.verificationData.serverVerificationData},
      ).withRequestTimeout();
      return r.status == 200 ? StoreOutcome.validated : StoreOutcome.failed;
    } on FunctionException catch (e) {
      return e.status == 409 || e.status == 403 ? StoreOutcome.conflict : StoreOutcome.failed;
    } catch (_) {
      return StoreOutcome.failed;
    }
  }

  @override
  Future<Result<void>> buy(StorePlan plan) async {
    if (!_native) return Error(UnexpectedFailure());
    try {
      _listen();
      // Token opaco gerado no servidor (appAccountToken / obfuscatedAccountId).
      final token = await _client.rpc<dynamic>('get_purchase_account_token').withRequestTimeout() as String;
      final d = plan.handle as ProductDetails;
      final param = d is GooglePlayProductDetails
          ? GooglePlayPurchaseParam(productDetails: d, applicationUserName: token, offerToken: d.offerToken)
          : PurchaseParam(productDetails: d, applicationUserName: token);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
      return const Success(null);
    } catch (e) {
      return Error(failureFromError(e));
    }
  }

  @override
  Future<Result<void>> restore() async {
    if (!_native) return const Success(null);
    try {
      _listen();
      await InAppPurchase.instance.restorePurchases(); // o servidor revalida cada comprovante
      return const Success(null);
    } catch (e) {
      return Error(failureFromError(e));
    }
  }

  Future<Map<String, dynamic>> _mp(Map<String, dynamic> body) async {
    final r = await _client.functions.invoke('mp-checkout', body: body).withRequestTimeout();
    return Map<String, dynamic>.from(r.data as Map);
  }

  @override
  Future<Result<PixCharge?>> createCharge(PayPlan plan, String method) async {
    try {
      final r = await _mp({'action': 'create', 'plan': plan.name, 'method': method});
      return Success(PixCharge.fromJson(r['charge']));
    } on FunctionException catch (e) {
      return Error(e.status == 409 ? AlreadySubscribedFailure() : failureFromError(e));
    } catch (e) {
      return Error(failureFromError(e));
    }
  }

  @override
  Future<Result<String>> chargeStatus() async {
    try {
      return Success('${(await _mp({'action': 'status'}))['status']}');
    } catch (e) {
      return Error(failureFromError(e));
    }
  }

  @override
  Future<Result<void>> cancelCard() async {
    try {
      await _mp({'action': 'cancel'});
      return const Success(null);
    } catch (e) {
      return Error(failureFromError(e));
    }
  }
}

/// Já existe assinatura vigente em outro provedor: orientar a gerenciar, nunca cancelar sozinho.
class AlreadySubscribedFailure extends Failure {
  const AlreadySubscribedFailure() : super('already_subscribed');
}

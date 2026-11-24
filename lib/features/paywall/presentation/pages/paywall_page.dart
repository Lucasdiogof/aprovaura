import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/payments/domain/payments.dart';
import 'package:aura/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:aura/features/payments/presentation/widgets/pix_payment_panel.dart';
import 'package:aura/features/paywall/presentation/widgets/paywall_common.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/shared/utils/external_link.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/aura/aura_glyph.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Tela de assinatura Premium. Obrigatória quando o acesso está bloqueado
/// (sem botão voltar) e opcional, com "fechar", quando o acesso já está
/// liberado (ex.: teste querendo assinar antes do fim). Nada aqui concede
/// acesso: o "sucesso" só aparece depois que o servidor confirmou e o
/// AccessCubit reabriu o acesso.
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<PaymentsCubit>()..load(),
    child: const _PaywallView(),
  );
}

enum _Variant {
  trialExpired,
  subscriptionExpired,
  existingUser,
  none,
  voluntary,
  pending,
  validating,
  declined,
  unavailable,
  active,
}

class _PlanOption {
  const _PlanOption(this.plan, this.label, this.value, this.store);
  final PayPlan plan;
  final String label;
  final double? value;
  final StorePlan? store;
}

class _PaywallView extends StatefulWidget {
  const _PaywallView();

  @override
  State<_PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<_PaywallView> {
  PayPlan _plan = PayPlan.annual;
  String _method = 'card';
  bool _wasBlocked = false;
  bool _unlocked = false;

  List<_PlanOption> _options(PaymentsState s, PortalStrings t, PayProvider here) {
    final out = <_PlanOption>[];
    if (here == PayProvider.mercadopago) {
      for (final o in s.config.catalog.where((o) => o.provider == PayProvider.mercadopago && o.priceCents != null)) {
        out.add(_PlanOption(o.plan, t.money(o.priceCents!), o.priceCents! / 100, null));
      }
    } else {
      for (final p in s.plans) {
        out.add(_PlanOption(p.offer.plan, p.priceLabel, p.value, p));
      }
    }
    out.sort((a, b) => a.plan.index.compareTo(b.plan.index));
    return out;
  }

  _Variant _variant(AccessCubit access, PaymentsState pay, bool providerReady, bool hasPlans) {
    final st = access.state;
    if (pay.current != null && st.status.allowed && !st.status.isBlocked) return _Variant.active;
    if (pay.phase == PayPhase.validating || pay.phase == PayPhase.purchasing) return _Variant.validating;
    if (pay.charge != null || pay.phase == PayPhase.pending || st.context.pendingPayment) return _Variant.pending;
    if (pay.phase == PayPhase.failed && pay.failure == null) return _Variant.declined;
    if (pay.phase == PayPhase.failed && pay.failure != null && !isConnectionFailure(pay.failure!)) {
      return pay.overview.subscriptions.isEmpty && pay.config.catalog.isEmpty
          ? _Variant.unavailable
          : _Variant.declined;
    }
    if (pay.phase != PayPhase.loading &&
        pay.phase != PayPhase.idle &&
        (!providerReady || !hasPlans)) {
      return _Variant.unavailable;
    }
    if (access.gate == AccessGate.open) return _Variant.voluntary;
    return switch (st.context.reason) {
      BlockReason.trialExpired => _Variant.trialExpired,
      BlockReason.subscriptionExpired => _Variant.subscriptionExpired,
      BlockReason.existingUser => _Variant.existingUser,
      BlockReason.none => _Variant.none,
    };
  }

  (String, String, AurudoPose) _copy(PortalStrings t, _Variant v) => switch (v) {
    _Variant.trialExpired => (
      t('Seus 3 dias gratuitos terminaram', 'Your 3 free days have ended', 'Tus 3 días gratis terminaron'),
      t('Continue sua preparação sem perder o ritmo: assine o Premium e siga de onde parou. Seu histórico e seu progresso estão guardados.',
          'Keep your preparation going: subscribe to Premium and pick up where you left off. Your history and progress are safe.',
          'Sigue con tu preparación: suscríbete a Premium y continúa donde lo dejaste. Tu historial y tu progreso están guardados.'),
      AurudoPose.studying,
    ),
    _Variant.subscriptionExpired => (
      t('Seu Premium terminou', 'Your Premium has ended', 'Tu Premium terminó'),
      t('O acesso ao conteúdo foi encerrado. Renove para continuar estudando: sua conta e seu progresso continuam aqui.',
          'Access to the content has ended. Renew to keep studying: your account and progress are still here.',
          'El acceso al contenido terminó. Renueva para seguir estudiando: tu cuenta y tu progreso siguen aquí.'),
      AurudoPose.thinking,
    ),
    _Variant.existingUser => (
      t('Conheça o novo AprovaAura Premium', 'Meet the new AprovaAura Premium', 'Conoce el nuevo AprovaAura Premium'),
      t('O AprovaAura agora funciona por assinatura. Seu histórico, seu progresso e suas conquistas continuam preservados e voltam assim que você assinar.',
          'AprovaAura now works by subscription. Your history, progress and achievements are preserved and come back as soon as you subscribe.',
          'AprovaAura ahora funciona por suscripción. Tu historial, tu progreso y tus logros siguen preservados y vuelven en cuanto te suscribas.'),
      AurudoPose.neutral,
    ),
    _Variant.none => (
      t('Assine o AprovaAura Premium', 'Subscribe to AprovaAura Premium', 'Suscríbete a AprovaAura Premium'),
      t('Questões, simulados, redações e revisão dos seus erros, em todos os seus aparelhos com a mesma conta.',
          'Questions, mock exams, essays and review of your mistakes, on all your devices with the same account.',
          'Preguntas, simulacros, redacciones y revisión de tus errores, en todos tus dispositivos con la misma cuenta.'),
      AurudoPose.neutral,
    ),
    _Variant.voluntary => (
      t('Seja Premium', 'Go Premium', 'Hazte Premium'),
      t('Assine quando quiser e garanta a continuidade dos seus estudos sem interrupção.',
          'Subscribe whenever you like and keep your studies going without interruption.',
          'Suscríbete cuando quieras y asegura la continuidad de tus estudios sin interrupciones.'),
      AurudoPose.farmingAura,
    ),
    _Variant.pending => (
      t('Pagamento aguardando confirmação', 'Payment awaiting confirmation', 'Pago pendiente de confirmación'),
      t('Ainda estamos aguardando a confirmação do pagamento. Não é preciso pagar de novo: o acesso é liberado assim que for confirmado.',
          'We are still waiting for the payment to be confirmed. There is no need to pay again: access is released as soon as it is confirmed.',
          'Aún esperamos la confirmación del pago. No hace falta pagar de nuevo: el acceso se libera en cuanto se confirme.'),
      AurudoPose.thinking,
    ),
    _Variant.validating => (
      t('Confirmando seu pagamento…', 'Confirming your payment…', 'Confirmando tu pago…'),
      t('Estamos validando a compra no nosso servidor. Seu acesso só é liberado depois da confirmação.',
          'We are validating the purchase on our server. Your access is only released after confirmation.',
          'Estamos validando la compra en nuestro servidor. Tu acceso solo se libera después de la confirmación.'),
      AurudoPose.thinking,
    ),
    _Variant.declined => (
      t('O pagamento não foi concluído', 'The payment was not completed', 'El pago no se completó'),
      t('Você pode tentar novamente ou escolher outro método disponível. Nenhum acesso é liberado sem a confirmação do pagamento.',
          'You can try again or choose another available method. No access is released without payment confirmation.',
          'Puedes intentarlo de nuevo o elegir otro método disponible. No se libera ningún acceso sin la confirmación del pago.'),
      AurudoPose.frustrated,
    ),
    _Variant.unavailable => (
      t('Assinatura indisponível no momento', 'Subscription unavailable right now', 'Suscripción no disponible por ahora'),
      t('Não conseguimos carregar as opções de assinatura agora. Tente de novo em alguns minutos. Nenhuma cobrança foi feita.',
          'We could not load the subscription options right now. Try again in a few minutes. No charge was made.',
          'No pudimos cargar las opciones de suscripción ahora. Inténtalo de nuevo en unos minutos. No se hizo ningún cobro.'),
      AurudoPose.thinking,
    ),
    _Variant.active => (
      t('Seu Premium está ativo', 'Your Premium is active', 'Tu Premium está activo'),
      t('Você já tem uma assinatura vigente. Não é preciso assinar de novo.',
          'You already have an active subscription. There is no need to subscribe again.',
          'Ya tienes una suscripción vigente. No hace falta suscribirse de nuevo.'),
      AurudoPose.celebrating,
    ),
  };

  List<String> _benefits(PortalStrings t) => [
    t('Banco completo de questões e simulados', 'Full question bank and mock exams', 'Banco completo de preguntas y simulacros'),
    t('Redações com rascunhos salvos', 'Essays with saved drafts', 'Redacciones con borradores guardados'),
    t('Revisão dos seus erros e favoritos', 'Review of your mistakes and favorites', 'Revisión de tus errores y favoritos'),
    t('Mapas, atualidades e trilhas por disciplina', 'Maps, current affairs and subject tracks', 'Mapas, actualidades y rutas por asignatura'),
    t('Uma conta no Android, iOS e Web', 'One account on Android, iOS and Web', 'Una cuenta en Android, iOS y Web'),
  ];

  Future<void> _buy(PaymentsCubit cubit, _PlanOption? sel, bool web) async {
    if (sel == null) return;
    if (web) {
      await cubit.createCharge(sel.plan, _method);
    } else if (sel.store != null) {
      await cubit.buy(sel.store!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final access = context.watch<AccessCubit>();
    final pay = context.watch<PaymentsCubit>();
    final here = pay.provider;
    final web = here == PayProvider.mercadopago;
    final gate = access.gate;
    if (gate == AccessGate.paywall) _wasBlocked = true;
    final voluntary = gate == AccessGate.open;

    return BlocListener<AccessCubit, AccessState>(
      listener: (context, _) {
        // Bloqueio -> aberto: o servidor confirmou. Só então o sucesso aparece.
        if (_wasBlocked && access.gate == AccessGate.open && !_unlocked) setState(() => _unlocked = true);
      },
      child: Builder(builder: (context) {
        final s = pay.state;
        if (_unlocked || s.phase == PayPhase.success) return _Unlocked(t: t);
        final options = _options(s, t, here);
        final providerReady = s.canBuy(here);
        final variant = _variant(access, s, providerReady, options.isNotEmpty);
        final (title, body, pose) = _copy(t, variant);
        final sel = options.where((o) => o.plan == _plan).firstOrNull ?? options.firstOrNull;
        final busy = variant == _Variant.validating;
        final canBuy = providerReady && sel != null && variant != _Variant.pending && variant != _Variant.active && !busy;
        final monthly = options.where((o) => o.plan == PayPlan.monthly).firstOrNull;
        final annual = options.where((o) => o.plan == PayPlan.annual).firstOrNull;
        int? savePct;
        if (monthly?.value != null && annual?.value != null && monthly!.value! > 0) {
          final pct = ((1 - annual!.value! / (monthly.value! * 12)) * 100).round();
          if (pct >= 1) savePct = pct;
        }
        final cubit = context.read<PaymentsCubit>();
        final showPlans = options.isNotEmpty &&
            variant != _Variant.pending &&
            variant != _Variant.active &&
            variant != _Variant.unavailable;

        return PaywallFrame(
          pose: pose,
          onClose: voluntary ? () => (context.canPop() ? context.pop() : context.go('/home')) : null,
          children: [
            PaywallHeading(title: title, body: body),
            const SizedBox(height: AppSpacing.xl),
            if (s.phase == PayPhase.loading || s.phase == PayPhase.idle)
              const Center(child: SizedBox(height: 4, width: 160, child: LinearProgressIndicator()))
            else if (variant == _Variant.validating)
              const Center(child: SizedBox(height: 4, width: 160, child: LinearProgressIndicator()))
            else if (variant == _Variant.active)
              _ActiveCard(t: t, sub: s.current!, here: here, cubit: cubit)
            else ...[
              if (showPlans) ...[
                ..._benefits(t).map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(padding: EdgeInsets.only(top: 2), child: AuraGlyph(size: 16)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(b, style: TextStyle(color: context.colors.textPrimary, height: 1.3))),
                  ]),
                )),
                const SizedBox(height: AppSpacing.lg),
                if (annual != null)
                  _PlanCard(
                    t: t,
                    option: annual,
                    selected: sel?.plan == PayPlan.annual,
                    badge: savePct == null
                        ? t('Melhor valor', 'Best value', 'Mejor valor')
                        : t('Melhor valor · economize $savePct%', 'Best value · save $savePct%', 'Mejor valor · ahorra $savePct%'),
                    onTap: () => setState(() => _plan = PayPlan.annual),
                  ),
                if (annual != null && monthly != null) const SizedBox(height: AppSpacing.md),
                if (monthly != null)
                  _PlanCard(
                    t: t,
                    option: monthly,
                    selected: sel?.plan == PayPlan.monthly,
                    onTap: () => setState(() => _plan = PayPlan.monthly),
                  ),
                if (web) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _MethodPicker(t: t, method: _method, onChanged: (m) => setState(() => _method = m)),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(_terms(t, here, sel?.plan ?? PayPlan.monthly),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, height: 1.4, color: context.colors.textSecondary)),
              ],
              if (s.charge != null) ...[
                _PendingCharge(t: t, charge: s.charge!, options: options, cubit: cubit),
              ],
              if (variant == _Variant.pending && s.charge == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: OutlinedButton(
                    onPressed: () => unawaited(() async {
                      await cubit.load();
                      await access.refresh(force: true);
                    }()),
                    child: Text(t('Atualizar status', 'Refresh status', 'Actualizar estado')),
                  ),
                ),
              if (s.phase == PayPhase.failed && s.failure != null && isConnectionFailure(s.failure!))
                _Notice(t('Sem conexão. Verifique sua internet e tente de novo.',
                    'No connection. Check your internet and try again.',
                    'Sin conexión. Revisa tu internet e inténtalo de nuevo.')),
              if (s.phase == PayPhase.cancelled)
                _Notice(t('Compra cancelada. Nada foi cobrado.', 'Purchase cancelled. Nothing was charged.',
                    'Compra cancelada. No se cobró nada.')),
              if (s.phase == PayPhase.conflict)
                _Notice(t('Esta assinatura já está associada a outra conta AprovaAura. Entre nessa conta ou fale com o suporte.',
                    'This subscription is already linked to another AprovaAura account. Sign in to that account or contact support.',
                    'Esta suscripción ya está asociada a otra cuenta de AprovaAura. Entra en esa cuenta o contacta con soporte.')),
              if (s.restoreEmpty)
                _Notice(t('Nenhuma compra encontrada para restaurar nesta conta da loja.',
                    'No purchases found to restore on this store account.',
                    'No se encontraron compras para restaurar en esta cuenta de la tienda.')),
              if (variant == _Variant.unavailable)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: AppButton(
                    label: t('Tentar de novo', 'Try again', 'Intentar de nuevo'),
                    onPressed: () => unawaited(cubit.load()),
                  ),
                )
              else if (showPlans && s.charge == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: AppButton(
                    label: _cta(t, web, sel, variant == _Variant.declined),
                    isLoading: busy,
                    onPressed: canBuy ? () => unawaited(_buy(cubit, sel, web)) : null,
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(alignment: WrapAlignment.center, children: [
              if (!web)
                TextButton(
                  onPressed: busy ? null : () => unawaited(cubit.restore()),
                  child: Text(t('Restaurar compras', 'Restore purchases', 'Restaurar compras')),
                ),
              TextButton(
                onPressed: () => context.push('/minha-assinatura'),
                child: Text(t('Minha assinatura', 'My subscription', 'Mi suscripción')),
              ),
            ]),
            const AccountFooter(),
          ],
        );
      }),
    );
  }

  String _cta(PortalStrings t, bool web, _PlanOption? sel, bool retry) {
    if (sel == null) return t('Assinar', 'Subscribe', 'Suscribirse');
    final plan = sel.plan == PayPlan.annual ? t('anual', 'annual', 'anual') : t('mensal', 'monthly', 'mensual');
    if (web) {
      return _method == 'pix'
          ? t('Gerar Pix · ${sel.label}', 'Generate Pix · ${sel.label}', 'Generar Pix · ${sel.label}')
          : t('Assinar com cartão · ${sel.label}', 'Subscribe by card · ${sel.label}', 'Suscribirse con tarjeta · ${sel.label}');
    }
    final base = t('Assinar $plan · ${sel.label}', 'Subscribe $plan · ${sel.label}', 'Suscribirse $plan · ${sel.label}');
    return retry ? t('Tentar novamente · ${sel.label}', 'Try again · ${sel.label}', 'Intentar de nuevo · ${sel.label}') : base;
  }

  String _terms(PortalStrings t, PayProvider here, PayPlan plan) {
    switch (here) {
      case PayProvider.apple:
        return t(
          'A assinatura renova automaticamente pelo mesmo valor e período, a menos que seja cancelada pelo menos 24 horas antes do fim do período atual. A cobrança é feita na sua conta Apple. Gerencie ou cancele a qualquer momento nos Ajustes do aparelho.',
          'The subscription renews automatically at the same price and period unless cancelled at least 24 hours before the end of the current period. You are charged through your Apple account. Manage or cancel anytime in your device Settings.',
          'La suscripción se renueva automáticamente por el mismo precio y período, salvo que se cancele al menos 24 horas antes del fin del período actual. El cobro se hace en tu cuenta de Apple. Gestiona o cancela en cualquier momento en los Ajustes del dispositivo.',
        );
      case PayProvider.google:
        return t(
          'A assinatura renova automaticamente pelo mesmo valor e período até ser cancelada. A cobrança é feita na sua conta do Google Play. Cancele a qualquer momento no Google Play.',
          'The subscription renews automatically at the same price and period until cancelled. You are charged through your Google Play account. Cancel anytime in Google Play.',
          'La suscripción se renueva automáticamente por el mismo precio y período hasta que se cancele. El cobro se hace en tu cuenta de Google Play. Cancela en cualquier momento en Google Play.',
        );
      case PayProvider.mercadopago:
        final days = plan == PayPlan.annual ? 365 : 30;
        return _method == 'pix'
            ? t('Pix avulso: você paga uma vez e libera $days dias de acesso. Não renova sozinho: para continuar, gere um novo Pix. O período se soma ao que você já tem.',
                'One-time Pix: you pay once and get $days days of access. It does not renew by itself: to continue, generate a new Pix. The period adds to what you already have.',
                'Pix único: pagas una vez y obtienes $days días de acceso. No se renueva solo: para continuar, genera un nuevo Pix. El período se suma al que ya tienes.')
            : t('Cobrança recorrente no cartão pelo Mercado Pago: renova automaticamente até você cancelar, aqui na sua conta. O pagamento acontece no checkout oficial; o AprovaAura não vê os dados do cartão.',
                'Recurring card billing through Mercado Pago: renews automatically until you cancel, here in your account. Payment happens on the official checkout; AprovaAura never sees your card data.',
                'Cobro recurrente con tarjeta por Mercado Pago: se renueva automáticamente hasta que canceles, aquí en tu cuenta. El pago ocurre en el checkout oficial; AprovaAura no ve los datos de tu tarjeta.');
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.t, required this.option, required this.selected, required this.onTap, this.badge});
  final PortalStrings t;
  final _PlanOption option;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final annual = option.plan == PayPlan.annual;
    return Semantics(
      button: true,
      selected: selected,
      child: PaywallCard(
        highlighted: selected,
        onTap: onTap,
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? c.primary : c.textHint),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.auraViolet.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(badge!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.primary)),
                ),
              Text(annual ? t('Premium anual', 'Annual Premium', 'Premium anual') : t('Premium mensal', 'Monthly Premium', 'Premium mensual'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
              Text(annual ? t('Cobrança uma vez por ano', 'Billed once a year', 'Cobro una vez al año') : t('Cobrança todo mês', 'Billed monthly', 'Cobro mensual'),
                  style: TextStyle(fontSize: 12, color: c.textSecondary)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(option.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
            Text(annual ? t('/ano', '/year', '/año') : t('/mês', '/month', '/mes'),
                style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ]),
        ]),
      ),
    );
  }
}

class _MethodPicker extends StatelessWidget {
  const _MethodPicker({required this.t, required this.method, required this.onChanged});
  final PortalStrings t;
  final String method;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget tile(String id, String title, String sub) => PaywallCard(
      highlighted: method == id,
      onTap: () => onChanged(id),
      child: Row(children: [
        Icon(method == id ? Icons.radio_button_checked : Icons.radio_button_off, color: method == id ? c.primary : c.textHint),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary)),
            Text(sub, style: TextStyle(fontSize: 12, height: 1.3, color: c.textSecondary)),
          ]),
        ),
      ]),
    );
    return Column(children: [
      tile('card', t('Cartão (recorrente)', 'Card (recurring)', 'Tarjeta (recurrente)'),
          t('Renova sozinho até você cancelar.', 'Renews by itself until you cancel.', 'Se renueva solo hasta que canceles.')),
      const SizedBox(height: AppSpacing.sm),
      tile('pix', t('Pix (avulso)', 'Pix (one-time)', 'Pix (único)'),
          t('Paga uma vez, sem renovação automática.', 'Pay once, no automatic renewal.', 'Pagas una vez, sin renovación automática.')),
    ]);
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md),
    child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: context.colors.warning)),
  );
}

class _PendingCharge extends StatelessWidget {
  const _PendingCharge({required this.t, required this.charge, required this.options, required this.cubit});
  final PortalStrings t;
  final PixCharge charge;
  final List<_PlanOption> options;
  final PaymentsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final label = t.money(charge.amountCents);
    final name = charge.plan == PayPlan.annual
        ? t('Premium anual', 'Annual Premium', 'Premium anual')
        : t('Premium mensal', 'Monthly Premium', 'Premium mensual');
    if (charge.method == 'pix') {
      return PaywallCard(
        child: PixPaymentPanel(
          charge: charge,
          planName: name,
          priceLabel: label,
          onCheck: cubit.checkCharge,
          onNewCharge: () => unawaited(cubit.createCharge(charge.plan, 'pix')),
        ),
      );
    }
    return PaywallCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('$name · $label', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(t('Conclua a assinatura no checkout oficial do Mercado Pago. Depois, volte aqui e toque em verificar: o acesso só é liberado quando o servidor confirmar.',
            'Finish the subscription on the official Mercado Pago checkout. Then come back and tap check: access is only released once the server confirms.',
            'Completa la suscripción en el checkout oficial de Mercado Pago. Luego vuelve aquí y toca verificar: el acceso solo se libera cuando el servidor lo confirme.')),
        const SizedBox(height: AppSpacing.md),
        if (charge.checkoutUrl != null)
          AppButton(
            label: t('Abrir checkout', 'Open checkout', 'Abrir checkout'),
            onPressed: () => unawaited(openExternalLink(context, charge.checkoutUrl!)),
          ),
        TextButton(
          onPressed: () => unawaited(cubit.checkCharge()),
          child: Text(t('Já concluí — verificar', 'I finished — check', 'Ya terminé — verificar')),
        ),
      ]),
    );
  }
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({required this.t, required this.sub, required this.here, required this.cubit});
  final PortalStrings t;
  final SubscriptionInfo sub;
  final PayProvider here;
  final PaymentsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final info = manageFor(t, sub, here);
    return PaywallCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(t('Provedor: ${providerName(t, sub.provider)}', 'Provider: ${providerName(t, sub.provider)}',
            'Proveedor: ${providerName(t, sub.provider)}'), style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Text(info.text),
        if (info.url != null)
          TextButton(
            onPressed: () => unawaited(openExternalLink(context, info.url!)),
            child: Text(t('Gerenciar assinatura', 'Manage subscription', 'Gestionar suscripción')),
          ),
        TextButton(
          onPressed: () => context.push('/minha-assinatura'),
          child: Text(t('Ver detalhes', 'See details', 'Ver detalles')),
        ),
      ]),
    );
  }
}

/// Confirmação visual: só existe depois que o servidor confirmou e o acesso
/// foi reaberto. Conta, progresso e dados seguem como estavam; sem logout.
class _Unlocked extends StatelessWidget {
  const _Unlocked({required this.t});
  final PortalStrings t;

  @override
  Widget build(BuildContext context) {
    return PaywallFrame(
      pose: AurudoPose.celebrating,
      aurudoSize: 180,
      children: [
        PaywallHeading(
          title: t('Premium ativado!', 'Premium activated!', '¡Premium activado!'),
          body: t('Pagamento confirmado. Sua conta e todo o seu progresso estão do jeito que você deixou. Bons estudos!',
              'Payment confirmed. Your account and all your progress are just as you left them. Happy studying!',
              'Pago confirmado. Tu cuenta y todo tu progreso están como los dejaste. ¡Buenos estudios!'),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: t('Continuar estudando', 'Keep studying', 'Seguir estudiando'),
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }
}

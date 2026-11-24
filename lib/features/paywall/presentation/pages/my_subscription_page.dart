import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/payments/domain/payments.dart';
import 'package:aura/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:aura/features/paywall/presentation/widgets/paywall_common.dart';
import 'package:aura/features/paywall/presentation/widgets/trial_banner.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/shared/utils/external_link.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// "Minha assinatura": situação real do acesso (todas as fontes), assinaturas
/// comerciais com gerenciamento compatível com a plataforma e histórico de
/// pagamentos. Funciona também com o acesso bloqueado. Cortesia e papéis
/// administrativos NUNCA aparecem como assinatura cancelável.
class MySubscriptionPage extends StatelessWidget {
  const MySubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<PaymentsCubit>()..load(),
    child: const _View(),
  );
}

class _View extends StatefulWidget {
  const _View();
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late final Future<Result<List<PaymentRecord>>> _history = sl<PaymentsRepository>().history();

  String _stateLabel(PortalStrings t, String s) => switch (s) {
    'active' => t('Ativa', 'Active', 'Activa'),
    'grace' => t('Em carência (pagamento a regularizar)', 'In grace period (payment to fix)', 'En gracia (pago por regularizar)'),
    'canceled' => t('Cancelada — vale até o fim do período', 'Cancelled — valid until the period ends', 'Cancelada — vale hasta el fin del período'),
    'pending' => t('Aguardando confirmação', 'Awaiting confirmation', 'Esperando confirmación'),
    'expired' => t('Expirada', 'Expired', 'Vencida'),
    'refunded' => t('Reembolsada', 'Refunded', 'Reembolsada'),
    _ => s,
  };

  String _payStatus(PortalStrings t, String s) => switch (s) {
    'confirmed' => t('Confirmado', 'Confirmed', 'Confirmado'),
    'partially_refunded' => t('Reembolso parcial', 'Partially refunded', 'Reembolso parcial'),
    'refunded' => t('Reembolsado', 'Refunded', 'Reembolsado'),
    'charged_back' => t('Contestado', 'Charged back', 'Contracargo'),
    _ => s,
  };

  String _plan(PortalStrings t, PayPlan p) =>
      p == PayPlan.annual ? t('Anual', 'Annual', 'Anual') : t('Mensal', 'Monthly', 'Mensual');

  Widget _row(BuildContext context, String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 130, child: Text(k, style: TextStyle(color: context.colors.textSecondary, fontSize: 13))),
      Expanded(child: Text(v, style: TextStyle(color: context.colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final access = context.watch<AccessCubit>().state;
    final pay = context.watch<PaymentsCubit>();
    final s = pay.state;
    final st = access.status;
    final here = pay.provider;
    final live = s.overview.subscriptions.where((x) => x.isLive).toList();
    final origins = <Widget>[];

    void origin(String title, String body) => origins.add(PaywallCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
        const SizedBox(height: 4),
        Text(body, style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
      ]),
    ));

    if (st.isAdmin) {
      origin(t('Administrador', 'Administrator', 'Administrador'),
          t('Premium como benefício administrativo, enquanto você tiver o papel.',
              'Premium as an administrative benefit, for as long as you hold the role.',
              'Premium como beneficio administrativo, mientras tengas el rol.'));
    }
    if (st.isPartner) {
      origin(t('Professor parceiro', 'Partner teacher', 'Profesor asociado'),
          t('Acesso vinculado à parceria ativa. Termina junto com a parceria.',
              'Access tied to the active partnership. It ends with the partnership.',
              'Acceso vinculado a la alianza activa. Termina con la alianza.'));
    }
    if (st.sources.contains('courtesy')) {
      origin(t('Cortesia', 'Courtesy', 'Cortesía'),
          st.accessUntil != null && !st.indefinite
              ? t('Concedida pela equipe. Válida até ${t.dateTime(st.accessUntil)}.',
                  'Granted by the team. Valid until ${t.dateTime(st.accessUntil)}.',
                  'Concedida por el equipo. Válida hasta ${t.dateTime(st.accessUntil)}.')
              : t('Concedida pela equipe, sem data de término.', 'Granted by the team, with no end date.',
                  'Concedida por el equipo, sin fecha de fin.'));
    }
    if (st.sources.contains('transition')) {
      origin(t('Período de transição', 'Transition period', 'Período de transición'),
          t('Acesso temporário para quem já usava o AprovaAura.', 'Temporary access for existing users.',
              'Acceso temporal para quienes ya usaban AprovaAura.'));
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(children: [
        ModernAppBar(
          title: t('Minha assinatura', 'My subscription', 'Mi suscripción'),
          showBackButton: true,
          onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                children: [
                  // Status geral.
                  PaywallCard(
                    highlighted: st.allowed,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        !st.enforced
                            ? t('Todos os recursos estão liberados no momento.', 'All features are available right now.',
                                'Todos los recursos están disponibles por ahora.')
                            : st.allowed
                                ? t('Premium ativo', 'Premium active', 'Premium activo')
                                : t('Sem Premium ativo', 'No active Premium', 'Sin Premium activo'),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.colors.textPrimary),
                      ),
                      if (st.enforced && st.allowed && st.accessUntil != null && !st.indefinite)
                        _row(context, t('Acesso até', 'Access until', 'Acceso hasta'), t.dateTime(st.accessUntil)),
                      if (st.enforced && st.allowed && st.indefinite)
                        _row(context, t('Validade', 'Validity', 'Vigencia'), t('Sem data de término', 'No end date', 'Sin fecha de fin')),
                      if (st.fromOfflineGrant)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            t('Você está offline: mostrando a última autorização verificada.',
                                'You are offline: showing the last verified authorization.',
                                'Estás sin conexión: mostrando la última autorización verificada.'),
                            style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                          ),
                        ),
                    ]),
                  ),
                  if (st.enforced && st.allowed && st.trialOnly && st.accessUntil != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    TrialSummaryCard(status: st),
                  ],
                  for (final w in origins) ...[const SizedBox(height: AppSpacing.md), w],
                  for (final sub in live) ...[
                    const SizedBox(height: AppSpacing.md),
                    _SubscriptionCard(
                      t: t,
                      sub: sub,
                      here: here,
                      stateLabel: _stateLabel(t, sub.state),
                      plan: _plan(t, sub.plan),
                      row: _row,
                      onCancelCard: () => unawaited(_confirmCancel(context, pay, t)),
                    ),
                  ],
                  if (live.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        t('Você tem mais de uma fonte de acesso. Elas não se cancelam: o acesso vale enquanto qualquer uma estiver vigente.',
                            'You have more than one source of access. They do not cancel each other: access holds while any one is active.',
                            'Tienes más de una fuente de acceso. No se cancelan entre sí: el acceso vale mientras alguna esté vigente.'),
                        style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                      ),
                    ),
                  if (live.isEmpty && !st.isStaff) ...[
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: t('Ver planos', 'See plans', 'Ver planes'),
                      onPressed: () => context.push('/assinatura'),
                    ),
                  ],
                  if (here != PayProvider.mercadopago)
                    TextButton(
                      onPressed: () => unawaited(pay.restore()),
                      child: Text(t('Restaurar compras', 'Restore purchases', 'Restaurar compras')),
                    ),
                  if (s.restoreEmpty)
                    Text(t('Nenhuma compra encontrada para restaurar.', 'No purchases found to restore.',
                        'No se encontraron compras para restaurar.'),
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                  const SizedBox(height: AppSpacing.xl),
                  Text(t('Histórico de pagamentos', 'Payment history', 'Historial de pagos'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  FutureBuilder(
                    future: _history,
                    builder: (context, snap) {
                      final r = snap.data;
                      if (r == null) return const Center(child: Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()));
                      if (r is Error<List<PaymentRecord>>) {
                        return Text(t('Não foi possível carregar o histórico agora.', 'Could not load the history right now.',
                            'No se pudo cargar el historial ahora.'));
                      }
                      final items = (r as Success<List<PaymentRecord>>).data;
                      if (items.isEmpty) {
                        return Text(t('Nenhum pagamento registrado.', 'No payments recorded.', 'Ningún pago registrado.'),
                            style: TextStyle(color: context.colors.textSecondary));
                      }
                      return Column(children: [
                        for (final p in items)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('${_plan(t, p.plan)} · ${t.money(p.amountCents)}'),
                            subtitle: Text('${t.date(p.paidAt)} · ${providerName(t, p.provider)}'),
                            trailing: Text(_payStatus(t, p.status), style: const TextStyle(fontSize: 12)),
                          ),
                      ]);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AccountFooter(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _confirmCancel(BuildContext context, PaymentsCubit pay, PortalStrings t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Cancelar renovação?', 'Cancel renewal?', '¿Cancelar la renovación?')),
        content: Text(t('Você mantém o acesso até o fim do período já pago e não será cobrado(a) de novo.',
            'You keep access until the end of the period already paid and will not be charged again.',
            'Mantienes el acceso hasta el fin del período ya pagado y no se te cobrará de nuevo.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('Voltar', 'Back', 'Volver'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('Cancelar renovação', 'Cancel renewal', 'Cancelar renovación'))),
        ],
      ),
    );
    if (ok == true) await pay.cancelCard();
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.t,
    required this.sub,
    required this.here,
    required this.stateLabel,
    required this.plan,
    required this.row,
    required this.onCancelCard,
  });
  final PortalStrings t;
  final SubscriptionInfo sub;
  final PayProvider here;
  final String stateLabel;
  final String plan;
  final Widget Function(BuildContext, String, String) row;
  final VoidCallback onCancelCard;

  @override
  Widget build(BuildContext context) {
    final info = manageFor(t, sub, here);
    final renews = sub.autoRenew == true;
    return PaywallCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t('Assinatura comercial', 'Commercial subscription', 'Suscripción comercial'),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        row(context, t('Situação', 'Status', 'Estado'), stateLabel),
        row(context, t('Plano', 'Plan', 'Plan'), plan),
        row(context, t('Provedor', 'Provider', 'Proveedor'), providerName(t, sub.provider)),
        row(context, t('Início', 'Started', 'Inicio'), t.date(sub.since)),
        row(context, renews ? t('Próxima renovação', 'Next renewal', 'Próxima renovación') : t('Acesso até', 'Access until', 'Acceso hasta'),
            t.dateTime(sub.periodEnd)),
        row(context, t('Renovação', 'Renewal', 'Renovación'),
            renews ? t('Automática', 'Automatic', 'Automática') : t('Manual — não renova sozinha', 'Manual — does not renew by itself', 'Manual — no se renueva sola')),
        if (sub.sandbox)
          row(context, t('Ambiente', 'Environment', 'Entorno'), t('Teste (sandbox)', 'Test (sandbox)', 'Prueba (sandbox)')),
        const SizedBox(height: 6),
        Text(info.text, style: const TextStyle(fontSize: 13)),
        if (info.url != null)
          TextButton(
            onPressed: () => unawaited(openExternalLink(context, info.url!)),
            child: Text(t('Gerenciar assinatura', 'Manage subscription', 'Gestionar suscripción')),
          ),
        if (sub.provider == PayProvider.mercadopago && here == PayProvider.mercadopago && renews)
          TextButton(
            onPressed: onCancelCard,
            child: Text(t('Cancelar renovação', 'Cancel renewal', 'Cancelar renovación')),
          ),
      ]),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

// Integrações de pagamento (Etapa 07), somente leitura + reprocessamento seguro.
// Nenhum segredo trafega aqui; o reprocessamento só recoloca um evento FALHO na
// fila (o servidor relê o provedor) — não cria nem edita pagamentos.
//
// Origem de cada estado (ver admin_payments_status, migration 20261129000100):
//  - "Provedor habilitado": payment_providers_config.enabled (liga/desliga real, por ambiente).
//  - "Produto no backend": linhas de payment_catalog (o RPC não devolve `active`).
//  - "Conferido na loja": payment_catalog.verified (manual; homologar no sandbox NÃO altera).
//  - "Falhas/conflitos": payment_events agrupado por PROVEDOR (o RPC não separa por ambiente).
//  - O resto (implementação, credenciais, homologação) o banco não sabe: vem de [_evidence].

List<Map<String, dynamic>> _l(dynamic v) => [for (final e in (v as List? ?? const [])) Map<String, dynamic>.from(e as Map)];

String _provider(String p) => switch (p) { 'apple' => 'Apple', 'google' => 'Google Play', _ => 'Mercado Pago' };

/// Evidência DOCUMENTADA (não vem do banco): data e documento-fonte são obrigatórios.
class _Evidence {
  const _Evidence({
    required this.provider,
    required this.date,
    required this.source,
    required this.implemented,
    required this.credentials,
    required this.sandbox,
    required this.pending,
  });
  final String provider;
  final String date;
  final String source;
  final (String, String, String) implemented;
  final (String, String, String) credentials;
  final (String, String, String) sandbox;
  final List<(String, String, String)> pending;
}

const _evidence = <_Evidence>[
  _Evidence(
    provider: 'apple',
    date: '2026-11-27',
    source: 'docs/qa/APPLE_STOREKIT_HOMOLOGACAO.md; docs/release/HOMOLOGACAO_FINAL_2026-11-27.md',
    implemented: ('Implementada (StoreKit 2 + App Store Server API + notificações V2).', 'Implemented (StoreKit 2 + App Store Server API + V2 notifications).', 'Implementada (StoreKit 2 + App Store Server API + notificaciones V2).'),
    credentials: (
      'Chave IAP e Secrets configurados segundo o relatório de 25/11; não verificável pelo portal.',
      'IAP key and Secrets configured per the 25/11 report; not verifiable from the portal.',
      'Clave IAP y Secrets configurados según el informe del 25/11; no verificable desde el portal.'
    ),
    sandbox: (
      'Sandbox: compra, renovação, troca de plano, cancelamento e expiração homologados; reembolso/revogação, carência e Ask to Buy só simulados.',
      'Sandbox: purchase, renewal, plan change, cancellation and expiry homologated; refund/revocation, grace and Ask to Buy only simulated.',
      'Sandbox: compra, renovación, cambio de plan, cancelación y expiración homologados; reembolso/revocación, gracia y Ask to Buy solo simulados.'
    ),
    pending: [
      ('Backup do .p8, nível dos produtos e carência, Small Business Program.', '.p8 backup, product tier and grace period, Small Business Program.', 'Respaldo del .p8, nivel de productos y gracia, Small Business Program.'),
      ('Localização, imagem e captura de revisão do grupo; primeira assinatura vai com nova versão do app.', 'Group localization, image and review screenshot; first subscription ships with a new app version.', 'Localización, imagen y captura de revisión del grupo; la primera suscripción va con una nueva versión de la app.'),
      ('URL de notificação de produção só na ativação; relatórios financeiros reais pendentes.', 'Production notification URL only at activation; real financial reports pending.', 'URL de notificación de producción solo en la activación; informes financieros reales pendientes.'),
    ],
  ),
  _Evidence(
    provider: 'google',
    date: '2026-11-25',
    source: 'docs/qa/GOOGLE_PLAY_HOMOLOGACAO.md §9–10; docs/release/HOMOLOGACAO_FINAL_2026-11-27.md §4',
    implemented: ('Implementada (payments-google + conciliação payments-reconcile).', 'Implemented (payments-google + payments-reconcile reconciliation).', 'Implementada (payments-google + conciliación payments-reconcile).'),
    credentials: (
      'Conta de serviço e Secrets instalados segundo o relatório de 25/11; não verificável pelo portal.',
      'Service account and Secrets installed per the 25/11 report; not verifiable from the portal.',
      'Cuenta de servicio y Secrets instalados según el informe del 25/11; no verificable desde el portal.'
    ),
    sandbox: (
      'Teste licenciado real no emulador: mensal, anual, recusa, renovação, cancelamento, expiração, restauração, estorno, carência, retenção e recuperação homologados; sem RTDN.',
      'Real licensed test on emulator: monthly, annual, decline, renewal, cancellation, expiry, restore, refund, grace, hold and recovery homologated; no RTDN.',
      'Prueba con licencia real en emulador: mensual, anual, rechazo, renovación, cancelación, expiración, restauración, reembolso, gracia, retención y recuperación homologados; sin RTDN.'
    ),
    pending: [
      ('Base plans estão em rascunho: ativar no Play Console.', 'Base plans are drafts: activate in Play Console.', 'Los base plans están en borrador: activar en Play Console.'),
      ('RTDN/Pub/Sub bloqueado por faturamento do Cloud; agendamento da conciliação não criado.', 'RTDN/Pub/Sub blocked by Cloud billing; reconciliation schedule not created.', 'RTDN/Pub/Sub bloqueado por facturación de Cloud; programación de la conciliación no creada.'),
      ('Falta 2ª conta de teste e reinstalação com dados limpos; relatórios financeiros reais pendentes.', '2nd test account and clean-data reinstall missing; real financial reports pending.', 'Falta 2.ª cuenta de prueba y reinstalación con datos limpios; informes financieros reales pendientes.'),
    ],
  ),
  _Evidence(
    provider: 'mercadopago',
    date: '2026-11-27',
    source: 'docs/qa/MERCADOPAGO_HOMOLOGACAO.md §11; docs/release/HOMOLOGACAO_FINAL_2026-11-27.md §4',
    implemented: ('Implementada (mp-checkout, mp-webhook com HMAC, payments-reconcile).', 'Implemented (mp-checkout, mp-webhook with HMAC, payments-reconcile).', 'Implementada (mp-checkout, mp-webhook con HMAC, payments-reconcile).'),
    credentials: (
      'Produção própria do AprovaAura NÃO definida (token e segredo de webhook de produção ausentes, de propósito); não verificável pelo portal.',
      'AprovaAura production credentials NOT set (production token and webhook secret absent on purpose); not verifiable from the portal.',
      'Producción propia de AprovaAura NO definida (token y secreto de webhook de producción ausentes, a propósito); no verificable desde el portal.'
    ),
    sandbox: (
      'Sandbox real: cartão mensal/anual, HMAC, cancelamento, recusa, idempotência e entitlement homologados; Pix e reembolso só em mocks/SQL (401 do sandbox).',
      'Real sandbox: monthly/annual card, HMAC, cancellation, decline, idempotency and entitlement homologated; Pix and refund only mocks/SQL (sandbox 401).',
      'Sandbox real: tarjeta mensual/anual, HMAC, cancelación, rechazo, idempotencia y entitlement homologados; Pix y reembolso solo en mocks/SQL (401 del sandbox).'
    ),
    pending: [
      ('Decidir a aplicação de produção; segredo de webhook de produção no cofre.', 'Decide the production application; production webhook secret in the vault.', 'Decidir la aplicación de producción; secreto de webhook de producción en la bóveda.'),
      ('Pix real de valor mínimo (exige autorização do dono) e chamado ao MP sobre o 401 de Pix/reembolso.', 'Real minimum-value Pix (needs owner authorization) and MP ticket on the Pix/refund 401.', 'Pix real de valor mínimo (requiere autorización del dueño) y caso en MP sobre el 401 de Pix/reembolso.'),
      ('Relatório de liberações real para validar o importador.', 'Real release report to validate the importer.', 'Informe de liberaciones real para validar el importador.'),
    ],
  ),
];

class IntegrationsPage extends StatefulWidget {
  const IntegrationsPage({super.key});
  @override
  State<IntegrationsPage> createState() => _IntegrationsPageState();
}

class _IntegrationsPageState extends State<IntegrationsPage> {
  String _status = 'failed';

  Widget _providerPanel(BuildContext context, PortalStrings t, _Evidence ev, List<Map<String, dynamic>> cfg, List<Map<String, dynamic>> cat, Map<String, dynamic> events) {
    final c = context.colors;
    final id = ev.provider;
    final stats = Map<String, dynamic>.from((events[id] as Map?) ?? {});
    final failed = (stats['failed'] as num?) ?? 0;
    final conflicts = (stats['conflicts'] as num?) ?? 0;
    final envs = ['sandbox', 'production'];
    String envName(String e) => e == 'production' ? t('Produção', 'Production', 'Producción') : 'Sandbox';
    Widget caption(String s) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(s, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.textSecondary)),
        );
    return Panel(
      title: _provider(id),
      trailing: Wrap(spacing: 8, children: [
        if (failed > 0) StatusBadge('${t('Falhas', 'Failures', 'Fallos')}: $failed', tone: Tone.bad),
        if (conflicts > 0) StatusBadge('${t('Conflitos', 'Conflicts', 'Conflictos')}: $conflicts', tone: Tone.warn),
        if (failed == 0 && conflicts == 0) StatusBadge(t('Sem falha operacional', 'No operational failure', 'Sin fallo operativo'), tone: Tone.good),
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PortalTable(
          columns: [
            PortalColumn(t('Ambiente', 'Environment', 'Entorno')),
            PortalColumn(t('Provedor habilitado', 'Provider enabled', 'Proveedor habilitado'), flex: 2),
            PortalColumn(t('Produtos no backend', 'Products in backend', 'Productos en backend'), flex: 2),
            PortalColumn(t('Conferidos na loja', 'Checked in store', 'Verificados en tienda'), flex: 2),
          ],
          rows: [
            for (final e in envs)
              () {
                final conf = cfg.where((x) => x['provider'] == id && x['environment'] == e).firstOrNull;
                final prods = cat.where((x) => x['provider'] == id && x['environment'] == e).toList();
                final ok = prods.where((x) => x['verified'] == true).length;
                return <Widget>[
                  Text(envName(e)),
                  conf == null
                      ? StatusBadge(t('Sem registro', 'No record', 'Sin registro'))
                      : StatusBadge(conf['enabled'] == true ? t('Habilitado', 'Enabled', 'Habilitado') : t('Desligado', 'Off', 'Apagado'),
                          tone: conf['enabled'] == true ? Tone.good : Tone.neutral),
                  prods.isEmpty
                      ? StatusBadge(t('Nenhum', 'None', 'Ninguno'))
                      : StatusBadge('${prods.length} ${t('configurado(s)', 'configured', 'configurado(s)')}', tone: Tone.info),
                  prods.isEmpty
                      ? const Text('—')
                      : StatusBadge('$ok/${prods.length} ${t('conferido(s)', 'checked', 'verificado(s)')}', tone: ok == prods.length ? Tone.good : Tone.warn),
                ];
              }(),
          ],
        ),
        caption(t('Produtos e preços de referência', 'Products and reference prices', 'Productos y precios de referencia')),
        PortalTable(
          columns: [
            PortalColumn(t('Ambiente', 'Environment', 'Entorno')),
            PortalColumn(t('Plano', 'Plan', 'Plan')),
            PortalColumn(t('Produto', 'Product', 'Producto'), flex: 3),
            PortalColumn(t('Preço de referência', 'Reference price', 'Precio de referencia'), flex: 2),
            PortalColumn(t('Conferido na loja', 'Checked in store', 'Verificado en tienda'), flex: 2),
          ],
          rows: [
            for (final p in cat.where((x) => x['provider'] == id))
              [
                Text(envName('${p['environment']}')),
                Text(p['plan'] == 'annual' ? t('Anual', 'Annual', 'Anual') : t('Mensal', 'Monthly', 'Mensual')),
                Text('${p['product_id']}${p['base_plan_id'] != null ? ' / ${p['base_plan_id']}' : ''}'),
                Text(t.money(p['price_cents'] as num)),
                StatusBadge(p['verified'] == true ? t('Conferido', 'Checked', 'Verificado') : t('Não conferido', 'Not checked', 'No verificado'),
                    tone: p['verified'] == true ? Tone.good : Tone.warn),
              ],
          ],
        ),
        caption(t('Evidências documentadas (${ev.date}) — não vêm do banco', 'Documented evidence (${ev.date}) — not from the database', 'Evidencias documentadas (${ev.date}) — no vienen de la base de datos')),
        KeyValue(t('Implementação', 'Implementation', 'Implementación'), Text(t(ev.implemented.$1, ev.implemented.$2, ev.implemented.$3))),
        KeyValue(t('Credenciais', 'Credentials', 'Credenciales'), Text(t(ev.credentials.$1, ev.credentials.$2, ev.credentials.$3))),
        KeyValue(t('Homologação', 'Homologation', 'Homologación'), Text(t(ev.sandbox.$1, ev.sandbox.$2, ev.sandbox.$3))),
        KeyValue(t('Pendência comercial', 'Commercial pending', 'Pendiente comercial'), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final p in ev.pending) Text('• ${t(p.$1, p.$2, p.$3)}'),
        ])),
        KeyValue(t('Falha operacional', 'Operational failure', 'Fallo operativo'), Text(
          '${t('Falhos', 'Failed', 'Fallidos')}: $failed · ${t('Conflitos', 'Conflicts', 'Conflictos')}: $conflicts · '
          '${t('Último evento', 'Last event', 'Último evento')}: ${stats['last_at'] == null ? '—' : t.dateTime(DateTime.tryParse('${stats['last_at']}'))} '
          '(${t('todos os ambientes', 'all environments', 'todos los entornos')})',
        )),
        KeyValue(t('Fonte', 'Source', 'Fuente'), Text(ev.source, style: TextStyle(color: c.textSecondary))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Integrações de pagamento', 'Payment integrations', 'Integraciones de pago'),
        subtitle: t(
            '"Habilitado" é a liga/desliga real do banco por ambiente. "Conferido na loja" é um aviso manual e NÃO muda quando o sandbox é homologado. Homologação, credenciais e pendências vêm de relatórios datados.',
            '"Enabled" is the real per-environment switch in the database. "Checked in store" is a manual flag and does NOT change when the sandbox is homologated. Homologation, credentials and pending items come from dated reports.',
            '"Habilitado" es el interruptor real por entorno en la base. "Verificado en tienda" es una marca manual y NO cambia al homologar el sandbox. Homologación, credenciales y pendientes vienen de informes fechados.'),
      ),
      Loader<Map<String, dynamic>>(
        loader: api.paymentsStatus,
        builder: (context, d, reload) {
          final cfg = _l(d['config']);
          final cat = _l(d['catalog']);
          final ev = Map<String, dynamic>.from((d['events'] as Map?) ?? {});
          final pendingRec = (d['pending_reconciliation'] as num?) ?? 0;
          final conflicts = (d['unresolved_conflicts'] as num?) ?? 0;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CardGrid(children: [
              StatCard(label: t('Pagamentos a conciliar', 'Payments to reconcile', 'Pagos por conciliar'), value: '$pendingRec', tone: pendingRec > 0 ? Tone.warn : null),
              StatCard(label: t('Conflitos de conta', 'Account conflicts', 'Conflictos de cuenta'), value: '$conflicts', tone: conflicts > 0 ? Tone.bad : null),
              StatCard(label: t('Assinaturas ativas', 'Active subscriptions', 'Suscripciones activas'), value: '${(d['subscriptions'] as Map?)?['active'] ?? 0}'),
            ]),
            for (final e in _evidence) ...[
              const SizedBox(height: kSectionGap),
              _providerPanel(context, t, e, cfg, cat, ev),
            ],
          ]);
        },
      ),
      const SizedBox(height: kSectionGap),
      SectionHeader(t('Eventos de pagamento', 'Payment events', 'Eventos de pago')),
      PortalTabs<String>(
        tabs: {
          'failed': t('Falhos', 'Failed', 'Fallidos'),
          'conflict': t('Conflitos', 'Conflicts', 'Conflictos'),
          'processed': t('Processados', 'Processed', 'Procesados'),
        },
        value: _status,
        onChanged: (s) => setState(() => _status = s),
      ),
      Loader<Map<String, dynamic>>(
        loader: () => api.paymentEvents(status: _status),
        keys: [_status],
        builder: (context, d, reload) {
          final rows = _l(d['rows']);
          if (rows.isEmpty) return EmptyState(message: t('Nenhum evento.', 'No events.', 'Sin eventos.'));
          return Panel(
            title: t('Histórico de processamento', 'Processing history', 'Historial de procesamiento'),
            child: PortalTable(
              columns: [
                PortalColumn(t('Quando', 'When', 'Cuándo'), flex: 2),
                PortalColumn(t('Provedor', 'Provider', 'Proveedor'), flex: 2),
                PortalColumn(t('Tipo', 'Type', 'Tipo'), flex: 2),
                PortalColumn(t('Tentativas', 'Attempts', 'Intentos')),
                PortalColumn(t('Erro', 'Error', 'Error'), flex: 3),
                const PortalColumn('', flex: 2),
              ],
              rows: [
                for (final e in rows)
                  [
                    Text(t.dateTime(DateTime.tryParse('${e['received_at']}'))),
                    Text('${_provider('${e['provider']}')}${e['environment'] == 'sandbox' ? ' (sandbox)' : ''}'),
                    Text('${e['type']}'),
                    Text('${e['attempts']}'),
                    Text('${e['last_error'] ?? ''}'),
                    if (e['status'] == 'failed')
                      TextButton(
                        onPressed: () async {
                          final confirmed = await confirmDialog(context,
                              title: t('Reprocessar evento', 'Reprocess event', 'Reprocesar evento'),
                              message: t('O servidor relerá o estado oficial no provedor. Nada é criado manualmente.',
                                  'The server will re-read the official state from the provider. Nothing is created manually.',
                                  'El servidor releerá el estado oficial en el proveedor. No se crea nada manualmente.'),
                              action: t('Reprocessar', 'Reprocess', 'Reprocesar'));
                          if (!confirmed) return;
                          if (!context.mounted) return;
                          if (await runAction(context, () => api.requeuePaymentEvent(e['id'] as int),
                              success: t('Na fila para reprocessar.', 'Queued for reprocessing.', 'En cola para reprocesar.'))) {
                            await reload();
                          }
                        },
                        child: Text(t('Reprocessar', 'Reprocess', 'Reprocesar')),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
              ],
            ),
          );
        },
      ),
    ]);
  }
}

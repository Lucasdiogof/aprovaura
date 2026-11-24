import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

// Integrações de pagamento (Etapa 07), somente leitura + reprocessamento seguro.
// Nenhum segredo trafega aqui; o reprocessamento só recoloca um evento FALHO na
// fila (o servidor relê o provedor) — não cria nem edita pagamentos.

List<Map<String, dynamic>> _l(dynamic v) => [for (final e in (v as List? ?? const [])) Map<String, dynamic>.from(e as Map)];

String _provider(String p) => switch (p) { 'apple' => 'Apple', 'google' => 'Google Play', _ => 'Mercado Pago' };

class IntegrationsPage extends StatefulWidget {
  const IntegrationsPage({super.key});
  @override
  State<IntegrationsPage> createState() => _IntegrationsPageState();
}

class _IntegrationsPageState extends State<IntegrationsPage> {
  String? _status = 'failed';

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: t('Integrações de pagamento', 'Payment integrations', 'Integraciones de pago')),
      Loader<Map<String, dynamic>>(
        loader: api.paymentsStatus,
        builder: (context, d, reload) {
          final cfg = _l(d['config']);
          final cat = _l(d['catalog']);
          final ev = Map<String, dynamic>.from((d['events'] as Map?) ?? {});
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CardGrid(children: [
              StatCard(label: t('Pagamentos a conciliar', 'Payments to reconcile', 'Pagos por conciliar'), value: '${d['pending_reconciliation']}'),
              StatCard(label: t('Conflitos de conta', 'Account conflicts', 'Conflictos de cuenta'), value: '${d['unresolved_conflicts']}'),
              StatCard(label: t('Assinaturas ativas', 'Active subscriptions', 'Suscripciones activas'), value: '${(d['subscriptions'] as Map?)?['active'] ?? 0}'),
            ]),
            const SizedBox(height: 16),
            Panel(
              title: t('Provedores e ambientes', 'Providers and environments', 'Proveedores y entornos'),
              child: PortalTable(
                columns: [
                  PortalColumn(t('Provedor', 'Provider', 'Proveedor'), flex: 2),
                  PortalColumn(t('Ambiente', 'Environment', 'Entorno')),
                  PortalColumn(t('Compra', 'Purchase', 'Compra')),
                  PortalColumn(t('Último evento', 'Last event', 'Último evento'), flex: 2),
                  PortalColumn(t('Falhas', 'Failures', 'Fallos')),
                ],
                rows: [
                  for (final c in cfg)
                    [
                      Text(_provider('${c['provider']}')),
                      Text(c['environment'] == 'production' ? t('Produção', 'Production', 'Producción') : 'Sandbox'),
                      StatusBadge(c['enabled'] == true ? t('Liberada', 'Enabled', 'Habilitada') : t('Desligada', 'Off', 'Apagada'),
                          tone: c['enabled'] == true ? Tone.good : Tone.neutral),
                      Text(c['environment'] == 'production'
                          ? t.dateTime(DateTime.tryParse('${(ev[c['provider']] as Map?)?['last_at']}'))
                          : '—'),
                      Text('${(ev[c['provider']] as Map?)?['failed'] ?? 0}'),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Produtos configurados', 'Configured products', 'Productos configurados'),
              child: PortalTable(
                columns: [
                  PortalColumn(t('Provedor', 'Provider', 'Proveedor'), flex: 2),
                  PortalColumn(t('Plano', 'Plan', 'Plan')),
                  PortalColumn(t('Produto', 'Product', 'Producto'), flex: 3),
                  PortalColumn(t('Preço de referência', 'Reference price', 'Precio de referencia'), flex: 2),
                  PortalColumn(t('Conferido na loja', 'Checked in store', 'Verificado en tienda'), flex: 2),
                ],
                rows: [
                  for (final c in cat.where((c) => c['environment'] == 'production'))
                    [
                      Text(_provider('${c['provider']}')),
                      Text(c['plan'] == 'annual' ? t('Anual', 'Annual', 'Anual') : t('Mensal', 'Monthly', 'Mensual')),
                      Text('${c['product_id']}${c['base_plan_id'] != null ? ' / ${c['base_plan_id']}' : ''}'),
                      Text(t.money(c['price_cents'] as num)),
                      StatusBadge(c['verified'] == true ? t('Sim', 'Yes', 'Sí') : t('Pendente', 'Pending', 'Pendiente'),
                          tone: c['verified'] == true ? Tone.good : Tone.warn),
                    ],
                ],
              ),
            ),
          ]);
        },
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 8, children: [
        for (final s in const [('failed', 'Falhos', 'Failed', 'Fallidos'), ('conflict', 'Conflitos', 'Conflicts', 'Conflictos'), ('processed', 'Processados', 'Processed', 'Procesados')])
          ChoiceChip(label: Text(t(s.$2, s.$3, s.$4)), selected: _status == s.$1, onSelected: (_) => setState(() => _status = s.$1)),
      ]),
      const SizedBox(height: 8),
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

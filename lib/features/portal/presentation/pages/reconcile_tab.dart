import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/domain/report_parser.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

/// Conciliação por relatórios oficiais. Importar só CONFERE; aplicar é um ato
/// explícito e auditado. Formatos NÃO validados com amostra real (aviso fixo).
class ReconcileTab extends StatefulWidget {
  const ReconcileTab({super.key});
  @override
  State<ReconcileTab> createState() => _ReconcileTabState();
}

class _ReconcileTabState extends State<ReconcileTab> {
  String _provider = 'google', _kind = 'google_earnings';
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month - 1);
  final _text = TextEditingController();
  final _name = TextEditingController();
  int _reload = 0;
  bool _busy = false;
  String? _msg;

  @override
  void dispose() {
    _text.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _import(PortalApi api) async {
    final t = PortalStrings.read(context);
    setState(() { _busy = true; _msg = null; });
    try {
      final p = parseReport(kind: _kind, text: _text.text);
      final r = await api.importReport(
        provider: _provider, kind: _kind, competence: _month,
        fileName: _name.text.isEmpty ? null : _name.text, sha256: p.sha256Hex, lines: p.lines);
      _text.clear();
      _msg = '${t('Importado', 'Imported', 'Importado')}: ${r['lines']} · '
          '${t('prontas', 'ready', 'listas')} ${r['matched']} · ${t('divergentes', 'divergent', 'divergentes')} ${r['divergent']} · '
          '${t('sem par', 'unmatched', 'sin par')} ${r['unmatched']}'
          '${p.warnings.isEmpty ? '' : '\n${p.warnings.join('\n')}'}';
      _reload++;
    } on ReportFormatException catch (e) {
      _msg = e.message;
    } on PortalException catch (e) {
      _msg = e.code == 'P0061'
          ? t('Este arquivo já foi importado.', 'This file was already imported.', 'Este archivo ya fue importado.')
          : e.message;
    } catch (e) {
      _msg = '$e';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    final kinds = reportKinds[_provider]!;
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Loader<List<Map<String, dynamic>>>(
        loader: () => api.reportImports(),
        keys: [_reload],
        builder: (context, rows, reload) {
          num sum(String k) => rows.fold<num>(0, (a, r) => a + ((r[k] as num?) ?? 0));
          final toApply = rows.where((r) => r['status'] == 'staged' && ((r['matched'] as num?) ?? 0) > 0).length;
          final divergent = sum('divergent'), unmatched = sum('unmatched');
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionHeader(t('Situação da conciliação', 'Reconciliation status', 'Estado de la conciliación'),
                subtitle: t('Todos os relatórios importados', 'All imported reports', 'Todos los informes importados')),
            CardGrid(children: [
              StatCard(icon: Icons.upload_file_outlined, label: t('Relatórios importados', 'Imported reports', 'Informes importados'), value: t.number(rows.length), hint: '${t.number(sum('line_count'))} ${t('linhas', 'lines', 'líneas')}'),
              StatCard(label: t('Prontas para conciliar', 'Ready to reconcile', 'Listas para conciliar'), value: t.number(sum('matched')), tone: toApply > 0 ? Tone.good : null, hint: t('Conferem com o sistema', 'Match the system', 'Coinciden con el sistema')),
              StatCard(label: t('Divergências', 'Divergences', 'Divergencias'), value: t.number(divergent), tone: divergent > 0 ? Tone.warn : null, hint: t('Valores diferentes do sistema', 'Differ from the system', 'Difieren del sistema')),
              StatCard(label: t('Sem par (pendentes)', 'Unmatched (pending)', 'Sin par (pendientes)'), value: t.number(unmatched), tone: unmatched > 0 ? Tone.warn : null, hint: t('Sem pagamento correspondente', 'No matching payment', 'Sin pago correspondiente')),
            ]),
            if (toApply > 0 || divergent > 0 || unmatched > 0)
              Padding(
                padding: const EdgeInsets.only(top: kCardGap),
                child: Panel(
                  title: t('Ações necessárias', 'Actions required', 'Acciones necesarias'),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (toApply > 0)
                      Text('• ${t('Aplicar as linhas prontas de', 'Apply the ready lines of', 'Aplicar las líneas listas de')} ${t.number(toApply)} ${t('importação(ões) conferida(s)', 'checked import(s)', 'importación(es) comprobada(s)')}.'),
                    if (divergent > 0) Text('• ${t('Revisar divergências antes de qualquer ajuste.', 'Review divergences before any adjustment.', 'Revisar divergencias antes de cualquier ajuste.')}'),
                    if (unmatched > 0) Text('• ${t('Linhas sem par não são alteradas; confira o pagamento no provedor.', 'Unmatched lines are not changed; check the payment at the provider.', 'Las líneas sin par no se modifican; revisa el pago en el proveedor.')}'),
                  ]),
                ),
              ),
            SectionHeader(t('Relatórios importados', 'Imported reports', 'Informes importados'), subtitle: t('Toque em um relatório para conferir e aplicar', 'Tap a report to check and apply', 'Toca un informe para comprobar y aplicar')),
            Panel(
              child: rows.isEmpty
                  ? EmptyState(message: t('Nenhum relatório importado.', 'No reports imported.', 'Ningún informe importado.'))
                  : PortalTable(
                      columns: [
                        PortalColumn(t('Provedor / tipo', 'Provider / type', 'Proveedor / tipo'), flex: 3),
                        PortalColumn(t('Competência', 'Competence', 'Competencia')),
                        PortalColumn(t('Situação', 'Status', 'Estado')),
                        PortalColumn(t('Linhas', 'Lines', 'Líneas')),
                        PortalColumn(t('Prontas', 'Ready', 'Listas')),
                        PortalColumn(t('Divergentes', 'Divergent', 'Divergentes')),
                        PortalColumn(t('Sem par', 'Unmatched', 'Sin par')),
                      ],
                      onTap: (i) => showDialog<void>(
                          context: context, builder: (_) => _Detail(api: api, id: '${rows[i]['id']}', onChanged: () => setState(() => _reload++))),
                      rows: [
                        for (final r in rows)
                          [
                            Text('${r['provider']} · ${r['kind']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${r['competence']}'.substring(0, 7)),
                            StatusBadge('${r['status']}', tone: r['status'] == 'applied' ? Tone.good : (r['status'] == 'staged' ? Tone.warn : Tone.neutral)),
                            Text('${r['line_count']}'),
                            Text('${r['matched']}'),
                            Text('${r['divergent']}', style: TextStyle(color: ((r['divergent'] as num?) ?? 0) > 0 ? c.warning : null)),
                            Text('${r['unmatched']}', style: TextStyle(color: ((r['unmatched'] as num?) ?? 0) > 0 ? c.warning : null)),
                          ],
                      ],
                    ),
            ),
          ]);
        },
      ),
      SectionHeader(t('Importar relatório', 'Import report', 'Importar informe'), subtitle: t('Importar só confere; aplicar é um ato explícito e auditado', 'Importing only checks; applying is an explicit, audited act', 'Importar solo comprueba; aplicar es un acto explícito y auditado')),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.warning_amber_rounded, size: 18, color: c.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(t(
                  'Atenção: os formatos de relatório ainda NÃO foram validados com amostras reais dos provedores. Confira o resultado antes de aplicar. Relatórios da Apple são agregados: apenas conferem totais.',
                  'Warning: report formats have NOT yet been validated against real provider samples. Review the result before applying. Apple reports are aggregate: they only check totals.',
                  'Atención: los formatos aún NO fueron validados con muestras reales de los proveedores. Revisa el resultado antes de aplicar. Los informes de Apple son agregados: solo comparan totales.')),
            ),
          ]),
          const SizedBox(height: kCardGap),
          FilterBar(children: [
            Select<String>(
              label: t('Provedor', 'Provider', 'Proveedor'), value: _provider,
              items: const {'google': 'Google Play', 'apple': 'Apple', 'mercadopago': 'Mercado Pago'},
              onChanged: (v) => setState(() { _provider = v; _kind = reportKinds[v]!.first; }),
            ),
            Select<String>(
              label: t('Tipo de relatório', 'Report type', 'Tipo de informe'), value: _kind,
              items: {for (final k in kinds) k: k}, onChanged: (v) => setState(() => _kind = v),
            ),
            SizedBox(
              height: kControlH,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: Text('${_month.month.toString().padLeft(2, '0')}/${_month.year}'),
                onPressed: () async {
                  final d = await showDatePicker(
                      context: context, initialDate: _month, firstDate: DateTime(2026), lastDate: DateTime(2100));
                  if (d != null) setState(() => _month = DateTime(d.year, d.month));
                },
              ),
            ),
          ]),
          Field(label: t('Nome do arquivo (opcional)', 'File name (optional)', 'Nombre del archivo (opcional)'), controller: _name),
          Field(
            label: t('Conteúdo do relatório (CSV/TSV com cabeçalho)', 'Report content (CSV/TSV with header)', 'Contenido del informe (CSV/TSV con encabezado)'),
            controller: _text, maxLines: 8),
          SizedBox(
            height: kControlH,
            child: ElevatedButton(
              onPressed: _busy ? null : () => _import(api),
              child: Text(t('Importar e conferir', 'Import and check', 'Importar y comprobar')),
            ),
          ),
          if (_msg != null) Padding(padding: const EdgeInsets.only(top: 10), child: SelectableText(_msg!)),
        ]),
      ),
    ]);
  }
}

class _Detail extends StatefulWidget {
  const _Detail({required this.api, required this.id, required this.onChanged});
  final PortalApi api;
  final String id;
  final VoidCallback onChanged;
  @override
  State<_Detail> createState() => _DetailState();
}

class _DetailState extends State<_Detail> {
  int _k = 0;
  bool _busy = false;
  String? _msg;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    return AlertDialog(
      title: Text(t('Conferência da importação', 'Import check', 'Comprobación de la importación')),
      content: SizedBox(
        width: 560,
        child: Loader<Map<String, dynamic>>(
          loader: () => widget.api.reportImport(widget.id),
          keys: [_k],
          builder: (context, d, _) {
            final imp = Map<String, dynamic>.from(d['import'] as Map);
            final check = d['check'] as Map?;
            final lines = [for (final e in (d['lines'] as List? ?? const [])) Map<String, dynamic>.from(e as Map)];
            final canApply = imp['status'] == 'staged' && (imp['matched'] as num) > 0;
            return SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text('${imp['provider']} · ${imp['kind']} · ${imp['status']}'),
                if (check != null) ...[
                  const SizedBox(height: 8),
                  Text('${check['note']}'),
                  Text('${t('Relatório', 'Report', 'Informe')}: ${check['report_quantity']} · '
                      '${t('preço ao cliente', 'customer price', 'precio al cliente')} ${t.money(check['report_customer_price_cents'] as num)} · '
                      '${t('repasse', 'share', 'reparto')} ${t.money(check['report_partner_share_cents'] as num)}'),
                  Text('${t('Sistema', 'System', 'Sistema')}: ${check['system_payments']} · ${t.money(check['system_gross_cents'] as num)}'),
                ],
                const SizedBox(height: 8),
                Text(t('Linhas com problema', 'Problem lines', 'Líneas con problema'), style: Theme.of(context).textTheme.titleSmall),
                if (lines.isEmpty) const Text('—'),
                for (final l in lines) Text('#${l['line_no']} ${l['ref'] ?? ''} · ${l['status']} · ${l['note'] ?? ''}'),
                if (_msg != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_msg!)),
                if (canApply)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ElevatedButton(
                      onPressed: _busy ? null : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(t('Aplicar conciliação?', 'Apply reconciliation?', '¿Aplicar conciliación?')),
                            content: Text(t(
                                'Só as ${imp['matched']} linhas prontas serão conciliadas (taxa e imposto do provedor). Divergentes e sem par não são alterados. Ato auditado.',
                                'Only the ${imp['matched']} ready lines will be reconciled (provider fee and tax). Divergent and unmatched stay untouched. Audited.',
                                'Solo se conciliarán las ${imp['matched']} líneas listas (comisión e impuesto del proveedor). Divergentes y sin par no cambian. Auditado.')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t('Aplicar', 'Apply', 'Aplicar'))),
                            ],
                          ),
                        );
                        if (ok != true) return;
                        setState(() => _busy = true);
                        try {
                          final r = await widget.api.applyReport(widget.id);
                          _msg = '${t('Aplicadas', 'Applied', 'Aplicadas')}: ${r['applied']}';
                          widget.onChanged();
                          _k++;
                        } catch (e) {
                          _msg = '$e';
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                      child: Text(t('Aplicar linhas prontas', 'Apply ready lines', 'Aplicar líneas listas')),
                    ),
                  ),
              ]),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t('Fechar', 'Close', 'Cerrar')))],
    );
  }
}

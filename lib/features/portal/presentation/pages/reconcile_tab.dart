import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t(
              'Atenção: os formatos de relatório ainda NÃO foram validados com amostras reais dos provedores. Confira o resultado antes de aplicar. Relatórios da Apple são agregados: apenas conferem totais.',
              'Warning: report formats have NOT yet been validated against real provider samples. Review the result before applying. Apple reports are aggregate: they only check totals.',
              'Atención: los formatos aún NO fueron validados con muestras reales de los proveedores. Revisa el resultado antes de aplicar. Los informes de Apple son agregados: solo comparan totales.')),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [
            Select<String>(
              label: t('Provedor', 'Provider', 'Proveedor'), value: _provider,
              items: const {'google': 'Google Play', 'apple': 'Apple', 'mercadopago': 'Mercado Pago'},
              onChanged: (v) => setState(() { _provider = v; _kind = reportKinds[v]!.first; }),
            ),
            Select<String>(
              label: t('Tipo de relatório', 'Report type', 'Tipo de informe'), value: _kind,
              items: {for (final k in kinds) k: k}, onChanged: (v) => setState(() => _kind = v),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text('${_month.month.toString().padLeft(2, '0')}/${_month.year}'),
              onPressed: () async {
                final d = await showDatePicker(
                    context: context, initialDate: _month, firstDate: DateTime(2026), lastDate: DateTime(2100));
                if (d != null) setState(() => _month = DateTime(d.year, d.month));
              },
            ),
          ]),
          const SizedBox(height: 10),
          Field(label: t('Nome do arquivo (opcional)', 'File name (optional)', 'Nombre del archivo (opcional)'), controller: _name),
          Field(
            label: t('Conteúdo do relatório (CSV/TSV com cabeçalho)', 'Report content (CSV/TSV with header)', 'Contenido del informe (CSV/TSV con encabezado)'),
            controller: _text, maxLines: 8),
          ElevatedButton(
            onPressed: _busy ? null : () => _import(api),
            child: Text(t('Importar e conferir', 'Import and check', 'Importar y comprobar')),
          ),
          if (_msg != null) Padding(padding: const EdgeInsets.only(top: 10), child: SelectableText(_msg!)),
        ]),
      ),
      const SizedBox(height: 16),
      Panel(
        child: Loader<List<Map<String, dynamic>>>(
          loader: () => api.reportImports(),
          keys: [_reload],
          builder: (context, rows, reload) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('Importações', 'Imports', 'Importaciones'), style: Theme.of(context).textTheme.titleMedium),
            if (rows.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('—')),
            for (final r in rows)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${r['provider']} · ${r['kind']} · ${'${r['competence']}'.substring(0, 7)}'),
                subtitle: Text('${r['status']} · ${r['line_count']} ${t('linhas', 'lines', 'líneas')} · '
                    '${t('prontas', 'ready', 'listas')} ${r['matched']} · ${t('divergentes', 'divergent', 'divergentes')} ${r['divergent']} · '
                    '${t('sem par', 'unmatched', 'sin par')} ${r['unmatched']}'),
                onTap: () => showDialog<void>(
                    context: context, builder: (_) => _Detail(api: api, id: '${r['id']}', onChanged: () => setState(() => _reload++))),
              ),
          ]),
        ),
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

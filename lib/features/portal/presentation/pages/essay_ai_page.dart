import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

// Correção de redação por IA: provedores gratuitos, ordem (Plano A/B), liga/desliga, franquias e saúde.
// Só chama RPCs admin_essay_ai_* (cada uma valida o administrador e audita). Nenhuma chave nem texto de
// redação trafega aqui: só configuração, contagens, latência e códigos de erro.

List<Map<String, dynamic>> _l(dynamic v) => [for (final e in (v as List? ?? const [])) Map<String, dynamic>.from(e as Map)];
Map<String, dynamic> _m(dynamic v) => Map<String, dynamic>.from((v as Map?) ?? const {});
num _n(dynamic v) => v is num ? v : 0;

String _name(String p) => switch (p) { 'groq' => 'Groq', 'cloudflare' => 'Cloudflare Workers AI', _ => 'Google Gemini' };
String _unit(String u) => switch (u) { 'tokens' => 'tokens', 'neurons' => 'neurons', _ => 'req.' };

class EssayAiPage extends StatefulWidget {
  const EssayAiPage({super.key});
  @override
  State<EssayAiPage> createState() => _EssayAiPageState();
}

class _EssayAiPageState extends State<EssayAiPage> {
  Future<void> _toggle(BuildContext context, PortalApi api, PortalStrings t, Map<String, dynamic> p, Future<void> Function() reload) async {
    final enable = p['enabled'] != true;
    final ok = await confirmDialog(context,
        title: enable ? t('Habilitar provedor', 'Enable provider', 'Habilitar proveedor') : t('Desabilitar provedor', 'Disable provider', 'Deshabilitar proveedor'),
        message: enable
            ? t('Redações passarão a ser enviadas a ${_name('${p['provider']}')} (plano gratuito). Confirme que as condições de uso e privacidade foram validadas.',
                'Essays will be sent to ${_name('${p['provider']}')} (free tier). Confirm that terms and privacy were validated.',
                'Las redacciones se enviarán a ${_name('${p['provider']}')} (plan gratuito). Confirma que los términos y la privacidad fueron validados.')
            : t('${_name('${p['provider']}')} deixa de receber redações imediatamente. O outro provedor assume.',
                '${_name('${p['provider']}')} stops receiving essays immediately. The other provider takes over.',
                '${_name('${p['provider']}')} deja de recibir redacciones de inmediato. El otro proveedor asume.'),
        action: enable ? t('Habilitar', 'Enable', 'Habilitar') : t('Desabilitar', 'Disable', 'Deshabilitar'),
        danger: !enable);
    if (!ok || !context.mounted) return;
    if (await runAction(context, () => api.essayAiSet('${p['provider']}', {'enabled': enable}),
        success: t('Alterado.', 'Updated.', 'Actualizado.'))) {
      await reload();
    }
  }

  Future<void> _move(BuildContext context, PortalApi api, PortalStrings t, List<Map<String, dynamic>> all, int index, int delta, Future<void> Function() reload) async {
    final order = [for (final p in all) '${p['provider']}'];
    final to = index + delta;
    if (to < 0 || to >= order.length) return;
    final tmp = order[index];
    order[index] = order[to];
    order[to] = tmp;
    final ok = await confirmDialog(context,
        title: t('Alterar a ordem', 'Change order', 'Cambiar el orden'),
        message: t('Nova ordem: ${order.map(_name).join(' → ')}. Vale já para as próximas correções, sem publicar o app.',
            'New order: ${order.map(_name).join(' → ')}. Applies to the next corrections, no app release needed.',
            'Nuevo orden: ${order.map(_name).join(' → ')}. Vale para las próximas correcciones, sin publicar la app.'),
        action: t('Alterar', 'Change', 'Cambiar'));
    if (!ok || !context.mounted) return;
    if (await runAction(context, () => api.essayAiSetOrder(order), success: t('Ordem alterada.', 'Order changed.', 'Orden cambiado.'))) {
      await reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: t('Correção de redação por IA', 'AI essay feedback', 'Corrección de redacciones por IA')),
      Loader<Map<String, dynamic>>(
        loader: api.essayAiOverview,
        builder: (context, d, reload) {
          final all = _l(d['providers']);
          final today = [for (final p in all) _m(p['today'])];
          final week = [for (final p in all) _m(p['last_7_days'])];
          num sum(List<Map<String, dynamic>> l, String k) => l.fold<num>(0, (a, e) => a + _n(e[k]));
          final capacity = [for (final p in all) if (p['enabled'] == true) _n(_m(p['today'])['capacity_left'])].fold<num>(0, (a, b) => a + b);
          final anyOn = all.any((p) => p['enabled'] == true);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!anyOn)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StatusBadge(t('Nenhum provedor habilitado: correção desativada.', 'No provider enabled: feedback is off.', 'Ningún proveedor habilitado: corrección desactivada.'), tone: Tone.warn),
              ),
            CardGrid(children: [
              StatCard(label: t('Correções hoje', 'Corrections today', 'Correcciones hoy'), value: '${sum(today, 'successes')}'),
              StatCard(label: t('Falhas hoje', 'Failures today', 'Fallos hoy'), value: '${sum(today, 'failures')}'),
              StatCard(label: t('Fallbacks hoje', 'Fallbacks today', 'Fallbacks hoy'), value: '${sum(today, 'fallbacks')}'),
              StatCard(label: t('Capacidade restante hoje', 'Capacity left today', 'Capacidad restante hoy'), value: '~$capacity ${t('correções', 'corrections', 'correcciones')}'),
              StatCard(label: t('Correções (7 dias)', 'Corrections (7 days)', 'Correcciones (7 días)'), value: '${sum(week, 'successes')}'),
              StatCard(label: t('Falhas (7 dias)', 'Failures (7 days)', 'Fallos (7 días)'), value: '${sum(week, 'failures')}'),
            ]),
            const SizedBox(height: 16),
            Panel(
              title: t('Provedores (Plano A primeiro)', 'Providers (Plan A first)', 'Proveedores (Plan A primero)'),
              child: PortalTable(
                columns: [
                  PortalColumn(t('Provedor', 'Provider', 'Proveedor'), flex: 3),
                  PortalColumn(t('Papel', 'Role', 'Rol'), flex: 2),
                  PortalColumn(t('Circuit breaker', 'Circuit breaker', 'Circuit breaker'), flex: 2),
                  PortalColumn(t('Hoje', 'Today', 'Hoy'), flex: 2),
                  PortalColumn(t('Franquia', 'Allowance', 'Cuota'), flex: 3),
                  PortalColumn(t('Latência', 'Latency', 'Latencia'), flex: 2),
                  PortalColumn(t('Último erro', 'Last error', 'Último error'), flex: 3),
                  PortalColumn(t('Última correção', 'Last success', 'Último éxito'), flex: 2),
                  const PortalColumn('', flex: 4),
                ],
                rows: [
                  for (var i = 0; i < all.length; i++)
                    () {
                      final p = all[i];
                      final td = _m(p['today']);
                      final wk = _m(p['last_7_days']);
                      final breaker = '${p['breaker']}';
                      final cooldown = DateTime.tryParse('${p['cooldown_until']}');
                      final cooling = cooldown != null && cooldown.isAfter(DateTime.now());
                      final role = switch ('${p['role']}') {
                        'primary' => t('Principal (A)', 'Primary (A)', 'Principal (A)'),
                        'secondary' => t('Secundário (B)', 'Secondary (B)', 'Secundario (B)'),
                        _ => t('Desligado', 'Off', 'Apagado'),
                      };
                      return <Widget>[
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_name('${p['provider']}')),
                          Text('${p['model']}', style: Theme.of(context).textTheme.bodySmall),
                        ]),
                        StatusBadge(role, tone: p['enabled'] == true ? (p['role'] == 'primary' ? Tone.good : Tone.info) : Tone.neutral),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          StatusBadge(
                            switch (breaker) {
                              'open' => t('Aberto', 'Open', 'Abierto'),
                              'half_open' => t('Meia-abertura', 'Half-open', 'Semiabierto'),
                              _ => t('Fechado', 'Closed', 'Cerrado'),
                            },
                            tone: breaker == 'closed' ? Tone.good : (breaker == 'open' ? Tone.bad : Tone.warn),
                          ),
                          if (cooling) Text(t('espera até ${t.dateTime(cooldown)}', 'waiting until ${t.dateTime(cooldown)}', 'espera hasta ${t.dateTime(cooldown)}')),
                        ]),
                        Text('${td['successes']} ok · ${td['failures']} ${t('falhas', 'fail', 'fallos')} · ${td['fallbacks']} fb'),
                        Text('${td['cost_used']} / ${p['daily_budget']} ${_unit('${p['budget_unit']}')} (${td['budget_used_pct'] ?? 0}%)\n'
                            '${t('restam', 'left', 'quedan')} ~${td['capacity_left'] ?? 0} ${t('correções', 'corrections', 'correcciones')}'),
                        Text(wk['avg_latency_ms'] == null ? '—' : '${wk['avg_latency_ms']} ms'),
                        Text('${p['last_error'] ?? '—'}'),
                        Text(p['last_success_at'] == null ? '—' : t.dateTime(DateTime.tryParse('${p['last_success_at']}'))),
                        Wrap(spacing: 4, children: [
                          IconButton(
                            tooltip: t('Subir prioridade', 'Move up', 'Subir prioridad'),
                            icon: const Icon(Icons.arrow_upward_rounded),
                            onPressed: i == 0 ? null : () => _move(context, api, t, all, i, -1, reload),
                          ),
                          IconButton(
                            tooltip: t('Descer prioridade', 'Move down', 'Bajar prioridad'),
                            icon: const Icon(Icons.arrow_downward_rounded),
                            onPressed: i == all.length - 1 ? null : () => _move(context, api, t, all, i, 1, reload),
                          ),
                          TextButton(
                            onPressed: () => _toggle(context, api, t, p, reload),
                            child: Text(p['enabled'] == true ? t('Desligar', 'Turn off', 'Apagar') : t('Ligar', 'Turn on', 'Encender')),
                          ),
                          if (breaker != 'closed' || cooling || _n(p['consecutive_failures']) > 0)
                            TextButton(
                              onPressed: () async {
                                if (await runAction(context, () => api.essayAiSet('${p['provider']}', {'reset_breaker': true}),
                                    success: t('Breaker reiniciado.', 'Breaker reset.', 'Breaker reiniciado.'))) {
                                  await reload();
                                }
                              },
                              child: Text(t('Reiniciar breaker', 'Reset breaker', 'Reiniciar breaker')),
                            ),
                        ]),
                      ];
                    }(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t('O limite de 3 correções por aluno por dia é compartilhado entre os provedores. Falha dos dois provedores não consome o limite e a redação fica salva. Alterações valem na hora e ficam na auditoria.',
                  'The limit of 3 corrections per student per day is shared across providers. If both providers fail the limit is not consumed and the essay stays saved. Changes apply immediately and are audited.',
                  'El límite de 3 correcciones por alumno al día se comparte entre proveedores. Si ambos fallan no se consume el límite y la redacción queda guardada. Los cambios valen al instante y quedan en auditoría.'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ]);
        },
      ),
    ]);
  }
}

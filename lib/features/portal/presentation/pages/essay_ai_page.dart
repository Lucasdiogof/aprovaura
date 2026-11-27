import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/theme/app_colors.dart';
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

  Widget _card(BuildContext context, PortalApi api, PortalStrings t, List<Map<String, dynamic>> all, int i, Future<void> Function() reload, {required bool featured}) {
    final c = context.colors;
    final p = all[i];
    final td = _m(p['today']);
    final wk = _m(p['last_7_days']);
    final enabled = p['enabled'] == true;
    final breaker = '${p['breaker']}';
    final cooldown = DateTime.tryParse('${p['cooldown_until']}');
    final cooling = cooldown != null && cooldown.isAfter(DateTime.now());
    final blocked = breaker == 'open' || cooling;
    final pct = _n(td['budget_used_pct']).toDouble();
    final left = _n(td['capacity_left']);
    final plan = switch ('${p['provider']}') {
      'groq' => t('Plano A', 'Plan A', 'Plan A'),
      'cloudflare' => t('Plano B', 'Plan B', 'Plan B'),
      _ => t('Integração antiga', 'Legacy integration', 'Integración antigua'),
    };
    final role = switch ('${p['role']}') {
      'primary' => t('Principal', 'Primary', 'Principal'),
      'secondary' => t('Reserva', 'Backup', 'Reserva'),
      _ => t('Desligado', 'Off', 'Apagado'),
    };
    final (availLabel, availTone) = !enabled
        ? (t('Indisponível: desabilitado', 'Unavailable: disabled', 'No disponible: deshabilitado'), Tone.neutral)
        : blocked
            ? (t('Indisponível: breaker aberto', 'Unavailable: breaker open', 'No disponible: breaker abierto'), Tone.bad)
            : breaker == 'half_open'
                ? (t('Em teste (meia-abertura)', 'Probing (half-open)', 'En prueba (semiabierto)'), Tone.warn)
                : left <= 0
                    ? (t('Franquia esgotada hoje', 'Allowance used up today', 'Cuota agotada hoy'), Tone.warn)
                    : (t('Disponível', 'Available', 'Disponible'), Tone.good);
    final String capacity;
    if (!enabled) {
      capacity = '— (${t('desabilitado', 'disabled', 'deshabilitado')})';
    } else if (blocked) {
      capacity = '~$left ${t('teórica', 'theoretical', 'teórica')} · 0 ${t('efetiva (breaker aberto)', 'effective (breaker open)', 'efectiva (breaker abierto)')}';
    } else {
      capacity = '~$left ${t('correções', 'corrections', 'correcciones')}';
    }
    final breakerName = switch (breaker) {
      'open' => t('Aberto', 'Open', 'Abierto'),
      'half_open' => t('Meia-abertura', 'Half-open', 'Semiabierto'),
      _ => t('Fechado', 'Closed', 'Cerrado'),
    };
    final barColor = !enabled ? c.textSecondary : (pct >= 90 ? c.error : (pct >= 70 ? c.warning : c.success));
    Widget kv(String l, String v) => KeyValue(l, Text(v));
    final lastErr = '${p['last_error'] ?? '—'}';
    final authHint = p['last_error'] == 'auth'
        ? ' (${t('sugere falha de autenticação; não confirma credencial ausente', 'suggests an authentication failure; does not confirm a missing credential', 'sugiere fallo de autenticación; no confirma credencial ausente')})'
        : '';
    final waiting = cooling
        ? ' · ${t('espera até ${t.dateTime(cooldown)}', 'waiting until ${t.dateTime(cooldown)}', 'espera hasta ${t.dateTime(cooldown)}')}'
        : '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: featured && enabled ? c.primary.withValues(alpha: 0.5) : c.border, width: featured && enabled ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(_name('${p['provider']}'), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.textPrimary)),
          StatusBadge(plan, tone: featured ? Tone.info : Tone.neutral),
          StatusBadge(role, tone: !enabled ? Tone.neutral : (p['role'] == 'primary' ? Tone.good : Tone.info)),
          StatusBadge(enabled ? t('Habilitado', 'Enabled', 'Habilitado') : t('Desabilitado', 'Disabled', 'Deshabilitado'), tone: enabled ? Tone.good : Tone.neutral),
        ]),
        const SizedBox(height: 4),
        Text('${p['model']}', style: TextStyle(fontSize: 13, color: c.textSecondary)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          StatusBadge(availLabel, tone: availTone),
          Text('Breaker', style: TextStyle(fontSize: 13, color: c.textSecondary)),
          StatusBadge(breakerName, tone: breaker == 'closed' ? (enabled ? Tone.good : Tone.neutral) : (breaker == 'open' ? Tone.bad : Tone.warn)),
        ]),
        if (!enabled && breaker == 'closed')
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(t('Breaker fechado não significa operacional: o provedor está desligado.', 'A closed breaker does not mean operational: the provider is off.', 'Breaker cerrado no significa operativo: el proveedor está apagado.'),
                style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: (pct / 100).clamp(0.0, 1.0), minHeight: 8, color: barColor, backgroundColor: c.border),
            ),
          ),
          const SizedBox(width: 10),
          Text('${td['budget_used_pct'] ?? 0}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.textPrimary)),
        ]),
        const SizedBox(height: 8),
        kv(t('Consumo do dia', 'Used today', 'Consumo del día'), '${td['cost_used'] ?? 0} ${_unit('${p['budget_unit']}')}'),
        kv(t('Franquia interna', 'Internal allowance', 'Cuota interna'),
            '${p['daily_budget']} ${_unit('${p['budget_unit']}')} · ${p['daily_request_limit']} ${t('req./dia', 'req./day', 'req./día')}'),
        kv(t('Capacidade restante', 'Capacity left', 'Capacidad restante'), capacity),
        kv(t('Hoje', 'Today', 'Hoy'),
            '${td['successes'] ?? 0} ${t('sucessos', 'successes', 'éxitos')} · ${td['failures'] ?? 0} ${t('falhas', 'failures', 'fallos')} · ${td['fallbacks'] ?? 0} fallbacks'),
        kv(t('Latência média (7 dias)', 'Avg latency (7 days)', 'Latencia media (7 días)'), wk['avg_latency_ms'] == null ? '—' : '${wk['avg_latency_ms']} ms'),
        kv(t('Circuit breaker', 'Circuit breaker', 'Circuit breaker'),
            '${t('limite', 'threshold', 'umbral')} ${p['breaker_threshold']} · ${t('falhas seguidas', 'consecutive failures', 'fallos seguidos')} ${p['consecutive_failures'] ?? 0}$waiting'),
        kv(t('Última atividade', 'Last activity', 'Última actividad'), p['last_success_at'] == null ? '—' : t.dateTime(DateTime.tryParse('${p['last_success_at']}'))),
        kv(t('Último erro', 'Last error', 'Último error'), '$lastErr$authHint'),
        kv(t('Credencial', 'Credential', 'Credencial'), t('não informada pelo painel', 'not reported by the panel', 'no informada por el panel')),
        const SizedBox(height: 8),
        Wrap(spacing: 4, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
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
            child: Text(enabled ? t('Desligar', 'Turn off', 'Apagar') : t('Ligar', 'Turn on', 'Encender')),
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
      ]),
    );
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
          final enabled = [for (final p in all) if (p['enabled'] == true) p];
          final anyOn = enabled.isNotEmpty;
          num cap(Map<String, dynamic> p) => _n(_m(p['today'])['capacity_left']);
          final theoretical = enabled.fold<num>(0, (a, p) => a + cap(p));
          final effective = enabled.where((p) => p['breaker'] != 'open').fold<num>(0, (a, p) => a + cap(p));
          final featured = [for (var i = 0; i < all.length; i++) if (all[i]['provider'] == 'groq' || all[i]['provider'] == 'cloudflare') i];
          final extra = [for (var i = 0; i < all.length; i++) if (!featured.contains(i)) i];
          Widget cards(List<int> idx, {required bool feat}) => LayoutBuilder(builder: (context, box) {
                final cols = box.maxWidth >= 900 && idx.length > 1 ? 2 : 1;
                final w = (box.maxWidth - (cols - 1) * kCardGap) / cols;
                return Wrap(spacing: kCardGap, runSpacing: kCardGap, children: [
                  for (final i in idx) SizedBox(width: w, child: _card(context, api, t, all, i, reload, featured: feat)),
                ]);
              });
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
              StatCard(
                label: t('Capacidade efetiva hoje', 'Effective capacity today', 'Capacidad efectiva hoy'),
                value: anyOn ? '~$effective ${t('correções', 'corrections', 'correcciones')}' : '—',
                hint: anyOn
                    ? '${t('teórica', 'theoretical', 'teórica')}: ~$theoretical'
                    : t('Nenhum provedor habilitado', 'No provider enabled', 'Ningún proveedor habilitado'),
                tone: anyOn && effective == 0 ? Tone.bad : null,
              ),
              StatCard(label: t('Correções (7 dias)', 'Corrections (7 days)', 'Correcciones (7 días)'), value: '${sum(week, 'successes')}'),
              StatCard(label: t('Falhas (7 dias)', 'Failures (7 days)', 'Fallos (7 días)'), value: '${sum(week, 'failures')}'),
            ]),
            const SizedBox(height: kSectionGap),
            SectionHeader(t('Provedores principais', 'Main providers', 'Proveedores principales'),
                subtitle: t('Plano A (Groq) e Plano B (Cloudflare Workers AI), na ordem de prioridade.', 'Plan A (Groq) and Plan B (Cloudflare Workers AI), in priority order.', 'Plan A (Groq) y Plan B (Cloudflare Workers AI), en orden de prioridad.')),
            const SizedBox(height: 12),
            cards(featured, feat: true),
            if (extra.isNotEmpty) ...[
              const SizedBox(height: kSectionGap),
              SectionHeader(t('Provedores adicionais/inativos', 'Additional/inactive providers', 'Proveedores adicionales/inactivos'),
                  subtitle: t('Integrações antigas preservadas, fora do Plano A/B.', 'Legacy integrations preserved, outside Plan A/B.', 'Integraciones antiguas preservadas, fuera del Plan A/B.')),
              const SizedBox(height: 12),
              cards(extra, feat: false),
            ],
            const SizedBox(height: 16),
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

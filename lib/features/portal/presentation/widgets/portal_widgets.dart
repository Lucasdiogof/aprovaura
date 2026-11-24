import 'dart:async';

import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/csv_download.dart';

const double kWide = 900;

/// Título de página com ações à direita.
class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.subtitle, this.actions = const [], super.key});
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: c.textPrimary)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle!, style: TextStyle(color: c.textSecondary)),
              ),
          ]),
          if (actions.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ),
    );
  }
}

/// Superfície padrão (card).
class Panel extends StatelessWidget {
  const Panel({required this.child, this.title, this.trailing, this.padding = 16, super.key});
  final Widget child;
  final String? title;
  final Widget? trailing;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Expanded(
                child: Text(title!,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: c.textPrimary)),
              ),
              ?trailing,
            ]),
          ),
        child,
      ]),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({required this.label, required this.value, this.hint, this.icon, super.key});
  final String label;
  final String value;
  final String? hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          if (icon != null) ...[Icon(icon, size: 16, color: c.primary), const SizedBox(width: 6)],
          Expanded(
            child: Text(label,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.textPrimary)),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(hint!, style: TextStyle(fontSize: 11, color: c.textHint)),
          ),
      ]),
    );
  }
}

/// Grade responsiva de cards (colunas conforme a largura).
class CardGrid extends StatelessWidget {
  const CardGrid({required this.children, this.minWidth = 200, super.key});
  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final cols = (box.maxWidth / minWidth).floor().clamp(1, 6);
        final w = (box.maxWidth - (cols - 1) * 12) / cols;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final ch in children) SizedBox(width: w, child: ch),
        ]);
      });
}

enum Tone { neutral, good, warn, bad, info }

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {this.tone = Tone.neutral, super.key});
  final String label;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (tone) {
      Tone.good => c.success,
      Tone.warn => c.warning,
      Tone.bad => c.error,
      Tone.info => c.auraCyan,
      Tone.neutral => c.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

/// Rótulos de origem/estado de acesso, compartilhados entre telas.
String sourceLabel(PortalStrings t, String s) => switch (s) {
      'admin' => t('Administrador', 'Administrator', 'Administrador'),
      'partner' => t('Professor', 'Teacher', 'Profesor'),
      'trial' => t('Teste', 'Trial', 'Prueba'),
      'courtesy' => t('Cortesia', 'Courtesy', 'Cortesía'),
      'apple' => 'Apple',
      'google' => 'Google Play',
      'web' => 'Web',
      'transition' => t('Transição', 'Transition', 'Transición'),
      _ => s,
    };

String stateLabel(PortalStrings t, String s) => switch (s) {
      'active' => t('Ativa', 'Active', 'Activa'),
      'grace' => t('Carência', 'Grace', 'Gracia'),
      'canceled' => t('Cancelada', 'Canceled', 'Cancelada'),
      'expired' => t('Expirada', 'Expired', 'Expirada'),
      'refunded' => t('Reembolsada', 'Refunded', 'Reembolsada'),
      'revoked' => t('Revogada', 'Revoked', 'Revocada'),
      'pending' => t('Pendente', 'Pending', 'Pendiente'),
      'scheduled' => t('Agendada', 'Scheduled', 'Programada'),
      _ => s,
    };

Tone stateTone(String s) => switch (s) {
      'active' => Tone.good,
      'grace' || 'canceled' || 'pending' || 'scheduled' => Tone.warn,
      'expired' || 'refunded' || 'revoked' => Tone.bad,
      _ => Tone.neutral,
    };

/// Mensagem legível para um erro do servidor.
String errorText(PortalStrings t, Object e) {
  final code = e is PortalException ? e.code : null;
  return switch (code) {
    '42501' => t('Sem permissão para esta operação.', 'You are not allowed to do this.', 'Sin permiso para esta operación.'),
    'P0021' => t('Professor indisponível (inativo).', 'Teacher unavailable (inactive).', 'Profesor no disponible (inactivo).'),
    'P0022' => t('Um professor não pode ser vinculado a si mesmo.', 'A teacher cannot be linked to themselves.', 'Un profesor no puede vincularse a sí mismo.'),
    'P0024' => t('O aluno já está com este professor.', 'The student already has this teacher.', 'El alumno ya tiene este profesor.'),
    'P0030' => t('Duração inválida.', 'Invalid duration.', 'Duración no válida.'),
    'P0032' => t('Só cortesias podem ser revogadas aqui; compras são do provedor.', 'Only courtesies can be revoked here; purchases belong to the provider.', 'Solo las cortesías se pueden revocar aquí; las compras son del proveedor.'),
    'P0050' => t('Dados inválidos. Confira os campos.', 'Invalid data. Check the fields.', 'Datos no válidos. Revisa los campos.'),
    'P0051' || 'already_partner' => t('Este usuário já é professor ativo.', 'This user is already an active teacher.', 'Este usuario ya es profesor activo.'),
    'P0052' || 'code_in_use' => t('Este código de indicação já está em uso.', 'This referral code is already in use.', 'Este código de referencia ya está en uso.'),
    'P0053' => t('O aluno não tem professor.', 'The student has no teacher.', 'El alumno no tiene profesor.'),
    'P0040' => t('Pagamento não encontrado.', 'Payment not found.', 'Pago no encontrado.'),
    'P0041' => t('Valor acima do saldo disponível.', 'Amount exceeds the available balance.', 'Valor superior al saldo disponible.'),
    'P0042' => t('Este repasse não pode ser revertido.', 'This payout cannot be reversed.', 'Este pago no puede revertirse.'),
    'P0060' => t('Filtro ou período inválido.', 'Invalid filter or period.', 'Filtro o periodo no válido.'),
    _ => t('Não foi possível concluir. Tente novamente.', 'Could not complete. Try again.', 'No se pudo completar. Inténtalo de nuevo.'),
  };
}

/// Carrega dados assíncronos com skeleton, erro e recarregar. [loader] roda de novo
/// quando [keys] muda ou quando a tela chama `reload`.
class Loader<T> extends StatefulWidget {
  const Loader({required this.loader, required this.builder, this.keys = const [], super.key});
  final Future<T> Function() loader;
  final Widget Function(BuildContext, T, Future<void> Function() reload) builder;
  final List<Object?> keys;

  @override
  State<Loader<T>> createState() => _LoaderState<T>();
}

class _LoaderState<T> extends State<Loader<T>> {
  T? _data;
  Object? _error;
  bool _loading = true;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(Loader<T> old) {
    super.didUpdateWidget(old);
    if (!_same(old.keys, widget.keys)) unawaited(_load());
  }

  bool _same(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _load() async {
    final seq = ++_seq;
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final d = await widget.loader();
      if (mounted && seq == _seq) {
        setState(() {
          _data = d;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted && seq == _seq) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    if (_data != null && _error == null) {
      return Opacity(opacity: _loading ? 0.5 : 1, child: widget.builder(context, _data as T, _load));
    }
    if (_loading) return const Skeleton();
    return Panel(
      child: Column(children: [
        Icon(Icons.error_outline_rounded, color: context.colors.error),
        const SizedBox(height: 8),
        Text(errorText(t, _error!), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _load, child: Text(t('Tentar de novo', 'Try again', 'Reintentar'))),
      ]),
    );
  }
}

class Skeleton extends StatelessWidget {
  const Skeleton({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget bar(double w) => Container(
          height: 14,
          width: w,
          decoration: BoxDecoration(color: c.secondary, borderRadius: BorderRadius.circular(6)),
        );
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < 5; i++)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: bar(i.isEven ? 280 : 180)),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, this.icon = Icons.inbox_outlined, super.key});
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 36, color: c.textHint),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
        ]),
      ),
    );
  }
}

class PortalColumn {
  const PortalColumn(this.label, {this.flex = 1});
  final String label;
  final int flex;
}

/// Tabela responsiva: colunas em telas largas, cartões rótulo/valor nas estreitas.
class PortalTable extends StatelessWidget {
  const PortalTable({required this.columns, required this.rows, this.onTap, super.key});
  final List<PortalColumn> columns;
  final List<List<Widget>> rows;
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(builder: (context, box) {
      if (box.maxWidth >= kWide) {
        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              for (final col in columns)
                Expanded(
                  flex: col.flex,
                  child: Text(col.label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.textHint)),
                ),
            ]),
          ),
          Divider(height: 1, color: c.border),
          for (var i = 0; i < rows.length; i++) ...[
            InkWell(
              onTap: onTap == null ? null : () => onTap!(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(children: [
                  for (var j = 0; j < columns.length; j++)
                    Expanded(
                      flex: columns[j].flex,
                      child: Align(alignment: Alignment.centerLeft, child: rows[i][j]),
                    ),
                ]),
              ),
            ),
            Divider(height: 1, color: c.border),
          ],
        ]);
      }
      return Column(children: [
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap == null ? null : () => onTap!(i),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  for (var j = 0; j < columns.length; j++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(
                          width: 110,
                          child: Text(columns[j].label, style: TextStyle(fontSize: 11, color: c.textHint)),
                        ),
                        Expanded(child: Align(alignment: Alignment.centerLeft, child: rows[i][j])),
                      ]),
                    ),
                ]),
              ),
            ),
          ),
      ]);
    });
  }
}

/// Paginação do servidor.
class Pager extends StatelessWidget {
  const Pager({required this.total, required this.offset, required this.limit, required this.onPage, super.key});
  final int total;
  final int offset;
  final int limit;
  final void Function(int offset) onPage;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final from = total == 0 ? 0 : offset + 1;
    final to = (offset + limit).clamp(0, total);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('$from–$to ${t('de', 'of', 'de')} ${t.number(total)}'),
        IconButton(
          tooltip: t('Anterior', 'Previous', 'Anterior'),
          onPressed: offset > 0 ? () => onPage((offset - limit).clamp(0, total)) : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        IconButton(
          tooltip: t('Próxima', 'Next', 'Siguiente'),
          onPressed: offset + limit < total ? () => onPage(offset + limit) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ]),
    );
  }
}

/// Campo de busca com atraso (não consulta a cada tecla).
class SearchBox extends StatefulWidget {
  const SearchBox({required this.hint, required this.onChanged, this.initial = '', super.key});
  final String hint;
  final String initial;
  final void Function(String) onChanged;
  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final _ctrl = TextEditingController(text: widget.initial);
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 260,
        child: TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
          ),
          onChanged: (v) {
            _timer?.cancel();
            _timer = Timer(const Duration(milliseconds: 400), () => widget.onChanged(v.trim()));
          },
        ),
      );
}

/// Seleção por lista (somente escolher, sem digitar).
class Select<T> extends StatelessWidget {
  const Select({required this.label, required this.value, required this.items, required this.onChanged, super.key});
  final String label;
  final T value;
  final Map<T, String> items;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Em tela estreita o item mais largo estourava a linha: ocupa o espaço disponível e trunca.
    final narrow = MediaQuery.sizeOf(context).width < 480;
    final dropdown = DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isDense: true,
        isExpanded: narrow,
        items: [
          for (final e in items.entries)
            DropdownMenuItem<T>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min, children: [
        Text('$label: ', style: TextStyle(fontSize: 12, color: c.textHint)),
        if (narrow) Expanded(child: dropdown) else dropdown,
      ]),
    );
  }
}

class KeyValue extends StatelessWidget {
  const KeyValue(this.label, this.value, {super.key});
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 150, child: Text(label, style: TextStyle(color: c.textSecondary, fontSize: 13))),
        Expanded(child: DefaultTextStyle.merge(style: const TextStyle(fontSize: 13), child: value)),
      ]),
    );
  }
}

/// Confirmação de operação relevante. Devolve true se confirmou.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
  bool danger = false,
}) async {
  final t = PortalStrings.read(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Text(message)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(action, style: danger ? TextStyle(color: ctx.colors.error) : null),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Roda uma operação mostrando erro/sucesso no SnackBar. Devolve true se deu certo.
Future<bool> runAction(BuildContext context, Future<void> Function() op, {String? success}) async {
  final t = PortalStrings.read(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    await op();
    if (success != null) messenger.showSnackBar(SnackBar(content: Text(success)));
    return true;
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorText(t, e))));
    return false;
  }
}

/// Campo de texto simples para diálogos/formulários do portal.
class Field extends StatelessWidget {
  const Field({required this.label, required this.controller, this.hint, this.keyboard, this.maxLines = 1, super.key});
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final int maxLines;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label, hintText: hint, isDense: true),
        ),
      );
}

/// Gráfico de barras simples (sem dependência externa).
class BarChart extends StatelessWidget {
  const BarChart({required this.values, required this.labels, this.format, this.height = 140, super.key});
  final List<num> values;
  final List<String> labels;
  final String Function(num)? format;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final max = values.fold<num>(0, (a, b) => b > a ? b : a);
    return Column(children: [
      SizedBox(
        height: height,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Tooltip(
                message: '${labels[i]}: ${format?.call(values[i]) ?? values[i]}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Container(
                    // Valor negativo (estorno/saldo) vira barra mínima: altura negativa quebra o layout.
                    height: max <= 0 || values[i] <= 0 ? 2 : (values[i] / max * (height - 4)).toDouble() + 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.auraViolet, c.auraCyan],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(labels.isEmpty ? '' : labels.first, style: TextStyle(fontSize: 10, color: c.textHint)),
        Text(labels.isEmpty ? '' : labels.last, style: TextStyle(fontSize: 10, color: c.textHint)),
      ]),
    ]);
  }
}

enum Preset { today, d7, d30, month, lastMonth, year, custom }

/// Seletor de período compartilhado (painel do admin e do professor): mesmos
/// atalhos, mesmo intervalo personalizado, mesmos rótulos.
mixin PeriodState<T extends StatefulWidget> on State<T> {
  Preset preset = Preset.d30;
  DateTimeRange? customRange;

  DateTimeRange get range {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (preset) {
      case Preset.today:
        return DateTimeRange(start: today, end: today);
      case Preset.d7:
        return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today);
      case Preset.d30:
        return DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
      case Preset.month:
        return DateTimeRange(start: DateTime(now.year, now.month), end: today);
      case Preset.lastMonth:
        return DateTimeRange(start: DateTime(now.year, now.month - 1), end: DateTime(now.year, now.month, 0));
      case Preset.year:
        return DateTimeRange(start: DateTime(now.year), end: today);
      case Preset.custom:
        return customRange ?? DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
    }
  }

  Future<void> pickPreset(Object? v) async {
    final p = v as Preset;
    if (p == Preset.custom) {
      final r = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2025),
        lastDate: DateTime.now(),
        initialDateRange: range,
      );
      if (r == null) return;
      setState(() {
        customRange = r;
        preset = p;
      });
      return;
    }
    setState(() => preset = p);
  }

  Widget periodSelect(PortalStrings t) => Select<Preset>(
        label: t('Período', 'Period', 'Periodo'),
        value: preset,
        items: {
          Preset.today: t('Hoje', 'Today', 'Hoy'),
          Preset.d7: t('Últimos 7 dias', 'Last 7 days', 'Últimos 7 días'),
          Preset.d30: t('Últimos 30 dias', 'Last 30 days', 'Últimos 30 días'),
          Preset.month: t('Mês atual', 'This month', 'Mes actual'),
          Preset.lastMonth: t('Mês anterior', 'Last month', 'Mes anterior'),
          Preset.year: t('Ano atual', 'This year', 'Año actual'),
          Preset.custom: t('Personalizado…', 'Custom…', 'Personalizado…'),
        },
        onChanged: pickPreset,
      );
}

String providerLabel(String p) => switch (p) {
      'apple' => 'Apple',
      'google' => 'Google Play',
      'mercadopago' => 'Mercado Pago',
      _ => p,
    };

/// Exporta CSV: baixa no navegador (web) ou copia para a área de transferência.
Future<void> exportCsv(BuildContext context, Future<String> Function() fetch, String name) async {
  final t = PortalStrings.read(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final csv = await fetch();
    if (await downloadCsv(name, csv)) return;
    await Clipboard.setData(ClipboardData(text: csv));
    messenger.showSnackBar(SnackBar(content: Text(t('CSV copiado.', 'CSV copied.', 'CSV copiado.'))));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorText(t, e))));
  }
}

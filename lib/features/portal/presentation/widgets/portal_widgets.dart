import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';

import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/csv_download.dart';

const double kWide = 900;

/// Largura máxima do conteúdo (monitores grandes aproveitam a área; abaixo disso ocupa tudo).
const double kContentMax = 1680;

/// Tokens do portal derivados do tema (nunca cores fixas): texto auxiliar legível e borda discreta.
extension PortalTokens on AppColors {
  /// Texto auxiliar: entre o hint e o secundário (o hint puro ficava apagado demais).
  Color get muted => Color.lerp(textHint, textSecondary, 0.6)!;

  /// Borda de cartões: mais suave que a borda de campos.
  Color get hairline => border.withValues(alpha: 0.65);
}

/// Plural simples nos 3 idiomas ("1 novo" / "2 novos").
String plural(PortalStrings t, num n, {required String one, required String many, required String oneEn, required String manyEn, required String oneEs, required String manyEs}) =>
    '${t.number(n)} ${n == 1 ? t(one, oneEn, oneEs) : t(many, manyEn, manyEs)}';

/// Altura única dos controles de barra de ferramentas (busca, seletores, botões).
const double kControlH = 44;

/// Espaçamentos do portal: entre seções, entre cards e padding interno.
const double kSectionGap = 28;
const double kCardGap = 16;

/// Título de página com ações à direita (largura proporcional ao texto).
class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.subtitle, this.actions = const [], super.key});
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final titleBlock = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.textPrimary)),
      if (subtitle != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle!, style: TextStyle(fontSize: 14, color: c.textSecondary)),
        ),
    ]);
    final acts = Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: actions);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(builder: (context, box) {
        if (actions.isEmpty) return titleBlock;
        if (box.maxWidth < 640) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            titleBlock,
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: acts),
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 16),
          ConstrainedBox(constraints: BoxConstraints(maxWidth: box.maxWidth * 0.65), child: acts),
        ]);
      }),
    );
  }
}

/// Título de seção dentro de uma página (sempre a mesma tipografia e espaçamento).
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.subtitle, this.trailing, super.key});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: kSectionGap - 8, bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle!, style: TextStyle(fontSize: 13, color: c.textSecondary)),
              ),
          ]),
        ),
        ?trailing,
      ]),
    );
  }
}

/// Superfície padrão (card).
class Panel extends StatelessWidget {
  const Panel({required this.child, this.title, this.trailing, this.padding = 20, super.key});
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.hairline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Expanded(
                child: Text(title!,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.1, color: c.textPrimary)),
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
  const StatCard({required this.label, required this.value, this.hint, this.icon, this.tone, super.key});
  final String label;
  final String value;
  final String? hint;
  final IconData? icon;

  /// Realça o valor (ex.: atenção em âmbar). Neutro por padrão.
  final Tone? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final valueColor = switch (tone) {
      Tone.good => c.success,
      Tone.warn => c.warning,
      Tone.bad => c.error,
      _ => c.textPrimary,
    };
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.hairline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[Icon(icon, size: 16, color: c.muted), const SizedBox(width: 8)],
          Expanded(
            child: Text(label,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.textSecondary)),
          ),
        ]),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: valueColor)),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(hint!, style: TextStyle(fontSize: 12, color: c.muted)),
          ),
      ]),
    );
  }
}

/// Grade responsiva de cards: colunas conforme a largura, linhas com a MESMA altura
/// e a última linha alinhada às mesmas colunas das demais.
class CardGrid extends StatelessWidget {
  const CardGrid({required this.children, this.minWidth = 220, this.maxColumns = 6, super.key});
  final List<Widget> children;
  final double minWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final fit = (box.maxWidth / minWidth).floor().clamp(1, maxColumns);
        // Poucos cards ocupam a largura toda em vez de deixar um vazio à direita.
        final cols = children.length < fit && children.isNotEmpty ? children.length : fit;
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += cols) {
          final slice = children.skip(i).take(cols).toList();
          rows.add(Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : kCardGap),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var j = 0; j < cols; j++) ...[
                  if (j > 0) const SizedBox(width: kCardGap),
                  Expanded(child: j < slice.length ? slice[j] : const SizedBox.shrink()),
                ],
              ]),
            ),
          ));
        }
        return Column(children: rows);
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, maxLines: 1, softWrap: false, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
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
        Icon(LucideIcons.circleAlert, color: context.colors.error),
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
  const EmptyState({required this.message, this.icon = LucideIcons.inbox, this.action, super.key});
  final String message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 40, color: c.muted),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
          if (action != null) ...[const SizedBox(height: 12), action!],
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              Container(
                color: c.secondary.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  for (final col in columns)
                    Expanded(
                      flex: col.flex,
                      child: Text(col.label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: c.textSecondary)),
                    ),
                ]),
              ),
              for (var i = 0; i < rows.length; i++) ...[
                Divider(height: 1, color: c.border),
                InkWell(
                  onTap: onTap == null ? null : () => onTap!(i),
                  hoverColor: c.primary.withValues(alpha: 0.05),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        for (var j = 0; j < columns.length; j++)
                          Expanded(
                            flex: columns[j].flex,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(padding: const EdgeInsets.only(right: 12), child: rows[i][j]),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ),
              ],
            ]),
          ),
        );
      }
      return Column(children: [
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap == null ? null : () => onTap!(i),
              child: Container(
                padding: const EdgeInsets.all(14),
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
                          child: Text(columns[j].label, style: TextStyle(fontSize: 12, color: c.muted)),
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
          icon: const Icon(LucideIcons.chevronLeft),
        ),
        IconButton(
          tooltip: t('Próxima', 'Next', 'Siguiente'),
          onPressed: offset + limit < total ? () => onPage(offset + limit) : null,
          icon: const Icon(LucideIcons.chevronRight),
        ),
      ]),
    );
  }
}

/// Campo de busca com atraso (não consulta a cada tecla).
class SearchBox extends StatefulWidget {
  const SearchBox({required this.hint, required this.onChanged, this.initial = '', this.width = 320, super.key});
  final double? width;
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
        width: widget.width,
        height: kControlH,
        child: TextField(
          controller: _ctrl,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(LucideIcons.search, size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
        borderRadius: BorderRadius.circular(10),
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
      height: kControlH,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min, children: [
        Text('$label: ', style: TextStyle(fontSize: 13, color: c.textSecondary)),
        if (narrow) Expanded(child: dropdown) else dropdown,
      ]),
    );
  }
}

/// Barra de ferramentas: busca + filtros alinhados na mesma altura; quebra em linhas coerentes.
class FilterBar extends StatelessWidget {
  const FilterBar({required this.children, this.trailing, super.key});
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
          ...children,
          ?trailing,
        ]),
      );
}

/// Abas de navegação em página: sublinhado no item ativo (substitui botões soltos).
class PortalTabs<T> extends StatelessWidget {
  const PortalTabs({required this.tabs, required this.value, required this.onChanged, super.key});
  final Map<T, String> tabs;
  final T value;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
      margin: const EdgeInsets.only(bottom: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final e in tabs.entries)
            InkWell(
              onTap: () => onChanged(e.key),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: e.key == value ? c.primary : Colors.transparent, width: 2),
                  ),
                ),
                child: Text(e.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: e.key == value ? FontWeight.w700 : FontWeight.w500,
                      color: e.key == value ? c.primary : c.textSecondary,
                    )),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Ícone em fundo suave (usar só nos indicadores principais, não em todo ícone do sistema).
class IconChip extends StatelessWidget {
  const IconChip(this.icon, {this.tone = Tone.info, this.size = 40, super.key});
  final IconData icon;
  final Tone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (tone) {
      Tone.good => c.success,
      Tone.warn => c.warning,
      Tone.bad => c.error,
      Tone.neutral => c.textSecondary,
      Tone.info => c.primary,
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(size / 3.2)),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// Indicador principal: número grande, ícone suave e legenda opcional.
class HeroStat extends StatelessWidget {
  const HeroStat({required this.label, required this.value, required this.icon, this.hint, this.tone = Tone.info, super.key});
  final String label;
  final String value;
  final String? hint;
  final IconData icon;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.hairline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          IconChip(icon, tone: tone),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: c.textSecondary)),
          ),
        ]),
        const SizedBox(height: 18),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: TextStyle(fontSize: 34, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: c.textPrimary)),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(hint!, style: TextStyle(fontSize: 12.5, color: c.muted)),
          ),
      ]),
    );
  }
}

/// Uma métrica dentro de um [MetricPanel] (rótulo, valor e nota).
class Metric {
  const Metric(this.label, this.value, {this.hint, this.tone});
  final String label;
  final String value;
  final String? hint;
  final Tone? tone;
}

/// Painel único que agrupa métricas relacionadas (no lugar de vários cards isolados).
/// [footer] recebe, por exemplo, uma [DistributionBar].
class MetricPanel extends StatelessWidget {
  const MetricPanel({required this.title, required this.metrics, this.subtitle, this.footer, this.icon, this.columns = 4, super.key});
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Metric> metrics;
  final Widget? footer;

  /// Colunas máximas em tela larga (reduz sozinho em telas menores).
  final int columns;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.hairline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[Icon(icon, size: 18, color: c.primary), const SizedBox(width: 10)],
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary)),
          ),
        ]),
        if (subtitle != null)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle!, style: TextStyle(fontSize: 13, color: c.muted))),
        const SizedBox(height: 18),
        Builder(builder: (context) {
          final w = MediaQuery.sizeOf(context).width;
          final cols = (w >= 1200 ? columns : (w >= kWide ? (columns < 3 ? columns : 3) : 2)).clamp(1, metrics.length);
          final rows = <Widget>[];
          for (var i = 0; i < metrics.length; i += cols) {
            final slice = metrics.skip(i).take(cols).toList();
            rows.add(Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 20),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (var j = 0; j < cols; j++) ...[
                  if (j > 0) const SizedBox(width: 20),
                  Expanded(child: j < slice.length ? _MetricCell(slice[j]) : const SizedBox.shrink()),
                ],
              ]),
            ));
          }
          return Column(children: rows);
        }),
        if (footer != null) ...[const SizedBox(height: 20), footer!],
      ]),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell(this.m);
  final Metric m;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (m.tone) {
      Tone.good => c.success,
      Tone.warn => c.warning,
      Tone.bad => c.error,
      _ => c.textPrimary,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(m.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.textSecondary)),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(m.value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: color)),
      ),
      if (m.hint != null)
        Padding(padding: const EdgeInsets.only(top: 2), child: Text(m.hint!, style: TextStyle(fontSize: 12, color: c.muted))),
    ]);
  }
}

/// Barra segmentada de distribuição (só com valores reais) e legenda.
class DistributionBar extends StatelessWidget {
  const DistributionBar({required this.segments, super.key});
  final List<({String label, num value, Tone tone})> segments;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = PortalStrings.watch(context);
    final total = segments.fold<num>(0, (a, e) => a + e.value);
    if (total <= 0) {
      return Text(t('Sem dados para distribuir ainda.', 'No data to distribute yet.', 'Aún no hay datos que distribuir.'),
          style: TextStyle(fontSize: 12.5, color: c.muted));
    }
    Color colorOf(Tone tone) => switch (tone) {
          Tone.good => c.success,
          Tone.warn => c.warning,
          Tone.bad => c.error,
          Tone.neutral => c.textSecondary.withValues(alpha: 0.55),
          Tone.info => c.primary,
        };
    final shown = segments.where((e) => e.value > 0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 10,
          child: Row(children: [
            for (final e in shown)
              Expanded(flex: (e.value * 1000).round().clamp(1, 1 << 30), child: Container(height: 10, color: colorOf(e.tone))),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 18, runSpacing: 6, children: [
        for (final e in segments)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: colorOf(e.tone), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('${e.label} · ${t.number(e.value)}', style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
          ]),
      ]),
    ]);
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
                      color: c.primary.withValues(alpha: 0.85),
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
        Text(labels.isEmpty ? '' : labels.first, style: TextStyle(fontSize: 10, color: c.muted)),
        Text(labels.isEmpty ? '' : labels.last, style: TextStyle(fontSize: 10, color: c.muted)),
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

/// Tema do portal: refina botões, campos, diálogos e tooltips SÓ dentro do /partners
/// (o aplicativo do aluno não é afetado). Parte do tema do app, sem cores fixas.
ThemeData portalTheme(BuildContext context) {
  final base = Theme.of(context);
  final c = context.colors;
  final shape = WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  ButtonStyle refine(ButtonStyle? s, {double h = kControlH}) => (s ?? const ButtonStyle()).merge(ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(0, h)),
        shape: shape,
        elevation: const WidgetStatePropertyAll(0),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18)),
      ));
  OutlineInputBorder border(Color color, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: color, width: w));
  return base.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(style: refine(base.elevatedButtonTheme.style)),
    filledButtonTheme: FilledButtonThemeData(style: refine(base.filledButtonTheme.style)),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: refine(base.outlinedButtonTheme.style).merge(ButtonStyle(side: WidgetStatePropertyAll(BorderSide(color: c.border))))),
    textButtonTheme: TextButtonThemeData(style: refine(base.textButtonTheme.style, h: 40)),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      border: border(c.border),
      enabledBorder: border(c.border),
      focusedBorder: border(c.primary, 1.6),
      errorBorder: border(c.error),
      focusedErrorBorder: border(c.error, 1.6),
      hintStyle: TextStyle(color: c.muted, fontSize: 14),
      labelStyle: TextStyle(color: c.textSecondary),
    ),
    dialogTheme: base.dialogTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: c.hairline)),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
    ),
    tooltipTheme: base.tooltipTheme.copyWith(
      waitDuration: const Duration(milliseconds: 350),
      textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: DividerThemeData(color: c.hairline, space: 1, thickness: 1),
  );
}

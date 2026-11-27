import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';

class ModernAppBar extends StatelessWidget {
  const ModernAppBar({
    required this.title,
    super.key,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  // Optional action at the far right (e.g. an overflow menu).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 20, 14),
        decoration: BoxDecoration(
          color: context.colors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          // Sem subtítulo: seta e título centralizados pelo próprio layout (sem "empurrões" em pixels, que
          // variam com a fonte de cada plataforma). Com subtítulo: tudo no topo, e o título ganha só o
          // espaço que falta para a linha dele ficar na altura do centro da seta.
          crossAxisAlignment: subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            if (showBackButton) ...[
              // A proper round IconButton, standard Material style -- not
              // the old bare Icon wrapped in an InkWell, which had a
              // smaller, one-off tap area. Compact density keeps its
              // footprint close to a single line of title text, so it
              // doesn't grow the header even when there's no subtitle.
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final text = Text(
      title,
      style: TextStyle(
        fontSize: 24,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      ),
    );
    if (!showBackButton || subtitle == null) {
      return text;
    }
    // Linha do título = 24 * 1.1; a seta ocupa 32: centraliza a linha na seta.
    return Padding(padding: const EdgeInsets.only(top: (_backSize - 24 * 1.1) / 2), child: text);
  }

  static const _backSize = 32.0;
}

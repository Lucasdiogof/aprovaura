import 'package:flutter/material.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';

/// The loader every existing call site already uses, now drawn as the
/// Aprovaura sparkles ([AppAuraLoader]) -- one identity everywhere, from
/// [AppButton] to [AppLoadingOverlay], without touching each caller.
///
/// New code can use [AppAuraLoader] directly (with its small / medium /
/// large sizes); this stays as the thin, backwards-compatible name.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = AppAuraLoader.smallSize,
    this.color,
    this.semanticsLabel,
  });

  final double size;

  /// Only where the loader sits on a colour that needs one plain colour
  /// for contrast (white on a solid brand-violet button). Null keeps the
  /// brand sparkles.
  final Color? color;

  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) =>
      AppAuraLoader(size: size, color: color, semanticsLabel: semanticsLabel);
}

import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/widgets/essay_supporting_text_view.dart';
import 'package:aura/shared/widgets/app_sheet_frame.dart';

/// The proposal, reachable from inside the editor. A sheet rather than a
/// panel: consulting the prompt is something you do for a moment, and a
/// permanent panel would eat the writing area it is meant to serve.
Future<void> showEssayPromptSheet(
  BuildContext context, {
  required EssayTheme theme,
  required AppLanguage language,
}) {
  return AppSheetFrame.show<void>(
    context,
    (_) => _EssayPromptSheet(theme: theme, language: language),
  );
}

class _EssayPromptSheet extends StatelessWidget {
  const _EssayPromptSheet({required this.theme, required this.language});

  final EssayTheme theme;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final t = EssayStrings(language);
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          theme.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.proposalHeading.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  theme.prompt,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: colors.textPrimary,
                  ),
                ),
                if (theme.supportingTexts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    t.supportingTextsHeading.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: colors.textSecondary,
                    ),
                  ),
                  for (final text in theme.supportingTexts) ...[
                    const SizedBox(height: AppSpacing.md),
                    EssaySupportingTextView(text: text),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

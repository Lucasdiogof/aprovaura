import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';
import 'package:aura/shared/widgets/app_sheet_frame.dart';
import 'package:aura/shared/widgets/app_button.dart';

/// "Seu simulado": the last look at the config before creating it, with
/// exam mode spelled out. Resolves to true only on "Começar simulado".
Future<bool> showMockExamConfirmSheet(
  BuildContext context, {
  required List<MockExamSubjectConfig> selections,
  required AppLanguage language,
}) async {
  final confirmed = await AppSheetFrame.show<bool>(
    context,
    (_) => _MockExamConfirmSheet(selections: selections, language: language),
  );
  return confirmed ?? false;
}

class _MockExamConfirmSheet extends StatelessWidget {
  const _MockExamConfirmSheet({
    required this.selections,
    required this.language,
  });

  final List<MockExamSubjectConfig> selections;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final t = MockExamStrings(language);
    final total = selections.fold(0, (sum, e) => sum + e.questionCount);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.confirmTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final entry in selections)
                  _SummaryRow(entry: entry, language: language),
              ],
            ),
          ),
        ),
        Divider(color: context.colors.border, height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text(
                t.totalLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            Text(
              t.questionCount(total),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lock_clock_outlined,
                size: 20,
                color: context.colors.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.examModeTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.examModeDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: t.confirmStartButton,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.confirmBackButton),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.entry, required this.language});

  final MockExamSubjectConfig entry;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final t = MockExamStrings(language);
    final style = subjectStyle(
      entry.subject,
      language,
      fallbackColor: context.colors.primary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Icon(style.icon, size: 18, color: style.color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  '${entry.difficulty.label(language)} · '
                  '${t.questionCount(entry.questionCount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

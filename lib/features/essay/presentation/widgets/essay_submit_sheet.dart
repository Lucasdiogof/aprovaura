import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_sheet_frame.dart';

/// Last look before freezing the text. Says plainly what sending costs --
/// this version stops being editable -- and that another attempt is always
/// possible, which is what makes the decision easy rather than scary.
///
/// Resolves to true only on "Enviar redação".
Future<bool> showEssaySubmitSheet(
  BuildContext context, {
  required EssayStrings strings,
}) async {
  final confirmed = await AppSheetFrame.show<bool>(
    context,
    (_) => _SubmitSheet(strings: strings),
  );
  return confirmed ?? false;
}

class _SubmitSheet extends StatelessWidget {
  const _SubmitSheet({required this.strings});

  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.submitConfirmTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          strings.submitConfirmDescription,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: strings.submitConfirmAction,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.submitReviewAction),
        ),
      ],
    );
  }
}

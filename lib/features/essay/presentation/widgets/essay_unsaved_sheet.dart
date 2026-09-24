import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_sheet_frame.dart';

enum EssayUnsavedChoice {
  /// A retry from inside the sheet succeeded.
  saved,

  /// The person chose to leave with the text still unsaved.
  leave,
}

/// Shown only when leaving with text the server never accepted, and only
/// after an automatic attempt has already failed.
///
/// It never claims the text is safe. Walking away is offered plainly, in
/// the error colour, because that is what it costs.
Future<EssayUnsavedChoice?> showEssayUnsavedSheet(
  BuildContext context, {
  required EssayStrings strings,
  required Future<bool> Function() onRetry,
}) {
  return AppSheetFrame.show<EssayUnsavedChoice>(
    context,
    (_) => _UnsavedSheet(strings: strings, onRetry: onRetry),
  );
}

class _UnsavedSheet extends StatefulWidget {
  const _UnsavedSheet({required this.strings, required this.onRetry});

  final EssayStrings strings;
  final Future<bool> Function() onRetry;

  @override
  State<_UnsavedSheet> createState() => _UnsavedSheetState();
}

class _UnsavedSheetState extends State<_UnsavedSheet> {
  bool _saving = false;

  Future<void> _retry() async {
    if (_saving) return;
    setState(() => _saving = true);
    final saved = await widget.onRetry();
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(EssayUnsavedChoice.saved);
      return;
    }
    // Still failing: stay open so the text is not abandoned by accident.
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.strings;
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.unsavedTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          t.unsavedDescription,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: t.trySavingAgain,
          isLoading: _saving,
          onPressed: _retry,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: _saving
              ? null
              : () => Navigator.of(context).pop(EssayUnsavedChoice.leave),
          child: Text(t.leaveAnyway, style: TextStyle(color: colors.error)),
        ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(t.cancelAction),
        ),
      ],
    );
  }
}

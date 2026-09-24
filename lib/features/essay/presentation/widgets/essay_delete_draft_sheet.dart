import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_sheet_frame.dart';

/// Destructive confirmation for throwing the draft away.
///
/// Resolves to true when the server confirmed the deletion, false when it
/// refused, and null when the person backed out. The delete runs inside the
/// sheet so the button can show its own progress and swallow the second
/// tap.
///
/// It only ever touches the draft. A submission already sent is immutable
/// and has no delete policy at all, so starting a new text and discarding
/// it cannot reach a previous attempt.
Future<bool?> showEssayDeleteDraftSheet(
  BuildContext context, {
  required EssayStrings strings,
  required Future<bool> Function() onConfirm,
}) {
  return AppSheetFrame.show<bool>(
    context,
    (_) => _DeleteDraftSheet(strings: strings, onConfirm: onConfirm),
  );
}

class _DeleteDraftSheet extends StatefulWidget {
  const _DeleteDraftSheet({required this.strings, required this.onConfirm});

  final EssayStrings strings;
  final Future<bool> Function() onConfirm;

  @override
  State<_DeleteDraftSheet> createState() => _DeleteDraftSheetState();
}

class _DeleteDraftSheetState extends State<_DeleteDraftSheet> {
  bool _deleting = false;

  Future<void> _confirm() async {
    if (_deleting) return;
    setState(() => _deleting = true);
    final deleted = await widget.onConfirm();
    if (!mounted) return;
    Navigator.of(context).pop(deleted);
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
          t.deleteDraftTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          t.deleteDraftDescription,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: t.deleteDraftAction,
          isLoading: _deleting,
          onPressed: _confirm,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(),
          child: Text(t.cancelAction),
        ),
      ],
    );
  }
}

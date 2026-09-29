import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/shared/widgets/app_sheet_frame.dart';
import 'package:aura/shared/widgets/app_button.dart';

enum MockExamActiveChoice { continueExam, discarded }

/// "Você já tem um simulado em andamento": continue it, or discard it and
/// build another. Discarding only happens on that explicit tap -- the sheet
/// runs [onDiscard] itself (with a loading state and an inline error) and
/// only resolves to [MockExamActiveChoice.discarded] once the server
/// confirmed. Null means the user cancelled.
Future<MockExamActiveChoice?> showMockExamActiveSheet(
  BuildContext context, {
  required ActiveMockExam? active,
  required AppLanguage language,
  required Future<MockExamFailure?> Function(String mockExamId) onDiscard,
}) => AppSheetFrame.show<MockExamActiveChoice>(
  context,
  (_) => _MockExamActiveSheet(
    active: active,
    language: language,
    onDiscard: onDiscard,
  ),
);

class _MockExamActiveSheet extends StatefulWidget {
  const _MockExamActiveSheet({
    required this.active,
    required this.language,
    required this.onDiscard,
  });

  final ActiveMockExam? active;
  final AppLanguage language;
  final Future<MockExamFailure?> Function(String mockExamId) onDiscard;

  @override
  State<_MockExamActiveSheet> createState() => _MockExamActiveSheetState();
}

class _MockExamActiveSheetState extends State<_MockExamActiveSheet> {
  bool _isDiscarding = false;
  String? _error;

  Future<void> _discard() async {
    final active = widget.active;
    if (active == null) return;
    setState(() {
      _isDiscarding = true;
      _error = null;
    });
    // Remote and destructive: the app's blocking overlay covers it from
    // the tap on, and always comes down (run() has its own finally) --
    // on success the sheet closes with "discarded", on failure it stays
    // open with the reason, ready for another try. Never a reaction.
    final failure = await context.read<AppBlockingLoadingCubit>().run(
      () => widget.onDiscard(active.id),
      message: MockExamStrings(widget.language).discardingExam,
    );
    if (!mounted) return;
    if (failure == null || failure.kind == MockExamFailureKind.notInProgress) {
      // notInProgress: it was already finished/discarded elsewhere -- either
      // way nothing is blocking a new exam any more.
      Navigator.of(context).pop(MockExamActiveChoice.discarded);
      return;
    }
    setState(() {
      _isDiscarding = false;
      _error = MockExamStrings(widget.language).failureMessage(failure);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = MockExamStrings(widget.language);
    final active = widget.active;
    return PopScope(
      canPop: !_isDiscarding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: context.colors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.activeTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            active == null
                ? t.activeFallbackDescription
                : t.answeredProgress(
                    active.answeredCount,
                    active.questionCount,
                  ),
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textSecondary),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.colors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: t.activeContinueButton,
              onPressed: _isDiscarding || active == null
                  ? null
                  : () => Navigator.of(
                      context,
                    ).pop(MockExamActiveChoice.continueExam),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.error,
                side: BorderSide(
                  color: context.colors.error.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: _isDiscarding || active == null ? null : _discard,
              // The overlay is the feedback; the button only stays blocked.
              child: Text(t.activeDiscardButton),
            ),
          ),
          TextButton(
            onPressed: _isDiscarding ? null : () => Navigator.of(context).pop(),
            child: Text(t.cancelButton),
          ),
        ],
      ),
    );
  }
}

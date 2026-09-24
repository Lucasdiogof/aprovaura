import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_score.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Where a handed-in exam lands. TECHNICAL PLACEHOLDER until FASE 6 (the
/// real result: per subject/difficulty via get_mock_exam_result(), CTAs):
/// only the server's grade, so finishing has a real destination today.
class MockExamResultPage extends StatelessWidget {
  const MockExamResultPage({required this.score, super.key});

  final MockExamScore score;

  @override
  Widget build(BuildContext context) {
    final t = MockExamStrings(context.watch<LocaleCubit>().state);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: t.sessionTitle, showBackButton: true),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 44,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.resultTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.resultScore(score.correctCount, score.scoredCount),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (score.blankCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        t.resultBlank(score.blankCount),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      t.resultPlaceholderNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: t.backHomeButton,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

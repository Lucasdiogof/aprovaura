import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_review_cubit.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_review_state.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_answer_option.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/content_width.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Read-only review of one finished mock exam: every wrong or blank
/// question, with the correct answer, what was picked (when it wasn't
/// blank), and the explanation -- exactly what "não tem como saber as
/// questões que errei" was asking for, right after the result screen.
/// Re-answering them is a different feature (Revisar erros, topic by
/// topic) -- this one only shows what happened, it never grades again.
class MockExamReviewPage extends StatelessWidget {
  const MockExamReviewPage({required this.mockExamId, super.key});

  final String mockExamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MockExamReviewCubit(sl<MockExamRepository>(), mockExamId: mockExamId),
      child: const _MockExamReviewView(),
    );
  }
}

class _MockExamReviewView extends StatelessWidget {
  const _MockExamReviewView();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = MockExamStrings(language);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: t.reviewPageTitle, showBackButton: true),
          Expanded(
            child: BlocBuilder<MockExamReviewCubit, MockExamReviewState>(
              builder: (context, state) => switch (state) {
                MockExamReviewLoading() => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                ),
                MockExamReviewError() => _ErrorView(
                  strings: t,
                  onRetry: context.read<MockExamReviewCubit>().load,
                ),
                MockExamReviewLoaded(:final items) => _ReviewList(
                  items: items,
                  strings: t,
                  language: language,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({
    required this.items,
    required this.strings,
    required this.language,
  });

  final List<MockExamItem> items;
  final MockExamStrings strings;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    // Only what was actually wrong or left blank -- correct answers
    // aren't what this screen is for, and would just push the mistakes
    // further down the list.
    final missed = items
        .where((item) => item.isCorrect == false || item.wasBlank)
        .toList();
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        appHorizontalPadding(context),
        AppSpacing.lg,
        appHorizontalPadding(context),
        AppSpacing.xxl,
      ),
      itemCount: missed.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) => _ReviewItemCard(
        item: missed[index],
        strings: strings,
        language: language,
      ),
    );
  }
}

class _ReviewItemCard extends StatelessWidget {
  const _ReviewItemCard({
    required this.item,
    required this.strings,
    required this.language,
  });

  final MockExamItem item;
  final MockExamStrings strings;
  final AppLanguage language;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    final t = strings;
    final style = subjectStyle(
      item.subject,
      language,
      fallbackColor: context.colors.primary,
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(style.icon, size: 16, color: style.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${style.label} · ${t.reviewQuestionLabel(item.position)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: style.color,
                  ),
                ),
              ),
              if (item.wasBlank)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    t.reviewBlankBadge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.prompt,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < item.options.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            QuizAnswerOption(
              letter: _letters[i],
              text: item.options[i],
              status: _statusFor(i),
              onTap: null,
            ),
          ],
          if (item.explanation case final explanation?
              when explanation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              explanation,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  QuizOptionStatus _statusFor(int index) {
    if (index == item.correctIndex) return QuizOptionStatus.correct;
    if (index == item.selectedIndex) return QuizOptionStatus.incorrect;
    return QuizOptionStatus.neutral;
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.strings, required this.onRetry});

  final MockExamStrings strings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              strings.reviewLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(label: strings.retryButton, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

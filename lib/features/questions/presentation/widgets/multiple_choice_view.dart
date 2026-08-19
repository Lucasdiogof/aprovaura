import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/l10n/multiple_choice_strings.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_cubit.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_state.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_answer_option.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_feedback.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_progress.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/shared/widgets/app_button.dart';

class MultipleChoiceView extends StatelessWidget {
  const MultipleChoiceView({
    required this.catalogNodeId,
    required this.onEmpty,
    super.key,
    this.repository,
    this.difficulty,
    this.trackProgress = true,
  });

  final String catalogNodeId;
  final WidgetBuilder onEmpty;
  final QuestionRepository? repository;
  final QuestionDifficulty? difficulty;
  final bool trackProgress;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MultipleChoiceCubit(
        repository ?? sl<QuestionRepository>(),
        sl<ProgressRepository>(),
        catalogNodeId: catalogNodeId,
        difficulty: difficulty,
        trackProgress: trackProgress,
      ),
      child: Builder(
        builder: (context) {
          final language = context.watch<LocaleCubit>().state;
          final t = MultipleChoiceStrings(language);
          return BlocConsumer<MultipleChoiceCubit, MultipleChoiceState>(
            listener: (context, state) {
              if (state is MultipleChoiceFinished) {
                context.read<StreakCubit>().registerActivityCompletion();
              }
            },
            builder: (context, state) => switch (state) {
              MultipleChoiceLoading() => Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              ),
              MultipleChoiceEmpty() => onEmpty(context),
              MultipleChoiceError(:final message) => _ErrorView(
                strings: t,
                message: message,
              ),
              MultipleChoiceFinished(:final correctCount, :final totalCount) =>
                _FinishedView(
                  strings: t,
                  correctCount: correctCount,
                  totalCount: totalCount,
                ),
              MultipleChoicePlaying() => _QuestionView(
                strings: t,
                state: state,
              ),
            },
          );
        },
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.strings, required this.state});

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  final MultipleChoiceStrings strings;
  final MultipleChoicePlaying state;

  QuizOptionStatus _statusFor(int index) {
    if (!state.hasAnswered) return QuizOptionStatus.neutral;
    if (index == state.currentQuestion.correctIndex) {
      return QuizOptionStatus.correct;
    }
    if (index == state.selectedIndex) return QuizOptionStatus.incorrect;
    return QuizOptionStatus.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    final wasCorrect = state.selectedIndex == question.correctIndex;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: QuizProgress(
            currentIndex: state.currentIndex,
            totalCount: state.questions.length,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.prompt,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 28),
                for (var i = 0; i < question.options.length; i++) ...[
                  QuizAnswerOption(
                    letter: _letters[i],
                    text: question.options[i],
                    status: _statusFor(i),
                    onTap: state.hasAnswered
                        ? null
                        : () => context
                              .read<MultipleChoiceCubit>()
                              .selectOption(i),
                  ),
                  if (i != question.options.length - 1)
                    const SizedBox(height: 12),
                ],
                if (state.hasAnswered) ...[
                  const SizedBox(height: 20),
                  QuizFeedback(
                    isCorrect: wasCorrect,
                    title: wasCorrect
                        ? strings.correctFeedbackTitle
                        : strings.incorrectFeedbackTitle,
                    explanation: question.explanation,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (state.hasAnswered)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: AppButton(
                label: state.isLastQuestion
                    ? strings.seeResultButton
                    : strings.nextButton,
                onPressed: () => context.read<MultipleChoiceCubit>().next(),
              ),
            ),
          ),
      ],
    );
  }
}

class _FinishedView extends StatelessWidget {
  const _FinishedView({
    required this.strings,
    required this.correctCount,
    required this.totalCount,
  });

  // Cosmetic only -- there is no XP system tracking or persisting this yet.
  static const _xpEarned = 10;

  final MultipleChoiceStrings strings;
  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final fraction = totalCount == 0 ? 0.0 : correctCount / totalCount;
    final percent = (fraction * 100).round();
    final streakState = context.watch<StreakCubit>().state;
    final currentStreak = switch (streakState) {
      StreakLoaded(:final streak) => streak.currentStreak,
      _ => 0,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _TrophyBadge(color: context.colors.primary),
          const SizedBox(height: 24),
          Text(
            strings.finishedTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.finishedSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCell(
                          icon: Icons.track_changes_rounded,
                          iconColor: context.colors.primary,
                          value: '$correctCount/$totalCount',
                          label: strings.finishedCorrectLabel,
                        ),
                      ),
                      VerticalDivider(color: context.colors.border, width: 24),
                      Expanded(
                        child: _StatCell(
                          icon: Icons.bar_chart_rounded,
                          iconColor: context.colors.primary,
                          value: '$percent%',
                          label: strings.finishedScoreLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: context.colors.border),
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      const Expanded(
                        child: _StatCell(
                          icon: Icons.star_rounded,
                          iconColor: Color(0xFFE0A32E),
                          value: '+$_xpEarned',
                          label: 'XP',
                        ),
                      ),
                      VerticalDivider(color: context.colors.border, width: 24),
                      Expanded(
                        child: _StatCell(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFE8763D),
                          value: '$currentStreak',
                          label: strings.finishedStreakLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: strings.continueButton,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.read<MultipleChoiceCubit>().load(),
            child: Text(strings.finishedRetryButton),
          ),
          Divider(height: 24, color: context.colors.border),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(
              strings.backToTrailButton,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  const _TrophyBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 32,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Icon(
            Icons.emoji_events_rounded,
            color: context.colors.onPrimary,
            size: 44,
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.strings, required this.message});

  final MultipleChoiceStrings strings;
  final String message;

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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: strings.retryButton,
              onPressed: () => context.read<MultipleChoiceCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}

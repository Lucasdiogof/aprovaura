import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/l10n/multiple_choice_strings.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_cubit.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_state.dart';
import 'package:aura/shared/widgets/app_button.dart';

class MultipleChoiceView extends StatelessWidget {
  const MultipleChoiceView({
    required this.catalogNodeId,
    required this.onEmpty,
    super.key,
  });

  final String catalogNodeId;
  final WidgetBuilder onEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MultipleChoiceCubit(
        sl<QuestionRepository>(),
        catalogNodeId: catalogNodeId,
      ),
      child: Builder(
        builder: (context) {
          final language = context.watch<LocaleCubit>().state;
          final t = MultipleChoiceStrings(language);
          return BlocBuilder<MultipleChoiceCubit, MultipleChoiceState>(
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

  final MultipleChoiceStrings strings;
  final MultipleChoicePlaying state;

  Color? _optionColor(BuildContext context, int index) {
    if (!state.hasAnswered) return null;
    final colors = context.colors;
    if (index == state.currentQuestion.correctIndex) {
      return colors.success.withValues(alpha: 0.15);
    }
    if (index == state.selectedIndex) {
      return colors.error.withValues(alpha: 0.15);
    }
    return null;
  }

  Color _optionBorderColor(BuildContext context, int index) {
    if (!state.hasAnswered) return context.colors.border;
    final colors = context.colors;
    if (index == state.currentQuestion.correctIndex) return colors.success;
    if (index == state.selectedIndex) return colors.error;
    return colors.border;
  }

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.questionProgress(
              state.currentIndex + 1,
              state.questions.length,
            ),
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            question.prompt,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < question.options.length; i++) ...[
            Material(
              color: _optionColor(context, i) ?? context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: state.hasAnswered
                    ? null
                    : () => context.read<MultipleChoiceCubit>().selectOption(i),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _optionBorderColor(context, i)),
                  ),
                  child: Text(
                    question.options[i],
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (state.hasAnswered && question.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              question.explanation!,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (state.hasAnswered) ...[
            const SizedBox(height: 24),
            AppButton(
              label: state.isLastQuestion
                  ? strings.seeResultButton
                  : strings.nextButton,
              onPressed: () => context.read<MultipleChoiceCubit>().next(),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinishedView extends StatelessWidget {
  const _FinishedView({
    required this.strings,
    required this.correctCount,
    required this.totalCount,
  });

  final MultipleChoiceStrings strings;
  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: context.colors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              strings.finishedTitle,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.finishedScore(correctCount, totalCount),
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: strings.retryButton,
              onPressed: () => context.read<MultipleChoiceCubit>().load(),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(strings.backButton),
            ),
          ],
        ),
      ),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_achievement_badge.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_activity_completion.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_report_repository.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/l10n/multiple_choice_strings.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_cubit.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_state.dart';
import 'package:aura/features/questions/presentation/question_meta_label.dart';
import 'package:aura/features/questions/presentation/quiz_result_tier.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_answer_option.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_feedback.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_progress.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/app_loading_indicator.dart';
import 'package:aura/shared/l10n/aura_strings.dart';
import 'package:aura/shared/widgets/aura/aura_glyph.dart';
import 'package:aura/shared/widgets/stat_cell.dart';

class MultipleChoiceView extends StatefulWidget {
  const MultipleChoiceView({
    required this.catalogNodeId,
    required this.onEmpty,
    super.key,
    this.repository,
    this.difficulty,
    this.trackProgress = true,
    this.awardsRewards = true,
    this.isCorrectionMode = false,
    this.contextLabel,
    this.onSessionFinished,
  });

  final String catalogNodeId;
  final WidgetBuilder onEmpty;
  final QuestionRepository? repository;
  final QuestionDifficulty? difficulty;
  final bool trackProgress;
  // False for sessions that shouldn't grant XP or count toward the streak
  // (currently: reviewing already-answered wrong questions), so finishing
  // the same activity repeatedly there can't be farmed for rewards.
  final bool awardsRewards;
  // True for error-review sessions: the result screen reads as a
  // correction instead of a fresh attempt, and only offers a way back.
  final bool isCorrectionMode;
  // Breadcrumb shown above the question, e.g. "Geografia · Brasil ·
  // Relevo" -- optional because not every caller has that chain handy
  // (quick practice mixes subjects, dossiers don't have one at all).
  final String? contextLabel;
  // Called once the deck is done, on top of the result screen. Quick
  // practice uses it to ask whether to deal another deck; passing the cubit
  // lets the caller reload without reaching into this widget's internals.
  final void Function(BuildContext context, MultipleChoiceCubit cubit)?
  onSessionFinished;

  @override
  State<MultipleChoiceView> createState() => _MultipleChoiceViewState();
}

class _MultipleChoiceViewState extends State<MultipleChoiceView> {
  // Captured once, before this session's own answers can move any of these
  // numbers -- the Aurudo Reaction System diffs against these to notice a
  // level up, a streak milestone or the daily goal completing *because of
  // this session*, never because of one that already happened earlier.
  // Null when awardsRewards is false: a session that grants no rewards has
  // nothing to diff.
  AurudoRewardsSnapshot? _before;
  bool _snapshotTaken = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_snapshotTaken || !widget.awardsRewards) return;
    _snapshotTaken = true;
    _before = AurudoRewardsSnapshot.fromCubits(context);
    unawaited(_loadDailyGoalBefore());
  }

  Future<void> _loadDailyGoalBefore() async {
    final goal = await AurudoRewardsSnapshot.readDailyGoal();
    if (!mounted || goal == null) return;
    setState(() => _before = _before?.withDailyGoal(goal));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MultipleChoiceCubit(
        widget.repository ?? sl<QuestionRepository>(),
        sl<ProgressRepository>(),
        sl<FavoritesRepository>(),
        catalogNodeId: widget.catalogNodeId,
        difficulty: widget.difficulty,
        trackProgress: widget.trackProgress,
      ),
      child: Builder(
        builder: (context) {
          final language = context.watch<LocaleCubit>().state;
          final t = MultipleChoiceStrings(language);
          return BlocConsumer<MultipleChoiceCubit, MultipleChoiceState>(
            listener: (context, state) {
              if (state is! MultipleChoiceFinished) return;
              widget.onSessionFinished?.call(
                context,
                context.read<MultipleChoiceCubit>(),
              );
            },
            builder: (context, state) {
              final canPop =
                  state is! MultipleChoicePlaying || state.isFirstQuestion;
              return PopScope(
                canPop: canPop,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) return;
                  context.read<MultipleChoiceCubit>().previous();
                },
                child: switch (state) {
                  MultipleChoiceLoading() => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  MultipleChoiceEmpty() => widget.onEmpty(context),
                  MultipleChoiceError(:final message) => _ErrorView(
                    strings: t,
                    message: message,
                  ),
                  MultipleChoiceFinished(
                    :final correctCount,
                    :final totalCount,
                    :final attemptId,
                  ) =>
                    _FinishedView(
                      key: ValueKey(attemptId),
                      strings: t,
                      correctCount: correctCount,
                      totalCount: totalCount,
                      attemptId: attemptId,
                      awardsRewards: widget.awardsRewards,
                      isCorrectionMode: widget.isCorrectionMode,
                      before: _before,
                    ),
                  MultipleChoicePlaying() => _QuestionView(
                    strings: t,
                    state: state,
                    showFavoriteButton: widget.trackProgress,
                    contextLabel: widget.contextLabel,
                  ),
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.strings,
    required this.state,
    required this.showFavoriteButton,
    this.contextLabel,
  });

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  final MultipleChoiceStrings strings;
  final MultipleChoicePlaying state;
  final bool showFavoriteButton;
  final String? contextLabel;

  QuizOptionStatus _statusFor(int index) {
    if (!state.hasAnswered) return QuizOptionStatus.neutral;
    if (index == state.currentQuestion.correctIndex) {
      return QuizOptionStatus.correct;
    }
    if (index == state.selectedIndex) return QuizOptionStatus.incorrect;
    return QuizOptionStatus.neutral;
  }

  Future<void> _confirmReport(BuildContext context) async {
    final questionId = state.currentQuestion.id;
    final questionPrompt = state.currentQuestion.prompt;
    await AppInfoBottomSheet.showInfo(
      context,
      title: strings.reportQuestionTitle,
      description: strings.reportQuestionDescription,
      primaryActionLabel: strings.reportQuestionConfirm,
      onPrimaryAction: () async {
        final result = await sl<QuestionReportRepository>().reportQuestion(
          questionId: questionId,
          questionPrompt: questionPrompt,
        );
        if (!context.mounted) return;
        final message = switch (result) {
          Success() => strings.reportQuestionThanks,
          Error() => strings.reportQuestionFailed,
        };
        await AppInfoBottomSheet.showInfo(context, description: message);
      },
      secondaryActionLabel: strings.reportQuestionCancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion;
    final wasCorrect = state.selectedIndex == question.correctIndex;
    final label = contextLabel ?? questionMetaLabel(question, strings.language);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null && label.isNotEmpty) ...[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  Expanded(
                    child: QuizProgress(
                      strings: strings,
                      currentIndex: state.currentIndex,
                      totalCount: state.questions.length,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmReport(context),
                    icon: Icon(
                      Icons.flag_outlined,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  if (showFavoriteButton)
                    IconButton(
                      onPressed: () =>
                          context.read<MultipleChoiceCubit>().toggleFavorite(),
                      icon: Icon(
                        state.isCurrentFavorited
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: state.isCurrentFavorited
                            ? context.colors.primary
                            : context.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
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
                // Disabled (with a spinner) until the answer just given is
                // confirmed persisted -- see MultipleChoiceCubit.next().
                isLoading: state.isPersisting,
                onPressed: () => context.read<MultipleChoiceCubit>().next(),
              ),
            ),
          ),
      ],
    );
  }
}

/// The finished screen, now presented through the Aurudo Reaction System
/// instead of a static badge. Three steps, in order:
///
/// 1. If [awardsRewards], award XP and register the streak completion
///    (awaited -- the numbers must be final before anything is shown) and
///    read the daily-goal count again, all *after* the deck's last answer
///    is already persisted (this widget only exists once the cubit reaches
///    `MultipleChoiceFinished`, which is itself gated on that).
/// 2. Resolve the one reaction that should play from the before/after
///    snapshots -- no thresholds duplicated here.
/// 3. Check the reaction ledger for [attemptId]: already played once (a
///    rebuild reaching this same attempt again) shows the final state
///    instantly instead of replaying the scene, and only a reaction not
///    yet marked gets marked now, at the point it actually starts
///    presenting.
class _FinishedView extends StatefulWidget {
  const _FinishedView({
    required this.strings,
    required this.correctCount,
    required this.totalCount,
    required this.attemptId,
    required this.awardsRewards,
    required this.isCorrectionMode,
    required this.before,
    super.key,
  });

  final MultipleChoiceStrings strings;
  final int correctCount;
  final int totalCount;
  final String attemptId;
  final bool awardsRewards;
  final bool isCorrectionMode;

  /// Null when this session grants nothing, so there is no achievement to
  /// diff for -- see [awardAndResolveReaction].
  final AurudoRewardsSnapshot? before;

  @override
  State<_FinishedView> createState() => _FinishedViewState();
}

class _FinishedViewState extends State<_FinishedView> {
  AurudoReaction? _reaction;
  bool _instant = false;

  @override
  void initState() {
    super.initState();
    unawaited(_resolve());
  }

  Future<void> _resolve() async {
    final reaction = await awardAndResolveReaction(
      context: context,
      before: widget.awardsRewards ? widget.before : null,
      attemptId: widget.attemptId,
      correctCount: widget.correctCount,
      totalAnswered: widget.totalCount,
    );
    if (!mounted) return;
    final alreadySeen = markReactionSeen(widget.attemptId);
    setState(() {
      _reaction = reaction;
      _instant = alreadySeen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reaction = _reaction;
    if (reaction == null) {
      return const Center(child: AppLoadingIndicator());
    }

    final strings = widget.strings;
    final fraction = widget.totalCount == 0
        ? 0.0
        : widget.correctCount / widget.totalCount;
    final tier = QuizResultTier.fromFraction(fraction);
    final xpEarned = widget.correctCount * UserXp.auraPerCorrectAnswer;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: AurudoReactionStage(
        reaction: reaction,
        instant: _instant,
        headline: _FinishedHeadline(
          strings: strings,
          type: reaction.type,
          tier: tier,
          totalCount: widget.totalCount,
          isCorrectionMode: widget.isCorrectionMode,
        ),
        content: _ResultStatsCard(
          correctCount: widget.correctCount,
          totalCount: widget.totalCount,
          percent: (fraction * 100).round(),
          xpEarned: xpEarned,
          showXp: widget.awardsRewards,
          strings: strings,
        ),
        stats: reaction.secondary.isEmpty
            ? null
            : _SecondaryBadgesRow(
                achievements: reaction.secondary,
                strings: strings,
              ),
        cta: _FinishedCtas(
          strings: strings,
          tier: tier,
          isCorrectionMode: widget.isCorrectionMode,
        ),
      ),
    );
  }
}

class _FinishedHeadline extends StatelessWidget {
  const _FinishedHeadline({
    required this.strings,
    required this.type,
    required this.tier,
    required this.totalCount,
    required this.isCorrectionMode,
  });

  final MultipleChoiceStrings strings;
  final AurudoReactionType type;
  final QuizResultTier tier;
  final int totalCount;
  final bool isCorrectionMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isCorrectionMode
                ? strings.correctionTitle
                : strings.reactionHeadline(type, tier),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCorrectionMode
                ? strings.correctionSubtitle(totalCount)
                : strings.finishedSubtitle(tier),
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ResultStatsCard extends StatelessWidget {
  const _ResultStatsCard({
    required this.correctCount,
    required this.totalCount,
    required this.percent,
    required this.xpEarned,
    required this.showXp,
    required this.strings,
  });

  final int correctCount;
  final int totalCount;
  final int percent;
  final int xpEarned;
  final bool showXp;
  final MultipleChoiceStrings strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: StatCell(
                  icon: Icons.track_changes_rounded,
                  iconColor: context.colors.primary,
                  value: '$correctCount/$totalCount',
                  label: strings.finishedCorrectLabel,
                ),
              ),
              VerticalDivider(color: context.colors.border, width: 1),
              Expanded(
                child: StatCell(
                  icon: Icons.bar_chart_rounded,
                  iconColor: context.colors.primary,
                  value: '$percent%',
                  label: strings.finishedScoreLabel,
                ),
              ),
              if (showXp) ...[
                VerticalDivider(color: context.colors.border, width: 1),
                Expanded(
                  child: StatCell(
                    icon: Icons.star_rounded,
                    iconColor: context.colors.auraViolet,
                    iconWidget: const AuraGlyph(size: 22),
                    value: '+$xpEarned',
                    label: AuraStrings.unit,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryBadgesRow extends StatelessWidget {
  const _SecondaryBadgesRow({
    required this.achievements,
    required this.strings,
  });

  final List<AurudoSecondaryAchievement> achievements;
  final MultipleChoiceStrings strings;

  String _labelFor(AurudoSecondaryAchievement achievement) =>
      switch (achievement.type) {
        AurudoSecondaryAchievementType.levelUp => strings.levelUpBadge(
          achievement.value!,
        ),
        AurudoSecondaryAchievementType.streakMilestone =>
          strings.streakMilestoneBadge(achievement.value!),
        AurudoSecondaryAchievementType.dailyGoalComplete =>
          strings.dailyGoalBadge,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final achievement in achievements)
            AurudoAchievementBadge(
              achievement: achievement,
              label: _labelFor(achievement),
            ),
        ],
      ),
    );
  }
}

class _FinishedCtas extends StatelessWidget {
  const _FinishedCtas({
    required this.strings,
    required this.tier,
    required this.isCorrectionMode,
  });

  final MultipleChoiceStrings strings;
  final QuizResultTier tier;
  final bool isCorrectionMode;

  @override
  Widget build(BuildContext context) {
    if (isCorrectionMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AppButton(
          label: strings.backButton,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      );
    }
    // Only two distinct actions exist (leave, or do another round); which
    // one leads depends on how the attempt went, instead of always
    // offering "Continuar" and "Voltar para trilha" as if they were
    // different things.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: tier.isCelebratory
            ? [
                AppButton(
                  label: strings.continueButton,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.read<MultipleChoiceCubit>().load(),
                  child: Text(strings.finishedRetryButton),
                ),
              ]
            : [
                AppButton(
                  label: strings.retryButton,
                  onPressed: () => context.read<MultipleChoiceCubit>().load(),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(
                    strings.backButton,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
              ],
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
            // Frustrated, not scolding: the load failed, the user didn't.
            const AurudoIllustration(pose: AurudoPose.frustrated, size: 120),
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

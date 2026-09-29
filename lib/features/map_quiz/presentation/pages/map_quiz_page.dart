import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/utils/id_generator.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_achievement_badge.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_activity_completion.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_prompt_mode.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';
import 'package:aura/features/map_quiz/l10n/map_quiz_strings.dart';
import 'package:aura/features/map_quiz/l10n/map_region_names.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_cubit.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_state.dart';
import 'package:aura/features/map_quiz/presentation/widgets/map_quiz_board.dart';
import 'package:aura/features/map_quiz/presentation/widgets/map_quiz_header.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/presentation/quiz_result_tier.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/shared/widgets/aura/aura_badge.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_loading_indicator.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class MapQuizPage extends StatelessWidget {
  const MapQuizPage({
    required this.mapId,
    required this.catalogNodeId,
    required this.interactionType,
    required this.title,
    this.promptMode = MapPromptMode.name,
    this.backgroundMapId,
    this.attemptIdGenerator,
    this.boardBuilder,
    super.key,
  });

  final String mapId;
  final String catalogNodeId;
  final MapInteractionType interactionType;
  final String title;
  final MapPromptMode promptMode;
  // A non-interactive reference layer (e.g. world countries) shown behind
  // quizzes whose own shapes don't read as a map on their own -- short
  // strait lines or scattered points, unlike filled country polygons.
  final String? backgroundMapId;

  // Test seams, both forwarded straight to MapQuizCubit: a deterministic
  // attempt id to assert on, and a board builder that stays on the test's
  // own thread instead of going through compute(). Null in the app.
  final String Function()? attemptIdGenerator;
  final Future<MapBoard> Function(MapBoardInput)? boardBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapQuizCubit(
        sl<MapQuizRepository>(),
        sl<ProgressRepository>(),
        mapId: mapId,
        catalogNodeId: catalogNodeId,
        interactionType: interactionType,
        backgroundMapId: backgroundMapId,
        attemptIdGenerator: attemptIdGenerator ?? generateAttemptId,
        boardBuilder: boardBuilder ?? buildMapBoardInBackground,
      ),
      child: _MapQuizView(mapId: mapId, title: title, promptMode: promptMode),
    );
  }
}

class _MapQuizView extends StatefulWidget {
  const _MapQuizView({
    required this.mapId,
    required this.title,
    required this.promptMode,
  });

  final String mapId;
  final String title;
  final MapPromptMode promptMode;

  @override
  State<_MapQuizView> createState() => _MapQuizViewState();
}

class _MapQuizViewState extends State<_MapQuizView> {
  // Read while the map is still being played, before finishing it can move
  // any of these numbers -- that diff is how the Aurudo Reaction System
  // tells a level, streak or daily goal earned by THIS map from one that
  // had already happened.
  AurudoRewardsSnapshot? _before;
  bool _snapshotTaken = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_snapshotTaken) return;
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
    final language = context.watch<LocaleCubit>().state;
    final t = MapQuizStrings(language);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: widget.title, showBackButton: true),
          Expanded(
            child: BlocConsumer<MapQuizCubit, MapQuizState>(
              listener: (context, state) {
                if (state is MapQuizPlaying && state.revealed) {
                  Future.delayed(const Duration(milliseconds: 1800), () {
                    if (context.mounted) {
                      context.read<MapQuizCubit>().advancePastReveal();
                    }
                  });
                } else if (state is MapQuizPlaying && state.lastTap != null) {
                  Future.delayed(const Duration(milliseconds: 700), () {
                    if (context.mounted) {
                      context.read<MapQuizCubit>().clearFeedback();
                    }
                  });
                }
              },
              builder: (context, state) => switch (state) {
                MapQuizLoading() => Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                ),
                MapQuizError(:final message) => _ErrorView(
                  strings: t,
                  message: message,
                ),
                MapQuizFinished(
                  :final correctCount,
                  :final totalCount,
                  :final attemptId,
                ) =>
                  _FinishedView(
                    // Keyed by attempt so a retry builds a fresh state
                    // instead of reusing the finished one.
                    key: ValueKey(attemptId),
                    strings: t,
                    correctCount: correctCount,
                    totalCount: totalCount,
                    attemptId: attemptId,
                    before: _before,
                  ),
                MapQuizPlaying(
                  :final board,
                  :final regions,
                  :final remainingIds,
                  :final currentTargetId,
                  :final correctCount,
                  :final totalCount,
                  :final lastTap,
                  :final revealed,
                ) =>
                  _PlayingView(
                    strings: t,
                    mapId: widget.mapId,
                    promptMode: widget.promptMode,
                    board: board,
                    solvedIds: regions
                        .map((region) => region.id)
                        .toSet()
                        .difference(remainingIds.toSet()),
                    currentTargetId: currentTargetId,
                    correctCount: correctCount,
                    totalCount: totalCount,
                    lastTap: lastTap,
                    revealed: revealed,
                    onRegionTapped: context.read<MapQuizCubit>().onRegionTapped,
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayingView extends StatelessWidget {
  const _PlayingView({
    required this.strings,
    required this.mapId,
    required this.promptMode,
    required this.board,
    required this.solvedIds,
    required this.currentTargetId,
    required this.correctCount,
    required this.totalCount,
    required this.lastTap,
    required this.revealed,
    required this.onRegionTapped,
  });

  final MapQuizStrings strings;
  final String mapId;
  final MapPromptMode promptMode;
  final MapBoard board;
  final Set<String> solvedIds;
  final String currentTargetId;
  final int correctCount;
  final int totalCount;
  final TapFeedback? lastTap;
  // True once the miss limit is hit for the current target -- the target's
  // own region is highlighted as the answer instead of accepting taps.
  final bool revealed;
  final ValueChanged<String> onRegionTapped;

  @override
  Widget build(BuildContext context) {
    final currentTarget = board.regions.firstWhere(
      (region) => region.id == currentTargetId,
    );
    return Column(
      children: [
        MapQuizHeader(
          strings: strings,
          promptMode: promptMode,
          targetId: currentTarget.id,
          targetName: localizedRegionName(
            currentTarget.name,
            strings.language,
            mapId: mapId,
          ),
          revealed: revealed,
          correctCount: correctCount,
          totalCount: totalCount,
        ),
        Expanded(
          child: MapQuizBoard(
            board: board,
            strings: strings,
            solvedIds: solvedIds,
            currentTargetId: currentTargetId,
            lastTap: lastTap,
            revealed: revealed,
            onRegionTapped: onRegionTapped,
          ),
        ),
      ],
    );
  }
}

/// The map quiz grants a flat award per finished map rather than per
/// region (a big map can have dozens), so it calls award_quiz_xp() with a
/// correct count of one.
const _awardedCorrectCount = 1;

/// The finished map, presented through the Aurudo Reaction System -- the
/// same components and the same resolver the quiz deck uses, so a perfect
/// map celebrates exactly like a perfect deck.
///
/// Order matters: the map's rewards are granted and awaited first (same
/// calls as before, no longer fire-and-forget), only then is the reaction
/// resolved from the before/after numbers, and only then does the scene
/// start. An attempt already celebrated opens straight in its final state.
///
/// Nothing of the map itself is still mounted here: this widget replaces
/// the board entirely, so no camera, zoom or repaint runs behind the
/// reaction.
class _FinishedView extends StatefulWidget {
  const _FinishedView({
    required this.strings,
    required this.correctCount,
    required this.totalCount,
    required this.attemptId,
    required this.before,
    super.key,
  });

  final MapQuizStrings strings;
  final int correctCount;
  final int totalCount;
  final String attemptId;
  final AurudoRewardsSnapshot? before;

  @override
  State<_FinishedView> createState() => _FinishedViewState();
}

class _FinishedViewState extends State<_FinishedView> {
  /// A beat between the last answer and the celebration, so the result
  /// does not snap into place the instant the final region is tapped.
  static const _transition = Duration(milliseconds: 200);

  AurudoReaction? _reaction;
  bool _instant = false;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_resolve());
  }

  @override
  void dispose() {
    // Leaving during the beat before the scene: nothing is waiting for it
    // any more.
    _transitionTimer?.cancel();
    super.dispose();
  }

  Future<void> _resolve() async {
    final reaction = await awardAndResolveReaction(
      context: context,
      before: widget.before,
      attemptId: widget.attemptId,
      correctCount: widget.correctCount,
      totalAnswered: widget.totalCount,
      // The map has always granted a flat amount per finished map rather
      // than per region (a world map has dozens), and this phase does not
      // change that.
      awardedCorrectCount: _awardedCorrectCount,
    );
    if (!mounted) return;
    final alreadySeen = markReactionSeen(widget.attemptId);
    if (alreadySeen) {
      // Already celebrated once: this is the result being opened again,
      // and it goes straight to its final state.
      _show(reaction, instant: true);
      return;
    }
    _transitionTimer = Timer(_transition, () => _show(reaction));
  }

  void _show(AurudoReaction reaction, {bool instant = false}) {
    if (!mounted) return;
    setState(() {
      _reaction = reaction;
      _instant = instant;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reaction = _reaction;
    if (reaction == null) {
      return const Center(child: AppLoadingIndicator());
    }

    final strings = widget.strings;
    final tier = QuizResultTier.fromFraction(
      widget.totalCount == 0 ? 0 : widget.correctCount / widget.totalCount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: AurudoReactionStage(
        reaction: reaction,
        instant: _instant,
        headline: _FinishedHeadline(
          strings: strings,
          type: reaction.type,
          tier: tier,
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings.finishedScore(widget.correctCount, widget.totalCount),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 16),
              const AuraBadge(
                amount: UserXp.auraPerCorrectAnswer * _awardedCorrectCount,
              ),
            ],
          ),
        ),
        stats: reaction.secondary.isEmpty
            ? null
            : _SecondaryBadgesRow(
                achievements: reaction.secondary,
                strings: strings,
              ),
        cta: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: strings.retryButton,
                onPressed: () => context.read<MapQuizCubit>().load(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(strings.backButton),
              ),
            ],
          ),
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
  });

  final MapQuizStrings strings;
  final AurudoReactionType type;
  final QuizResultTier tier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.reactionHeadline(type, tier),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.finishedSubtitle(tier),
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Achievements that landed on this same map. Perfect stays the main
/// reaction, so these are always badges next to it, never a scene.
class _SecondaryBadgesRow extends StatelessWidget {
  const _SecondaryBadgesRow({
    required this.achievements,
    required this.strings,
  });

  final List<AurudoSecondaryAchievement> achievements;
  final MapQuizStrings strings;

  String _labelFor(AurudoSecondaryAchievement achievement) =>
      switch (achievement.type) {
        AurudoSecondaryAchievementType.levelUp => strings.levelUpBadge(
          achievement.value ?? 0,
        ),
        AurudoSecondaryAchievementType.streakMilestone =>
          strings.streakMilestoneBadge(achievement.value ?? 0),
        AurudoSecondaryAchievementType.dailyGoalComplete =>
          strings.dailyGoalBadge,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.strings, required this.message});

  final MapQuizStrings strings;
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
              onPressed: () => context.read<MapQuizCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}

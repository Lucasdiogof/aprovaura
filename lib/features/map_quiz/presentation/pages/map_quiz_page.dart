import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
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
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/questions/presentation/quiz_result_tier.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/shared/widgets/aura/aura_badge.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class MapQuizPage extends StatelessWidget {
  const MapQuizPage({
    required this.mapId,
    required this.catalogNodeId,
    required this.interactionType,
    required this.title,
    this.promptMode = MapPromptMode.name,
    this.backgroundMapId,
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
                if (state is MapQuizFinished) {
                  context.read<StreakCubit>().registerActivityCompletion();
                  // Map quiz isn't part of this phase's "+10 per correct
                  // answer" rework (it wasn't in scope, and a big map can
                  // have far more than 10 regions) -- correctCount: 1
                  // keeps its old flat +10-per-completed-map amount while
                  // still going through the new idempotent award path.
                  context.read<XpCubit>().awardQuizXp(
                    attemptId: state.attemptId,
                    correctCount: _awardedCorrectCount,
                  );
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
                MapQuizFinished(:final correctCount, :final totalCount) =>
                  _FinishedView(
                    strings: t,
                    correctCount: correctCount,
                    totalCount: totalCount,
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

class _FinishedView extends StatelessWidget {
  const _FinishedView({
    required this.strings,
    required this.correctCount,
    required this.totalCount,
  });

  final MapQuizStrings strings;
  final int correctCount;
  final int totalCount;

  AurudoPose get _pose => switch (QuizResultTier.fromFraction(
    totalCount == 0 ? 0 : correctCount / totalCount,
  )) {
    QuizResultTier.excellent => AurudoPose.farmingAura,
    QuizResultTier.good => AurudoPose.celebrating,
    QuizResultTier.developing => AurudoPose.studying,
    QuizResultTier.zero => AurudoPose.thinking,
  };

  @override
  Widget build(BuildContext context) {
    // Scrollable like the multiple-choice result: with the mascot and the
    // Aura badge this column no longer fits a short screen at large text
    // sizes.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AurudoIllustration(pose: _pose, size: 136),
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
            const SizedBox(height: 16),
            // The map quiz has always granted Aura on completion; until now
            // it was the only finished screen that never said so.
            const AuraBadge(
              amount: UserXp.auraPerCorrectAnswer * _awardedCorrectCount,
            ),
            const SizedBox(height: 24),
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

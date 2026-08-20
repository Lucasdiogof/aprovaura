import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/map_quiz/domain/entities/flag_emoji.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_prompt_mode.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';
import 'package:aura/features/map_quiz/l10n/map_quiz_strings.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_cubit.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_state.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
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
        backgroundMapId: backgroundMapId,
      ),
      child: _MapQuizView(
        interactionType: interactionType,
        title: title,
        promptMode: promptMode,
      ),
    );
  }
}

class _MapQuizView extends StatefulWidget {
  const _MapQuizView({
    required this.interactionType,
    required this.title,
    required this.promptMode,
  });

  final MapInteractionType interactionType;
  final String title;
  final MapPromptMode promptMode;

  @override
  State<_MapQuizView> createState() => _MapQuizViewState();
}

class _MapQuizViewState extends State<_MapQuizView> {
  final _hitNotifier = ValueNotifier<LayerHitResult<String>?>(null);
  final _mapController = MapController();

  @override
  void dispose() {
    _hitNotifier.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final hitValues = _hitNotifier.value?.hitValues;
    if (hitValues == null || hitValues.isEmpty) return;
    context.read<MapQuizCubit>().onRegionTapped(hitValues.first);
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
                if (state is MapQuizFinished) {
                  context.read<StreakCubit>().registerActivityCompletion();
                  context.read<XpCubit>().awardActivityCompletion();
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
                  :final regions,
                  :final backgroundRegions,
                  :final remainingIds,
                  :final currentTargetId,
                  :final correctCount,
                  :final totalCount,
                  :final lastTap,
                  :final revealed,
                ) =>
                  _PlayingView(
                    strings: t,
                    interactionType: widget.interactionType,
                    promptMode: widget.promptMode,
                    regions: regions,
                    backgroundRegions: backgroundRegions,
                    solvedIds: regions
                        .map((region) => region.id)
                        .toSet()
                        .difference(remainingIds.toSet()),
                    currentTargetId: currentTargetId,
                    correctCount: correctCount,
                    totalCount: totalCount,
                    lastTap: lastTap,
                    revealed: revealed,
                    hitNotifier: _hitNotifier,
                    mapController: _mapController,
                    onTap: _handleTap,
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
    required this.interactionType,
    required this.promptMode,
    required this.regions,
    required this.backgroundRegions,
    required this.solvedIds,
    required this.currentTargetId,
    required this.correctCount,
    required this.totalCount,
    required this.lastTap,
    required this.revealed,
    required this.hitNotifier,
    required this.mapController,
    required this.onTap,
  });

  final MapQuizStrings strings;
  final MapInteractionType interactionType;
  final MapPromptMode promptMode;
  final List<MapRegion> regions;
  final List<MapRegion> backgroundRegions;
  final Set<String> solvedIds;
  final String currentTargetId;
  final int correctCount;
  final int totalCount;
  final TapFeedback? lastTap;
  // True once the miss limit is hit for the current target -- the target's
  // own region is highlighted as the answer instead of accepting taps.
  final bool revealed;
  final LayerHitNotifier<String> hitNotifier;
  final MapController mapController;
  final VoidCallback onTap;

  Color _regionColor(BuildContext context, String regionId) {
    final colors = context.colors;
    if (revealed && regionId == currentTargetId) {
      return colors.success.withValues(alpha: 0.85);
    }
    if (lastTap?.regionId == regionId) {
      return lastTap!.wasCorrect
          ? colors.success.withValues(alpha: 0.7)
          : colors.error.withValues(alpha: 0.7);
    }
    if (solvedIds.contains(regionId)) {
      return colors.success.withValues(
        alpha: interactionType == MapInteractionType.polygon ? 0.35 : 0.9,
      );
    }
    return switch (interactionType) {
      MapInteractionType.polygon => colors.secondary,
      MapInteractionType.line => colors.textSecondary,
      MapInteractionType.point => colors.primary,
    };
  }

  Widget? _buildBackgroundLayer(BuildContext context) {
    if (backgroundRegions.isEmpty) return null;
    return IgnorePointer(
      child: PolygonLayer<String>(
        polygons: [
          for (final region in backgroundRegions)
            for (final part in region.parts)
              Polygon<String>(
                points: part,
                color: context.colors.secondary.withValues(alpha: 0.5),
                borderColor: context.colors.border,
                borderStrokeWidth: 0.8,
              ),
        ],
      ),
    );
  }

  Widget _buildInteractionLayer(BuildContext context) =>
      switch (interactionType) {
        MapInteractionType.polygon => PolygonLayer<String>(
          hitNotifier: hitNotifier,
          polygons: [
            for (final region in regions)
              for (final part in region.parts)
                Polygon<String>(
                  points: part,
                  hitValue: region.id,
                  color: _regionColor(context, region.id),
                  borderColor: context.colors.border,
                  borderStrokeWidth: 1.2,
                ),
          ],
        ),
        MapInteractionType.line => PolylineLayer<String>(
          hitNotifier: hitNotifier,
          minimumHitbox: 20,
          polylines: [
            for (final region in regions)
              for (final part in region.parts)
                Polyline<String>(
                  points: part,
                  hitValue: region.id,
                  color: _regionColor(context, region.id),
                  strokeWidth: 3.5,
                ),
          ],
        ),
        MapInteractionType.point => CircleLayer<String>(
          hitNotifier: hitNotifier,
          circles: [
            for (final region in regions)
              for (final part in region.parts)
                for (final point in part)
                  CircleMarker<String>(
                    point: point,
                    radius: 12,
                    hitValue: region.id,
                    color: _regionColor(context, region.id),
                    borderColor: context.colors.background,
                    borderStrokeWidth: 2,
                  ),
          ],
        ),
      };

  @override
  Widget build(BuildContext context) {
    final currentTarget = regions.firstWhere(
      (region) => region.id == currentTargetId,
    );
    final allPoints = regions.expand(
      (region) => region.parts.expand((part) => part),
    );
    final bounds = LatLngBounds.fromPoints(allPoints.toList());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: promptMode == MapPromptMode.flag
                          ? Text(
                              flagEmojiForCountryId(currentTarget.id) ?? '🏳️',
                              style: const TextStyle(fontSize: 26),
                            )
                          : Icon(
                              Icons.gps_fixed_rounded,
                              color: context.colors.primary,
                              size: 26,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            revealed
                                ? strings.revealedLabel
                                : promptMode == MapPromptMode.flag
                                ? strings.identifyFlagLabel
                                : strings.locateLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: revealed
                                  ? context.colors.success
                                  : context.colors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(0, 0.2),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOut,
                                          ),
                                        ),
                                    child: child,
                                  ),
                                ),
                            child: Text(
                              promptMode == MapPromptMode.flag
                                  ? strings.flagPrompt
                                  : currentTarget.name,
                              key: ValueKey(currentTarget.id),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        strings.progressLabel(correctCount, totalCount),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: totalCount == 0 ? 0.0 : correctCount / totalCount,
                    minHeight: 8,
                    backgroundColor: context.colors.secondary,
                    valueColor: AlwaysStoppedAnimation(context.colors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(24),
                  ),
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  ?_buildBackgroundLayer(context),
                  GestureDetector(
                    onTap: onTap,
                    child: _buildInteractionLayer(context),
                  ),
                ],
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: _ZoomControls(mapController: mapController),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.mapController});

  final MapController mapController;

  void _zoomBy(double delta) {
    final camera = mapController.camera;
    mapController.move(camera.center, camera.zoom + delta);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add, color: context.colors.textPrimary),
            onPressed: () => _zoomBy(1),
          ),
          Divider(height: 1, color: context.colors.border),
          IconButton(
            icon: Icon(Icons.remove, color: context.colors.textPrimary),
            onPressed: () => _zoomBy(-1),
          ),
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

  final MapQuizStrings strings;
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

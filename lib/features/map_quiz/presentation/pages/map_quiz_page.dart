import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';
import 'package:aura/features/map_quiz/l10n/map_quiz_strings.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_cubit.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_state.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class MapQuizPage extends StatelessWidget {
  const MapQuizPage({
    required this.mapId,
    required this.interactionType,
    required this.title,
    super.key,
  });

  final String mapId;
  final MapInteractionType interactionType;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapQuizCubit(sl<MapQuizRepository>(), mapId: mapId),
      child: _MapQuizView(interactionType: interactionType, title: title),
    );
  }
}

class _MapQuizView extends StatefulWidget {
  const _MapQuizView({required this.interactionType, required this.title});

  final MapInteractionType interactionType;
  final String title;

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
                if (state is MapQuizPlaying && state.lastTap != null) {
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
                MapQuizFinished(:final correctCount, :final totalCount) =>
                  _FinishedView(
                    strings: t,
                    correctCount: correctCount,
                    totalCount: totalCount,
                  ),
                MapQuizPlaying(
                  :final regions,
                  :final remainingIds,
                  :final currentTargetId,
                  :final correctCount,
                  :final totalCount,
                  :final lastTap,
                ) =>
                  _PlayingView(
                    strings: t,
                    interactionType: widget.interactionType,
                    regions: regions,
                    solvedIds: regions
                        .map((region) => region.id)
                        .toSet()
                        .difference(remainingIds.toSet()),
                    currentTargetId: currentTargetId,
                    correctCount: correctCount,
                    totalCount: totalCount,
                    lastTap: lastTap,
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
    required this.regions,
    required this.solvedIds,
    required this.currentTargetId,
    required this.correctCount,
    required this.totalCount,
    required this.lastTap,
    required this.hitNotifier,
    required this.mapController,
    required this.onTap,
  });

  final MapQuizStrings strings;
  final MapInteractionType interactionType;
  final List<MapRegion> regions;
  final Set<String> solvedIds;
  final String currentTargetId;
  final int correctCount;
  final int totalCount;
  final TapFeedback? lastTap;
  final LayerHitNotifier<String> hitNotifier;
  final MapController mapController;
  final VoidCallback onTap;

  Color _regionColor(BuildContext context, String regionId) {
    final colors = context.colors;
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.findPrompt(currentTarget.name),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                strings.progressLabel(correctCount, totalCount),
                style: TextStyle(color: context.colors.textSecondary),
              ),
            ],
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(24),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              GestureDetector(
                onTap: onTap,
                child: _buildInteractionLayer(context),
              ),
            ],
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

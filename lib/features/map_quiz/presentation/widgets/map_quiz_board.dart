import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';
import 'package:aura/features/map_quiz/l10n/map_quiz_strings.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_state.dart';
import 'package:aura/features/map_quiz/presentation/viewport/board_camera_constraint.dart';
import 'package:aura/features/map_quiz/presentation/viewport/board_crs.dart';
import 'package:aura/features/map_quiz/presentation/viewport/map_hit_tester.dart';
import 'package:aura/features/map_quiz/presentation/viewport/map_viewport_policy.dart';

/// The quiz map as a board: framed on every answer, with the camera rules
/// of its [MapViewport] (locked, constrained or world).
///
/// The camera belongs to the user once the board is shown: it's not reset
/// between questions, and right/wrong feedback only recolors -- it never
/// moves the camera toward the answer. "Ver tudo" appears after the user
/// zooms or pans and brings back exactly the initial frame.
class MapQuizBoard extends StatefulWidget {
  const MapQuizBoard({
    required this.board,
    required this.strings,
    required this.solvedIds,
    required this.currentTargetId,
    required this.lastTap,
    required this.revealed,
    required this.onRegionTapped,
    super.key,
  });

  final MapBoard board;
  final MapQuizStrings strings;
  final Set<String> solvedIds;
  final String currentTargetId;
  final TapFeedback? lastTap;
  final bool revealed;
  final ValueChanged<String> onRegionTapped;

  @override
  State<MapQuizBoard> createState() => _MapQuizBoardState();
}

class _MapQuizBoardState extends State<MapQuizBoard>
    with SingleTickerProviderStateMixin {
  final _controller = MapController();
  late final AnimationController _reset = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..addListener(_onResetTick);
  late final Animation<double> _resetCurve = CurvedAnimation(
    parent: _reset,
    curve: Curves.easeOutCubic,
  );
  LatLng? _resetFrom;
  double _resetFromZoom = 0;

  Size? _size;
  MapViewport? _viewport;
  bool _moved = false;

  // The geography itself never changes while playing: built once per board
  // and theme and reused on every rebuild, so a tap doesn't re-project the
  // world map's 37k vertices. Only the few colored answers are rebuilt.
  Object? _staticKey;
  List<Polygon> _staticPolygons = const [];
  List<Polyline> _staticLines = const [];
  List<Polygon> _backgroundPolygons = const [];

  @override
  void didUpdateWidget(MapQuizBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.board, widget.board)) {
      _size = null;
      _moved = false;
    }
  }

  @override
  void dispose() {
    _reset.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// The zoom buttons' corner, margin included.
  static const _zoomButtonsFootprint = Size(60, 108);

  /// Zoom buttons only where pinching isn't the obvious way in: on world
  /// boards, and on the web (mouse users). Decided from the board alone --
  /// before the viewport exists -- so the frame can keep their corner free.
  static bool _hasZoomButtons(MapBoard board) =>
      board.spec.scope == MapScope.world ||
      board.spec.mode == MapViewportMode.world ||
      kIsWeb;

  MapViewport _viewportFor(Size size) {
    final previous = _size;
    if (previous != size || _viewport == null) {
      _size = size;
      _viewport = MapViewportPolicy.resolve(
        widget.board,
        size,
        controls: _hasZoomButtons(widget.board)
            ? _zoomButtonsFootprint
            : Size.zero,
      );
      _moved = false;
      if (previous != null) {
        // Rotation or a resized browser window: re-frame on the new size.
        final vp = _viewport!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _controller.move(vp.center, vp.fitZoom);
        });
      }
    }
    return _viewport!;
  }

  void _buildStaticLayers(BuildContext context) {
    final colors = context.colors;
    final key = (widget.board, Theme.of(context).brightness);
    if (key == _staticKey) return;
    _staticKey = key;
    final board = widget.board;
    final byId = {for (final r in board.regions) r.id: r};
    _backgroundPolygons = [
      for (final region in board.background)
        for (var i = 0; i < region.parts.length; i++)
          Polygon(
            points: region.parts[i],
            holePointsList: region.holesOf(i),
            color: colors.secondary.withValues(alpha: 0.5),
            borderColor: colors.border,
            borderStrokeWidth: 0.6,
          ),
    ];
    _staticPolygons = board.interactionType == MapInteractionType.polygon
        ? [
            for (final id in board.paintOrder)
              for (var i = 0; i < byId[id]!.parts.length; i++)
                Polygon(
                  points: byId[id]!.parts[i],
                  holePointsList: byId[id]!.holesOf(i),
                  color: colors.secondary,
                  borderColor: colors.border,
                  borderStrokeWidth: 1,
                ),
          ]
        : const [];
    _staticLines = board.interactionType == MapInteractionType.line
        ? [
            for (final region in board.regions)
              for (final part in region.parts)
                Polyline(
                  points: part,
                  color: colors.textSecondary,
                  strokeWidth: 3,
                ),
          ]
        : const [];
  }

  /// Color of an answer that needs one right now, or null for the neutral
  /// base color.
  Color? _highlight(BuildContext context, String id) {
    final colors = context.colors;
    final type = widget.board.interactionType;
    if (widget.revealed && id == widget.currentTargetId) {
      return colors.warning.withValues(alpha: 0.85);
    }
    final tap = widget.lastTap;
    if (tap != null && tap.regionId == id) {
      return (tap.wasCorrect ? colors.success : colors.error).withValues(
        alpha: 0.75,
      );
    }
    if (widget.solvedIds.contains(id)) {
      return colors.success.withValues(
        alpha: type == MapInteractionType.polygon ? 0.4 : 0.9,
      );
    }
    return null;
  }

  void _handleTap(TapPosition position, LatLng latLng) {
    final relative = position.relative;
    final viewport = _viewport;
    if (relative == null || viewport == null) return;
    final camera = _controller.camera;
    final hit = hitTestBoard(
      board: widget.board,
      viewport: viewport,
      tap: latLng,
      tapOnScreen: relative,
      toScreen: camera.latLngToScreenOffset,
    );
    if (hit != null) widget.onRegionTapped(hit);
  }

  void _showAll() {
    final viewport = _viewport;
    if (viewport == null) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.move(viewport.center, viewport.fitZoom);
    } else {
      _resetFrom = _controller.camera.center;
      _resetFromZoom = _controller.camera.zoom;
      _reset.forward(from: 0);
    }
    setState(() => _moved = false);
  }

  void _onResetTick() {
    final from = _resetFrom, viewport = _viewport;
    if (from == null || viewport == null) return;
    final t = _resetCurve.value;
    _controller.move(
      LatLng(
        ui.lerpDouble(from.latitude, viewport.center.latitude, t)!,
        ui.lerpDouble(from.longitude, viewport.center.longitude, t)!,
      ),
      ui.lerpDouble(_resetFromZoom, viewport.fitZoom, t)!,
    );
  }

  void _zoomBy(double delta) {
    final viewport = _viewport;
    if (viewport == null) return;
    final camera = _controller.camera;
    _controller.move(
      camera.center,
      (camera.zoom + delta).clamp(viewport.minZoom, viewport.maxZoom),
    );
    if (!_moved) setState(() => _moved = true);
  }

  @override
  Widget build(BuildContext context) {
    _buildStaticLayers(context);
    final colors = context.colors;
    final board = widget.board;
    final type = board.interactionType;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = _viewportFor(constraints.biggest);
        final highlighted = [
          for (final id in board.paintOrder)
            if (_highlight(context, id) case final color?) (id, color),
        ];
        final byId = {for (final r in board.regions) r.id: r};
        final showZoomButtons =
            _hasZoomButtons(board) && viewport.isInteractive;

        return Stack(
          children: [
            FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: viewport.center,
                initialZoom: viewport.fitZoom,
                minZoom: viewport.minZoom,
                maxZoom: viewport.maxZoom,
                crs: const BoardCrs(),
                cameraConstraint: BoardCameraConstraint(
                  bounds: board.bounds,
                  padding: viewport.padding,
                  reservedRight: viewport.reservedRight,
                ),
                backgroundColor: colors.background,
                interactionOptions: InteractionOptions(
                  // No double-tap zoom anywhere: with it on, flutter_map
                  // holds every tap for 250 ms waiting for a second one,
                  // and answering would feel laggy. No rotation either.
                  flags: viewport.isInteractive
                      ? InteractiveFlag.drag |
                            InteractiveFlag.flingAnimation |
                            InteractiveFlag.pinchMove |
                            InteractiveFlag.pinchZoom |
                            InteractiveFlag.scrollWheelZoom
                      : InteractiveFlag.none,
                ),
                onTap: _handleTap,
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture && !_moved) setState(() => _moved = true);
                },
              ),
              children: [
                if (_backgroundPolygons.isNotEmpty)
                  PolygonLayer(polygons: _backgroundPolygons),
                if (_staticPolygons.isNotEmpty)
                  PolygonLayer(polygons: _staticPolygons),
                if (_staticLines.isNotEmpty)
                  PolylineLayer(polylines: _staticLines),
                if (type == MapInteractionType.polygon &&
                    highlighted.isNotEmpty)
                  PolygonLayer(
                    polygons: [
                      for (final (id, color) in highlighted)
                        for (var i = 0; i < byId[id]!.parts.length; i++)
                          Polygon(
                            points: byId[id]!.parts[i],
                            holePointsList: byId[id]!.holesOf(i),
                            color: color,
                            borderColor: colors.border,
                            borderStrokeWidth: 1,
                          ),
                    ],
                  ),
                if (type == MapInteractionType.line && highlighted.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      for (final (id, color) in highlighted)
                        for (final part in byId[id]!.parts)
                          Polyline(points: part, color: color, strokeWidth: 4),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    for (final id in [
                      if (type == MapInteractionType.point)
                        for (final r in board.regions) r.id
                      else
                        ...viewport.proxyIds,
                    ])
                      _marker(
                        context,
                        id,
                        viewport,
                        isProxy: type != MapInteractionType.point,
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showZoomButtons)
                    _ZoomButtons(
                      strings: widget.strings,
                      onZoomIn: () => _zoomBy(1),
                      onZoomOut: () => _zoomBy(-1),
                    ),
                  if (showZoomButtons && _moved) const SizedBox(height: 8),
                  if (_moved && viewport.isInteractive)
                    _ShowAllButton(
                      label: widget.strings.showAllButton,
                      onPressed: _showAll,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Marker _marker(
    BuildContext context,
    String id,
    MapViewport viewport, {
    required bool isProxy,
  }) {
    final colors = context.colors;
    final displacement = viewport.displacements[id] ?? Offset.zero;
    final radius = isProxy
        ? MapMarkerSizes.proxyVisualRadius
        : viewport.markerRadius;
    final side = (displacement.distance + radius + 4) * 2;
    final fill =
        _highlight(context, id) ??
        (isProxy ? colors.textSecondary : colors.primary);
    // No key: flutter_map repeats markers across the world copies past
    // ±180° (never on screen, thanks to the camera constraint), and a key
    // would be duplicated among them.
    return Marker(
      point: widget.board.metrics[id]!.anchor,
      width: side,
      height: side,
      child: IgnorePointer(
        child: CustomPaint(
          painter: _MarkerPainter(
            radius: radius,
            fill: fill,
            ring: colors.background,
            leader: colors.textSecondary,
            displacement: displacement,
          ),
        ),
      ),
    );
  }
}

/// A small dot, optionally nudged off its real spot with a leader line
/// and a pin-point dot marking where the place actually is.
class _MarkerPainter extends CustomPainter {
  const _MarkerPainter({
    required this.radius,
    required this.fill,
    required this.ring,
    required this.leader,
    required this.displacement,
  });

  final double radius;
  final Color fill;
  final Color ring;
  final Color leader;
  final Offset displacement;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final dot = center + displacement;
    if (displacement != Offset.zero) {
      final line = Paint()
        ..color = leader
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(center, dot, line);
      canvas.drawCircle(center, 1.8, Paint()..color = leader);
    }
    canvas.drawCircle(dot, radius + 1.5, Paint()..color = ring);
    canvas.drawCircle(dot, radius, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_MarkerPainter old) =>
      old.radius != radius ||
      old.fill != fill ||
      old.ring != ring ||
      old.leader != leader ||
      old.displacement != displacement;
}

class _ShowAllButton extends StatelessWidget {
  const _ShowAllButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fit_screen_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons({
    required this.strings,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final MapQuizStrings strings;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: strings.zoomInTooltip,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.add, color: colors.textPrimary),
            onPressed: onZoomIn,
          ),
          Divider(height: 1, color: colors.border),
          IconButton(
            tooltip: strings.zoomOutTooltip,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.remove, color: colors.textPrimary),
            onPressed: onZoomOut,
          ),
        ],
      ),
    );
  }
}

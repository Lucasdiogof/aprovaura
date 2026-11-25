import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Geometry of the "farm Aura" rig, in the art space of its four layers
/// (822 × 800 px, the same canvas for all of them).
///
/// Ported from the promo film's rig (`aprovaura-promo-v8.html`: `farmPose`,
/// `farmArmPose`, `farmApply`, `farmPalm`) with the same constants, so the
/// motion is the one the film shows: both forearms come toward the camera,
/// palms up, and rise and fall in counter-phase while the body leans a hair
/// towards the raised hand.
abstract final class FarmHandsGeometry {
  static const artWidth = 822.0;
  static const artHeight = 800.0;
  static const aspect = artWidth / artHeight;

  /// One stage pixel of the promo (rig drawn 196 px wide) in art units.
  static const stageToArt = artWidth / 196;

  /// Hand pivot, shoulder pivot and sleeve end of the right arm (the left
  /// one is the same art mirrored).
  static const handOrigin = Offset(653.5, 428);
  static const shoulder = Offset(541, 447);
  static const sleeveEnd = Offset(587, 548);

  /// Foreshortening of the upturned hand.
  static const handSquash = .64;

  static const _low = (th: 4.0, f: .97, lift: 4.0, ha: 176.0, hs: 1.06);
  static const _high = (th: 7.0, f: .9, lift: 50.0, ha: 172.0, hs: 1.1);

  static final sleeveAxis = math.atan2(
    sleeveEnd.dy - shoulder.dy,
    sleeveEnd.dx - shoulder.dx,
  );

  /// The orbit Aurudo carries around him (art coordinates).
  static const ringCenter = Offset(386, 260);
  static const ringRx = 362.0;
  static const ringRy = 80.0;
  static const ringRot = -11 * math.pi / 180;

  static const folder = 'lib/assets/mascot/farm_hands/';
  static const body = '${folder}aurudo_farm_hands_body.webp';
  static const sleeve = '${folder}aurudo_farm_hands_sleeve.webp';
  static const hand = '${folder}aurudo_farm_hands_hand.webp';
  static const cuff = '${folder}aurudo_farm_hands_cuff.webp';

  /// Paint order, back to front.
  static const all = [body, sleeve, hand, cuff];

  /// Pose of one arm at raise [r] (0 = palm low, 1 = palm high).
  static FarmArmPose armPose(double r) {
    double l(double a, double b) => a + (b - a) * r;
    final th = l(_low.th, _high.th);
    final f = l(_low.f, _high.f);
    final lift = l(_low.lift, _high.lift);
    final vx = (sleeveEnd.dx - shoulder.dx) * f;
    final vy = (sleeveEnd.dy - shoulder.dy) * f;
    final a = th * math.pi / 180;
    final end = Offset(
      shoulder.dx + math.cos(a) * vx - math.sin(a) * vy,
      shoulder.dy + math.sin(a) * vx + math.cos(a) * vy,
    );
    return FarmArmPose(
      sleeveTurn: th,
      sleeveScale: f,
      wrist: Offset(end.dx - 4 * r, end.dy - 10 - lift),
      handTurn: l(_low.ha, _high.ha),
      handScale: l(_low.hs, _high.hs),
    );
  }

  /// Centre of the open palm of the right arm (the left is mirrored by
  /// [mirrorX]) at the top of a raise.
  static Offset palm({required bool right}) {
    final p = armPose(1);
    final th = p.handTurn * math.pi / 180;
    final ox = 31.5 * p.handScale;
    final oy = -53 * p.handScale * handSquash;
    var x = p.wrist.dx + math.cos(th) * ox - math.sin(th) * oy;
    final y = p.wrist.dy + math.sin(th) * ox + math.cos(th) * oy;
    if (!right) x = mirrorX(x);
    return Offset(x, y);
  }

  /// The left arm is the right one drawn mirrored about this axis.
  static double mirrorX(double x) => 824 - x;

  /// A point of the orbit at angle [th].
  static Offset ringPoint(double th) {
    final x = math.cos(th) * ringRx;
    final y = math.sin(th) * ringRy;
    return Offset(
      ringCenter.dx + x * math.cos(ringRot) - y * math.sin(ringRot),
      ringCenter.dy + x * math.sin(ringRot) + y * math.cos(ringRot),
    );
  }
}

@immutable
class FarmArmPose {
  const FarmArmPose({
    required this.sleeveTurn,
    required this.sleeveScale,
    required this.wrist,
    required this.handTurn,
    required this.handScale,
  });

  /// Degrees.
  final double sleeveTurn;
  final double sleeveScale;
  final Offset wrist;

  /// Degrees.
  final double handTurn;
  final double handScale;
}

/// One orb of Aura born in a palm.
@immutable
class FarmOrb {
  const FarmOrb({required this.right, required this.startsAt});

  final bool right;

  /// Seconds on the arm clock.
  final double startsAt;
}

/// The farm-Aura timeline, in seconds, as in the film: each arm is a
/// smooth cosine swing of [period] seconds, the right one half a period
/// behind the left, every raise leaves an orb that is pulled into the orbit.
///
/// Two clocks: the *scene* clock starts at 0 when the mascot appears, the
/// *arm* clock is the scene clock minus [lead].
abstract final class FarmHandsTimeline {
  static const period = .9;
  static const rightOffset = .45;

  /// Scene time before the left arm starts (the entrance).
  static const lead = .15;
  static const entrance = .4;
  static const orbLife = 1.25;

  /// Where in a raise the orb is born (just before the palm tops out).
  static const orbBirth = .44 * period;

  /// Raises per arm in the one-shot (reaction) version.
  static const onceRaises = 2;

  /// Arm clock at which the one-shot has finished charging and fades out.
  static const onceFadeStart = 2.9;
  static const onceFadeEnd = 3.3;

  /// Scene length of the one-shot.
  static const onceTotal = lead + onceFadeEnd;

  static double progress(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  static double easeOut(double x) => 1 - math.pow(1 - x, 3).toDouble();

  static double easeInOut(double x) =>
      x < .5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2;

  /// 0 palm low .. 1 palm high, on the arm clock.
  static double raise(double t, {required bool right, required bool loop}) {
    final tt = t - (right ? rightOffset : 0);
    if (tt < 0) return 0;
    if (!loop && tt >= onceRaises * period) return 0;
    return (1 - math.cos(2 * math.pi * tt / period)) / 2;
  }

  static double _orbStart(bool right, int cycle) =>
      (right ? rightOffset : 0) + cycle * period + orbBirth;

  /// Every orb of the one-shot, in order of birth.
  static List<FarmOrb> get onceOrbs => [
    for (var c = 0; c < onceRaises; c++)
      for (final right in const [false, true])
        FarmOrb(right: right, startsAt: _orbStart(right, c)),
  ];

  /// Orbs alive at arm time [t].
  static List<FarmOrb> orbsAt(double t, {required bool loop}) {
    final out = <FarmOrb>[];
    if (loop) {
      for (final right in const [false, true]) {
        final first = math.max(
          0,
          ((t - _orbStart(right, 0) - orbLife) / period).floor() + 1,
        );
        final last = ((t - _orbStart(right, 0)) / period).floor();
        for (var c = first; c <= last; c++) {
          out.add(FarmOrb(right: right, startsAt: _orbStart(right, c)));
        }
      }
    } else {
      for (final o in onceOrbs) {
        if (t >= o.startsAt && t < o.startsAt + orbLife) out.add(o);
      }
    }
    return out;
  }

  /// How charged Aurudo's orbit is, 0..1: it brightens as each orb lands.
  static double charge(double t, {required bool loop}) {
    double landed(FarmOrb o) =>
        easeOut(progress(t, o.startsAt + .7, o.startsAt + 1.0));
    if (loop) {
      var pulse = 0.0;
      for (final o in orbsAt(t, loop: true)) {
        pulse = math.max(
          pulse,
          landed(o) * (1 - progress(t, o.startsAt + 1.0, o.startsAt + 1.45)),
        );
      }
      return math.max(.45 * easeOut(progress(t, .5, 1.5)), pulse);
    }
    final orbs = onceOrbs;
    var q = 0.0;
    for (final o in orbs) {
      q += landed(o) / orbs.length;
    }
    return q * (1 - progress(t, onceFadeStart, onceFadeEnd));
  }
}

/// Aurudo farming Aura with both hands: the film's gesture, redrawn from
/// the character's own cut-out layers (body, sleeve, hand, cuff) by one
/// painter on one clock. No video, no new art.
///
/// [loop] repeats the see-saw while the widget is mounted and visible (the
/// last onboarding slide); otherwise it plays once for about 3.5 s and
/// settles in the resting pose (the `perfectFarmAura` reaction). [instant]
/// (or the platform's reduced motion) shows that resting pose straight
/// away: no entrance, no orbs, no ticker. If a layer fails to load, the
/// still `farming_aura` illustration stands in.
class AurudoFarmHandsAnimation extends StatefulWidget {
  const AurudoFarmHandsAnimation({
    required this.size,
    this.loop = false,
    this.instant = false,
    @visibleForTesting this.assets = FarmHandsGeometry.all,
    super.key,
  });

  /// Height; the width follows the art's aspect.
  final double size;
  final bool loop;
  final bool instant;

  /// Body, sleeve, hand and cuff layers, in that order.
  final List<String> assets;

  @override
  State<AurudoFarmHandsAnimation> createState() =>
      _AurudoFarmHandsAnimationState();
}

class _AurudoFarmHandsAnimationState extends State<AurudoFarmHandsAnimation>
    with SingleTickerProviderStateMixin {
  /// Scene clock in seconds.
  final _clock = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker(_onTick);
  final List<ui.Image?> _layers = [null, null, null, null];
  final List<(ImageStream, ImageStreamListener)> _streams = [];
  Object? _loadedFor;
  bool _failed = false;
  bool _started = false;

  bool get _still => widget.instant || MediaQuery.disableAnimationsOf(context);

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (!widget.loop && t >= FarmHandsTimeline.onceTotal) {
      _clock.value = FarmHandsTimeline.onceTotal;
      _ticker.stop();
      return;
    }
    _clock.value = t;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
    final decodeWidth = (widget.size * FarmHandsGeometry.aspect * dpr)
        .round()
        .clamp(64, FarmHandsGeometry.artWidth.round());
    final key = (widget.assets.join('|'), decodeWidth);
    if (_loadedFor != key) {
      _loadedFor = key;
      _loadLayers(decodeWidth);
    }
    _sync();
  }

  /// Still: park on the resting pose. Otherwise start the clock once every
  /// layer is decoded, so the entrance is never eaten by the loading.
  void _sync() {
    if (_still) {
      _ticker.stop();
      _clock.value = FarmHandsTimeline.onceTotal;
    } else if (!_started && _layers.every((l) => l != null)) {
      _started = true;
      _clock.value = 0;
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(AurudoFarmHandsAnimation old) {
    super.didUpdateWidget(old);
    if (old.size != widget.size || old.assets != widget.assets) {
      _loadedFor = null;
      didChangeDependencies();
    }
  }

  void _loadLayers(int decodeWidth) {
    _unload();
    final config = createLocalImageConfiguration(context);
    for (var i = 0; i < widget.assets.length; i++) {
      final stream = ResizeImage(
        AssetImage(widget.assets[i]),
        width: decodeWidth,
      ).resolve(config);
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          if (!mounted) return;
          setState(() {
            _layers[i]?.dispose();
            _layers[i] = info.image.clone();
          });
          _sync();
        },
        onError: (_, _) {
          if (mounted && !_failed) setState(() => _failed = true);
        },
      );
      stream.addListener(listener);
      _streams.add((stream, listener));
    }
  }

  void _unload() {
    for (final (stream, listener) in _streams) {
      stream.removeListener(listener);
    }
    _streams.clear();
  }

  @override
  void dispose() {
    _unload();
    _ticker.dispose();
    _clock.dispose();
    for (final image in _layers) {
      image?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return AurudoIllustration(
        pose: AurudoPose.farmingAura,
        size: widget.size,
        animate: false,
      );
    }
    final box = Size(widget.size * FarmHandsGeometry.aspect, widget.size);
    if (_layers.any((l) => l == null)) return SizedBox.fromSize(size: box);
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: box,
          willChange: true,
          painter: _FarmHandsPainter(
            clock: _clock,
            layers: List.of(_layers.cast<ui.Image>()),
            loop: widget.loop,
            still: _still,
            dark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class _FarmHandsPainter extends CustomPainter {
  _FarmHandsPainter({
    required this.clock,
    required this.layers,
    required this.loop,
    required this.still,
    required this.dark,
  }) : super(repaint: clock);

  final ValueListenable<double> clock;
  final List<ui.Image> layers;
  final bool loop;
  final bool still;
  final bool dark;

  static const _px = FarmHandsGeometry.stageToArt;
  static const _artRect = Rect.fromLTWH(
    0,
    0,
    FarmHandsGeometry.artWidth,
    FarmHandsGeometry.artHeight,
  );

  // Dark scenes add light on top (as the film does); on light ones the same
  // light would vanish, so the orbs are painted with deeper tones instead.
  Color get _cyan => dark ? const Color(0xFF67E8F9) : const Color(0xFF0891B2);
  Color get _violet => dark ? const Color(0xFFC4B5FD) : const Color(0xFF7C3AED);
  static const _core = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final e = still ? FarmHandsTimeline.onceTotal : clock.value; // scene time
    final t = e - FarmHandsTimeline.lead; // arm time
    final settled = still || (!loop && e >= FarmHandsTimeline.onceTotal);

    final rL = settled
        ? 0.0
        : FarmHandsTimeline.raise(t, right: false, loop: loop);
    final rR = settled
        ? 0.0
        : FarmHandsTimeline.raise(t, right: true, loop: loop);
    final ch = still ? .3 : FarmHandsTimeline.charge(t, loop: loop);
    final enter = still
        ? 1.0
        : FarmHandsTimeline.easeOut(
            FarmHandsTimeline.progress(e, 0, FarmHandsTimeline.entrance),
          );
    final opacity = still ? 1.0 : FarmHandsTimeline.progress(e, 0, .2);

    canvas.save();
    canvas.scale(
      size.width / FarmHandsGeometry.artWidth,
      size.height / FarmHandsGeometry.artHeight,
    );

    _glow(canvas, still ? 1 : FarmHandsTimeline.progress(e, .1, .45), ch);

    // Whole rig: entrance, tiny bob and lean towards the raised palm.
    const c = Offset(FarmHandsGeometry.artWidth / 2, 400);
    final lean = rR - rL;
    final scale = .9 + .1 * enter;
    final fade = opacity < 1;
    if (fade) {
      canvas.saveLayer(
        _artRect.inflate(120),
        Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
      );
    }
    canvas.save();
    canvas.translate(
      c.dx + .6 * lean * _px,
      c.dy + 30 * (1 - enter) * _px - 1.6 * math.max(rL, rR) * _px,
    );
    canvas.rotate(.9 * lean * math.pi / 180);
    canvas.scale(scale);
    canvas.translate(-c.dx, -c.dy);
    // Soft violet halo hugging the silhouette, stronger as it charges.
    final sigma = (5 + 11 * ch) / 2 * _px;
    canvas.saveLayer(
      _artRect.inflate(sigma * 3),
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: ui.TileMode.decal,
        )
        ..colorFilter = ColorFilter.mode(
          const Color(0xFFA855F7).withValues(alpha: .25 + .45 * ch),
          BlendMode.srcIn,
        ),
    );
    _rig(canvas, rL, rR, handShadow: false);
    canvas.restore();
    _rig(canvas, rL, rR, handShadow: true);
    canvas.restore();
    if (fade) canvas.restore();

    if (!settled) _aura(canvas, t, ch);
    canvas.restore();
  }

  void _image(Canvas canvas, int i) {
    final img = layers[i];
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      _artRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  void _rig(Canvas canvas, double rL, double rR, {required bool handShadow}) {
    _image(canvas, 0);
    for (final right in const [false, true]) {
      final p = FarmHandsGeometry.armPose(right ? rR : rL);
      canvas.save();
      if (!right) {
        canvas.translate(824, 0);
        canvas.scale(-1, 1);
      }
      const s = FarmHandsGeometry.shoulder;
      final sleeve = Matrix4.translationValues(s.dx, s.dy, 0)
        ..multiply(Matrix4.rotationZ(p.sleeveTurn * math.pi / 180))
        ..multiply(Matrix4.rotationZ(FarmHandsGeometry.sleeveAxis))
        ..multiply(Matrix4.diagonal3Values(p.sleeveScale, 1, 1))
        ..multiply(Matrix4.rotationZ(-FarmHandsGeometry.sleeveAxis))
        ..multiply(Matrix4.translationValues(-s.dx, -s.dy, 0));
      canvas.save();
      canvas.transform(sleeve.storage);
      _image(canvas, 1);
      canvas.restore();

      const o = FarmHandsGeometry.handOrigin;
      final hand = Matrix4.translationValues(p.wrist.dx, p.wrist.dy, 0)
        ..multiply(Matrix4.rotationZ(p.handTurn * math.pi / 180))
        ..multiply(
          Matrix4.diagonal3Values(
            p.handScale,
            p.handScale * FarmHandsGeometry.handSquash,
            1,
          ),
        )
        ..multiply(Matrix4.translationValues(-o.dx, -o.dy, 0));
      canvas.save();
      canvas.transform(hand.storage);
      if (handShadow) {
        // Cast up and back, as in the film: the palm reads as cupped.
        const sigma = 10.0;
        canvas.save();
        canvas.translate(0, -24);
        canvas.saveLayer(
          _artRect.inflate(sigma * 3),
          Paint()
            ..imageFilter = ui.ImageFilter.blur(
              sigmaX: sigma,
              sigmaY: sigma,
              tileMode: ui.TileMode.decal,
            )
            ..colorFilter = const ColorFilter.mode(
              Color(0x732E1065),
              BlendMode.srcIn,
            ),
        );
        _image(canvas, 2);
        _image(canvas, 3);
        canvas.restore();
        canvas.restore();
      }
      _image(canvas, 2);
      _image(canvas, 3);
      canvas.restore();
      canvas.restore();
    }
  }

  /// The ellipse of light behind Aurudo, centred on his orbit.
  void _glow(Canvas canvas, double appear, double ch) {
    if (appear <= 0) return;
    final centre = FarmHandsGeometry.ringCenter + const Offset(0, 4 * _px);
    const w = 300 * _px;
    const h = 150 * _px;
    const radius = w / 2 * 1.4142;
    final a = appear * (.18 + .55 * ch);
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.scale(.9 + .2 * ch);
    canvas.scale(1, h / w);
    canvas.drawCircle(
      Offset.zero,
      radius * .7,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          radius,
          [
            const Color(0xFFA855F7).withValues(alpha: .55 * a),
            const Color(0xFF22D3EE).withValues(alpha: .18 * a),
            const Color(0xFF7C3AED).withValues(alpha: 0),
          ],
          const [0, .45, .7],
        ),
    );
    canvas.restore();
  }

  Paint get _pen => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..blendMode = dark ? BlendMode.plus : BlendMode.srcOver;

  Paint get _fill =>
      Paint()..blendMode = dark ? BlendMode.plus : BlendMode.srcOver;

  /// Orbs born in the palms, their trails, and the orbit they charge.
  void _aura(Canvas canvas, double t, double ch) {
    final boost = dark ? 1.0 : 1.6;

    final ringOn = FarmHandsTimeline.progress(t, .2, .4);
    if (ch > .01 && ringOn > 0) {
      final path = Path();
      for (var i = 0; i <= 40; i++) {
        final p = FarmHandsGeometry.ringPoint(.15 + i / 40 * (math.pi - .3));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      for (final (lw, al) in const [(7.0, .10), (3.0, .32)]) {
        canvas.drawPath(
          path,
          _pen
            ..strokeWidth = lw * _px
            ..color = _violet.withValues(
              alpha: (al * ch * ringOn * boost).clamp(0.0, 1.0),
            ),
        );
      }
    }

    for (final o in FarmHandsTimeline.orbsAt(t, loop: loop)) {
      final b = FarmHandsTimeline.progress(t, o.startsAt, o.startsAt + .12);
      final travel = FarmHandsTimeline.progress(
        t,
        o.startsAt + .18,
        o.startsAt + 1.0,
      );
      final g =
          (travel <= 0 ? b : 1.0) *
          (1 -
              FarmHandsTimeline.progress(
                t,
                o.startsAt + .85,
                o.startsAt + 1.2,
              ));
      if (g <= 0) continue;
      final dir = o.right ? 1.0 : -1.0;
      final th0 = o.right ? -.2 : math.pi + .2;
      final palm =
          FarmHandsGeometry.palm(right: o.right) +
          const Offset(0, (-1.6 - 8) * _px);
      final entry = FarmHandsGeometry.ringPoint(th0);
      final ctrl = palm + Offset(dir * 14 * _px, -46 * _px);
      Offset path(double u) {
        if (u < .45) return _bezier(palm, ctrl, entry, u / .45);
        return FarmHandsGeometry.ringPoint(th0 + dir * ((u - .45) / .55) * .75);
      }

      final col = o.right ? _cyan : _violet;
      final Offset head;
      if (travel <= 0) {
        head =
            palm -
            Offset(
              0,
              5 *
                  _px *
                  FarmHandsTimeline.progress(t, o.startsAt, o.startsAt + .18),
            );
      } else {
        final uh = FarmHandsTimeline.easeInOut(travel);
        final ut = FarmHandsTimeline.easeInOut(
          FarmHandsTimeline.progress(
            t - .22,
            o.startsAt + .18,
            o.startsAt + 1.0,
          ),
        );
        head = path(uh);
        _comet(
          canvas,
          [for (var i = 0; i <= 14; i++) path(ut + (uh - ut) * i / 14)],
          col,
          2.8 * _px,
          g * math.min(boost, 1.2),
        );
      }
      // The orb: soft halo and a four-point spark.
      _halo(canvas, head, 12 * g * _px, col, .32 * g);
      final sp = (4.5 + 2 * math.sin(math.pi * b)) * math.max(g, .2) * _px;
      canvas.drawPath(
        _spark(head, sp),
        _fill..color = _core.withValues(alpha: g),
      );
    }
  }

  /// Flat added light on dark scenes (as in the film); on light ones a
  /// flat disc reads as a sticker, so it fades out radially instead.
  void _halo(Canvas canvas, Offset c, double r, Color col, double a) {
    if (r <= 0) return;
    if (dark) {
      canvas.drawCircle(c, r, _fill..color = col.withValues(alpha: a));
      return;
    }
    canvas.drawCircle(
      c,
      r * 1.3,
      Paint()
        ..shader = ui.Gradient.radial(c, r * 1.3, [
          col.withValues(alpha: (a * 2.4).clamp(0.0, 1.0)),
          col.withValues(alpha: 0),
        ]),
    );
  }

  void _comet(Canvas canvas, List<Offset> pts, Color col, double w, double g) {
    final n = pts.length;
    if (n < 2) return;
    for (var i = 1; i < n; i++) {
      final a = i / (n - 1);
      canvas.drawLine(
        pts[i - 1],
        pts[i],
        _pen
          ..strokeWidth = w * (.2 + .8 * a)
          ..color = col.withValues(alpha: (a * a * .85 * g).clamp(0.0, 1.0)),
      );
    }
    final h = pts.last;
    _halo(canvas, h, w * 3.4, col, .3 * g);
    canvas.drawCircle(
      h,
      w * .7,
      _fill..color = _core.withValues(alpha: (.95 * g).clamp(0.0, 1.0)),
    );
  }

  Path _spark(Offset c, double s) => Path()
    ..moveTo(c.dx, c.dy - s)
    ..quadraticBezierTo(c.dx, c.dy, c.dx + s, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s)
    ..quadraticBezierTo(c.dx, c.dy, c.dx - s, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s)
    ..close();

  static Offset _bezier(Offset p0, Offset p1, Offset p2, double u) {
    final v = 1 - u;
    return p0 * (v * v) + p1 * (2 * v * u) + p2 * (u * u);
  }

  @override
  bool shouldRepaint(_FarmHandsPainter old) =>
      old.layers.length != layers.length ||
      !listEquals(old.layers, layers) ||
      old.loop != loop ||
      old.still != still ||
      old.dark != dark;
}

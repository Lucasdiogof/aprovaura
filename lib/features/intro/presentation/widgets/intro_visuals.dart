import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_farm_hands_animation.dart';
import 'package:aura/features/intro/l10n/intro_strings.dart';
import 'package:aura/features/intro/presentation/widgets/intro_common.dart';
import 'package:aura/features/intro/presentation/widgets/intro_scene.dart';
import 'package:aura/shared/widgets/app_logo.dart';
import 'package:aura/shared/widgets/aura/aura_glyph.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

// ---------------------------------------------------------------------------
// 1. Welcome
// ---------------------------------------------------------------------------
class IntroWelcomeVisual extends StatelessWidget {
  const IntroWelcomeVisual({required this.active, super.key});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return IntroScene(
      active: active,
      duration: const Duration(milliseconds: 1400),
      builder: (context, t) => SizedBox.fromSize(
        size: kIntroBox,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const IntroGlow(size: 330),
            if (active)
              const Positioned.fill(
                child: AuraParticles(
                  style: AuraParticlesStyle.ambient,
                  count: 6,
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AurudoIllustration(
                  pose: AurudoPose.neutral,
                  size: 236,
                  animate: active,
                ),
                const SizedBox(height: 22),
                introPop(
                  introSeg(t, 0.3, 0.85),
                  const AppLogo.text(width: 176),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Practice
// ---------------------------------------------------------------------------
class IntroPracticeVisual extends StatelessWidget {
  const IntroPracticeVisual({
    required this.active,
    required this.strings,
    super.key,
  });

  final bool active;
  final IntroStrings strings;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = strings;
    final options = [t.sampleA, t.sampleB, t.sampleC];
    return IntroScene(
      active: active,
      duration: const Duration(milliseconds: 3000),
      builder: (context, p) {
        final pick = introSeg(p, 0.55, 0.72);
        return SizedBox.fromSize(
          size: kIntroBox,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const IntroGlow(size: 320, opacity: 0.2),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IntroCard(
                    width: 304,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        introPop(
                          introSeg(p, 0, 0.18),
                          Text(
                            t.sampleQuestion,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        for (var i = 0; i < 3; i++)
                          introPop(
                            introSeg(p, 0.14 + i * 0.09, 0.32 + i * 0.09),
                            _Option(
                              letter: 'ABC'[i],
                              label: options[i],
                              // 1 = correct, -1 = dimmed, 0 = neutral.
                              state: i == 0 ? pick : -pick,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  introChips(p, 0.7, [
                    (t.t2Subjects, Icons.menu_book_rounded),
                    (t.t2Paths, Icons.route_rounded),
                    (t.t2Difficulty, Icons.stairs_rounded),
                    (t.t2Mock, Icons.timer_outlined),
                  ]),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.letter,
    required this.label,
    required this.state,
  });

  final String letter;
  final String label;
  final double state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final good = state.clamp(0.0, 1.0);
    final dim = (-state).clamp(0.0, 1.0);
    return Opacity(
      opacity: 1 - 0.45 * dim,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color.lerp(c.surface, c.success.withValues(alpha: 0.12), good),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color.lerp(c.border, c.success, good)!,
            width: 1 + good * 0.6,
          ),
        ),
        child: Row(
          children: [
            Text(
              letter,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: c.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: c.textPrimary),
              ),
            ),
            Transform.scale(
              scale: good,
              child: Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: c.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Learn from mistakes
// ---------------------------------------------------------------------------
class IntroProgressVisual extends StatelessWidget {
  const IntroProgressVisual({
    required this.active,
    required this.strings,
    super.key,
  });

  final bool active;
  final IntroStrings strings;

  static const _bars = [0.42, 0.58, 0.5, 0.72, 0.66, 0.86, 0.95];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = strings;
    return IntroScene(
      active: active,
      duration: const Duration(milliseconds: 3200),
      builder: (context, p) {
        final ring = introSeg(p, 0.05, 0.55, curve: Curves.easeOutQuart);
        final goal = introSeg(p, 0.4, 0.8);
        return SizedBox.fromSize(
          size: kIntroBox,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const IntroGlow(size: 320, opacity: 0.18),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  introPop(
                    introSeg(p, 0, 0.15),
                    IntroCard(
                      width: 304,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 92,
                                child: CustomPaint(
                                  painter: _RingPainter(
                                    progress: 0.82 * ring,
                                    track: c.border,
                                    colors: [c.auraViolet, c.auraCyan],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${(82 * ring).round()}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 19,
                                            color: c.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          t.accuracy,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: c.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: SizedBox(
                                  height: 92,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      for (var i = 0; i < _bars.length; i++)
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2.5,
                                            ),
                                            child: _Bar(
                                              fraction:
                                                  _bars[i] *
                                                  introSeg(
                                                    p,
                                                    0.15 + i * 0.06,
                                                    0.5 + i * 0.06,
                                                  ),
                                              highlight: i == _bars.length - 1,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                t.goalDone,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: c.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(75 * goal).round()}%',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: c.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _GradientBar(value: 0.75 * goal, height: 8),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (var i = 0; i < 7; i++)
                                _StreakDay(
                                  pop: introSeg(
                                    p,
                                    0.5 + i * 0.05,
                                    0.62 + i * 0.05,
                                  ),
                                  lit: i < 6,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  introChips(p, 0.7, [
                    (t.t3Review, Icons.replay_rounded),
                    (t.t3Stats, Icons.insights_rounded),
                    (t.t3Goal, Icons.flag_rounded),
                    (t.t3Streak, Icons.local_fire_department_rounded),
                  ]),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One column of the weekly chart: a faint full-height track with the
/// gradient fill rising inside it; the latest day is brighter and glows.
class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.highlight});

  final double fraction;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: FractionallySizedBox(
        heightFactor: math.max(0.05, fraction),
        alignment: Alignment.bottomCenter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [c.auraViolet, c.auraCyan],
            ),
            boxShadow: highlight
                ? [
                    BoxShadow(
                      color: c.auraCyan.withValues(alpha: 0.45),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

/// A rounded progress bar filled with the app's violet-to-cyan gradient.
class _GradientBar extends StatelessWidget {
  const _GradientBar({required this.value, required this.height});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(height),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height),
            gradient: LinearGradient(colors: [c.auraViolet, c.auraCyan]),
          ),
        ),
      ),
    );
  }
}

class _StreakDay extends StatelessWidget {
  const _StreakDay({required this.lit, required this.pop});

  /// Whether this day is part of the streak; it lights up as [pop] arrives.
  final bool lit;
  final double pop;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = lit && pop > 0.5;
    return Transform.scale(
      scale: 0.8 + 0.2 * pop,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: on ? c.warning.withValues(alpha: 0.18) : c.surfaceElevated,
          border: Border.all(color: on ? c.warning : c.border),
        ),
        child: Icon(
          Icons.local_fire_department_rounded,
          size: 17,
          color: on ? c.warning : c.textHint,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.colors,
  });

  final double progress;
  final Color track;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(6);
    canvas.drawArc(
      r,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = track,
    );
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: colors,
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track;
}

// ---------------------------------------------------------------------------
// 4. Essays
// ---------------------------------------------------------------------------
class IntroEssayVisual extends StatelessWidget {
  const IntroEssayVisual({
    required this.active,
    required this.strings,
    super.key,
  });

  final bool active;
  final IntroStrings strings;

  /// Sample points per ENEM competency (each out of 200): an illustration of
  /// the breakdown, not a real result.
  static const _points = [160, 120, 180, 140, 160];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = strings;
    return IntroScene(
      active: active,
      duration: const Duration(milliseconds: 3400),
      builder: (context, p) {
        return SizedBox.fromSize(
          size: kIntroBox,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const IntroGlow(size: 320, opacity: 0.2),
              introPop(
                introSeg(p, 0, 0.15),
                IntroCard(
                  width: 304,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: c.auraViolet.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: 19,
                              color: c.auraViolet,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t.essayTheme,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          introPop(
                            introSeg(p, 0.5, 0.65),
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 18,
                              color: c.auraCyan,
                            ),
                            dy: 0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: c.border),
                      const SizedBox(height: 14),
                      for (var i = 0; i < 5; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == 4 ? 0 : 14),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: c.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'C${i + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color.lerp(
                                      c.auraViolet,
                                      c.auraCyan,
                                      i / 4,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _GradientBar(
                                  value:
                                      _points[i] /
                                      200 *
                                      introSeg(
                                        p,
                                        0.25 + i * 0.08,
                                        0.6 + i * 0.08,
                                      ),
                                  height: 8,
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 28,
                                child: Opacity(
                                  opacity: introSeg(
                                    p,
                                    0.45 + i * 0.08,
                                    0.65 + i * 0.08,
                                  ),
                                  child: Text(
                                    '${_points[i]}',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: c.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Farm Aura
// ---------------------------------------------------------------------------
class IntroFarmVisual extends StatefulWidget {
  const IntroFarmVisual({
    required this.active,
    required this.strings,
    super.key,
  });

  final bool active;
  final IntroStrings strings;

  @override
  State<IntroFarmVisual> createState() => _IntroFarmVisualState();
}

class _IntroFarmVisualState extends State<IntroFarmVisual> {
  // Bumped on every arrival so the one-shot farm animation replays.
  int _plays = 0;

  @override
  void initState() {
    super.initState();
    if (widget.active) _plays++;
  }

  @override
  void didUpdateWidget(covariant IntroFarmVisual old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _plays++;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = widget.strings;
    return IntroScene(
      active: widget.active,
      duration: const Duration(milliseconds: 3200),
      builder: (context, p) {
        final fill = introSeg(p, 0.35, 0.85, curve: Curves.easeInOutCubic);
        final levelUp = p > 0.88;
        final gain = introSeg(p, 0.3, 0.7);
        return SizedBox.fromSize(
          size: kIntroBox,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: -10,
                child: IntroGlow(size: 330, opacity: 0.18 + 0.12 * fill),
              ),
              Positioned(
                top: 0,
                child: AurudoFarmHandsAnimation(
                  // Loops while the slide is on screen; a new key replays
                  // the entrance each time it comes back.
                  key: ValueKey('farm-${widget.active}-$_plays'),
                  size: 200,
                  loop: true,
                  instant: !widget.active,
                ),
              ),
              Positioned(
                top: 204,
                child: IntroCard(
                  width: 280,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, a) => ScaleTransition(
                              scale: a,
                              child: FadeTransition(opacity: a, child: child),
                            ),
                            child: Text(
                              '${t.t5Level} ${levelUp ? 4 : 3}',
                              key: ValueKey(levelUp),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: levelUp ? c.auraViolet : c.textPrimary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Opacity(
                            opacity: gain * (1 - introSeg(p, 0.75, 1)),
                            child: Transform.translate(
                              offset: Offset(0, -10 * gain),
                              child: Row(
                                children: [
                                  const AuraGlyph(size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    '+10',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: c.auraViolet,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 9,
                          value: 0.35 + 0.65 * fill,
                          backgroundColor: c.border,
                          valueColor: AlwaysStoppedAnimation(c.auraViolet),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 282,
                left: 0,
                right: 0,
                child: introChips(p, 0.6, [
                  (t.t5Gain, Icons.bolt_rounded),
                  (t.t5Achievements, Icons.emoji_events_rounded),
                  (t.t5Streak, Icons.local_fire_department_rounded),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

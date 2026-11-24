import 'package:material_ui/material_ui.dart';

/// Normalised progress of [t] inside the window [a]..[b] (0 before, 1 after),
/// eased. The slides split one controller into staggered pieces with it.
double introSeg(
  double t,
  double a,
  double b, {
  Curve curve = Curves.easeOutCubic,
}) => curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

/// One non-looping animation clock for a slide. It runs only while [active]
/// (the slide is the visible page): leaving the page stops and rewinds it, so
/// nothing ticks off-screen, and coming back replays the entrance. Under the
/// platform's reduced-motion setting it just shows the final state.
class IntroScene extends StatefulWidget {
  const IntroScene({
    required this.active,
    required this.duration,
    required this.builder,
    super.key,
  });

  final bool active;
  final Duration duration;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<IntroScene> createState() => _IntroSceneState();
}

class _IntroSceneState extends State<IntroScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  bool get _reduce => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduce) {
      _clock.value = 1;
    } else if (widget.active && _clock.value == 0 && !_clock.isAnimating) {
      _clock.forward();
    }
  }

  @override
  void didUpdateWidget(covariant IntroScene old) {
    super.didUpdateWidget(old);
    if (old.active == widget.active) return;
    if (_reduce) {
      _clock.value = 1;
    } else if (widget.active) {
      _clock
        ..reset()
        ..forward();
    } else {
      _clock
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => widget.builder(context, _clock.value),
      ),
    );
  }
}

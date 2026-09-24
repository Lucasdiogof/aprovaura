import 'package:flutter/material.dart';

/// Aurudo, the Aprovaura mascot (the official robot/astronaut), in one of
/// his official poses -- see lib/assets/mascot/.
enum AurudoPose {
  /// Waving hello: onboarding, neutral empty states.
  neutral('aurudo_neutral.webp'),

  /// Focused, laptop on his lap: "keep going" moments.
  studying('aurudo_studying.webp'),

  /// Holding an Aura orb: the best results / rewards.
  farmingAura('aurudo_farming_aura.webp'),

  /// Fist up: a good result, a cleared list.
  celebrating('aurudo_celebrating.webp'),

  /// Hand on chin: a result with room to grow, a hard spot.
  thinking('aurudo_thinking.webp'),

  /// Frustrated: reserved for genuine errors; never used to shame a score.
  frustrated('aurudo_frustrated.webp');

  const AurudoPose(this._file);

  final String _file;

  String get asset => 'lib/assets/mascot/$_file';
}

/// Aurudo at a given size, with a short, subtle entrance (fade + slight
/// scale, 350ms) that is skipped entirely when the platform asks for
/// reduced motion. Decorative by default: the text next to him carries the
/// meaning, so screen readers skip the image.
///
/// Use sparingly -- empty states, results, onboarding -- and never while a
/// question is on screen.
class AurudoIllustration extends StatelessWidget {
  const AurudoIllustration({
    required this.pose,
    this.size = 140,
    this.animate = true,
    super.key,
  });

  final AurudoPose pose;
  final double size;
  final bool animate;

  static const _entrance = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    final image = ExcludeSemantics(
      child: Image.asset(
        pose.asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        // A missing/undecodable asset must never break the screen it
        // decorates.
        errorBuilder: (_, _, _) => SizedBox.square(dimension: size),
      ),
    );
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!animate || reduceMotion) return image;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _entrance,
      curve: Curves.easeOutCubic,
      child: image,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
      ),
    );
  }
}

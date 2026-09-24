/// Shared spacing/radius/sizing scale so new screens stop picking their own
/// one-off numbers. Existing screens keep their current values until they
/// are otherwise touched during the visual refresh -- this is additive, not
/// a forced repaint of everything at once.
class AppSpacing {
  const AppSpacing._();

  /// Horizontal padding used by every full-bleed screen.
  static const pageHorizontal = 24.0;

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

class AppRadius {
  const AppRadius._();

  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const pill = 100.0;
}

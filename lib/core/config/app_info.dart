class AppInfo {
  const AppInfo._();

  // Kept in sync by hand with pubspec.yaml's `version:` -- there's no
  // package_info_plus dependency to read it at runtime, and adding one
  // just for an About screen felt like more than this needed.
  static const version = '1.0.0';

  /// Public privacy policy, hosted on the studio's site (the same URL goes
  /// in the Play Console and App Store Connect).
  static const privacyPolicyUrl = 'https://lucksrei.com/projects/aura/privacy/';
}

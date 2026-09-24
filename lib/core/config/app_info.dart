class AppInfo {
  const AppInfo._();

  // Kept in sync by hand with pubspec.yaml's `version:` -- there's no
  // package_info_plus dependency to read it at runtime, and adding one
  // just for an About screen felt like more than this needed.
  static const version = '1.0.0';
}

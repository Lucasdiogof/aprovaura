/// How the result screen talks about a score -- so 20% and 95% never get
/// the same message. Only picks words; the percentage itself comes from
/// the server.
enum MockExamResultTier {
  /// Below 40%.
  review,

  /// 40% to below 70%.
  advancing,

  /// 70% to below 90%.
  good,

  /// 90% and up.
  excellent;

  static MockExamResultTier fromAccuracy(double percent) {
    if (percent >= 90) return MockExamResultTier.excellent;
    if (percent >= 70) return MockExamResultTier.good;
    if (percent >= 40) return MockExamResultTier.advancing;
    return MockExamResultTier.review;
  }
}

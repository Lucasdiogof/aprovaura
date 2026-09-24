/// How the result screen frames a finished attempt. Kept as its own
/// four-way split (rather than a single fraction >= 0.5 "did well" check)
/// so a genuine 0% never reads the same as a middling-but-nonzero score --
/// see MultipleChoiceStrings.finishedTitle/finishedSubtitle and
/// _FinishedView's badge in multiple_choice_view.dart.
enum QuizResultTier {
  zero,
  developing,
  good,
  excellent;

  static QuizResultTier fromFraction(double fraction) {
    if (fraction <= 0) return QuizResultTier.zero;
    if (fraction < 0.5) return QuizResultTier.developing;
    if (fraction < 1.0) return QuizResultTier.good;
    return QuizResultTier.excellent;
  }

  bool get isCelebratory =>
      this == QuizResultTier.good || this == QuizResultTier.excellent;
}

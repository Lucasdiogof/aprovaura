/// How an essay's estimated score (0-1000) reads for the Aurudo reaction
/// system -- a separate scale from `QuizResultTier` on purpose: an essay
/// score is a sum of five competencies out of 200 each, not a
/// right/wrong fraction, and the two scales don't mean the same thing at
/// the same number (an 899 essay is "great", not "developing" the way a
/// 0.89 quiz fraction would read).
enum EssayReactionTier {
  /// 900-1000. 1000 itself is left prepared for a future special
  /// reaction, but this V1 still plays the same excellent pose.
  excellent,

  /// 700-899.
  great,

  /// 500-699.
  developing,

  /// 0-499. Never the frustrated pose -- see `AurudoMascotView`.
  encourage;

  static EssayReactionTier fromScore(int score) {
    if (score >= 900) return EssayReactionTier.excellent;
    if (score >= 700) return EssayReactionTier.great;
    if (score >= 500) return EssayReactionTier.developing;
    return EssayReactionTier.encourage;
  }
}

/// The one place the editor's numbers come from.
///
/// These mirror `essays.sql` -- `essay_min_word_count()` and
/// `essay_word_count()` -- so the screen can refuse the obviously invalid
/// case without a round trip. The server still decides: it revalidates
/// every submission and refuses short text on its own, whatever the app
/// believes. Changing the rule means changing both, and the server's copy
/// is the one that counts.
abstract final class EssayRules {
  /// Below this, "Enviar para correção" stays disabled. Deliberately low:
  /// it is the technical floor for marking something at all, not an
  /// editorial opinion about how long an essay should be.
  static const minimumWords = 50;

  /// Words the same way the database counts them: split on whitespace,
  /// drop the empties. Matching `essay_word_count()` is what stops the
  /// counter from saying 50 while the server still sees 49.
  static int wordsIn(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  static bool isLongEnough(String text) => wordsIn(text) >= minimumWords;
}

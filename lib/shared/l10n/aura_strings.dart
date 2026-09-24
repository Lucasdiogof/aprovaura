/// Wording for Aura, the Aprovaura score.
///
/// "Aura" is a proper unit, the same in every language, and never plural:
/// "1 Aura", "120 Aura" -- never "Auras", "pontos", "coins" or "XP". Only
/// the presentation says Aura; the backend keeps its technical names
/// (user_xp, xp_awards, award_quiz_xp).
class AuraStrings {
  const AuraStrings._();

  static const unit = 'Aura';

  /// "+10 Aura".
  static String gained(int amount) => '+$amount $unit';

  /// "150 Aura".
  static String amount(int amount) => '$amount $unit';
}

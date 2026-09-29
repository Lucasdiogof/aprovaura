/// The mascot's single main reaction to an event. Exactly one of these
/// plays at a time -- never a sequence of animations back to back, even
/// when several achievements land together (see
/// `AurudoReactionResolver.resolveActivity`).
enum AurudoReactionType {
  /// 100% correct: the Aprovaura signature reaction.
  perfectFarmAura,

  /// A strong result, short of perfect.
  great,

  /// A middling result: "one more step".
  normal,

  /// A weak result, without any note of disappointment: "now we know what
  /// to review".
  encourage,

  /// Today's goal was just completed by this activity.
  dailyGoalComplete,

  /// The level just went up.
  levelUp,

  /// A streak milestone was just reached.
  streakMilestone,

  /// An essay was just sent off, waiting on its correction.
  writing,

  /// An essay's correction is ready to be revealed.
  correctionReady,
}

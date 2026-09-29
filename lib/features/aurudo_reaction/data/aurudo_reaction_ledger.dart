import 'dart:convert';

import 'package:aura/features/aurudo_reaction/domain/aurudo_reaction_resolver.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which Aurudo reactions have already played, so a rebuild or a
/// trip back to Home never replays one.
///
/// Keyed by user id: signing out and into a different account never
/// inherits (or pollutes) another account's celebrated events, because
/// each user gets its own entry under its own preferences key. Construct a
/// fresh instance with the current user's id rather than caching one
/// across a sign-out -- this class does not watch auth state itself.
///
/// Bounded on purpose -- this is a "seen it" marker, not a history. Each
/// list keeps only its most recent entries, dropping the oldest as new
/// ones come in, since [SharedPreferences] itself never does that for us.
class AurudoReactionLedger {
  AurudoReactionLedger(this._prefs, {required this.userId});

  final SharedPreferences _prefs;
  final String userId;

  static const _keyPrefix = 'aurudo_reaction_ledger_v1_';
  static const _maxRecentAttempts = 50;
  static const _maxRecentEssayCorrections = 50;
  static const _maxRecentEssayWritings = 50;
  static const _maxRecentDailyGoalDates = 7;

  String get _key => '$_keyPrefix$userId';

  bool hasCelebratedAttempt(String attemptId) =>
      _read().recentAttempts.contains(attemptId);

  void markAttemptCelebrated(String attemptId) {
    final data = _read();
    _write(
      data.copyWith(
        recentAttempts: _bounded([
          ...data.recentAttempts,
          attemptId,
        ], _maxRecentAttempts),
      ),
    );
  }

  bool hasCelebratedDailyGoal(DateTime date) =>
      _read().dailyGoalDates.contains(_dateKey(date));

  void markDailyGoalCelebrated(DateTime date) {
    final data = _read();
    _write(
      data.copyWith(
        dailyGoalDates: _bounded([
          ...data.dailyGoalDates,
          _dateKey(date),
        ], _maxRecentDailyGoalDates),
      ),
    );
  }

  /// Levels only ever go up, so "already celebrated" for any level up to
  /// the last one recorded, not just an exact match -- there is no
  /// scenario where a lower level needs celebrating again.
  bool hasCelebratedLevel(int level) =>
      (_read().lastLevelCelebrated ?? 0) >= level;

  void markLevelCelebrated(int level) =>
      _write(_read().copyWith(lastLevelCelebrated: level));

  bool hasCelebratedStreakMilestone(int days) =>
      _read().streakMilestonesCelebrated.contains(days);

  void markStreakMilestoneCelebrated(int days) {
    final data = _read();
    _write(
      data.copyWith(
        streakMilestonesCelebrated: {...data.streakMilestonesCelebrated, days},
      ),
    );
  }

  /// Whether this user's current standing has been written down once
  /// without celebrating it.
  bool get hasBaseline => _read().baselineTaken;

  /// Records where the user already is as "seen", celebrating nothing.
  ///
  /// Without this, a ledger that starts empty -- a fresh install, a new
  /// device, cleared storage -- would read level 8 and a 30-day streak as
  /// achievements that just happened and throw a party for history. The
  /// first observation is the floor; only what grows past it is news.
  void takeBaseline({
    required int level,
    required int streakDays,
    required bool dailyGoalComplete,
    required DateTime today,
  }) {
    final data = _read();
    _write(
      data.copyWith(
        baselineTaken: true,
        lastLevelCelebrated: level,
        streakMilestonesCelebrated: {
          ...data.streakMilestonesCelebrated,
          ...AurudoReactionResolver.streakMilestones.where(
            (days) => days <= streakDays,
          ),
        },
        dailyGoalDates: dailyGoalComplete
            ? _bounded([
                ...data.dailyGoalDates,
                _dateKey(today),
              ], _maxRecentDailyGoalDates)
            : data.dailyGoalDates,
      ),
    );
  }

  bool hasCelebratedEssayCorrection(String submissionId) =>
      _read().essayCorrections.contains(submissionId);

  void markEssayCorrectionCelebrated(String submissionId) {
    final data = _read();
    _write(
      data.copyWith(
        essayCorrections: _bounded([
          ...data.essayCorrections,
          submissionId,
        ], _maxRecentEssayCorrections),
      ),
    );
  }

  /// The "Deixa comigo" moment right after an essay is sent. Its own list,
  /// never the corrections one: having seen the send must not stop the
  /// correction from being celebrated later -- they are two events of the
  /// same submission.
  bool hasCelebratedEssayWriting(String submissionId) =>
      _read().essayWritings.contains(submissionId);

  void markEssayWritingCelebrated(String submissionId) {
    final data = _read();
    _write(
      data.copyWith(
        essayWritings: _bounded([
          ...data.essayWritings,
          submissionId,
        ], _maxRecentEssayWritings),
      ),
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static List<String> _bounded(List<String> values, int max) =>
      values.length <= max ? values : values.sublist(values.length - max);

  _LedgerData _read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const _LedgerData.empty();
    try {
      return _LedgerData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      // Corrupted, or from a future schema version: treat as empty rather
      // than crash a whole activity result over a "seen it" marker.
      return const _LedgerData.empty();
    }
  }

  void _write(_LedgerData data) =>
      _prefs.setString(_key, jsonEncode(data.toJson()));
}

class _LedgerData {
  const _LedgerData({
    required this.recentAttempts,
    required this.dailyGoalDates,
    required this.lastLevelCelebrated,
    required this.streakMilestonesCelebrated,
    required this.essayCorrections,
    required this.essayWritings,
    required this.baselineTaken,
  });

  const _LedgerData.empty()
    : recentAttempts = const [],
      dailyGoalDates = const [],
      lastLevelCelebrated = null,
      streakMilestonesCelebrated = const {},
      essayCorrections = const [],
      essayWritings = const [],
      baselineTaken = false;

  factory _LedgerData.fromJson(Map<String, dynamic> json) => _LedgerData(
    recentAttempts: List<String>.from(
      json['recentAttempts'] as List? ?? const [],
    ),
    dailyGoalDates: List<String>.from(
      json['dailyGoalDates'] as List? ?? const [],
    ),
    lastLevelCelebrated: json['lastLevelCelebrated'] as int?,
    streakMilestonesCelebrated: Set<int>.from(
      json['streakMilestonesCelebrated'] as List? ?? const [],
    ),
    essayCorrections: List<String>.from(
      json['essayCorrections'] as List? ?? const [],
    ),
    essayWritings: List<String>.from(
      json['essayWritings'] as List? ?? const [],
    ),
    baselineTaken: json['baselineTaken'] as bool? ?? false,
  );

  final List<String> recentAttempts;
  final List<String> dailyGoalDates;
  final int? lastLevelCelebrated;
  final Set<int> streakMilestonesCelebrated;
  final List<String> essayCorrections;
  final List<String> essayWritings;

  /// Whether this user's standing has been recorded once without
  /// celebrating it -- see [AurudoReactionLedger.takeBaseline].
  final bool baselineTaken;

  Map<String, dynamic> toJson() => {
    'recentAttempts': recentAttempts,
    'dailyGoalDates': dailyGoalDates,
    'lastLevelCelebrated': lastLevelCelebrated,
    'streakMilestonesCelebrated': streakMilestonesCelebrated.toList(),
    'essayCorrections': essayCorrections,
    'essayWritings': essayWritings,
    'baselineTaken': baselineTaken,
  };

  _LedgerData copyWith({
    List<String>? recentAttempts,
    List<String>? dailyGoalDates,
    int? lastLevelCelebrated,
    Set<int>? streakMilestonesCelebrated,
    List<String>? essayCorrections,
    List<String>? essayWritings,
    bool? baselineTaken,
  }) => _LedgerData(
    recentAttempts: recentAttempts ?? this.recentAttempts,
    dailyGoalDates: dailyGoalDates ?? this.dailyGoalDates,
    lastLevelCelebrated: lastLevelCelebrated ?? this.lastLevelCelebrated,
    baselineTaken: baselineTaken ?? this.baselineTaken,
    streakMilestonesCelebrated:
        streakMilestonesCelebrated ?? this.streakMilestonesCelebrated,
    essayCorrections: essayCorrections ?? this.essayCorrections,
    essayWritings: essayWritings ?? this.essayWritings,
  );
}

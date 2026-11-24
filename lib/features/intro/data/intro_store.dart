import 'package:shared_preferences/shared_preferences.dart';

/// Local-only flags of the first-run flow. NEVER used to grant Premium or a
/// trial: the server alone decides access (see docs/PREMIUM_PARTNERS.md).
///
/// * intro seen: the animated presentation is shown once per install (or
///   browser profile); skipping counts.
/// * setup pending: the account that still has to finish the personal setup
///   (goal / exam year / subjects), so an interrupted setup resumes instead
///   of dropping the person into the app half-configured. Existing accounts
///   never get this flag, so they are never sent back through the setup.
class IntroStore {
  const IntroStore(this._prefs);

  final SharedPreferences _prefs;

  static const _introKey = 'intro_seen_v1';
  static const _setupKey = 'setup_pending_uid_v1';

  bool get introSeen => _prefs.getBool(_introKey) ?? false;

  Future<void> markIntroSeen() => _prefs.setBool(_introKey, true);

  /// An interrupted e-mail confirmation exists (see PendingSignupStore): the
  /// login resumes it, so the presentation must not get in the way.
  bool get hasPendingSignup => _prefs.containsKey('pending_signup_v1');

  String? get setupPendingFor => _prefs.getString(_setupKey);

  Future<void> markSetupPending(String uid) => _prefs.setString(_setupKey, uid);

  Future<void> clearSetupPending() => _prefs.remove(_setupKey);
}

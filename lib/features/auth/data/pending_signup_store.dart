import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/features/auth/domain/entities/pending_signup.dart';

/// Keeps the interrupted sign-up (no password) across app restarts.
class PendingSignupStore {
  static const _key = 'pending_signup_v1';

  Future<void> save(PendingSignup pending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'email': pending.email,
        'name': pending.name,
        'username': pending.username,
        'referral': pending.referralPartnerId,
        'legal': pending.legalAccept,
      }),
    );
  }

  Future<PendingSignup?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return PendingSignup(
        email: json['email'] as String,
        name: json['name'] as String?,
        username: json['username'] as String?,
        referralPartnerId: json['referral'] as String?,
        legalAccept: {
          for (final e in ((json['legal'] as Map?) ?? const {}).entries)
            e.key as String: e.value as String,
        },
      );
    } catch (_) {
      await prefs.remove(_key);
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

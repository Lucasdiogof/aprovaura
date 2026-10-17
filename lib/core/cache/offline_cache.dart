import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/network/request_guard.dart';

/// Small JSON cache over [SharedPreferences] for content the person has
/// already fetched once, so it can be shown again without a connection.
///
/// Two kinds of entries, kept apart by key prefix:
///  * public content (catalog nodes, question text) — not tied to an
///    account, so it survives a sign-out and is shared by whoever signs in;
///  * personal data (progress bars) — keyed by user id and removed by
///    [clearUserData] on sign-out, so nobody sees another account's numbers.
///
/// Invalidation: every successful online fetch overwrites its entry, so the
/// cache is always the last good answer. [version] is part of every key —
/// bump it to discard all saved entries when a stored shape changes.
/// Reads never throw: a missing or unreadable entry is just a miss.
class OfflineCache {
  OfflineCache(this._prefs);

  static const int version = 1;
  static const String _publicPrefix = 'offline.v$version.pub.';
  static const String _userPrefix = 'offline.v$version.usr.';

  final SharedPreferences _prefs;

  String publicKey(String key) => '$_publicPrefix$key';
  String userKey(String userId, String key) => '$_userPrefix$userId.$key';

  Object? read(String fullKey) {
    try {
      final raw = _prefs.getString(fullKey);
      if (raw == null) return null;
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String fullKey, Object value) async {
    try {
      await _prefs.setString(fullKey, jsonEncode(value));
    } catch (_) {
      // Storage full or unavailable: the cache is an optimization, never a
      // reason to fail the screen that just loaded fine.
    }
  }

  /// Removes every personal entry (all accounts). Public content stays.
  Future<void> clearUserData() async {
    for (final key in _prefs.getKeys().toList()) {
      if (key.startsWith(_userPrefix)) await _prefs.remove(key);
    }
  }

  /// Every full key that starts with [prefix] (used to find saved decks).
  List<String> keysWithPrefix(String prefix) => [
    for (final key in _prefs.getKeys())
      if (key.startsWith(prefix)) key,
  ];

  /// Network first, saved copy as the fallback: returns fresh [fetch] rows
  /// (and saves them) or, when the failure is the connection itself, the
  /// last saved rows under [fullKey]. Any other failure (server refused,
  /// unexpected) is returned as is, so real errors are never hidden behind
  /// stale data. Empty answers are returned but not saved.
  Future<Result<List<Map<String, dynamic>>>> rowsWithFallback(
    String fullKey,
    Future<List<dynamic>> Function() fetch, {
    Duration timeout = kRequestTimeout,
  }) async {
    try {
      final rows = (await fetch().timeout(
        timeout,
      )).cast<Map<String, dynamic>>();
      if (rows.isNotEmpty) await write(fullKey, rows);
      return Success(rows);
    } catch (error) {
      final failure = failureFromError(error);
      if (isConnectionFailure(failure)) {
        final raw = read(fullKey);
        if (raw is List && raw.isNotEmpty) {
          try {
            return Success([
              for (final row in raw) Map<String, dynamic>.from(row as Map),
            ]);
          } catch (_) {}
        }
      }
      return Error(failure);
    }
  }
}

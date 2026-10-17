import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/network/request_guard.dart';

enum PendingKind { answer, xp, favorite, streak }

class PendingAction {
  const PendingAction({
    required this.kind,
    required this.key,
    required this.payload,
    this.attempts = 0,
  });

  final PendingKind kind;

  /// What makes two actions "the same thing": the question id for an answer
  /// or favorite, the attempt id for XP. A newer action replaces an older
  /// one with the same key, so the queue only ever holds the latest choice.
  final String key;
  final Map<String, dynamic> payload;
  final int attempts;

  bool sameTarget(PendingAction other) =>
      kind == other.kind && key == other.key;

  Map<String, dynamic> toJson() => {
    'k': kind.name,
    'id': key,
    'p': payload,
    'n': attempts,
  };

  static PendingAction? fromJson(Object? raw) {
    try {
      final map = raw as Map;
      return PendingAction(
        kind: PendingKind.values.byName(map['k'] as String),
        key: map['id'] as String,
        payload: Map<String, dynamic>.from(map['p'] as Map),
        attempts: map['n'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  PendingAction retried() => PendingAction(
    kind: kind,
    key: key,
    payload: payload,
    attempts: attempts + 1,
  );
}

/// [deferred]: the server cannot take this yet (the dated functions from
/// supabase/offline_sync_dates.sql are not applied). The entry stays queued,
/// untouched, until they are.
enum _Outcome { done, failed, offline, deferred }

/// Writes that could not reach the server, kept on the device per account
/// and replayed in order once it is reachable again.
///
/// Why replaying is safe without server changes: every action maps to an
/// RPC/row that is already idempotent --
///  * `register_question_answered` upserts on (user, question), so a
///    repeat only rewrites the same row (no second progress);
///  * `award_quiz_xp` ignores an attempt id it has already paid;
///  * favorites are insert/delete by (user, question) and a duplicate
///    insert or a delete of nothing is treated as done.
/// Entries are stored under the signed-in user's id, so another account on
/// the same device never sees or sends them.
///
/// Not queued on purpose: streak completion (the server dates it with
/// now(), so a late replay would credit a day that was not studied) and
/// anything that needs the server's answer to continue (simulado grading).
class PendingSyncQueue {
  PendingSyncQueue(this._prefs, this._client);

  static const _maxAttempts = 3;
  static const _prefix = 'offline.v1.queue.';

  final SharedPreferences _prefs;
  final SupabaseClient _client;
  final List<void Function(Set<PendingKind> synced)> _flushListeners = [];
  Future<void>? _flushing;

  void onFlushed(void Function(Set<PendingKind> synced) listener) =>
      _flushListeners.add(listener);

  String? get _storageKey {
    final uid = _client.auth.currentUser?.id;
    return uid == null ? null : '$_prefix$uid';
  }

  List<PendingAction> _read() {
    final key = _storageKey;
    if (key == null) return [];
    try {
      final raw = _prefs.getString(key);
      if (raw == null) return [];
      return [
        for (final item in jsonDecode(raw) as List)
          ?PendingAction.fromJson(item),
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<PendingAction> actions) async {
    final key = _storageKey;
    if (key == null) return;
    try {
      if (actions.isEmpty) {
        await _prefs.remove(key);
      } else {
        await _prefs.setString(
          key,
          jsonEncode([for (final a in actions) a.toJson()]),
        );
      }
    } catch (_) {}
  }

  int get pendingCount => _read().length;

  /// Question ids with an answer waiting to be sent.
  Set<String> pendingAnswerIds() => {
    for (final a in _read())
      if (a.kind == PendingKind.answer) a.key,
  };

  Future<void> enqueue(PendingAction action) async {
    final all = _read()
      ..removeWhere(action.sameTarget)
      ..add(action);
    await _write(all);
  }

  /// Forgets everything saved for the signed-in account (account deletion).
  Future<void> clearForCurrentUser() async {
    final key = _storageKey;
    if (key != null) await _prefs.remove(key);
  }

  /// Sends what is waiting. Safe to call from several places: overlapping
  /// calls share one run. Stops at the first connection failure, keeping
  /// the rest for the next reconnect.
  Future<void> flush() => _flushing ??= _run().whenComplete(() {
    _flushing = null;
  });

  Future<void> _run() async {
    final synced = <PendingKind>{};
    final handled = <PendingAction>[];
    while (true) {
      final next = _read().where((a) => !handled.any(a.sameTarget)).firstOrNull;
      if (next == null) break;
      final outcome = await _send(next);
      if (outcome == _Outcome.offline) break;
      handled.add(next);
      if (outcome == _Outcome.deferred) continue;

      // Re-read: the same target may have been enqueued again while the
      // request ran, in which case the newer one must stay for its own turn.
      final latest = _read();
      final index = latest.indexWhere(next.sameTarget);
      if (index < 0) continue;
      final changed =
          jsonEncode(latest[index].payload) != jsonEncode(next.payload);
      if (changed) {
        handled.removeLast();
        continue;
      }
      if (outcome == _Outcome.done) {
        latest.removeAt(index);
        synced.add(next.kind);
      } else if (latest[index].attempts + 1 >= _maxAttempts) {
        latest.removeAt(index);
      } else {
        latest[index] = latest[index].retried();
      }
      await _write(latest);
    }
    if (synced.isNotEmpty) {
      for (final listener in List.of(_flushListeners)) {
        listener(synced);
      }
    }
  }

  Future<_Outcome> _send(PendingAction action) async {
    try {
      switch (action.kind) {
        case PendingKind.answer:
          final params = {
            'p_question_id': action.key,
            'p_is_correct': action.payload['isCorrect'] as bool,
          };
          final answeredAt = action.payload['answeredAt'] as String?;
          try {
            await _client
                .rpc<void>(
                  'register_question_answered',
                  params: {...params, 'p_answered_at': ?answeredAt},
                )
                .withRequestTimeout();
          } on PostgrestException catch (e) {
            // PGRST202: the dated version is not deployed yet. Sending the
            // answer without its time still records it (counted on the day
            // it syncs), which beats losing it.
            if (e.code != 'PGRST202' || answeredAt == null) rethrow;
            await _client
                .rpc<void>('register_question_answered', params: params)
                .withRequestTimeout();
          }
        case PendingKind.streak:
          try {
            await _client
                .rpc<dynamic>(
                  'register_activity_completion',
                  params: {'p_activity_date': action.key},
                )
                .withRequestTimeout();
          } on PostgrestException catch (e) {
            // Without the dated function the server would credit today,
            // a day that may not have been studied: keep it queued.
            if (e.code == 'PGRST202') return _Outcome.deferred;
            rethrow;
          }
        case PendingKind.xp:
          await _client
              .rpc<dynamic>(
                'award_quiz_xp',
                params: {
                  'p_attempt_id': action.key,
                  'p_correct_count': action.payload['correctCount'] as int,
                },
              )
              .withRequestTimeout();
        case PendingKind.favorite:
          final uid = _client.auth.currentUser!.id;
          if (action.payload['add'] as bool) {
            await _client.from('user_question_favorites').insert({
              'user_id': uid,
              'question_id': action.key,
            }).withRequestTimeout();
          } else {
            await _client
                .from('user_question_favorites')
                .delete()
                .eq('user_id', uid)
                .eq('question_id', action.key)
                .withRequestTimeout();
          }
      }
      return _Outcome.done;
    } on PostgrestException catch (e) {
      // 23505: the favorite already exists, which is what we wanted.
      if (e.code == '23505') return _Outcome.done;
      return _Outcome.failed;
    } catch (error) {
      return isConnectionFailure(failureFromError(error))
          ? _Outcome.offline
          : _Outcome.failed;
    }
  }
}

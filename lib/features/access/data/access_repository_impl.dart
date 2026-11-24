import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/features/access/data/access_grant_verifier.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';
import 'package:aura/features/access/domain/repositories/access_repository.dart';

/// Acesso Premium: servidor primeiro; offline, só com a autorização assinada
/// DA CONTA ATUAL. Chaves locais são por conta, então trocar de conta nunca
/// reaproveita a autorização de outra pessoa.
class AccessRepositoryImpl implements AccessRepository {
  AccessRepositoryImpl(
    this._client,
    this._prefs,
    this._verifier, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SupabaseClient _client;
  final SharedPreferences _prefs;
  final AccessGrantVerifier _verifier;
  final DateTime Function() _clock;

  static const _root = 'access.v1.';
  static String _grantKey(String uid) => '${_root}grant.$uid';
  static String _seenKey(String uid) => '${_root}seen.$uid';
  static String _enforcedKey(String uid) => '${_root}enforced.$uid';

  @override
  Future<Result<AccessStatus>> refresh() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return Error(AuthFailure());
    try {
      final raw = await _client
          .rpc<dynamic>('get_my_access')
          .withRequestTimeout();
      final json = Map<String, dynamic>.from(raw as Map);
      final grant = json['offline_grant'];
      if (grant is String) {
        await _prefs.setString(_grantKey(uid), grant);
      } else {
        // Negado (ou sem chave no servidor): não guardar autorização antiga.
        await _prefs.remove(_grantKey(uid));
      }
      await _prefs.setBool(_enforcedKey(uid), json['enforced'] == true);
      await _ratchetSeen(uid);
      if (json['must_verify_email'] == true) onEmailUnverified?.call();
      return Success(AccessStatus.fromJson(json));
    } catch (error) {
      final failure = failureFromError(error);
      if (isConnectionFailure(failure)) return Success(_offline(uid));
      return Error(failure);
    }
  }

  AccessStatus _offline(String uid) {
    final token = _prefs.getString(_grantKey(uid));
    if (token != null) {
      final seen = DateTime.fromMillisecondsSinceEpoch(
        _prefs.getInt(_seenKey(uid)) ?? 0,
        isUtc: true,
      );
      final result = _verifier.verify(
        token,
        userId: uid,
        now: _clock(),
        lastSeen: seen,
      );
      final payload = result.payload;
      if (payload != null) {
        unawaited(_ratchetSeen(uid));
        final status = AccessStatus.fromJson({
          ...payload,
          'access_until': null,
        });
        return AccessStatus(
          enforced: status.enforced,
          allowed: status.allowed,
          isAdmin: status.isAdmin,
          isPartner: status.isPartner,
          sources: status.sources,
          fromOfflineGrant: true,
        );
      }
      if (result.rejection == GrantRejection.wrongAccount ||
          result.rejection == GrantRejection.malformed ||
          result.rejection == GrantRejection.badSignature) {
        unawaited(_prefs.remove(_grantKey(uid)));
      }
    }
    // Sem autorização válida. Se o modelo comercial já foi visto ligado
    // nesta conta, exige conexão; senão o app segue como hoje. (Dica local,
    // não assinada: protege contra uso comum, não contra aparelho adulterado.)
    return (_prefs.getBool(_enforcedKey(uid)) ?? false)
        ? AccessStatus.connectionRequired
        : AccessStatus.open;
  }

  /// O "último instante visto" só avança: recuar o relógio não rejuvenesce
  /// uma autorização.
  Future<void> _ratchetSeen(String uid) async {
    final now = _clock().toUtc().millisecondsSinceEpoch;
    final seen = _prefs.getInt(_seenKey(uid)) ?? 0;
    if (now > seen) await _prefs.setInt(_seenKey(uid), now);
  }

  @override
  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_root)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

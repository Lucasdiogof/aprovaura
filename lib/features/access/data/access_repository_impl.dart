import 'dart:async';
import 'dart:convert';

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
      // Sem rede OU falha do servidor (5xx/inesperada): vale só a autorização
      // assinada ainda válida. Uma falha do servidor NUNCA estende acesso
      // vencido: sem autorização válida cai em "conecte-se para verificar".
      if (isConnectionFailure(failure) ||
          failure is ServerFailure ||
          failure is UnexpectedFailure) {
        return Success(_offline(uid));
      }
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
          authorizationExpiresAt: payload['exp'] is num
              ? DateTime.fromMillisecondsSinceEpoch(
                  (payload['exp'] as num).toInt() * 1000,
                  isUtc: true,
                )
              : null,
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
  Future<AccessContext> loadContext() async {
    try {
      final raw = await _client
          .rpc<dynamic>('get_my_access_context')
          .withRequestTimeout();
      return AccessContext.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      return const AccessContext();
    }
  }

  static String _legalKey(String uid) => '${_root}legal.$uid';

  /// O que o servidor confirmou fica guardado por conta: desconectar o aparelho
  /// ou reiniciar offline NÃO apaga uma obrigação já conhecida. Sem resposta do
  /// servidor e sem nada guardado, devolve null (nunca inventa bloqueio).
  @override
  Future<List<PendingLegal>?> loadPendingLegal() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final raw = await _client.rpc<dynamic>('get_legal_status').withRequestTimeout();
      final list = (raw as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .where((d) => d['accepted'] != true && d['requires_reaccept'] == true)
          .map((d) => PendingLegal(kind: '${d['kind']}', version: '${d['version']}', url: d['url'] as String?))
          .toList();
      await _prefs.setString(
        _legalKey(uid),
        jsonEncode([for (final d in list) {'k': d.kind, 'v': d.version, 'u': d.url}]),
      );
      return list;
    } catch (_) {
      final cached = _prefs.getString(_legalKey(uid));
      if (cached == null) return null;
      try {
        return [
          for (final e in (jsonDecode(cached) as List).whereType<Map<String, dynamic>>())
            PendingLegal(kind: '${e['k']}', version: '${e['v']}', url: e['u'] as String?),
        ];
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<bool> acceptLegal(List<PendingLegal> docs, String platform) async {
    try {
      for (final d in docs) {
        await _client
            .rpc<dynamic>('record_legal_acceptance',
                params: {'p_kind': d.kind, 'p_version': d.version, 'p_platform': platform})
            .withRequestTimeout();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_root)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}

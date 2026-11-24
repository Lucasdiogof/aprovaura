import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/access/data/access_grant_verifier.dart';
import 'package:aura/features/access/data/access_repository_impl.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';

/// Servidor HTTP local fingindo ser o PostgREST: o repositório real roda contra
/// ele (sem mock do cliente), inclusive "desconectar" (parar o servidor) e 5xx.
class _Server {
  late HttpServer _http;
  int status = 200;
  Object body = <String, Object?>{};
  final Map<String, Object> bodies = {};
  int rpcCalls = 0;

  Future<void> start([int port = 0]) async {
    _http = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _http.listen((req) async {
      rpcCalls++;
      final name = req.uri.pathSegments.last;
      await utf8.decoder.bind(req).join();
      req.response.statusCode = status;
      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode(bodies[name] ?? body));
      await req.response.close();
    });
  }

  int get port => _http.port;
  Future<void> stop() => _http.close(force: true);
}

String _jwt() {
  String b(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  final exp = DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000;
  return '${b({'alg': 'HS256', 'typ': 'JWT'})}.${b({'sub': 'u-1', 'exp': exp, 'role': 'authenticated'})}.sig';
}

Future<SupabaseClient> _client(int port) async {
  final c = SupabaseClient('http://127.0.0.1:$port', 'anon-key');
  final token = _jwt();
  await c.auth.recoverSession(jsonEncode({
    'access_token': token,
    'refresh_token': 'r',
    'token_type': 'bearer',
    'expires_in': 7200,
    'expires_at': DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
    'user': {
      'id': 'u-1',
      'aud': 'authenticated',
      'app_metadata': <String, Object?>{},
      'user_metadata': <String, Object?>{},
      'created_at': '2026-01-01T00:00:00Z',
    },
  }));
  return c;
}

void main() {
  const pending = [
    {'kind': 'terms', 'version': '2027-01-01', 'url': 'https://x', 'accepted': false, 'requires_reaccept': true},
    {'kind': 'privacy', 'version': '2026-09-28', 'url': 'https://y', 'accepted': true, 'requires_reaccept': true},
    {'kind': 'cookies', 'version': '1', 'url': null, 'accepted': false, 'requires_reaccept': false},
  ];

  late _Server server;
  late AccessRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    server = _Server();
    await server.start();
    final prefs = await SharedPreferences.getInstance();
    repo = AccessRepositoryImpl(await _client(server.port), prefs, const AccessGrantVerifier());
  });
  tearDown(() => server.stop());

  group('reaceite legal: obrigação confirmada pelo servidor não some offline', () {
    test('só entra o que exige reaceite e ainda não foi aceito', () async {
      server.bodies['get_legal_status'] = pending;
      final r = await repo.loadPendingLegal();
      expect(r!.map((d) => d.kind), ['terms']);
    });

    test('desconectar (servidor fora) mantém a obrigação já conhecida', () async {
      server.bodies['get_legal_status'] = pending;
      await repo.loadPendingLegal();
      await server.stop();
      final r = await repo.loadPendingLegal();
      expect(r!.map((d) => d.kind), ['terms']);
    });

    test('erro 5xx também mantém a obrigação', () async {
      server.bodies['get_legal_status'] = pending;
      await repo.loadPendingLegal();
      server.status = 503;
      final r = await repo.loadPendingLegal();
      expect(r!.map((d) => d.kind), ['terms']);
    });

    test('reinício offline (novo repositório, mesmas preferências) mantém a obrigação', () async {
      server.bodies['get_legal_status'] = pending;
      await repo.loadPendingLegal();
      await server.stop();
      final prefs = await SharedPreferences.getInstance();
      final fresh = AccessRepositoryImpl(await _client(1), prefs, const AccessGrantVerifier());
      expect((await fresh.loadPendingLegal())!.map((d) => d.kind), ['terms']);
    });

    test('nunca soube de nada e está offline: null (não inventa bloqueio)', () async {
      await server.stop();
      expect(await repo.loadPendingLegal(), isNull);
    });

    test('servidor diz que não há pendência: libera e a lista guardada é limpa', () async {
      server.bodies['get_legal_status'] = pending;
      await repo.loadPendingLegal();
      server.bodies['get_legal_status'] = [
        {...pending.first, 'accepted': true},
      ];
      expect(await repo.loadPendingLegal(), isEmpty);
      await server.stop();
      expect(await repo.loadPendingLegal(), isEmpty);
    });

    test('aceitar offline falha (a tela de aceite continua)', () async {
      await server.stop();
      expect(await repo.acceptLegal([const PendingLegal(kind: 'terms', version: 'v')], 'android'), isFalse);
    });
  });

  group('acesso: 5xx e desconexão nunca estendem acesso vencido', () {
    test('5xx sem autorização offline válida e modelo visto ligado: exige conexão', () async {
      server.body = {'enforced': true, 'allowed': true, 'roles': <String, Object?>{}};
      final ok = await repo.refresh();
      expect((ok as Success<AccessStatus>).data.allowed, isTrue);
      server.status = 500;
      final r = await repo.refresh();
      final s = (r as Success<AccessStatus>).data;
      expect(s.needsConnection, isTrue);
      expect(s.allowed, isFalse);
    });

    test('sem rede e sem histórico do modelo: segue aberto como hoje', () async {
      await server.stop();
      final s = ((await repo.refresh()) as Success<AccessStatus>).data;
      expect(s.needsConnection, isFalse);
      expect(s.isBlocked, isFalse);
    });

    test('clear() esquece obrigações e autorização da conta', () async {
      server.bodies['get_legal_status'] = pending;
      await repo.loadPendingLegal();
      await repo.clear();
      await server.stop();
      expect(await repo.loadPendingLegal(), isNull);
    });
  });
}

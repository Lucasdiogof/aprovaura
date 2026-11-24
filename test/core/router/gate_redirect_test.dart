import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';

void main() {
  String? r(AccessGate g, String loc, {String? to}) =>
      gateRedirect(gate: g, location: loc, fullLocation: loc, to: to);

  test('paywall barra estudo, deep link e rotas diretas', () {
    for (final p in ['/home', '/onboarding', '/login', '/apresentacao', '/cadastro']) {
      expect(r(AccessGate.paywall, p), '/assinatura');
    }
    expect(r(AccessGate.paywall, '/assinatura'), isNull);
    expect(r(AccessGate.paywall, '/minha-assinatura'), isNull);
  });

  test('portal nunca é barrado pelo paywall', () {
    expect(r(AccessGate.paywall, '/partners/finance'), isNull);
    expect(r(AccessGate.connectionRequired, '/partners'), isNull);
  });

  test('conexão e versão têm destino próprio', () {
    expect(r(AccessGate.connectionRequired, '/home'), '/conectar');
    expect(r(AccessGate.updateRequired, '/home'), '/atualizar');
  });

  test('resolvendo leva à verificação e volta ao destino, só interno', () {
    expect(r(AccessGate.resolving, '/home'), '/verificando?to=%2Fhome');
    expect(r(AccessGate.open, '/verificando', to: '/onboarding'), '/onboarding');
    expect(r(AccessGate.open, '/verificando', to: '//evil.com'), '/home');
    expect(r(AccessGate.open, '/verificando'), '/home');
  });

  test('aberto: paywall voluntário fica; telas de bloqueio saem', () {
    expect(r(AccessGate.open, '/assinatura'), isNull);
    expect(r(AccessGate.open, '/conectar'), '/home');
    expect(r(AccessGate.open, '/atualizar'), '/home');
  });
}

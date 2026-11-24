import 'package:aura/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authRedirect', () {
    test('sem sessão, rotas autenticadas voltam para /login', () {
      expect(authRedirect(hasSession: false, location: '/home'), '/login');
      expect(
        authRedirect(hasSession: false, location: '/onboarding'),
        '/login',
      );
    });

    test('sem sessão, login e cadastro continuam acessíveis', () {
      expect(authRedirect(hasSession: false, location: '/login'), isNull);
      expect(authRedirect(hasSession: false, location: '/cadastro'), isNull);
    });

    test('com sessão, /login vai para /home e o resto segue', () {
      expect(authRedirect(hasSession: true, location: '/login'), '/home');
      expect(authRedirect(hasSession: true, location: '/home'), isNull);
      expect(authRedirect(hasSession: true, location: '/onboarding'), isNull);
    });

    test('first run signed out goes to the presentation before login', () {
      expect(
        authRedirect(hasSession: false, location: '/login', introSeen: false),
        '/apresentacao',
      );
      expect(
        authRedirect(
          hasSession: false,
          location: '/login',
          introSeen: false,
          hasPendingSignup: true,
        ),
        isNull,
      );
      expect(
        authRedirect(hasSession: false, location: '/login', introSeen: true),
        isNull,
      );
    });

    test('an interrupted personal setup resumes; finished accounts do not', () {
      expect(
        authRedirect(hasSession: true, location: '/home', setupPending: true),
        '/onboarding',
      );
      expect(
        authRedirect(hasSession: true, location: '/home'),
        isNull,
      );
      expect(
        authRedirect(hasSession: true, location: '/apresentacao'),
        '/home',
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/features/auth/data/auth_error_messages.dart';

void main() {
  group('classifyAuthError', () {
    test('reads the error code first', () {
      expect(
        classifyAuthError(
          const AuthException('whatever', code: 'user_already_exists'),
        ),
        AuthErrorKind.emailTaken,
      );
      expect(
        classifyAuthError(
          const AuthException(
            'Invalid login credentials',
            code: 'invalid_credentials',
          ),
        ),
        AuthErrorKind.invalidCredentials,
      );
      expect(
        classifyAuthError(
          const AuthException('slow down', code: 'over_email_send_rate_limit'),
        ),
        AuthErrorKind.rateLimited,
      );
      expect(
        classifyAuthError(
          const AuthException('bad', code: 'email_address_invalid'),
        ),
        AuthErrorKind.invalidEmail,
      );
    });

    test('falls back to the message when the server sends no code', () {
      expect(
        classifyAuthError(const AuthException('User already registered')),
        AuthErrorKind.emailTaken,
      );
      expect(
        classifyAuthError(const AuthException('Invalid login credentials')),
        AuthErrorKind.invalidCredentials,
      );
    });

    test('a request that never reached the server is a network error', () {
      expect(
        classifyAuthError(AuthRetryableFetchException(message: 'offline')),
        AuthErrorKind.network,
      );
    });

    test('anything else is unknown, never the raw server text', () {
      const e = AuthException('Something odd happened', code: 'unexpected');
      final kind = classifyAuthError(e);
      expect(kind, AuthErrorKind.unknown);
      expect(authErrorMessage(kind), isNot(contains('odd')));
    });
  });

  test('every kind has a Portuguese message', () {
    for (final kind in AuthErrorKind.values) {
      expect(authErrorMessage(kind), isNotEmpty);
    }
    expect(
      authErrorMessage(AuthErrorKind.emailTaken),
      startsWith('Já existe uma conta'),
    );
  });
}

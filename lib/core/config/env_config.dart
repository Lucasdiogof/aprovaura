class EnvConfig {
  const EnvConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Só builds da faixa interna (--dart-define=BILLING_TEST_ENTRY=true): abre o paywall sem a monetização ligada.
  static const bool billingTestEntry = bool.fromEnvironment('BILLING_TEST_ENTRY');

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL ausente. Rode com --dart-define-from-file=env.json '
        '(copie env.example.json para env.json e preencha as chaves).',
      );
    }
    if (supabasePublishableKey.isEmpty) {
      throw StateError(
        'SUPABASE_PUBLISHABLE_KEY ausente. Rode com --dart-define-from-file=env.json '
        '(copie env.example.json para env.json e preencha as chaves).',
      );
    }
  }
}

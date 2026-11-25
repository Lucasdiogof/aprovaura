import 'package:aura/core/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Builds de loja nunca definem BILLING_TEST_ENTRY: a entrada de teste de compra tem de ficar desligada por padrão.
  test('BILLING_TEST_ENTRY é falso por padrão', () {
    expect(EnvConfig.billingTestEntry, isFalse);
  });
}

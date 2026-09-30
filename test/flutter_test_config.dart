import 'dart:async';

import 'package:aura/shared/widgets/aura/aurudo_idle.dart';

/// Runs once around the whole widget-test suite.
///
/// Aurudo's idle drift loops forever by design, and he stands in eight
/// screens: left on, he turns `pumpAndSettle` into a timeout in every test
/// that opens one of them. The drift carries no meaning -- the tests that
/// exist to check it switch it back on themselves.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AurudoIdle.debugEnabled = false;
  await testMain();
}

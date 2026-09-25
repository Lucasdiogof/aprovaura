import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';

void main() {
  group(AppBlockingLoadingCubit, () {
    test('starts hidden', () {
      final cubit = AppBlockingLoadingCubit();
      expect(cubit.state.isVisible, isFalse);
      cubit.close();
    });

    test('run shows the overlay while the future is in flight', () async {
      final cubit = AppBlockingLoadingCubit();
      final completer = Completer<void>();

      final future = cubit.run(() => completer.future, message: 'Saindo...');
      expect(cubit.state.isVisible, isTrue);
      expect(cubit.state.message, 'Saindo...');

      completer.complete();
      await future;
      expect(cubit.state.isVisible, isFalse);
      expect(cubit.state.message, isNull);
      await cubit.close();
    });

    test('hides on the way out even if the action throws', () async {
      final cubit = AppBlockingLoadingCubit();

      await expectLater(
        cubit.run(() => Future<void>.error(StateError('boom'))),
        throwsA(isA<StateError>()),
      );
      expect(cubit.state.isVisible, isFalse);
      await cubit.close();
    });

    test(
      'two concurrent operations: the overlay only hides once both finish',
      () async {
        final cubit = AppBlockingLoadingCubit();
        final first = Completer<void>();
        final second = Completer<void>();

        final futureA = cubit.run(() => first.future, message: 'A');
        final futureB = cubit.run(() => second.future, message: 'B');
        expect(cubit.state.activeCount, 2);

        first.complete();
        await futureA;
        // Still up: the second call hasn't finished.
        expect(cubit.state.isVisible, isTrue);
        expect(cubit.state.activeCount, 1);

        second.complete();
        await futureB;
        expect(cubit.state.isVisible, isFalse);
        await cubit.close();
      },
    );

    test(
      "the message shown is always the most recently started call's",
      () async {
        final cubit = AppBlockingLoadingCubit();
        final a = Completer<void>();
        final b = Completer<void>();

        final futureA = cubit.run(() => a.future, message: 'first');
        expect(cubit.state.message, 'first');
        final futureB = cubit.run(() => b.future, message: 'second');
        expect(cubit.state.message, 'second');

        a.complete();
        b.complete();
        await Future.wait([futureA, futureB]);
        await cubit.close();
      },
    );
  });
}

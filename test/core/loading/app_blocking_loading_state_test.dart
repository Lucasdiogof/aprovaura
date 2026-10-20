import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/loading/app_blocking_loading_state.dart';

void main() {
  test('starts hidden', () {
    const state = AppBlockingLoadingState();
    expect(state.isVisible, isFalse);
    expect(state.activeCount, 0);
    expect(state.message, isNull);
  });

  test('increment shows the overlay with the message', () {
    final state = const AppBlockingLoadingState().increment(
      message: 'Salvando',
    );
    expect(state.isVisible, isTrue);
    expect(state.activeCount, 1);
    expect(state.message, 'Salvando');
  });

  test('is reference counted: stays visible until all finish', () {
    final state = const AppBlockingLoadingState().increment().increment();
    final afterOne = state.decrement();
    expect(afterOne.isVisible, isTrue);
    expect(afterOne.activeCount, 1);
    expect(afterOne.decrement().isVisible, isFalse);
  });

  test('newest message wins, and a message-less increment keeps it', () {
    var state = const AppBlockingLoadingState().increment(message: 'A');
    state = state.increment(message: 'B');
    expect(state.message, 'B');
    expect(state.increment().message, 'B');
  });

  test('message is cleared when the count reaches zero', () {
    final state = const AppBlockingLoadingState()
        .increment(message: 'A')
        .decrement();
    expect(state.message, isNull);
  });

  test('decrement never goes below zero', () {
    final state = const AppBlockingLoadingState().decrement().decrement();
    expect(state.activeCount, 0);
    expect(state.isVisible, isFalse);
  });

  test('value equality', () {
    expect(
      const AppBlockingLoadingState().increment(message: 'x'),
      const AppBlockingLoadingState().increment(message: 'x'),
    );
  });
}

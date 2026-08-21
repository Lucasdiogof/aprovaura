import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/home/presentation/cubit/home_shell_cubit.dart';
import 'package:aura/features/home/presentation/cubit/home_shell_state.dart';

void main() {
  group(HomeShellCubit, () {
    test('starts with the default $HomeShellState (index 0)', () {
      expect(HomeShellCubit().state, const HomeShellState());
    });

    blocTest<HomeShellCubit, HomeShellState>(
      'navigateToTab emits a state with the given index',
      build: HomeShellCubit.new,
      act: (cubit) => cubit.navigateToTab(2),
      expect: () => [const HomeShellState(index: 2)],
    );

    blocTest<HomeShellCubit, HomeShellState>(
      'navigateToTab called repeatedly emits one state per call',
      build: HomeShellCubit.new,
      act: (cubit) {
        cubit.navigateToTab(1);
        cubit.navigateToTab(3);
        cubit.navigateToTab(0);
      },
      expect: () => [
        const HomeShellState(index: 1),
        const HomeShellState(index: 3),
        const HomeShellState(),
      ],
    );
  });
}

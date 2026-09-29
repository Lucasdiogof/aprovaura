import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_state.dart';

void main() {
  final wait = UsernameCheckCubit.checkDelay * 2;

  UsernameCheckCubit build({
    Future<Result<bool>> Function(String)? answer,
    String? current,
  }) => UsernameCheckCubit(
    isAvailable: answer ?? (_) => fail('the database should not be asked'),
    currentUsername: current,
  );

  group(UsernameCheckCubit, () {
    blocTest<UsernameCheckCubit, UsernameCheckState>(
      'a malformed name never reaches the database',
      build: build,
      act: (cubit) => cubit
        ..changed('ab')
        ..changed('a' * 21)
        ..changed('com espaço'),
      wait: wait,
      expect: () => const [
        UsernameCheckState(username: 'ab'),
        UsernameCheckState(username: 'aaaaaaaaaaaaaaaaaaaaa'),
        UsernameCheckState(username: 'com espaço'),
      ],
    );

    blocTest<UsernameCheckCubit, UsernameCheckState>(
      'a well-formed name: checking, then the answer',
      build: () => build(answer: (_) async => const Success(false)),
      act: (cubit) => cubit.changed(' lucks '),
      wait: wait,
      expect: () => const [
        UsernameCheckState(status: UsernameCheck.checking, username: 'lucks'),
        UsernameCheckState(status: UsernameCheck.taken, username: 'lucks'),
      ],
    );

    blocTest<UsernameCheckCubit, UsernameCheckState>(
      'a failed check is reported (and blocks saving)',
      build: () => build(answer: (_) async => Error(ServerFailure())),
      act: (cubit) => cubit.changed('lucks'),
      wait: wait,
      expect: () => const [
        UsernameCheckState(status: UsernameCheck.checking, username: 'lucks'),
        UsernameCheckState(status: UsernameCheck.failed, username: 'lucks'),
      ],
    );

    blocTest<UsernameCheckCubit, UsernameCheckState>(
      'the own username is available in any casing, without asking',
      build: () => build(current: 'Lucas_Diogo'),
      act: (cubit) => cubit
        ..changed('Lucas_Diogo')
        ..changed('lucas_diogo'),
      expect: () => const [
        UsernameCheckState(
          status: UsernameCheck.available,
          username: 'Lucas_Diogo',
        ),
        UsernameCheckState(
          status: UsernameCheck.available,
          username: 'lucas_diogo',
        ),
      ],
    );

    blocTest<UsernameCheckCubit, UsernameCheckState>(
      'markTaken: what the database refused on save shows as taken',
      build: () => build(answer: (_) async => const Success(true)),
      act: (cubit) async {
        cubit.changed('lucks');
        await Future<void>.delayed(wait);
        cubit.markTaken('lucks');
      },
      skip: 2,
      expect: () => const [
        UsernameCheckState(status: UsernameCheck.taken, username: 'lucks'),
      ],
    );

    test('an answer for a name no longer typed is dropped', () async {
      final slow = Completer<Result<bool>>();
      final cubit = build(
        answer: (name) =>
            name == 'first' ? slow.future : Future.value(const Success(true)),
      );
      addTearDown(cubit.close);

      cubit.changed('first');
      await Future<void>.delayed(UsernameCheckCubit.checkDelay * 1.5);
      cubit.changed('second');
      await Future<void>.delayed(UsernameCheckCubit.checkDelay * 1.5);
      slow.complete(const Success(false));
      await Future<void>.delayed(Duration.zero);

      expect(
        cubit.state,
        const UsernameCheckState(
          status: UsernameCheck.available,
          username: 'second',
        ),
      );
    });

    test('fast typing asks once, for the last value', () async {
      final asked = <String>[];
      final cubit = build(
        answer: (name) async {
          asked.add(name);
          return const Success(true);
        },
      );
      addTearDown(cubit.close);
      for (final partial in ['luc', 'luca', 'lucas']) {
        cubit.changed(partial);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      await Future<void>.delayed(wait);
      expect(asked, ['lucas']);
    });
  });
}

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/error_review/presentation/cubit/error_review_cubit.dart';
import 'package:aura/features/error_review/presentation/cubit/error_review_state.dart';

class _MockErrorReviewRepository extends Mock
    implements ErrorReviewRepository {}

void main() {
  group(ErrorReviewCubit, () {
    late ErrorReviewRepository repository;

    const topics = [
      ErrorTopic(
        catalogNodeId: 't1',
        subject: 'geografia',
        title: 'Estados do Brasil',
        wrongCount: 3,
      ),
    ];

    setUp(() {
      repository = _MockErrorReviewRepository();
    });

    test(
      'settles on $ErrorReviewLoaded when the topics load successfully',
      () async {
        when(
          () => repository.listPendingTopics(source: null),
        ).thenAnswer((_) async => const Success(topics));
        final cubit = ErrorReviewCubit(repository);

        await pumpEventQueue();

        expect(cubit.state, const ErrorReviewLoaded(topics));
      },
    );

    test('settles on $ErrorReviewError when loading fails', () async {
      when(
        () => repository.listPendingTopics(source: null),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));
      final cubit = ErrorReviewCubit(repository);

      await pumpEventQueue();

      expect(cubit.state, const ErrorReviewError('boom'));
    });

    blocTest<ErrorReviewCubit, ErrorReviewState>(
      'refresh() reloads without an intermediate $ErrorReviewLoading state',
      build: () {
        var call = 0;
        when(() => repository.listPendingTopics(source: null)).thenAnswer((
          _,
        ) async {
          call++;
          return Success(call == 1 ? topics : const <ErrorTopic>[]);
        });
        return ErrorReviewCubit(repository);
      },
      act: (cubit) => cubit.refresh(),
      // No skip: the constructor's own initial fetch is still in flight
      // when refresh() starts a newer one, and the stale-request guard
      // makes sure that first fetch's resolution never emits at all (not
      // even a discarded one) -- refresh()'s own result is the only thing
      // this cubit ever emits here.
      expect: () => [const ErrorReviewLoaded(<ErrorTopic>[])],
    );

    test('setSource switches the filter and reloads for it', () async {
      when(
        () => repository.listPendingTopics(source: null),
      ).thenAnswer((_) async => const Success(topics));
      when(
        () => repository.listPendingTopics(source: 'mock_exam'),
      ).thenAnswer((_) async => const Success(<ErrorTopic>[]));
      final cubit = ErrorReviewCubit(repository);
      // Let the constructor's own initial load settle first -- calling
      // setSource before that would race it, since neither fetch cancels
      // the other.
      await pumpEventQueue();

      await cubit.setSource('mock_exam');

      expect(cubit.state, const ErrorReviewLoaded(<ErrorTopic>[], 'mock_exam'));
      verify(() => repository.listPendingTopics(source: 'mock_exam')).called(1);
    });

    test('setSource is a no-op when it matches the current filter', () async {
      when(
        () => repository.listPendingTopics(source: null),
      ).thenAnswer((_) async => const Success(topics));
      final cubit = ErrorReviewCubit(repository);
      await pumpEventQueue();

      await cubit.setSource(null);

      // Still just the one call from the initial load -- setSource(null)
      // never asked the repository again.
      verify(() => repository.listPendingTopics(source: null)).called(1);
    });

    test(
      'a slower earlier fetch resolving late never overwrites a newer one',
      () async {
        final practiceCompleter = Completer<Result<List<ErrorTopic>>>();
        when(
          () => repository.listPendingTopics(source: null),
        ).thenAnswer((_) => practiceCompleter.future);
        when(
          () => repository.listPendingTopics(source: 'mock_exam'),
        ).thenAnswer((_) async => const Success(<ErrorTopic>[]));
        final cubit = ErrorReviewCubit(repository);

        // The initial load (source: null) is still in flight when the tab
        // is switched -- nothing cancels it.
        await cubit.setSource('mock_exam');
        expect(
          cubit.state,
          const ErrorReviewLoaded(<ErrorTopic>[], 'mock_exam'),
        );

        // It finally resolves after the newer one already settled -- its
        // (now stale) result must be ignored, not flip the screen back to
        // "Tudo" with data for a tab the person already left.
        practiceCompleter.complete(const Success(topics));
        await pumpEventQueue();

        expect(
          cubit.state,
          const ErrorReviewLoaded(<ErrorTopic>[], 'mock_exam'),
        );
      },
    );
  });
}

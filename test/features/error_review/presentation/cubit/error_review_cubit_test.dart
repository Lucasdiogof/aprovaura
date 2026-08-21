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
          () => repository.listPendingTopics(),
        ).thenAnswer((_) async => const Success(topics));
        final cubit = ErrorReviewCubit(repository);

        await pumpEventQueue();

        expect(cubit.state, const ErrorReviewLoaded(topics));
      },
    );

    test('settles on $ErrorReviewError when loading fails', () async {
      when(
        () => repository.listPendingTopics(),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));
      final cubit = ErrorReviewCubit(repository);

      await pumpEventQueue();

      expect(cubit.state, const ErrorReviewError('boom'));
    });

    blocTest<ErrorReviewCubit, ErrorReviewState>(
      'refresh() reloads without an intermediate $ErrorReviewLoading state',
      build: () {
        var call = 0;
        when(() => repository.listPendingTopics()).thenAnswer((_) async {
          call++;
          return Success(call == 1 ? topics : const <ErrorTopic>[]);
        });
        return ErrorReviewCubit(repository);
      },
      act: (cubit) => cubit.refresh(),
      skip: 1,
      expect: () => [const ErrorReviewLoaded(<ErrorTopic>[])],
    );
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/favorites/domain/entities/favorite_question.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/favorites/presentation/cubit/favorite_questions_cubit.dart';
import 'package:aura/features/favorites/presentation/cubit/favorite_questions_state.dart';
import 'package:aura/features/questions/domain/entities/question.dart';

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group(FavoriteQuestionsCubit, () {
    late FavoritesRepository repository;

    const question = Question(
      id: 'q1',
      prompt: 'Qual é o maior lago da África?',
      options: ['Vitória', 'Tanganica', 'Malawi', 'Chade'],
      correctIndex: 0,
    );
    const wrong = [
      FavoriteQuestion(
        question: question,
        status: FavoriteQuestionStatus.needsReview,
      ),
    ];
    const fixed = [
      FavoriteQuestion(
        question: question,
        status: FavoriteQuestionStatus.correct,
      ),
    ];

    setUp(() {
      repository = _MockFavoritesRepository();
    });

    test('loads the favorited questions of the given topic', () async {
      when(
        () => repository.listFavoriteQuestions('lagos'),
      ).thenAnswer((_) async => const Success(wrong));
      final cubit = FavoriteQuestionsCubit(repository, catalogNodeId: 'lagos');

      await pumpEventQueue();

      expect(cubit.state, const FavoriteQuestionsLoaded(wrong));
      verify(() => repository.listFavoriteQuestions('lagos')).called(1);
    });

    test('settles on $FavoriteQuestionsError when loading fails', () async {
      when(
        () => repository.listFavoriteQuestions(any()),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));
      final cubit = FavoriteQuestionsCubit(repository, catalogNodeId: 'lagos');

      await pumpEventQueue();

      expect(cubit.state, const FavoriteQuestionsError('boom'));
    });

    blocTest<FavoriteQuestionsCubit, FavoriteQuestionsState>(
      'refresh() picks up a status change without a loading flash',
      build: () {
        var call = 0;
        when(() => repository.listFavoriteQuestions(any())).thenAnswer((
          _,
        ) async {
          call++;
          return Success(call == 1 ? wrong : fixed);
        });
        return FavoriteQuestionsCubit(repository, catalogNodeId: 'lagos');
      },
      act: (cubit) => cubit.refresh(),
      skip: 1,
      expect: () => [const FavoriteQuestionsLoaded(fixed)],
    );
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_cubit.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_state.dart';

class _MockQuestionRepository extends Mock implements QuestionRepository {}

class _MockProgressRepository extends Mock implements ProgressRepository {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group(MultipleChoiceCubit, () {
    late QuestionRepository questionRepository;
    late ProgressRepository progressRepository;
    late FavoritesRepository favoritesRepository;

    const questionA = Question(
      id: 'q1',
      prompt: 'Capital da França?',
      options: ['Paris', 'Londres', 'Roma', 'Berlim'],
      correctIndex: 0,
    );
    const questionB = Question(
      id: 'q2',
      prompt: 'Capital do Japão?',
      options: ['Pequim', 'Tóquio', 'Seul', 'Bangkok'],
      correctIndex: 1,
    );
    const questions = [questionA, questionB];

    setUp(() {
      questionRepository = _MockQuestionRepository();
      progressRepository = _MockProgressRepository();
      favoritesRepository = _MockFavoritesRepository();
      when(
        () => progressRepository.registerQuestionAnswered(
          questionId: any(named: 'questionId'),
          isCorrect: any(named: 'isCorrect'),
        ),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => favoritesRepository.getFavoriteQuestionIds(any()),
      ).thenAnswer((_) async => const Success(<String>{}));
      when(
        () => favoritesRepository.addFavorite(any()),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => favoritesRepository.removeFavorite(any()),
      ).thenAnswer((_) async => const Success(null));
    });

    MultipleChoiceCubit buildCubit({bool trackProgress = true}) =>
        MultipleChoiceCubit(
          questionRepository,
          progressRepository,
          favoritesRepository,
          catalogNodeId: 'node-1',
          trackProgress: trackProgress,
        );

    test(
      'settles on $MultipleChoiceEmpty when there are no questions',
      () async {
        when(
          () => questionRepository.getQuestions(
            any(),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => const Success(<Question>[]));
        final cubit = buildCubit();

        await pumpEventQueue();

        expect(cubit.state, const MultipleChoiceEmpty());
      },
    );

    test('settles on $MultipleChoiceError when loading fails', () async {
      when(
        () => questionRepository.getQuestions(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));
      final cubit = buildCubit();

      await pumpEventQueue();

      expect(cubit.state, const MultipleChoiceError('boom'));
    });

    test('settles on $MultipleChoicePlaying with shuffled options that keep '
        'the correct answer text intact', () async {
      when(
        () => questionRepository.getQuestions(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => const Success(questions));
      final cubit = buildCubit();

      await pumpEventQueue();

      final state = cubit.state as MultipleChoicePlaying;
      expect(state.questions, hasLength(2));
      expect(state.currentIndex, 0);
      expect(state.correctCount, 0);
      for (final question in state.questions) {
        final original = questions.firstWhere((q) => q.id == question.id);
        expect(
          question.options[question.correctIndex],
          original.options[original.correctIndex],
        );
        expect(question.options.toSet(), original.options.toSet());
      }
    });

    test('loads favorite question ids when trackProgress is true', () async {
      when(
        () => questionRepository.getQuestions(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => const Success(questions));
      when(
        () => favoritesRepository.getFavoriteQuestionIds(any()),
      ).thenAnswer((_) async => const Success({'q1'}));
      final cubit = buildCubit();

      await pumpEventQueue();

      final state = cubit.state as MultipleChoicePlaying;
      expect(state.favoriteQuestionIds, {'q1'});
    });

    test('skips loading favorite ids when trackProgress is false', () async {
      when(
        () => questionRepository.getQuestions(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => const Success(questions));
      final cubit = buildCubit(trackProgress: false);

      await pumpEventQueue();

      final state = cubit.state as MultipleChoicePlaying;
      expect(state.favoriteQuestionIds, isEmpty);
      verifyNever(() => favoritesRepository.getFavoriteQuestionIds(any()));
    });

    group('selectOption', () {
      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'records the chosen index and increments correctCount on a correct '
        'answer, and reports it to the progress repository',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          final state = cubit.state as MultipleChoicePlaying;
          cubit.selectOption(state.currentQuestion.correctIndex);
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.hasAnswered, isTrue);
          expect(state.correctCount, 1);
          verify(
            () => progressRepository.registerQuestionAnswered(
              questionId: state.currentQuestion.id,
              isCorrect: true,
            ),
          ).called(1);
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'records the chosen index without incrementing correctCount on a '
        'wrong answer',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          final state = cubit.state as MultipleChoicePlaying;
          final wrongIndex = (state.currentQuestion.correctIndex + 1) % 4;
          cubit.selectOption(wrongIndex);
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.hasAnswered, isTrue);
          expect(state.correctCount, 0);
          verify(
            () => progressRepository.registerQuestionAnswered(
              questionId: any(named: 'questionId'),
              isCorrect: false,
            ),
          ).called(1);
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'does nothing when the current question has already been answered',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          final state = cubit.state as MultipleChoicePlaying;
          final correct = state.currentQuestion.correctIndex;
          cubit.selectOption(correct);
          cubit.selectOption((correct + 1) % 4);
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.correctCount, 1);
          verify(
            () => progressRepository.registerQuestionAnswered(
              questionId: any(named: 'questionId'),
              isCorrect: any(named: 'isCorrect'),
            ),
          ).called(1);
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'does not call the progress repository when trackProgress is false',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit(trackProgress: false);
        },
        act: (cubit) async {
          await pumpEventQueue();
          final state = cubit.state as MultipleChoicePlaying;
          cubit.selectOption(state.currentQuestion.correctIndex);
        },
        verify: (_) {
          verifyNever(
            () => progressRepository.registerQuestionAnswered(
              questionId: any(named: 'questionId'),
              isCorrect: any(named: 'isCorrect'),
            ),
          );
        },
      );
    });

    group('next / previous', () {
      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'next() does nothing until the current question is answered',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          cubit.next();
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.currentIndex, 0);
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'next() moves to the next question once answered',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          final state = cubit.state as MultipleChoicePlaying;
          cubit.selectOption(state.currentQuestion.correctIndex);
          cubit.next();
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.currentIndex, 1);
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'next() on the last answered question emits $MultipleChoiceFinished',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success([questionA]));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          final state = cubit.state as MultipleChoicePlaying;
          cubit.selectOption(state.currentQuestion.correctIndex);
          cubit.next();
        },
        verify: (cubit) {
          expect(
            cubit.state,
            const MultipleChoiceFinished(correctCount: 1, totalCount: 1),
          );
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'previous() moves back to the earlier question, keeping its answer',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          final first = cubit.state as MultipleChoicePlaying;
          cubit.selectOption(first.currentQuestion.correctIndex);
          cubit.next();
          cubit.previous();
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.currentIndex, 0);
          expect(state.hasAnswered, isTrue);
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'previous() does nothing on the first question',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          cubit.previous();
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.currentIndex, 0);
        },
      );
    });

    group('toggleFavorite', () {
      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'adds the current question to favorites when not yet favorited',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          cubit.toggleFavorite();
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.isCurrentFavorited, isTrue);
          verify(
            () => favoritesRepository.addFavorite(state.currentQuestion.id),
          ).called(1);
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'removes the current question from favorites when already favorited',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          when(
            () => favoritesRepository.getFavoriteQuestionIds(any()),
          ).thenAnswer((_) async => const Success({'q1'}));
          return buildCubit();
        },
        act: (cubit) async {
          await pumpEventQueue();
          cubit.toggleFavorite();
        },
        verify: (cubit) {
          final state = cubit.state as MultipleChoicePlaying;
          expect(state.isCurrentFavorited, isFalse);
          verify(() => favoritesRepository.removeFavorite('q1')).called(1);
        },
      );

      blocTest<MultipleChoiceCubit, MultipleChoiceState>(
        'does nothing when trackProgress is false',
        build: () {
          when(
            () => questionRepository.getQuestions(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(questions));
          return buildCubit(trackProgress: false);
        },
        act: (cubit) async {
          await pumpEventQueue();
          cubit.toggleFavorite();
        },
        verify: (_) {
          verifyNever(() => favoritesRepository.addFavorite(any()));
        },
      );
    });
  });
}

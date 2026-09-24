import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/essay_failure.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_submission_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_submission_state.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

EssaySubmission _submission(EssaySubmissionStatus status, {int? score}) =>
    EssaySubmission(
      id: 's1',
      themeId: 't1',
      themeTitle: 'Tema',
      body: 'Texto da redação.',
      wordCount: 3,
      status: status,
      submittedAt: DateTime(2026, 9, 24),
      totalScore: score,
    );

void main() {
  late EssayRepository repository;

  setUp(() {
    repository = _MockEssayRepository();
    when(
      () => repository.requestEvaluation(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  /// Each call returns the next status, so a test can describe a marking
  /// that finishes between polls.
  void stubStatuses(List<EssaySubmission> sequence) {
    var index = 0;
    when(() => repository.getSubmission('s1')).thenAnswer((_) async {
      final value = sequence[index.clamp(0, sequence.length - 1)];
      index++;
      return Success(value);
    });
  }

  EssaySubmissionCubit build() => EssaySubmissionCubit(
    repository,
    's1',
    pollInterval: const Duration(milliseconds: 20),
    maxPolls: 5,
  );

  group(EssaySubmissionCubit, () {
    test('an attempt nobody picked up gets its marking asked for', () async {
      stubStatuses([
        _submission(EssaySubmissionStatus.submitted),
        _submission(EssaySubmissionStatus.evaluating),
        _submission(EssaySubmissionStatus.evaluated, score: 900),
      ]);
      final cubit = build();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // This is the resume path: closing the app between sending and
      // marking must not leave the attempt stuck forever.
      verify(() => repository.requestEvaluation('s1')).called(1);
      final state = cubit.state as EssaySubmissionLoaded;
      expect(state.submission.status, EssaySubmissionStatus.evaluated);
      expect(state.submission.totalScore, 900);
      await cubit.close();
    });

    test('an attempt already marked is never sent again', () async {
      stubStatuses([_submission(EssaySubmissionStatus.evaluated, score: 880)]);
      final cubit = build();
      await Future<void>.delayed(const Duration(milliseconds: 120));

      verifyNever(() => repository.requestEvaluation(any()));
      await cubit.close();
    });

    test('polling stops once the attempt reaches a final state', () async {
      stubStatuses([
        _submission(EssaySubmissionStatus.evaluating),
        _submission(EssaySubmissionStatus.evaluating),
        _submission(EssaySubmissionStatus.evaluated, score: 700),
      ]);
      final cubit = build();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      // Consumes everything read so far; mocktail resets the log here.
      verify(() => repository.getSubmission('s1')).called(greaterThan(1));

      await Future<void>.delayed(const Duration(milliseconds: 150));
      // Nothing new: the result arrived, so the watching stopped.
      verifyNever(() => repository.getSubmission('s1'));
      await cubit.close();
    });

    test('it gives up watching instead of polling forever', () async {
      stubStatuses([_submission(EssaySubmissionStatus.evaluating)]);
      final cubit = build();
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(cubit.gaveUpWaiting, isTrue);
      // One read on open plus at most maxPolls while watching.
      verify(() => repository.getSubmission('s1')).called(lessThan(8));
      await cubit.close();
    });

    test('the daily limit surfaces as itself, not a generic error', () async {
      stubStatuses([_submission(EssaySubmissionStatus.submitted)]);
      when(() => repository.requestEvaluation('s1')).thenAnswer(
        (_) async => const Error(
          EssayEvaluationFailureWrapper(
            EssayEvaluationFailure.dailyLimitReached,
          ),
        ),
      );

      final cubit = build();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final state = cubit.state as EssaySubmissionLoaded;
      expect(state.failure, EssayEvaluationFailure.dailyLimitReached);
      // The attempt itself is untouched -- only the marking did not run.
      expect(state.submission.status, EssaySubmissionStatus.submitted);
      await cubit.close();
    });

    test('a retry after failure asks again', () async {
      stubStatuses([_submission(EssaySubmissionStatus.failed)]);
      final cubit = build();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Nothing automatic for a failed attempt: retrying is the person's
      // call, since it may cost a marking.
      verifyNever(() => repository.requestEvaluation(any()));

      await cubit.requestEvaluation();
      verify(() => repository.requestEvaluation('s1')).called(1);
      await cubit.close();
    });

    test('a second request while one is in flight is ignored', () async {
      stubStatuses([_submission(EssaySubmissionStatus.failed)]);
      final cubit = build();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await Future.wait([cubit.requestEvaluation(), cubit.requestEvaluation()]);

      verify(() => repository.requestEvaluation('s1')).called(1);
      await cubit.close();
    });

    test('a failed read shows an error instead of a blank attempt', () async {
      when(() => repository.getSubmission('s1')).thenAnswer(
        (_) async => const Error(
          EssayEvaluationFailureWrapper(EssayEvaluationFailure.unexpected),
        ),
      );
      final cubit = build();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(cubit.state, isA<EssaySubmissionError>());
      await cubit.close();
    });
  });
}

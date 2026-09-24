import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_draft.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_state.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

/// Comfortably past the debounce, so a test that waits this long is
/// asserting about what autosave did, not about timer slop.
final _afterDebounce =
    EssayEditorCubit.debounce + const Duration(milliseconds: 300);

final _attempt = EssayAttempt(
  id: 's1',
  status: EssaySubmissionStatus.submitted,
  wordCount: 0,
  submittedAt: DateTime(2026, 9, 24),
);

void main() {
  late EssayRepository repository;

  setUp(() {
    repository = _MockEssayRepository();
    when(
      () => repository.saveDraft(any(), any()),
    ).thenAnswer((_) async => Success(DateTime(2026, 9, 24)));
    when(
      () => repository.deleteDraft(any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repository.submitDraft(
        themeId: any(named: 'themeId'),
        clientRequestId: any(named: 'clientRequestId'),
      ),
    ).thenAnswer((_) async => Success(_attempt));
  });

  void stubDraft(EssayDraft? draft) {
    when(
      () => repository.getDraft('t1'),
    ).thenAnswer((_) async => Success(draft));
  }

  group('$EssayEditorCubit opening', () {
    blocTest<EssayEditorCubit, EssayEditorState>(
      'with no draft starts empty and offers nothing to delete',
      build: () {
        stubDraft(null);
        return EssayEditorCubit(repository, 't1');
      },
      expect: () => [
        const EssayEditorReady(initialBody: '', hasSavedDraft: false),
      ],
    );

    blocTest<EssayEditorCubit, EssayEditorState>(
      'restores the saved text',
      build: () {
        stubDraft(
          EssayDraft(body: 'Texto salvo ontem', updatedAt: DateTime(2026)),
        );
        return EssayEditorCubit(repository, 't1');
      },
      expect: () => [
        const EssayEditorReady(
          initialBody: 'Texto salvo ontem',
          hasSavedDraft: true,
        ),
      ],
    );

    blocTest<EssayEditorCubit, EssayEditorState>(
      'a failed load does not offer an editor over an unknown draft',
      build: () {
        when(
          () => repository.getDraft('t1'),
        ).thenAnswer((_) async => Error(ServerFailure()));
        return EssayEditorCubit(repository, 't1');
      },
      expect: () => [const EssayEditorLoadFailed()],
    );
  });

  group('$EssayEditorCubit autosave', () {
    blocTest<EssayEditorCubit, EssayEditorState>(
      'waits for the pause instead of saving every keystroke',
      build: () {
        stubDraft(null);
        return EssayEditorCubit(repository, 't1');
      },
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        cubit.textChanged('A');
        cubit.textChanged('AB');
        cubit.textChanged('ABC');
      },
      verify: (_) {
        verifyNever(() => repository.saveDraft(any(), any()));
      },
    );

    blocTest<EssayEditorCubit, EssayEditorState>(
      'saves once, with the last thing typed',
      build: () {
        stubDraft(null);
        return EssayEditorCubit(repository, 't1');
      },
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        cubit.textChanged('A');
        cubit.textChanged('AB');
        cubit.textChanged('ABC');
        await Future<void>.delayed(_afterDebounce);
      },
      verify: (_) {
        verify(() => repository.saveDraft('t1', 'ABC')).called(1);
        verifyNever(() => repository.saveDraft('t1', 'A'));
        verifyNever(() => repository.saveDraft('t1', 'AB'));
      },
    );

    test('a slow save never lands on top of newer text', () async {
      stubDraft(null);
      // "A" takes a long time; "ABC" is typed while it is still in flight.
      final slow = Completer<Result<DateTime?>>();
      when(
        () => repository.saveDraft('t1', 'A'),
      ).thenAnswer((_) => slow.future);

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      cubit.textChanged('A');
      await Future<void>.delayed(_afterDebounce);
      cubit.textChanged('ABC');

      slow.complete(Success(DateTime(2026)));
      await Future<void>.delayed(_afterDebounce);

      // The newer text was written after the slow one returned, so the
      // server ends holding ABC -- not the stale A.
      verifyInOrder([
        () => repository.saveDraft('t1', 'A'),
        () => repository.saveDraft('t1', 'ABC'),
      ]);
      expect(cubit.hasUnsavedChanges, isFalse);
      final state = cubit.state as EssayEditorReady;
      expect(state.status, EssaySaveStatus.saved);
      await cubit.close();
    });

    test(
      'clearing the text deletes the draft instead of saving a blank one',
      () async {
        stubDraft(EssayDraft(body: 'algo', updatedAt: DateTime(2026)));
        final cubit = EssayEditorCubit(repository, 't1');
        await Future<void>.delayed(const Duration(milliseconds: 10));

        cubit.textChanged('');
        await Future<void>.delayed(_afterDebounce);

        // save_essay_draft deletes on blank text, which is why the cubit can
        // treat this as an ordinary save.
        verify(() => repository.saveDraft('t1', '')).called(1);
        expect((cubit.state as EssayEditorReady).hasSavedDraft, isFalse);
        await cubit.close();
      },
    );

    test('a failed save keeps the text and says so', () async {
      stubDraft(null);
      when(
        () => repository.saveDraft('t1', 'Texto'),
      ).thenAnswer((_) async => Error(ServerFailure()));

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.textChanged('Texto');
      await Future<void>.delayed(_afterDebounce);

      expect((cubit.state as EssayEditorReady).status, EssaySaveStatus.failed);
      // Still pending: nothing was thrown away, and the next attempt will
      // carry the same text.
      expect(cubit.hasUnsavedChanges, isTrue);

      when(
        () => repository.saveDraft('t1', 'Texto'),
      ).thenAnswer((_) async => Success(DateTime(2026)));
      await cubit.retrySave();

      expect((cubit.state as EssayEditorReady).status, EssaySaveStatus.saved);
      expect(cubit.hasUnsavedChanges, isFalse);
      await cubit.close();
    });
  });

  group('$EssayEditorCubit saveNow', () {
    test('flushes immediately, without waiting out the debounce', () async {
      stubDraft(null);
      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      cubit.textChanged('Texto novo');
      expect(await cubit.saveNow(), isTrue);

      verify(() => repository.saveDraft('t1', 'Texto novo')).called(1);
      await cubit.close();
    });

    test(
      'with nothing pending it succeeds without touching the server',
      () async {
        stubDraft(EssayDraft(body: 'igual', updatedAt: DateTime(2026)));
        final cubit = EssayEditorCubit(repository, 't1');
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(await cubit.saveNow(), isTrue);
        verifyNever(() => repository.saveDraft(any(), any()));
        await cubit.close();
      },
    );

    test('waits out a save already in flight instead of giving up', () async {
      stubDraft(null);
      // The autosave of "A" is still running when the person hits send or
      // walks out of the screen.
      final slow = Completer<Result<DateTime?>>();
      when(
        () => repository.saveDraft('t1', 'A'),
      ).thenAnswer((_) => slow.future);

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.textChanged('A');
      await Future<void>.delayed(_afterDebounce);

      final flush = cubit.saveNow();
      slow.complete(Success(DateTime(2026)));

      // The text was on its way to the server the whole time: saying "not
      // saved" here would warn about losing something that was not lost.
      expect(await flush, isTrue);
      expect(cubit.hasUnsavedChanges, isFalse);
      await cubit.close();
    });

    test('waits for the follow-up save of text typed mid-request', () async {
      stubDraft(null);
      final slow = Completer<Result<DateTime?>>();
      when(
        () => repository.saveDraft('t1', 'A'),
      ).thenAnswer((_) => slow.future);

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.textChanged('A');
      await Future<void>.delayed(_afterDebounce);
      // Newer text arrives while "A" is still in flight, so the cubit owes
      // a second save after the first returns.
      cubit.textChanged('AB');

      final flush = cubit.saveNow();
      slow.complete(Success(DateTime(2026)));

      expect(await flush, isTrue);
      verify(() => repository.saveDraft('t1', 'AB')).called(1);
      expect(cubit.hasUnsavedChanges, isFalse);
      await cubit.close();
    });

    test('an in-flight save that fails is reported as a failure', () async {
      stubDraft(null);
      final slow = Completer<Result<DateTime?>>();
      when(
        () => repository.saveDraft('t1', 'A'),
      ).thenAnswer((_) => slow.future);

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.textChanged('A');
      await Future<void>.delayed(_afterDebounce);

      final flush = cubit.saveNow();
      slow.complete(Error(ServerFailure()));

      // Waiting for the in-flight save must not turn a failure into a
      // "saved": the retry loop would try again and also fail.
      when(
        () => repository.saveDraft('t1', 'A'),
      ).thenAnswer((_) async => Error(ServerFailure()));
      expect(await flush, isFalse);
      expect(cubit.hasUnsavedChanges, isTrue);
      await cubit.close();
    });

    test('reports failure instead of pretending the text is safe', () async {
      stubDraft(null);
      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Error(ServerFailure()));

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.textChanged('Texto');

      expect(await cubit.saveNow(), isFalse);
      expect(cubit.hasUnsavedChanges, isTrue);
      await cubit.close();
    });
  });

  group('$EssayEditorCubit deleteDraft', () {
    test('clears everything once the server confirms', () async {
      stubDraft(EssayDraft(body: 'texto', updatedAt: DateTime(2026)));
      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(await cubit.deleteDraft(), isTrue);
      final state = cubit.state as EssayEditorReady;
      expect(state.hasSavedDraft, isFalse);
      expect(state.isDeleting, isFalse);
      expect(cubit.hasUnsavedChanges, isFalse);
      await cubit.close();
    });

    test('a failure leaves the draft exactly where it was', () async {
      stubDraft(EssayDraft(body: 'texto', updatedAt: DateTime(2026)));
      when(
        () => repository.deleteDraft(any()),
      ).thenAnswer((_) async => Error(ServerFailure()));

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(await cubit.deleteDraft(), isFalse);
      final state = cubit.state as EssayEditorReady;
      expect(state.hasSavedDraft, isTrue);
      expect(state.isDeleting, isFalse);
      await cubit.close();
    });

    test('a second tap while deleting does nothing', () async {
      stubDraft(EssayDraft(body: 'texto', updatedAt: DateTime(2026)));
      final gate = Completer<Result<void>>();
      when(() => repository.deleteDraft(any())).thenAnswer((_) => gate.future);

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final first = cubit.deleteDraft();
      expect(await cubit.deleteDraft(), isFalse);

      gate.complete(const Success(null));
      expect(await first, isTrue);
      verify(() => repository.deleteDraft('t1')).called(1);
      await cubit.close();
    });
  });

  group('$EssayEditorCubit submit', () {
    test('flushes the pending text before freezing it', () async {
      stubDraft(EssayDraft(body: 'versão antiga', updatedAt: DateTime(2026)));
      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      cubit.textChanged('versão nova');
      expect(await cubit.submit(), EssaySubmitOutcome.submitted);

      // The save happens first: freezing an older version than what is on
      // screen would be the worst possible outcome here.
      verifyInOrder([
        () => repository.saveDraft('t1', 'versão nova'),
        () => repository.submitDraft(
          themeId: 't1',
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ]);
      await cubit.close();
    });

    test('a failed flush stops the submit entirely', () async {
      stubDraft(EssayDraft(body: 'antigo', updatedAt: DateTime(2026)));
      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Error(ServerFailure()));

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.textChanged('novo');

      expect(await cubit.submit(), EssaySubmitOutcome.saveFailed);
      verifyNever(
        () => repository.submitDraft(
          themeId: any(named: 'themeId'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      );
      await cubit.close();
    });

    test(
      'two taps send one request id, so the server sees one attempt',
      () async {
        stubDraft(EssayDraft(body: 'texto', updatedAt: DateTime(2026)));
        var generated = 0;
        final cubit = EssayEditorCubit(
          repository,
          't1',
          requestIdGenerator: () => 'req-${++generated}',
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final first = cubit.submit();
        final second = cubit.submit();
        await Future.wait([first, second]);

        // The second tap is refused while the first is in flight, and any
        // later retry reuses the same id -- the server recognises it.
        verify(
          () => repository.submitDraft(themeId: 't1', clientRequestId: 'req-1'),
        ).called(1);
        expect(generated, 1);
        await cubit.close();
      },
    );

    test('a retry after failure reuses the same request id', () async {
      stubDraft(EssayDraft(body: 'texto', updatedAt: DateTime(2026)));
      when(
        () => repository.submitDraft(
          themeId: any(named: 'themeId'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer((_) async => Error(ServerFailure()));

      final cubit = EssayEditorCubit(
        repository,
        't1',
        requestIdGenerator: () => 'req-fixo',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(await cubit.submit(), EssaySubmitOutcome.submitFailed);
      // The draft is untouched, so trying again is safe.
      expect((cubit.state as EssayEditorReady).hasSavedDraft, isTrue);

      when(
        () => repository.submitDraft(
          themeId: any(named: 'themeId'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer((_) async => Success(_attempt));
      expect(await cubit.submit(), EssaySubmitOutcome.submitted);

      verify(
        () =>
            repository.submitDraft(themeId: 't1', clientRequestId: 'req-fixo'),
      ).called(2);
      await cubit.close();
    });

    test('after submitting there is no draft left to delete', () async {
      stubDraft(EssayDraft(body: 'texto', updatedAt: DateTime(2026)));
      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await cubit.submit();

      final state = cubit.state as EssayEditorReady;
      expect(state.hasSavedDraft, isFalse);
      expect(cubit.submittedAttempt?.id, 's1');
      await cubit.close();
    });
  });
}

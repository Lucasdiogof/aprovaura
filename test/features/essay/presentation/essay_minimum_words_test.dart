import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/essay_failure.dart';
import 'package:aura/features/essay/domain/essay_rules.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_state.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';

import '../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

const _theme = EssayTheme(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  prompt: 'Redija um texto dissertativo-argumentativo sobre o tema.',
  origin: EssayThemeOrigin.practice(),
  supportingTexts: [],
);

/// Exactly [count] words, so the boundary can be walked one word at a time.
String _words(int count) =>
    List.generate(count, (i) => 'palavra${i + 1}').join(' ');

Future<void> _settleAutosave(WidgetTester tester) =>
    tester.pumpAndSettle(EssayEditorCubit.debounce * 2);

ElevatedButton _sendButton(WidgetTester tester) =>
    tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Enviar para correção'),
    );

/// The minimum lives in the database (`essay_min_word_count()`); these
/// tests are about the screen agreeing with it, and about what happens if
/// it ever does not.
void main() {
  late EssayRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => repository);
    when(
      () => repository.getDraft('t1'),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repository.saveDraft(any(), any()),
    ).thenAnswer((_) async => Success(DateTime(2026, 9, 24)));
    when(
      () => repository.submitDraft(
        themeId: any(named: 'themeId'),
        clientRequestId: any(named: 'clientRequestId'),
      ),
    ).thenAnswer(
      (_) async => Success(
        EssayAttempt(
          id: 's1',
          status: EssaySubmissionStatus.submitted,
          wordCount: EssayRules.minimumWords,
          submittedAt: DateTime(2026, 9, 24),
        ),
      ),
    );
  });

  Future<void> open(WidgetTester tester, String text) async {
    await tester.pumpApp(const EssayEditorPage(theme: _theme));
    await tester.pumpAndSettle();
    if (text.isNotEmpty) {
      await tester.enterText(find.byType(TextField), text);
      await _settleAutosave(tester);
    }
  }

  group('the counter', () {
    testWidgets('an empty editor already shows what it is counting towards', (
      tester,
    ) async {
      await open(tester, '');

      expect(find.text('0 / 50 palavras'), findsOneWidget);
      expect(find.text('Mínimo de 50 palavras para enviar.'), findsOneWidget);
    });

    testWidgets('one word short still shows the target', (tester) async {
      await open(tester, _words(EssayRules.minimumWords - 1));

      expect(find.text('49 / 50 palavras'), findsOneWidget);
      expect(find.text('Mínimo de 50 palavras para enviar.'), findsOneWidget);
    });

    testWidgets('at the minimum the target goes away', (tester) async {
      await open(tester, _words(EssayRules.minimumWords));

      // Once the floor is behind, "/ 50" would read like a quota.
      expect(find.text('50 palavras'), findsOneWidget);
      expect(find.text('Mínimo de 50 palavras para enviar.'), findsNothing);
    });

    testWidgets('past the minimum it is just a count', (tester) async {
      await open(tester, _words(87));

      expect(find.text('87 palavras'), findsOneWidget);
      expect(find.textContaining('Mínimo de'), findsNothing);
    });
  });

  group('the send button', () {
    testWidgets('is disabled with nothing written', (tester) async {
      await open(tester, '');
      expect(_sendButton(tester).onPressed, isNull);
    });

    testWidgets('is disabled one word short', (tester) async {
      await open(tester, _words(EssayRules.minimumWords - 1));
      expect(_sendButton(tester).onPressed, isNull);
    });

    testWidgets('turns on exactly at the minimum', (tester) async {
      await open(tester, _words(EssayRules.minimumWords));
      expect(_sendButton(tester).onPressed, isNotNull);
    });

    testWidgets('a short text never even opens the confirmation', (
      tester,
    ) async {
      await open(tester, _words(10));

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Enviar para correção'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enviar redação para correção?'), findsNothing);
      verifyNever(
        () => repository.submitDraft(
          themeId: any(named: 'themeId'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      );
    });
  });

  group('the server refusing anyway', () {
    testWidgets('says why, and the text stays where it was', (tester) async {
      // The screen let it through; the server still says no. It is the one
      // that decides, so the app repeats its reason instead of shrugging.
      when(
        () => repository.submitDraft(
          themeId: any(named: 'themeId'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer(
        (_) async => const Error(
          EssaySubmitFailure(EssaySubmitFailureKind.textTooShort),
        ),
      );

      final text = _words(EssayRules.minimumWords);
      await open(tester, text);

      await tester.tap(find.text('Enviar para correção'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar redação'));
      await tester.pumpAndSettle();

      expect(find.textContaining('pelo menos 50 palavras'), findsOneWidget);

      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();

      // Still in the editor, with every word of it.
      expect(find.byType(EssayEditorPage), findsOneWidget);
      expect(find.text(text), findsOneWidget);
      verifyNever(() => repository.deleteDraft(any()));
    });
  });

  group(EssayRules, () {
    test('counts words the way the database does', () {
      expect(EssayRules.wordsIn(''), 0);
      expect(EssayRules.wordsIn('   '), 0);
      expect(EssayRules.wordsIn('uma'), 1);
      // Line breaks, tabs and double spaces are all just separators there.
      expect(EssayRules.wordsIn('uma  duas\ttrês\n\nquatro'), 4);
      expect(EssayRules.wordsIn('  cinco seis  '), 2);
    });

    test('the floor is the same number the server enforces', () {
      // essay_min_word_count() in supabase/essays.sql.
      expect(EssayRules.minimumWords, 50);
      expect(EssayRules.isLongEnough(_words(49)), isFalse);
      expect(EssayRules.isLongEnough(_words(50)), isTrue);
    });
  });

  group('$EssayEditorCubit', () {
    test('a short-text refusal comes back as itself', () async {
      when(
        () => repository.submitDraft(
          themeId: any(named: 'themeId'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer(
        (_) async => const Error(
          EssaySubmitFailure(EssaySubmitFailureKind.textTooShort),
        ),
      );

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.textChanged(_words(60));

      expect(await cubit.submit(), EssaySubmitOutcome.textTooShort);
      // The draft was saved and left alone: nothing was frozen.
      verify(() => repository.saveDraft('t1', any())).called(1);
      verifyNever(() => repository.deleteDraft(any()));
      await cubit.close();
    });

    test('any other refusal stays generic', () async {
      when(
        () => repository.submitDraft(
          themeId: any(named: 'themeId'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer(
        (_) async =>
            const Error(EssaySubmitFailure(EssaySubmitFailureKind.unexpected)),
      );

      final cubit = EssayEditorCubit(repository, 't1');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.textChanged(_words(60));

      expect(await cubit.submit(), EssaySubmitOutcome.submitFailed);
      await cubit.close();
    });
  });

  group(EssaySubmitFailure, () {
    test('maps the codes submit_essay_draft actually raises', () {
      expect(
        EssaySubmitFailure.fromCode('P0003').kind,
        EssaySubmitFailureKind.textTooShort,
      );
      expect(
        EssaySubmitFailure.fromCode('P0002').kind,
        EssaySubmitFailureKind.noDraft,
      );
      // An unknown code is not guessed at.
      expect(
        EssaySubmitFailure.fromCode('42P01').kind,
        EssaySubmitFailureKind.unexpected,
      );
      expect(
        EssaySubmitFailure.fromCode(null).kind,
        EssaySubmitFailureKind.unexpected,
      );
    });
  });
}

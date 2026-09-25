import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_session_info.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_result_page.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_session_page.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

import '../../../../helpers/pump_app.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

const _examId = 'e1';

MockExamItem _item(int position, {String? prompt, List<String>? options}) =>
    MockExamItem(
      position: position,
      questionId: 'q$position',
      subject: 'geografia',
      difficulty: QuestionDifficulty.dificil,
      prompt: prompt ?? 'Qual é a capital da região $position?',
      options: options ?? const ['Opção um', 'Opção dois', 'Opção três'],
    );

void main() {
  late MockExamRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockMockExamRepository();
    sl.registerLazySingleton<MockExamRepository>(() => repository);
    when(() => repository.getSession(_examId)).thenAnswer(
      (_) async =>
          const Success(MockExamSessionInfo(status: MockExamStatus.inProgress)),
    );
    when(
      () => repository.getItems(_examId),
    ).thenAnswer((_) async => Success([_item(1), _item(2), _item(3)]));
    when(
      () => repository.answerItem(
        any(),
        position: any(named: 'position'),
        selectedIndex: any(named: 'selectedIndex'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repository.setCurrentPosition(any(), any()),
    ).thenAnswer((_) async => const Success(null));
  });

  Future<void> pumpSession(WidgetTester tester) async {
    await tester.pumpApp(const MockExamSessionPage(mockExamId: _examId));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the question with progress and no grading at all', (
    tester,
  ) async {
    await pumpSession(tester);

    expect(find.text('Questão 1 de 3'), findsOneWidget);
    expect(find.text('Geografia · Difícil'), findsOneWidget);
    // No "N de M respondidas" counter: the progress line is enough.
    expect(find.textContaining('respondidas'), findsNothing);
    expect(find.text('Anterior'), findsOneWidget);
    expect(find.text('Próxima'), findsOneWidget);

    await tester.tap(find.text('Opção dois'));
    await tester.pumpAndSettle();

    // Exam mode: selecting never reveals right/wrong.
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.cancel), findsNothing);
    verify(
      () => repository.answerItem(_examId, position: 1, selectedIndex: 1),
    ).called(1);
  });

  testWidgets('Anterior and Próxima/Entregar are the same size', (
    tester,
  ) async {
    await pumpSession(tester);

    final previous = tester.getSize(find.byType(OutlinedButton));
    final next = tester.getSize(find.byType(ElevatedButton));
    expect(previous.width, closeTo(next.width, 0.5));
    expect(previous.height, closeTo(next.height, 0.5));
  });

  testWidgets('back asks before leaving and never abandons', (tester) async {
    await pumpSession(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Sair do simulado?'), findsOneWidget);
    expect(
      find.text('Seu progresso está salvo e você poderá continuar depois.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Continuar simulado'));
    await tester.pumpAndSettle();
    expect(find.text('Questão 1 de 3'), findsOneWidget);
    verifyNever(() => repository.abandonMockExam(any()));
  });

  testWidgets('abandoning is a separate, confirmed action', (tester) async {
    await pumpSession(tester);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abandonar simulado'));
    await tester.pumpAndSettle();

    expect(find.text('Abandonar simulado?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    verifyNever(() => repository.abandonMockExam(any()));
  });

  testWidgets(
    'the last question hands in; blanks are flagged with a way back',
    (tester) async {
      await pumpSession(tester);

      await tester.tap(find.text('Próxima'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Opção um'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Próxima'));
      await tester.pumpAndSettle();

      expect(find.text('Questão 3 de 3'), findsOneWidget);
      expect(find.text('Entregar'), findsOneWidget);

      await tester.tap(find.text('Entregar'));
      await tester.pumpAndSettle();
      expect(find.text('Você deixou 2 questões sem resposta.'), findsOneWidget);
      expect(find.text('Entregar assim mesmo'), findsOneWidget);

      // "Voltar e revisar" jumps to the first blank one, nothing is graded.
      await tester.tap(find.text('Voltar e revisar'));
      await tester.pumpAndSettle();
      expect(find.text('Questão 1 de 3'), findsOneWidget);
      verifyNever(() => repository.finishMockExam(any()));
    },
  );

  testWidgets('finished elsewhere: human message and a way to the result', (
    tester,
  ) async {
    when(() => repository.getSession(_examId)).thenAnswer(
      (_) async =>
          const Success(MockExamSessionInfo(status: MockExamStatus.finished)),
    );
    when(
      () => repository.getResult(_examId),
    ).thenAnswer((_) async => const Success(null));
    await pumpSession(tester);

    expect(
      find.text('Este simulado já foi entregue. Seu resultado está pronto.'),
      findsOneWidget,
    );
    expect(find.text('Próxima'), findsNothing);
    await tester.tap(find.text('Ver resultado'));
    await tester.pumpAndSettle();
    expect(find.byType(MockExamResultPage), findsOneWidget);
  });

  testWidgets('finished on another device while open: detected on tap', (
    tester,
  ) async {
    await pumpSession(tester);
    when(
      () => repository.answerItem(
        any(),
        position: any(named: 'position'),
        selectedIndex: any(named: 'selectedIndex'),
      ),
    ).thenAnswer(
      (_) async => Error(
        MockExamFailure(
          MockExamFailureKind.notInProgress,
          serverStatus: 'finished',
        ),
      ),
    );

    await tester.tap(find.text('Opção dois'));
    await tester.pumpAndSettle();

    expect(find.text('Ver resultado'), findsOneWidget);
    // Not a technical error, not "tap again".
    expect(
      find.text(
        'Não foi possível salvar sua resposta. Toque na alternativa de novo.',
      ),
      findsNothing,
    );
  });

  testWidgets('abandoned elsewhere: human message, back home', (tester) async {
    when(() => repository.getSession(_examId)).thenAnswer(
      (_) async =>
          const Success(MockExamSessionInfo(status: MockExamStatus.abandoned)),
    );
    await pumpSession(tester);

    expect(
      find.text('Este simulado foi abandonado e não pode mais ser respondido.'),
      findsOneWidget,
    );
    expect(find.text('Voltar para o início'), findsOneWidget);
  });

  testWidgets('leaving while a save is in flight waits for it, no timer', (
    tester,
  ) async {
    final save = Completer<Result<void>>();
    when(
      () => repository.answerItem(
        any(),
        position: any(named: 'position'),
        selectedIndex: any(named: 'selectedIndex'),
      ),
    ).thenAnswer((_) => save.future);
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MockExamSessionPage(mockExamId: _examId),
            ),
          ),
          child: const Text('home'),
        ),
      ),
    );
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Opção dois'));
    await tester.pump();
    // A save is in flight, so the "Salvando…" spinner never settles --
    // pump fixed frames instead of pumpAndSettle.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Sair e continuar depois'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 5));

    // Still waiting on the real call -- no timer lets it leave early.
    expect(find.text('Salvando suas respostas…'), findsOneWidget);
    expect(find.text('Sair sem esperar'), findsOneWidget);

    save.complete(const Success(null));
    await tester.pumpAndSettle();
    expect(find.byType(MockExamSessionPage), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('leaving after a failed save says it was not saved', (
    tester,
  ) async {
    when(
      () => repository.answerItem(
        any(),
        position: any(named: 'position'),
        selectedIndex: any(named: 'selectedIndex'),
      ),
    ).thenAnswer(
      (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
    );
    await pumpSession(tester);

    await tester.tap(find.text('Opção dois'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair e continuar depois'));
    await tester.pumpAndSettle();

    expect(find.text('Sua última resposta não foi salva'), findsOneWidget);
    await tester.tap(find.text('Ficar e marcar de novo'));
    await tester.pumpAndSettle();
    expect(find.byType(MockExamSessionPage), findsOneWidget);
  });

  testWidgets('long prompt and options fit 360px in dark mode', (tester) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final longText = List.filled(40, 'palavra comprida').join(' ');
    when(() => repository.getItems(_examId)).thenAnswer(
      (_) async => Success([
        _item(
          1,
          prompt: longText,
          options: [longText, longText, 'curta', longText, longText],
        ),
      ]),
    );

    await tester.pumpWidget(
      BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const MockExamSessionPage(mockExamId: _examId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('curta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('curta'));
    await tester.pumpAndSettle();
    expect(find.text('Entregar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text (1.3x) at 360px, dark: no overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
        child: MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const MockExamSessionPage(mockExamId: _examId),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Opção dois'));
    await tester.pumpAndSettle();
    expect(find.text('Próxima'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Entregar" fits half the footer at 360px, 1.3x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const MockExamSessionPage(mockExamId: _examId),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Próxima'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Entregar'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final previous = tester.getSize(find.byType(OutlinedButton));
    final submit = tester.getSize(find.byType(ElevatedButton));
    expect(previous.width, closeTo(submit.width, 0.5));
    // Same height means neither label wrapped onto a second line.
    expect(previous.height, closeTo(submit.height, 0.5));
    expect(submit.height, 52);
  });
}

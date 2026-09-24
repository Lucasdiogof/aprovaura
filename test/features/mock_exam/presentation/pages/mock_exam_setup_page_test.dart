import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_setup_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

void main() {
  group(MockExamSetupPage, () {
    late MockExamRepository repository;

    setUp(() async {
      await sl.reset();
      repository = _MockMockExamRepository();
      sl.registerLazySingleton<MockExamRepository>(() => repository);
      when(() => repository.getAvailability()).thenAnswer(
        (_) async => const Success(
          MockExamAvailability({
            'geografia': {
              MockExamDifficulty.facil: 142,
              MockExamDifficulty.medio: 178,
              MockExamDifficulty.dificil: 63,
              MockExamDifficulty.misto: 383,
            },
            'portugues': {
              MockExamDifficulty.facil: 59,
              MockExamDifficulty.medio: 61,
              MockExamDifficulty.dificil: 18,
              MockExamDifficulty.misto: 138,
            },
          }),
        ),
      );
    });

    ElevatedButton startButton(WidgetTester tester) =>
        tester.widget(find.widgetWithText(ElevatedButton, 'Iniciar simulado'));

    testWidgets('lists subjects collapsed with the start button disabled', (
      tester,
    ) async {
      await tester.pumpApp(const MockExamSetupPage());
      await tester.pumpAndSettle();

      expect(find.text('Geografia'), findsOneWidget);
      expect(find.text('Português'), findsOneWidget);
      expect(find.text('Nível'), findsNothing);
      expect(find.text('Selecione ao menos uma matéria'), findsOneWidget);
      expect(startButton(tester).onPressed, isNull);
    });

    testWidgets(
      'selecting expands the config, updates the footer, enables start',
      (tester) async {
        await tester.pumpApp(const MockExamSetupPage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Geografia'));
        await tester.pumpAndSettle();

        expect(find.text('Nível'), findsOneWidget);
        expect(find.text('Questões disponíveis: 383'), findsOneWidget);
        expect(find.text('1 matéria · 5 questões'), findsOneWidget);
        expect(startButton(tester).onPressed, isNotNull);

        await tester.tap(find.text('Difícil'));
        await tester.pumpAndSettle();
        expect(find.text('Questões disponíveis: 63'), findsOneWidget);

        await tester.tap(find.byTooltip('Mais questões'));
        await tester.pumpAndSettle();
        expect(find.text('1 matéria · 10 questões'), findsOneWidget);
      },
    );

    testWidgets('start opens the confirmation with exam mode spelled out', (
      tester,
    ) async {
      await tester.pumpApp(const MockExamSetupPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Geografia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar simulado'));
      await tester.pumpAndSettle();

      expect(find.text('Seu simulado'), findsOneWidget);
      expect(find.text('Modo prova'), findsOneWidget);
      expect(
        find.text('O resultado será mostrado somente ao finalizar.'),
        findsOneWidget,
      );
      expect(find.text('Misto · 5 questões'), findsOneWidget);

      // "Voltar e editar" never creates anything.
      await tester.tap(find.text('Voltar e editar'));
      await tester.pumpAndSettle();
      verifyNever(() => repository.createMockExam(any()));
    });

    testWidgets('fits a narrow phone in dark mode with every subject open', (
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
            theme: AppTheme.dark,
            home: const MockExamSetupPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Geografia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();

      expect(find.text('Nível'), findsNWidgets(2));
      expect(find.text('2 matérias · 10 questões'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

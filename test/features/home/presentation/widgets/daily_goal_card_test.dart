import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/home/presentation/widgets/daily_goal_card.dart';

void main() {
  Widget host(
    DailyGoal? goal, {
    bool reducedMotion = false,
    double width = 480,
    double textScale = 1,
    ThemeData? theme,
  }) => MaterialApp(
    theme: theme ?? AppTheme.light,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reducedMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: width,
              child: DailyGoalCard(
                strings: const HomeStrings(AppLanguage.portuguese),
                goal: goal,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  /// A running border keeps asking for frames; a still card doesn't.
  bool isAnimating(WidgetTester tester) => tester.binding.hasScheduledFrame;

  double barValue(WidgetTester tester) => tester
      .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
      .value!;

  testWidgets('0 / 10: incomplete, the border light is running', (
    tester,
  ) async {
    await tester.pumpWidget(host(const DailyGoal(answered: 0)));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Meta de hoje'), findsOneWidget);
    expect(find.text('0 / 10 questões'), findsOneWidget);
    expect(isAnimating(tester), isTrue);
  });

  testWidgets('9 / 10: still incomplete and animated', (tester) async {
    await tester.pumpWidget(host(const DailyGoal(answered: 9)));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Meta de hoje'), findsOneWidget);
    expect(find.text('Meta batida!'), findsNothing);
    expect(isAnimating(tester), isTrue);
  });

  testWidgets('10 / 10: complete and fully static', (tester) async {
    await tester.pumpWidget(host(const DailyGoal(answered: 10)));
    await tester.pumpAndSettle();

    expect(find.text('Meta batida!'), findsOneWidget);
    expect(find.text('Meta de hoje'), findsNothing);
    expect(find.text('10 / 10 questões'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(isAnimating(tester), isFalse);
  });

  testWidgets('14 / 10: complete, real count shown, bar capped at 100%', (
    tester,
  ) async {
    await tester.pumpWidget(host(const DailyGoal(answered: 14)));
    await tester.pumpAndSettle();

    expect(find.text('14 / 10 questões'), findsOneWidget);
    expect(find.text('Você passou da meta de hoje!'), findsOneWidget);
    expect(barValue(tester), 1.0);
    expect(isAnimating(tester), isFalse);
  });

  testWidgets('past the goal, how many times over', (tester) async {
    await tester.pumpWidget(host(const DailyGoal(answered: 20)));
    expect(find.text('Você dobrou a meta de hoje!'), findsOneWidget);
    await tester.pumpWidget(host(const DailyGoal(answered: 35)));
    expect(find.text('Você triplicou a meta de hoje!'), findsOneWidget);
    await tester.pumpWidget(host(const DailyGoal(answered: 80)));
    expect(find.text('Você fez 8 vezes a meta de hoje!'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion: a still highlight, no continuous animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const DailyGoal(answered: 3), reducedMotion: true),
    );
    await tester.pump();

    expect(find.text('Meta de hoje'), findsOneWidget);
    expect(isAnimating(tester), isFalse);
  });

  testWidgets('while loading, nothing animates yet', (tester) async {
    await tester.pumpWidget(host(null));
    await tester.pump();

    expect(find.text('Meta de hoje'), findsOneWidget);
    expect(isAnimating(tester), isFalse);
  });

  testWidgets('9 -> 10 while open: a short fade into the static done state', (
    tester,
  ) async {
    await tester.pumpWidget(host(const DailyGoal(answered: 9)));
    await tester.pump(const Duration(milliseconds: 500));
    expect(isAnimating(tester), isTrue);

    await tester.pumpWidget(host(const DailyGoal(answered: 10)));
    // Mid-transition: still fading, both headers cross-fading.
    await tester.pump(const Duration(milliseconds: 150));
    expect(isAnimating(tester), isTrue);

    // Done well within ~350 ms, then nothing keeps running.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('Meta batida!'), findsOneWidget);
    expect(find.text('Meta de hoje'), findsNothing);
    expect(isAnimating(tester), isFalse);
  });

  testWidgets('10 -> 9 (e.g. a new day): the light comes back without error', (
    tester,
  ) async {
    await tester.pumpWidget(host(const DailyGoal(answered: 10)));
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(const DailyGoal(answered: 9)));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Meta de hoje'), findsOneWidget);
    expect(isAnimating(tester), isTrue);
  });

  testWidgets('title is not cut short', (tester) async {
    await tester.pumpWidget(host(const DailyGoal(answered: 4)));
    final title = tester.renderObject<RenderParagraph>(
      find.text('Meta de hoje'),
    );
    expect(title.didExceedMaxLines, isFalse);
  });

  for (final scale in [1.0, 1.3, 1.5]) {
    testWidgets('360 px wide at ${scale}x text, both themes: no overflow', (
      tester,
    ) async {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        for (final answered in [4, 14]) {
          await tester.pumpWidget(
            host(
              DailyGoal(answered: answered),
              width: 328,
              textScale: scale,
              theme: theme,
            ),
          );
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
        }
      }
    });
  }
}

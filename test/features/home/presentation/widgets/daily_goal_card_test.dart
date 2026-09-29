import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/home/presentation/widgets/daily_goal_card.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, int answered) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SizedBox(
          width: 480,
          child: DailyGoalCard(
            strings: const HomeStrings(AppLanguage.portuguese),
            goal: DailyGoal(answered: answered),
          ),
        ),
      ),
    ),
  );

  testWidgets('below the goal: progress against the target', (tester) async {
    await pumpCard(tester, 7);
    expect(find.text('7 / 10 questões'), findsOneWidget);
    expect(find.text('Meta batida!'), findsNothing);
  });

  testWidgets('exactly on the goal: badge, no extra line', (tester) async {
    await pumpCard(tester, 10);
    expect(find.text('10 / 10 questões'), findsOneWidget);
    expect(find.text('Meta batida!'), findsOneWidget);
    expect(find.textContaining('Você'), findsNothing);
  });

  testWidgets('past the goal: plain count and how many times over', (
    tester,
  ) async {
    await pumpCard(tester, 14);
    expect(find.text('14 questões hoje'), findsOneWidget);
    expect(find.text('Você passou da meta de hoje!'), findsOneWidget);

    await pumpCard(tester, 20);
    expect(find.text('20 questões hoje'), findsOneWidget);
    expect(find.text('Você dobrou a meta de hoje!'), findsOneWidget);

    await pumpCard(tester, 35);
    expect(find.text('Você triplicou a meta de hoje!'), findsOneWidget);

    await pumpCard(tester, 80);
    expect(find.text('Você fez 8 vezes a meta de hoje!'), findsOneWidget);
  });

  testWidgets('title is not cut short by the badge', (tester) async {
    await pumpCard(tester, 10);
    final title = tester.renderObject<RenderParagraph>(
      find.text('Meta de hoje'),
    );
    expect(title.didExceedMaxLines, isFalse);
  });
}

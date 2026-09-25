import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_tile.dart';
import 'package:aura/shared/widgets/aura_sparkle_burst.dart';

void main() {
  Widget host({
    bool inFocus = false,
    bool justEnteredFocus = false,
    bool reducedMotion = false,
  }) => MediaQuery(
    data: MediaQueryData(disableAnimations: reducedMotion),
    child: MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SubjectTile(
          icon: Icons.calculate_outlined,
          accentColor: Colors.orange,
          label: 'Matemática',
          description: 'Exercícios e desafios.',
          inFocus: inFocus,
          justEnteredFocus: justEnteredFocus,
          onTap: () {},
        ),
      ),
    ),
  );

  group(SubjectTile, () {
    testWidgets('a normal tile has no focus mark and no sparkle', (
      tester,
    ) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome_rounded), findsNothing);
      expect(find.byType(AuraSparkleBurst), findsNothing);
    });

    testWidgets('an in-focus tile shows the mark but not a sparkle by itself', (
      tester,
    ) async {
      await tester.pumpWidget(host(inFocus: true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
      // Already in focus when it first appears -- not the moment it
      // happened, so no burst plays.
      expect(find.byType(AuraSparkleBurst), findsNothing);
    });

    testWidgets('the sparkle only plays on the transition into focus, once', (
      tester,
    ) async {
      await tester.pumpWidget(host());
      await tester.pumpWidget(host(inFocus: true, justEnteredFocus: true));
      await tester.pump();

      expect(find.byType(AuraSparkleBurst), findsOneWidget);

      // A later rebuild with the same (no longer "just entered") state
      // never plays it again.
      await tester.pumpWidget(host(inFocus: true));
      await tester.pumpAndSettle();
      expect(find.byType(AuraSparkleBurst), findsNothing);
    });

    testWidgets('reduced motion drops the sparkle, keeps the static mark', (
      tester,
    ) async {
      await tester.pumpWidget(host(reducedMotion: true));
      await tester.pumpWidget(
        host(inFocus: true, justEnteredFocus: true, reducedMotion: true),
      );
      await tester.pump();

      expect(find.byType(AuraSparkleBurst), findsNothing);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    });

    testWidgets('tapping still opens the subject either way', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SubjectTile(
              icon: Icons.calculate_outlined,
              accentColor: Colors.orange,
              label: 'Matemática',
              description: 'Exercícios e desafios.',
              inFocus: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Matemática'));
      expect(tapped, isTrue);
    });
  });
}

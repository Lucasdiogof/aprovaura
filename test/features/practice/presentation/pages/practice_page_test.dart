import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/pages/essay_themes_page.dart';
import 'package:aura/features/practice/presentation/pages/practice_page.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_tile.dart';

import '../../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

void main() {
  late EssayRepository essayRepository;

  setUp(() async {
    await sl.reset();
    essayRepository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => essayRepository);
    when(
      () => essayRepository.listThemes(),
    ).thenAnswer((_) async => const Success(<EssayThemeSummary>[]));
  });

  group(PracticePage, () {
    testWidgets('shows every subject plus Redação', (tester) async {
      await tester.pumpApp(const PracticePage());
      await tester.pumpAndSettle();

      // The grid builds lazily, so this checks both ends of it instead of
      // counting tiles that were never built.
      expect(
        find.text(Subject.values.first.label(AppLanguage.portuguese)),
        findsOneWidget,
      );
      expect(find.byType(SubjectTile), findsWidgets);

      await tester.scrollUntilVisible(find.text('Redação'), 300);
      expect(find.text('Redação'), findsOneWidget);
    });

    testWidgets('Redação opens its own route, not the catalog', (tester) async {
      await tester.pumpApp(const PracticePage());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Redação'), 300);
      await tester.tap(find.text('Redação'));
      await tester.pumpAndSettle();

      expect(find.byType(EssayThemesPage), findsOneWidget);
    });

    testWidgets('nothing in the grid claims a percentage', (tester) async {
      await tester.pumpApp(const PracticePage());
      await tester.pumpAndSettle();

      // Essays have no progress to show, and the subject tiles never had
      // one either -- so a bar anywhere here would be invented.
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}

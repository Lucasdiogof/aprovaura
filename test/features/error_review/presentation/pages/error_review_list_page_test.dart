import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/error_review/presentation/pages/error_review_list_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockErrorReviewRepository extends Mock
    implements ErrorReviewRepository {}

void main() {
  late ErrorReviewRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockErrorReviewRepository();
    sl.registerLazySingleton<ErrorReviewRepository>(() => repository);
  });

  void stubTopics(List<ErrorTopic> topics, {String? source}) {
    when(
      () => repository.listPendingTopics(source: source),
    ).thenAnswer((_) async => Success(topics));
  }

  group(ErrorReviewListPage, () {
    testWidgets('groups topics by subject, in the app\'s subject order', (
      tester,
    ) async {
      // Given out of the app's usual order (matematica, geografia,
      // historia, ...) and interleaved -- the page must still group and
      // order them itself, not just trust the server's row order.
      stubTopics(const [
        ErrorTopic(
          catalogNodeId: 'g1',
          subject: 'geografia',
          title: 'Relevo',
          wrongCount: 2,
        ),
        ErrorTopic(
          catalogNodeId: 'm1',
          subject: 'matematica',
          title: 'Frações',
          wrongCount: 1,
        ),
        ErrorTopic(
          catalogNodeId: 'g2',
          subject: 'geografia',
          title: 'Clima',
          wrongCount: 3,
        ),
      ]);
      await tester.pumpApp(const ErrorReviewListPage());
      await tester.pumpAndSettle();

      expect(find.text('Matemática'), findsOneWidget);
      expect(find.text('Geografia'), findsOneWidget);
      expect(find.text('Frações'), findsOneWidget);
      expect(find.text('Relevo'), findsOneWidget);
      expect(find.text('Clima'), findsOneWidget);

      final matematicaHeader = tester.getTopLeft(find.text('Matemática')).dy;
      final geografiaHeader = tester.getTopLeft(find.text('Geografia')).dy;
      final fracoes = tester.getTopLeft(find.text('Frações')).dy;
      final relevo = tester.getTopLeft(find.text('Relevo')).dy;
      // Matemática's whole section (header + its one topic) sits above
      // Geografia's section.
      expect(matematicaHeader < geografiaHeader, isTrue);
      expect(fracoes < geografiaHeader, isTrue);
      expect(matematicaHeader < relevo, isTrue);
    });

    testWidgets('an empty list shows the empty state, not an empty page', (
      tester,
    ) async {
      stubTopics(const []);
      await tester.pumpApp(const ErrorReviewListPage());
      await tester.pumpAndSettle();

      expect(find.text('Nenhum erro para revisar'), findsOneWidget);
    });

    testWidgets('switching to Simulados reloads with only mock-exam errors', (
      tester,
    ) async {
      stubTopics(const [
        ErrorTopic(
          catalogNodeId: 'g1',
          subject: 'geografia',
          title: 'Relevo',
          wrongCount: 2,
        ),
      ]);
      stubTopics(const [
        ErrorTopic(
          catalogNodeId: 'm1',
          subject: 'matematica',
          title: 'Frações',
          wrongCount: 1,
        ),
      ], source: 'mock_exam');
      await tester.pumpApp(const ErrorReviewListPage());
      await tester.pumpAndSettle();

      expect(find.text('Relevo'), findsOneWidget);
      expect(find.text('Frações'), findsNothing);

      await tester.tap(find.text('Simulados'));
      await tester.pumpAndSettle();

      expect(find.text('Relevo'), findsNothing);
      expect(find.text('Frações'), findsOneWidget);
      verify(() => repository.listPendingTopics(source: 'mock_exam')).called(1);
    });
  });
}

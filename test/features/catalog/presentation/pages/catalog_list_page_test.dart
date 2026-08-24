import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/catalog/presentation/pages/catalog_list_page.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

import '../../../../helpers/pump_app.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  group(CatalogListPage, () {
    late CatalogRepository catalogRepository;
    late ProgressRepository progressRepository;

    setUp(() async {
      await sl.reset();
      catalogRepository = _MockCatalogRepository();
      progressRepository = _MockProgressRepository();
      sl
        ..registerLazySingleton<CatalogRepository>(() => catalogRepository)
        ..registerLazySingleton<ProgressRepository>(() => progressRepository);
    });

    testWidgets('renders each node title once the catalog loads', (
      tester,
    ) async {
      when(
        () => catalogRepository.getChildren(
          subject: any(named: 'subject'),
          parentId: any(named: 'parentId'),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer(
        (_) async => const Success([
          CatalogNode(id: 'n1', title: 'Estados'),
          CatalogNode(id: 'n2', title: 'Relevo'),
        ]),
      );
      when(
        () => progressRepository.getBatchProgress(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer(
        (_) async =>
            const Success({'n1': TopicProgress(completed: 2, total: 5)}),
      );

      await tester.pumpApp(
        const CatalogListPage(subject: Subject.geografia, title: 'Geografia'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Estados'), findsOneWidget);
      expect(find.text('Relevo'), findsOneWidget);
    });

    testWidgets('shows the error state when loading fails', (tester) async {
      when(
        () => catalogRepository.getChildren(
          subject: any(named: 'subject'),
          parentId: any(named: 'parentId'),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => const Error(_FakeFailure()));

      await tester.pumpApp(
        const CatalogListPage(subject: Subject.geografia, title: 'Geografia'),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('shows a loading indicator before the catalog resolves', (
      tester,
    ) async {
      // Never completes during the test -- no real Timer involved, just
      // holds the cubit in its loading state for the assertion below.
      final pending = Completer<Result<List<CatalogNode>>>();
      when(
        () => catalogRepository.getChildren(
          subject: any(named: 'subject'),
          parentId: any(named: 'parentId'),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) => pending.future);

      await tester.pumpApp(
        const CatalogListPage(subject: Subject.geografia, title: 'Geografia'),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

class _FakeFailure extends Failure {
  const _FakeFailure() : super('boom');
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_state.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class _MockCatalogRepository extends Mock implements CatalogRepository {}

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  group(CatalogCubit, () {
    late CatalogRepository catalogRepository;
    late ProgressRepository progressRepository;

    const nodes = [
      CatalogNode(id: 'n1', title: 'Nó 1'),
      CatalogNode(id: 'n2', title: 'Nó 2'),
    ];
    const progress = {
      'n1': TopicProgress(completed: 2, total: 5),
      'n2': TopicProgress(completed: 0, total: 3),
    };

    setUp(() {
      catalogRepository = _MockCatalogRepository();
      progressRepository = _MockProgressRepository();
      when(
        () => catalogRepository.cachedChildren(
          subject: any(named: 'subject'),
          parentId: any(named: 'parentId'),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => progressRepository.cachedBatchProgress(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => null);
    });

    CatalogCubit buildCubit({QuestionDifficulty? difficulty}) => CatalogCubit(
      catalogRepository,
      progressRepository,
      subject: 'geografia',
      parentId: 'parent-1',
      difficulty: difficulty,
    );

    test(
      'settles on $CatalogLoaded with merged progress when both calls succeed',
      () async {
        when(
          () => catalogRepository.getChildren(
            subject: any(named: 'subject'),
            parentId: any(named: 'parentId'),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => const Success(nodes));
        when(
          () => progressRepository.getBatchProgress(
            any(),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => const Success(progress));

        final cubit = buildCubit();
        await pumpEventQueue();

        expect(cubit.state, const CatalogLoaded(nodes, progress));
      },
    );

    test('settles on $CatalogLoaded with empty progress when the progress '
        'call fails, instead of surfacing an error', () async {
      when(
        () => catalogRepository.getChildren(
          subject: any(named: 'subject'),
          parentId: any(named: 'parentId'),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => const Success(nodes));
      when(
        () => progressRepository.getBatchProgress(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));

      final cubit = buildCubit();
      await pumpEventQueue();

      expect(cubit.state, const CatalogLoaded(nodes, {}));
    });

    test('settles on $CatalogError when getChildren fails, without calling '
        'the progress repository', () async {
      when(
        () => catalogRepository.getChildren(
          subject: any(named: 'subject'),
          parentId: any(named: 'parentId'),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => Error(ServerFailure('load failed')));

      final cubit = buildCubit();
      await pumpEventQueue();

      expect(cubit.state, const CatalogError('load failed'));
      verifyNever(
        () => progressRepository.getBatchProgress(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      );
    });

    group('setDifficulty', () {
      test('reloads with the new difficulty when it changes', () async {
        when(
          () => catalogRepository.getChildren(
            subject: any(named: 'subject'),
            parentId: any(named: 'parentId'),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => const Success(nodes));
        when(
          () => progressRepository.getBatchProgress(
            any(),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => const Success(progress));
        final cubit = buildCubit();
        await pumpEventQueue();

        await cubit.setDifficulty(QuestionDifficulty.dificil);

        expect(cubit.state, const CatalogLoaded(nodes, progress));
        verify(
          () => catalogRepository.getChildren(
            subject: 'geografia',
            parentId: 'parent-1',
            difficulty: QuestionDifficulty.dificil,
          ),
        ).called(1);
      });

      test(
        'does nothing when set to the same difficulty already active',
        () async {
          when(
            () => catalogRepository.getChildren(
              subject: any(named: 'subject'),
              parentId: any(named: 'parentId'),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(nodes));
          when(
            () => progressRepository.getBatchProgress(
              any(),
              difficulty: any(named: 'difficulty'),
            ),
          ).thenAnswer((_) async => const Success(progress));
          final cubit = buildCubit();
          await pumpEventQueue();

          await cubit.setDifficulty(null);

          verify(
            () => catalogRepository.getChildren(
              subject: any(named: 'subject'),
              parentId: any(named: 'parentId'),
              difficulty: any(named: 'difficulty'),
            ),
          ).called(1);
        },
      );
    });

    group('refresh', () {
      test('reloads in place, reflecting freshly fetched data', () async {
        var call = 0;
        when(
          () => catalogRepository.getChildren(
            subject: any(named: 'subject'),
            parentId: any(named: 'parentId'),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async {
          call++;
          return Success(call == 1 ? nodes : const <CatalogNode>[]);
        });
        when(
          () => progressRepository.getBatchProgress(
            any(),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => const Success(progress));
        final cubit = buildCubit();
        await pumpEventQueue();
        expect(cubit.state, const CatalogLoaded(nodes, progress));

        await cubit.refresh();

        expect(cubit.state, const CatalogLoaded(<CatalogNode>[], progress));
      });
    });
    group('offline', () {
      void stubFetch(Future<Result<List<CatalogNode>>> Function() answer) {
        when(
          () => catalogRepository.getChildren(
            subject: any(named: 'subject'),
            parentId: any(named: 'parentId'),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) => answer());
      }

      test('with nothing saved, a connection failure ends in $CatalogError '
          'flagged as a connection problem', () async {
        stubFetch(() async => Error(NetworkFailure()));
        final cubit = buildCubit();
        await pumpEventQueue();
        expect(cubit.state, isA<CatalogError>());
        expect((cubit.state as CatalogError).isConnection, isTrue);
      });

      test('shows the saved copy first and keeps it when the server cannot '
          'be reached', () async {
        when(
          () => catalogRepository.cachedChildren(
            subject: any(named: 'subject'),
            parentId: any(named: 'parentId'),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => nodes);
        when(
          () => progressRepository.cachedBatchProgress(
            any(),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => progress);
        final failure = RequestTimeoutFailure();
        stubFetch(() async => Error(failure));
        final cubit = buildCubit();
        await pumpEventQueue();
        expect(
          cubit.state,
          CatalogLoaded(nodes, progress, offlineMessage: failure.message),
        );
      });

      test('a slow answer for an old filter never overwrites the newest '
          'filter', () async {
        final slow = Completer<Result<List<CatalogNode>>>();
        when(
          () => catalogRepository.getChildren(
            subject: any(named: 'subject'),
            parentId: any(named: 'parentId'),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((invocation) {
          // "Todos" (no filter) is the slow request; the filter picked
          // afterwards answers at once.
          if (invocation.namedArguments[#difficulty] == null) {
            return slow.future;
          }
          return Future.value(
            const Success([CatalogNode(id: 'hard', title: 'Difícil')]),
          );
        });
        when(
          () => progressRepository.getBatchProgress(
            any(),
            difficulty: any(named: 'difficulty'),
          ),
        ).thenAnswer((_) async => const Success({}));
        final cubit = buildCubit();
        await cubit.setDifficulty(QuestionDifficulty.dificil);
        await pumpEventQueue();
        slow.complete(const Success(nodes));
        await pumpEventQueue();
        expect((cubit.state as CatalogLoaded).nodes.single.id, 'hard');
      });
    });
  });
}

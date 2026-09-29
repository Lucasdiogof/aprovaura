import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_cubit.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_state.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';

class _MockMapQuizRepository extends Mock implements MapQuizRepository {}

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  group(MapQuizCubit, () {
    late MapQuizRepository mapRepository;
    late ProgressRepository progressRepository;

    const regionA = MapRegion(
      id: 'sp',
      name: 'São Paulo',
      parts: [
        [LatLng(-23.5, -46.6)],
      ],
    );
    const regionB = MapRegion(
      id: 'rj',
      name: 'Rio de Janeiro',
      parts: [
        [LatLng(-22.9, -43.2)],
      ],
    );
    const regions = [regionA, regionB];

    setUp(() {
      mapRepository = _MockMapQuizRepository();
      when(
        () => mapRepository.loadViewportSpec(any()),
      ).thenAnswer((_) async => MapViewportSpec.fallback);
      progressRepository = _MockProgressRepository();
      when(
        () => progressRepository.registerRegionFound(
          catalogNodeId: any(named: 'catalogNodeId'),
          regionId: any(named: 'regionId'),
        ),
      ).thenAnswer((_) async => const Success(null));
    });

    MapQuizCubit buildCubit({String? backgroundMapId}) => MapQuizCubit(
      mapRepository,
      progressRepository,
      mapId: 'brazil_states',
      catalogNodeId: 'node-1',
      backgroundMapId: backgroundMapId,
      attemptIdGenerator: () => 'attempt-1',
      boardBuilder: (input) async => buildMapBoard(input),
    );

    Future<MapQuizCubit> buildPlayingCubit({String? backgroundMapId}) async {
      when(
        () => mapRepository.loadRegions('brazil_states'),
      ).thenAnswer((_) async => const Success(regions));
      final cubit = buildCubit(backgroundMapId: backgroundMapId);
      await pumpEventQueue();
      return cubit;
    }

    test('settles on $MapQuizPlaying with all regions queued and no background '
        'when no backgroundMapId is given', () async {
      final cubit = await buildPlayingCubit();

      final state = cubit.state as MapQuizPlaying;
      expect(state.regions, regions);
      expect(state.backgroundRegions, isEmpty);
      expect(state.remainingIds, unorderedEquals(['sp', 'rj']));
      expect(state.totalCount, 2);
      expect(state.correctCount, 0);
    });

    test(
      'settles on $MapQuizError when loading the main regions fails',
      () async {
        when(
          () => mapRepository.loadRegions('brazil_states'),
        ).thenAnswer((_) async => Error(ServerFailure('boom')));

        final cubit = buildCubit();
        await pumpEventQueue();

        expect(cubit.state, const MapQuizError('boom'));
      },
    );

    test(
      'includes the loaded background regions when a backgroundMapId is set',
      () async {
        when(
          () => mapRepository.loadRegions('brazil_states'),
        ).thenAnswer((_) async => const Success(regions));
        when(
          () => mapRepository.loadRegions('world_countries_bg'),
        ).thenAnswer((_) async => const Success([regionA]));

        final cubit = buildCubit(backgroundMapId: 'world_countries_bg');
        await pumpEventQueue();

        final state = cubit.state as MapQuizPlaying;
        expect(state.backgroundRegions, [regionA]);
      },
    );

    test(
      'falls back to an empty background list when the background load fails',
      () async {
        when(
          () => mapRepository.loadRegions('brazil_states'),
        ).thenAnswer((_) async => const Success(regions));
        when(
          () => mapRepository.loadRegions('broken_bg'),
        ).thenAnswer((_) async => Error(ServerFailure('boom')));

        final cubit = buildCubit(backgroundMapId: 'broken_bg');
        await pumpEventQueue();

        final state = cubit.state as MapQuizPlaying;
        expect(state.backgroundRegions, isEmpty);
      },
    );

    group('onRegionTapped', () {
      test(
        'keeps the very same board from question to question -- the '
        'frame comes from all answers, never from the current target',
        () async {
          final cubit = await buildPlayingCubit();
          final before = (cubit.state as MapQuizPlaying).board;
          cubit.onRegionTapped((cubit.state as MapQuizPlaying).currentTargetId);
          final after = (cubit.state as MapQuizPlaying).board;
          expect(identical(before, after), isTrue);
        },
      );

      test(
        'registers progress and advances to the next target on a correct tap',
        () async {
          final cubit = await buildPlayingCubit();
          final target = (cubit.state as MapQuizPlaying).currentTargetId;

          cubit.onRegionTapped(target);

          final state = cubit.state as MapQuizPlaying;
          expect(state.correctCount, 1);
          expect(state.remainingIds, hasLength(1));
          expect(state.lastTap?.wasCorrect, isTrue);
          verify(
            () => progressRepository.registerRegionFound(
              catalogNodeId: 'node-1',
              regionId: target,
            ),
          ).called(1);
        },
      );

      test('holds the last correct answer on its feedback before finishing, '
          'with a full correctCount', () async {
        when(
          () => mapRepository.loadRegions('brazil_states'),
        ).thenAnswer((_) async => const Success([regionA]));
        final cubit = buildCubit();
        await pumpEventQueue();

        cubit.onRegionTapped('sp');

        // The region it just found turns green like any other answer --
        // the map does not jump straight to the result.
        final finishing = cubit.state as MapQuizPlaying;
        expect(finishing.finishing, isTrue);
        expect(finishing.correctCount, 1);
        expect(finishing.remainingIds, isEmpty);
        expect(
          finishing.lastTap,
          const TapFeedback(regionId: 'sp', wasCorrect: true),
        );

        // A tap during that moment finds nothing and changes nothing.
        cubit.onRegionTapped('sp');
        expect(cubit.state, finishing);

        await Future<void>.delayed(
          MapQuizCubit.feedbackDuration + const Duration(milliseconds: 50),
        );
        expect(
          cubit.state,
          const MapQuizFinished(
            correctCount: 1,
            totalCount: 1,
            attemptId: 'attempt-1',
          ),
        );
      });

      test('a closed cubit never finishes after the last feedback', () async {
        when(
          () => mapRepository.loadRegions('brazil_states'),
        ).thenAnswer((_) async => const Success([regionA]));
        final cubit = buildCubit();
        await pumpEventQueue();

        cubit.onRegionTapped('sp');
        await cubit.close();
        await Future<void>.delayed(
          MapQuizCubit.feedbackDuration + const Duration(milliseconds: 50),
        );

        // Leaving the page mid-feedback: the timer is cancelled, so
        // nothing emits into a closed cubit.
        expect(cubit.state, isA<MapQuizPlaying>());
      });

      test('a wrong tap increments wrongAttempts and flags it in lastTap '
          'without changing the target or correctCount', () async {
        final cubit = await buildPlayingCubit();
        final target = (cubit.state as MapQuizPlaying).currentTargetId;
        final wrongId = target == 'sp' ? 'rj' : 'sp';

        cubit.onRegionTapped(wrongId);

        final state = cubit.state as MapQuizPlaying;
        expect(state.wrongAttempts, 1);
        expect(state.revealed, isFalse);
        expect(state.correctCount, 0);
        expect(state.lastTap?.wasCorrect, isFalse);
      });

      test(
        'reveals the target after the 3rd wrong tap on the same target',
        () async {
          final cubit = await buildPlayingCubit();
          final target = (cubit.state as MapQuizPlaying).currentTargetId;
          final wrongId = target == 'sp' ? 'rj' : 'sp';

          cubit.onRegionTapped(wrongId);
          cubit.onRegionTapped(wrongId);
          cubit.onRegionTapped(wrongId);

          final state = cubit.state as MapQuizPlaying;
          expect(state.wrongAttempts, 3);
          expect(state.revealed, isTrue);
        },
      );

      test('ignores taps once the target is revealed', () async {
        final cubit = await buildPlayingCubit();
        final target = (cubit.state as MapQuizPlaying).currentTargetId;
        final wrongId = target == 'sp' ? 'rj' : 'sp';
        cubit.onRegionTapped(wrongId);
        cubit.onRegionTapped(wrongId);
        cubit.onRegionTapped(wrongId);
        final revealed = cubit.state as MapQuizPlaying;

        cubit.onRegionTapped(target);

        expect(cubit.state, revealed);
      });
    });

    group('advancePastReveal', () {
      test(
        'moves to the next target without counting the miss as correct',
        () async {
          final cubit = await buildPlayingCubit();
          final target = (cubit.state as MapQuizPlaying).currentTargetId;
          final wrongId = target == 'sp' ? 'rj' : 'sp';
          cubit.onRegionTapped(wrongId);
          cubit.onRegionTapped(wrongId);
          cubit.onRegionTapped(wrongId);

          cubit.advancePastReveal();

          final state = cubit.state as MapQuizPlaying;
          expect(state.correctCount, 0);
          expect(state.wrongAttempts, 0);
          expect(state.revealed, isFalse);
          expect(state.remainingIds, hasLength(1));
        },
      );

      test(
        'emits $MapQuizFinished when the revealed target was the last one',
        () async {
          when(
            () => mapRepository.loadRegions('brazil_states'),
          ).thenAnswer((_) async => const Success([regionA]));
          final cubit = buildCubit();
          await pumpEventQueue();
          cubit.onRegionTapped('rj');
          cubit.onRegionTapped('rj');
          cubit.onRegionTapped('rj');

          cubit.advancePastReveal();

          // The reveal already had its own, longer moment on screen, so
          // the two waits never stack: this finishes straight away.
          expect(
            cubit.state,
            const MapQuizFinished(
              correctCount: 0,
              totalCount: 1,
              attemptId: 'attempt-1',
            ),
          );
        },
      );

      test(
        'does nothing when the current target has not been revealed',
        () async {
          final cubit = await buildPlayingCubit();
          final before = cubit.state;

          cubit.advancePastReveal();

          expect(cubit.state, before);
        },
      );
    });

    group('clearFeedback', () {
      test('clears lastTap without touching the rest of the state', () async {
        final cubit = await buildPlayingCubit();
        final target = (cubit.state as MapQuizPlaying).currentTargetId;
        final wrongId = target == 'sp' ? 'rj' : 'sp';
        cubit.onRegionTapped(wrongId);

        cubit.clearFeedback();

        final state = cubit.state as MapQuizPlaying;
        expect(state.lastTap, isNull);
        expect(state.wrongAttempts, 1);
      });

      test('does nothing when there is no feedback to clear', () async {
        final cubit = await buildPlayingCubit();
        final before = cubit.state;

        cubit.clearFeedback();

        expect(cubit.state, before);
      });
    });
  });
}

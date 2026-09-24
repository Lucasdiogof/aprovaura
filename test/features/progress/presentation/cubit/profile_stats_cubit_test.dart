import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/progress/domain/entities/profile_stats.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/progress/presentation/cubit/profile_stats_cubit.dart';
import 'package:aura/features/progress/presentation/cubit/profile_stats_state.dart';

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  group(ProfileStatsCubit, () {
    late ProgressRepository repository;

    const stats = ProfileStats(totalAnswered: 247, correctAnswered: 200);

    setUp(() {
      repository = _MockProgressRepository();
    });

    test('settles on $ProfileStatsLoaded when the call succeeds', () async {
      when(
        () => repository.getProfileStats(),
      ).thenAnswer((_) async => const Success(stats));
      final cubit = ProfileStatsCubit(repository);

      await pumpEventQueue();

      expect(cubit.state, const ProfileStatsLoaded(stats));
    });

    test('settles on $ProfileStatsError when the call fails', () async {
      when(
        () => repository.getProfileStats(),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));
      final cubit = ProfileStatsCubit(repository);

      await pumpEventQueue();

      expect(cubit.state, const ProfileStatsError());
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_cubit.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_state.dart';

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group(FavoritesListCubit, () {
    late FavoritesRepository repository;

    const topics = [
      FavoriteTopic(
        catalogNodeId: 't1',
        subject: 'historia',
        title: 'Era Vargas',
        favoriteCount: 4,
      ),
    ];

    setUp(() {
      repository = _MockFavoritesRepository();
    });

    test(
      'settles on $FavoritesListLoaded when the topics load successfully',
      () async {
        when(
          () => repository.listFavoriteTopics(),
        ).thenAnswer((_) async => const Success(topics));
        final cubit = FavoritesListCubit(repository);

        await pumpEventQueue();

        expect(cubit.state, const FavoritesListLoaded(topics));
      },
    );

    test('settles on $FavoritesListError when loading fails', () async {
      when(
        () => repository.listFavoriteTopics(),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));
      final cubit = FavoritesListCubit(repository);

      await pumpEventQueue();

      expect(cubit.state, const FavoritesListError('boom'));
    });

    blocTest<FavoritesListCubit, FavoritesListState>(
      'refresh() reloads without an intermediate $FavoritesListLoading state',
      build: () {
        var call = 0;
        when(() => repository.listFavoriteTopics()).thenAnswer((_) async {
          call++;
          return Success(call == 1 ? topics : const <FavoriteTopic>[]);
        });
        return FavoritesListCubit(repository);
      },
      act: (cubit) => cubit.refresh(),
      skip: 1,
      expect: () => [const FavoritesListLoaded(<FavoriteTopic>[])],
    );
  });
}

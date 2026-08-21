import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/atualidades/domain/entities/dossier.dart';
import 'package:aura/features/atualidades/domain/entities/dossier_area.dart';
import 'package:aura/features/atualidades/domain/repositories/atualidades_repository.dart';
import 'package:aura/features/atualidades/presentation/cubit/dossier_list_cubit.dart';
import 'package:aura/features/atualidades/presentation/cubit/dossier_list_state.dart';

class _MockAtualidadesRepository extends Mock
    implements AtualidadesRepository {}

void main() {
  group(DossierListCubit, () {
    late AtualidadesRepository repository;

    const dossiers = [Dossier(id: 'd1', title: 'Eleições 2026')];

    setUpAll(() {
      registerFallbackValue(DossierArea.brasil);
    });

    setUp(() {
      repository = _MockAtualidadesRepository();
    });

    test('loads the dossiers for the given area on construction', () async {
      when(
        () => repository.getDossiers(area: any(named: 'area')),
      ).thenAnswer((_) async => const Success(dossiers));
      final cubit = DossierListCubit(repository, DossierArea.brasil);

      await pumpEventQueue();

      expect(cubit.state, const DossierListLoaded(dossiers));
      verify(() => repository.getDossiers(area: DossierArea.brasil)).called(1);
    });

    test('settles on $DossierListError when loading fails', () async {
      when(
        () => repository.getDossiers(area: any(named: 'area')),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));
      final cubit = DossierListCubit(repository, DossierArea.economia);

      await pumpEventQueue();

      expect(cubit.state, const DossierListError('boom'));
    });

    test('load() re-fetches the dossiers', () async {
      var call = 0;
      when(() => repository.getDossiers(area: any(named: 'area'))).thenAnswer((
        _,
      ) async {
        call++;
        return Success(call == 1 ? dossiers : const <Dossier>[]);
      });
      final cubit = DossierListCubit(repository, DossierArea.brasil);
      await pumpEventQueue();
      expect(cubit.state, const DossierListLoaded(dossiers));

      await cubit.load();

      expect(cubit.state, const DossierListLoaded(<Dossier>[]));
      verify(() => repository.getDossiers(area: DossierArea.brasil)).called(2);
    });
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/atualidades/domain/entities/dossier_area.dart';
import 'package:aura/features/atualidades/domain/repositories/atualidades_repository.dart';
import 'package:aura/features/atualidades/presentation/cubit/dossier_list_state.dart';

class DossierListCubit extends Cubit<DossierListState> {
  DossierListCubit(this._repository, this.area)
    : super(const DossierListLoading()) {
    load();
  }

  final AtualidadesRepository _repository;
  final DossierArea area;

  Future<void> load() async {
    emit(const DossierListLoading());
    final result = await _repository.getDossiers(area: area);
    switch (result) {
      case Success(:final data):
        emit(DossierListLoaded(data));
      case Error(:final failure):
        emit(DossierListError(failure.message));
    }
  }
}

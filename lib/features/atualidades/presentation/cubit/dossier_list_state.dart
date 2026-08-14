import 'package:equatable/equatable.dart';
import 'package:aura/features/atualidades/domain/entities/dossier.dart';

sealed class DossierListState extends Equatable {
  const DossierListState();

  @override
  List<Object?> get props => [];
}

class DossierListLoading extends DossierListState {
  const DossierListLoading();
}

class DossierListLoaded extends DossierListState {
  const DossierListLoaded(this.dossiers);

  final List<Dossier> dossiers;

  @override
  List<Object?> get props => [dossiers];
}

class DossierListError extends DossierListState {
  const DossierListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

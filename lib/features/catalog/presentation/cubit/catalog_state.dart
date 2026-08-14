import 'package:equatable/equatable.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';

sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  const CatalogLoaded(this.nodes);

  final List<CatalogNode> nodes;

  @override
  List<Object?> get props => [nodes];
}

class CatalogError extends CatalogState {
  const CatalogError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

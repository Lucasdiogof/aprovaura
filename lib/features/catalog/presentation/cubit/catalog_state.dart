import 'package:equatable/equatable.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';

sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  const CatalogLoaded(this.nodes, this.progressByNodeId);

  final List<CatalogNode> nodes;
  final Map<String, TopicProgress> progressByNodeId;

  @override
  List<Object?> get props => [nodes, progressByNodeId];
}

class CatalogError extends CatalogState {
  const CatalogError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

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
  const CatalogLoaded(this.nodes, this.progressByNodeId, {this.offlineMessage});

  final List<CatalogNode> nodes;
  final Map<String, TopicProgress> progressByNodeId;

  /// Non-null when these nodes are the last saved copy because the server
  /// could not be reached; holds the reason to show next to them.
  final String? offlineMessage;

  @override
  List<Object?> get props => [nodes, progressByNodeId, offlineMessage];
}

class CatalogError extends CatalogState {
  const CatalogError(this.message, {this.isConnection = false});

  final String message;

  /// The cause was the connection (offline / timeout), not the server.
  final bool isConnection;

  @override
  List<Object?> get props => [message, isConnection];
}

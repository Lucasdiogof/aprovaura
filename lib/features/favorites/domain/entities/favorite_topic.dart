import 'package:equatable/equatable.dart';

class FavoriteTopic extends Equatable {
  const FavoriteTopic({
    required this.catalogNodeId,
    required this.subject,
    required this.title,
    required this.favoriteCount,
    this.parentTitle,
  });

  final String catalogNodeId;
  final String subject;
  final String title;
  final String? parentTitle;
  final int favoriteCount;

  @override
  List<Object?> get props => [
    catalogNodeId,
    subject,
    title,
    parentTitle,
    favoriteCount,
  ];
}

import 'package:equatable/equatable.dart';

class CatalogNode extends Equatable {
  const CatalogNode({
    required this.id,
    required this.title,
    this.description,
    this.icon,
  });

  final String id;
  final String title;
  final String? description;
  final String? icon;

  factory CatalogNode.fromJson(Map<String, dynamic> json) => CatalogNode(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    icon: json['icon'] as String?,
  );

  @override
  List<Object?> get props => [id, title, description, icon];
}

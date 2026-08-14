import 'package:equatable/equatable.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    this.name = '',
    this.username,
    this.avatarUrl,
    this.goal,
    this.examYear,
    this.interestedSubjects = const [],
  });

  final String id;
  final String name;
  final String? username;
  final String? avatarUrl;
  final Goal? goal;
  final String? examYear;
  final List<Subject> interestedSubjects;

  UserProfile copyWith({
    String? name,
    String? username,
    String? avatarUrl,
    Goal? goal,
    String? examYear,
    List<Subject>? interestedSubjects,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      goal: goal ?? this.goal,
      examYear: examYear ?? this.examYear,
      interestedSubjects: interestedSubjects ?? this.interestedSubjects,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    avatarUrl,
    goal,
    examYear,
    interestedSubjects,
  ];
}

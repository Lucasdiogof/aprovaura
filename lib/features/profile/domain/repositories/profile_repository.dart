import 'package:aura/core/error/result.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/domain/entities/user_profile.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

abstract class ProfileRepository {
  Future<Result<UserProfile>> getCurrent();

  Future<Result<UserProfile>> createProfile({
    required String id,
    required String name,
    String? username,
  });

  Future<Result<void>> updateProfile({
    String? name,
    String? username,
    Goal? goal,
    String? examYear,
    List<Subject>? interestedSubjects,
  });
}

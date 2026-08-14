import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/domain/entities/user_profile.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<Result<UserProfile>> getCurrent() async {
    try {
      final rows = await _client.from('profiles').select().eq('id', _userId);
      if (rows.isEmpty) {
        final inserted = await _client
            .from('profiles')
            .insert({'id': _userId, 'name': ''})
            .select()
            .single();
        return Success(_toUserProfile(inserted));
      }
      return Success(_toUserProfile(rows.first));
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<UserProfile>> createProfile({
    required String id,
    required String name,
    String? username,
  }) async {
    try {
      final inserted = await _client
          .from('profiles')
          .upsert({
            'id': id,
            'name': name,
            if (username != null) 'username': username,
          })
          .select()
          .single();
      return Success(_toUserProfile(inserted));
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> updateProfile({
    String? name,
    String? username,
    Goal? goal,
    String? examYear,
    List<Subject>? interestedSubjects,
  }) async {
    try {
      final patch = <String, dynamic>{
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (goal != null) 'goal': goal.name,
        if (examYear != null) 'exam_year': examYear,
        if (interestedSubjects != null)
          'interested_subjects': interestedSubjects
              .map((s) => s.name)
              .toList(growable: false),
      };
      if (patch.isEmpty) return const Success(null);
      await _client.from('profiles').update(patch).eq('id', _userId);
      return const Success(null);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  UserProfile _toUserProfile(Map<String, dynamic> row) {
    final subjectNames = (row['interested_subjects'] as List<dynamic>? ?? [])
        .cast<String>();
    return UserProfile(
      id: row['id'] as String,
      name: row['name'] as String? ?? '',
      username: row['username'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      goal: Goal.fromName(row['goal'] as String?),
      examYear: row['exam_year'] as String?,
      interestedSubjects: subjectNames
          .map((n) => Subject.values.where((s) => s.name == n))
          .where((matches) => matches.isNotEmpty)
          .map((matches) => matches.first)
          .toList(growable: false),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/features/profile/data/profile_repository_impl.dart';

void main() {
  group('ProfileRepositoryImpl.isUsernameConflict', () {
    test('the unique index on the username is a conflict', () {
      expect(
        ProfileRepositoryImpl.isUsernameConflict(
          const PostgrestException(
            message:
                'duplicate key value violates unique constraint '
                '"profiles_username_lower_key"',
            code: '23505',
          ),
        ),
        isTrue,
      );
    });

    test('any other error is not', () {
      expect(
        ProfileRepositoryImpl.isUsernameConflict(
          const PostgrestException(message: 'timeout', code: '57014'),
        ),
        isFalse,
      );
      expect(
        ProfileRepositoryImpl.isUsernameConflict(
          const PostgrestException(
            message:
                'duplicate key value violates unique constraint '
                '"profiles_pkey"',
            code: '23505',
          ),
        ),
        isFalse,
      );
    });
  });
}

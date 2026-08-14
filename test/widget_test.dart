import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/app.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  AppUser? get currentUser => null;
}

void main() {
  testWidgets('app opens directly on the login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    if (!sl.isRegistered<ThemeCubit>()) {
      sl.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
    }
    if (!sl.isRegistered<LocaleCubit>()) {
      sl.registerLazySingleton<LocaleCubit>(LocaleCubit.new);
    }
    if (!sl.isRegistered<AuthRepository>()) {
      sl.registerLazySingleton<AuthRepository>(_FakeAuthRepository.new);
    }
    if (!sl.isRegistered<AuthCubit>()) {
      sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
    }

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Aura'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}

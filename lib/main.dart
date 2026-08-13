import 'package:flutter/material.dart';
import 'package:aura/app.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  sl.registerLazySingleton<LocaleCubit>(LocaleCubit.new);

  runApp(const App());
}

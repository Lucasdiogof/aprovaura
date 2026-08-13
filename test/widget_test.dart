import 'package:flutter_test/flutter_test.dart';
import 'package:aura/app.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';

void main() {
  testWidgets('splash shows the Aura wordmark', (tester) async {
    if (!sl.isRegistered<LocaleCubit>()) {
      sl.registerLazySingleton<LocaleCubit>(LocaleCubit.new);
    }

    await tester.pumpWidget(const App());
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Aura'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/auth/presentation/widgets/auth_scaffold.dart';

void main() {
  group(AuthScaffold, () {
    testWidgets('never asserts on a negative minHeight, even below 48px '
        'tall', (tester) async {
      // 48 is exactly the padding AuthScaffold subtracts from the
      // available height -- a viewport shorter than that used to compute
      // a negative BoxConstraints.minHeight and crash the LayoutBuilder.
      tester.view.physicalSize = const Size(300, 40);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AuthScaffold(children: [Text('content')]),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('content starts near the top, not centred with a gap '
        'above it', (tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AuthScaffold(children: [Text('content')]),
        ),
      );
      await tester.pump();

      // A tall screen used to centre the whole column, leaving a wide gap
      // above the first child. It should now sit close to the top.
      final topOfContent = tester.getTopLeft(find.text('content')).dy;
      expect(topOfContent, lessThan(120));
    });
  });
}

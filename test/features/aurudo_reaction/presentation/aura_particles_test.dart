import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group(AuraParticles, () {
    for (final style in AuraParticlesStyle.values) {
      testWidgets('${style.name}: renders and animates without error', (
        tester,
      ) async {
        await tester.pumpApp(
          SizedBox(width: 200, height: 200, child: AuraParticles(style: style)),
        );
        await tester.pump(const Duration(milliseconds: 700));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('reduced motion: no ticking, no exception', (tester) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SizedBox(
            width: 200,
            height: 200,
            child: AuraParticles(style: AuraParticlesStyle.converge),
          ),
        ),
      );
      // A single pump is enough: there is nothing left to animate.
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes its controller when removed from the tree', (
      tester,
    ) async {
      await tester.pumpApp(
        const SizedBox(
          width: 200,
          height: 200,
          child: AuraParticles(style: AuraParticlesStyle.burst),
        ),
      );
      await tester.pumpApp(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}

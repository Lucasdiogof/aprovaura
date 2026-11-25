import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/features/paywall/presentation/widgets/paywall_common.dart';

void main() {
  Widget host(Widget child) => MaterialApp(theme: AppTheme.light, home: child);

  testWidgets('o X toca mesmo com conteúdo rolável por cima (regressão: o conteúdo engolia o toque)', (tester) async {
    var closed = 0;
    await tester.pumpWidget(host(PaywallFrame(
      onClose: () => closed++,
      particles: false,
      children: const [SizedBox(height: 900, child: Text('conteúdo longo'))],
    )));
    await tester.tap(find.byIcon(Icons.close));
    expect(closed, 1);
  });

  testWidgets('sem onClose (bloqueio) não há X', (tester) async {
    await tester.pumpWidget(host(const PaywallFrame(particles: false, children: [Text('x')])));
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('PaywallLoading mostra só o indicador', (tester) async {
    await tester.pumpWidget(host(const PaywallLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Restaurar compras'), findsNothing);
  });

  testWidgets('sem mascote e com botão fixo no rodapé, fora da rolagem', (tester) async {
    await tester.pumpWidget(host(const PaywallFrame(
      particles: false,
      showMascot: false,
      bottom: Text('ASSINAR'),
      children: [SizedBox(height: 2000, child: Text('planos'))],
    )));
    expect(find.byType(AurudoIllustration), findsNothing);
    expect(find.descendant(of: find.byType(SingleChildScrollView), matching: find.text('ASSINAR')), findsNothing);
    expect(find.text('ASSINAR'), findsOneWidget);
  });
}

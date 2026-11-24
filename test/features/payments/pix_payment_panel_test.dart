import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/payments/domain/payments.dart';
import 'package:aura/features/payments/presentation/widgets/pix_payment_panel.dart';

import '../../helpers/pump_app.dart';

// 1x1 PNG, só para o QR renderizar sem rede.
final _png = base64Encode(base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='));

PixCharge _charge({DateTime? expiresAt, PayPlan plan = PayPlan.monthly}) => PixCharge(
      id: 'c1',
      plan: plan,
      method: 'pix',
      amountCents: plan == PayPlan.annual ? 19000 : 1990,
      qrCode: '00020126PIXCOPIAECOLA',
      qrBase64: _png,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 30)),
    );

Widget _host(Widget c) => Scaffold(body: SingleChildScrollView(child: c));

void main() {
  testWidgets('mostra QR, copia e cola, prazo de 30 dias e aguarda o pagamento', (tester) async {
    await tester.pumpApp(_host(PixPaymentPanel(
      charge: _charge(), planName: 'Premium mensal', priceLabel: 'R\$ 19,90', onCheck: () async => 'pending')));
    expect(find.text('Premium mensal · R\$ 19,90'), findsOneWidget);
    expect(find.textContaining('Acesso por 30 dias'), findsOneWidget);
    expect(find.text('00020126PIXCOPIAECOLA'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('Aguardando pagamento'), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // cancela os timers
  });

  testWidgets('plano anual avisa 365 dias e que o Pix não renova sozinho', (tester) async {
    await tester.pumpApp(_host(PixPaymentPanel(
      charge: _charge(plan: PayPlan.annual), planName: 'Premium anual', priceLabel: 'R\$ 190,00', onCheck: () async => 'pending')));
    expect(find.textContaining('Acesso por 365 dias'), findsOneWidget);
    expect(find.textContaining('não renova sozinho'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('copiar código coloca o Pix na área de transferência', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
      return null;
    });
    await tester.pumpApp(_host(PixPaymentPanel(
      charge: _charge(), planName: 'Premium mensal', priceLabel: 'R\$ 19,90', onCheck: () async => 'pending')));
    await tester.tap(find.text('Copiar código Pix'));
    await tester.pump();
    expect(copied, '00020126PIXCOPIAECOLA');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('"Verificar pagamento" só confirma quando o servidor responde approved', (tester) async {
    var calls = 0;
    var answer = 'pending';
    await tester.pumpApp(_host(PixPaymentPanel(
      charge: _charge(), planName: 'Premium mensal', priceLabel: 'R\$ 19,90',
      onCheck: () async { calls++; return answer; })));
    await tester.tap(find.text('Verificar pagamento'));
    await tester.pump();
    await tester.pump();
    expect(calls, 1);
    expect(find.text('Pagamento confirmado!'), findsNothing); // pendente não libera nada
    answer = 'approved';
    await tester.tap(find.text('Verificar pagamento'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Pagamento confirmado!'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Pix expirado oferece gerar novo código e não mostra o QR', (tester) async {
    var again = false;
    await tester.pumpApp(_host(PixPaymentPanel(
      charge: _charge(expiresAt: DateTime.now().subtract(const Duration(minutes: 1))),
      planName: 'Premium mensal', priceLabel: 'R\$ 19,90', onCheck: () async => 'expired', onNewCharge: () => again = true)));
    expect(find.text('Este Pix expirou.'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    await tester.tap(find.text('Gerar novo Pix'));
    expect(again, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}

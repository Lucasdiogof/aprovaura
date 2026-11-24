import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/portal/domain/report_parser.dart';

void main() {
  group('parseCents', () {
    test('formatos brasileiro e internacional, sinal e símbolo', () {
      expect(parseCents('19.90'), 1990);
      expect(parseCents('19,90'), 1990);
      expect(parseCents('1.234,56'), 123456);
      expect(parseCents('1,234.56'), 123456);
      expect(parseCents('-2,99'), 299);
      expect(parseCents('R\$ 190,00'), 19000);
    });
    test('vazio e ilegível viram null (nunca zero inventado)', () {
      expect(parseCents(''), isNull);
      expect(parseCents(null), isNull);
      expect(parseCents('-'), isNull);
      expect(parseCents('abc'), isNull);
    });
  });

  group('parseReport', () {
    const sample = 'Order Number;Charged Amount;Fee Amount;Tax Amount;Order Charged Date\n'
        'GPA.1;19,90;2,99;0,00;2026-12-02\n'
        'GPA.2;190,00;28,50;0,00;2026-12-03\n';

    test('relatório individual do Google lê id, bruto, taxa e imposto em centavos', () {
      final p = parseReport(kind: 'google_earnings', text: sample);
      expect(p.lines, hasLength(2));
      expect(p.lines[0]['ref'], 'GPA.1');
      expect(p.lines[0]['gross_cents'], 1990);
      expect(p.lines[0]['fee_cents'], 299);
      expect(p.lines[0]['tax_cents'], 0);
      expect(p.lines[1]['gross_cents'], 19000);
      expect(p.warnings, isEmpty);
    });

    test('o hash identifica o conteúdo (mesmo arquivo => mesmo hash; fim de linha não importa)', () {
      final a = parseReport(kind: 'google_earnings', text: sample);
      final b = parseReport(kind: 'google_earnings', text: sample.replaceAll('\n', '\r\n'));
      final c = parseReport(kind: 'google_earnings', text: sample.replaceFirst('19,90', '19,91'));
      expect(a.sha256Hex, b.sha256Hex);
      expect(a.sha256Hex, isNot(c.sha256Hex));
      expect(a.sha256Hex, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('coluna de identificação ausente em relatório individual: erro explícito, sem palpite', () {
      expect(
        () => parseReport(kind: 'google_earnings', text: 'Charged Amount;Fee Amount\n19,90;2,99\n'),
        throwsA(isA<ReportFormatException>()),
      );
    });

    test('sem taxa/imposto: avisa que nada ficará pronto para aplicar', () {
      final p = parseReport(kind: 'google_earnings', text: 'Order Number;Charged Amount\nGPA.1;19,90\n');
      expect(p.warnings, isNotEmpty);
      expect(p.lines.single['fee_cents'], isNull);
    });

    test('Apple (agregado) não exige id por linha', () {
      final p = parseReport(
        kind: 'apple_sales',
        text: 'SKU,Units,Customer Price,Country Code,Customer Currency\naprovaura_premium_monthly,3,19.90,BR,BRL\n',
      );
      expect(p.lines.single['ref'], isNull);
      expect(p.lines.single['qty'], 3);
      expect(p.lines.single['gross_cents'], 1990);
    });

    test('só cabeçalho: erro', () {
      expect(() => parseReport(kind: 'mp_release', text: 'SOURCE_ID;gross_amount\n'), throwsA(isA<ReportFormatException>()));
    });
  });
}

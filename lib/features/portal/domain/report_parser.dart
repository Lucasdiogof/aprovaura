import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Relatórios financeiros oficiais (colados como texto CSV/TSV) → linhas para
/// `admin_import_report`. ATENÇÃO: os nomes de coluna abaixo são ALIASES prováveis,
/// NÃO validados com amostra real dos provedores (ver docs/finance/RECONCILIATION.md).
/// Coluna obrigatória ausente => erro explícito, nunca palpite.
const reportKinds = <String, List<String>>{
  'apple': ['apple_sales', 'apple_financial'],
  'google': ['google_sales', 'google_earnings'],
  'mercadopago': ['mp_release', 'mp_settlement'],
};

const _aliases = <String, List<String>>{
  'ref': ['order number', 'order id', 'source_id', 'source id', 'id da operação', 'external_reference'],
  'gross': ['charged amount', 'item price', 'gross_amount', 'transaction_amount', 'valor bruto', 'customer price',
    'extended partner share'],
  'fee': ['fee amount', 'google fee', 'mercadopago_fee', 'fee_amount', 'tarifa', 'taxa'],
  'tax': ['tax amount', 'taxes_amount', 'tax', 'imposto', 'taxes'],
  'net': ['net_credit_amount', 'net amount', 'valor líquido', 'partner share', 'developer proceeds'],
  'qty': ['quantity', 'units', 'qty'],
  'sku': ['sku', 'product id', 'product title', 'apple identifier'],
  'country': ['country', 'country of sale', 'buyer country', 'country code'],
  'currency': ['currency', 'currency of sale', 'buyer currency', 'customer currency'],
  'at': ['order charged date', 'date', 'transaction_date', 'money_release_date', 'begin date'],
};

class ParsedReport {
  ParsedReport(this.lines, this.sha256Hex, this.warnings);
  final List<Map<String, dynamic>> lines;
  final String sha256Hex;
  final List<String> warnings;
}

class ReportFormatException implements Exception {
  ReportFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// "19.90", "19,90", "1.234,56", "-5,00", "R$ 10" → centavos (módulo); null se vazio/ilegível.
int? parseCents(String? raw) {
  if (raw == null) return null;
  var s = raw.replaceAll(RegExp(r'[^0-9,.\-]'), '');
  if (s.isEmpty || s == '-') return null;
  final lastComma = s.lastIndexOf(','), lastDot = s.lastIndexOf('.');
  if (lastComma > lastDot) {
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else {
    s = s.replaceAll(',', '');
  }
  final v = double.tryParse(s);
  return v == null ? null : (v.abs() * 100).round();
}

List<String> _split(String line, String d) {
  final out = <String>[];
  final b = StringBuffer();
  var q = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      if (q && i + 1 < line.length && line[i + 1] == '"') {
        b.write('"');
        i++;
      } else {
        q = !q;
      }
    } else if (c == d && !q) {
      out.add(b.toString());
      b.clear();
    } else {
      b.write(c);
    }
  }
  out.add(b.toString());
  return out.map((e) => e.trim()).toList();
}

ParsedReport parseReport({required String kind, required String text}) {
  final clean = text.replaceAll('\r', '').replaceFirst('﻿', '');
  final rows = clean.split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (rows.length < 2) throw ReportFormatException('Cole o cabeçalho e ao menos uma linha.');
  final head = rows.first;
  final d = ['\t', ';', ','].reduce((a, b) => head.split(a).length >= head.split(b).length ? a : b);
  final names = _split(head, d).map((e) => e.toLowerCase()).toList();
  int? col(String key) {
    for (final a in _aliases[key]!) {
      final i = names.indexOf(a);
      if (i >= 0) return i;
    }
    return null;
  }

  final individual = kind != 'apple_sales' && kind != 'apple_financial';
  final cRef = col('ref'), cGross = col('gross'), cFee = col('fee'), cTax = col('tax');
  final warnings = <String>[];
  if (individual && cRef == null) {
    throw ReportFormatException('Coluna de identificação do pagamento não encontrada. Esperado um destes cabeçalhos: '
        '${_aliases['ref']!.join(', ')}.');
  }
  if (cGross == null) throw ReportFormatException('Coluna de valor bruto não encontrada (${_aliases['gross']!.join(', ')}).');
  if (kind.endsWith('earnings') || kind == 'mp_release' || kind == 'mp_settlement') {
    if (cFee == null || cTax == null) {
      warnings.add('Colunas de taxa e/ou imposto ausentes: nenhuma linha ficará pronta para aplicar.');
    }
  }
  String? at(List<String> r, int? i) => i == null || i >= r.length ? null : r[i];
  final lines = <Map<String, dynamic>>[];
  for (final raw in rows.skip(1)) {
    final r = _split(raw, d);
    final m = <String, dynamic>{
      'ref': at(r, cRef),
      'gross_cents': parseCents(at(r, cGross)),
      'fee_cents': parseCents(at(r, cFee)),
      'tax_cents': parseCents(at(r, cTax)),
      'net_cents': parseCents(at(r, col('net'))),
      'qty': int.tryParse(at(r, col('qty')) ?? ''),
      'sku': at(r, col('sku')),
      'country': at(r, col('country')),
      'currency': at(r, col('currency')),
    };
    final when = DateTime.tryParse(at(r, col('at')) ?? '');
    if (when != null) m['at'] = when.toUtc().toIso8601String();
    lines.add(m);
  }
  return ParsedReport(lines, sha256.convert(utf8.encode(clean)).toString(), warnings);
}

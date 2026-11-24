import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Baixa o CSV no navegador (UTF-8 com BOM para o Excel).
Future<bool> downloadCsv(String name, String csv) async {
  final blob = web.Blob(
    [Uint8List.fromList(utf8.encode('\uFEFF$csv')).toJS].toJS,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  (web.HTMLAnchorElement()
        ..href = url
        ..download = name)
      .click();
  web.URL.revokeObjectURL(url);
  return true;
}

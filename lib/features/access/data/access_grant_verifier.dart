import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:aura/features/access/data/access_keys.dart';

enum GrantRejection {
  malformed,
  unknownKey,
  badSignature,
  wrongAccount,
  expired,
  clockRolledBack,
}

class GrantVerification {
  const GrantVerification.accepted(Map<String, dynamic> this.payload)
    : rejection = null;
  const GrantVerification.rejected(GrantRejection this.rejection)
    : payload = null;

  final Map<String, dynamic>? payload;
  final GrantRejection? rejection;

  bool get isValid => payload != null;
}

/// Verifica (RS256, PKCS#1 v1.5, SHA-256) a autorização offline emitida pelo
/// servidor. Só usa a chave PÚBLICA. Puro Dart, sem plugin.
///
/// Limite assumido: offline não existe relógio confiável. A defesa é
/// proporcional: validade curta emitida pelo servidor, vínculo à conta e um
/// "último instante visto" que só avança (relógio recuado => exige conexão).
class AccessGrantVerifier {
  const AccessGrantVerifier({this.keys = kAccessPublicKeys});

  final Map<String, String> keys;

  static const _sha256Prefix = <int>[
    0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, //
    0x65, 0x03, 0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20,
  ];
  static const _clockSlack = Duration(minutes: 5);

  GrantVerification verify(
    String token, {
    required String userId,
    required DateTime now,
    required DateTime lastSeen,
  }) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return const GrantVerification.rejected(GrantRejection.malformed);
    }
    final Map<String, dynamic> payload;
    try {
      final header = jsonDecode(utf8.decode(_b64(parts[0])));
      if (header is! Map || header['alg'] != 'RS256') {
        return const GrantVerification.rejected(GrantRejection.malformed);
      }
      final nHex = keys[header['kid']];
      if (nHex == null) {
        return const GrantVerification.rejected(GrantRejection.unknownKey);
      }
      if (!_signatureOk('${parts[0]}.${parts[1]}', _b64(parts[2]), nHex)) {
        return const GrantVerification.rejected(GrantRejection.badSignature);
      }
      final decoded = jsonDecode(utf8.decode(_b64(parts[1])));
      if (decoded is! Map) {
        return const GrantVerification.rejected(GrantRejection.malformed);
      }
      payload = Map<String, dynamic>.from(decoded);
    } catch (_) {
      return const GrantVerification.rejected(GrantRejection.malformed);
    }

    if (payload['sub'] != userId) {
      return const GrantVerification.rejected(GrantRejection.wrongAccount);
    }
    final iat = payload['iat'];
    final exp = payload['exp'];
    if (iat is! num || exp is! num) {
      return const GrantVerification.rejected(GrantRejection.malformed);
    }
    final issuedAt = DateTime.fromMillisecondsSinceEpoch(
      iat.toInt() * 1000,
      isUtc: true,
    );
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );
    final utcNow = now.toUtc();
    if (utcNow.isBefore(lastSeen.toUtc().subtract(_clockSlack)) ||
        utcNow.isBefore(issuedAt.subtract(_clockSlack))) {
      return const GrantVerification.rejected(GrantRejection.clockRolledBack);
    }
    if (!utcNow.isBefore(expiresAt)) {
      return const GrantVerification.rejected(GrantRejection.expired);
    }
    return GrantVerification.accepted(payload);
  }

  bool _signatureOk(String signingInput, Uint8List signature, String nHex) {
    final n = BigInt.parse(nHex, radix: 16);
    final k = (n.bitLength + 7) ~/ 8;
    if (signature.length != k) return false;
    final s = _toBig(signature);
    if (s >= n) return false;
    final em = _fromBig(s.modPow(BigInt.from(65537), n), k);
    final hash = sha256.convert(ascii.encode(signingInput)).bytes;
    final expected = <int>[
      0x00,
      0x01,
      ...List.filled(k - 3 - _sha256Prefix.length - hash.length, 0xff),
      0x00,
      ..._sha256Prefix,
      ...hash,
    ];
    var diff = 0;
    for (var i = 0; i < k; i++) {
      diff |= em[i] ^ expected[i];
    }
    return diff == 0;
  }

  static Uint8List _b64(String s) => base64Url.decode(base64Url.normalize(s));

  static BigInt _toBig(List<int> bytes) {
    var r = BigInt.zero;
    for (final b in bytes) {
      r = (r << 8) | BigInt.from(b);
    }
    return r;
  }

  static Uint8List _fromBig(BigInt value, int length) {
    final out = Uint8List(length);
    var v = value;
    for (var i = length - 1; i >= 0; i--) {
      out[i] = (v & BigInt.from(0xff)).toInt();
      v >>= 8;
    }
    return out;
  }
}

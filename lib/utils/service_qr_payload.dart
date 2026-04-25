import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Builds the UTF-8 string encoded into the service QR code.
///
/// v2: JSON with HMAC-SHA256 over a canonical string (see backend [qrTokenService]).
/// v1: legacy `userID` + `timestamp` only (server may reject when legacy is disabled).
abstract final class ServiceQrPayload {
  /// Production format: signed payload including [serviceId] and a random [nonce].
  static String buildV2({
    required String userId,
    required String serviceId,
    required String hmacKeyHex,
    DateTime? at,
  }) {
    final t = (at ?? DateTime.now()).toUtc();
    final nonce = _randomHex(16);
    final can = 'v2|$userId|${t.toIso8601String()}|$nonce|$serviceId';
    final key = _hexToBytes(hmacKeyHex);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode(can));
    // `Digest` from package:crypto exposes `bytes` (HMAC output).
    final b64 = base64Encode(Uint8List.fromList(digest.bytes));
    return jsonEncode(<String, Object?>{
      'v': 2,
      'userID': userId,
      'timestamp': t.toIso8601String(),
      'nonce': nonce,
      'serviceId': serviceId,
      'signature': b64,
    });
  }

  /// Pre-HMAC format (do not use when server requires v2).
  @Deprecated('Use buildV2 with qrHmacKey from login')
  static String build({
    required String userId,
    DateTime? at,
  }) {
    final t = (at ?? DateTime.now()).toUtc();
    return jsonEncode(<String, String>{
      'userID': userId,
      'timestamp': t.toIso8601String(),
    });
  }
}

String _randomHex(int byteCount) {
  final r = Random.secure();
  final b = List<int>.generate(byteCount, (_) => r.nextInt(256));
  return b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
}

List<int> _hexToBytes(String hex) {
  var s = hex.trim();
  if (s.length.isOdd) {
    throw FormatException('Invalid HMAC key length');
  }
  if (s.isEmpty) {
    throw FormatException('Empty HMAC key');
  }
  final out = <int>[];
  for (var i = 0; i < s.length; i += 2) {
    out.add(int.parse(s.substring(i, i + 2), radix: 16));
  }
  return out;
}

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Matches `backend/src/utils/contentHash.js` (agent).
String hashAgentScan({
  String? userId,
  required String rawPayload,
  required String scannedAt,
}) {
  final s = 'agent|${userId ?? ''}|$rawPayload|$scannedAt';
  return sha256.convert(utf8.encode(s)).toString();
}

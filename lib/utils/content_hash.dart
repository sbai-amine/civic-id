import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Must match `backend/src/utils/contentHash.js` (citizen).
String hashCitizenQr({
  required String nationalId,
  required String serviceId,
  required String payload,
  required String createdAt,
}) {
  final s = '$nationalId|$serviceId|$payload|$createdAt';
  final d = sha256.convert(utf8.encode(s));
  return d.toString();
}

/// Must match `backend/src/utils/contentHash.js` (agent app uses same for scans).
String hashAgentScan({
  String? userId,
  required String rawPayload,
  required String scannedAt,
}) {
  final s = 'agent|${userId ?? ''}|$rawPayload|$scannedAt';
  final d = sha256.convert(utf8.encode(s));
  return d.toString();
}

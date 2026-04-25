import 'dart:convert';

/// Data encoded by the citizen BridgeID service QR (JSON).
///
/// v1: [userID] + [timestamp]. v2 adds [nonce] + [signature] (HMAC verified on server; agent does TTL + replay check).
class DecodedQrPayload {
  const DecodedQrPayload({
    required this.userId,
    required this.timestamp,
    this.version,
    this.nonce,
    this.serviceId,
    this.signatureB64,
  });

  final String userId;
  final String timestamp;
  final int? version;
  final String? nonce;
  final String? serviceId;
  final String? signatureB64;

  /// Parses v1 and v2 JSON from the citizen mobile app.
  static DecodedQrPayload? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) return null;
      final uid = decoded['userID'] ?? decoded['userId'];
      final ts = decoded['timestamp'];
      if (uid is! String || ts is! String || uid.isEmpty || ts.isEmpty) {
        return null;
      }
      final v = decoded['v'];
      int? version;
      if (v is int) {
        version = v;
      } else if (v is num) {
        version = v.toInt();
      }
      return DecodedQrPayload(
        userId: uid,
        timestamp: ts,
        version: version,
        nonce: decoded['nonce'] is String ? decoded['nonce'] as String : null,
        serviceId: decoded['serviceId'] is String
            ? decoded['serviceId'] as String
            : null,
        signatureB64: decoded['signature'] is String
            ? decoded['signature'] as String
            : null,
      );
    } catch (_) {
      return null;
    }
  }
}

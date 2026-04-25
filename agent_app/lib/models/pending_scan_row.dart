import '../utils/content_hash.dart';

/// One pending row from `local_scans` for POST `/sync/scans`.
class PendingScanRow {
  const PendingScanRow({
    required this.id,
    required this.rawPayload,
    required this.userId,
    required this.payloadTimestamp,
    required this.parseOk,
    required this.scannedAt,
    required this.contentHash,
  });

  final int id;
  final String rawPayload;
  final String? userId;
  final String? payloadTimestamp;
  final bool parseOk;
  final String scannedAt;
  final String contentHash;

  factory PendingScanRow.fromMap(Map<String, Object?> m) {
    final idVal = m['id'];
    final id = idVal is int ? idVal : (idVal as num).toInt();
    final parseVal = m['parse_ok'];
    final parseOk = parseVal is int
        ? parseVal != 0
        : parseVal is bool
            ? parseVal
            : false;
    final raw = m['raw_payload']! as String;
    final uid = m['user_id'] as String?;
    final at = m['scanned_at']! as String;
    final h0 = m['content_hash'] as String?;
    final h = (h0 != null && h0.isNotEmpty)
        ? h0
        : hashAgentScan(userId: uid, rawPayload: raw, scannedAt: at);
    return PendingScanRow(
      id: id,
      rawPayload: raw,
      userId: uid,
      payloadTimestamp: m['payload_timestamp'] as String?,
      parseOk: parseOk,
      scannedAt: at,
      contentHash: h,
    );
  }

  Map<String, dynamic> toSyncJson() => <String, dynamic>{
        'localId': id,
        'rawPayload': rawPayload,
        if (userId != null) 'userId': userId,
        if (payloadTimestamp != null) 'payloadTimestamp': payloadTimestamp,
        'parseOk': parseOk,
        'scannedAt': scannedAt,
        'hash': contentHash,
      };
}

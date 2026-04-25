import '../database/app_database.dart';
import '../models/decoded_qr_payload.dart';

const _maxAge = Duration(minutes: 5);

/// Result of best-effort checks the agent can do **without** the server HMAC secret.
sealed class QrLocalCheck {
  const QrLocalCheck();
}

final class QrLocalOk extends QrLocalCheck {
  const QrLocalOk();
}

final class QrLocalReject extends QrLocalCheck {
  const QrLocalReject(this.message);
  final String message;
}

/// Expiry (clock skew) + v2 **nonce** replay (SQLite). HMAC is validated when scans sync to the API.
Future<QrLocalCheck> validateScanLocally(
  String raw, {
  DecodedQrPayload? parsed,
}) async {
  final p = parsed ?? DecodedQrPayload.tryParse(raw);
  if (p == null) {
    return const QrLocalReject('Unrecognized QR format');
  }
  final at = DateTime.tryParse(p.timestamp);
  if (at == null) {
    return const QrLocalReject('Invalid timestamp in QR');
  }
  if (DateTime.now().toUtc().difference(at.toUtc()) > _maxAge) {
    return const QrLocalReject('This QR is too old (re-generate a new one).');
  }
  if (p.version == 2) {
    if (p.nonce == null || p.nonce!.isEmpty) {
      return const QrLocalReject('v2 QR missing nonce');
    }
    final db = await AgentAppDatabase.instance();
    final ex = await db.query(
      'qr_nonce_cache',
      columns: ['nonce'],
      where: 'nonce = ?',
      whereArgs: [p.nonce!],
      limit: 1,
    );
    if (ex.isNotEmpty) {
      return const QrLocalReject('This QR was already scanned (replay).');
    }
    await db.insert('qr_nonce_cache', {
      'nonce': p.nonce!,
      'seen_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
  return const QrLocalOk();
}

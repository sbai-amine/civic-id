import '../models/pending_scan_row.dart';
import '../utils/content_hash.dart';
import 'app_database.dart';
import 'sync_status.dart';

class OfflineScanRepository {
  OfflineScanRepository._();

  static final OfflineScanRepository instance = OfflineScanRepository._();

  Future<List<PendingScanRow>> fetchPendingRows() async {
    return fetchSyncableRows();
  }

  Future<List<PendingScanRow>> fetchSyncableRows() async {
    final db = await AgentAppDatabase.instance();
    final rows = await db.query(
      'local_scans',
      where: 'sync_status IN (?, ?) AND retry_count < 5',
      whereArgs: [SyncStatus.pending, SyncStatus.failed],
      orderBy: 'id ASC',
    );
    return rows.map(PendingScanRow.fromMap).toList();
  }

  Future<int> countSynced() async {
    final db = await AgentAppDatabase.instance();
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM local_scans WHERE sync_status = ?',
      [SyncStatus.synced],
    );
    final c = r.first['c'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<int> countFailed() async {
    final db = await AgentAppDatabase.instance();
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM local_scans WHERE sync_status = ?',
      [SyncStatus.failed],
    );
    final c = r.first['c'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<int> countSyncing() async {
    final db = await AgentAppDatabase.instance();
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM local_scans WHERE sync_status = ?',
      [SyncStatus.syncing],
    );
    final c = r.first['c'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<int> markSyncedByIds(Iterable<int> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return 0;
    final db = await AgentAppDatabase.instance();
    final placeholders = List.filled(list.length, '?').join(',');
    return db.rawUpdate(
      'UPDATE local_scans SET sync_status = ?, last_error = NULL WHERE id IN ($placeholders)',
      <Object?>[SyncStatus.synced, ...list],
    );
  }

  Future<int> markSyncingByIds(Iterable<int> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return 0;
    final db = await AgentAppDatabase.instance();
    final placeholders = List.filled(list.length, '?').join(',');
    return db.rawUpdate(
      'UPDATE local_scans SET sync_status = ? WHERE id IN ($placeholders)',
      <Object?>[SyncStatus.syncing, ...list],
    );
  }

  Future<int> markFailed(
    List<int> ids, {
    required String message,
  }) async {
    if (ids.isEmpty) return 0;
    final db = await AgentAppDatabase.instance();
    var n = 0;
    for (final id in ids) {
      n += await db.rawUpdate(
        '''
        UPDATE local_scans
        SET sync_status = ?, last_error = ?, retry_count = retry_count + 1
        WHERE id = ?
        ''',
        [SyncStatus.failed, message, id],
      );
    }
    return n;
  }

  Future<int> retryFailedRows({bool resetRetryCount = false}) async {
    final db = await AgentAppDatabase.instance();
    return db.rawUpdate(
      resetRetryCount
          ? "UPDATE local_scans SET sync_status = 'pending', last_error = NULL, retry_count = 0 WHERE sync_status = 'failed'"
          : "UPDATE local_scans SET sync_status = 'pending' WHERE sync_status = 'failed'",
    );
  }

  Future<int> deleteSynced() async {
    final db = await AgentAppDatabase.instance();
    return db.delete(
      'local_scans',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.synced],
    );
  }

  /// Removes every row (for testing / privacy).
  Future<void> clearAll() async {
    final db = await AgentAppDatabase.instance();
    await db.delete('local_scans');
  }

  Future<int> insertPending({
    required String rawPayload,
    String? userId,
    String? payloadTimestamp,
    required bool parseOk,
    String? scannedAt,
  }) async {
    final at = scannedAt ?? DateTime.now().toUtc().toIso8601String();
    final h = hashAgentScan(
      userId: userId,
      rawPayload: rawPayload,
      scannedAt: at,
    );
    final db = await AgentAppDatabase.instance();
    return db.insert(
      'local_scans',
      <String, Object?>{
        'raw_payload': rawPayload,
        'user_id': userId,
        'payload_timestamp': payloadTimestamp,
        'parse_ok': parseOk ? 1 : 0,
        'scanned_at': at,
        'content_hash': h,
        'sync_status': SyncStatus.pending,
      },
    );
  }

  Future<int> countPending() async {
    final db = await AgentAppDatabase.instance();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM local_scans WHERE sync_status = ?',
      [SyncStatus.pending],
    );
    final c = rows.first['c'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }
}

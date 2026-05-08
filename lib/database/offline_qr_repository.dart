import '../models/pending_service_qr_row.dart';
import '../services/token_storage.dart';
import '../utils/content_hash.dart';
import 'app_database.dart';
import 'sync_status.dart';

/// Persists generated service QR payloads: history + sync outbox.
///
/// Every query is scoped to the currently logged-in user's national ID so
/// data is never shared across accounts on the same device.
class OfflineQrRepository {
  OfflineQrRepository._();

  static final OfflineQrRepository instance = OfflineQrRepository._();

  Future<String> _userId() async => await SecureTokenStorage().readUserId() ?? '';

  /// Pending and failed (retry) rows, syncable, oldest first.
  Future<List<PendingServiceQrRow>> fetchSyncableRows() async {
    final nat = await _userId();
    if (nat.isEmpty) return [];
    final db = await AppDatabase.instance();
    final rows = await db.query(
      'local_service_qr',
      where: 'sync_status IN (?, ?) AND retry_count < 5 AND national_id = ?',
      whereArgs: [SyncStatus.pending, SyncStatus.failed, nat],
      orderBy: 'id ASC',
    );
    return rows.map((m) => PendingServiceQrRow.fromMap(m, nationalId: nat)).toList();
  }

  @Deprecated('Use fetchSyncableRows')
  Future<List<PendingServiceQrRow>> fetchPendingRows() => fetchSyncableRows();

  Future<void> repairContentHashesIfNeeded() async {
    final nat = await _userId();
    if (nat.isEmpty) return;
    final db = await AppDatabase.instance();
    final rows = await db.query(
      'local_service_qr',
      where: 'national_id = ?',
      whereArgs: [nat],
    );
    for (final m in rows) {
      final h = m['content_hash'] as String?;
      if (h != null && h.isNotEmpty) continue;
      final p = m['payload']! as String;
      final c = m['created_at']! as String;
      final sid = m['service_id']! as String;
      final idVal = m['id'];
      final id = idVal is int ? idVal : (idVal as num).toInt();
      final hash = hashCitizenQr(
        nationalId: nat,
        serviceId: sid,
        payload: p,
        createdAt: c,
      );
      await db.update(
        'local_service_qr',
        {'content_hash': hash},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<int> countByStatus(String status) async {
    final nat = await _userId();
    if (nat.isEmpty) return 0;
    final db = await AppDatabase.instance();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM local_service_qr WHERE sync_status = ? AND national_id = ?',
      [status, nat],
    );
    final c = rows.first['c'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<int> countSynced() => countByStatus(SyncStatus.synced);
  Future<int> countSyncing() => countByStatus(SyncStatus.syncing);

  Future<int> countPending() async {
    final nat = await _userId();
    if (nat.isEmpty) return 0;
    final db = await AppDatabase.instance();
    final rows = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM local_service_qr WHERE sync_status = 'pending' AND national_id = ?",
      [nat],
    );
    final c = rows.first['c'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<int> countFailed() async {
    final nat = await _userId();
    if (nat.isEmpty) return 0;
    final db = await AppDatabase.instance();
    final rows = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM local_service_qr WHERE sync_status = 'failed' AND national_id = ?",
      [nat],
    );
    final c = rows.first['c'];
    if (c is int) return c;
    if (c is num) return c.toInt();
    return 0;
  }

  Future<int> markSyncedByIds(Iterable<int> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return 0;
    final db = await AppDatabase.instance();
    final placeholders = List.filled(list.length, '?').join(',');
    return db.rawUpdate(
      'UPDATE local_service_qr SET sync_status = ?, last_error = NULL WHERE id IN ($placeholders)',
      <Object?>[SyncStatus.synced, ...list],
    );
  }

  Future<int> markSyncingByIds(Iterable<int> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return 0;
    final db = await AppDatabase.instance();
    final placeholders = List.filled(list.length, '?').join(',');
    return db.rawUpdate(
      'UPDATE local_service_qr SET sync_status = ? WHERE id IN ($placeholders)',
      <Object?>[SyncStatus.syncing, ...list],
    );
  }

  Future<int> markFailed(
    List<int> ids, {
    required String message,
  }) async {
    if (ids.isEmpty) return 0;
    final db = await AppDatabase.instance();
    var n = 0;
    for (final id in ids) {
      n += await db.rawUpdate(
        '''
        UPDATE local_service_qr
        SET sync_status = ?, last_error = ?, retry_count = retry_count + 1
        WHERE id = ?
        ''',
        [SyncStatus.failed, message, id],
      );
    }
    return n;
  }

  Future<int> retryFailedRows({bool resetRetryCount = false}) async {
    final nat = await _userId();
    if (nat.isEmpty) return 0;
    final db = await AppDatabase.instance();
    return db.rawUpdate(
      resetRetryCount
          ? "UPDATE local_service_qr SET sync_status = 'pending', last_error = NULL, retry_count = 0 WHERE sync_status = 'failed' AND national_id = ?"
          : "UPDATE local_service_qr SET sync_status = 'pending' WHERE sync_status = 'failed' AND national_id = ?",
      [nat],
    );
  }

  /// Resets a single failed row back to pending (and clears retry counter so
  /// it can be re-attempted even after the auto-retry cap was reached).
  Future<int> resetRowToPending(int id) async {
    final nat = await _userId();
    if (nat.isEmpty) return 0;
    final db = await AppDatabase.instance();
    return db.rawUpdate(
      "UPDATE local_service_qr SET sync_status = 'pending', last_error = NULL, retry_count = 0 WHERE id = ? AND national_id = ?",
      [id, nat],
    );
  }

  /// Inserts a new history row; returns SQLite id.
  Future<int> insertPending({
    required String serviceId,
    required String serviceName,
    required String payload,
  }) async {
    final nat = await _userId();
    if (nat.isEmpty) {
      throw StateError('User ID not set');
    }
    final created = DateTime.now().toUtc().toIso8601String();
    final hash = hashCitizenQr(
      nationalId: nat,
      serviceId: serviceId,
      payload: payload,
      createdAt: created,
    );
    final db = await AppDatabase.instance();
    return db.insert(
      'local_service_qr',
      <String, Object?>{
        'national_id': nat,
        'service_id': serviceId,
        'service_name': serviceName,
        'payload': payload,
        'content_hash': hash,
        'created_at': created,
        'sync_status': SyncStatus.pending,
        'retry_count': 0,
      },
    );
  }

  /// All generated QRs for the current user, newest first.
  Future<List<ServiceQrHistoryRow>> listHistory() async {
    final nat = await _userId();
    if (nat.isEmpty) return [];
    final db = await AppDatabase.instance();
    final rows = await db.query(
      'local_service_qr',
      where: 'national_id = ?',
      whereArgs: [nat],
      orderBy: 'id DESC',
    );
    return rows.map(ServiceQrHistoryRow.fromMap).toList();
  }
}

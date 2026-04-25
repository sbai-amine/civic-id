/// Outbox state for rows in `local_service_qr`.
abstract final class SyncStatus {
  static const String pending = 'pending';
  static const String syncing = 'syncing';
  static const String synced = 'synced';
  static const String failed = 'failed';
}

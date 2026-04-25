/// Rows with [pending] are queued until a future background sync succeeds.
abstract final class SyncStatus {
  static const String pending = 'pending';
  static const String syncing = 'syncing';
  static const String failed = 'failed';
  static const String synced = 'synced';
}

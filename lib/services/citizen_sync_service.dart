import 'dart:async';

import '../database/offline_qr_repository.dart';
import 'citizen_sync_api_service.dart';
import 'token_storage.dart';

/// Silent, idempotent background sync of pending citizen QR rows.
///
/// Called from app resume, dashboard mount, and just after a QR is generated.
/// All errors swallow on purpose — the user does not see a queue, so a failed
/// attempt simply leaves rows in pending/failed for the next trigger.
class CitizenSyncService {
  CitizenSyncService._();

  static final CitizenSyncService instance = CitizenSyncService._();

  final CitizenSyncApiService _api = CitizenSyncApiService();
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();

  Future<void>? _inFlight;

  /// Returns when the current attempt finishes. If one is already running,
  /// joins it. Never throws.
  Future<void> trigger() {
    return _inFlight ??= _run().whenComplete(() => _inFlight = null);
  }

  Future<void> _run() async {
    try {
      await OfflineQrRepository.instance.repairContentHashesIfNeeded();
      final rows = await OfflineQrRepository.instance.fetchSyncableRows();
      if (rows.isEmpty) return;

      await OfflineQrRepository.instance.markSyncingByIds(rows.map((e) => e.id));
      final result = await _api.pushServiceQrBatch(rows: rows);

      if (result.error != null) {
        await OfflineQrRepository.instance
            .markFailed(rows.map((e) => e.id).toList(), message: result.error!);
        return;
      }

      await OfflineQrRepository.instance.markSyncedByIds(result.localIds);
      await _tokenStorage.saveLastSyncTimeUtc(DateTime.now().toUtc());
    } catch (_) {
      // Silent: nothing visible to the citizen.
    }
  }
}

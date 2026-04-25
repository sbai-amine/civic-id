import '../utils/content_hash.dart';

/// One row from `local_service_qr` for upload to POST `/sync/service-qr`.
class PendingServiceQrRow {
  const PendingServiceQrRow({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.payload,
    required this.createdAt,
    required this.nationalId,
    required this.contentHash,
  });

  final int id;
  final String serviceId;
  final String serviceName;
  final String payload;
  final String createdAt;
  final String nationalId;
  final String contentHash;

  factory PendingServiceQrRow.fromMap(
    Map<String, Object?> m, {
    required String nationalId,
  }) {
    final idVal = m['id'];
    final id = idVal is int ? idVal : (idVal as num).toInt();
    final h = m['content_hash'] as String?;
    final p = m['payload']! as String;
    final c = m['created_at']! as String;
    final sid = m['service_id']! as String;
    final sname = m['service_name']! as String;
    final effectiveHash = (h != null && h.isNotEmpty)
        ? h
        : hashCitizenQr(
            nationalId: nationalId,
            serviceId: sid,
            payload: p,
            createdAt: c,
          );
    return PendingServiceQrRow(
      id: id,
      serviceId: sid,
      serviceName: sname,
      payload: p,
      createdAt: c,
      nationalId: nationalId,
      contentHash: effectiveHash,
    );
  }

  Map<String, dynamic> toSyncJson() => <String, dynamic>{
        'localId': id,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'payload': payload,
        'createdAt': createdAt,
        'hash': contentHash,
      };
}

/// History row (same table, all statuses).
class ServiceQrHistoryRow {
  const ServiceQrHistoryRow({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.payload,
    required this.createdAt,
    required this.syncStatus,
  });

  final int id;
  final String serviceId;
  final String serviceName;
  final String payload;
  final String createdAt;
  final String syncStatus;

  factory ServiceQrHistoryRow.fromMap(Map<String, Object?> m) {
    final idVal = m['id'];
    final id = idVal is int ? idVal : (idVal as num).toInt();
    return ServiceQrHistoryRow(
      id: id,
      serviceId: m['service_id']! as String,
      serviceName: m['service_name']! as String,
      payload: m['payload']! as String,
      createdAt: m['created_at']! as String,
      syncStatus: m['sync_status']! as String,
    );
  }
}

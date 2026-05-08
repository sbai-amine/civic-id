import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../database/offline_qr_repository.dart';
import '../database/sync_status.dart';
import '../i18n/app_i18n.dart';
import '../models/pending_service_qr_row.dart' show ServiceQrHistoryRow;
import '../services/citizen_sync_service.dart';
import '../widgets/app_shell.dart';

class QrHistoryScreen extends StatefulWidget {
  const QrHistoryScreen({super.key});

  @override
  State<QrHistoryScreen> createState() => _QrHistoryScreenState();
}

class _QrHistoryScreenState extends State<QrHistoryScreen> {
  var _rows = <ServiceQrHistoryRow>[];
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final list = await OfflineQrRepository.instance.listHistory();
    if (!mounted) return;
    setState(() {
      _rows = list;
      _loading = false;
    });
  }

  Future<void> _retryRow(ServiceQrHistoryRow r) async {
    await OfflineQrRepository.instance.resetRowToPending(r.id);
    unawaited(CitizenSyncService.instance.trigger().then((_) {
      if (mounted) _refresh();
    }));
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: AppI18n.t(context, 'nav.qrHistory'),
      current: CivicDestination.history,
      actions: [
        IconButton(
          onPressed: _loading ? null : _refresh,
          icon: const Icon(Icons.refresh),
          tooltip: AppI18n.t(context, 'history.refreshTooltip'),
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rows.isEmpty
              ? Center(
                  child: Text(
                    AppI18n.t(context, 'history.empty'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final r = _rows[i];
                    final failed = r.syncStatus == SyncStatus.failed;
                    final friendly = _friendlyStatus(context, r.syncStatus);
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(AppI18n.tOr(
                              context,
                              'service.${r.serviceId}.name',
                              r.serviceName,
                            )),
                            subtitle: Text('$friendly · ${_formatDate(r.createdAt)}'),
                            leading: const Icon(Icons.qr_code_2),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openRow(context, r),
                          ),
                          if (failed)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 12, 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 18, color: Color(0xFFB3261E)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppI18n.t(context, 'history.couldNotSave'),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _retryRow(r),
                                    child: Text(AppI18n.t(context, 'common.retry')),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String iso) {
    final t = DateTime.tryParse(iso);
    if (t == null) return '';
    final l = t.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  String _friendlyStatus(BuildContext context, String syncStatus) {
    switch (syncStatus) {
      case SyncStatus.synced:
        return AppI18n.t(context, 'history.status.submitted');
      case SyncStatus.failed:
        return AppI18n.t(context, 'history.status.couldNotSave');
      default:
        return AppI18n.t(context, 'history.status.savedOnDevice');
    }
  }

  void _openRow(BuildContext context, ServiceQrHistoryRow r) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppI18n.tOr(
                  context,
                  'service.${r.serviceId}.name',
                  r.serviceName,
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (r.payload.isNotEmpty)
                SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: r.payload,
                    version: QrVersions.auto,
                  ),
                )
              else
                Text(AppI18n.t(context, 'history.emptyPayload')),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  final localizedName = AppI18n.tOr(
                    context,
                    'service.${r.serviceId}.name',
                    r.serviceName,
                  );
                  Share.share(
                    r.payload,
                    subject: AppI18n.tf(context, 'history.shareSubject',
                        args: {'name': localizedName}),
                  );
                },
                icon: const Icon(Icons.ios_share_outlined),
                label: Text(AppI18n.t(context, 'history.share')),
              ),
            ],
          ),
        );
      },
    );
  }
}

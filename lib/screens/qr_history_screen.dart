import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../database/offline_qr_repository.dart';
import '../i18n/app_i18n.dart';
import '../models/pending_service_qr_row.dart' show ServiceQrHistoryRow;
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
                    return Card(
                      child: ListTile(
                        title: Text(r.serviceName),
                        subtitle: Text('${r.syncStatus} · id ${r.id}'),
                        leading: const Icon(Icons.qr_code_2),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openRow(context, r),
                      ),
                    );
                  },
                ),
    );
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
                r.serviceName,
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
                  Share.share(
                    r.payload,
                    subject: AppI18n.tf(context, 'history.shareSubject', args: {'name': r.serviceName}),
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

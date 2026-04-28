import 'package:flutter/material.dart';

import '../database/offline_scan_repository.dart';
import '../i18n/app_i18n.dart';
import '../services/agent_sync_api_service.dart';
import '../widgets/agent_shell.dart';
import 'agent_settings_screen.dart';
import 'result_screen.dart';
import 'scan_screen.dart';

/// Landing screen: scan action, sync status, and upload of pending scans.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AgentSyncApiService _syncApi = AgentSyncApiService();

  int _pending = 0;
  int _synced = 0;
  int _failed = 0;
  int _syncingRows = 0;
  bool _syncing = false;
  String? _syncMessage;

  @override
  void initState() {
    super.initState();
    _refreshCounts();
  }

  Future<void> _refreshCounts() async {
    final p = await OfflineScanRepository.instance.countPending();
    final s = await OfflineScanRepository.instance.countSynced();
    final f = await OfflineScanRepository.instance.countFailed();
    final x = await OfflineScanRepository.instance.countSyncing();
    if (!mounted) return;
    setState(() {
      _pending = p;
      _synced = s;
      _failed = f;
      _syncingRows = x;
    });
  }

  Future<void> _onSyncPressed() async {
    setState(() {
      _syncing = true;
      _syncMessage = null;
    });

    try {
      final rows = await OfflineScanRepository.instance.fetchSyncableRows();
      if (!mounted) return;
      if (rows.isEmpty) {
        setState(() => _syncMessage = AppI18n.t(context, 'home.nothingPending'));
        await _refreshCounts();
        return;
      }
      await OfflineScanRepository.instance.markSyncingByIds(rows.map((e) => e.id));

      final result = await _syncApi.pushScanBatch(rows: rows);
      if (!mounted) return;

      if (result.error != null) {
        await OfflineScanRepository.instance
            .markFailed(rows.map((e) => e.id).toList(), message: result.error!);
        if (!mounted) return;
        setState(() => _syncMessage = result.error);
        await _refreshCounts();
        return;
      }

      await OfflineScanRepository.instance.markSyncedByIds(result.localIds);
      if (!mounted) return;
      setState(
        () => _syncMessage =
            AppI18n.tf(context, 'home.syncedCount', args: {'count': '${result.localIds.length}'}),
      );
      await _refreshCounts();
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _onScanPressed() async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const ScanScreen(),
      ),
    );
    if (!mounted || raw == null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(rawPayload: raw),
      ),
    );
    if (context.mounted) await _refreshCounts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AgentShell(
      title: AppI18n.t(context, 'home.title'),
      current: AgentDestination.home,
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AgentSettingsScreen()),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF06695D), Color(0xFF0A8275)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppI18n.t(context, 'home.verifyQr'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppI18n.t(context, 'home.subtitle'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppI18n.t(context, 'home.offlineScans'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatusChip(
                  label: AppI18n.t(context, 'home.pending'),
                  value: '$_pending',
                  color: theme.colorScheme.tertiaryContainer,
                  onColor: theme.colorScheme.onTertiaryContainer,
                ),
                _StatusChip(
                  label: AppI18n.t(context, 'home.syncing'),
                  value: '$_syncingRows',
                  color: const Color(0xFFE7EEFF),
                  onColor: const Color(0xFF1E3A8A),
                ),
                _StatusChip(
                  label: AppI18n.t(context, 'home.synced'),
                  value: '$_synced',
                  color: theme.colorScheme.secondaryContainer,
                  onColor: theme.colorScheme.onSecondaryContainer,
                ),
                _StatusChip(
                  label: AppI18n.t(context, 'home.failed'),
                  value: '$_failed',
                  color: theme.colorScheme.errorContainer,
                  onColor: theme.colorScheme.onErrorContainer,
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _syncing ? null : _onSyncPressed,
              icon: _syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(AppI18n.t(context, 'home.syncNow')),
            ),
            if (_syncMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _syncMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _failed > 0
                      ? () async {
                          await OfflineScanRepository.instance.retryFailedRows();
                          if (!mounted) return;
                          await _refreshCounts();
                        }
                      : null,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(AppI18n.t(context, 'home.retryFailed')),
                ),
                OutlinedButton.icon(
                  onPressed: (_failed + _pending + _syncingRows) > 0
                      ? () async {
                          await OfflineScanRepository.instance.retryFailedRows(
                            resetRetryCount: true,
                          );
                          if (!mounted) return;
                          await _refreshCounts();
                        }
                      : null,
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: Text(AppI18n.t(context, 'home.resetQueue')),
                ),
              ],
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(AppI18n.t(context, 'home.deleteSyncedTitle')),
                    content: Text(AppI18n.t(context, 'home.deleteSyncedBody')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: Text(AppI18n.t(context, 'common.cancel')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: Text(AppI18n.t(context, 'common.delete')),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await OfflineScanRepository.instance.deleteSynced();
                  if (context.mounted) await _refreshCounts();
                }
              },
              child: Text(AppI18n.t(context, 'home.deleteSynced')),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text(AppI18n.t(context, 'home.clearAllTitle')),
                    content: Text(AppI18n.t(context, 'home.clearAllBody')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: Text(AppI18n.t(context, 'common.cancel')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: Text(AppI18n.t(context, 'common.clearAll')),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await OfflineScanRepository.instance.clearAll();
                  if (context.mounted) await _refreshCounts();
                }
              },
              child: Text(AppI18n.t(context, 'home.clearLocal')),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _onScanPressed,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(AppI18n.t(context, 'home.scanQr')),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: onColor.withValues(alpha: 0.85),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

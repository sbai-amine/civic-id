import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database/offline_qr_repository.dart';
import '../i18n/app_i18n.dart';
import '../models/pending_service_qr_row.dart' show ServiceQrHistoryRow;
import '../services/app_settings.dart';
import '../services/biometric_auth_service.dart';
import '../services/citizen_sync_api_service.dart';
import '../services/token_storage.dart';
import '../utils/app_routes.dart';
import '../widgets/app_shell.dart';

/// Post-login home: services entry + offline QR sync.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();
  final CitizenSyncApiService _syncApi = CitizenSyncApiService();
  final AppSettings _settings = AppSettings();
  final BiometricAuthService _bio = BiometricAuthService();

  int _pending = 0;
  int _synced = 0;
  int _failed = 0;
  int _syncingRows = 0;
  List<ServiceQrHistoryRow> _recent = const [];
  bool _syncing = false;
  String? _syncMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await OfflineQrRepository.instance.repairContentHashesIfNeeded();
    await _refreshCounts();
  }

  Future<void> _refreshCounts() async {
    final p = await OfflineQrRepository.instance.countPending();
    final s = await OfflineQrRepository.instance.countSynced();
    final f = await OfflineQrRepository.instance.countFailed();
    final x = await OfflineQrRepository.instance.countSyncing();
    final h = await OfflineQrRepository.instance.listHistory();
    if (!mounted) return;
    setState(() {
      _pending = p;
      _synced = s;
      _failed = f;
      _syncingRows = x;
      _recent = h.take(3).toList();
    });
  }

  Future<void> _onSyncPressed() async {
    final needBio = await _settings.requireBiometricOnSync;
    if (needBio && !kIsWeb) {
      final ok = await _bio.authenticate(reason: 'Confirm sync to server');
      if (!ok) return;
    }
    setState(() {
      _syncing = true;
      _syncMessage = null;
    });

    try {
      final rows = await OfflineQrRepository.instance.fetchSyncableRows();
      if (!mounted) return;
      if (rows.isEmpty) {
        setState(() => _syncMessage = AppI18n.t(context, 'sync.nothingPending'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppI18n.t(context, 'sync.alreadySynced'))),
        );
        await _refreshCounts();
        return;
      }
      await OfflineQrRepository.instance.markSyncingByIds(rows.map((e) => e.id));

      final result = await _syncApi.pushServiceQrBatch(rows: rows);
      if (!mounted) return;

      if (result.error != null) {
        await OfflineQrRepository.instance
            .markFailed(rows.map((e) => e.id).toList(), message: result.error!);
        if (!mounted) return;
        setState(() => _syncMessage = result.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error!)),
        );
        await _refreshCounts();
        return;
      }

      await OfflineQrRepository.instance.markSyncedByIds(result.localIds);
      if (!mounted) return;
      await _tokenStorage.saveLastSyncTimeUtc(DateTime.now().toUtc());
      setState(
        () => _syncMessage =
            AppI18n.tf(context, 'sync.uploadedRecords', args: {'count': '${result.localIds.length}'}),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppI18n.tf(context, 'sync.syncedRecords', args: {'count': '${result.localIds.length}'}))),
      );
      await _refreshCounts();
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  void _toProfile() {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }

  void _toHistory() {
    Navigator.of(context).pushNamed(AppRoutes.qrHistory);
  }

  Future<void> _signOut() async {
    await _tokenStorage.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppShell(
      title: AppI18n.t(context, 'app.name'),
      current: CivicDestination.dashboard,
      actions: [
        IconButton(
          onPressed: _toHistory,
          icon: const Icon(Icons.history),
          tooltip: AppI18n.t(context, 'nav.qrHistory'),
        ),
        IconButton(
          onPressed: _toProfile,
          icon: const Icon(Icons.person_outline),
          tooltip: AppI18n.t(context, 'nav.profile'),
        ),
        TextButton(onPressed: _signOut, child: Text(AppI18n.t(context, 'common.signOut'))),
      ],
      child: ListView(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F4CBA), Color(0xFF2A67D6)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2A0F4CBA),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppI18n.t(context, 'dashboard.welcome')} 👋',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppI18n.t(context, 'dashboard.hero.subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(label: AppI18n.t(context, 'dashboard.pending'), value: '$_pending', color: const Color(0xFFFFF4D7)),
              _StatusChip(label: AppI18n.t(context, 'dashboard.syncing'), value: '$_syncingRows', color: const Color(0xFFE5EDFF)),
              _StatusChip(label: AppI18n.t(context, 'dashboard.synced'), value: '$_synced', color: const Color(0xFFDDF6E8)),
              _StatusChip(label: AppI18n.t(context, 'dashboard.failed'), value: '$_failed', color: const Color(0xFFFFE3E1)),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _syncing ? null : _onSyncPressed,
            icon: _syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(_syncing ? AppI18n.t(context, 'dashboard.syncing') : AppI18n.t(context, 'dashboard.syncNow')),
          ),
          if (_syncMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _syncMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _failed > 0
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final msg = AppI18n.t(context, 'sync.failedToPending');
                        await OfflineQrRepository.instance.retryFailedRows();
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                        await _refreshCounts();
                      }
                    : null,
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(AppI18n.t(context, 'dashboard.retryFailed')),
              ),
              OutlinedButton.icon(
                onPressed: (_failed + _pending + _syncingRows) > 0
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final msg = AppI18n.t(context, 'sync.queueReset');
                        await OfflineQrRepository.instance.retryFailedRows(resetRetryCount: true);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                        await _refreshCounts();
                      }
                    : null,
                icon: const Icon(Icons.cleaning_services_outlined),
                label: Text(AppI18n.t(context, 'dashboard.resetQueue')),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppI18n.t(context, 'dashboard.services.title'),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppI18n.t(context, 'dashboard.services.subtitle'),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.services),
                    icon: const Icon(Icons.grid_view_rounded),
                    label: Text(AppI18n.t(context, 'dashboard.browseServices')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppI18n.t(context, 'dashboard.recent.title'),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  if (_recent.isEmpty)
                    Text(
                      AppI18n.t(context, 'dashboard.recent.empty'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  for (final row in _recent)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.qr_code_2_outlined),
                      title: Text(row.serviceName, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(row.syncStatus),
                      trailing: Text('#${row.id}'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF3B4252),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

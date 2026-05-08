import 'dart:async';

import 'package:flutter/material.dart';

import '../database/offline_qr_repository.dart';
import '../database/sync_status.dart';
import '../i18n/app_i18n.dart';
import '../models/pending_service_qr_row.dart' show ServiceQrHistoryRow;
import '../services/citizen_sync_service.dart';
import '../services/token_storage.dart';
import '../utils/app_routes.dart';
import '../widgets/app_shell.dart';

/// Post-login home: welcome and a single primary call to action (Services).
///
/// Sync is intentionally invisible here — the only signal a citizen ever sees
/// is a subtle offline banner when QR codes are still waiting to upload.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();

  int _waitingUpload = 0;
  List<ServiceQrHistoryRow> _recent = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _refresh();
    unawaited(_syncAndRefresh());
  }

  Future<void> _syncAndRefresh() async {
    await CitizenSyncService.instance.trigger();
    if (!mounted) return;
    await _refresh();
  }

  Future<void> _refresh() async {
    final pending = await OfflineQrRepository.instance.countPending();
    final failed = await OfflineQrRepository.instance.countFailed();
    final syncing = await OfflineQrRepository.instance.countSyncing();
    final history = await OfflineQrRepository.instance.listHistory();
    if (!mounted) return;
    setState(() {
      _waitingUpload = pending + failed + syncing;
      _recent = history.take(5).toList();
    });
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
      child: RefreshIndicator(
        onRefresh: _syncAndRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
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
                    const SizedBox(height: 10),
                    Text(
                      AppI18n.t(context, 'dashboard.hero.subtitle'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.services),
                      icon: const Icon(Icons.grid_view_rounded),
                      label: Text(AppI18n.t(context, 'dashboard.browseServices')),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F4CBA),
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_waitingUpload > 0) ...[
              const SizedBox(height: 14),
              _OfflineBanner(),
            ],
            const SizedBox(height: 22),
            _RecentActivity(rows: _recent, onSeeAll: _toHistory),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.rows, required this.onSeeAll});

  final List<ServiceQrHistoryRow> rows;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppI18n.t(context, 'dashboard.recent.title'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (rows.isNotEmpty)
                    TextButton(
                      onPressed: onSeeAll,
                      child: Text(AppI18n.t(context, 'dashboard.recent.seeAll')),
                    ),
                ],
              ),
            ),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
                child: Text(
                  AppI18n.t(context, 'dashboard.recent.empty'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final row in rows)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.qr_code_2_outlined),
                  title: Text(
                    AppI18n.tOr(
                      context,
                      'service.${row.serviceId}.name',
                      row.serviceName,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${_friendlyStatus(context, row.syncStatus)} · ${_formatDate(row.createdAt)}',
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String _friendlyStatus(BuildContext context, String status) {
    switch (status) {
      case SyncStatus.synced:
        return AppI18n.t(context, 'history.status.submitted');
      case SyncStatus.failed:
        return AppI18n.t(context, 'history.status.couldNotSave');
      default:
        return AppI18n.t(context, 'history.status.savedOnDevice');
    }
  }

  String _formatDate(String iso) {
    final t = DateTime.tryParse(iso);
    if (t == null) return '';
    final l = t.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}

/// Tiny piece of context that only appears when QR codes are still waiting to
/// be uploaded. No counts, no buttons — just reassurance.
class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_off_outlined, color: Color(0xFFB28704), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppI18n.t(context, 'dashboard.offlineBanner'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6D4C00),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

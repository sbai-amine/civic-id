import 'package:flutter/material.dart';

import '../i18n/app_i18n.dart';
import '../services/admin_api_service.dart';
import '../widgets/app_shell.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminApiService _admin = AdminApiService();
  final TextEditingController _verifyId = TextEditingController();
  bool _loading = true;
  String? _error;
  String? _verifyStatus;
  Map<String, dynamic> _kpis = const {};
  List<Map<String, dynamic>> _logs = const [];
  List<Map<String, dynamic>> _keys = const [];

  @override
  void dispose() {
    _verifyId.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_admin.hasAdminKey) {
      setState(() {
        _loading = false;
        _error = AppI18n.t(context, 'admin.missingKey');
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final kpis = await _admin.fetchKpis();
      final logs = await _admin.fetchAuditLogs();
      final keys = await _admin.fetchAgentKeys();
      if (!mounted) return;
      setState(() {
        _kpis = (kpis['data']?['kpis'] as Map?)?.cast<String, dynamic>() ?? const {};
        _logs = logs;
        _keys = keys;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleKey(Map<String, dynamic> key) async {
    final id = key['id']?.toString();
    if (id == null || id.isEmpty) return;
    final disabled = key['disabled'] == true;
    try {
      if (disabled) {
        await _admin.enableAgentKey(id);
      } else {
        await _admin.disableAgentKey(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(disabled ? AppI18n.t(context, 'admin.keyEnabled') : AppI18n.t(context, 'admin.keyDisabled'))),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: AppI18n.t(context, 'admin.title'),
      current: CivicDestination.profile,
      actions: [
        IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh)),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, textAlign: TextAlign.center))
              : ListView(
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _KpiCard(label: AppI18n.t(context, 'admin.users'), value: '${_kpis['users'] ?? 0}'),
                        _KpiCard(label: AppI18n.t(context, 'admin.serviceRecords'), value: '${_kpis['serviceRecords'] ?? 0}'),
                        _KpiCard(label: AppI18n.t(context, 'admin.agentScans'), value: '${_kpis['agentScans'] ?? 0}'),
                        _KpiCard(label: AppI18n.t(context, 'admin.activeKeys'), value: '${_kpis['activeAgentKeys'] ?? 0}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppI18n.t(context, 'admin.agentKeys'), style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            for (final key in _keys)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  key['disabled'] == true ? Icons.block : Icons.vpn_key_outlined,
                                ),
                                title: Text(key['label']?.toString() ?? key['key_id']?.toString() ?? 'key'),
                                subtitle: Text(key['key_id']?.toString() ?? ''),
                                trailing: FilledButton.tonal(
                                  onPressed: () => _toggleKey(key),
                                  child: Text(key['disabled'] == true ? AppI18n.t(context, 'admin.enable') : AppI18n.t(context, 'admin.disable')),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppI18n.t(context, 'admin.logs'), style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            if (_logs.isEmpty) Text(AppI18n.t(context, 'admin.noLogs')),
                            for (final log in _logs.take(30))
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.history, size: 18),
                                title: Text(log['action']?.toString() ?? 'action'),
                                subtitle: Text(
                                  '${log['actor_type'] ?? '-'} · ${log['created_at'] ?? ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppI18n.t(context, 'admin.verifyDoc'), style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _verifyId,
                              decoration: InputDecoration(
                                labelText: AppI18n.t(context, 'admin.verifyDocId'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                final id = _verifyId.text.trim();
                                if (id.isEmpty) return;
                                setState(() => _verifyStatus = null);
                                try {
                                  final data = await _admin.verifySignedDocument(id);
                                  final ok = data['verification']?['ok'] == true;
                                  final hash = data['verification']?['payloadHash']?.toString() ?? '-';
                                  if (!mounted) return;
                                  setState(() => _verifyStatus = AppI18n.tf(context, 'admin.signatureValid', args: {'ok': '$ok', 'hash': hash}));
                                } catch (e) {
                                  if (!mounted) return;
                                  setState(() => _verifyStatus = e.toString().replaceFirst('Bad state: ', ''));
                                }
                              },
                              icon: const Icon(Icons.verified_outlined),
                              label: Text(AppI18n.t(context, 'admin.verifySignature')),
                            ),
                            if (_verifyStatus != null) ...[
                              const SizedBox(height: 8),
                              SelectableText(_verifyStatus!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

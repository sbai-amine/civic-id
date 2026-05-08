import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database/offline_scan_repository.dart';
import '../i18n/app_i18n.dart';
import '../services/agent_key_storage.dart';
import 'agent_setup_screen.dart';
import 'government_issuance_screen.dart';

/// Lets the operator view (masked) the current key, replace it, or clear it.
class AgentSettingsScreen extends StatefulWidget {
  const AgentSettingsScreen({super.key});

  @override
  State<AgentSettingsScreen> createState() => _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends State<AgentSettingsScreen> {
  String? _key;
  String? _label;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final k = await AgentKeyStorage.instance.readKey();
    final l = await AgentKeyStorage.instance.readLabel();
    if (!mounted) return;
    setState(() {
      _key = k;
      _label = l;
      _loading = false;
    });
  }

  String _mask(String s) {
    if (s.length <= 8) return '•' * s.length;
    return '${s.substring(0, 4)}…${s.substring(s.length - 4)}';
  }

  Future<void> _replace() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AgentSetupScreen()),
    );
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear agent key?'),
        content: const Text(
          'The verifier app will not be able to sync scans until a new key is entered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AgentKeyStorage.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AgentSetupScreen()),
      (_) => false,
    );
  }

  /// Two-step destructive prompt: typed reason required to enable Confirm.
  Future<bool> _confirmDestructive({
    required String title,
    required String body,
  }) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final canConfirm = reasonController.text.trim().length >= 3;
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(body, style: Theme.of(ctx).textTheme.bodyMedium),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText:
                          AppI18n.t(ctx, 'settings.confirmReason'),
                      hintText: AppI18n.t(
                          ctx, 'settings.confirmReasonHint'),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setLocal(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(AppI18n.t(ctx, 'common.cancel')),
                ),
                FilledButton(
                  onPressed: canConfirm
                      ? () => Navigator.of(ctx).pop(true)
                      : null,
                  child: Text(AppI18n.t(ctx, 'common.delete')),
                ),
              ],
            );
          },
        );
      },
    );
    reasonController.dispose();
    return result ?? false;
  }

  Future<void> _deleteSynced() async {
    final ok = await _confirmDestructive(
      title: AppI18n.t(context, 'home.deleteSyncedTitle'),
      body: AppI18n.t(context, 'home.deleteSyncedBody'),
    );
    if (!ok || !mounted) return;
    await OfflineScanRepository.instance.deleteSynced();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppI18n.t(context, 'settings.deleteSynced'))),
    );
  }

  Future<void> _clearAll() async {
    final ok = await _confirmDestructive(
      title: AppI18n.t(context, 'home.clearAllTitle'),
      body: AppI18n.t(context, 'home.clearAllBody'),
    );
    if (!ok || !mounted) return;
    await OfflineScanRepository.instance.clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppI18n.t(context, 'settings.clearAll'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (kDebugMode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: const Color(0xFFFFF8E1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.science_outlined,
                                    color: Color(0xFFB28704)),
                                const SizedBox(width: 8),
                                Text(
                                  'Demo tools',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF6D4C00),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Visible only in debug builds. Simulates the in-person issuance flow that creates BridgeID accounts.',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF5D4037)),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const GovernmentIssuanceScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.account_balance_outlined),
                              label: const Text('Government Issuance Portal'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppI18n.t(context, 'settings.localData.title'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppI18n.t(context, 'settings.localData.subtitle'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _deleteSynced,
                              icon: const Icon(Icons.cleaning_services_outlined),
                              label: Text(
                                  AppI18n.t(context, 'settings.deleteSynced')),
                            ),
                            OutlinedButton.icon(
                              onPressed: _clearAll,
                              icon: const Icon(Icons.delete_forever_outlined),
                              label: Text(
                                  AppI18n.t(context, 'settings.clearAll')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agent API key',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_label != null && _label!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'Label: $_label',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        Text(
                          (_key == null || _key!.isEmpty)
                              ? 'No key set'
                              : 'Key: ${_mask(_key!)}',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: _replace,
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('Replace key'),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: (_key == null || _key!.isEmpty)
                                  ? null
                                  : _clear,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Clear'),
                            ),
                          ],
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

import 'package:flutter/material.dart';

import '../services/agent_key_storage.dart';
import 'agent_setup_screen.dart';

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

import 'package:flutter/material.dart';

import '../database/offline_scan_repository.dart';
import '../i18n/app_i18n.dart';
import '../models/decoded_qr_payload.dart';
import '../utils/qr_scan_local_validation.dart';

/// Shows [userID] and [timestamp] after a successful scan (or parse error).
///
/// Persists each result to SQLite with `sync_status = pending` for a future sync job.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.rawPayload});

  /// Raw string returned from the scanner (expected JSON).
  final String rawPayload;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _testPayload = TextEditingController();
  bool _persisted = false;
  String? _persistError;
  String? _localInvalidReason;

  @override
  void initState() {
    super.initState();
    _testPayload.text = widget.rawPayload;
    WidgetsBinding.instance.addPostFrameCallback((_) => _persistScan());
  }

  @override
  void dispose() {
    _testPayload.dispose();
    super.dispose();
  }

  Future<void> _persistScan() async {
    final parsed = DecodedQrPayload.tryParse(widget.rawPayload);
    final check = await validateScanLocally(widget.rawPayload, parsed: parsed);
    if (!mounted) return;
    if (check is QrLocalReject) {
      setState(() {
        _localInvalidReason = check.message;
        _persisted = false;
      });
      return;
    }
    try {
      await OfflineScanRepository.instance.insertPending(
        rawPayload: widget.rawPayload,
        userId: parsed?.userId,
        payloadTimestamp: parsed?.timestamp,
        parseOk: parsed != null,
      );
      if (!mounted) return;
      setState(() => _persisted = true);
    } catch (e, st) {
      assert(() {
        debugPrint('OfflineScanRepository.insertPending: $e\n$st');
        return true;
      }());
      if (!mounted) return;
      setState(() {
        _persistError =
            AppI18n.t(context, 'result.persistError');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsed = DecodedQrPayload.tryParse(widget.rawPayload);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppI18n.t(context, 'result.title')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_localInvalidReason != null) ...[
            Material(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppI18n.tf(context, 'result.notSaved', args: {'reason': '$_localInvalidReason'}),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (_persisted) ...[
            Material(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppI18n.t(context, 'result.stored'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (_persistError != null) ...[
            Material(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _persistError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (parsed != null) ...[
            Text(
              AppI18n.t(context, 'result.decoded'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _ResultTile(
              label: AppI18n.t(context, 'result.userId'),
              value: parsed.userId,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _ResultTile(
              label: AppI18n.t(context, 'result.timestamp'),
              value: parsed.timestamp,
              icon: Icons.schedule,
            ),
          ] else ...[
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              AppI18n.t(context, 'result.couldNotRead'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppI18n.t(context, 'result.expected'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppI18n.t(context, 'result.raw'),
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SelectableText(
              widget.rawPayload,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
          const SizedBox(height: 32),
          const SizedBox(height: 8),
          Text(AppI18n.t(context, 'result.testPayload'), style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _testPayload,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              labelText: AppI18n.t(context, 'result.override'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final t = _testPayload.text;
              if (t.trim().isEmpty) return;
              final p = DecodedQrPayload.tryParse(t);
              try {
                await OfflineScanRepository.instance.insertPending(
                  rawPayload: t,
                  userId: p?.userId,
                  payloadTimestamp: p?.timestamp,
                  parseOk: p != null,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppI18n.t(context, 'result.savedTestRow')),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: Text(AppI18n.t(context, 'result.saveAdditional')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(AppI18n.t(context, 'result.done')),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

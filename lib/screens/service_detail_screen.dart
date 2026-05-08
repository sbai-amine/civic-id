import 'package:flutter/material.dart';

import '../i18n/app_i18n.dart';
import '../models/civic_service.dart';
import '../services/crypto_api_service.dart';
import 'service_qr_screen.dart';

/// Full service metadata and action to open QR generation.
class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key, required this.service});

  final CivicService service;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _cryptoApi = CryptoApiService();
  bool _signing = false;

  /// Returns the localized required-documents list for [service]. The i18n key
  /// stores items joined by `\n`; falls back to the backend list verbatim.
  List<String> _localizedRequiredDocs(BuildContext context, CivicService service) {
    final joined = service.requiredDocuments.join('\n');
    final localized = AppI18n.tOr(
      context,
      'service.${service.id}.requiredDocs',
      joined,
    );
    return localized
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = widget.service;

    final description = AppI18n.tOr(
      context,
      'service.${service.id}.description',
      service.description,
    );
    final fees = AppI18n.tOr(
      context,
      'service.${service.id}.fees',
      service.fees,
    );
    final docs = _localizedRequiredDocs(context, service);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppI18n.t(context, 'serviceDetail.title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppI18n.tOr(context, 'service.${service.id}.name', service.name),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppI18n.t(context, 'serviceDetail.description'), style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (fees.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppI18n.t(context, 'serviceDetail.fees'), style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text(fees, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ],
          if (docs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppI18n.t(context, 'serviceDetail.requiredDocs'), style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    ...docs.map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(d)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => ServiceQrScreen(service: widget.service),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_2),
            label: Text(AppI18n.t(context, 'serviceDetail.showAtCounter')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _signing
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _signing = true);
                    try {
                      final signed = await _cryptoApi.signServiceRequest(
                        serviceId: service.id,
                        serviceName: service.name,
                        note: 'Citizen digital signature for service request',
                      );
                      if (!context.mounted) return;
                      final docId = signed['id']?.toString() ?? '-';
                      final hash = signed['payload_hash']?.toString() ?? '-';
                      messenger.showSnackBar(
                        SnackBar(content: Text(AppI18n.tf(context, 'serviceDetail.signedCreated', args: {'id': docId}))),
                      );
                      await showDialog<void>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: Text(AppI18n.t(context, 'serviceDetail.requestSigned')),
                          content: SelectableText('Document ID: $docId\nPayload hash: $hash'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(c).pop(),
                              child: Text(AppI18n.t(context, 'common.ok')),
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
                      );
                    } finally {
                      if (mounted) setState(() => _signing = false);
                    }
                  },
            icon: _signing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.draw_outlined),
            label: Text(_signing
                ? AppI18n.t(context, 'serviceDetail.signing')
                : AppI18n.t(context, 'serviceDetail.submitSigned')),
          ),
          const SizedBox(height: 8),
          Text(
            AppI18n.t(context, 'serviceDetail.actionsHint'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

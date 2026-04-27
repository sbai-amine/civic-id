import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../database/offline_qr_repository.dart';
import '../i18n/app_i18n.dart';
import '../models/civic_service.dart';
import '../services/token_storage.dart';
import '../utils/service_qr_payload.dart';

/// After choosing a service, user can generate a QR holding [userID] + timestamp.
class ServiceQrScreen extends StatefulWidget {
  const ServiceQrScreen({super.key, required this.service});

  final CivicService service;

  @override
  State<ServiceQrScreen> createState() => _ServiceQrScreenState();
}

class _ServiceQrScreenState extends State<ServiceQrScreen> {
  final SecureTokenStorage _storage = SecureTokenStorage();

  String? _qrData;
  String? _error;
  bool _pendingSaved = false;
  String? _saveError;

  Future<void> _generateQr() async {
    setState(() {
      _error = null;
      _qrData = null;
      _pendingSaved = false;
      _saveError = null;
    });

    final userId = await _storage.readUserId();
    if (!mounted) return;

    if (userId == null || userId.isEmpty) {
      setState(() {
        _error = AppI18n.t(context, 'serviceQr.missingUser');
      });
      return;
    }

    final hmacKey = await _storage.readQrHmacKey();
    if (!mounted) return;
    if (hmacKey == null || hmacKey.isEmpty) {
      setState(() {
        _error = AppI18n.t(context, 'serviceQr.secureKeyMissing');
      });
      return;
    }

    final payload = ServiceQrPayload.buildV2(
      userId: userId,
      serviceId: widget.service.id,
      hmacKeyHex: hmacKey,
    );
    setState(() => _qrData = payload);

    try {
      await OfflineQrRepository.instance.insertPending(
        serviceId: widget.service.id,
        serviceName: widget.service.name,
        payload: payload,
      );
      if (!mounted) return;
      setState(() => _pendingSaved = true);
    } catch (e, st) {
      assert(() {
        debugPrint('OfflineQrRepository.insertPending: $e\n$st');
        return true;
      }());
      if (!mounted) return;
      setState(() {
        _saveError = AppI18n.t(context, 'serviceQr.saveFailed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppI18n.t(context, 'serviceQr.title')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            AppI18n.tOr(context, 'service.${widget.service.id}.name', widget.service.name),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.service.id,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppI18n.t(context, 'serviceQr.description'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _generateQr,
            icon: const Icon(Icons.qr_code_2_outlined),
            label: Text(AppI18n.t(context, 'serviceQr.generate')),
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            Material(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_saveError != null) ...[
            const SizedBox(height: 12),
            Material(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.storage_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _saveError!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_pendingSaved) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Chip(
                avatar: Icon(
                  Icons.cloud_upload_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(AppI18n.t(context, 'serviceQr.savedPending')),
              ),
            ),
          ],
          if (_qrData != null) ...[
            const SizedBox(height: 32),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x220F4CBA),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppI18n.t(context, 'serviceQr.scanTitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              AppI18n.t(context, 'serviceQr.payloadHint'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

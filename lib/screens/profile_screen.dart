import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/app_settings.dart';
import '../services/biometric_auth_service.dart';
import '../services/locale_controller.dart';
import '../services/token_storage.dart';
import '../utils/app_routes.dart';
import '../config/api_config.dart';
import '../i18n/app_i18n.dart';
import '../widgets/app_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = SecureTokenStorage();
  final _settings = AppSettings();
  final _bio = BiometricAuthService();
  String? _nationalId;
  String? _version;
  DateTime? _lastSync;
  bool _bioApp = false;
  bool _bioSync = false;
  bool _bioOk = false;
  String _languageCode = 'en';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await _storage.readUserId();
    final sync = await _storage.readLastSyncTimeUtc();
    _bioApp = await _settings.requireBiometricOnAppOpen;
    _bioSync = await _settings.requireBiometricOnSync;
    _bioOk = await _bio.canUse;
    _languageCode = await _settings.preferredLocaleCode;
    if (kIsWeb) {
      _version = 'web';
    } else {
      final p = await PackageInfo.fromPlatform();
      _version = '${p.version} (${p.buildNumber})';
    }
    if (!mounted) return;
    setState(() {
      _nationalId = id;
      _lastSync = sync;
    });
  }

  Future<void> _signOut() async {
    final ctx = context;
    await _storage.clearSession();
    if (!ctx.mounted) return;
    Navigator.of(ctx).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppShell(
      title: AppI18n.t(context, 'profile.title'),
      current: CivicDestination.profile,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Tile(
                    label: AppI18n.t(context, 'profile.nationalId'),
                    value: _nationalId ?? '—',
                  ),
                  const SizedBox(height: 12),
                  _Tile(
                    label: AppI18n.t(context, 'profile.lastSync'),
                    value: _lastSync == null
                        ? AppI18n.t(context, 'profile.never')
                        : _format(_lastSync!),
                  ),
                  const SizedBox(height: 12),
                  _Tile(
                    label: AppI18n.t(context, 'profile.appVersion'),
                    value: _version ?? '…',
                  ),
                ],
              ),
            ),
          ),
          if (_bioOk) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppI18n.t(context, 'profile.security'),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(AppI18n.t(context, 'profile.bioOpen')),
                      value: _bioApp,
                      onChanged: (v) async {
                        final ok = !v || await _bio.authenticate(reason: 'Enable app lock');
                        if (!ok) return;
                        await _settings.setRequireBiometricOnAppOpen(v);
                        if (mounted) setState(() => _bioApp = v);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(AppI18n.t(context, 'profile.bioSync')),
                      value: _bioSync,
                      onChanged: (v) async {
                        final ok = !v || await _bio.authenticate(reason: 'Enable sync protection');
                        if (!ok) return;
                        await _settings.setRequireBiometricOnSync(v);
                        if (mounted) setState(() => _bioSync = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (kIsWeb) ...[
            const SizedBox(height: 8),
            Text(
              AppI18n.t(context, 'profile.bio.web'),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppI18n.t(context, 'profile.language.title'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppI18n.t(context, 'profile.language.subtitle'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _languageCode,
                    decoration: InputDecoration(
                      labelText: AppI18n.t(context, 'profile.appLanguage'),
                    ),
                    items: [
                      for (final opt in AppI18n.languageOptions)
                        DropdownMenuItem<String>(
                          value: opt.code,
                          child: Text(opt.label),
                        ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      await _settings.setPreferredLocaleCode(value);
                      await LocaleController.instance.setLocaleCode(value);
                      if (!mounted) return;
                      setState(() => _languageCode = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (ApiConfig.adminApiKey.trim().isNotEmpty) ...[
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.admin),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: Text(AppI18n.t(context, 'profile.openAdmin')),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.tonalIcon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
            label: Text(AppI18n.t(context, 'common.signOut')),
          ),
        ],
      ),
    );
  }

  String _format(DateTime t) {
    final l = t.toLocal();
    return '${l.year}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')} '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      );
  }
}

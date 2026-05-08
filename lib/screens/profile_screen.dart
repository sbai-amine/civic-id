import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../i18n/app_i18n.dart';
import '../services/app_settings.dart';
import '../services/biometric_auth_service.dart';
import '../services/locale_controller.dart';
import '../services/token_storage.dart';
import '../utils/app_routes.dart';
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
  String? _fullName;
  String? _version;
  bool _bioApp = false;
  bool _bioOk = false;
  String _languageCode = 'en';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await _storage.readUserId();
    final name = await _storage.readFullName();
    _bioApp = await _settings.requireBiometricOnAppOpen;
    _bioOk = await _bio.canUse;
    _languageCode = await _settings.preferredLocaleCode;
    if (kIsWeb) {
      _version = 'web';
    } else {
      final p = await PackageInfo.fromPlatform();
      _version = p.version;
    }
    if (!mounted) return;
    setState(() {
      _nationalId = id;
      _fullName = (name ?? '').trim().isEmpty ? null : name!.trim();
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

  /// Returns initials when a name is set, otherwise null (caller renders an
  /// icon fallback). Showing a digit from the national ID isn't useful.
  String? _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return null;
    final parts = n.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppShell(
      title: AppI18n.t(context, 'profile.title'),
      current: CivicDestination.profile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          _ProfileHeader(
            initials: _initials(_fullName),
            name: _fullName ?? AppI18n.t(context, 'profile.unnamedAccount'),
            nationalId: _nationalId ?? '—',
            verified: (_nationalId ?? '').isNotEmpty,
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _SectionHeader(
              icon: Icons.language_rounded,
              text: AppI18n.t(context, 'profile.language.title'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
          ),
          if (_bioOk) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _SectionHeader(
                icon: Icons.lock_outline_rounded,
                text: AppI18n.t(context, 'profile.security'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                child: SwitchListTile(
                  title: Text(AppI18n.t(context, 'profile.bioOpen')),
                  subtitle: Text(
                    AppI18n.t(context, 'profile.bioOpen.subtitle'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  secondary: const Icon(Icons.fingerprint_rounded),
                  value: _bioApp,
                  onChanged: (v) async {
                    final ok = !v ||
                        await _bio.authenticate(reason: 'Enable app lock');
                    if (!ok) return;
                    await _settings.setRequireBiometricOnAppOpen(v);
                    if (mounted) setState(() => _bioApp = v);
                  },
                ),
              ),
            ),
          ],
          if (kIsWeb) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppI18n.t(context, 'profile.bio.web'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _SectionHeader(
              icon: Icons.info_outline_rounded,
              text: AppI18n.t(context, 'profile.about'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.smartphone_rounded),
                title: Text(AppI18n.t(context, 'profile.appVersion')),
                trailing: Text(
                  _version ?? '…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonalIcon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded),
              label: Text(AppI18n.t(context, 'common.signOut')),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.nationalId,
    required this.verified,
  });

  /// Null when no full name is known — caller renders a person icon instead.
  final String? initials;
  final String name;
  final String nationalId;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F4CBA), Color(0xFF2A67D6)],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white,
              child: initials == null
                  ? const Icon(
                      Icons.person_outline_rounded,
                      size: 36,
                      color: Color(0xFF0F4CBA),
                    )
                  : Text(
                      initials!,
                      style: const TextStyle(
                        color: Color(0xFF0F4CBA),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppI18n.t(context, 'profile.nationalId'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.4,
                    ),
                  ),
                  SelectableText(
                    nationalId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (verified) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            AppI18n.t(context, 'profile.accountVerified'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

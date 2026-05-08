import 'package:flutter/material.dart';

import '../models/civic_service.dart';
import '../i18n/app_i18n.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../utils/app_routes.dart';
import '../widgets/app_shell.dart';
import 'service_detail_screen.dart';

/// Loads civic services from GET `/services` using the stored JWT.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final SecureTokenStorage _tokenStorage = SecureTokenStorage();
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;
  List<CivicService> _services = const [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  /// Uses session (refresh) to load the service catalog.
  Future<void> _loadServices() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final has = await _tokenStorage.readAccessToken();
    if (!mounted) return;

    if (has == null || has.isEmpty) {
      setState(() {
        _loading = false;
        _error = AppI18n.t(context, 'services.notSignedIn');
        _services = const [];
      });
      return;
    }

    final result = await _api.fetchServices();
    if (!mounted) return;

    setState(() {
      _loading = false;
      _error = result.error;
      _services = result.services;
    });
  }

  void _onServiceTap(CivicService service) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ServiceDetailScreen(service: service),
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppShell(
      title: AppI18n.t(context, 'services.title'),
      current: CivicDestination.services,
      child: RefreshIndicator(
        onRefresh: _loadServices,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: List.generate(
          3,
          (i) => const _ServiceSkeleton(),
        ),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.cloud_off_outlined,
            size: 56,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            AppI18n.t(context, 'services.loadFailed'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _loadServices,
            icon: const Icon(Icons.refresh),
            label: Text(AppI18n.t(context, 'common.retry')),
          ),
          if (_error == AppI18n.t(context, 'services.notSignedIn')) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _goToLogin,
              child: Text(AppI18n.t(context, 'services.goSignIn')),
            ),
          ],
        ],
      );
    }

    if (_services.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Text(
            AppI18n.t(context, 'services.empty'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loadServices,
            child: Text(AppI18n.t(context, 'common.refresh')),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final service = _services[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _onServiceTap(service),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.article_outlined, color: Color(0xFF0F4CBA)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppI18n.tOr(context, 'service.${service.id}.name', service.name),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppI18n.tOr(
                            context,
                            'service.${service.id}.description',
                            service.description.isEmpty ? service.id : service.description,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ServiceSkeleton extends StatelessWidget {
  const _ServiceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECF5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 120, color: const Color(0xFFE8ECF5)),
                  const SizedBox(height: 8),
                  Container(height: 10, width: double.infinity, color: const Color(0xFFE8ECF5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

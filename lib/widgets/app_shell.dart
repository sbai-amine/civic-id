import 'package:flutter/material.dart';

import '../i18n/app_i18n.dart';
import '../utils/app_routes.dart';

enum CivicDestination { dashboard, services, history, profile }

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    required this.current,
    this.actions = const [],
    this.floatingActionButton,
  });

  final String title;
  final Widget child;
  final CivicDestination current;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.sizeOf(context).width >= 1000;
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (!large) {
      return Scaffold(
        drawer: _MobileDrawer(current: current),
        appBar: AppBar(
          title: Text(title),
          actions: actions,
        ),
        floatingActionButton: floatingActionButton,
        body: content,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(current: current),
          Expanded(
            child: Column(
              children: [
                Material(
                  elevation: 1,
                  color: Theme.of(context).colorScheme.surface,
                  child: SafeArea(
                    bottom: false,
                    child: SizedBox(
                      height: 64,
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Spacer(),
                          ...actions,
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _NavTarget {
  const _NavTarget({
    required this.destination,
    required this.label,
    required this.icon,
    required this.route,
  });

  final CivicDestination destination;
  final String label;
  final IconData icon;
  final String route;
}

const _targets = <_NavTarget>[
  _NavTarget(
    destination: CivicDestination.dashboard,
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    route: AppRoutes.dashboard,
  ),
  _NavTarget(
    destination: CivicDestination.services,
    label: 'Services',
    icon: Icons.grid_view_rounded,
    route: AppRoutes.services,
  ),
  _NavTarget(
    destination: CivicDestination.history,
    label: 'QR history',
    icon: Icons.history_rounded,
    route: AppRoutes.qrHistory,
  ),
  _NavTarget(
    destination: CivicDestination.profile,
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    route: AppRoutes.profile,
  ),
];

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.current});

  final CivicDestination current;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F4CBA), Color(0xFF123D90)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Text(
                AppI18n.t(context, 'app.name'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            for (final target in _targets)
              _DesktopNavItem(
                target: target,
                selected: target.destination == current,
              ),
          ],
        ),
      ),
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  const _DesktopNavItem({
    required this.target,
    required this.selected,
  });

  final _NavTarget target;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? Colors.white.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _goTo(context, target),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(target.icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  target.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.current});

  final CivicDestination current;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F4CBA), Color(0xFF123D90)],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                AppI18n.t(context, 'app.name'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          for (final target in _targets)
            ListTile(
              leading: Icon(target.icon),
              title: Text(target.label),
              selected: target.destination == current,
              onTap: () {
                Navigator.of(context).pop();
                _goTo(context, target);
              },
            ),
        ],
      ),
    );
  }
}

void _goTo(BuildContext context, _NavTarget target) {
  final currentName = ModalRoute.of(context)?.settings.name;
  if (currentName == target.route) return;
  Navigator.of(context).pushReplacementNamed(target.route);
}

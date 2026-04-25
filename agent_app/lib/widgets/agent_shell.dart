import 'package:flutter/material.dart';

import '../i18n/app_i18n.dart';

enum AgentDestination { home }

class AgentShell extends StatelessWidget {
  const AgentShell({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
    this.current = AgentDestination.home,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final AgentDestination current;

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
        appBar: AppBar(title: Text(title), actions: actions),
        body: content,
        floatingActionButton: floatingActionButton,
      );
    }
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 236,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF06695D), Color(0xFF0A4E46)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppI18n.t(context, 'shell.brand'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _NavItem(icon: Icons.verified_user_outlined, label: 'Verification'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Material(
                  elevation: 1,
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

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

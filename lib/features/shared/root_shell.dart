import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class RootShell extends StatelessWidget {
  const RootShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    ('/', Icons.shield_moon_rounded, 'Home'),
    ('/chat', Icons.auto_awesome, 'AI Chat'),
    ('/learn', Icons.school_rounded, 'Learn'),
    ('/profile', Icons.person_rounded, 'Profile'),
  ];

  int _indexFor(String location) {
    final i = _tabs.indexWhere((t) => t.$1 == location);
    return i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFor(location);
    final isWide = MediaQuery.of(context).size.width >= 800;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppColors.surface,
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(_tabs[i].$1),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final t in _tabs)
                  NavigationRailDestination(icon: Icon(t.$2), label: Text(t.$3)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        destinations: [
          for (final t in _tabs) NavigationDestination(icon: Icon(t.$2), label: t.$3),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:archive/core/constants/app_colors.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({super.key, required this.child});

  static const _tabs = [
    _TabItem(path: '/', icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
    _TabItem(path: '/map', icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Map'),
    _TabItem(path: '/saved', icon: Icons.bookmark_outline, activeIcon: Icons.bookmark, label: 'Saved'),
    _TabItem(path: '/profile', icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _getCurrentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          if (i != currentIndex) context.go(_tabs[i].path);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.activeIcon, color: AppColors.primary),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/saved')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}

class _TabItem {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

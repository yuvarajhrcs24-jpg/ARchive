import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:archive/presentation/screens/home/home_screen.dart';
import 'package:archive/presentation/screens/map/map_screen.dart';
import 'package:archive/presentation/screens/place_detail/place_detail_screen.dart';
import 'package:archive/presentation/screens/saved/saved_screen.dart';
import 'package:archive/presentation/screens/profile/profile_screen.dart';
import 'package:archive/presentation/widgets/bottom_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithBottomNav(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MapScreen(),
          ),
        ),
        GoRoute(
          path: '/saved',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SavedScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/place/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlaceDetailScreen(placeId: id);
      },
    ),
  ],
);

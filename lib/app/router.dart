import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/presentation/settings/alert_settings_screen.dart';
import 'package:pomodoro_app/presentation/settings/appearance_settings_screen.dart';
import 'package:pomodoro_app/presentation/settings/focus_settings_screen.dart';
import 'package:pomodoro_app/presentation/settings/platform_settings_screen.dart';
import 'package:pomodoro_app/presentation/settings/settings_screen.dart';
import 'package:pomodoro_app/presentation/settings/statistics_settings_screen.dart';
import 'package:pomodoro_app/presentation/settings/time_settings_screen.dart';
import 'package:pomodoro_app/presentation/settings/whitelist_settings_screen.dart';
import 'package:pomodoro_app/presentation/shared/home_shell.dart';
import 'package:pomodoro_app/presentation/statistic/statistic_screen.dart';
import 'package:pomodoro_app/presentation/tag/tag_form_screen.dart';
import 'package:pomodoro_app/presentation/tag/tag_list_screen.dart';
import 'package:pomodoro_app/presentation/timer/timer_screen.dart';
import 'package:pomodoro_app/presentation/timeline/timeline_screen.dart';
import 'package:pomodoro_app/presentation/timeline/timeline_session_detail_screen.dart';

/// Deep link placeholder for notification tap (BR-NAV-001).
final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/timer',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timer',
                builder: (context, state) {
                  final sessionId = state.uri.queryParameters['sessionId'];
                  return TimerScreen(deepLinkSessionId: sessionId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                builder: (context, state) => const TimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistic',
                builder: (context, state) => const StatisticScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/tags',
        builder: (context, state) => const TagListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const TagFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                TagFormScreen(tagId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: '/settings/focus',
        builder: (context, state) => const FocusSettingsScreen(),
        routes: [
          GoRoute(
            path: 'whitelist',
            builder: (context, state) => const WhitelistSettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings/alert',
        builder: (context, state) => const AlertSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/appearance',
        builder: (context, state) => const AppearanceSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/time',
        builder: (context, state) => const TimeSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/statistics',
        builder: (context, state) => const StatisticsSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/platform',
        builder: (context, state) => const PlatformSettingsScreen(),
      ),
      GoRoute(
        path: '/timeline/session/:id',
        builder: (context, state) =>
            TimelineSessionDetailScreen(sessionId: state.pathParameters['id']!),
      ),
    ],
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/statistic/statistic_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({required this.navigationShell, super.key});

  static const statisticBranchIndex = 2;

  final StatefulNavigationShell navigationShell;

  void _onTap(WidgetRef ref, int index) {
    if (index == statisticBranchIndex) {
      ref.read(statisticQueryProvider.notifier).state = StatisticQuery.defaults;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasActiveSession =
        ref.watch(hasActiveSessionProvider).valueOrNull ?? false;
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(ref, index),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: hasActiveSession,
              child: const Icon(Icons.timer_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: hasActiveSession,
              child: const Icon(Icons.timer),
            ),
            label: l10n.navTimer,
          ),
          NavigationDestination(
            icon: const Icon(Icons.view_timeline_outlined),
            selectedIcon: const Icon(Icons.view_timeline),
            label: l10n.navTimeline,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navStatistic,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

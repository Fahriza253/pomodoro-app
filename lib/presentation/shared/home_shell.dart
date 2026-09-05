import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/app_layout.dart';
import 'package:pomodoro_app/presentation/statistic/statistic_providers.dart';
import 'package:pomodoro_app/presentation/timer/timer_actions.dart';
import 'package:pomodoro_app/presentation/timer/timer_providers.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({required this.navigationShell, super.key});

  static const timerBranchIndex = 0;
  static const statisticBranchIndex = 2;

  final StatefulNavigationShell navigationShell;

  Future<void> _onTap(BuildContext context, WidgetRef ref, int index) async {
    final leavingTimer =
        navigationShell.currentIndex == timerBranchIndex &&
        index != timerBranchIndex;
    if (leavingTimer) {
      final coordinator = ref.read(timerCoordinatorProvider);
      if (coordinator.currentViewState.phase == EnginePhase.sessionComplete) {
        // Navigate away from soft session-complete = Done.
        final ok = await runTimerAction(
          context,
          ref,
          () => coordinator.dismissSessionComplete(),
        );
        if (!ok) {
          return;
        }
      }
    }
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
    final navTheme = NavigationBarTheme.of(context);
    // Match M3 NavigationBar surface so the full-bleed strip matches the bar.
    final barColor =
        navTheme.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainer;

    return Scaffold(
      body: navigationShell,
      // Full-bleed chrome; destinations capped/centered (ticket bottom-nav 02).
      // heightFactor: 1 — Center would expand to fill the Scaffold slot and zero the body.
      bottomNavigationBar: Material(
        color: barColor,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kAppContentMaxWidth),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => _onTap(context, ref, index),
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
          ),
        ),
      ),
    );
  }
}

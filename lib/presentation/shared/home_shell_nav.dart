import 'package:flutter/material.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';

/// Phosphor bottom-nav glyphs per `docs/design/MASTER.md` (24px, 48dp target).
Widget homeShellNavGlyph(IconData icon) {
  return SizedBox(
    width: 48,
    height: 48,
    child: Center(child: Icon(icon, size: 24)),
  );
}

/// M3 [NavigationDestination]s for the four main tabs.
List<NavigationDestination> homeShellNavigationDestinations({
  required bool hasActiveSession,
  required AppLocalizations l10n,
}) {
  return [
    NavigationDestination(
      icon: Badge(
        isLabelVisible: hasActiveSession,
        child: homeShellNavGlyph(HomeShellPhosphorIcons.timer(selected: false)),
      ),
      selectedIcon: Badge(
        isLabelVisible: hasActiveSession,
        child: homeShellNavGlyph(HomeShellPhosphorIcons.timer(selected: true)),
      ),
      label: l10n.navTimer,
    ),
    NavigationDestination(
      icon: homeShellNavGlyph(HomeShellPhosphorIcons.clock(selected: false)),
      selectedIcon: homeShellNavGlyph(HomeShellPhosphorIcons.clock(selected: true)),
      label: l10n.navTimeline,
    ),
    NavigationDestination(
      icon: homeShellNavGlyph(HomeShellPhosphorIcons.chartBar(selected: false)),
      selectedIcon: homeShellNavGlyph(
        HomeShellPhosphorIcons.chartBar(selected: true),
      ),
      label: l10n.navStatistic,
    ),
    NavigationDestination(
      icon: homeShellNavGlyph(HomeShellPhosphorIcons.gear(selected: false)),
      selectedIcon: homeShellNavGlyph(HomeShellPhosphorIcons.gear(selected: true)),
      label: l10n.navSettings,
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';

/// Gap from the 24px nav glyph to its label.
const kHomeShellNavIconLabelGap = 10.0;

/// Phosphor bottom-nav glyphs per `docs/design/MASTER.md` (24px glyph).
Widget homeShellNavGlyph(IconData icon) {
  return SizedBox(
    width: 48,
    height: 24,
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
      tooltip: '',
    ),
    NavigationDestination(
      icon: homeShellNavGlyph(
        HomeShellPhosphorIcons.clockCounterClockwise(selected: false),
      ),
      selectedIcon: homeShellNavGlyph(
        HomeShellPhosphorIcons.clockCounterClockwise(selected: true),
      ),
      label: l10n.navTimeline,
      tooltip: '',
    ),
    NavigationDestination(
      icon: homeShellNavGlyph(HomeShellPhosphorIcons.chartBar(selected: false)),
      selectedIcon: homeShellNavGlyph(
        HomeShellPhosphorIcons.chartBar(selected: true),
      ),
      label: l10n.navStatistic,
      tooltip: '',
    ),
    NavigationDestination(
      icon: homeShellNavGlyph(HomeShellPhosphorIcons.gear(selected: false)),
      selectedIcon: homeShellNavGlyph(HomeShellPhosphorIcons.gear(selected: true)),
      label: l10n.navSettings,
      tooltip: '',
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/shared/home_shell_nav.dart';

/// Chrome for the main [NavigationBar]: selection is icon fill only (MASTER).
NavigationBarThemeData homeShellNavigationBarTheme() {
  return const NavigationBarThemeData(
    indicatorColor: Colors.transparent,
    overlayColor: WidgetStatePropertyAll(Colors.transparent),
    backgroundColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    // M3 stacks a 32px indicator behind a 24px glyph (4px below the icon).
    labelPadding: EdgeInsets.only(top: kHomeShellNavIconLabelGap - 4),
  );
}

/// Disables ink splash/highlight for destinations under [homeShellNavigationBarTheme].
ThemeData homeShellNavigationBarWrapperTheme(ThemeData base) {
  return base.copyWith(
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    navigationBarTheme: homeShellNavigationBarTheme(),
  );
}
import 'package:flutter/material.dart';

/// Chrome for the main [NavigationBar]: selection is icon fill only (MASTER).
NavigationBarThemeData homeShellNavigationBarTheme() {
  return const NavigationBarThemeData(
    indicatorColor: Colors.transparent,
    overlayColor: WidgetStatePropertyAll(Colors.transparent),
    backgroundColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
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
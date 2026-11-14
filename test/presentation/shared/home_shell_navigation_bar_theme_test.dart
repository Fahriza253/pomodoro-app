import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/shared/home_shell_navigation_bar_theme.dart';

void main() {
  test('shell nav theme removes indicator and interaction overlays', () {
    final theme = homeShellNavigationBarTheme();
    expect(theme.indicatorColor, Colors.transparent);
    expect(theme.overlayColor?.resolve(<WidgetState>{}), Colors.transparent);
    expect(theme.overlayColor?.resolve({WidgetState.hovered}), Colors.transparent);
    expect(theme.overlayColor?.resolve({WidgetState.pressed}), Colors.transparent);
  });

  test('wrapper theme disables ink splash', () {
    final wrapped = homeShellNavigationBarWrapperTheme(ThemeData.light());
    expect(wrapped.splashFactory, same(NoSplash.splashFactory));
    expect(wrapped.highlightColor, Colors.transparent);
    expect(wrapped.hoverColor, Colors.transparent);
  });
}
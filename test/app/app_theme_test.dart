import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/theme/app_theme.dart';
import 'package:pomodoro_app/app/theme/material_theme.dart';

void main() {
  test('light and dark themes use MaterialTheme color schemes', () {
    expect(
      AppThemeData.light().colorScheme.primary,
      MaterialTheme.lightScheme().primary,
    );
    expect(
      AppThemeData.dark().colorScheme.primary,
      MaterialTheme.darkScheme().primary,
    );
  });

  test('default tag hex matches light primary', () {
    const hex = AppThemeData.defaultTagColorHex;
    final parsed = Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    expect(parsed, MaterialTheme.lightScheme().primary);
  });
}

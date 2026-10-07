import 'package:flutter/material.dart';

import 'package:pomodoro_app/app/theme/material_theme.dart';

/// App-wide theme entry point. Palettes live in [MaterialTheme].
abstract final class AppThemeData {
  /// Default tag hex for new rows (matches light `ColorScheme.primary`).
  static const defaultTagColorHex = '#2C638B';

  static const brandPrimaryLight = Color(0xff2c638b);
  static const brandPrimaryDark = Color(0xff99ccfa);

  static final MaterialTheme _material = MaterialTheme(
    ThemeData(useMaterial3: true).textTheme,
  );

  static ThemeData light() => _material.light();

  static ThemeData dark() => _material.dark();
}

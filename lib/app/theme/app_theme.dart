import 'package:flutter/material.dart';

import 'package:pomodoro_app/app/theme/app_text_theme.dart';
import 'package:pomodoro_app/app/theme/material_theme.dart';

/// App-wide theme entry point. Palettes live in [MaterialTheme].
abstract final class AppThemeData {
  static const brandPrimaryLight = Color(0xff2c638b);
  static const brandPrimaryDark = Color(0xff99ccfa);

  static MaterialTheme? _material;

  static MaterialTheme get _resolvedMaterial =>
      _material ??= MaterialTheme(buildAppTextTheme());

  static ThemeData light() => _resolvedMaterial.light();

  static ThemeData dark() => _resolvedMaterial.dark();
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter-backed Material 3 typography per `docs/design/MASTER.md`.
TextTheme buildAppTextTheme([TextTheme? base]) {
  final m3 = base ?? ThemeData(useMaterial3: true).textTheme;
  final inter = _interTextTheme(m3);
  return inter.copyWith(
    displaySmall: inter.displaySmall?.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );
}

TextTheme _interTextTheme(TextTheme m3) {
  if (GoogleFonts.config.allowRuntimeFetching) {
    return GoogleFonts.interTextTheme(m3);
  }
  return m3.apply(
    fontFamily: 'Inter',
    bodyColor: m3.bodyLarge?.color,
    displayColor: m3.displayLarge?.color,
  );
}

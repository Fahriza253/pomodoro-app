import 'package:flutter/material.dart';

/// Data-visualization series palette per `docs/design/MASTER.md` (max six).
List<Color> chartSeriesColors(ColorScheme scheme) => [
  scheme.primary,
  scheme.tertiary,
  scheme.secondary,
  scheme.primaryContainer,
  scheme.outline,
  scheme.onSurfaceVariant.withValues(alpha: 0.7),
];

Color chartSeriesColorForIndex(ColorScheme scheme, int index) {
  final palette = chartSeriesColors(scheme);
  return palette[index % palette.length];
}

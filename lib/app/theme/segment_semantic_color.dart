import 'package:flutter/material.dart';

import 'package:pomodoro_app/domain/common/enums.dart';

/// Maps [SegmentType] to Material 3 [ColorScheme] emphasis per `docs/design/MASTER.md`.
///
/// Session phase color only — never derived from Tag hex.
Color segmentSemanticColor(ColorScheme scheme, SegmentType type) =>
    switch (type) {
      SegmentType.focus => scheme.primary,
      SegmentType.shortRest => scheme.tertiary,
      SegmentType.longRest => scheme.secondary,
      SegmentType.flexible => scheme.primary,
    };

/// Chip / emphasis surfaces aligned with [segmentSemanticColor].
({Color background, Color foreground, Color accent}) segmentSemanticEmphasis(
  ColorScheme scheme,
  SegmentType type,
) =>
    switch (type) {
      SegmentType.focus => (
        background: scheme.primaryContainer.withValues(alpha: 0.55),
        foreground: scheme.onPrimaryContainer,
        accent: scheme.primary,
      ),
      SegmentType.shortRest => (
        background: scheme.tertiaryContainer.withValues(alpha: 0.55),
        foreground: scheme.onTertiaryContainer,
        accent: scheme.tertiary,
      ),
      SegmentType.longRest => (
        background: scheme.secondaryContainer.withValues(alpha: 0.55),
        foreground: scheme.onSecondaryContainer,
        accent: scheme.secondary,
      ),
      SegmentType.flexible => (
        background: scheme.primaryContainer.withValues(alpha: 0.55),
        foreground: scheme.onPrimaryContainer,
        accent: scheme.primary,
      ),
    };

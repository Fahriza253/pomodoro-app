import 'package:flutter/physics.dart';

/// Critically damped settle used after a pointer releases a gesture surface.
const kFluidSettleSpring = SpringDescription(
  mass: 1,
  stiffness: 400,
  damping: 40,
);

const kFluidRubberBandCoefficient = 0.55;

/// Compresses distance past a rest edge into a shorter visual offset.
double fluidRubberBand({
  required double overscroll,
  required double dimension,
  double coefficient = kFluidRubberBandCoefficient,
}) {
  if (overscroll <= 0 || dimension <= 0 || coefficient <= 0) {
    return 0;
  }
  return (1 - 1 / (overscroll * coefficient / dimension + 1)) * dimension;
}

/// Linear drag mapped to a visual value. Below [min] clamps; above [max]
/// rubber-bands. No undershoot past [min].
double fluidVisualOverscroll(
  double linear, {
  required double min,
  required double max,
}) {
  if (linear <= min) {
    return min;
  }
  if (linear <= max) {
    return linear;
  }
  final dimension = max - min;
  if (dimension <= 0) {
    return max;
  }
  return max + fluidRubberBand(overscroll: linear - max, dimension: dimension);
}

double tagSelectSheetHeight({
  required double viewportHeight,
  required double contentHeight,
}) {
  if (viewportHeight <= 0) {
    return 0;
  }
  final minH = viewportHeight * kTagSelectSheetMinHeightFraction;
  final maxH = viewportHeight * kTagSelectSheetMaxHeightFraction;
  return contentHeight.clamp(minH, maxH);
}

/// Paint offset for dismiss only. Positive Y moves the sheet down. Overshoot
/// past open does not translate; it grows [tagSelectSheetDisplayHeight].
double tagSelectSheetTranslationY({
  required double linearProgress,
  required double sheetHeight,
  required double viewportHeight,
}) {
  if (sheetHeight <= 0 || linearProgress >= 1) {
    return 0;
  }
  return (1 - linearProgress.clamp(0.0, 1.0)) * sheetHeight;
}

/// Rest height plus rubber-banded growth into the space above the sheet.
/// Bottom edge stays put. Result never exceeds [availableHeight].
double tagSelectSheetDisplayHeight({
  required double linearProgress,
  required double restHeight,
  required double availableHeight,
}) {
  if (restHeight <= 0) {
    return 0;
  }
  if (linearProgress <= 1) {
    return restHeight;
  }
  final extra = (linearProgress - 1) * restHeight;
  final maxExtra = (availableHeight - restHeight).clamp(0.0, availableHeight);
  return restHeight + fluidRubberBand(overscroll: extra, dimension: maxExtra);
}

const kFluidSheetMinHeightFraction = 0.5;
const kFluidSheetMaxHeightFraction = 0.8;

const kTagSelectSheetMinHeightFraction = kFluidSheetMinHeightFraction;
const kTagSelectSheetMaxHeightFraction = kFluidSheetMaxHeightFraction;

/// Linear sheet progress from a vertical handle drag. May exceed 1 (overshoot).
/// Clamps below 0 (closed edge).
double fluidSheetLinearProgressFromDrag({
  required double current,
  required double deltaDy,
  required double sheetHeight,
}) {
  if (sheetHeight <= 0) {
    return current < 0 ? 0.0 : current;
  }
  final next = current - deltaDy / sheetHeight;
  return next < 0 ? 0.0 : next;
}

/// Icon opacity for swipe action chrome. Hidden until 40% reveal, then fades in.
double tagSwipeActionIconOpacity(double revealT) {
  final t = revealT.clamp(0.0, 1.0);
  if (t <= 0.4) {
    return 0;
  }
  return ((t - 0.4) / 0.6).clamp(0.0, 1.0);
}

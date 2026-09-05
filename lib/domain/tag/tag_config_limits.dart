/// Shared limits for TagModeConfig inputs (UI + validation).
///
/// Values are expressed in minutes (UI-facing), but can be converted to seconds
/// for persistence.
class TagConfigLimits {
  const TagConfigLimits._();

  static const int focusMinMin = 5;

  static const int focusMaxMin = 180;
  static const int focusStepMin = 5;

  static const int shortBreakMinMin = 5;
  static const int shortBreakMaxMin = 15;
  static const int shortBreakStepMin = 1;

  static const int longBreakMinMin = 10;
  static const int longBreakMaxMin = 30;
  static const int longBreakStepMin = 1;

  static const int totalCyclesMin = 2;
  static const int totalCyclesMax = 8;
  static const int totalCyclesStep = 2;

  static const int sessionsBeforeLongBreakMin = 2;
  static const int sessionsBeforeLongBreakMax = 10;

  static const int reminderMinMinutes = 5;
  static const int reminderMaxMinutes = 180;
  static const int reminderStepMinutes = 5;

  static int minToSec(int minutes) => minutes * 60;

  static int secToMinRounded(int seconds) => (seconds / 60).round();

  static bool isWithin(int value, {required int min, required int max}) =>
      value >= min && value <= max;

  /// Grid validation where valid values are:
  /// `min`, `min + step`, `min + 2*step`, ..., up to `max`.
  static bool isOnGrid(
    int value, {
    required int min,
    required int max,
    required int step,
  }) {
    if (!isWithin(value, min: min, max: max)) return false;
    return ((value - min) % step) == 0;
  }

  /// Snap an integer value to the nearest grid point within [min, max].
  static int snapToGrid(
    int value, {
    required int min,
    required int max,
    required int step,
  }) {
    if (value <= min) return min;
    if (value >= max) return max;
    final k = ((value - min) / step).round();
    final snapped = min + k * step;
    if (snapped < min) return min;
    if (snapped > max) return max;
    return snapped;
  }
}

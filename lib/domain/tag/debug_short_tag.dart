import 'package:pomodoro_app/domain/tag/system_tags.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';

/// Manual-QA short Tag gated by `--dart-define=DEBUG_SHORT_TAG=true`.
///
/// Does not change [TagConfigLimits]; upserts a reserved Tag instead.
abstract final class DebugShortTag {
  static const enabled = bool.fromEnvironment('DEBUG_SHORT_TAG');

  static const color = '#F59E0B';

  static const focusDurationSec = 5;
  static const shortRestDurationSec = 5;
  static const longRestDurationSec = 5;
  static const sessionsBeforeLongBreak = 2;
  static const totalCycles = 2;

  static TagModeConfigPomodoro get pomodoroConfig =>
      const TagModeConfigPomodoro(
        focusDurationSec: focusDurationSec,
        shortBreakDurationSec: shortRestDurationSec,
        longBreakDurationSec: longRestDurationSec,
        sessionsBeforeLongBreak: sessionsBeforeLongBreak,
        totalCycles: totalCycles,
      );

  /// Flexible stays production-like (General seed shape).
  static TagModeConfigFlexible get flexibleConfig =>
      TagModeConfigFlexible.defaults();

  static bool isReservedName(String name) =>
      name.trim() == SystemTags.debugName;

  static List<Tag> forManagement(List<Tag> tags) =>
      tags.where((t) => t.name != SystemTags.debugName).toList();

  static List<Tag> forTimerPicker(List<Tag> tags) =>
      enabled ? List<Tag>.from(tags) : forManagement(tags);
}

import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/tag/tag_mode_config.dart';

/// Builds frozen config snapshot from tag mode config (BR-TAG-006).
class ConfigSnapshotFactory {
  const ConfigSnapshotFactory();

  ConfigSnapshot fromTagModeConfig(TagModeConfig config) {
    if (config.mode == TimerMode.pomodoro) {
      return ConfigSnapshot(
        mode: TimerMode.pomodoro,
        focusDurationSec: config.focusDurationSec,
        shortBreakDurationSec: config.shortBreakDurationSec,
        longBreakDurationSec: config.longBreakDurationSec,
        sessionsBeforeLongBreak: config.sessionsBeforeLongBreak,
        totalCycles: config.totalCycles,
        autoStartBreak: config.autoStartBreak ?? false,
        autoStartFocus: config.autoStartFocus ?? false,
      );
    }

    return ConfigSnapshot(
      mode: TimerMode.flexible,
      defaultDurationSec: config.defaultDurationSec,
      reminderIntervalMin: config.reminderIntervalMin,
      reminderEnabled: config.reminderEnabled,
    );
  }
}

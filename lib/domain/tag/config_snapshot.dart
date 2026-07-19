import 'package:pomodoro_app/domain/common/enums.dart';

/// Immutable config snapshot stored on Session start (BR-TAG-006).
class ConfigSnapshot {
  const ConfigSnapshot({
    required this.mode,
    this.focusDurationSec,
    this.shortBreakDurationSec,
    this.longBreakDurationSec,
    this.sessionsBeforeLongBreak,
    this.totalCycles,
    this.autoStartBreak = false,
    this.autoStartFocus = false,
    this.defaultDurationSec,
    this.reminderIntervalMin,
    this.reminderEnabled,
  });

  final TimerMode mode;
  final int? focusDurationSec;
  final int? shortBreakDurationSec;
  final int? longBreakDurationSec;
  final int? sessionsBeforeLongBreak;
  final int? totalCycles;
  final bool autoStartBreak;
  final bool autoStartFocus;
  final int? defaultDurationSec;
  final int? reminderIntervalMin;
  final bool? reminderEnabled;

  factory ConfigSnapshot.fromJson(Map<String, dynamic> json) {
    final mode = TimerMode.fromDb(json['mode'] as String);
    return ConfigSnapshot(
      mode: mode,
      focusDurationSec: json['focusDurationSec'] as int?,
      shortBreakDurationSec: json['shortBreakDurationSec'] as int?,
      longBreakDurationSec: json['longBreakDurationSec'] as int?,
      sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] as int?,
      totalCycles: json['totalCycles'] as int?,
      autoStartBreak: json['autoStartBreak'] as bool? ?? false,
      autoStartFocus: json['autoStartFocus'] as bool? ?? false,
      defaultDurationSec: json['defaultDurationSec'] as int?,
      reminderIntervalMin: json['reminderIntervalMin'] as int?,
      reminderEnabled: json['reminderEnabled'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.toDb(),
        if (focusDurationSec != null) 'focusDurationSec': focusDurationSec,
        if (shortBreakDurationSec != null)
          'shortBreakDurationSec': shortBreakDurationSec,
        if (longBreakDurationSec != null)
          'longBreakDurationSec': longBreakDurationSec,
        if (sessionsBeforeLongBreak != null)
          'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
        if (totalCycles != null) 'totalCycles': totalCycles,
        'autoStartBreak': autoStartBreak,
        'autoStartFocus': autoStartFocus,
        if (defaultDurationSec != null)
          'defaultDurationSec': defaultDurationSec,
        if (reminderIntervalMin != null)
          'reminderIntervalMin': reminderIntervalMin,
        if (reminderEnabled != null) 'reminderEnabled': reminderEnabled,
      };

  static ConfigSnapshot pomodoroDefaults() => const ConfigSnapshot(
        mode: TimerMode.pomodoro,
        focusDurationSec: 1500,
        shortBreakDurationSec: 300,
        longBreakDurationSec: 900,
        sessionsBeforeLongBreak: 4,
        totalCycles: 4,
        autoStartBreak: false,
        autoStartFocus: false,
      );

  static ConfigSnapshot flexibleDefaults() => const ConfigSnapshot(
        mode: TimerMode.flexible,
        reminderIntervalMin: 25,
        reminderEnabled: true,
      );
}

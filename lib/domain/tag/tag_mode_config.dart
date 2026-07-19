import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';

class TagModeConfig {
  const TagModeConfig({
    required this.id,
    required this.tagId,
    required this.mode,
    required this.updatedAtUtcMs,
    this.focusDurationSec,
    this.shortBreakDurationSec,
    this.longBreakDurationSec,
    this.sessionsBeforeLongBreak,
    this.totalCycles,
    this.autoStartBreak,
    this.autoStartFocus,
    this.defaultDurationSec,
    this.reminderIntervalMin,
    this.reminderEnabled,
  });

  final String id;
  final String tagId;
  final TimerMode mode;
  final int? focusDurationSec;
  final int? shortBreakDurationSec;
  final int? longBreakDurationSec;
  final int? sessionsBeforeLongBreak;
  final int? totalCycles;
  final bool? autoStartBreak;
  final bool? autoStartFocus;
  final int? defaultDurationSec;
  final int? reminderIntervalMin;
  final bool? reminderEnabled;
  final int updatedAtUtcMs;
}

class TagWithConfigs {
  const TagWithConfigs({
    required this.tag,
    required this.pomodoro,
    required this.flexible,
  });

  final Tag tag;
  final TagModeConfig pomodoro;
  final TagModeConfig flexible;
}

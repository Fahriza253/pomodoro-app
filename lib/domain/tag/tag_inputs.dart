/// Pomodoro config payload for create/update (BR-TAG-002, BR-TAG-003).
class TagModeConfigPomodoro {
  const TagModeConfigPomodoro({
    required this.focusDurationSec,
    required this.shortBreakDurationSec,
    required this.longBreakDurationSec,
    required this.sessionsBeforeLongBreak,
    required this.totalCycles,
    this.autoStartBreak = false,
    this.autoStartFocus = false,
  });

  final int focusDurationSec;
  final int shortBreakDurationSec;
  final int longBreakDurationSec;
  final int sessionsBeforeLongBreak;
  final int totalCycles;
  final bool autoStartBreak;
  final bool autoStartFocus;

  static TagModeConfigPomodoro defaults() => const TagModeConfigPomodoro(
    focusDurationSec: 1500,
    shortBreakDurationSec: 300,
    longBreakDurationSec: 900,
    sessionsBeforeLongBreak: 4,
    totalCycles: 4,
  );
}

/// Flexible config payload for create/update (BR-TAG-002, BR-TAG-003).
class TagModeConfigFlexible {
  const TagModeConfigFlexible({
    this.defaultDurationSec,
    this.reminderEnabled = true,
    this.reminderIntervalMin = 25,
  });

  final int? defaultDurationSec;
  final bool reminderEnabled;
  final int reminderIntervalMin;

  static TagModeConfigFlexible defaults() => const TagModeConfigFlexible();
}

class CreateTagInput {
  const CreateTagInput({
    required this.name,
    required this.color,
    required this.pomodoro,
    required this.flexible,
  });

  final String name;
  final String color;
  final TagModeConfigPomodoro pomodoro;
  final TagModeConfigFlexible flexible;
}

class UpdateTagInput {
  const UpdateTagInput({
    required this.id,
    required this.name,
    required this.color,
    required this.pomodoro,
    required this.flexible,
  });

  final String id;
  final String name;
  final String color;
  final TagModeConfigPomodoro pomodoro;
  final TagModeConfigFlexible flexible;
}

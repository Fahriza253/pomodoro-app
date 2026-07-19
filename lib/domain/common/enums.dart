/// Domain enums mirroring [DATA_MODEL.md] snake_case DB values.
library;

enum TimerMode {
  pomodoro,
  flexible;

  String toDb() => name;

  static TimerMode fromDb(String value) => TimerMode.values.byName(value);
}

enum SessionStatus {
  active,
  completed,
  abandoned,
  failed,
  manual;

  String toDb() => name;

  static SessionStatus fromDb(String value) =>
      SessionStatus.values.byName(value);
}

enum SegmentType {
  focus,
  shortRest,
  longRest,
  flexible;

  String toDb() => switch (this) {
    SegmentType.focus => 'focus',
    SegmentType.shortRest => 'short_rest',
    SegmentType.longRest => 'long_rest',
    SegmentType.flexible => 'flexible',
  };

  static SegmentType fromDb(String value) => switch (value) {
    'focus' => SegmentType.focus,
    'short_rest' => SegmentType.shortRest,
    'long_rest' => SegmentType.longRest,
    'flexible' => SegmentType.flexible,
    _ => throw ArgumentError('Unknown segment type: $value'),
  };
}

enum SegmentStatus {
  pending,
  active,
  completed,
  skipped;

  String toDb() => name;

  static SegmentStatus fromDb(String value) =>
      SegmentStatus.values.byName(value);
}

enum EnginePhase {
  idle,
  running,
  paused,
  segmentComplete,
  sessionComplete;

  /// Maps to persisted [EngineState]; `idle` is not stored (BR-TIMER-024).
  EngineState? toPersistedEngineState() => switch (this) {
    EnginePhase.idle => null,
    EnginePhase.running => EngineState.running,
    EnginePhase.paused => EngineState.paused,
    EnginePhase.segmentComplete => EngineState.segmentComplete,
    EnginePhase.sessionComplete => EngineState.sessionComplete,
  };

  static EnginePhase fromPersistedEngineState(EngineState state) =>
      switch (state) {
        EngineState.running => EnginePhase.running,
        EngineState.paused => EnginePhase.paused,
        EngineState.segmentComplete => EnginePhase.segmentComplete,
        EngineState.sessionComplete => EnginePhase.sessionComplete,
      };
}

enum SessionOutcome { none, completed, abandoned, failed }

enum EngineState {
  running,
  paused,
  segmentComplete,
  sessionComplete;

  String toDb() => switch (this) {
    EngineState.running => 'running',
    EngineState.paused => 'paused',
    EngineState.segmentComplete => 'segment_complete',
    EngineState.sessionComplete => 'session_complete',
  };

  static EngineState fromDb(String value) => switch (value) {
    'running' => EngineState.running,
    'paused' => EngineState.paused,
    'segment_complete' => EngineState.segmentComplete,
    'session_complete' => EngineState.sessionComplete,
    _ => throw ArgumentError('Unknown engine state: $value'),
  };
}

enum FocusMode {
  loose,
  whitelist,
  strict;

  String toDb() => name;

  static FocusMode fromDb(String value) => FocusMode.values.byName(value);
}

enum AppTheme {
  light,
  dark,
  system;

  String toDb() => name;

  static AppTheme fromDb(String value) => AppTheme.values.byName(value);
}

enum TimeFormat {
  h12,
  h24;

  String toDb() => switch (this) {
    TimeFormat.h12 => '12h',
    TimeFormat.h24 => '24h',
  };

  static TimeFormat fromDb(String value) => switch (value) {
    '12h' => TimeFormat.h12,
    '24h' => TimeFormat.h24,
    _ => throw ArgumentError('Unknown time format: $value'),
  };
}

enum StatisticPeriod {
  daily,
  weekly,
  monthly,
  yearly,
  total;

  String toDb() => name;

  static StatisticPeriod fromDb(String value) =>
      StatisticPeriod.values.byName(value);
}

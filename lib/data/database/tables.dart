import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/converters/json_converters.dart';

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get color => text().withDefault(const Constant('#6366F1'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TagModeConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get tagId => text().references(Tags, #id)();
  TextColumn get mode => text()();
  IntColumn get focusDurationSec => integer().nullable()();
  IntColumn get shortBreakDurationSec => integer().nullable()();
  IntColumn get longBreakDurationSec => integer().nullable()();
  IntColumn get sessionsBeforeLongBreak => integer().nullable()();
  IntColumn get totalCycles => integer().nullable()();
  IntColumn get autoStartBreak => integer().nullable()();
  IntColumn get autoStartFocus => integer().nullable()();
  IntColumn get defaultDurationSec => integer().nullable()();
  IntColumn get reminderIntervalMin => integer().nullable()();
  IntColumn get reminderEnabled => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {tagId, mode},
  ];
}

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get tagId => text().references(Tags, #id)();
  TextColumn get mode => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get startedAt => integer()();
  IntColumn get endedAt => integer().nullable()();
  TextColumn get timelineDate => text()();
  IntColumn get totalActiveSec => integer().withDefault(const Constant(0))();
  IntColumn get totalPausedSec => integer().withDefault(const Constant(0))();
  TextColumn get configSnapshotJson =>
      text().map(const ConfigSnapshotConverter())();
  IntColumn get pomodoroFocusCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get pomodoroCyclesCompleted =>
      integer().withDefault(const Constant(0))();
  IntColumn get pomodoroCyclesTarget => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SessionSegments extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get type => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get plannedSec => integer()();
  IntColumn get actualSec => integer().withDefault(const Constant(0))();
  IntColumn get segmentPausedSec => integer().withDefault(const Constant(0))();
  TextColumn get segmentStatus =>
      text().withDefault(const Constant('pending'))();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get endedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sessionId, orderIndex},
  ];
}

class ActiveTimerStates extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get engineState => text()();
  TextColumn get currentSegmentId =>
      text().nullable().references(SessionSegments, #id)();
  IntColumn get segmentStartedAt => integer()();
  IntColumn get flexibleReminderActiveSec =>
      integer().withDefault(const Constant(0))();
  IntColumn get lastPersistedAt => integer()();
  /// Wall-clock pause start (UTC ms). Nullable — only set while paused.
  IntColumn get pauseStartedAt => integer().nullable()();
  /// Pomodoro remaining frozen at pause. Null when not applicable.
  IntColumn get frozenRemainingSec => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettingsTable extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get id => text()();
  TextColumn get alertToneFocusSuccess => text()
      .named('alert_tone')
      .withDefault(const Constant('success_arpeggio'))();
  TextColumn get alertToneBreakOver =>
      text().withDefault(const Constant('break_coin'))();
  TextColumn get alertToneFocusFailure =>
      text().withDefault(const Constant('failure_wrong'))();
  IntColumn get alertHapticEnabled => integer().withDefault(const Constant(1))();
  IntColumn get alertSoundMuted => integer().withDefault(const Constant(0))();
  IntColumn get alertFlashEnabled => integer().withDefault(const Constant(0))();
  TextColumn get focusMode => text().withDefault(const Constant('loose'))();
  TextColumn get whitelistJson => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  IntColumn get focusViolationThresholdSec =>
      integer().withDefault(const Constant(5))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  IntColumn get alwaysOnDisplay => integer().withDefault(const Constant(0))();
  TextColumn get language => text().withDefault(const Constant('en'))();
  IntColumn get weekStartDay => integer().withDefault(const Constant(1))();
  TextColumn get timeFormat => text().withDefault(const Constant('24h'))();
  IntColumn get trackFailedSessions =>
      integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

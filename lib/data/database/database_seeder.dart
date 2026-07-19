import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/system_tags.dart';
import 'package:uuid/uuid.dart';

/// Seeds Tag "General" + default AppSettings on first open (BR-TAG-001).
class DatabaseSeeder {
  DatabaseSeeder(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  static const generalTagName = SystemTags.generalName;
  static const settingsId = 'default';
  static const activeTimerStateId = 'active';

  Future<void> seedIfNeeded() async {
    final tagCount = await _db.select(_db.tags).get();
    if (tagCount.isNotEmpty) {
      return;
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final tagId = _uuid.v4();
    final pomodoroConfigId = _uuid.v4();
    final flexibleConfigId = _uuid.v4();

    await _db.transaction(() async {
      await _db
          .into(_db.tags)
          .insert(
            TagsCompanion.insert(
              id: tagId,
              name: generalTagName,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db.batch((batch) {
        batch.insertAll(_db.tagModeConfigs, [
          TagModeConfigsCompanion.insert(
            id: pomodoroConfigId,
            tagId: tagId,
            mode: TimerMode.pomodoro.toDb(),
            focusDurationSec: const Value(1500),
            shortBreakDurationSec: const Value(300),
            longBreakDurationSec: const Value(900),
            sessionsBeforeLongBreak: const Value(4),
            totalCycles: const Value(4),
            autoStartBreak: const Value(0),
            autoStartFocus: const Value(0),
            updatedAt: now,
          ),
          TagModeConfigsCompanion.insert(
            id: flexibleConfigId,
            tagId: tagId,
            mode: TimerMode.flexible.toDb(),
            defaultDurationSec: const Value(null),
            reminderIntervalMin: const Value(25),
            reminderEnabled: const Value(1),
            updatedAt: now,
          ),
        ]);
      });

      await _db
          .into(_db.appSettingsTable)
          .insert(
            AppSettingsTableCompanion.insert(
              id: settingsId,
              language: const Value('en'),
              updatedAt: now,
            ),
          );
    });
  }
}

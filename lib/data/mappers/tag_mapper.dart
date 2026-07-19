import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/app_database.dart' as db;
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/domain/tag/tag_mode_config.dart';

class TagMapper {
  const TagMapper();

  Tag toDomain(db.Tag row) {
    return Tag(
      id: row.id,
      name: row.name,
      color: row.color,
      sortOrder: row.sortOrder,
      deletedAtUtcMs: row.deletedAt,
      createdAtUtcMs: row.createdAt,
      updatedAtUtcMs: row.updatedAt,
    );
  }

  db.TagsCompanion toCompanion(Tag tag) {
    return db.TagsCompanion(
      id: Value(tag.id),
      name: Value(tag.name),
      color: Value(tag.color),
      sortOrder: Value(tag.sortOrder),
      deletedAt: Value(tag.deletedAtUtcMs),
      createdAt: Value(tag.createdAtUtcMs),
      updatedAt: Value(tag.updatedAtUtcMs),
    );
  }
}

class TagModeConfigMapper {
  const TagModeConfigMapper();

  TagModeConfig toDomain(db.TagModeConfig row) {
    return TagModeConfig(
      id: row.id,
      tagId: row.tagId,
      mode: TimerMode.fromDb(row.mode),
      focusDurationSec: row.focusDurationSec,
      shortBreakDurationSec: row.shortBreakDurationSec,
      longBreakDurationSec: row.longBreakDurationSec,
      sessionsBeforeLongBreak: row.sessionsBeforeLongBreak,
      totalCycles: row.totalCycles,
      autoStartBreak: row.autoStartBreak?.let((v) => v == 1),
      autoStartFocus: row.autoStartFocus?.let((v) => v == 1),
      defaultDurationSec: row.defaultDurationSec,
      reminderIntervalMin: row.reminderIntervalMin,
      reminderEnabled: row.reminderEnabled?.let((v) => v == 1),
      updatedAtUtcMs: row.updatedAt,
    );
  }

  db.TagModeConfigsCompanion toCompanion(TagModeConfig config) {
    return db.TagModeConfigsCompanion(
      id: Value(config.id),
      tagId: Value(config.tagId),
      mode: Value(config.mode.toDb()),
      focusDurationSec: Value(config.focusDurationSec),
      shortBreakDurationSec: Value(config.shortBreakDurationSec),
      longBreakDurationSec: Value(config.longBreakDurationSec),
      sessionsBeforeLongBreak: Value(config.sessionsBeforeLongBreak),
      totalCycles: Value(config.totalCycles),
      autoStartBreak: config.autoStartBreak == null
          ? const Value.absent()
          : Value(config.autoStartBreak! ? 1 : 0),
      autoStartFocus: config.autoStartFocus == null
          ? const Value.absent()
          : Value(config.autoStartFocus! ? 1 : 0),
      defaultDurationSec: Value(config.defaultDurationSec),
      reminderIntervalMin: Value(config.reminderIntervalMin),
      reminderEnabled: Value(config.reminderEnabled == true ? 1 : 0),
      updatedAt: Value(config.updatedAtUtcMs),
    );
  }
}

extension _NullableMap<T, R> on T? {
  R? let(R Function(T value) mapper) {
    final self = this;
    if (self == null) {
      return null;
    }
    return mapper(self);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/domain/common/enums.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = openAppDatabase(inMemory: true);
  });

  tearDown(() async {
    await db.close();
  });

  test('creates all tables and custom indexes', () async {
    await DatabaseSeeder(db).seedIfNeeded();

    await db.customSelect(
      "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_sessions_active'",
    ).getSingle();

    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='index'",
        )
        .get();

    final indexNames = indexes.map((r) => r.read<String>('name')).toSet();
    expect(indexNames, contains('idx_sessions_active'));
    expect(indexNames, contains('idx_sessions_started'));
    expect(indexNames, contains('idx_segments_session_order'));
  });

  test('tag_mode_configs enforces unique (tag_id, mode)', () async {
    await DatabaseSeeder(db).seedIfNeeded();
    final tag = await db.select(db.tags).getSingle();

    expect(
      () => db.into(db.tagModeConfigs).insert(
            TagModeConfigsCompanion.insert(
              id: 'duplicate-config',
              tagId: tag.id,
              mode: TimerMode.pomodoro.toDb(),
              updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
            ),
          ),
      throwsException,
    );
  });
}

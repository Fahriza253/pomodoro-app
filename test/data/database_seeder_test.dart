import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/domain/common/enums.dart';

void main() {
  test('seedIfNeeded inserts General tag with dual-mode configs', () async {
    final db = openAppDatabase(inMemory: true);
    addTearDown(db.close);

    await DatabaseSeeder(db).seedIfNeeded();

    final tags = await db.select(db.tags).get();
    expect(tags, hasLength(1));
    expect(tags.single.name, DatabaseSeeder.generalTagName);
    expect(tags.single.deletedAt, isNull);

    final configs = await db.select(db.tagModeConfigs).get();
    expect(configs, hasLength(2));
    expect(
      configs.map((c) => c.mode).toSet(),
      {TimerMode.pomodoro.toDb(), TimerMode.flexible.toDb()},
    );

    final pomodoro = configs.firstWhere(
      (c) => c.mode == TimerMode.pomodoro.toDb(),
    );
    expect(pomodoro.focusDurationSec, 1500);
    expect(pomodoro.totalCycles, 4);

    final flexible = configs.firstWhere(
      (c) => c.mode == TimerMode.flexible.toDb(),
    );
    expect(flexible.reminderIntervalMin, 25);
    expect(flexible.reminderEnabled, 1);

    final settings =
        await db.select(db.appSettingsTable).getSingleOrNull();
    expect(settings, isNotNull);
    expect(settings!.id, DatabaseSeeder.settingsId);
    expect(settings.focusMode, 'loose');
    expect(settings.language, 'en');
  });

  test('seedIfNeeded is idempotent', () async {
    final db = openAppDatabase(inMemory: true);
    addTearDown(db.close);

    await DatabaseSeeder(db).seedIfNeeded();
    await DatabaseSeeder(db).seedIfNeeded();

    final tags = await db.select(db.tags).get();
    expect(tags, hasLength(1));
  });
}

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart' hide EnginePhase;
import 'package:pomodoro_app/data/database/app_database.dart' hide ActiveTimerState;
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:uuid/uuid.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('schema upgrades', () {
    for (final from in GeneratedHelper.versions.where((v) => v < 6)) {
      test('upgrade from v$from to v6 matches current schema', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        addTearDown(db.close);
        await verifier.migrateAndValidate(db, 6);
      });
    }
  });

  test('v1→v6 remaps legacy alert_tone and keeps Settings readable', () async {
    final schema = await verifier.schemaAt(1);
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    await oldDb
        .into(oldDb.appSettings)
        .insert(
          v1.AppSettingsCompanion.insert(
            id: DatabaseSeeder.settingsId,
            alertTone: const Value('bell'),
            updatedAt: DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
          ),
        );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 6);

    final settings = await DriftSettingsRepository(db).get();
    expect(settings.alertToneFocusSuccess, 'success_arpeggio');
    expect(settings.alertToneBreakOver, isNotEmpty);
    expect(settings.alertToneFocusFailure, isNotEmpty);
  });

  test(
    'v1→v6 then seed + Session/Tag/ActiveTimerState round-trip; indexes hold',
    () async {
      final schema = await verifier.schemaAt(1);
      final db = AppDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 6);

      await DatabaseSeeder(db).seedIfNeeded();

      final indexNames = await _indexNames(db);
      expect(indexNames, contains('idx_sessions_active'));
      expect(indexNames, contains('idx_sessions_started'));
      expect(indexNames, contains('idx_segments_session_order'));

      final tags = DriftTagRepository(db);
      final createdTag = await tags.create(
        CreateTagInput(
          name: 'Study',
          color: '#3B82F6',
          pomodoro: TagModeConfigPomodoro.defaults(),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );
      final tagId = createdTag.id;

      final settingsRepo = DriftSettingsRepository(db);
      final patched = await settingsRepo.update(
        const AppSettingsPatch(theme: AppTheme.dark),
      );
      expect(patched.theme, AppTheme.dark);

      const uuid = Uuid();
      final sessions = DriftSessionRepository(db);
      final now = DateTime.utc(2026, 9, 6, 8).millisecondsSinceEpoch;
      final sessionId = uuid.v4();
      final segmentId = uuid.v4();

      final session = await sessions.createSession(
        CreateSessionInput(
          id: sessionId,
          tagId: tagId,
          mode: TimerMode.pomodoro,
          configSnapshot: ConfigSnapshot.pomodoroDefaults(),
          startedAtUtcMs: now,
          timelineDate: '2026-09-06',
          pomodoroCyclesTarget: 4,
          segments: [
            CreateSegmentInput(
              id: segmentId,
              type: SegmentType.focus,
              orderIndex: 0,
              plannedSec: 1500,
              segmentStatus: SegmentStatus.active,
              startedAtUtcMs: now,
            ),
          ],
        ),
      );
      expect(session.id, sessionId);

      final active = DriftActiveTimerStateRepository(db);
      await active.upsert(
        ActiveTimerState(
          sessionId: sessionId,
          enginePhase: EnginePhase.running,
          currentSegmentId: segmentId,
          segmentStartedAtUtcMs: now,
          flexibleReminderActiveSec: 0,
          lastPersistedAtUtcMs: now,
        ),
      );
      final recovered = await active.get();
      expect(recovered?.sessionId, sessionId);

      final settings = await settingsRepo.get();
      expect(settings.id, DatabaseSeeder.settingsId);
    },
  );
}

Future<Set<String>> _indexNames(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type='index'")
      .get();
  return rows.map((r) => r.read<String>('name')).toSet();
}

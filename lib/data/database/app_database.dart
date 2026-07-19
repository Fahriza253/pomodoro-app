import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/converters/json_converters.dart';
import 'package:pomodoro_app/data/database/tables.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Tags,
    TagModeConfigs,
    Sessions,
    SessionSegments,
    ActiveTimerStates,
    AppSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createCustomIndexes();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(
          appSettingsTable,
          appSettingsTable.alertToneBreakOver,
        );
        await m.addColumn(
          appSettingsTable,
          appSettingsTable.alertToneFocusFailure,
        );
        await customStatement(
          "UPDATE app_settings SET alert_tone = 'success_arpeggio' "
          "WHERE alert_tone IN ('default', 'bell', 'chime', 'soft')",
        );
      }
      if (from < 3) {
        await m.addColumn(
          activeTimerStates,
          activeTimerStates.pauseStartedAt,
        );
        await m.addColumn(
          activeTimerStates,
          activeTimerStates.frozenRemainingSec,
        );
      }
      // v4: column default for new installs is `en` (tables.dart).
      // Existing rows keep their saved language — do not overwrite.
      if (from < 5) {
        // Drop track_manual_duration (setting removed; manual always in stats).
        await customStatement(
          'ALTER TABLE app_settings DROP COLUMN track_manual_duration',
        );
      }
    },
  );

  Future<void> _createCustomIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tags_sort '
      'ON tags (deleted_at, sort_order)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_started '
      'ON sessions (started_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_timeline_date '
      'ON sessions (timeline_date DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_tag_started '
      'ON sessions (tag_id, started_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_status_started '
      'ON sessions (status, started_at DESC)',
    );
    // BR-GLOBAL-002: partial index for active session lookup.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_active '
      "ON sessions (status) WHERE status = 'active'",
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_segments_session_order '
      'ON session_segments (session_id, order_index)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_segments_session_type '
      'ON session_segments (session_id, type)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_tags_name_active '
      'ON tags (name) WHERE deleted_at IS NULL',
    );
  }
}

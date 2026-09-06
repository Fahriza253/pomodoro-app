import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/converters/json_converters.dart';
import 'package:pomodoro_app/data/database/schema_versions.dart';
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
  int get schemaVersion => 6;

  static final OnUpgrade _upgrade = stepByStep(
    from1To2: (m, schema) async {
      await m.addColumn(
        schema.appSettings,
        schema.appSettings.alertToneBreakOver,
      );
      await m.addColumn(
        schema.appSettings,
        schema.appSettings.alertToneFocusFailure,
      );
      await m.database.customStatement(
        "UPDATE app_settings SET alert_tone = 'success_arpeggio' "
        "WHERE alert_tone IN ('default', 'bell', 'chime', 'soft')",
      );
      // Downgrade note: drop alert_tone_break_over / alert_tone_focus_failure;
      // restore remapped alert_tone values from backup if needed.
    },
    from2To3: (m, schema) async {
      await m.addColumn(
        schema.activeTimerStates,
        schema.activeTimerStates.pauseStartedAt,
      );
      await m.addColumn(
        schema.activeTimerStates,
        schema.activeTimerStates.frozenRemainingSec,
      );
      // Downgrade note: drop pause_started_at / frozen_remaining_sec.
    },
    // v4: column default for new installs is `en` (tables.dart).
    // Existing rows keep their saved language — do not overwrite.
    // Downgrade note: no structural change (default-only).
    from3To4: (m, schema) async {},
    from4To5: (m, schema) async {
      // Drop track_manual_duration (setting removed; manual always in stats).
      await m.database.customStatement(
        'ALTER TABLE app_settings DROP COLUMN track_manual_duration',
      );
      // Downgrade note: re-add INTEGER NOT NULL DEFAULT 0 track_manual_duration
      // (data for that column is not recoverable after drop).
    },
    from5To6: (m, schema) async {
      await m.addColumn(
        schema.appSettings,
        schema.appSettings.alertHapticEnabled,
      );
      await m.addColumn(
        schema.appSettings,
        schema.appSettings.alertSoundMuted,
      );
      await m.addColumn(
        schema.appSettings,
        schema.appSettings.alertFlashEnabled,
      );
      // Downgrade note: drop alert_haptic_enabled / alert_sound_muted /
      // alert_flash_enabled.
    },
  );

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createCustomIndexes();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      await _upgrade(m, from, to);
      // Idempotent: upgrades from older installs keep Statistic/Timeline indexes.
      await _createCustomIndexes();
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

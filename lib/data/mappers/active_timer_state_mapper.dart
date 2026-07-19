import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/app_database.dart' as db;
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart' as domain;

class ActiveTimerStateMapper {
  const ActiveTimerStateMapper();

  static const singletonId = DatabaseSeeder.activeTimerStateId;

  domain.ActiveTimerState toDomain(db.ActiveTimerState row) {
    return domain.ActiveTimerState(
      sessionId: row.sessionId,
      enginePhase: EnginePhase.fromPersistedEngineState(
        EngineState.fromDb(row.engineState),
      ),
      currentSegmentId: row.currentSegmentId,
      segmentStartedAtUtcMs: row.segmentStartedAt,
      flexibleReminderActiveSec: row.flexibleReminderActiveSec,
      lastPersistedAtUtcMs: row.lastPersistedAt,
      pauseStartedAtUtcMs: row.pauseStartedAt,
      frozenRemainingSec: row.frozenRemainingSec,
    );
  }

  db.ActiveTimerStatesCompanion toCompanion(domain.ActiveTimerState state) {
    final persisted = state.enginePhase.toPersistedEngineState();
    if (persisted == null) {
      throw ArgumentError('Cannot persist idle engine phase (BR-TIMER-024)');
    }

    return db.ActiveTimerStatesCompanion(
      id: const Value(singletonId),
      sessionId: Value(state.sessionId),
      engineState: Value(persisted.toDb()),
      currentSegmentId: Value(state.currentSegmentId),
      segmentStartedAt: Value(state.segmentStartedAtUtcMs),
      flexibleReminderActiveSec: Value(state.flexibleReminderActiveSec),
      lastPersistedAt: Value(state.lastPersistedAtUtcMs),
      pauseStartedAt: Value(state.pauseStartedAtUtcMs),
      frozenRemainingSec: Value(state.frozenRemainingSec),
    );
  }
}

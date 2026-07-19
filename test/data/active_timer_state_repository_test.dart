import 'package:flutter_test/flutter_test.dart' hide EnginePhase;
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';

import 'test_database.dart';

void main() {
  group('DriftActiveTimerStateRepository', () {
    test('upsert and get singleton state', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftActiveTimerStateRepository(db);

      final state = ActiveTimerState(
        sessionId: 'session-1',
        enginePhase: EnginePhase.running,
        currentSegmentId: 'segment-1',
        segmentStartedAtUtcMs: 1000,
        flexibleReminderActiveSec: 0,
        lastPersistedAtUtcMs: 1000,
      );

      await repository.upsert(state);
      final loaded = await repository.get();

      expect(loaded, isNotNull);
      expect(loaded!.sessionId, 'session-1');
      expect(loaded.enginePhase, EnginePhase.running);
    });

    test('delete removes persisted state', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftActiveTimerStateRepository(db);

      await repository.upsert(
        ActiveTimerState(
          sessionId: 'session-1',
          enginePhase: EnginePhase.paused,
          segmentStartedAtUtcMs: 1000,
          flexibleReminderActiveSec: 0,
          lastPersistedAtUtcMs: 1000,
        ),
      );

      await repository.delete();
      expect(await repository.get(), isNull);
    });
  });
}

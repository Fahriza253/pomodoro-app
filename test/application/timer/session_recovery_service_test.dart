import 'package:pomodoro_app/application/timer/recovery_check_result.dart';
import 'package:pomodoro_app/application/timer/session_recovery_service.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:test/test.dart';

import 'timer_test_stack.dart';

void main() {
  group('SessionRecoveryService', () {
    late FakeClockAdapter clock;
    late SessionRecoveryService recovery;
    late TimerTestStack stack;

    setUp(() async {
      clock = FakeClockAdapter();
      stack = await TimerTestStack.open(clock: clock);
      recovery = SessionRecoveryService(
        sessionRepository: stack.sessions,
        activeTimerStateRepository: stack.activeState,
      );
    });

    tearDown(() {
      stack.dispose();
    });

    test('returns none when no persisted state', () async {
      final result = await recovery.check(clock.nowUtc());
      expect(result, isA<RecoveryCheckNone>());
    });

    test(
      'offers resume when state and session both active under 24h',
      () async {
        await stack.coordinator.startPomodoro(stack.tagId);
        final result = await recovery.check(clock.nowUtc());
        expect(result, isA<RecoveryCheckOfferResume>());
      },
    );

    test('auto-abandons when last persist older than 24h', () async {
      await stack.coordinator.startPomodoro(stack.tagId);
      clock.advance(
        SessionRecoveryService.recoveryWindow + const Duration(minutes: 1),
      );
      final result = await recovery.check(clock.nowUtc());
      expect(result, isA<RecoveryCheckAutoAbandoned>());
      expect(await stack.sessions.getActiveSession(), isNull);
      expect(await stack.activeState.get(), isNull);
    });

    test('cleans orphan active session without timer state', () async {
      await stack.coordinator.startPomodoro(stack.tagId);
      await stack.activeState.delete();
      final result = await recovery.check(clock.nowUtc());
      expect(result, isA<RecoveryCheckAutoAbandoned>());
      expect(await stack.sessions.getActiveSession(), isNull);
    });

    test(
      'sessionComplete phase auto-completes without resume offer',
      () async {
        await stack.coordinator.startFlexible(stack.tagId);
        final session = (await stack.sessions.getActiveSession())!;
        final persisted = (await stack.activeState.get())!;
        await stack.activeState.upsert(
          ActiveTimerState(
            sessionId: session.id,
            enginePhase: EnginePhase.sessionComplete,
            segmentStartedAtUtcMs: persisted.segmentStartedAtUtcMs,
            flexibleReminderActiveSec: persisted.flexibleReminderActiveSec,
            lastPersistedAtUtcMs: persisted.lastPersistedAtUtcMs,
            currentSegmentId: persisted.currentSegmentId,
          ),
        );

        final result = await recovery.check(clock.nowUtc());
        expect(result, isA<RecoveryCheckAutoCompleted>());
        expect(await stack.sessions.getActiveSession(), isNull);
        expect(await stack.activeState.get(), isNull);
        final finalized = await stack.sessions.getById(session.id);
        expect(finalized!.status, SessionStatus.completed);
      },
    );
  });
}

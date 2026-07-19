import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/timer_engine.dart';
import 'package:pomodoro_app/domain/timer/timer_transition_error.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:test/test.dart';

void main() {
  late FakeClockAdapter clock;
  late TimerEngine engine;

  setUp(() {
    clock = FakeClockAdapter(DateTime.utc(2026, 6, 28, 10));
    engine = TimerEngine();
  });

  tearDown(() {
    engine.dispose();
  });

  group('Flexible mode', () {
    test('start → running with count-up elapsed (BR-TIMER-010)', () {
      engine.startFlexible(ConfigSnapshot.flexibleDefaults(), clock.nowUtc());
      clock.advanceSeconds(45);

      engine.tick(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.running);
      expect(engine.currentState.elapsedActiveSecAt(clock.nowUtc()), 45);
    });

    test('pause excludes time from elapsed', () {
      engine.startFlexible(ConfigSnapshot.flexibleDefaults(), clock.nowUtc());
      clock.advanceSeconds(30);
      engine.pause(clock.nowUtc());
      clock.advanceSeconds(60);
      engine.resume(clock.nowUtc());
      clock.advanceSeconds(10);
      engine.tick(clock.nowUtc());

      expect(engine.currentState.elapsedActiveSecAt(clock.nowUtc()), 40);
    });

    test('completeFlexible → session_complete', () {
      engine.startFlexible(ConfigSnapshot.flexibleDefaults(), clock.nowUtc());
      clock.advanceSeconds(120);
      engine.completeFlexible(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.sessionComplete);
    });

    test('dismissSessionComplete → idle completed', () {
      engine.startFlexible(ConfigSnapshot.flexibleDefaults(), clock.nowUtc());
      engine.completeFlexible(clock.nowUtc());
      engine.dismissSessionComplete();

      expect(engine.currentState.phase, EnginePhase.idle);
      expect(engine.currentState.lastOutcome, SessionOutcome.completed);
    });

    test('MUST NOT use segment_complete (BR-SESSION-004)', () {
      engine.startFlexible(ConfigSnapshot.flexibleDefaults(), clock.nowUtc());

      expect(
        () => engine.advanceFromSegmentComplete(clock.nowUtc()),
        throwsA(isA<TimerTransitionError>()),
      );
      expect(
        () => engine.skipBreak(clock.nowUtc()),
        throwsA(isA<TimerTransitionError>()),
      );
    });

    test('flexible reminder counter resets on pause (BR-TIMER-012)', () {
      engine.startFlexible(
        const ConfigSnapshot(
          mode: TimerMode.flexible,
          reminderIntervalMin: 25,
          reminderEnabled: true,
        ),
        clock.nowUtc(),
      );
      clock.advanceSeconds(100);
      engine.tick(clock.nowUtc());
      expect(engine.currentState.flexibleReminderActiveSec, 100);

      engine.pause(clock.nowUtc());
      expect(engine.currentState.flexibleReminderActiveSec, 0);

      clock.advanceSeconds(60);
      // Still paused — reminder stays at 0 (not full session elapsed).
      expect(engine.currentState.flexibleReminderActiveSecAt(clock.nowUtc()), 0);
    });

    test('flexible reminder resumes from zero after pause', () {
      engine.startFlexible(
        const ConfigSnapshot(
          mode: TimerMode.flexible,
          reminderIntervalMin: 25,
          reminderEnabled: true,
        ),
        clock.nowUtc(),
      );
      clock.advanceSeconds(100);
      engine.tick(clock.nowUtc());
      engine.pause(clock.nowUtc());
      clock.advanceSeconds(200);
      engine.resume(clock.nowUtc());
      clock.advanceSeconds(30);
      engine.tick(clock.nowUtc());

      expect(engine.currentState.flexibleReminderActiveSec, 30);
      expect(engine.currentState.elapsedActiveSecAt(clock.nowUtc()), 130);
    });

    test('acknowledgeFlexibleReminder prevents re-fire until interval', () {
      engine.startFlexible(
        const ConfigSnapshot(
          mode: TimerMode.flexible,
          reminderIntervalMin: 1,
          reminderEnabled: true,
        ),
        clock.nowUtc(),
      );
      clock.advanceSeconds(60);
      engine.tick(clock.nowUtc());
      expect(
        shouldFireFlexibleReminder(
          config: engine.currentState.config!,
          flexibleReminderActiveSec:
              engine.currentState.flexibleReminderActiveSec,
        ),
        isTrue,
      );

      engine.acknowledgeFlexibleReminder(clock.nowUtc());
      expect(engine.currentState.flexibleReminderActiveSec, 0);
      expect(
        shouldFireFlexibleReminder(
          config: engine.currentState.config!,
          flexibleReminderActiveSec:
              engine.currentState.flexibleReminderActiveSec,
        ),
        isFalse,
      );

      clock.advanceSeconds(30);
      engine.tick(clock.nowUtc());
      expect(engine.currentState.flexibleReminderActiveSec, 30);
    });

    test('shouldFireFlexibleReminder when interval reached (BR-TIMER-011)', () {
      const config = ConfigSnapshot(
        mode: TimerMode.flexible,
        reminderIntervalMin: 25,
        reminderEnabled: true,
      );

      expect(
        shouldFireFlexibleReminder(
          config: config,
          flexibleReminderActiveSec: 25 * 60 - 1,
        ),
        isFalse,
      );
      expect(
        shouldFireFlexibleReminder(
          config: config,
          flexibleReminderActiveSec: 25 * 60,
        ),
        isTrue,
      );
    });

    test('resume clamps negative pause when clock goes backward', () {
      engine.startFlexible(ConfigSnapshot.flexibleDefaults(), clock.nowUtc());
      clock.advanceSeconds(20);
      engine.pause(clock.nowUtc());
      clock.set(clock.nowUtc().subtract(const Duration(seconds: 5)));
      engine.resume(clock.nowUtc());

      expect(engine.currentState.sessionTotalPausedSec, 0);
      expect(engine.currentState.phase, EnginePhase.running);
    });
  });
}

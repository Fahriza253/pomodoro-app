import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/session_plan.dart';
import 'package:pomodoro_app/domain/timer/segment_planner.dart';
import 'package:pomodoro_app/domain/timer/timer_engine.dart';
import 'package:pomodoro_app/domain/timer/timer_transition_error.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:test/test.dart';

void main() {
  late FakeClockAdapter clock;
  late TimerEngine engine;
  late SegmentPlanner planner;

  ConfigSnapshot pomodoroConfig({
    int focusSec = 60,
    int shortBreakSec = 10,
    int longBreakSec = 20,
    int sessionsBeforeLongBreak = 1,
    int totalCycles = 2,
    bool autoStartBreak = false,
    bool autoStartFocus = false,
  }) {
    return ConfigSnapshot(
      mode: TimerMode.pomodoro,
      focusDurationSec: focusSec,
      shortBreakDurationSec: shortBreakSec,
      longBreakDurationSec: longBreakSec,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak,
      totalCycles: totalCycles,
      autoStartBreak: autoStartBreak,
      autoStartFocus: autoStartFocus,
    );
  }

  SessionPlan singleCyclePlan({ConfigSnapshot? config}) {
    final cfg = config ?? pomodoroConfig();
    final segments = planner.buildCycleSegments(cfg);
    return SessionPlan(config: cfg, segments: segments, cyclesTarget: 1);
  }

  setUp(() {
    clock = FakeClockAdapter(DateTime.utc(2026, 6, 28, 9));
    planner = const SegmentPlanner();
    engine = TimerEngine(planner: planner);
  });

  tearDown(() {
    engine.dispose();
  });

  group('Pomodoro transitions', () {
    test('start → running on first focus segment', () {
      engine.startPomodoro(singleCyclePlan(), clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.running);
      expect(engine.currentState.currentSegment?.type, SegmentType.focus);
      expect(engine.currentState.remainingSecAt(clock.nowUtc()), 60);
    });

    test('pause freezes remaining (BR-TIMER-003)', () {
      engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
      clock.advanceSeconds(15);

      engine.pause(clock.nowUtc());
      expect(engine.currentState.phase, EnginePhase.paused);
      expect(engine.currentState.remainingSecAt(clock.nowUtc()), 45);

      clock.advanceSeconds(120);
      engine.tick(clock.nowUtc());
      expect(engine.currentState.remainingSecAt(clock.nowUtc()), 45);
    });

    test('resume continues countdown from frozen remaining', () {
      engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
      clock.advanceSeconds(10);
      engine.pause(clock.nowUtc());
      clock.advanceSeconds(50);
      engine.resume(clock.nowUtc());
      clock.advanceSeconds(5);

      expect(engine.currentState.remainingSecAt(clock.nowUtc()), 45);
    });

    test('resume clamps negative pause when clock goes backward', () {
      engine.startPomodoro(
        singleCyclePlan(config: pomodoroConfig(focusSec: 100)),
        clock.nowUtc(),
      );
      clock.advanceSeconds(10);
      engine.pause(clock.nowUtc());
      clock.set(clock.nowUtc().subtract(const Duration(seconds: 3)));
      engine.resume(clock.nowUtc());

      // Frozen remaining (90) is preserved despite clock skew during pause.
      expect(engine.currentState.remainingSecAt(clock.nowUtc()), 90);
    });

    test('tick auto-completes focus → segment_complete → rest', () {
      engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
      clock.advanceSeconds(60);
      engine.tick(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.segmentComplete);
      expect(engine.currentState.pomodoroFocusCount, 1);

      engine.advanceFromSegmentComplete(clock.nowUtc());
      expect(engine.currentState.phase, EnginePhase.running);
      expect(engine.currentState.currentSegment?.type, SegmentType.longRest);
    });

    test(
      'wall-clock formula within ±1s after 5 min background (NFR-PERF-001)',
      () {
        engine.startPomodoro(
          singleCyclePlan(config: pomodoroConfig(focusSec: 600)),
          clock.nowUtc(),
        );
        clock.advanceSeconds(300);
        engine.tick(clock.nowUtc());

        final remaining = engine.currentState.remainingSecAt(clock.nowUtc());
        expect(remaining, 300);
        expect((remaining - 300).abs(), lessThanOrEqualTo(1));
      },
    );

    test('skipBreak during rest advances without waiting', () {
      final plan = singleCyclePlan(
        config: pomodoroConfig(
          sessionsBeforeLongBreak: 1,
          focusSec: 30,
          longBreakSec: 60,
        ),
      );
      engine.startPomodoro(plan, clock.nowUtc());
      clock.advanceSeconds(30);
      engine.tick(clock.nowUtc());
      engine.advanceFromSegmentComplete(clock.nowUtc());

      expect(engine.currentState.currentSegment?.type, SegmentType.longRest);
      engine.skipBreak(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.sessionComplete);
      expect(engine.currentState.pomodoroCyclesCompleted, 1);
    });

    test('skipBreak from post-focus prompt skips short_rest → next focus', () {
      final config = pomodoroConfig(
        sessionsBeforeLongBreak: 2,
        focusSec: 30,
        shortBreakSec: 10,
        longBreakSec: 20,
        totalCycles: 2,
      );
      engine.startPomodoro(
        SessionPlan(
          config: config,
          segments: planner.buildCycleSegments(config),
          cyclesTarget: 1,
        ),
        clock.nowUtc(),
      );
      clock.advanceSeconds(30);
      engine.tick(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.segmentComplete);
      expect(engine.currentState.currentSegment?.type, SegmentType.focus);

      engine.skipBreak(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.running);
      expect(engine.currentState.currentSegment?.type, SegmentType.focus);
      expect(engine.currentState.currentSegmentIndex, 2);
      expect(engine.currentState.pomodoroFocusCount, 1);
    });

    test(
      'skipBreak from post-focus prompt on final long_rest → sessionComplete',
      () {
        engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
        clock.advanceSeconds(60);
        engine.tick(clock.nowUtc());

        expect(engine.currentState.phase, EnginePhase.segmentComplete);
        expect(engine.currentState.currentSegment?.type, SegmentType.focus);

        engine.skipBreak(clock.nowUtc());

        expect(engine.currentState.phase, EnginePhase.sessionComplete);
        expect(engine.currentState.pomodoroCyclesCompleted, 1);
        expect(engine.currentState.currentSegment?.type, SegmentType.longRest);
      },
    );

    test('skipBreak after restoreFromPersisted at focus segmentComplete', () {
      final config = pomodoroConfig(
        sessionsBeforeLongBreak: 2,
        focusSec: 30,
        shortBreakSec: 10,
        longBreakSec: 20,
        totalCycles: 2,
      );
      final plan = SessionPlan(
        config: config,
        segments: planner.buildCycleSegments(config),
        cyclesTarget: 1,
      );
      engine.startPomodoro(plan, clock.nowUtc());
      clock.advanceSeconds(30);
      engine.tick(clock.nowUtc());

      final persisted = engine.currentState;
      expect(persisted.phase, EnginePhase.segmentComplete);
      expect(persisted.currentSegment?.type, SegmentType.focus);

      engine.dispose();
      engine = TimerEngine(planner: planner);
      engine.restoreFromPersisted(persisted, clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.segmentComplete);
      engine.skipBreak(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.running);
      expect(engine.currentState.currentSegment?.type, SegmentType.focus);
      expect(engine.currentState.currentSegmentIndex, 2);
    });

    test('session_complete after final long_rest (BR-TIMER-008)', () {
      engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
      clock.advanceSeconds(60);
      engine.tick(clock.nowUtc());
      engine.advanceFromSegmentComplete(clock.nowUtc());
      clock.advanceSeconds(20);
      engine.tick(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.sessionComplete);
      expect(engine.currentState.pomodoroCyclesCompleted, 1);
    });

    test('continuePomodoro extends target (BR-TIMER-009)', () {
      final config = pomodoroConfig(totalCycles: 2);
      engine.startPomodoro(
        SessionPlan(
          config: config,
          segments: planner.buildCycleSegments(config),
          cyclesTarget: 1,
        ),
        clock.nowUtc(),
      );

      clock.advanceSeconds(60);
      engine.tick(clock.nowUtc());
      engine.advanceFromSegmentComplete(clock.nowUtc());
      clock.advanceSeconds(20);
      engine.tick(clock.nowUtc());

      engine.continuePomodoro(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.running);
      expect(engine.currentState.pomodoroCyclesTarget, 3);
      expect(engine.currentState.segments.length, greaterThan(2));
    });

    test('confirmStop from running → idle abandoned', () {
      engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
      engine.confirmStop();

      expect(engine.currentState.phase, EnginePhase.idle);
      expect(engine.currentState.lastOutcome, SessionOutcome.abandoned);
    });

    test('reportFocusViolation only from running (BR-FOCUS-007)', () {
      engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
      engine.reportFocusViolation();

      expect(engine.currentState.lastOutcome, SessionOutcome.failed);

      engine.resetAfterTerminalHandled();
      engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
      engine.pause(clock.nowUtc());

      expect(
        () => engine.reportFocusViolation(),
        throwsA(isA<TimerTransitionError>()),
      );
    });

    test('autoStartBreak skips segment_complete wait (BR-TIMER-005)', () {
      final config = pomodoroConfig(autoStartBreak: true);
      engine.startPomodoro(
        SessionPlan(
          config: config,
          segments: planner.buildCycleSegments(config),
          cyclesTarget: 1,
        ),
        clock.nowUtc(),
      );

      clock.advanceSeconds(60);
      engine.tick(clock.nowUtc());

      expect(engine.currentState.phase, EnginePhase.running);
      expect(engine.currentState.currentSegment?.type, SegmentType.longRest);
    });
  });

  group('TimerEngineState wall-clock', () {
    test('remaining uses planned - (now - start - paused)', () {
      engine.startPomodoro(
        singleCyclePlan(config: pomodoroConfig(focusSec: 100)),
        DateTime.utc(2026, 1, 1),
      );
      engine.pause(DateTime.utc(2026, 1, 1, 0, 0, 10));
      engine.resume(DateTime.utc(2026, 1, 1, 0, 0, 20));

      final now = DateTime.utc(2026, 1, 1, 0, 0, 40);
      expect(engine.currentState.remainingSecAt(now), 70);
    });
  });
}

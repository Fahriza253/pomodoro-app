import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/session_plan.dart';
import 'package:pomodoro_app/domain/timer/segment_completion_semantics.dart';
import 'package:pomodoro_app/domain/timer/segment_planner.dart';
import 'package:pomodoro_app/domain/timer/timer_engine.dart';
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
  }) {
    return ConfigSnapshot(
      mode: TimerMode.pomodoro,
      focusDurationSec: focusSec,
      shortBreakDurationSec: shortBreakSec,
      longBreakDurationSec: longBreakSec,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak,
      totalCycles: totalCycles,
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

  SegmentCompletionSemantics semanticsAfter(void Function() transition) {
    final before = engine.currentState;
    transition();
    final after = engine.currentState;
    return deriveSegmentCompletionSemantics(
      before: before,
      after: after,
      nowUtc: clock.nowUtc(),
    );
  }

  group('deriveSegmentCompletionSemantics', () {
    test('tick focus complete only syncs counters on current Segment', () {
      final config = pomodoroConfig(focusSec: 30, sessionsBeforeLongBreak: 2);
      engine.startPomodoro(
        SessionPlan(
          config: config,
          segments: planner.buildCycleSegments(config),
          cyclesTarget: 1,
        ),
        clock.nowUtc(),
      );
      clock.advanceSeconds(30);
      final semantics = semanticsAfter(() => engine.tick(clock.nowUtc()));

      expect(semantics.completedSegments, isEmpty);
      expect(semantics.skippedRests, isEmpty);
      expect(semantics.startedSegmentIndex, isNull);
      expect(semantics.counterSyncSegmentIndex, 0);
      expect(semantics.sessionReachedTerminal, isFalse);
    });

    test('advance from segmentComplete completes focus and starts rest', () {
      final config = pomodoroConfig(focusSec: 30, sessionsBeforeLongBreak: 2);
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

      final semantics = semanticsAfter(
        () => engine.advanceFromSegmentComplete(clock.nowUtc()),
      );

      expect(semantics.completedSegments, hasLength(1));
      expect(semantics.completedSegments.single.segmentIndex, 0);
      expect(semantics.completedSegments.single.actualSec, 30);
      expect(semantics.startedSegmentIndex, 1);
      expect(semantics.sessionReachedTerminal, isFalse);
    });

    test('skipBreak from post-focus marks pending rest skipped', () {
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

      final semantics = semanticsAfter(() => engine.skipBreak(clock.nowUtc()));

      expect(semantics.completedSegments.single.segmentIndex, 0);
      expect(semantics.skippedRests.single.segmentIndex, 1);
      expect(semantics.startedSegmentIndex, 2);
    });

    test(
      'skipBreak from post-focus on final long_rest reaches sessionComplete',
      () {
        engine.startPomodoro(singleCyclePlan(), clock.nowUtc());
        clock.advanceSeconds(60);
        engine.tick(clock.nowUtc());

        final semantics = semanticsAfter(() => engine.skipBreak(clock.nowUtc()));

        expect(semantics.completedSegments.single.segmentIndex, 0);
        expect(semantics.skippedRests.single.segmentIndex, 1);
        expect(semantics.startedSegmentIndex, isNull);
        expect(semantics.sessionReachedTerminal, isTrue);
        expect(semantics.counterSyncSegmentIndex, 1);
      },
    );

    test('skipBreak on running long_rest completes without index advance', () {
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

      final semantics = semanticsAfter(() => engine.skipBreak(clock.nowUtc()));

      expect(semantics.completedSegments.single.segmentIndex, 1);
      expect(semantics.skippedRests, isEmpty);
      expect(semantics.sessionReachedTerminal, isTrue);
    });

    test(
      'natural long_rest tick to sessionComplete uses terminal completion path',
      () {
        final plan = singleCyclePlan(
          config: pomodoroConfig(
            sessionsBeforeLongBreak: 1,
            focusSec: 30,
            longBreakSec: 20,
          ),
        );
        engine.startPomodoro(plan, clock.nowUtc());
        clock.advanceSeconds(30);
        engine.tick(clock.nowUtc());
        engine.advanceFromSegmentComplete(clock.nowUtc());
        clock.advanceSeconds(20);

        final semantics = semanticsAfter(() => engine.tick(clock.nowUtc()));

        expect(semantics.completedSegments.single.segmentIndex, 1);
        expect(semantics.completedSegments.single.actualSec, 20);
        expect(semantics.sessionReachedTerminal, isTrue);
      },
    );
  });

  group('withoutStartedSegment', () {
    test('clears started index only', () {
      const semantics = SegmentCompletionSemantics(
        completedSegments: [
          CompletedSegmentSemantics(
            segmentIndex: 0,
            actualSec: 30,
            segmentPausedSec: 0,
          ),
        ],
        startedSegmentIndex: 2,
        pomodoroFocusCount: 1,
        pomodoroCyclesCompleted: 0,
        sessionReachedTerminal: false,
      );
      final trimmed = semantics.withoutStartedSegment();
      expect(trimmed.startedSegmentIndex, isNull);
      expect(trimmed.completedSegments, semantics.completedSegments);
      expect(trimmed.hasRowWrites, isTrue);
    });
  });
}
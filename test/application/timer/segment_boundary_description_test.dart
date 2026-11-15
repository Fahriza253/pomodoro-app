import 'package:pomodoro_app/application/timer/segment_boundary_description.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:test/test.dart';

void main() {
  final started = DateTime.utc(2026, 1, 1, 12);
  const focus = SegmentPlan(
    type: SegmentType.focus,
    plannedSec: 30,
    orderIndex: 0,
  );
  const rest = SegmentPlan(
    type: SegmentType.shortRest,
    plannedSec: 10,
    orderIndex: 1,
  );

  TimerEngineState pomodoroRunning({required int index}) {
    return TimerEngineState(
      phase: EnginePhase.running,
      mode: TimerMode.pomodoro,
      config: ConfigSnapshot.pomodoroDefaults(),
      segments: const [focus, rest],
      currentSegmentIndex: index,
      segmentStartedAtUtc: started,
      sessionStartedAtUtc: started,
    );
  }

  group('describeSegmentBoundary', () {
    test('Pomodoro tick into segmentComplete is significant with alert', () {
      final before = pomodoroRunning(index: 0);
      final after = before.copyWith(phase: EnginePhase.segmentComplete);

      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      expect(boundary.significant, isTrue);
      expect(boundary.segmentEndAlert, isNotNull);
      expect(boundary.segmentEndAlert!.finishedType, SegmentType.focus);
      expect(boundary.segmentEndAlert!.sessionComplete, isFalse);
    });

    test('skipBreak from post-focus wait persists without segment-end Alert', () {
      final before = pomodoroRunning(index: 0).copyWith(
        phase: EnginePhase.segmentComplete,
      );
      final after = pomodoroRunning(index: 1);

      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      expect(boundary.significant, isTrue);
      expect(boundary.segmentEndAlert, isNull);
    });

    test('skipBreak from running rest auto-advances with break-over alert', () {
      final before = pomodoroRunning(index: 1);
      final after = pomodoroRunning(index: 0).copyWith(
        segmentStartedAtUtc: started.add(const Duration(seconds: 40)),
      );

      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      expect(boundary.significant, isTrue);
      expect(boundary.segmentEndAlert, isNotNull);
      expect(boundary.segmentEndAlert!.finishedType, SegmentType.shortRest);
    });

    test('advanceSegment from segmentComplete persists without alert', () {
      final before = pomodoroRunning(index: 0).copyWith(
        phase: EnginePhase.segmentComplete,
      );
      final after = pomodoroRunning(index: 1);

      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      expect(boundary.significant, isTrue);
      expect(boundary.segmentEndAlert, isNull);
    });

    test('sessionComplete from running last Segment persists with alert', () {
      final before = pomodoroRunning(index: 1);
      final after = before.copyWith(phase: EnginePhase.sessionComplete);

      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      expect(boundary.significant, isTrue);
      expect(boundary.segmentEndAlert, isNotNull);
      expect(boundary.segmentEndAlert!.sessionComplete, isTrue);
    });

    test('running tick without phase or index change is not significant', () {
      final before = pomodoroRunning(index: 0);
      final after = before;

      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      expect(boundary.significant, isFalse);
      expect(boundary.segmentEndAlert, isNull);
    });
  });
}
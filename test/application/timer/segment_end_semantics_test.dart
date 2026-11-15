import 'package:pomodoro_app/application/timer/segment_boundary_description.dart';
import 'package:pomodoro_app/application/timer/segment_end_semantics.dart';
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
  const flexible = SegmentPlan(
    type: SegmentType.flexible,
    plannedSec: 0,
    orderIndex: 0,
  );

  TimerEngineState pomodoroRunning({required int index, List<SegmentPlan>? segments}) {
    return TimerEngineState(
      phase: EnginePhase.running,
      mode: TimerMode.pomodoro,
      config: ConfigSnapshot.pomodoroDefaults(),
      segments: segments ?? const [focus, rest],
      currentSegmentIndex: index,
      pomodoroCyclesTarget: 4,
      segmentStartedAtUtc: started,
      sessionStartedAtUtc: started,
    );
  }

  group('segmentEndSemanticsAtPrompt', () {
    test('focus wait at segmentComplete matches boundary alert semantics', () {
      final before = pomodoroRunning(index: 0);
      final after = before.copyWith(phase: EnginePhase.segmentComplete);
      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      final prompt = segmentEndSemanticsAtPrompt(after);

      expect(prompt, isNotNull);
      expect(boundary.segmentEndSemantics, equals(prompt));
      expect(prompt!.finishedType, SegmentType.focus);
      expect(prompt.nextType, SegmentType.shortRest);
      expect(prompt.completedCount, 1);
      expect(prompt.totalCount, 4);
      expect(prompt.sessionComplete, isFalse);
    });

    test('rest wait at segmentComplete matches boundary alert semantics', () {
      const focus2 = SegmentPlan(
        type: SegmentType.focus,
        plannedSec: 30,
        orderIndex: 2,
      );
      final before = pomodoroRunning(
        index: 1,
        segments: const [focus, rest, focus2],
      );
      final after = before.copyWith(phase: EnginePhase.segmentComplete);
      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      final prompt = segmentEndSemanticsAtPrompt(after);
      expect(boundary.segmentEndSemantics, prompt);
      expect(prompt!.finishedType, SegmentType.shortRest);
      expect(prompt.nextType, SegmentType.focus);
    });

    test('session end on last segment', () {
      final before = pomodoroRunning(index: 0, segments: const [focus]);
      final after = before.copyWith(
        phase: EnginePhase.sessionComplete,
        pomodoroCyclesCompleted: 4,
      );
      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      final prompt = segmentEndSemanticsAtPrompt(after);

      expect(boundary.segmentEndSemantics, prompt);
      expect(prompt!.sessionComplete, isTrue);
      expect(prompt.nextType, isNull);
      expect(prompt.completedCount, 4);
    });
  });

  group('segmentEndSemanticsFromTransition', () {
    test('auto-start focus after running rest', () {
      const focus2 = SegmentPlan(
        type: SegmentType.focus,
        plannedSec: 30,
        orderIndex: 2,
      );
      final before = pomodoroRunning(
        index: 1,
        segments: const [focus, rest, focus2],
      );
      final after = before.copyWith(
        currentSegmentIndex: 2,
        segmentStartedAtUtc: started.add(const Duration(seconds: 40)),
      );
      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      final semantics = boundary.segmentEndSemantics;
      expect(semantics!.finishedType, SegmentType.shortRest);
      expect(semantics.nextType, SegmentType.focus);
    });

    test('auto-start break from running rest', () {
      final before = pomodoroRunning(index: 1);
      final after = pomodoroRunning(index: 0).copyWith(
        segmentStartedAtUtc: started.add(const Duration(seconds: 40)),
      );
      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      final semantics = boundary.segmentEndSemantics;
      expect(semantics, isNotNull);
      expect(semantics!.finishedType, SegmentType.shortRest);
      expect(semantics.nextType, isNull);
    });

    test('advance from segmentComplete has no alert semantics', () {
      final before = pomodoroRunning(index: 0).copyWith(
        phase: EnginePhase.segmentComplete,
      );
      final after = pomodoroRunning(index: 1);
      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      expect(boundary.segmentEndAlert, isNull);
      expect(boundary.segmentEndSemantics, isNull);
      expect(segmentEndSemanticsAtPrompt(before), isNotNull);
    });

    test('flexible complete to sessionComplete', () {
      final before = TimerEngineState(
        phase: EnginePhase.running,
        mode: TimerMode.flexible,
        config: ConfigSnapshot.flexibleDefaults(),
        segments: const [flexible],
        currentSegmentIndex: 0,
        segmentStartedAtUtc: started,
        sessionStartedAtUtc: started,
      );
      final after = before.copyWith(phase: EnginePhase.sessionComplete);
      final boundary = describeSegmentBoundary(
        before: before,
        after: after,
        nowUtc: started,
      );

      final semantics = boundary.segmentEndSemantics;
      expect(semantics, isNotNull);
      expect(semantics!.finishedType, SegmentType.flexible);
      expect(semantics.sessionComplete, isTrue);
      expect(semantics.nextType, isNull);
    });
  });

  group('segmentEndSemanticsForRunningSchedule', () {
    test('running focus predicts next rest and mid-cycle count', () {
      final running = pomodoroRunning(index: 0);
      final semantics = segmentEndSemanticsForRunningSchedule(running);
      expect(semantics, isNotNull);
      expect(semantics!.finishedType, SegmentType.focus);
      expect(semantics.nextType, SegmentType.shortRest);
      expect(semantics.completedCount, 1);
      expect(semantics.sessionComplete, isFalse);
    });

    test('running long rest on final segment predicts session end', () {
      const longRest = SegmentPlan(
        type: SegmentType.longRest,
        plannedSec: 20,
        orderIndex: 1,
      );
      final running = pomodoroRunning(
        index: 1,
        segments: const [focus, longRest],
      ).copyWith(pomodoroCyclesCompleted: 3);
      final semantics = segmentEndSemanticsForRunningSchedule(running);
      expect(semantics!.finishedType, SegmentType.longRest);
      expect(semantics.nextType, isNull);
      expect(semantics.sessionComplete, isTrue);
      expect(semantics.completedCount, 4);
    });
  });
}
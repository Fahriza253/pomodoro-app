import 'package:pomodoro_app/application/timer/segment_end_cycle_progress.dart';
import 'package:pomodoro_app/application/timer/timer_flow_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';

/// User-visible segment-end meaning: finished Segment, next or wait, cycle progress.
class SegmentEndSemantics {
  const SegmentEndSemantics({
    required this.finishedType,
    required this.nextType,
    required this.completedCount,
    required this.totalCount,
    required this.sessionComplete,
  });

  final SegmentType finishedType;
  final SegmentType? nextType;
  final int completedCount;
  final int totalCount;
  final bool sessionComplete;

  PomodoroSegmentEndSummary get pomodoroSummary => (
    finishedType: finishedType,
    nextType: nextType,
    completedCount: completedCount,
    totalCount: totalCount,
  );

  @override
  bool operator ==(Object other) {
    return other is SegmentEndSemantics &&
        other.finishedType == finishedType &&
        other.nextType == nextType &&
        other.completedCount == completedCount &&
        other.totalCount == totalCount &&
        other.sessionComplete == sessionComplete;
  }

  @override
  int get hashCode => Object.hash(
    finishedType,
    nextType,
    completedCount,
    totalCount,
    sessionComplete,
  );
}

SegmentEndSemantics? segmentEndSemanticsFromTransition({
  required TimerEngineState before,
  required TimerEngineState after,
  required bool sessionComplete,
  required bool hasSegmentEndAlert,
}) {
  if (hasSegmentEndAlert) {
    return _semanticsAfterFinishedSegment(
      segments: before.segments,
      finishedIndex: before.currentSegmentIndex,
      sessionComplete: sessionComplete,
      cyclesCompletedAfterSegment: after.pomodoroCyclesCompleted,
      cyclesTarget: after.pomodoroCyclesTarget,
    );
  }
  return segmentEndSemanticsAtPrompt(after);
}

SegmentEndSemantics? segmentEndSemanticsAtPrompt(TimerEngineState state) {
  if (state.phase != EnginePhase.segmentComplete &&
      state.phase != EnginePhase.sessionComplete) {
    return null;
  }
  if (state.segments.isEmpty) {
    return null;
  }
  final index = state.currentSegmentIndex;
  if (index < 0 || index >= state.segments.length) {
    return null;
  }

  final sessionComplete = state.phase == EnginePhase.sessionComplete;
  if (state.isPomodoro) {
    return _semanticsAfterFinishedSegment(
      segments: state.segments,
      finishedIndex: index,
      sessionComplete: sessionComplete,
      cyclesCompletedAfterSegment: state.pomodoroCyclesCompleted,
      cyclesTarget: state.pomodoroCyclesTarget,
    );
  }

  if (!sessionComplete) {
    return null;
  }
  return _semanticsAfterFinishedSegment(
    segments: state.segments,
    finishedIndex: index,
    sessionComplete: true,
    cyclesCompletedAfterSegment: 0,
    cyclesTarget: 0,
  );
}

/// Copy inputs while [state] is still running (OS segment-end schedule).
SegmentEndSemantics? segmentEndSemanticsForRunningSchedule(
  TimerEngineState state,
) {
  if (!state.isPomodoro || state.phase != EnginePhase.running) {
    return null;
  }
  final index = state.currentSegmentIndex;
  if (index < 0 || index >= state.segments.length) {
    return null;
  }
  final finished = state.segments[index].type;
  final nextIndex = index + 1;
  final nextType =
      nextIndex < state.segments.length ? state.segments[nextIndex].type : null;
  final sessionComplete = nextType == null;
  final cyclesAfter = cyclesCompletedAfterPredictedFinish(
    cyclesCompletedNow: state.pomodoroCyclesCompleted,
    current: finished,
  );
  return _semanticsAfterFinishedSegment(
    segments: state.segments,
    finishedIndex: index,
    sessionComplete: sessionComplete,
    cyclesCompletedAfterSegment: cyclesAfter,
    cyclesTarget: state.pomodoroCyclesTarget,
  );
}

SegmentEndSemantics? _semanticsAfterFinishedSegment({
  required List<SegmentPlan> segments,
  required int finishedIndex,
  required bool sessionComplete,
  required int cyclesCompletedAfterSegment,
  required int cyclesTarget,
}) {
  if (finishedIndex < 0 || finishedIndex >= segments.length) {
    return null;
  }
  final finished = segments[finishedIndex].type;
  final nextIndex = finishedIndex + 1;
  final nextType = !sessionComplete && nextIndex < segments.length
      ? segments[nextIndex].type
      : null;
  final progress = segmentEndCycleProgress(
    cyclesCompletedAfterSegment: cyclesCompletedAfterSegment,
    cyclesTarget: cyclesTarget,
    finished: finished,
    sessionComplete: sessionComplete,
  );
  return SegmentEndSemantics(
    finishedType: finished,
    nextType: nextType,
    completedCount: progress.n,
    totalCount: progress.total,
    sessionComplete: sessionComplete,
  );
}
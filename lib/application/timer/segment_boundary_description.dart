import 'package:pomodoro_app/application/timer/segment_end_semantics.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/domain/timer/segment_completion_semantics.dart';

/// What finished for a segment-end Alert (when [segmentEndAlert] is non-null).
class SegmentEndAlertTarget {
  const SegmentEndAlertTarget({
    required this.finishedType,
    required this.sessionComplete,
  });

  final SegmentType finishedType;
  final bool sessionComplete;
}

/// One interpretation of engine before/after for Segment persistence and Alerts.
class SegmentBoundaryDescription {
  const SegmentBoundaryDescription({
    required this.before,
    required this.after,
    required this.significant,
    this.segmentEndAlert,
    this.segmentEndSemantics,
    this.completionSemantics,
  });

  final TimerEngineState before;
  final TimerEngineState after;

  /// Phase or Segment index changed in a way that affects durable Segment rows.
  final bool significant;

  /// Non-null when segment-end Alert routing should run for this transition.
  final SegmentEndAlertTarget? segmentEndAlert;

  /// Finished / next / cycle copy for Alerts and in-app segment-end UI.
  final SegmentEndSemantics? segmentEndSemantics;

  /// Durable Segment row effects for this transition (when [significant]).
  final SegmentCompletionSemantics? completionSemantics;
}

/// Derives the single Segment boundary description for a lifecycle transition.
SegmentBoundaryDescription describeSegmentBoundary({
  required TimerEngineState before,
  required TimerEngineState after,
  required DateTime nowUtc,
}) {
  final significant =
      before.phase != after.phase ||
      before.currentSegmentIndex != after.currentSegmentIndex;

  final alert = significant ? _segmentEndAlert(before, after) : null;
  return SegmentBoundaryDescription(
    before: before,
    after: after,
    significant: significant,
    segmentEndAlert: alert,
    segmentEndSemantics: significant
        ? segmentEndSemanticsFromTransition(
            before: before,
            after: after,
            sessionComplete: alert?.sessionComplete ??
                after.phase == EnginePhase.sessionComplete,
            hasSegmentEndAlert: alert != null,
          )
        : null,
    completionSemantics: significant
        ? deriveSegmentCompletionSemantics(
            before: before,
            after: after,
            nowUtc: nowUtc,
          )
        : null,
  );
}

SegmentEndAlertTarget? _segmentEndAlert(
  TimerEngineState before,
  TimerEngineState after,
) {
  final completedPrompt =
      after.phase == EnginePhase.segmentComplete ||
      after.phase == EnginePhase.sessionComplete;
  final autoAdvanced =
      before.phase == EnginePhase.running &&
      after.phase == EnginePhase.running &&
      before.currentSegmentIndex != after.currentSegmentIndex;
  if ((!completedPrompt && !autoAdvanced) ||
      before.phase != EnginePhase.running) {
    return null;
  }
  final segment = before.currentSegment;
  if (segment == null) {
    return null;
  }
  final isFocusLike =
      segment.type == SegmentType.focus ||
      segment.type == SegmentType.flexible;
  if (!isFocusLike && !segment.isRest) {
    return null;
  }
  return SegmentEndAlertTarget(
    finishedType: segment.type,
    sessionComplete: after.phase == EnginePhase.sessionComplete,
  );
}
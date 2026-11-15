import 'package:pomodoro_app/application/timer/segment_boundary_description.dart';
import 'package:pomodoro_app/application/timer/session_terminal_follow_up.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';

/// Result of a [SessionLifecycle] command — enough for the facade to build
/// [SideEffectContext] without reading private lifecycle fields.
class LifecycleResult {
  const LifecycleResult({
    required this.before,
    required this.after,
    required this.sessionId,
    required this.segmentIds,
    required this.segmentBoundary,
    this.currentSegmentId,
    this.terminalFollowUp = SessionTerminalFollowUp.none,
  });

  final TimerEngineState before;
  final TimerEngineState after;

  /// Single boundary interpretation for durable Segment sync and segment-end Alerts.
  final SegmentBoundaryDescription segmentBoundary;

  /// Session id for side-effect context. Null after discard / when there is
  /// no Session. After abandon or fail, the finalized id (in-memory context
  /// may already be cleared).
  final String? sessionId;

  /// Durable Segment ids aligned with [after.segments] order.
  final List<String> segmentIds;

  /// Id for [after.currentSegmentIndex], when in range.
  final String? currentSegmentId;

  /// Explicit terminal policy after entering [EnginePhase.sessionComplete].
  final SessionTerminalFollowUp terminalFollowUp;
}

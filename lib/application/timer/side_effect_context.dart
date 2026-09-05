import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';

/// Immutable inputs for [TimerSideEffectHub] ops, built by the timer facade.
///
/// Hub must not read mutable coordinator fields or hold a facade back-pointer.
class SideEffectContext {
  const SideEffectContext({
    required this.sessionId,
    this.before,
    this.after,
    required this.isForeground,
    required this.suppressNextSegmentAlert,
    required this.nowUtc,
  });

  /// Active Session id; null when idle / after clear.
  final String? sessionId;

  /// Engine snapshot before the transition (when the op needs it).
  final TimerEngineState? before;

  /// Engine snapshot after the transition (when the op needs it).
  final TimerEngineState? after;

  /// App is interactive — prefer in-app tone over OS tray for segment end.
  final bool isForeground;

  /// Set when user opened from a segment-end push; consumed once on transition.
  final bool suppressNextSegmentAlert;

  /// Wall-clock from the lifecycle/facade clock path (hub has no own clock).
  final DateTime nowUtc;
}

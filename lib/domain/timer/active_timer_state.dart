import 'package:pomodoro_app/domain/common/enums.dart';

/// Persisted singleton timer state (BR-TIMER-020–025).
class ActiveTimerState {
  const ActiveTimerState({
    required this.sessionId,
    required this.enginePhase,
    required this.segmentStartedAtUtcMs,
    required this.flexibleReminderActiveSec,
    required this.lastPersistedAtUtcMs,
    this.currentSegmentId,
    this.pauseStartedAtUtcMs,
    this.frozenRemainingSec,
  });

  final String sessionId;
  final EnginePhase enginePhase;
  final String? currentSegmentId;
  final int segmentStartedAtUtcMs;
  final int flexibleReminderActiveSec;
  final int lastPersistedAtUtcMs;

  /// Wall-clock pause anchor (UTC ms). Required for pause restore (BR-TIMER-003).
  final int? pauseStartedAtUtcMs;

  /// Frozen Pomodoro remaining at pause. Null when not paused / Flexible.
  final int? frozenRemainingSec;
}

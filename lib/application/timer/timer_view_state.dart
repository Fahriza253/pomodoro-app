import 'package:pomodoro_app/domain/common/enums.dart';

/// Presentation-facing timer state ([API_CONTRACT](docs/internal/system/implementation/API_CONTRACT.md)).
class TimerViewState {
  const TimerViewState({
    required this.phase,
    this.mode,
    this.tagId,
    this.tagName,
    this.sessionId,
    required this.displaySec,
    required this.isCountdown,
    this.currentSegmentType,
    this.completedFocusCount = 0,
    this.totalFocusInCycle = 0,
    this.completedCycleCount,
    this.totalCycleTarget,
    this.showRecoveryPrompt = false,
    this.currentPlannedSec,
    this.earlyStopGraceRemainingSec = 0,
    this.segmentEndFinishedType,
    this.segmentEndNextType,
    this.segmentEndCompletedCount,
    this.segmentEndTotalCount,
    this.preStartCountdown,
  });

  factory TimerViewState.idle({
    bool showRecoveryPrompt = false,
    int? preStartCountdown,
    String? tagId,
  }) =>
      TimerViewState(
        phase: EnginePhase.idle,
        displaySec: 0,
        isCountdown: true,
        showRecoveryPrompt: showRecoveryPrompt,
        preStartCountdown: preStartCountdown,
        tagId: tagId,
      );

  final EnginePhase phase;
  final TimerMode? mode;
  final String? tagId;
  final String? tagName;
  final String? sessionId;
  final int displaySec;
  final bool isCountdown;
  final SegmentType? currentSegmentType;
  final int completedFocusCount;
  final int totalFocusInCycle;
  final int? completedCycleCount;
  final int? totalCycleTarget;
  final bool showRecoveryPrompt;
  final int? currentPlannedSec;

  /// Seconds left in BR-TIMER-026 early-stop window (`0` = grace over).
  final int earlyStopGraceRemainingSec;

  /// Segment-end prompt / session-end summary (null outside those phases).
  final SegmentType? segmentEndFinishedType;
  final SegmentType? segmentEndNextType;
  final int? segmentEndCompletedCount;
  final int? segmentEndTotalCount;

  /// Pomodoro 3-2-1 before Session create (`phase == idle` only; not persisted).
  final int? preStartCountdown;

  bool get isPreStart => preStartCountdown != null;

  bool get isWithinEarlyStopGrace => earlyStopGraceRemainingSec > 0;

  bool get hasSegmentEndSummary =>
      segmentEndFinishedType != null &&
      segmentEndCompletedCount != null &&
      segmentEndTotalCount != null;
}

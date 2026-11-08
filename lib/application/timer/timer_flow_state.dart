import 'package:pomodoro_app/domain/common/enums.dart';

/// Explicit presentation flow variants for Timer (migration stage 1).
///
/// [EnginePhase] describes runtime engine flow; [SessionStatus] describes the
/// durable Session row when a Session exists. They are never merged here.
sealed class TimerFlowState {
  const TimerFlowState();
}

/// Idle Tag/mode setup — no active Session, no pre-start, no recovery dialog.
final class TimerIdleSetupFlow extends TimerFlowState {
  const TimerIdleSetupFlow({required this.actions});

  final IdleSetupActions actions;
}

/// Pomodoro 3-2-1 before Session create (ephemeral; not persisted).
final class TimerPomodoroPreStartFlow extends TimerFlowState {
  const TimerPomodoroPreStartFlow({
    required this.tagId,
    required this.countdownSeconds,
    required this.actions,
  });

  final String tagId;
  final int countdownSeconds;
  final PomodoroPreStartActions actions;
}

/// Interrupted Session offer after cold start (UC-04).
final class TimerRecoveryOfferFlow extends TimerFlowState {
  const TimerRecoveryOfferFlow({
    required this.sessionId,
    required this.restoreEnginePhase,
    required this.actions,
  });

  final String sessionId;

  /// Phase stored in [ActiveTimerState] — runtime flow to restore.
  final EnginePhase restoreEnginePhase;
  final RecoveryOfferActions actions;
}

/// Active Session, wall-clock advancing.
final class TimerActiveRunningFlow extends TimerFlowState {
  const TimerActiveRunningFlow({
    required this.mode,
    required this.durableSessionStatus,
    required this.tagId,
    required this.tagName,
    required this.sessionId,
    required this.displaySec,
    required this.isCountdown,
    required this.currentSegmentType,
    required this.completedFocusCount,
    required this.totalFocusInCycle,
    required this.completedCycleCount,
    required this.totalCycleTarget,
    required this.currentPlannedSec,
    required this.earlyStopGraceRemainingSec,
    required this.actions,
  });

  final TimerMode mode;
  final SessionStatus durableSessionStatus;
  final String tagId;
  final String? tagName;
  final String sessionId;
  final int displaySec;
  final bool isCountdown;
  final SegmentType? currentSegmentType;
  final int completedFocusCount;
  final int totalFocusInCycle;
  final int? completedCycleCount;
  final int? totalCycleTarget;
  final int? currentPlannedSec;
  final int earlyStopGraceRemainingSec;
  final ActiveRunningActions actions;
}

/// Active Session frozen (pause).
final class TimerActivePausedFlow extends TimerFlowState {
  const TimerActivePausedFlow({
    required this.mode,
    required this.durableSessionStatus,
    required this.tagId,
    required this.tagName,
    required this.sessionId,
    required this.displaySec,
    required this.isCountdown,
    required this.currentSegmentType,
    required this.completedFocusCount,
    required this.totalFocusInCycle,
    required this.completedCycleCount,
    required this.totalCycleTarget,
    required this.currentPlannedSec,
    required this.earlyStopGraceRemainingSec,
    required this.actions,
  });

  final TimerMode mode;
  final SessionStatus durableSessionStatus;
  final String tagId;
  final String? tagName;
  final String sessionId;
  final int displaySec;
  final bool isCountdown;
  final SegmentType? currentSegmentType;
  final int completedFocusCount;
  final int totalFocusInCycle;
  final int? completedCycleCount;
  final int? totalCycleTarget;
  final int? currentPlannedSec;
  final int earlyStopGraceRemainingSec;
  final ActivePausedActions actions;
}

/// Segment finished; waiting for user or auto-start rules.
final class TimerSegmentCompleteFlow extends TimerFlowState {
  const TimerSegmentCompleteFlow({
    required this.mode,
    required this.durableSessionStatus,
    required this.tagId,
    required this.tagName,
    required this.sessionId,
    required this.displaySec,
    required this.isCountdown,
    required this.pomodoroSummary,
    required this.actions,
  });

  final TimerMode mode;
  final SessionStatus durableSessionStatus;
  final String tagId;
  final String? tagName;
  final String sessionId;
  final int displaySec;
  final bool isCountdown;
  final PomodoroSegmentEndSummary? pomodoroSummary;
  final SegmentCompleteActions actions;
}

/// Session block finished — Pomodoro soft-complete or Flexible terminal UI.
final class TimerSessionCompleteFlow extends TimerFlowState {
  const TimerSessionCompleteFlow({
    required this.mode,
    required this.durableSessionStatus,
    required this.tagId,
    required this.tagName,
    required this.sessionId,
    required this.displaySec,
    required this.isCountdown,
    required this.pomodoroSummary,
    required this.actions,
  });

  final TimerMode mode;

  /// `active` for Pomodoro soft-complete; `completed` after Flexible finalize.
  final SessionStatus durableSessionStatus;
  final String? tagId;
  final String? tagName;
  final String? sessionId;
  final int displaySec;
  final bool isCountdown;
  final PomodoroSegmentEndSummary? pomodoroSummary;
  final SessionCompleteActions actions;
}

/// Pomodoro segment-end / session-end cycle copy inputs.
typedef PomodoroSegmentEndSummary = ({
  SegmentType finishedType,
  SegmentType? nextType,
  int completedCount,
  int totalCount,
});

final class IdleSetupActions {
  const IdleSetupActions({required this.canStartSession});

  final bool canStartSession;
}

final class PomodoroPreStartActions {
  const PomodoroPreStartActions({
    required this.canSkip,
    required this.canCancel,
  });

  final bool canSkip;
  final bool canCancel;
}

final class RecoveryOfferActions {
  const RecoveryOfferActions({
    required this.canResume,
    required this.canDecline,
  });

  final bool canResume;
  final bool canDecline;
}

final class ActiveRunningActions {
  const ActiveRunningActions({
    required this.canPause,
    required this.canStop,
    required this.canSkipBreak,
    required this.canCompleteFlexible,
  });

  final bool canPause;
  final bool canStop;
  final bool canSkipBreak;
  final bool canCompleteFlexible;
}

final class ActivePausedActions {
  const ActivePausedActions({
    required this.canResume,
    required this.canStop,
    required this.canCompleteFlexible,
  });

  final bool canResume;
  final bool canStop;
  final bool canCompleteFlexible;
}

final class SegmentCompleteActions {
  const SegmentCompleteActions({
    required this.canAdvanceSegment,
    required this.canSkipBreak,
  });

  final bool canAdvanceSegment;
  final bool canSkipBreak;
}

final class SessionCompleteActions {
  const SessionCompleteActions({
    required this.canRestartSameTag,
    required this.canDismiss,
  });

  final bool canRestartSameTag;
  final bool canDismiss;
}

import 'package:pomodoro_app/application/timer/timer_flow_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';

/// How a projected [TimerFlowState] update should fan out to UI consumers.
enum TimerFlowChangeKind {
  none,
  displayTick,
  chrome,
  activeSession,
  recoveryOrCompletion,
}

/// Classifies flow updates without comparing every legacy [TimerViewState] field.
TimerFlowChangeKind classifyTimerFlowChange(
  TimerFlowState previous,
  TimerFlowState next,
) {
  if (previous == next) {
    return TimerFlowChangeKind.none;
  }
  if (_recoveryOrCompletionChanged(previous, next)) {
    return TimerFlowChangeKind.recoveryOrCompletion;
  }
  if (_activeSessionChanged(previous, next)) {
    return TimerFlowChangeKind.activeSession;
  }
  if (_chromeChanged(previous, next)) {
    return TimerFlowChangeKind.chrome;
  }
  if (_displayTickChanged(previous, next)) {
    return TimerFlowChangeKind.displayTick;
  }
  return TimerFlowChangeKind.none;
}

/// True when chrome-oriented providers may skip this update (display-only tick).
bool sameTimerFlowChrome(TimerFlowState a, TimerFlowState b) {
  final kind = classifyTimerFlowChange(a, b);
  return kind == TimerFlowChangeKind.none ||
      kind == TimerFlowChangeKind.displayTick;
}

bool _recoveryOrCompletionChanged(TimerFlowState a, TimerFlowState b) {
  if (a.runtimeType == b.runtimeType) {
    return false;
  }
  if (_isActiveRunPauseSwap(a, b)) {
    return false;
  }
  return true;
}

bool _isActiveRunPauseSwap(TimerFlowState a, TimerFlowState b) {
  return (a is TimerActiveRunningFlow && b is TimerActivePausedFlow) ||
      (a is TimerActivePausedFlow && b is TimerActiveRunningFlow);
}

bool _activeSessionChanged(TimerFlowState a, TimerFlowState b) {
  if (_isActiveRunPauseSwap(a, b)) {
    return true;
  }
  final sessionA = _sessionId(a);
  final sessionB = _sessionId(b);
  if (sessionA != sessionB) {
    return true;
  }
  final segmentA = _segmentType(a);
  final segmentB = _segmentType(b);
  return segmentA != segmentB;
}

bool _chromeChanged(TimerFlowState a, TimerFlowState b) {
  if (a.runtimeType != b.runtimeType) {
    return false;
  }
  return switch ((a, b)) {
    (TimerIdleSetupFlow(), TimerIdleSetupFlow()) => false,
    (TimerPomodoroPreStartFlow a, TimerPomodoroPreStartFlow b) =>
      a.tagId != b.tagId || a.countdownSeconds != b.countdownSeconds,
    (TimerRecoveryOfferFlow a, TimerRecoveryOfferFlow b) =>
      a.sessionId != b.sessionId || a.restoreEnginePhase != b.restoreEnginePhase,
    (TimerActiveRunningFlow a, TimerActiveRunningFlow b) =>
      _runningChromeChanged(a, b),
    (TimerActivePausedFlow a, TimerActivePausedFlow b) =>
      _pausedChromeChanged(a, b),
    (TimerSegmentCompleteFlow a, TimerSegmentCompleteFlow b) =>
      a.mode != b.mode ||
          a.tagId != b.tagId ||
          a.pomodoroSummary != b.pomodoroSummary ||
          a.durableSessionStatus != b.durableSessionStatus,
    (TimerSessionCompleteFlow a, TimerSessionCompleteFlow b) =>
      a.mode != b.mode ||
          a.tagId != b.tagId ||
          a.pomodoroSummary != b.pomodoroSummary ||
          a.durableSessionStatus != b.durableSessionStatus ||
          a.sessionId != b.sessionId,
    _ => true,
  };
}

bool _displayTickChanged(TimerFlowState a, TimerFlowState b) {
  if (a.runtimeType != b.runtimeType) {
    return false;
  }
  return switch ((a, b)) {
    (TimerActiveRunningFlow a, TimerActiveRunningFlow b) =>
      a.displaySec != b.displaySec ||
          a.earlyStopGraceRemainingSec != b.earlyStopGraceRemainingSec,
    (TimerActivePausedFlow a, TimerActivePausedFlow b) =>
      a.displaySec != b.displaySec ||
          a.earlyStopGraceRemainingSec != b.earlyStopGraceRemainingSec,
    _ => false,
  };
}

bool _runningChromeChanged(TimerActiveRunningFlow a, TimerActiveRunningFlow b) {
  return a.mode != b.mode ||
      a.tagId != b.tagId ||
      a.tagName != b.tagName ||
      a.isCountdown != b.isCountdown ||
      a.currentSegmentType != b.currentSegmentType ||
      a.completedFocusCount != b.completedFocusCount ||
      a.totalFocusInCycle != b.totalFocusInCycle ||
      a.completedCycleCount != b.completedCycleCount ||
      a.totalCycleTarget != b.totalCycleTarget ||
      a.currentPlannedSec != b.currentPlannedSec ||
      a.durableSessionStatus != b.durableSessionStatus;
}

bool _pausedChromeChanged(TimerActivePausedFlow a, TimerActivePausedFlow b) {
  return a.mode != b.mode ||
      a.tagId != b.tagId ||
      a.tagName != b.tagName ||
      a.isCountdown != b.isCountdown ||
      a.currentSegmentType != b.currentSegmentType ||
      a.completedFocusCount != b.completedFocusCount ||
      a.totalFocusInCycle != b.totalFocusInCycle ||
      a.completedCycleCount != b.completedCycleCount ||
      a.totalCycleTarget != b.totalCycleTarget ||
      a.currentPlannedSec != b.currentPlannedSec ||
      a.durableSessionStatus != b.durableSessionStatus;
}

String? _sessionId(TimerFlowState state) => switch (state) {
  TimerActiveRunningFlow(:final sessionId) => sessionId,
  TimerActivePausedFlow(:final sessionId) => sessionId,
  TimerSegmentCompleteFlow(:final sessionId) => sessionId,
  TimerSessionCompleteFlow(:final sessionId) => sessionId,
  TimerRecoveryOfferFlow(:final sessionId) => sessionId,
  _ => null,
};

SegmentType? _segmentType(TimerFlowState state) => switch (state) {
  TimerActiveRunningFlow(:final currentSegmentType) => currentSegmentType,
  TimerActivePausedFlow(:final currentSegmentType) => currentSegmentType,
  _ => null,
};

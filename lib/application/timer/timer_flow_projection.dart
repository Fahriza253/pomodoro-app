import 'package:pomodoro_app/application/timer/segment_end_cycle_progress.dart';
import 'package:pomodoro_app/application/timer/timer_flow_state.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/domain/timer/early_stop_grace.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';

/// Inputs for projecting legacy view-state and explicit flow variants together.
final class TimerProjectionContext {
  const TimerProjectionContext({
    required this.engineState,
    required this.nowUtc,
    required this.totalActiveSec,
    required this.lifecycleTagId,
    required this.lifecycleTagName,
    required this.lifecycleSessionId,
    required this.hasActiveSession,
    required this.showRecoveryPrompt,
    required this.pendingRecovery,
    required this.preStartCountdown,
    required this.preStartTagId,
  });

  final TimerEngineState engineState;
  final DateTime nowUtc;
  final int totalActiveSec;
  final String? lifecycleTagId;
  final String? lifecycleTagName;
  final String? lifecycleSessionId;
  final bool hasActiveSession;
  final bool showRecoveryPrompt;
  final ActiveTimerState? pendingRecovery;
  final int? preStartCountdown;
  final String? preStartTagId;
}

TimerViewState projectTimerViewState(TimerProjectionContext context) {
  final state = context.engineState;

  if (state.phase == EnginePhase.idle) {
    return TimerViewState.idle(
      showRecoveryPrompt: context.showRecoveryPrompt,
      preStartCountdown: context.preStartCountdown,
      tagId: context.preStartTagId,
    );
  }

  final isCountdown = state.isPomodoro;
  final displaySec = isCountdown
      ? state.remainingSecAt(context.nowUtc)
      : state.elapsedActiveSecAt(context.nowUtc);
  final graceRemaining =
      (state.phase == EnginePhase.running || state.phase == EnginePhase.paused)
      ? earlyStopGraceRemainingSec(context.totalActiveSec)
      : 0;

  final endSummary = _pomodoroSegmentEndSummary(state);

  return TimerViewState(
    phase: state.phase,
    mode: state.mode,
    tagId: context.lifecycleTagId,
    tagName: context.lifecycleTagName,
    sessionId: context.lifecycleSessionId,
    displaySec: displaySec,
    isCountdown: isCountdown,
    currentSegmentType: state.currentSegment?.type,
    completedFocusCount: state.pomodoroFocusCount,
    totalFocusInCycle: state.config?.sessionsBeforeLongBreak ?? 0,
    completedCycleCount: state.isPomodoro ? state.pomodoroCyclesCompleted : null,
    totalCycleTarget: state.isPomodoro ? state.pomodoroCyclesTarget : null,
    showRecoveryPrompt: context.showRecoveryPrompt,
    currentPlannedSec: state.currentSegment?.plannedSec,
    earlyStopGraceRemainingSec: graceRemaining,
    segmentEndFinishedType: endSummary?.finishedType,
    segmentEndNextType: endSummary?.nextType,
    segmentEndCompletedCount: endSummary?.completedCount,
    segmentEndTotalCount: endSummary?.totalCount,
  );
}

TimerFlowState projectTimerFlowState(TimerProjectionContext context) {
  if (context.showRecoveryPrompt && context.pendingRecovery != null) {
    final pending = context.pendingRecovery!;
    return TimerRecoveryOfferFlow(
      sessionId: pending.sessionId,
      restoreEnginePhase: pending.enginePhase,
      actions: const RecoveryOfferActions(canResume: true, canDecline: true),
    );
  }

  if (context.preStartCountdown != null && context.preStartTagId != null) {
    return TimerPomodoroPreStartFlow(
      tagId: context.preStartTagId!,
      countdownSeconds: context.preStartCountdown!,
      actions: const PomodoroPreStartActions(canSkip: true, canCancel: true),
    );
  }

  final state = context.engineState;
  if (state.phase == EnginePhase.idle) {
    return const TimerIdleSetupFlow(
      actions: IdleSetupActions(canStartSession: true),
    );
  }

  final durableStatus = _durableSessionStatus(context);
  final isCountdown = state.isPomodoro;
  final displaySec = isCountdown
      ? state.remainingSecAt(context.nowUtc)
      : state.elapsedActiveSecAt(context.nowUtc);
  final graceRemaining =
      (state.phase == EnginePhase.running || state.phase == EnginePhase.paused)
      ? earlyStopGraceRemainingSec(context.totalActiveSec)
      : 0;
  final summary = _pomodoroSegmentEndSummary(state);

  return switch (state.phase) {
    EnginePhase.running => TimerActiveRunningFlow(
      mode: state.mode!,
      durableSessionStatus: durableStatus,
      tagId: context.lifecycleTagId!,
      tagName: context.lifecycleTagName,
      sessionId: context.lifecycleSessionId!,
      displaySec: displaySec,
      isCountdown: isCountdown,
      currentSegmentType: state.currentSegment?.type,
      completedFocusCount: state.pomodoroFocusCount,
      totalFocusInCycle: state.config?.sessionsBeforeLongBreak ?? 0,
      completedCycleCount: state.isPomodoro ? state.pomodoroCyclesCompleted : null,
      totalCycleTarget: state.isPomodoro ? state.pomodoroCyclesTarget : null,
      currentPlannedSec: state.currentSegment?.plannedSec,
      earlyStopGraceRemainingSec: graceRemaining,
      actions: ActiveRunningActions(
        canPause: true,
        canStop: true,
        canSkipBreak:
            state.isPomodoro &&
            state.currentSegment?.type == SegmentType.shortRest,
        canCompleteFlexible: state.isFlexible,
      ),
    ),
    EnginePhase.paused => TimerActivePausedFlow(
      mode: state.mode!,
      durableSessionStatus: durableStatus,
      tagId: context.lifecycleTagId!,
      tagName: context.lifecycleTagName,
      sessionId: context.lifecycleSessionId!,
      displaySec: displaySec,
      isCountdown: isCountdown,
      currentSegmentType: state.currentSegment?.type,
      completedFocusCount: state.pomodoroFocusCount,
      totalFocusInCycle: state.config?.sessionsBeforeLongBreak ?? 0,
      completedCycleCount: state.isPomodoro ? state.pomodoroCyclesCompleted : null,
      totalCycleTarget: state.isPomodoro ? state.pomodoroCyclesTarget : null,
      currentPlannedSec: state.currentSegment?.plannedSec,
      earlyStopGraceRemainingSec: graceRemaining,
      actions: ActivePausedActions(
        canResume: true,
        canStop: true,
        canCompleteFlexible: state.isFlexible,
      ),
    ),
    EnginePhase.segmentComplete => TimerSegmentCompleteFlow(
      mode: state.mode!,
      durableSessionStatus: durableStatus,
      tagId: context.lifecycleTagId!,
      tagName: context.lifecycleTagName,
      sessionId: context.lifecycleSessionId!,
      displaySec: displaySec,
      isCountdown: isCountdown,
      pomodoroSummary: summary,
      actions: SegmentCompleteActions(
        canAdvanceSegment: true,
        canSkipBreak:
            state.isPomodoro && summary?.nextType == SegmentType.shortRest,
      ),
    ),
    EnginePhase.sessionComplete => TimerSessionCompleteFlow(
      mode: state.mode!,
      durableSessionStatus: durableStatus,
      tagId: context.lifecycleTagId,
      tagName: context.lifecycleTagName,
      sessionId: context.lifecycleSessionId,
      displaySec: displaySec,
      isCountdown: isCountdown,
      pomodoroSummary: summary,
      actions: const SessionCompleteActions(
        canRestartSameTag: true,
        canDismiss: true,
      ),
    ),
    EnginePhase.idle => const TimerIdleSetupFlow(
      actions: IdleSetupActions(canStartSession: true),
    ),
  };
}

SessionStatus _durableSessionStatus(TimerProjectionContext context) {
  final phase = context.engineState.phase;
  if (phase == EnginePhase.sessionComplete && !context.hasActiveSession) {
    return SessionStatus.completed;
  }
  return SessionStatus.active;
}

PomodoroSegmentEndSummary? _pomodoroSegmentEndSummary(TimerEngineState state) {
  if (state.phase != EnginePhase.segmentComplete &&
      state.phase != EnginePhase.sessionComplete) {
    return null;
  }
  if (!state.isPomodoro || state.segments.isEmpty) {
    return null;
  }
  final index = state.currentSegmentIndex;
  if (index < 0 || index >= state.segments.length) {
    return null;
  }
  final sessionComplete = state.phase == EnginePhase.sessionComplete;
  final nextIndex = index + 1;
  final nextType = !sessionComplete && nextIndex < state.segments.length
      ? state.segments[nextIndex].type
      : null;
  final finished = state.segments[index].type;
  final progress = segmentEndCycleProgress(
    cyclesCompletedAfterSegment: state.pomodoroCyclesCompleted,
    cyclesTarget: state.pomodoroCyclesTarget,
    finished: finished,
    sessionComplete: sessionComplete,
  );
  return (
    finishedType: finished,
    nextType: nextType,
    completedCount: progress.n,
    totalCount: progress.total,
  );
}

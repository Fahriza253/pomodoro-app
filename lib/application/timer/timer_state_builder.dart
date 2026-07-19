import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';

/// Rebuilds [TimerEngineState] from persisted session + active timer row.
class TimerStateBuilder {
  const TimerStateBuilder();

  TimerEngineState fromPersisted({
    required Session session,
    required List<SessionSegment> dbSegments,
    required ActiveTimerState persisted,
  }) {
    if (dbSegments.isEmpty) {
      throw StateError(
        'Cannot restore timer: session ${session.id} has no segments',
      );
    }

    final segments = dbSegments
        .map(
          (s) => SegmentPlan(
            type: s.type,
            plannedSec: s.plannedSec,
            orderIndex: s.orderIndex,
          ),
        )
        .toList();

    var currentIndex = 0;
    if (persisted.currentSegmentId != null) {
      final idx = dbSegments.indexWhere(
        (s) => s.id == persisted.currentSegmentId,
      );
      if (idx >= 0) {
        currentIndex = idx;
      }
    }
    if (currentIndex >= dbSegments.length) {
      currentIndex = 0;
    }

    final currentDbSegment = dbSegments[currentIndex];
    final segmentStarted = DateTime.fromMillisecondsSinceEpoch(
      persisted.segmentStartedAtUtcMs,
      isUtc: true,
    );
    final sessionStarted = DateTime.fromMillisecondsSinceEpoch(
      session.startedAtUtcMs,
      isUtc: true,
    );

    var state = TimerEngineState(
      phase: persisted.enginePhase,
      mode: session.mode,
      config: session.configSnapshot,
      segments: segments,
      currentSegmentIndex: currentIndex,
      pomodoroFocusCount: session.pomodoroFocusCount,
      pomodoroCyclesCompleted: session.pomodoroCyclesCompleted,
      pomodoroCyclesTarget:
          session.pomodoroCyclesTarget ??
          session.configSnapshot.totalCycles ??
          0,
      segmentStartedAtUtc: segmentStarted,
      segmentPausedSec: currentDbSegment.segmentPausedSec,
      sessionStartedAtUtc: sessionStarted,
      sessionTotalPausedSec: session.totalPausedSec,
      flexibleReminderActiveSec: persisted.flexibleReminderActiveSec,
    );

    if (persisted.enginePhase == EnginePhase.paused) {
      state = _restorePausedAnchors(
        state: state,
        session: session,
        currentDbSegment: currentDbSegment,
        segmentStarted: segmentStarted,
        persisted: persisted,
      );
    }

    if (persisted.enginePhase == EnginePhase.running &&
        session.mode == TimerMode.flexible) {
      state = _restoreFlexibleReminderBase(
        state: state,
        sessionStarted: sessionStarted,
        sessionTotalPausedSec: session.totalPausedSec,
        persisted: persisted,
      );
    }

    if (persisted.enginePhase == EnginePhase.segmentComplete ||
        persisted.enginePhase == EnginePhase.sessionComplete) {
      state = state.copyWith(frozenRemainingSec: 0);
    }

    return state;
  }

  List<String> segmentIdsFromDb(List<SessionSegment> dbSegments) =>
      dbSegments.map((s) => s.id).toList();

  TimerEngineState _restorePausedAnchors({
    required TimerEngineState state,
    required Session session,
    required SessionSegment currentDbSegment,
    required DateTime segmentStarted,
    required ActiveTimerState persisted,
  }) {
    final pauseStartedMs =
        persisted.pauseStartedAtUtcMs ?? persisted.lastPersistedAtUtcMs;
    final pauseStarted = DateTime.fromMillisecondsSinceEpoch(
      pauseStartedMs,
      isUtc: true,
    );

    if (session.mode == TimerMode.pomodoro) {
      final frozen =
          persisted.frozenRemainingSec ??
          TimerEngineState.wallClockRemaining(
            plannedSec: currentDbSegment.plannedSec,
            segmentStartedAtUtc: segmentStarted,
            segmentPausedSec: currentDbSegment.segmentPausedSec,
            nowUtc: pauseStarted,
          );
      return state.copyWith(
        pauseStartedAtUtc: pauseStarted,
        frozenRemainingSec: frozen,
      );
    }

    // Flexible: only pause start is required for resume (BR-TIMER-010).
    return state.copyWith(pauseStartedAtUtc: pauseStarted);
  }

  /// Rebuild reminder base so background gap continues the interval counter.
  TimerEngineState _restoreFlexibleReminderBase({
    required TimerEngineState state,
    required DateTime sessionStarted,
    required int sessionTotalPausedSec,
    required ActiveTimerState persisted,
  }) {
    final persistedAt = DateTime.fromMillisecondsSinceEpoch(
      persisted.lastPersistedAtUtcMs,
      isUtc: true,
    );
    final elapsedAtPersist =
        persistedAt.difference(sessionStarted).inSeconds - sessionTotalPausedSec;
    final safeElapsed = elapsedAtPersist < 0 ? 0 : elapsedAtPersist;
    final base = safeElapsed - persisted.flexibleReminderActiveSec;
    return state.copyWith(
      flexibleReminderBaseElapsedSec: base < 0 ? 0 : base,
      flexibleReminderActiveSec: persisted.flexibleReminderActiveSec,
    );
  }
}

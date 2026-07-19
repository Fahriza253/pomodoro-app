import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';

/// Immutable runtime snapshot emitted by [TimerEngine].
class TimerEngineState {
  const TimerEngineState({
    required this.phase,
    this.mode,
    this.config,
    this.segments = const [],
    this.currentSegmentIndex = -1,
    this.pomodoroFocusCount = 0,
    this.pomodoroCyclesCompleted = 0,
    this.pomodoroCyclesTarget = 0,
    this.segmentStartedAtUtc,
    this.segmentPausedSec = 0,
    this.sessionStartedAtUtc,
    this.sessionTotalPausedSec = 0,
    this.pauseStartedAtUtc,
    this.frozenRemainingSec,
    this.flexibleReminderActiveSec = 0,
    this.flexibleReminderBaseElapsedSec = 0,
    this.lastOutcome = SessionOutcome.none,
  });

  factory TimerEngineState.initial() =>
      const TimerEngineState(phase: EnginePhase.idle);

  final EnginePhase phase;
  final TimerMode? mode;
  final ConfigSnapshot? config;
  final List<SegmentPlan> segments;
  final int currentSegmentIndex;
  final int pomodoroFocusCount;
  final int pomodoroCyclesCompleted;
  final int pomodoroCyclesTarget;
  final DateTime? segmentStartedAtUtc;
  final int segmentPausedSec;
  final DateTime? sessionStartedAtUtc;
  final int sessionTotalPausedSec;
  final DateTime? pauseStartedAtUtc;
  final int? frozenRemainingSec;
  final int flexibleReminderActiveSec;

  /// Session active-elapsed (sec) when the Flexible reminder counter was last
  /// zeroed (start / resume / fire). Counter = elapsed − this base (BR-TIMER-011).
  final int flexibleReminderBaseElapsedSec;
  final SessionOutcome lastOutcome;

  SegmentPlan? get currentSegment {
    if (currentSegmentIndex < 0 || currentSegmentIndex >= segments.length) {
      return null;
    }
    return segments[currentSegmentIndex];
  }

  bool get isPomodoro => mode == TimerMode.pomodoro;
  bool get isFlexible => mode == TimerMode.flexible;

  /// Wall-clock remaining for Pomodoro countdown (BR-GLOBAL-003, BR-TIMER-003).
  int remainingSecAt(DateTime nowUtc) {
    if (isFlexible) {
      return 0;
    }

    if (phase == EnginePhase.paused) return frozenRemainingSec ?? 0;

    if (phase != EnginePhase.running) return frozenRemainingSec ?? 0;

    final segment = currentSegment;
    final started = segmentStartedAtUtc;
    if (segment == null || started == null) return 0;

    return _wallClockRemaining(
      plannedSec: segment.plannedSec,
      segmentStartedAtUtc: started,
      segmentPausedSec: segmentPausedSec,
      nowUtc: nowUtc,
    );
  }

  /// Count-up active elapsed for Flexible (BR-TIMER-010); excludes pause.
  int elapsedActiveSecAt(DateTime nowUtc) {
    if (!isFlexible) return 0;

    final started = sessionStartedAtUtc;
    if (started == null) return 0;

    var paused = sessionTotalPausedSec;
    if (phase == EnginePhase.paused && pauseStartedAtUtc != null) {
      final openPause = nowUtc.difference(pauseStartedAtUtc!).inSeconds;
      paused += openPause < 0 ? 0 : openPause;
    }

    final total = nowUtc.difference(started).inSeconds - paused;
    return total < 0 ? 0 : total;
  }

  /// Active seconds elapsed on the current segment (Pomodoro or Flexible).
  ///
  /// Used when stopping / failing mid-segment so Timeline keeps real `actualSec`.
  int currentSegmentElapsedActiveSecAt(DateTime nowUtc) {
    if (isFlexible) {
      return elapsedActiveSecAt(nowUtc);
    }
    final segment = currentSegment;
    if (segment == null) return 0;
    final remaining = remainingSecAt(nowUtc);
    final elapsed = segment.plannedSec - remaining;
    if (elapsed < 0) return 0;
    if (elapsed > segment.plannedSec) return segment.plannedSec;
    return elapsed;
  }

  /// Active seconds toward the next Flexible reminder (BR-TIMER-011/012).
  int flexibleReminderActiveSecAt(DateTime nowUtc) {
    if (!isFlexible || phase != EnginePhase.running) {
      return 0;
    }
    final value = elapsedActiveSecAt(nowUtc) - flexibleReminderBaseElapsedSec;
    return value < 0 ? 0 : value;
  }

  static int wallClockRemaining({
    required int plannedSec,
    required DateTime segmentStartedAtUtc,
    required int segmentPausedSec,
    required DateTime nowUtc,
  }) =>
      _wallClockRemaining(
        plannedSec: plannedSec,
        segmentStartedAtUtc: segmentStartedAtUtc,
        segmentPausedSec: segmentPausedSec,
        nowUtc: nowUtc,
      );

  static int _wallClockRemaining({
    required int plannedSec,
    required DateTime segmentStartedAtUtc,
    required int segmentPausedSec,
    required DateTime nowUtc,
  }) {
    final rawElapsed =
        nowUtc.difference(segmentStartedAtUtc).inSeconds - segmentPausedSec;
    final elapsed = rawElapsed < 0 ? 0 : rawElapsed;
    final remaining = plannedSec - elapsed;
    if (remaining < 0) return 0;
    // Clock skew: never report more remaining than planned.
    if (remaining > plannedSec) return plannedSec;
    return remaining;
  }

  TimerEngineState copyWith({
    EnginePhase? phase,
    TimerMode? mode,
    ConfigSnapshot? config,
    List<SegmentPlan>? segments,
    int? currentSegmentIndex,
    int? pomodoroFocusCount,
    int? pomodoroCyclesCompleted,
    int? pomodoroCyclesTarget,
    DateTime? segmentStartedAtUtc,
    int? segmentPausedSec,
    DateTime? sessionStartedAtUtc,
    int? sessionTotalPausedSec,
    DateTime? pauseStartedAtUtc,
    int? frozenRemainingSec,
    bool clearPauseStartedAt = false,
    bool clearFrozenRemaining = false,
    int? flexibleReminderActiveSec,
    int? flexibleReminderBaseElapsedSec,
    SessionOutcome? lastOutcome,
  }) {
    return TimerEngineState(
      phase: phase ?? this.phase,
      mode: mode ?? this.mode,
      config: config ?? this.config,
      segments: segments ?? this.segments,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
      pomodoroFocusCount: pomodoroFocusCount ?? this.pomodoroFocusCount,
      pomodoroCyclesCompleted:
          pomodoroCyclesCompleted ?? this.pomodoroCyclesCompleted,
      pomodoroCyclesTarget: pomodoroCyclesTarget ?? this.pomodoroCyclesTarget,
      segmentStartedAtUtc: segmentStartedAtUtc ?? this.segmentStartedAtUtc,
      segmentPausedSec: segmentPausedSec ?? this.segmentPausedSec,
      sessionStartedAtUtc: sessionStartedAtUtc ?? this.sessionStartedAtUtc,
      sessionTotalPausedSec:
          sessionTotalPausedSec ?? this.sessionTotalPausedSec,
      pauseStartedAtUtc: clearPauseStartedAt
          ? null
          : (pauseStartedAtUtc ?? this.pauseStartedAtUtc),
      frozenRemainingSec: clearFrozenRemaining
          ? null
          : (frozenRemainingSec ?? this.frozenRemainingSec),
      flexibleReminderActiveSec:
          flexibleReminderActiveSec ?? this.flexibleReminderActiveSec,
      flexibleReminderBaseElapsedSec:
          flexibleReminderBaseElapsedSec ?? this.flexibleReminderBaseElapsedSec,
      lastOutcome: lastOutcome ?? this.lastOutcome,
    );
  }
}

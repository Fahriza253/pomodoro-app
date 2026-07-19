import 'dart:async';

import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/session_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/domain/timer/segment_planner.dart';
import 'package:pomodoro_app/domain/timer/timer_transition_error.dart';

/// Pure-Dart Pomodoro & Flexible timer state machine (BR-GLOBAL-003).
///
/// Wall-clock accuracy: time is derived from timestamps on [tick], not from
/// periodic callbacks alone. Domain MUST NOT persist to DB (BR-TIMER-025).
class TimerEngine {
  TimerEngine({SegmentPlanner? planner})
    : _planner = planner ?? const SegmentPlanner();

  final SegmentPlanner _planner;
  final _stateController = StreamController<TimerEngineState>.broadcast();

  TimerEngineState _state = TimerEngineState.initial();

  TimerEngineState get currentState => _state;
  Stream<TimerEngineState> get states => _stateController.stream;

  void dispose() {
    _stateController.close();
  }

  void startPomodoro(SessionPlan plan, DateTime nowUtc) {
    _requirePhase(EnginePhase.idle, 'startPomodoro');
    if (plan.config.mode != TimerMode.pomodoro) {
      throw TimerTransitionError('SessionPlan config must be pomodoro');
    }
    if (plan.segments.isEmpty) {
      throw TimerTransitionError('SessionPlan must include segments');
    }

    _emit(
      TimerEngineState(
        phase: EnginePhase.running,
        mode: TimerMode.pomodoro,
        config: plan.config,
        segments: List.unmodifiable(plan.segments),
        currentSegmentIndex: 0,
        pomodoroCyclesTarget: plan.cyclesTarget,
        segmentStartedAtUtc: nowUtc.toUtc(),
        sessionStartedAtUtc: nowUtc.toUtc(),
        lastOutcome: SessionOutcome.none,
      ),
    );
  }

  void startFlexible(ConfigSnapshot config, DateTime nowUtc) {
    _requirePhase(EnginePhase.idle, 'startFlexible');
    if (config.mode != TimerMode.flexible) {
      throw TimerTransitionError('Config must be flexible mode');
    }

    final segment = _planner.buildFlexibleSegment(config);
    _emit(
      TimerEngineState(
        phase: EnginePhase.running,
        mode: TimerMode.flexible,
        config: config,
        segments: [segment],
        currentSegmentIndex: 0,
        segmentStartedAtUtc: nowUtc.toUtc(),
        sessionStartedAtUtc: nowUtc.toUtc(),
        flexibleReminderActiveSec: 0,
        flexibleReminderBaseElapsedSec: 0,
        lastOutcome: SessionOutcome.none,
      ),
    );
  }

  void pause(DateTime nowUtc) {
    _requirePhase(EnginePhase.running, 'pause');
    final now = nowUtc.toUtc();

    if (_state.isFlexible) {
      final pauseStarted = now;
      _emit(
        _state.copyWith(
          phase: EnginePhase.paused,
          pauseStartedAtUtc: pauseStarted,
          flexibleReminderActiveSec: 0, // BR-TIMER-012
        ),
      );
      return;
    }

    final remaining = _state.remainingSecAt(now);
    _emit(
      _state.copyWith(
        phase: EnginePhase.paused,
        pauseStartedAtUtc: now,
        frozenRemainingSec: remaining,
      ),
    );
  }

  void resume(DateTime nowUtc) {
    _requirePhase(EnginePhase.paused, 'resume');
    final now = nowUtc.toUtc();
    final pauseStarted = _state.pauseStartedAtUtc;
    if (pauseStarted == null) {
      throw TimerTransitionError('Missing pauseStartedAtUtc on resume');
    }

    final rawPause = now.difference(pauseStarted).inSeconds;
    final pauseDuration = rawPause < 0 ? 0 : rawPause;

    if (_state.isFlexible) {
      final next = _state.copyWith(
        phase: EnginePhase.running,
        sessionTotalPausedSec: _state.sessionTotalPausedSec + pauseDuration,
        clearPauseStartedAt: true,
      );
      final elapsed = next.elapsedActiveSecAt(now);
      _emit(
        next.copyWith(
          flexibleReminderBaseElapsedSec: elapsed,
          flexibleReminderActiveSec: 0,
        ),
      );
      return;
    }

    // Re-anchor segment start so frozen remaining is exact even if the
    // wall clock jumped during pause (BR-TIMER-003).
    final frozen = _state.frozenRemainingSec;
    final segment = _state.currentSegment;
    if (frozen != null && segment != null) {
      final activeAlready = segment.plannedSec - frozen;
      final safeActive = activeAlready < 0 ? 0 : activeAlready;
      _emit(
        _state.copyWith(
          phase: EnginePhase.running,
          segmentStartedAtUtc: now.subtract(Duration(seconds: safeActive)),
          segmentPausedSec: 0,
          clearPauseStartedAt: true,
          clearFrozenRemaining: true,
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        phase: EnginePhase.running,
        segmentPausedSec: _state.segmentPausedSec + pauseDuration,
        clearPauseStartedAt: true,
        clearFrozenRemaining: true,
      ),
    );
  }

  /// Recompute display values; auto-advance Pomodoro when countdown hits 0.
  void tick(DateTime nowUtc) {
    final now = nowUtc.toUtc();

    if (_state.phase == EnginePhase.running && _state.isPomodoro) {
      final remaining = _state.remainingSecAt(now);
      if (remaining <= 0) {
        _completeCurrentSegment(now, skipped: false);
        return;
      }
    }

    if (_state.phase == EnginePhase.running && _state.isFlexible) {
      final reminder = _state.flexibleReminderActiveSecAt(now);
      _emit(_state.copyWith(flexibleReminderActiveSec: reminder));
      return;
    }

    _emit(_state);
  }

  /// Reset Flexible reminder counter after a reminder is shown (BR-TIMER-011).
  void acknowledgeFlexibleReminder(DateTime nowUtc) {
    if (!_state.isFlexible || _state.phase != EnginePhase.running) {
      return;
    }
    final now = nowUtc.toUtc();
    final elapsed = _state.elapsedActiveSecAt(now);
    _emit(
      _state.copyWith(
        flexibleReminderBaseElapsedSec: elapsed,
        flexibleReminderActiveSec: 0,
      ),
    );
  }

  void advanceFromSegmentComplete(DateTime nowUtc) {
    _requirePhase(EnginePhase.segmentComplete, 'advanceFromSegmentComplete');
    _startNextSegment(nowUtc.toUtc(), autoStarted: false);
  }

  /// Skip pending, running, or just-completed rest segment (BR-TIMER-004).
  ///
  /// Allowed when:
  /// - [EnginePhase.running] + current rest
  /// - [EnginePhase.segmentComplete] + current rest (wait after rest done)
  /// - [EnginePhase.segmentComplete] + current focus + pending next rest
  ///   (prompt "Lewati istirahat" before rest starts)
  void skipBreak(DateTime nowUtc) {
    final now = nowUtc.toUtc();
    final segment = _state.currentSegment;
    if (segment == null) {
      throw TimerTransitionError('skipBreak requires an active segment');
    }

    if (_state.phase == EnginePhase.running) {
      if (!segment.isRest) {
        throw TimerTransitionError('skipBreak requires a rest segment');
      }
      _completeCurrentSegment(now, skipped: true);
      return;
    }

    if (_state.phase == EnginePhase.segmentComplete) {
      if (segment.isRest) {
        // Rest already finished — skip inter-segment wait (BR-TIMER-004).
        if (_state.pomodoroCyclesCompleted >= _state.pomodoroCyclesTarget &&
            segment.type == SegmentType.longRest) {
          throw TimerTransitionError(
            'Cannot skipBreak: session already at cycle target',
          );
        }
        _startNextSegment(now, autoStarted: false);
        return;
      }

      if (segment.type == SegmentType.focus) {
        _skipPendingRestAfterFocus(now);
        return;
      }

      throw TimerTransitionError(
        'skipBreak requires a rest segment or pending rest after focus',
      );
    }

    throw TimerTransitionError(
      'skipBreak requires running or segmentComplete phase',
    );
  }

  /// From post-focus prompt: mark pending rest skipped and start next focus
  /// (or [EnginePhase.sessionComplete] if that rest closed the cycle).
  void _skipPendingRestAfterFocus(DateTime nowUtc) {
    final restIndex = _state.currentSegmentIndex + 1;
    if (restIndex >= _state.segments.length) {
      throw TimerTransitionError('No pending rest to skip');
    }

    final rest = _state.segments[restIndex];
    if (!rest.isRest) {
      throw TimerTransitionError('skipBreak requires a pending rest segment');
    }

    var focusCount = _state.pomodoroFocusCount;
    var cyclesCompleted = _state.pomodoroCyclesCompleted;

    if (rest.type == SegmentType.longRest) {
      cyclesCompleted += 1;
      focusCount = 0;
    }

    if (cyclesCompleted >= _state.pomodoroCyclesTarget) {
      _emit(
        _state.copyWith(
          phase: EnginePhase.sessionComplete,
          currentSegmentIndex: restIndex,
          pomodoroFocusCount: focusCount,
          pomodoroCyclesCompleted: cyclesCompleted,
          frozenRemainingSec: 0,
        ),
      );
      return;
    }

    final focusIndex = restIndex + 1;
    if (focusIndex >= _state.segments.length ||
        _state.segments[focusIndex].type != SegmentType.focus) {
      throw TimerTransitionError('No next focus after skipped rest');
    }

    _emit(
      _state.copyWith(
        phase: EnginePhase.running,
        currentSegmentIndex: focusIndex,
        pomodoroFocusCount: focusCount,
        pomodoroCyclesCompleted: cyclesCompleted,
        segmentStartedAtUtc: nowUtc,
        segmentPausedSec: 0,
        clearPauseStartedAt: true,
        clearFrozenRemaining: true,
      ),
    );
  }

  void completeFlexible(DateTime nowUtc) {
    _requirePhase(EnginePhase.running, 'completeFlexible');
    if (!_state.isFlexible) {
      throw TimerTransitionError('completeFlexible requires flexible mode');
    }
    _emit(
      _state.copyWith(
        phase: EnginePhase.sessionComplete,
        frozenRemainingSec: _state.elapsedActiveSecAt(nowUtc.toUtc()),
      ),
    );
  }

  /// User tap **Lanjutkan** from session_complete (BR-TIMER-009).
  void continuePomodoro(DateTime nowUtc) {
    _requirePhase(EnginePhase.sessionComplete, 'continuePomodoro');
    if (!_state.isPomodoro || _state.config == null) {
      throw TimerTransitionError('continuePomodoro requires pomodoro session');
    }

    final config = _state.config!;
    final startOrder = _state.segments.isEmpty
        ? 0
        : _state.segments.last.orderIndex + 1;
    final extension = _planner.buildExtensionBlock(
      config,
      startOrderIndex: startOrder,
    );

    final newTarget = _state.pomodoroCyclesTarget + (config.totalCycles ?? 0);
    final allSegments = [..._state.segments, ...extension];
    final nextIndex = _state.currentSegmentIndex + 1;

    if (nextIndex >= allSegments.length) {
      throw TimerTransitionError('No extension segments generated');
    }

    _emit(
      _state.copyWith(
        phase: EnginePhase.running,
        segments: List.unmodifiable(allSegments),
        currentSegmentIndex: nextIndex,
        pomodoroCyclesTarget: newTarget,
        segmentStartedAtUtc: nowUtc.toUtc(),
        segmentPausedSec: 0,
        clearPauseStartedAt: true,
        clearFrozenRemaining: true,
      ),
    );
  }

  /// User tap **Selesai** / dismiss summary → terminal completed (application).
  void dismissSessionComplete() {
    _requirePhase(EnginePhase.sessionComplete, 'dismissSessionComplete');
    _resetToIdle(SessionOutcome.completed);
  }

  /// User stop confirmed → terminal abandoned (application).
  void confirmStop() {
    if (_state.phase != EnginePhase.running &&
        _state.phase != EnginePhase.paused &&
        _state.phase != EnginePhase.segmentComplete) {
      throw TimerTransitionError(
        'confirmStop requires running, paused, or segmentComplete',
      );
    }
    _resetToIdle(SessionOutcome.abandoned);
  }

  /// Focus violation from running only (BR-FOCUS-003, BR-FOCUS-007).
  void reportFocusViolation() {
    _requirePhase(EnginePhase.running, 'reportFocusViolation');
    _resetToIdle(SessionOutcome.failed);
  }

  void resetAfterTerminalHandled() {
    if (_state.phase != EnginePhase.idle) {
      throw TimerTransitionError('resetAfterTerminalHandled requires idle');
    }
    _emit(_state.copyWith(lastOutcome: SessionOutcome.none));
  }

  /// Restores persisted engine phase after force-quit (BR-TIMER-024).
  ///
  /// Coordinator MUST supply wall-clock anchors (`segmentStartedAtUtc`,
  /// `pauseStartedAtUtc`, `frozenRemainingSec`) reconstructed from DB +
  /// [ActiveTimerState].
  void restoreFromPersisted(TimerEngineState state, DateTime nowUtc) {
    _requirePhase(EnginePhase.idle, 'restoreFromPersisted');
    if (state.phase == EnginePhase.idle) {
      throw TimerTransitionError('Cannot restore idle engine phase');
    }
    _emit(state);
    tick(nowUtc.toUtc());
  }

  void _completeCurrentSegment(DateTime nowUtc, {required bool skipped}) {
    final segment = _state.currentSegment;
    if (segment == null) {
      throw TimerTransitionError('No active segment to complete');
    }

    var focusCount = _state.pomodoroFocusCount;
    var cyclesCompleted = _state.pomodoroCyclesCompleted;

    if (segment.type == SegmentType.focus) {
      focusCount += 1;
    }

    if (segment.type == SegmentType.longRest) {
      cyclesCompleted += 1;
      focusCount = 0;
      _advanceAfterRestCompletion(
        nowUtc,
        skipped: skipped,
        focusCount: focusCount,
        cyclesCompleted: cyclesCompleted,
      );
      return;
    }

    if (segment.isRest) {
      _advanceAfterRestCompletion(
        nowUtc,
        skipped: skipped,
        focusCount: focusCount,
        cyclesCompleted: cyclesCompleted,
      );
      return;
    }

    // Focus segment completed → next is rest or end-of-cycle long_rest.
    _advanceAfterFocusCompletion(
      nowUtc,
      focusCount: focusCount,
      cyclesCompleted: cyclesCompleted,
    );
  }

  void _advanceAfterFocusCompletion(
    DateTime nowUtc, {
    required int focusCount,
    required int cyclesCompleted,
  }) {
    final config = _state.config!;
    final n = config.sessionsBeforeLongBreak!;
    final nextIndex = _state.currentSegmentIndex + 1;

    if (nextIndex >= _state.segments.length) {
      throw TimerTransitionError('Segment index out of bounds after focus');
    }

    final nextSegment = _state.segments[nextIndex];
    final autoStart = _shouldAutoStartAfterFocus(nextSegment.type);

    if (autoStart) {
      _emit(
        _state.copyWith(
          phase: EnginePhase.running,
          currentSegmentIndex: nextIndex,
          pomodoroFocusCount: focusCount,
          pomodoroCyclesCompleted: cyclesCompleted,
          segmentStartedAtUtc: nowUtc,
          segmentPausedSec: 0,
          clearPauseStartedAt: true,
          clearFrozenRemaining: true,
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        phase: EnginePhase.segmentComplete,
        pomodoroFocusCount: focusCount,
        pomodoroCyclesCompleted: cyclesCompleted,
        frozenRemainingSec: 0,
      ),
    );

    // Suppress unused warning — n is validated by planner.
    assert(focusCount <= n);
  }

  void _advanceAfterRestCompletion(
    DateTime nowUtc, {
    required bool skipped,
    required int focusCount,
    required int cyclesCompleted,
  }) {
    if (cyclesCompleted >= _state.pomodoroCyclesTarget) {
      _emit(
        _state.copyWith(
          phase: EnginePhase.sessionComplete,
          pomodoroFocusCount: focusCount,
          pomodoroCyclesCompleted: cyclesCompleted,
          frozenRemainingSec: 0,
        ),
      );
      return;
    }

    final nextIndex = _state.currentSegmentIndex + 1;
    if (nextIndex >= _state.segments.length) {
      throw TimerTransitionError('No next segment after rest');
    }

    final nextSegment = _state.segments[nextIndex];
    final autoStart = _shouldAutoStartAfterRest(nextSegment.type);

    if (autoStart) {
      _emit(
        _state.copyWith(
          phase: EnginePhase.running,
          currentSegmentIndex: nextIndex,
          pomodoroFocusCount: focusCount,
          pomodoroCyclesCompleted: cyclesCompleted,
          segmentStartedAtUtc: nowUtc,
          segmentPausedSec: 0,
          clearPauseStartedAt: true,
          clearFrozenRemaining: true,
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        phase: EnginePhase.segmentComplete,
        pomodoroFocusCount: focusCount,
        pomodoroCyclesCompleted: cyclesCompleted,
        frozenRemainingSec: 0,
      ),
    );
  }

  void _startNextSegment(DateTime nowUtc, {required bool autoStarted}) {
    final nextIndex = _state.currentSegmentIndex + 1;
    if (nextIndex >= _state.segments.length) {
      throw TimerTransitionError('No next segment to start');
    }

    _emit(
      _state.copyWith(
        phase: EnginePhase.running,
        currentSegmentIndex: nextIndex,
        segmentStartedAtUtc: nowUtc,
        segmentPausedSec: 0,
        clearPauseStartedAt: true,
        clearFrozenRemaining: true,
      ),
    );
  }

  bool _shouldAutoStartAfterFocus(SegmentType nextType) {
    final config = _state.config;
    if (config == null) {
      return false;
    }
    return config.autoStartBreak &&
        (nextType == SegmentType.shortRest || nextType == SegmentType.longRest);
  }

  bool _shouldAutoStartAfterRest(SegmentType nextType) {
    final config = _state.config;
    if (config == null) {
      return false;
    }
    return config.autoStartFocus && nextType == SegmentType.focus;
  }

  void _resetToIdle(SessionOutcome outcome) {
    _emit(TimerEngineState(phase: EnginePhase.idle, lastOutcome: outcome));
  }

  void _requirePhase(EnginePhase expected, String action) {
    if (_state.phase != expected) {
      throw TimerTransitionError(
        '$action requires phase $expected but was ${_state.phase}',
      );
    }
  }

  void _emit(TimerEngineState next) {
    _state = next;
    if (!_stateController.isClosed) {
      _stateController.add(next);
    }
  }
}

/// Fires a reminder tick; returns true when interval elapsed (BR-TIMER-011).
bool shouldFireFlexibleReminder({
  required ConfigSnapshot config,
  required int flexibleReminderActiveSec,
}) {
  if (config.reminderEnabled != true) {
    return false;
  }
  final intervalMin = config.reminderIntervalMin;
  if (intervalMin == null || intervalMin <= 0) {
    return false;
  }
  final intervalSec = intervalMin * 60;
  return flexibleReminderActiveSec >= intervalSec;
}

import 'dart:async';

import 'package:pomodoro_app/application/timer/config_snapshot_factory.dart';
import 'package:pomodoro_app/application/timer/lifecycle_result.dart';
import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/application/timer/segment_end_cycle_progress.dart';
import 'package:pomodoro_app/application/timer/persist_reason.dart';
import 'package:pomodoro_app/application/timer/session_lifecycle.dart';
import 'package:pomodoro_app/application/timer/side_effect_context.dart';
import 'package:pomodoro_app/application/timer/timer_side_effect_hub.dart';
import 'package:pomodoro_app/application/timer/timer_state_builder.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/domain/timer/early_stop_grace.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/domain/timer/segment_planner.dart';
import 'package:pomodoro_app/domain/timer/timer_engine.dart';
import 'package:pomodoro_app/domain/timer/timer_transition_error.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter.dart';
import 'package:pomodoro_app/platform/clock/clock_adapter.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:uuid/uuid.dart';

/// Thin facade: view-state, recovery prompts, and Lifecycle → Hub order.
class TimerCoordinator {
  TimerCoordinator({
    required SessionRepository sessionRepository,
    required TagRepository tagRepository,
    required ActiveTimerStateRepository activeTimerStateRepository,
    required SettingsRepository settingsRepository,
    required NotificationAdapter notificationAdapter,
    required AlertSoundAdapter alertSoundAdapter,
    required HapticAdapter hapticAdapter,
    required FlashAdapter flashAdapter,
    required FocusAdapter focusAdapter,
    required AODAdapter aodAdapter,
    required ClockAdapter clock,
    TimerEngine? engine,
    SegmentPlanner? planner,
    ConfigSnapshotFactory? configSnapshotFactory,
    TimerStateBuilder? stateBuilder,
    Uuid? uuid,
    SessionLifecycle? sessionLifecycle,
    TimerSideEffectHub? sideEffectHub,
  }) : _lifecycle =
           sessionLifecycle ??
           SessionLifecycle(
             sessionRepository: sessionRepository,
             tagRepository: tagRepository,
             activeTimerStateRepository: activeTimerStateRepository,
             clock: clock,
             engine: engine,
             planner: planner,
             configSnapshotFactory: configSnapshotFactory,
             stateBuilder: stateBuilder,
             uuid: uuid,
           ),
       _settingsRepository = settingsRepository,
       _focusAdapter = focusAdapter,
       _clock = clock,
       _hub =
           sideEffectHub ??
           TimerSideEffectHub(
             settingsRepository: settingsRepository,
             notificationAdapter: notificationAdapter,
             alertSoundAdapter: alertSoundAdapter,
             hapticAdapter: hapticAdapter,
             flashAdapter: flashAdapter,
             focusAdapter: focusAdapter,
             aodAdapter: aodAdapter,
           ) {
    _focusSubscription = _focusAdapter.watchViolations().listen((_) {
      unawaited(_handleFocusViolation());
    });
    _emitViewState();
  }

  final SessionLifecycle _lifecycle;
  final SettingsRepository _settingsRepository;
  final FocusAdapter _focusAdapter;
  final ClockAdapter _clock;
  final TimerSideEffectHub _hub;

  final _viewStateController = StreamController<TimerViewState>.broadcast();
  late final StreamSubscription<FocusViolation> _focusSubscription;

  ActiveTimerState? _pendingRecovery;
  bool _showRecoveryPrompt = false;

  /// App is interactive — prefer in-app tone over OS tray for segment end.
  bool _isInForeground = true;

  /// Set when user opens the app from a segment-end push; consumed once.
  bool _suppressNextSegmentAlert = false;

  Stream<TimerViewState> get viewState => _viewStateController.stream;
  TimerViewState get currentViewState => _buildViewState();
  TimerEngine get engine => _lifecycle.engine;

  bool get hasActiveSession => _lifecycle.hasActiveSession;

  /// Call when the user opens the app via a segment-end notification tap
  /// so the subsequent foreground [tick] does not replay the alert in-app.
  void suppressNextSegmentAlert() {
    _suppressNextSegmentAlert = true;
  }

  void setRecoveryOffer(ActiveTimerState state) {
    _pendingRecovery = state;
    _showRecoveryPrompt = true;
    _emitViewState();
  }

  void clearRecoveryPrompt() {
    _showRecoveryPrompt = false;
    _pendingRecovery = null;
    _emitViewState();
  }

  Future<AppResult<void>> startPomodoro(String tagId) => _runAsync(() async {
    final result = await _lifecycle.startPomodoro(tagId);
    await _syncSideEffects(result);
    _emitViewState();
  });

  Future<AppResult<void>> startFlexible(String tagId) => _runAsync(() async {
    final result = await _lifecycle.startFlexible(tagId);
    await _syncSideEffects(result);
    _emitViewState();
  });

  Future<AppResult<void>> pause() => _runAsync(() async {
    final result = await _lifecycle.pause();
    await _afterTransition(result);
  });

  Future<AppResult<void>> resume() => _runAsync(() async {
    final result = await _lifecycle.resume();
    await _afterTransition(result);
  });

  Future<AppResult<void>> stop({required bool confirmed}) async {
    if (!confirmed) {
      return err(
        const ValidationError(
          code: 'TIMER_STOP_NOT_CONFIRMED',
          message: 'Konfirmasi diperlukan untuk menghentikan sesi.',
        ),
      );
    }
    return _runAsync(() async {
      final result = await _lifecycle.stop();
      if (result.sessionId == null) {
        await _hub.onIdle();
        _emitViewState();
        return;
      }
      // Stop is always a foreground action — in-app tone only (OS notification
      // would also play sound and cause a double alert).
      final settings = await _settingsRepository.get();
      final copy = NotificationStrings.forLanguage(settings.language);
      await _hub.onFocusFailed(
        _sideEffectContext(result: result),
        title: copy.sessionStoppedTitle,
        body: copy.sessionStoppedBody,
        osNotification: false,
      );
      _emitViewState();
    });
  }

  Future<AppResult<void>> skipBreak() => _runAsync(() async {
    final result = await _lifecycle.skipBreak();
    await _afterTransition(result);
  });

  Future<AppResult<void>> advanceSegment() => _runAsync(() async {
    final result = await _lifecycle.advanceSegment();
    await _afterTransition(result);
  });

  Future<AppResult<void>> completePomodoro() => dismissSessionComplete();

  Future<AppResult<void>> continuePomodoro() => _runAsync(() async {
    final result = await _lifecycle.continuePomodoro();
    await _afterTransition(result);
  });

  Future<AppResult<void>> completeFlexible() => _runAsync(() async {
    final result = await _lifecycle.completeFlexible();
    await _afterTransition(result);
  });

  Future<AppResult<void>> dismissSessionComplete() => _runAsync(() async {
    final result = await _lifecycle.dismissSessionComplete();
    if (result.before.phase != EnginePhase.idle) {
      await _hub.onIdle();
    }
    _emitViewState();
  });

  /// After auto-saved session complete: start a new session with the same tag.
  Future<AppResult<void>> restartSameTag() => _runAsync(() async {
    if (_lifecycle.sessionId != null) {
      await _hub.onIdle();
    }
    final result = await _lifecycle.restartSameTag();
    await _syncSideEffects(result);
    _emitViewState();
  });

  Future<AppResult<void>> resumeFromPersisted() => _runAsync(() async {
    final result = await _lifecycle.resumeFromPersisted(
      pending: _pendingRecovery,
    );
    clearRecoveryPrompt();
    await _syncSideEffects(result);
  });

  Future<AppResult<void>> declineRecovery() => _runAsync(() async {
    await _lifecycle.declineRecovery(pending: _pendingRecovery);
    clearRecoveryPrompt();
    await _hub.onIdle();
  });

  /// Foreground tick — persist only on phase/index change (BR-TIMER-025).
  Future<void> tick() async {
    final result = await _lifecycle.tick();
    _emitViewState();

    if (result.before.phase != result.after.phase ||
        result.before.currentSegmentIndex != result.after.currentSegmentIndex) {
      await _afterTransition(result);
    } else {
      _maybeFireFlexibleReminder(result.after);
    }
  }

  Future<void> persistActiveState(PersistReason reason) =>
      _lifecycle.persistActiveState(reason);

  Future<void> onLifecycleBackground() async {
    _isInForeground = false;
    await _lifecycle.persistActiveState(PersistReason.lifecycleFlush);
    // Re-schedule before Dart suspends — OS must deliver segment-end on iOS
    // while the user is in another app (BR-TIMER-020).
    await _hub.onLifecycleBackground(
      _currentSideEffectContext(after: _lifecycle.currentState),
    );
  }

  Future<void> onLifecycleForeground() async {
    _isInForeground = true;
    await _hub.onLifecycleForeground(_currentSideEffectContext());
    // Notification-tap callbacks often land in the same resume turn; yield so
    // [suppressNextSegmentAlert] can run before we replay the segment alert.
    // ponytail: 1-frame yield; if OEM delivers tap after this, deep-link path
    // still sets suppress for a later tick (alert already cancelled).
    await Future<void>.delayed(Duration.zero);
    await tick();
  }

  void dispose() {
    _focusSubscription.cancel();
    // AlertSoundAdapter lifecycle is owned by Riverpod provider — do not dispose here.
    _viewStateController.close();
    _lifecycle.dispose();
  }

  Future<void> _afterTransition(LifecycleResult result) async {
    final enteredSessionComplete =
        result.after.phase == EnginePhase.sessionComplete &&
        result.before.phase != EnginePhase.sessionComplete &&
        result.sessionId != null;

    await _runSegmentSideEffects(result);
    if (enteredSessionComplete && !result.after.isPomodoro) {
      // Flexible: auto-finalize completed while keeping tag UI context.
      // Pomodoro stays soft-complete until Done / continue (ticket 02).
      await _lifecycle.persistCompletedKeepUi();
    }

    _emitViewState();
    _maybeFireFlexibleReminder(result.after);
  }

  Future<void> _runSegmentSideEffects(LifecycleResult result) async {
    final consumed = await _hub.onSegmentTransition(
      _sideEffectContext(result: result),
    );
    if (consumed) {
      _suppressNextSegmentAlert = false;
    }
  }

  Future<void> _syncSideEffects(LifecycleResult result) async {
    await _hub.onSegmentTransition(_sideEffectContext(result: result));
  }

  SideEffectContext _sideEffectContext({required LifecycleResult result}) {
    return SideEffectContext(
      sessionId: result.sessionId,
      before: result.before,
      after: result.after,
      isForeground: _isInForeground,
      suppressNextSegmentAlert: _suppressNextSegmentAlert,
      nowUtc: _clock.nowUtc(),
    );
  }

  SideEffectContext _currentSideEffectContext({
    TimerEngineState? before,
    TimerEngineState? after,
  }) {
    return SideEffectContext(
      sessionId: _lifecycle.sessionId,
      before: before,
      after: after ?? _lifecycle.currentState,
      isForeground: _isInForeground,
      suppressNextSegmentAlert: _suppressNextSegmentAlert,
      nowUtc: _clock.nowUtc(),
    );
  }

  Future<void> _handleFocusViolation() async {
    if (_lifecycle.currentState.phase != EnginePhase.running) {
      return;
    }
    final settings = await _settingsRepository.get();
    final effective = _effectiveFocusMode(settings);
    if (effective == FocusMode.loose) {
      return;
    }
    try {
      final result = await _lifecycle.failForFocusViolation();
      await _hub.onFocusFailed(_sideEffectContext(result: result));
      _emitViewState();
    } on TimerTransitionError {
      // Ignore if phase changed concurrently.
    }
  }

  FocusMode _effectiveFocusMode(AppSettings settings) {
    final caps = _focusAdapter.capabilities();
    return switch (settings.focusMode) {
      FocusMode.strict =>
        caps.strictAvailable ? FocusMode.strict : FocusMode.loose,
      FocusMode.whitelist =>
        caps.whitelistAvailable ? FocusMode.whitelist : FocusMode.loose,
      FocusMode.loose => FocusMode.loose,
    };
  }

  void _maybeFireFlexibleReminder(TimerEngineState state) {
    if (!state.isFlexible ||
        state.phase != EnginePhase.running ||
        _lifecycle.sessionId == null) {
      return;
    }
    final config = state.config;
    if (config == null) {
      return;
    }
    if (shouldFireFlexibleReminder(
      config: config,
      flexibleReminderActiveSec: state.flexibleReminderActiveSec,
    )) {
      _lifecycle.acknowledgeFlexibleReminder();
      unawaited(
        _hub.maybeFlexibleReminder(_currentSideEffectContext(after: state)),
      );
    }
  }

  void _emitViewState() {
    if (_viewStateController.isClosed) {
      return;
    }
    _viewStateController.add(_buildViewState());
  }

  TimerViewState _buildViewState() {
    final state = _lifecycle.currentState;
    final now = _clock.nowUtc();

    if (state.phase == EnginePhase.idle) {
      return TimerViewState.idle(showRecoveryPrompt: _showRecoveryPrompt);
    }

    final isCountdown = state.isPomodoro;
    final displaySec = isCountdown
        ? state.remainingSecAt(now)
        : state.elapsedActiveSecAt(now);
    final activeSec = _lifecycle.totalActiveSec(state);
    final graceRemaining =
        (state.phase == EnginePhase.running ||
            state.phase == EnginePhase.paused)
        ? earlyStopGraceRemainingSec(activeSec)
        : 0;

    final endSummary = _segmentEndSummary(state);

    return TimerViewState(
      phase: state.phase,
      mode: state.mode,
      tagId: _lifecycle.tagId,
      tagName: _lifecycle.tagName,
      sessionId: _lifecycle.sessionId,
      displaySec: displaySec,
      isCountdown: isCountdown,
      currentSegmentType: state.currentSegment?.type,
      completedFocusCount: state.pomodoroFocusCount,
      totalFocusInCycle: state.config?.sessionsBeforeLongBreak ?? 0,
      completedCycleCount: state.isPomodoro
          ? state.pomodoroCyclesCompleted
          : null,
      totalCycleTarget: state.isPomodoro ? state.pomodoroCyclesTarget : null,
      showRecoveryPrompt: _showRecoveryPrompt,
      currentPlannedSec: state.currentSegment?.plannedSec,
      earlyStopGraceRemainingSec: graceRemaining,
      segmentEndFinishedType: endSummary?.finished,
      segmentEndNextType: endSummary?.next,
      segmentEndCompletedCount: endSummary?.completedCount,
      segmentEndTotalCount: endSummary?.totalCount,
    );
  }

  ({
    SegmentType finished,
    SegmentType? next,
    int completedCount,
    int totalCount,
  })?
  _segmentEndSummary(TimerEngineState state) {
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
      finished: finished,
      next: nextType,
      completedCount: progress.n,
      totalCount: progress.total,
    );
  }

  Future<AppResult<void>> _runAsync(Future<void> Function() action) async {
    try {
      await action();
      return ok();
    } on TimerTransitionError catch (e) {
      return err(ValidationError(code: e.code, message: e.message));
    } on AppError catch (e) {
      return err(e);
    } catch (e) {
      return err(
        StorageError(
          code: 'STORAGE_WRITE_FAILED',
          message: 'Operasi timer gagal.',
          cause: e,
        ),
      );
    }
  }
}

import 'dart:async';

import 'package:pomodoro_app/application/timer/lifecycle_result.dart';
import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/application/timer/persist_reason.dart';
import 'package:pomodoro_app/application/timer/timer_flow_projection.dart';
import 'package:pomodoro_app/application/timer/timer_flow_state.dart';
import 'package:pomodoro_app/application/timer/session_lifecycle.dart';
import 'package:pomodoro_app/application/timer/side_effect_context.dart';
import 'package:pomodoro_app/application/timer/timer_side_effect_hub.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/domain/timer/timer_engine.dart';
import 'package:pomodoro_app/domain/timer/timer_transition_error.dart';
import 'package:pomodoro_app/platform/clock/clock_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';

/// Thin facade: view-state, recovery prompts, and Lifecycle → Hub order.
///
/// Constructed with injected [SessionLifecycle] and [TimerSideEffectHub] —
/// production wiring owns those modules; this facade does not.
class TimerCoordinator {
  TimerCoordinator({
    required SessionLifecycle sessionLifecycle,
    required TimerSideEffectHub sideEffectHub,
    required this._settingsRepository,
    required this._focusAdapter,
    required this._clock,
  }) : _lifecycle = sessionLifecycle,
       _hub = sideEffectHub {
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
  final _flowStateController = StreamController<TimerFlowState>.broadcast();
  late final StreamSubscription<FocusViolation> _focusSubscription;

  ActiveTimerState? _pendingRecovery;
  bool _showRecoveryPrompt = false;

  String? _preStartTagId;
  int? _preStartCountdown;
  Timer? _preStartTimer;
  bool _isLaunchingAfterPreStart = false;

  /// App is interactive — prefer in-app tone over OS tray for segment end.
  bool _isInForeground = true;

  /// Set when user opens the app from a segment-end push; consumed once.
  bool _suppressNextSegmentAlert = false;

  Stream<TimerViewState> get viewState => _viewStateController.stream;
  TimerViewState get currentViewState => _buildViewState();

  Stream<TimerFlowState> get flowState => _flowStateController.stream;
  TimerFlowState get currentFlowState => _buildFlowState();

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

  /// Pomodoro UC-01: 3-2-1 countdown then [startPomodoro].
  AppResult<void> beginPomodoroStart(String tagId) {
    if (_lifecycle.currentState.phase != EnginePhase.idle) {
      return err(
        const ValidationError(
          code: 'TIMER_INVALID_TRANSITION',
          message: 'Aksi tidak dapat dilakukan pada state timer saat ini.',
        ),
      );
    }
    if (hasActiveSession) {
      return err(
        const ConflictError(
          code: 'TIMER_ACTIVE_SESSION',
          message: 'Sesi timer sedang berjalan. Selesaikan atau hentikan dulu.',
        ),
      );
    }
    if (_preStartCountdown != null) {
      return err(
        const ValidationError(
          code: 'TIMER_PRESTART_ACTIVE',
          message: 'Hitungan mundur sudah berjalan.',
        ),
      );
    }
    _preStartTagId = tagId;
    _preStartCountdown = 3;
    _isLaunchingAfterPreStart = false;
    _startPreStartTimer();
    _emitViewState();
    return ok();
  }

  void cancelPreStart() {
    if (_preStartCountdown == null) {
      return;
    }
    _clearPreStart();
    _emitViewState();
  }

  Future<AppResult<void>> skipPreStartAndLaunch() async {
    if (_preStartTagId == null || _preStartCountdown == null) {
      return err(
        const ValidationError(
          code: 'TIMER_INVALID_TRANSITION',
          message: 'Tidak ada hitungan mundur aktif.',
        ),
      );
    }
    return _runAsync(() async {
    _preStartTimer?.cancel();
    _preStartTimer = null;
    _preStartCountdown = 0;
    _emitViewState();
    await _launchAfterPreStart();
    });
  }

  Future<AppResult<void>> startPomodoro(String tagId) => _runAsync(() async {
    _clearPreStart();
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
    _preStartTimer?.cancel();
    _preStartTimer = null;
    _focusSubscription.cancel();
    // AlertSoundAdapter + SessionLifecycle lifecycles are owned by Riverpod
    // providers — do not dispose them here.
    _viewStateController.close();
    _flowStateController.close();
  }

  void _startPreStartTimer() {
    _preStartTimer?.cancel();
    _preStartTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _onPreStartTick();
    });
  }

  void _onPreStartTick() {
    final current = _preStartCountdown;
    if (current == null || _isLaunchingAfterPreStart) {
      return;
    }
    if (current <= 1) {
      _preStartCountdown = 0;
      _emitViewState();
      unawaited(_launchAfterPreStart());
      return;
    }
    _preStartCountdown = current - 1;
    _emitViewState();
  }

  Future<void> _launchAfterPreStart() async {
    if (_isLaunchingAfterPreStart) {
      return;
    }
    _isLaunchingAfterPreStart = true;
    _preStartTimer?.cancel();
    _preStartTimer = null;
    final tagId = _preStartTagId;
    if (tagId == null) {
      _clearPreStart();
      _isLaunchingAfterPreStart = false;
      _emitViewState();
      return;
    }
    final result = await startPomodoro(tagId);
    if (result.isErr) {
      _isLaunchingAfterPreStart = false;
    }
  }

  void _clearPreStart() {
    _preStartTimer?.cancel();
    _preStartTimer = null;
    _preStartTagId = null;
    _preStartCountdown = null;
    _isLaunchingAfterPreStart = false;
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
    final projection = _projectionContext();
    _viewStateController.add(projectTimerViewState(projection));
    _flowStateController.add(projectTimerFlowState(projection));
  }

  TimerViewState _buildViewState() =>
      projectTimerViewState(_projectionContext());

  TimerFlowState _buildFlowState() => projectTimerFlowState(_projectionContext());

  TimerProjectionContext _projectionContext() {
    final state = _lifecycle.currentState;
    return TimerProjectionContext(
      engineState: state,
      nowUtc: _clock.nowUtc(),
      totalActiveSec: _lifecycle.totalActiveSec(state),
      lifecycleTagId: _lifecycle.tagId,
      lifecycleTagName: _lifecycle.tagName,
      lifecycleSessionId: _lifecycle.sessionId,
      hasActiveSession: hasActiveSession,
      showRecoveryPrompt: _showRecoveryPrompt,
      pendingRecovery: _pendingRecovery,
      preStartCountdown: _preStartCountdown,
      preStartTagId: _preStartTagId,
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

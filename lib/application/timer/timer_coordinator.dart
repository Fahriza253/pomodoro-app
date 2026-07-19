import 'dart:async';

import 'package:pomodoro_app/application/timer/config_snapshot_factory.dart';
import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/application/timer/persist_reason.dart';
import 'package:pomodoro_app/application/timer/segment_end_copy.dart';
import 'package:pomodoro_app/application/timer/timer_state_builder.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/session_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/domain/timer/segment_planner.dart';
import 'package:pomodoro_app/domain/timer/early_stop_grace.dart';
import 'package:pomodoro_app/domain/timer/timer_engine.dart';
import 'package:pomodoro_app/domain/timer/timer_transition_error.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter.dart';
import 'package:pomodoro_app/platform/clock/clock_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_deep_link.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';
import 'package:uuid/uuid.dart';

/// Orchestrates timer engine, persistence, and platform side effects (UC-01/02/04).
class TimerCoordinator {
  TimerCoordinator({
    required this._sessionRepository,
    required this._tagRepository,
    required this._activeTimerStateRepository,
    required this._settingsRepository,
    required this._notificationAdapter,
    required this._alertSoundAdapter,
    required this._focusAdapter,
    required this._aodAdapter,
    required this._clock,
    TimerEngine? engine,
    SegmentPlanner? planner,
    ConfigSnapshotFactory? configSnapshotFactory,
    TimerStateBuilder? stateBuilder,
    Uuid? uuid,
  }) : _engine = engine ?? TimerEngine(planner: planner),
       _planner = planner ?? const SegmentPlanner(),
       _configSnapshotFactory =
           configSnapshotFactory ?? const ConfigSnapshotFactory(),
       _stateBuilder = stateBuilder ?? const TimerStateBuilder(),
       _uuid = uuid ?? const Uuid() {
    _focusSubscription = _focusAdapter.watchViolations().listen((_) {
      unawaited(_handleFocusViolation());
    });
    _emitViewState();
  }

  final SessionRepository _sessionRepository;
  final TagRepository _tagRepository;
  final ActiveTimerStateRepository _activeTimerStateRepository;
  final SettingsRepository _settingsRepository;
  final NotificationAdapter _notificationAdapter;
  final AlertSoundAdapter _alertSoundAdapter;
  final FocusAdapter _focusAdapter;
  final AODAdapter _aodAdapter;
  final ClockAdapter _clock;
  final TimerEngine _engine;
  final SegmentPlanner _planner;
  final ConfigSnapshotFactory _configSnapshotFactory;
  final TimerStateBuilder _stateBuilder;
  final Uuid _uuid;

  final _viewStateController = StreamController<TimerViewState>.broadcast();
  late final StreamSubscription<FocusViolation> _focusSubscription;

  String? _sessionId;
  String? _tagId;
  String? _tagName;
  List<String> _segmentIds = const [];
  ActiveTimerState? _pendingRecovery;
  bool _showRecoveryPrompt = false;

  /// App is interactive — prefer in-app tone over OS tray for segment end.
  bool _isInForeground = true;

  /// Set when user opens the app from a segment-end push; consumed once.
  bool _suppressNextSegmentAlert = false;

  /// Notification id for scheduled wall-clock segment-end.
  int get _scheduledSegmentEndNotificationId => _sessionId!.hashCode;

  /// Notification id for immediate segment-end tray alerts (legacy / rare).
  int get _immediateSegmentEndNotificationId =>
      _sessionId!.hashCode ^ 0x454E44; // 'END'

  Stream<TimerViewState> get viewState => _viewStateController.stream;
  TimerViewState get currentViewState => _buildViewState();
  TimerEngine get engine => _engine;

  bool get hasActiveSession => _sessionId != null;

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
    await _guardNoActiveSession();
    final tagWithConfigs = await _tagRepository.getWithConfigs(tagId);
    final snapshot = _configSnapshotFactory.fromTagModeConfig(
      tagWithConfigs.pomodoro,
    );
    final segments = _planner.buildBlockPlan(snapshot);
    final plan = SessionPlan(
      config: snapshot,
      segments: segments,
      cyclesTarget: snapshot.totalCycles!,
    );
    await _startSession(
      tagId: tagId,
      tagName: tagWithConfigs.tag.name,
      mode: TimerMode.pomodoro,
      snapshot: snapshot,
      segments: segments,
      cyclesTarget: snapshot.totalCycles,
      startEngine: (now) => _engine.startPomodoro(plan, now),
    );
  });

  Future<AppResult<void>> startFlexible(String tagId) => _runAsync(() async {
    await _guardNoActiveSession();
    final tagWithConfigs = await _tagRepository.getWithConfigs(tagId);
    final snapshot = _configSnapshotFactory.fromTagModeConfig(
      tagWithConfigs.flexible,
    );
    final segment = _planner.buildFlexibleSegment(snapshot);
    await _startSession(
      tagId: tagId,
      tagName: tagWithConfigs.tag.name,
      mode: TimerMode.flexible,
      snapshot: snapshot,
      segments: [segment],
      cyclesTarget: null,
      startEngine: (now) => _engine.startFlexible(snapshot, now),
    );
  });

  Future<AppResult<void>> pause() => _runAsync(() async {
    final before = _engine.currentState;
    _engine.pause(_clock.nowUtc());
    await _onEngineTransition(before, PersistReason.pause);
  });

  Future<AppResult<void>> resume() => _runAsync(() async {
    final before = _engine.currentState;
    _engine.resume(_clock.nowUtc());
    _engine.tick(_clock.nowUtc());
    await _onEngineTransition(before, PersistReason.resume);
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
      await _guardActiveSession();
      final activeSec = _computeTotalActiveSec(_engine.currentState);
      if (isWithinEarlyStopGrace(activeSec)) {
        // BR-TIMER-026: discard — no abandoned row, no failure tone.
        await _discardActiveSession();
        _engine.confirmStop();
        _emitViewState();
        return;
      }
      // Stop is always a foreground action — in-app tone only (OS notification
      // would also play sound and cause a double alert).
      final copy = await _notificationCopy();
      await _playFailureAlert(
        title: copy.sessionStoppedTitle,
        body: copy.sessionStoppedBody,
        osNotification: false,
      );
      await _finalizeActiveSession(SessionStatus.abandoned);
      _engine.confirmStop();
    });
  }

  Future<AppResult<void>> skipBreak() => _runAsync(() async {
    final before = _engine.currentState;
    _engine.skipBreak(_clock.nowUtc());
    await _onEngineTransition(before, PersistReason.segmentTransition);
  });

  Future<AppResult<void>> advanceSegment() => _runAsync(() async {
    final before = _engine.currentState;
    _engine.advanceFromSegmentComplete(_clock.nowUtc());
    await _onEngineTransition(before, PersistReason.segmentTransition);
  });

  Future<AppResult<void>> completePomodoro() => dismissSessionComplete();

  Future<AppResult<void>> continuePomodoro() => _runAsync(() async {
    await _guardActiveSession();
    final before = _engine.currentState;
    _engine.continuePomodoro(_clock.nowUtc());
    final after = _engine.currentState;
    final newSegments = after.segments.skip(before.segments.length).toList();
    final newInputs = newSegments.map((plan) {
      return CreateSegmentInput(
        id: _uuid.v4(),
        type: plan.type,
        orderIndex: plan.orderIndex,
        plannedSec: plan.plannedSec,
      );
    }).toList();
    _segmentIds = [..._segmentIds, ...newInputs.map((s) => s.id)];
    await _sessionRepository.appendSegments(
      _sessionId!,
      newInputs,
      pomodoroCyclesTarget: after.pomodoroCyclesTarget,
    );
    await _markCurrentSegmentStarted();
    await _onEngineTransition(before, PersistReason.segmentTransition);
  });

  Future<AppResult<void>> completeFlexible() => _runAsync(() async {
    await _guardActiveSession();
    final before = _engine.currentState;
    if (!before.isFlexible) {
      throw TimerTransitionError('completeFlexible requires flexible mode');
    }
    if (before.phase == EnginePhase.paused) {
      _engine.resume(_clock.nowUtc());
    }
    _engine.completeFlexible(_clock.nowUtc());
    await _onEngineTransition(before, PersistReason.segmentTransition);
  });

  Future<AppResult<void>> dismissSessionComplete() => _runAsync(() async {
    if (_engine.currentState.phase == EnginePhase.idle) {
      _emitViewState();
      return;
    }
    _requirePhase(EnginePhase.sessionComplete);
    if (_sessionId != null) {
      await _finalizeActiveSession(SessionStatus.completed);
    }
    _engine.dismissSessionComplete();
    _engine.resetAfterTerminalHandled();
    _clearSessionContext();
    await _syncPlatformAdapters();
    _emitViewState();
  });

  /// After auto-saved session complete: start a new session with the same tag.
  Future<AppResult<void>> restartSameTag() => _runAsync(() async {
    final tagId = _tagId;
    final mode = _engine.currentState.mode;
    if (tagId == null || mode == null) {
      throw const ConflictError(
        code: 'TIMER_NO_ACTIVE_SESSION',
        message: 'Tidak ada tag untuk memulai ulang.',
      );
    }
    _requirePhase(EnginePhase.sessionComplete);
    if (_sessionId != null) {
      await _cancelSegmentEndNotifications();
      await _writeTerminalSession(SessionStatus.completed);
      await _activeTimerStateRepository.delete();
      _sessionId = null;
      _segmentIds = const [];
    }
    _engine.dismissSessionComplete();
    _engine.resetAfterTerminalHandled();

    final tagWithConfigs = await _tagRepository.getWithConfigs(tagId);
    if (mode == TimerMode.pomodoro) {
      final snapshot = _configSnapshotFactory.fromTagModeConfig(
        tagWithConfigs.pomodoro,
      );
      final segments = _planner.buildBlockPlan(snapshot);
      final plan = SessionPlan(
        config: snapshot,
        segments: segments,
        cyclesTarget: snapshot.totalCycles!,
      );
      await _startSession(
        tagId: tagId,
        tagName: tagWithConfigs.tag.name,
        mode: TimerMode.pomodoro,
        snapshot: snapshot,
        segments: segments,
        cyclesTarget: snapshot.totalCycles,
        startEngine: (now) => _engine.startPomodoro(plan, now),
      );
    } else {
      final snapshot = _configSnapshotFactory.fromTagModeConfig(
        tagWithConfigs.flexible,
      );
      final segment = _planner.buildFlexibleSegment(snapshot);
      await _startSession(
        tagId: tagId,
        tagName: tagWithConfigs.tag.name,
        mode: TimerMode.flexible,
        snapshot: snapshot,
        segments: [segment],
        cyclesTarget: null,
        startEngine: (now) => _engine.startFlexible(snapshot, now),
      );
    }
  });

  Future<AppResult<void>> resumeFromPersisted() => _runAsync(() async {
    final persisted =
        _pendingRecovery ?? await _activeTimerStateRepository.get();
    if (persisted == null) {
      throw const ConflictError(
        code: 'TIMER_NO_ACTIVE_SESSION',
        message: 'Tidak ada sesi untuk dipulihkan.',
      );
    }
    final session = await _sessionRepository.getById(persisted.sessionId);
    if (session == null || session.status != SessionStatus.active) {
      throw const ConflictError(
        code: 'TIMER_NO_ACTIVE_SESSION',
        message: 'Tidak ada sesi aktif.',
      );
    }
    final dbSegments = await _sessionRepository.getSegmentsBySessionId(
      session.id,
    );
    final tag = await _tagRepository.getById(session.tagId);

    _sessionId = session.id;
    _tagId = session.tagId;
    _tagName = tag?.name;
    _segmentIds = _stateBuilder.segmentIdsFromDb(dbSegments);

    final rebuilt = _stateBuilder.fromPersisted(
      session: session,
      dbSegments: dbSegments,
      persisted: persisted,
    );
    _engine.restoreFromPersisted(rebuilt, _clock.nowUtc());
    clearRecoveryPrompt();
    await persistActiveState(PersistReason.sessionStart);
    await _syncPlatformAdapters();
  });

  Future<AppResult<void>> declineRecovery() => _runAsync(() async {
    final persisted =
        _pendingRecovery ?? await _activeTimerStateRepository.get();
    if (persisted != null) {
      await _sessionRepository.markAbandoned(
        persisted.sessionId,
        _clock.nowUtc(),
      );
      await _activeTimerStateRepository.delete();
    }
    clearRecoveryPrompt();
    _clearSessionContext();
    await _syncPlatformAdapters();
  });

  /// Foreground tick — MUST NOT persist (BR-TIMER-025).
  Future<void> tick() async {
    final before = _engine.currentState;
    _engine.tick(_clock.nowUtc());
    final after = _engine.currentState;
    _emitViewState();

    if (before.phase != after.phase ||
        before.currentSegmentIndex != after.currentSegmentIndex) {
      await _onEngineTransition(before, PersistReason.segmentTransition);
    } else {
      _maybeFireFlexibleReminder(after);
    }
  }

  Future<void> persistActiveState(PersistReason reason) async {
    final state = _engine.currentState;
    if (_sessionId == null || !_shouldPersistPhase(state.phase)) {
      return;
    }
    final nowMs = _clock.nowUtc().millisecondsSinceEpoch;
    await _activeTimerStateRepository.upsert(
      ActiveTimerState(
        sessionId: _sessionId!,
        enginePhase: state.phase,
        currentSegmentId: _currentSegmentId(),
        segmentStartedAtUtcMs:
            state.segmentStartedAtUtc?.millisecondsSinceEpoch ?? nowMs,
        flexibleReminderActiveSec: state.flexibleReminderActiveSec,
        lastPersistedAtUtcMs: nowMs,
        pauseStartedAtUtcMs: state.pauseStartedAtUtc?.millisecondsSinceEpoch,
        frozenRemainingSec: state.phase == EnginePhase.paused
            ? state.frozenRemainingSec
            : null,
      ),
    );
  }

  Future<void> onLifecycleBackground() async {
    _isInForeground = false;
    await persistActiveState(PersistReason.lifecycleFlush);
    // Re-schedule before Dart suspends — OS must deliver segment-end on iOS
    // while the user is in another app (BR-TIMER-020).
    await _scheduleSegmentNotification();
    final sessionId = _sessionId;
    if (sessionId == null) return;
    final copy = await _notificationCopy();
    final content = buildRunningTimerContent(
      state: _engine.currentState,
      sessionId: sessionId,
      nowUtc: _clock.nowUtc(),
      focusingTitle: copy.focusing,
      restingTitle: copy.resting,
    );
    if (content == null) {
      await _notificationAdapter.cancel(kRunningTimerNotificationId);
    } else {
      await _notificationAdapter.showRunningTimer(content);
    }
  }

  Future<void> onLifecycleForeground() async {
    _isInForeground = true;
    await _notificationAdapter.cancel(kRunningTimerNotificationId);
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
    _engine.dispose();
  }

  // --- internals ---

  Future<void> _startSession({
    required String tagId,
    required String tagName,
    required TimerMode mode,
    required ConfigSnapshot snapshot,
    required List<SegmentPlan> segments,
    required int? cyclesTarget,
    required void Function(DateTime now) startEngine,
  }) async {
    final now = _clock.nowUtc();
    final nowMs = now.millisecondsSinceEpoch;
    final sessionId = _uuid.v4();
    final segmentIds = List<String>.generate(
      segments.length,
      (_) => _uuid.v4(),
    );

    final segmentInputs = <CreateSegmentInput>[];
    for (var i = 0; i < segments.length; i++) {
      final plan = segments[i];
      segmentInputs.add(
        CreateSegmentInput(
          id: segmentIds[i],
          type: plan.type,
          orderIndex: plan.orderIndex,
          plannedSec: plan.plannedSec,
          segmentStatus: i == 0 ? SegmentStatus.active : SegmentStatus.pending,
          startedAtUtcMs: i == 0 ? nowMs : null,
        ),
      );
    }

    await _sessionRepository.createSession(
      CreateSessionInput(
        id: sessionId,
        tagId: tagId,
        mode: mode,
        configSnapshot: snapshot,
        startedAtUtcMs: nowMs,
        timelineDate: _localTimelineDate(now),
        segments: segmentInputs,
        pomodoroCyclesTarget: cyclesTarget,
      ),
    );

    _sessionId = sessionId;
    _tagId = tagId;
    _tagName = tagName;
    _segmentIds = segmentIds;

    startEngine(now);

    await persistActiveState(PersistReason.sessionStart);
    await _syncPlatformAdapters();
    _emitViewState();
  }

  Future<void> _onEngineTransition(
    TimerEngineState before,
    PersistReason reason,
  ) async {
    final after = _engine.currentState;
    if (_sessionId != null &&
        (before.currentSegmentIndex != after.currentSegmentIndex ||
            before.phase != after.phase)) {
      await _syncSegmentProgress(before, after);
    }

    final enteredSessionComplete =
        after.phase == EnginePhase.sessionComplete &&
        before.phase != EnginePhase.sessionComplete &&
        _sessionId != null;

    if (enteredSessionComplete) {
      // Alert before clearing session id (tray payload needs it).
      await _maybePlaySegmentAlert(before, after);
      await _persistCompletedSessionKeepUi();
    } else {
      await persistActiveState(reason);
      await _maybePlaySegmentAlert(before, after);
    }

    await _syncPlatformAdapters();
    _emitViewState();
    _maybeFireFlexibleReminder(after);
  }

  Future<void> _maybePlaySegmentAlert(
    TimerEngineState before,
    TimerEngineState after,
  ) async {
    final completedPrompt =
        after.phase == EnginePhase.segmentComplete ||
        after.phase == EnginePhase.sessionComplete;
    final autoAdvanced =
        before.phase == EnginePhase.running &&
        after.phase == EnginePhase.running &&
        before.currentSegmentIndex != after.currentSegmentIndex;
    if ((!completedPrompt && !autoAdvanced) ||
        before.phase != EnginePhase.running) {
      return;
    }
    final segment = before.currentSegment;
    if (segment == null || _sessionId == null) {
      return;
    }

    final settings = await _settingsRepository.get();
    final isFocusLike =
        segment.type == SegmentType.focus ||
        segment.type == SegmentType.flexible;
    if (!isFocusLike && !segment.isRest) {
      return;
    }

    final soundToneId = isFocusLike
        ? settings.alertToneFocusSuccess
        : settings.alertToneBreakOver;

    // Always drop pending wall-clock / immediate segment alerts so they
    // cannot double-fire after we handle the transition in-process.
    await _cancelSegmentEndNotifications();

    // User already heard the OS push and opened the app from it.
    if (_suppressNextSegmentAlert) {
      _suppressNextSegmentAlert = false;
      return;
    }

    // Foreground: in-app tone only. OS showAlert would overlap the same sound.
    if (_isInForeground) {
      await _alertSoundAdapter.play(soundToneId);
      return;
    }

    // Background edge path (rare — tick while not foreground): tray only.
    final copy = NotificationStrings.forLanguage(settings.language);
    final endCopy = _segmentEndCopyForTransition(
      before: before,
      after: after,
      strings: copy,
    );
    await _notificationAdapter.showAlert(
      title: endCopy.title,
      body: endCopy.body,
      sessionId: _sessionId!,
      soundToneId: soundToneId,
      notificationId: _immediateSegmentEndNotificationId,
      deepLinkSource: NotificationDeepLink.sourceSegmentEnd,
    );
  }

  Future<void> _cancelSegmentEndNotifications() async {
    if (_sessionId == null) {
      return;
    }
    await _notificationAdapter.cancel(_scheduledSegmentEndNotificationId);
    await _notificationAdapter.cancel(_immediateSegmentEndNotificationId);
  }

  Future<void> _syncSegmentProgress(
    TimerEngineState before,
    TimerEngineState after,
  ) async {
    final nowMs = _clock.nowUtc().millisecondsSinceEpoch;
    final from = before.currentSegmentIndex;
    final to = after.currentSegmentIndex;

    if (from >= 0 && from < _segmentIds.length && from != to) {
      final completedId = _segmentIds[from];
      final segment = before.currentSegment;
      final actualSec = segment?.type == SegmentType.flexible
          ? before.elapsedActiveSecAt(_clock.nowUtc())
          : segment?.plannedSec ?? 0;
      await _sessionRepository.updateSegmentProgress(
        UpdateSegmentInput(
          sessionId: _sessionId!,
          segmentId: completedId,
          segmentStatus: SegmentStatus.completed,
          actualSec: actualSec,
          segmentPausedSec: before.segmentPausedSec,
          endedAtUtcMs: nowMs,
          pomodoroFocusCount: after.pomodoroFocusCount,
          pomodoroCyclesCompleted: after.pomodoroCyclesCompleted,
          totalActiveSec: _computeTotalActiveSec(after),
          totalPausedSec: _computeTotalPausedSec(after),
          updatedAtUtcMs: nowMs,
        ),
      );

      // Pending rest skipped from post-focus prompt: mark jumped rests
      // as skipped / actualSec=0 (BR-TIMER-004). Includes sessionComplete
      // landing on the skipped long_rest itself.
      final skipEndExclusive =
          after.phase == EnginePhase.sessionComplete &&
              after.currentSegment?.isRest == true
          ? to + 1
          : to;
      for (var i = from + 1; i < skipEndExclusive; i++) {
        if (i < 0 || i >= _segmentIds.length || i >= before.segments.length) {
          break;
        }
        if (!before.segments[i].isRest) {
          continue;
        }
        await _sessionRepository.updateSegmentProgress(
          UpdateSegmentInput(
            sessionId: _sessionId!,
            segmentId: _segmentIds[i],
            segmentStatus: SegmentStatus.skipped,
            actualSec: 0,
            endedAtUtcMs: nowMs,
            pomodoroFocusCount: after.pomodoroFocusCount,
            pomodoroCyclesCompleted: after.pomodoroCyclesCompleted,
            totalActiveSec: _computeTotalActiveSec(after),
            totalPausedSec: _computeTotalPausedSec(after),
            updatedAtUtcMs: nowMs,
          ),
        );
      }
    } else if (after.phase == EnginePhase.sessionComplete &&
        before.phase != EnginePhase.sessionComplete &&
        from == to &&
        from >= 0 &&
        from < _segmentIds.length) {
      // Last segment completed without advancing index (typical final rest).
      final segment = before.currentSegment;
      final actualSec = segment?.type == SegmentType.flexible
          ? before.elapsedActiveSecAt(_clock.nowUtc())
          : segment?.plannedSec ?? 0;
      await _sessionRepository.updateSegmentProgress(
        UpdateSegmentInput(
          sessionId: _sessionId!,
          segmentId: _segmentIds[from],
          segmentStatus: SegmentStatus.completed,
          actualSec: actualSec,
          segmentPausedSec: before.segmentPausedSec,
          endedAtUtcMs: nowMs,
          pomodoroFocusCount: after.pomodoroFocusCount,
          pomodoroCyclesCompleted: after.pomodoroCyclesCompleted,
          totalActiveSec: _computeTotalActiveSec(after),
          totalPausedSec: _computeTotalPausedSec(after),
          updatedAtUtcMs: nowMs,
        ),
      );
    }

    if (after.phase == EnginePhase.running &&
        to >= 0 &&
        to < _segmentIds.length &&
        from != to) {
      await _markCurrentSegmentStarted();
    }

    if (after.phase == EnginePhase.sessionComplete ||
        after.phase == EnginePhase.segmentComplete) {
      await _updateSessionCounters(after);
    }
  }

  Future<void> _markCurrentSegmentStarted() async {
    final state = _engine.currentState;
    final index = state.currentSegmentIndex;
    if (index < 0 || index >= _segmentIds.length) {
      return;
    }
    final nowMs = _clock.nowUtc().millisecondsSinceEpoch;
    await _sessionRepository.updateSegmentProgress(
      UpdateSegmentInput(
        sessionId: _sessionId!,
        segmentId: _segmentIds[index],
        segmentStatus: SegmentStatus.active,
        startedAtUtcMs: nowMs,
        pomodoroFocusCount: state.pomodoroFocusCount,
        pomodoroCyclesCompleted: state.pomodoroCyclesCompleted,
        totalActiveSec: _computeTotalActiveSec(state),
        totalPausedSec: _computeTotalPausedSec(state),
        updatedAtUtcMs: nowMs,
      ),
    );
  }

  Future<void> _updateSessionCounters(TimerEngineState state) async {
    final nowMs = _clock.nowUtc().millisecondsSinceEpoch;
    if (_sessionId == null || state.currentSegmentIndex < 0) {
      return;
    }
    await _sessionRepository.updateSegmentProgress(
      UpdateSegmentInput(
        sessionId: _sessionId!,
        segmentId: _segmentIds[state.currentSegmentIndex],
        pomodoroFocusCount: state.pomodoroFocusCount,
        pomodoroCyclesCompleted: state.pomodoroCyclesCompleted,
        totalActiveSec: _computeTotalActiveSec(state),
        totalPausedSec: _computeTotalPausedSec(state),
        updatedAtUtcMs: nowMs,
      ),
    );
  }

  Future<void> _discardActiveSession() async {
    if (_sessionId == null) {
      return;
    }
    await _notificationAdapter.cancelAll();
    await _sessionRepository.deleteSession(_sessionId!);
    await _activeTimerStateRepository.delete();
    _clearSessionContext();
    await _focusAdapter.stopMonitoring();
    await _aodAdapter.disable();
  }

  Future<void> _finalizeActiveSession(SessionStatus terminalStatus) async {
    if (_sessionId == null) {
      return;
    }
    await _writeTerminalSession(terminalStatus);
    await _activeTimerStateRepository.delete();
    _clearSessionContext();
    await _syncPlatformAdapters();
    _emitViewState();
  }

  /// Persist completed session but keep tag context for "Start again" UI.
  Future<void> _persistCompletedSessionKeepUi() async {
    if (_sessionId == null) {
      return;
    }
    await _cancelSegmentEndNotifications();
    await _writeTerminalSession(SessionStatus.completed);
    await _activeTimerStateRepository.delete();
    _sessionId = null;
    _segmentIds = const [];
    // Keep _tagId / _tagName for restartSameTag.
  }

  Future<void> _writeTerminalSession(SessionStatus terminalStatus) async {
    if (_sessionId == null) {
      return;
    }
    final now = _clock.nowUtc();
    final nowMs = now.millisecondsSinceEpoch;
    final state = _engine.currentState;
    final dbSegments = await _sessionRepository.getSegmentsBySessionId(
      _sessionId!,
    );
    final currentId = _currentSegmentId();

    final finalizeSegments = dbSegments.map((dbSeg) {
      final isCurrent = dbSeg.id == currentId;
      var status = dbSeg.segmentStatus;
      var actual = dbSeg.actualSec;
      var ended = dbSeg.endedAtUtcMs;

      if (isCurrent && status != SegmentStatus.completed) {
        if (terminalStatus == SessionStatus.completed) {
          status = SegmentStatus.completed;
          actual = state.isFlexible
              ? state.elapsedActiveSecAt(now)
              : (state.currentSegment?.plannedSec ?? dbSeg.plannedSec);
        } else {
          // Abandoned / failed: keep elapsed active time for Timeline + stats.
          status = SegmentStatus.completed;
          actual = state.currentSegmentElapsedActiveSecAt(now);
        }
        ended = nowMs;
      } else if (terminalStatus != SessionStatus.completed &&
          (status == SegmentStatus.pending || status == SegmentStatus.active)) {
        status = SegmentStatus.skipped;
        actual = 0;
        ended = nowMs;
      }

      return FinalizeSegmentInput(
        segmentId: dbSeg.id,
        actualSec: actual,
        segmentPausedSec: isCurrent
            ? state.segmentPausedSec
            : dbSeg.segmentPausedSec,
        segmentStatus: status,
        startedAtUtcMs: dbSeg.startedAtUtcMs,
        endedAtUtcMs: ended ?? (status == SegmentStatus.pending ? null : nowMs),
      );
    }).toList();

    await _sessionRepository.finalizeSession(
      FinalizeSessionInput(
        sessionId: _sessionId!,
        terminalStatus: terminalStatus,
        endedAtUtcMs: nowMs,
        totalActiveSec: _computeTotalActiveSec(state),
        totalPausedSec: _computeTotalPausedSec(state),
        segments: finalizeSegments,
        updatedAtUtcMs: nowMs,
      ),
    );
  }

  Future<void> _handleFocusViolation() async {
    if (_engine.currentState.phase != EnginePhase.running) {
      return;
    }
    final settings = await _settingsRepository.get();
    final effective = _effectiveFocusMode(settings);
    if (effective == FocusMode.loose) {
      return;
    }
    try {
      final copy = NotificationStrings.forLanguage(settings.language);
      await _playFailureAlert(
        title: copy.focusFailedTitle,
        body: copy.focusViolationBody,
      );
      await _finalizeActiveSession(SessionStatus.failed);
      _engine.reportFocusViolation();
      _engine.resetAfterTerminalHandled();
    } on TimerTransitionError {
      // Ignore if phase changed concurrently.
    }
  }

  /// Failure tone via OS notification + in-app playback (stop / focus fail).
  ///
  /// Set [osNotification] false when the user is already in-app (e.g. Stop) so
  /// the custom failure tone is not played twice (tray + audioplayers).
  Future<void> _playFailureAlert({
    required String title,
    required String body,
    bool osNotification = true,
  }) async {
    final settings = await _settingsRepository.get();
    final toneId = settings.alertToneFocusFailure;
    final sessionId = _sessionId;
    if (sessionId != null) {
      await _notificationAdapter.cancel(sessionId.hashCode);
      if (osNotification) {
        await _notificationAdapter.showAlert(
          title: title,
          body: body,
          sessionId: sessionId,
          soundToneId: toneId,
          notificationId: sessionId.hashCode ^ 0x4641494c, // 'FAIL'
        );
      }
    }
    await _alertSoundAdapter.play(toneId);
  }

  Future<void> _syncPlatformAdapters() async {
    final phase = _engine.currentState.phase;
    final settings = await _settingsRepository.get();

    if (phase == EnginePhase.running) {
      await _startFocusMonitoring(settings);
      await _scheduleSegmentNotification();
      if (settings.alwaysOnDisplay) {
        await _aodAdapter.enable();
      }
    } else if (phase == EnginePhase.paused ||
        phase == EnginePhase.segmentComplete ||
        phase == EnginePhase.sessionComplete) {
      await _focusAdapter.stopMonitoring();
      if (settings.alwaysOnDisplay) {
        await _aodAdapter.enable();
      }
    } else {
      await _focusAdapter.stopMonitoring();
      await _aodAdapter.disable();
      await _notificationAdapter.cancelAll();
    }
  }

  Future<void> _startFocusMonitoring(AppSettings settings) async {
    final effective = _effectiveFocusMode(settings);
    await _focusAdapter.startMonitoring(
      effectiveMode: effective,
      whitelist: settings.whitelist,
      threshold: Duration(seconds: settings.focusViolationThresholdSec),
    );
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

  Future<void> _scheduleSegmentNotification() async {
    if (_sessionId == null) {
      return;
    }
    final state = _engine.currentState;
    if (!state.isPomodoro || state.phase != EnginePhase.running) {
      return;
    }
    final segment = state.currentSegment;
    if (segment == null) {
      return;
    }
    final now = _clock.nowUtc();
    final remaining = state.remainingSecAt(now);
    if (remaining <= 0) {
      return;
    }

    final settings = await _settingsRepository.get();
    final isFocus = segment.type == SegmentType.focus;
    final soundToneId = isFocus
        ? settings.alertToneFocusSuccess
        : settings.alertToneBreakOver;
    final copy = NotificationStrings.forLanguage(settings.language);
    final index = state.currentSegmentIndex;
    final nextIndex = index + 1;
    final nextType = nextIndex < state.segments.length
        ? state.segments[nextIndex].type
        : null;
    final endCopy = SegmentEndCopy.build(
      strings: copy,
      finished: segment.type,
      next: nextType,
      completedCount: index + 1,
      totalCount: state.segments.length,
      sessionComplete: nextType == null,
    );

    await _notificationAdapter.cancel(_scheduledSegmentEndNotificationId);
    await _notificationAdapter.scheduleSegmentEnd(
      fireAtUtc: now.add(Duration(seconds: remaining)),
      title: endCopy.title,
      body: endCopy.body,
      notificationId: _scheduledSegmentEndNotificationId,
      sessionId: _sessionId!,
      soundToneId: soundToneId,
    );
  }

  void _maybeFireFlexibleReminder(TimerEngineState state) {
    if (!state.isFlexible ||
        state.phase != EnginePhase.running ||
        _sessionId == null) {
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
      _engine.acknowledgeFlexibleReminder(_clock.nowUtc());
      unawaited(() async {
        final copy = await _notificationCopy();
        await _notificationAdapter.showReminder(
          title: copy.focusReminderTitle,
          body: copy.focusReminderBody,
          sessionId: _sessionId!,
        );
      }());
    }
  }

  String? _currentSegmentId() {
    final index = _engine.currentState.currentSegmentIndex;
    if (index < 0 || index >= _segmentIds.length) {
      return null;
    }
    return _segmentIds[index];
  }

  Future<NotificationStrings> _notificationCopy() async {
    final settings = await _settingsRepository.get();
    return NotificationStrings.forLanguage(settings.language);
  }

  int _computeTotalActiveSec(TimerEngineState state) {
    if (state.isFlexible) {
      return state.elapsedActiveSecAt(_clock.nowUtc());
    }
    return state.sessionStartedAtUtc == null
        ? 0
        : _clock.nowUtc().difference(state.sessionStartedAtUtc!).inSeconds -
              _computeTotalPausedSec(state);
  }

  int _computeTotalPausedSec(TimerEngineState state) {
    var paused = state.sessionTotalPausedSec + state.segmentPausedSec;
    if (state.phase == EnginePhase.paused && state.pauseStartedAtUtc != null) {
      paused += _clock.nowUtc().difference(state.pauseStartedAtUtc!).inSeconds;
    }
    return paused < 0 ? 0 : paused;
  }

  bool _shouldPersistPhase(EnginePhase phase) =>
      phase == EnginePhase.running ||
      phase == EnginePhase.paused ||
      phase == EnginePhase.segmentComplete ||
      phase == EnginePhase.sessionComplete;

  String _localTimelineDate(DateTime nowUtc) {
    final local = nowUtc.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }

  void _clearSessionContext() {
    _sessionId = null;
    _tagId = null;
    _tagName = null;
    _segmentIds = const [];
  }

  void _emitViewState() {
    if (_viewStateController.isClosed) {
      return;
    }
    _viewStateController.add(_buildViewState());
  }

  TimerViewState _buildViewState() {
    final state = _engine.currentState;
    final now = _clock.nowUtc();

    if (state.phase == EnginePhase.idle) {
      return TimerViewState.idle(showRecoveryPrompt: _showRecoveryPrompt);
    }

    final isCountdown = state.isPomodoro;
    final displaySec = isCountdown
        ? state.remainingSecAt(now)
        : state.elapsedActiveSecAt(now);
    final activeSec = _computeTotalActiveSec(state);
    final graceRemaining =
        (state.phase == EnginePhase.running ||
            state.phase == EnginePhase.paused)
        ? earlyStopGraceRemainingSec(activeSec)
        : 0;

    final endSummary = _segmentEndSummary(state);

    return TimerViewState(
      phase: state.phase,
      mode: state.mode,
      tagId: _tagId,
      tagName: _tagName,
      sessionId: _sessionId,
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

  SegmentEndCopy _segmentEndCopyForTransition({
    required TimerEngineState before,
    required TimerEngineState after,
    required NotificationStrings strings,
  }) {
    final finished = before.currentSegment!;
    final index = before.currentSegmentIndex;
    final nextIndex = index + 1;
    final nextType = nextIndex < before.segments.length
        ? before.segments[nextIndex].type
        : null;
    return SegmentEndCopy.build(
      strings: strings,
      finished: finished.type,
      next: nextType,
      completedCount: index + 1,
      totalCount: before.segments.length,
      sessionComplete: after.phase == EnginePhase.sessionComplete,
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
    return (
      finished: state.segments[index].type,
      next: nextType,
      completedCount: index + 1,
      totalCount: state.segments.length,
    );
  }

  Future<void> _guardNoActiveSession() async {
    if (_sessionId != null ||
        (_engine.currentState.phase != EnginePhase.idle &&
            _engine.currentState.phase != EnginePhase.sessionComplete)) {
      throw const ConflictError(
        code: 'TIMER_ACTIVE_SESSION',
        message: 'Sesi timer sedang berjalan. Selesaikan atau hentikan dulu.',
      );
    }
    final active = await _sessionRepository.getActiveSession();
    if (active != null) {
      throw const ConflictError(
        code: 'TIMER_ACTIVE_SESSION',
        message: 'Sesi timer sedang berjalan. Selesaikan atau hentikan dulu.',
      );
    }
  }

  Future<void> _guardActiveSession() async {
    if (_sessionId == null && _engine.currentState.phase == EnginePhase.idle) {
      throw const ConflictError(
        code: 'TIMER_NO_ACTIVE_SESSION',
        message: 'Tidak ada sesi aktif.',
      );
    }
  }

  void _requirePhase(EnginePhase phase) {
    if (_engine.currentState.phase != phase) {
      throw TimerTransitionError(
        'Requires phase $phase but was ${_engine.currentState.phase}',
      );
    }
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

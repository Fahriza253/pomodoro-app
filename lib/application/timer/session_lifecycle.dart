import 'package:pomodoro_app/application/timer/config_snapshot_factory.dart';
import 'package:pomodoro_app/application/timer/lifecycle_result.dart';
import 'package:pomodoro_app/application/timer/persist_reason.dart';
import 'package:pomodoro_app/application/timer/timer_state_builder.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/domain/timer/early_stop_grace.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/session_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/domain/timer/segment_planner.dart';
import 'package:pomodoro_app/domain/timer/timer_engine.dart';
import 'package:pomodoro_app/domain/timer/timer_transition_error.dart';
import 'package:pomodoro_app/platform/clock/clock_adapter.dart';
import 'package:uuid/uuid.dart';

/// Owns [TimerEngine] and durable Session/Segment/`ActiveTimerState` writes.
class SessionLifecycle {
  SessionLifecycle({
    required this._sessionRepository,
    required this._tagRepository,
    required this._activeTimerStateRepository,
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
       _uuid = uuid ?? const Uuid();

  final SessionRepository _sessionRepository;
  final TagRepository _tagRepository;
  final ActiveTimerStateRepository _activeTimerStateRepository;
  final ClockAdapter _clock;
  final TimerEngine _engine;
  final SegmentPlanner _planner;
  final ConfigSnapshotFactory _configSnapshotFactory;
  final TimerStateBuilder _stateBuilder;
  final Uuid _uuid;

  String? _sessionId;
  String? _tagId;
  String? _tagName;
  List<String> _segmentIds = const [];

  TimerEngineState get currentState => _engine.currentState;
  String? get sessionId => _sessionId;
  String? get tagId => _tagId;
  String? get tagName => _tagName;
  bool get hasActiveSession => _sessionId != null;

  Future<LifecycleResult> startPomodoro(String tagId) async {
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
    return _startSession(
      tagId: tagId,
      tagName: tagWithConfigs.tag.name,
      mode: TimerMode.pomodoro,
      snapshot: snapshot,
      segments: segments,
      cyclesTarget: snapshot.totalCycles,
      startEngine: (now) => _engine.startPomodoro(plan, now),
    );
  }

  Future<LifecycleResult> startFlexible(String tagId) async {
    await _guardNoActiveSession();
    final tagWithConfigs = await _tagRepository.getWithConfigs(tagId);
    final snapshot = _configSnapshotFactory.fromTagModeConfig(
      tagWithConfigs.flexible,
    );
    final segment = _planner.buildFlexibleSegment(snapshot);
    return _startSession(
      tagId: tagId,
      tagName: tagWithConfigs.tag.name,
      mode: TimerMode.flexible,
      snapshot: snapshot,
      segments: [segment],
      cyclesTarget: null,
      startEngine: (now) => _engine.startFlexible(snapshot, now),
    );
  }

  Future<LifecycleResult> pause() async {
    final before = _engine.currentState;
    _engine.pause(_clock.nowUtc());
    await _persistAfterCommand(before, PersistReason.pause);
    return _result(before);
  }

  Future<LifecycleResult> resume() async {
    final before = _engine.currentState;
    _engine.resume(_clock.nowUtc());
    _engine.tick(_clock.nowUtc());
    await _persistAfterCommand(before, PersistReason.resume);
    return _result(before);
  }

  Future<LifecycleResult> stop() async {
    await _guardActiveSession();
    final before = _engine.currentState;
    final activeSec = totalActiveSec(before);
    if (isWithinEarlyStopGrace(activeSec)) {
      // BR-TIMER-026: discard — no abandoned row, no failure tone.
      await _discardActiveSession();
      _engine.confirmStop();
      return _result(before);
    }
    return _finalizeThenIdle(
      before: before,
      status: SessionStatus.abandoned,
      resetEngine: _engine.confirmStop,
    );
  }

  Future<LifecycleResult> skipBreak() async {
    final before = _engine.currentState;
    _engine.skipBreak(_clock.nowUtc());
    await _persistAfterCommand(before, PersistReason.segmentTransition);
    return _result(before);
  }

  Future<LifecycleResult> advanceSegment() async {
    final before = _engine.currentState;
    _engine.advanceFromSegmentComplete(_clock.nowUtc());
    await _persistAfterCommand(before, PersistReason.segmentTransition);
    return _result(before);
  }

  Future<LifecycleResult> continuePomodoro() async {
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
    await _persistAfterCommand(before, PersistReason.segmentTransition);
    return _result(before);
  }

  Future<LifecycleResult> completeFlexible() async {
    await _guardActiveSession();
    final before = _engine.currentState;
    if (!before.isFlexible) {
      throw TimerTransitionError('completeFlexible requires flexible mode');
    }
    if (before.phase == EnginePhase.paused) {
      _engine.resume(_clock.nowUtc());
    }
    _engine.completeFlexible(_clock.nowUtc());
    await _persistAfterCommand(before, PersistReason.segmentTransition);
    return _result(before);
  }

  Future<LifecycleResult> dismissSessionComplete() async {
    final before = _engine.currentState;
    if (before.phase == EnginePhase.idle) {
      return _result(before);
    }
    _requirePhase(EnginePhase.sessionComplete);
    if (_sessionId != null) {
      await _writeTerminalSession(SessionStatus.completed);
      await _activeTimerStateRepository.delete();
    }
    _engine.dismissSessionComplete();
    _engine.resetAfterTerminalHandled();
    _clearSessionContext();
    return _result(before);
  }

  /// After auto-saved session complete: start a new session with the same tag.
  Future<LifecycleResult> restartSameTag() async {
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
      return _startSession(
        tagId: tagId,
        tagName: tagWithConfigs.tag.name,
        mode: TimerMode.pomodoro,
        snapshot: snapshot,
        segments: segments,
        cyclesTarget: snapshot.totalCycles,
        startEngine: (now) => _engine.startPomodoro(plan, now),
      );
    }
    final snapshot = _configSnapshotFactory.fromTagModeConfig(
      tagWithConfigs.flexible,
    );
    final segment = _planner.buildFlexibleSegment(snapshot);
    return _startSession(
      tagId: tagId,
      tagName: tagWithConfigs.tag.name,
      mode: TimerMode.flexible,
      snapshot: snapshot,
      segments: [segment],
      cyclesTarget: null,
      startEngine: (now) => _engine.startFlexible(snapshot, now),
    );
  }

  Future<LifecycleResult> resumeFromPersisted({
    ActiveTimerState? pending,
  }) async {
    final before = _engine.currentState;
    final persisted = pending ?? await _activeTimerStateRepository.get();
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
    await persistActiveState(PersistReason.sessionStart);
    return _result(before);
  }

  Future<LifecycleResult> declineRecovery({ActiveTimerState? pending}) async {
    final before = _engine.currentState;
    final persisted = pending ?? await _activeTimerStateRepository.get();
    if (persisted != null) {
      await _sessionRepository.markAbandoned(
        persisted.sessionId,
        _clock.nowUtc(),
      );
      await _activeTimerStateRepository.delete();
    }
    _clearSessionContext();
    return _result(before);
  }

  /// Wall-clock tick — MUST NOT persist unless phase/index changed (BR-TIMER-025).
  Future<LifecycleResult> tick() async {
    final before = _engine.currentState;
    _engine.tick(_clock.nowUtc());
    final after = _engine.currentState;
    if (before.phase != after.phase ||
        before.currentSegmentIndex != after.currentSegmentIndex) {
      await _persistAfterCommand(before, PersistReason.segmentTransition);
    }
    return _result(before);
  }

  Future<LifecycleResult> failForFocusViolation() async {
    final before = _engine.currentState;
    if (before.phase != EnginePhase.running) {
      return _result(before);
    }
    return _finalizeThenIdle(
      before: before,
      status: SessionStatus.failed,
      resetEngine: () {
        _engine.reportFocusViolation();
        _engine.resetAfterTerminalHandled();
      },
    );
  }

  /// Persist completed session but keep tag context for post-complete UI.
  ///
  /// Used for Flexible auto-finalize after session-complete Alert (session id
  /// still set for tray payload). Pomodoro stays soft-complete until Done.
  Future<LifecycleResult> persistCompletedKeepUi() async {
    final before = _engine.currentState;
    if (_sessionId == null) {
      return _result(before);
    }
    await _writeTerminalSession(SessionStatus.completed);
    await _activeTimerStateRepository.delete();
    _sessionId = null;
    _segmentIds = const [];
    return _result(before);
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

  void acknowledgeFlexibleReminder() {
    _engine.acknowledgeFlexibleReminder(_clock.nowUtc());
  }

  int totalActiveSec([TimerEngineState? state]) {
    final current = state ?? _engine.currentState;
    if (current.isFlexible) {
      return current.elapsedActiveSecAt(_clock.nowUtc());
    }
    return current.sessionStartedAtUtc == null
        ? 0
        : _clock.nowUtc().difference(current.sessionStartedAtUtc!).inSeconds -
              totalPausedSec(current);
  }

  int totalPausedSec([TimerEngineState? state]) {
    final current = state ?? _engine.currentState;
    var paused = current.sessionTotalPausedSec + current.segmentPausedSec;
    if (current.phase == EnginePhase.paused &&
        current.pauseStartedAtUtc != null) {
      paused += _clock
          .nowUtc()
          .difference(current.pauseStartedAtUtc!)
          .inSeconds;
    }
    return paused < 0 ? 0 : paused;
  }

  bool _disposed = false;

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _engine.dispose();
  }

  LifecycleResult _result(TimerEngineState before) {
    return LifecycleResult(
      before: before,
      after: _engine.currentState,
      sessionId: _sessionId,
      segmentIds: _segmentIds,
      currentSegmentId: _currentSegmentId(),
    );
  }

  /// Terminal write + idle engine. [LifecycleResult.sessionId] is the
  /// finalized Session so the facade can build [SideEffectContext] after clear.
  Future<LifecycleResult> _finalizeThenIdle({
    required TimerEngineState before,
    required SessionStatus status,
    required void Function() resetEngine,
  }) async {
    final sessionId = _sessionId;
    final segmentIds = _segmentIds;
    final currentSegmentId = _currentSegmentId();
    await _writeTerminalSession(status);
    await _activeTimerStateRepository.delete();
    _clearSessionContext();
    resetEngine();
    return LifecycleResult(
      before: before,
      after: _engine.currentState,
      sessionId: sessionId,
      segmentIds: segmentIds,
      currentSegmentId: currentSegmentId,
    );
  }

  Future<LifecycleResult> _startSession({
    required String tagId,
    required String tagName,
    required TimerMode mode,
    required ConfigSnapshot snapshot,
    required List<SegmentPlan> segments,
    required int? cyclesTarget,
    required void Function(DateTime now) startEngine,
  }) async {
    final before = _engine.currentState;
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
    return _result(before);
  }

  /// Persist Segment progress + ActiveTimerState. Does not finalize
  /// session-complete (facade Alerts first, then [persistCompletedKeepUi]).
  Future<void> _persistAfterCommand(
    TimerEngineState before,
    PersistReason reason,
  ) async {
    final after = _engine.currentState;
    if (_sessionId != null &&
        (before.currentSegmentIndex != after.currentSegmentIndex ||
            before.phase != after.phase)) {
      await _syncSegmentProgress(before, after);
    }

    await persistActiveState(reason);
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
          totalActiveSec: totalActiveSec(after),
          totalPausedSec: totalPausedSec(after),
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
            totalActiveSec: totalActiveSec(after),
            totalPausedSec: totalPausedSec(after),
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
          totalActiveSec: totalActiveSec(after),
          totalPausedSec: totalPausedSec(after),
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
        totalActiveSec: totalActiveSec(state),
        totalPausedSec: totalPausedSec(state),
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
        totalActiveSec: totalActiveSec(state),
        totalPausedSec: totalPausedSec(state),
        updatedAtUtcMs: nowMs,
      ),
    );
  }

  Future<void> _discardActiveSession() async {
    if (_sessionId == null) {
      return;
    }
    await _sessionRepository.deleteSession(_sessionId!);
    await _activeTimerStateRepository.delete();
    _clearSessionContext();
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
        totalActiveSec: totalActiveSec(state),
        totalPausedSec: totalPausedSec(state),
        segments: finalizeSegments,
        updatedAtUtcMs: nowMs,
      ),
    );
  }

  String? _currentSegmentId() {
    final index = _engine.currentState.currentSegmentIndex;
    if (index < 0 || index >= _segmentIds.length) {
      return null;
    }
    return _segmentIds[index];
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
}

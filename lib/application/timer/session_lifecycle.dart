import 'package:pomodoro_app/application/timer/config_snapshot_factory.dart';
import 'package:pomodoro_app/application/timer/lifecycle_result.dart';
import 'package:pomodoro_app/application/timer/segment_boundary_description.dart';
import 'package:pomodoro_app/application/timer/session_lifecycle_persistence.dart';
import 'package:pomodoro_app/application/timer/session_runtime_context.dart';
import 'package:pomodoro_app/application/timer/session_terminal_follow_up.dart';
import 'package:pomodoro_app/application/timer/session_wall_clock_totals.dart';
import 'package:pomodoro_app/application/timer/persist_reason.dart';
import 'package:pomodoro_app/application/timer/session_segment_writer.dart';
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
    required SessionRepository sessionRepository,
    required this._tagRepository,
    required ActiveTimerStateRepository activeTimerStateRepository,
    required ClockAdapter clock,
    SessionSegmentWriter? segmentWriter,
    TimerEngine? engine,
    SegmentPlanner? planner,
    ConfigSnapshotFactory? configSnapshotFactory,
    TimerStateBuilder? stateBuilder,
    Uuid? uuid,
  }) : _sessionRepository = sessionRepository,
       _activeTimerStateRepository = activeTimerStateRepository,
       _clock = clock,
       _segmentWriter =
           segmentWriter ??
           SessionSegmentWriter(
             sessionRepository: sessionRepository,
             clock: clock,
           ),
       _engine = engine ?? TimerEngine(planner: planner),
       _planner = planner ?? const SegmentPlanner(),
       _configSnapshotFactory =
           configSnapshotFactory ?? const ConfigSnapshotFactory(),
       _stateBuilder = stateBuilder ?? const TimerStateBuilder(),
       _uuid = uuid ?? const Uuid(),
       _context = SessionRuntimeContext(),
       _totals = SessionWallClockTotals(clock) {
    _persistence = SessionLifecyclePersistence(
      context: _context,
      totals: _totals,
      segmentWriter: _segmentWriter,
      activeTimerStateRepository: _activeTimerStateRepository,
      clock: _clock,
      currentEngineState: () => _engine.currentState,
    );
  }

  final SessionRepository _sessionRepository;
  final TagRepository _tagRepository;
  final ActiveTimerStateRepository _activeTimerStateRepository;
  final ClockAdapter _clock;
  final SessionSegmentWriter _segmentWriter;
  final TimerEngine _engine;
  final SegmentPlanner _planner;
  final ConfigSnapshotFactory _configSnapshotFactory;
  final TimerStateBuilder _stateBuilder;
  final Uuid _uuid;
  final SessionRuntimeContext _context;
  final SessionWallClockTotals _totals;
  late final SessionLifecyclePersistence _persistence;

  TimerEngineState get currentState => _engine.currentState;
  String? get sessionId => _context.sessionId;
  String? get tagId => _context.tagId;
  String? get tagName => _context.tagName;
  bool get hasActiveSession => _context.hasActiveSession;

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

  Future<LifecycleResult> pause() => _mutateAndPersist(
    mutate: _engine.pause,
    reason: PersistReason.pause,
  );

  Future<LifecycleResult> resume() => _mutateAndPersist(
    mutate: (now) {
      _engine.resume(now);
      _engine.tick(now);
    },
    reason: PersistReason.resume,
  );

  Future<LifecycleResult> stop() async {
    await _guardActiveSession();
    final before = _engine.currentState;
    final activeSec = _totals.totalActiveSec(before);
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

  Future<LifecycleResult> skipBreak() => _mutateAndPersist(
    mutate: _engine.skipBreak,
    reason: PersistReason.segmentTransition,
  );

  Future<LifecycleResult> advanceSegment() => _mutateAndPersist(
    mutate: _engine.advanceFromSegmentComplete,
    reason: PersistReason.segmentTransition,
  );

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
    _context.appendSegmentIds(newInputs.map((s) => s.id));
    await _segmentWriter.appendAndStart(
      sessionId: _context.sessionId!,
      newSegments: newInputs,
      pomodoroCyclesTarget: after.pomodoroCyclesTarget,
      activeSegmentId: _context.segmentIds[after.currentSegmentIndex],
      state: after,
      totalActiveSec: _totals.totalActiveSec(after),
      totalPausedSec: _totals.totalPausedSec(after),
    );
    final nowUtc = _clock.nowUtc();
    final boundary = describeSegmentBoundary(
      before: before,
      after: after,
      nowUtc: nowUtc,
    );
    await _persistence.syncAfterTransition(
      before: before,
      reason: PersistReason.segmentTransition,
      boundary: boundary,
      omitStartedSegment: true,
    );
    return _result(before, boundary: boundary);
  }

  Future<LifecycleResult> completeFlexible() async {
    await _guardActiveSession();
    if (!_engine.currentState.isFlexible) {
      throw TimerTransitionError('completeFlexible requires flexible mode');
    }
    return _mutateAndPersist(
      mutate: (now) {
        if (_engine.currentState.phase == EnginePhase.paused) {
          _engine.resume(now);
        }
        _engine.completeFlexible(now);
      },
      reason: PersistReason.segmentTransition,
    );
  }

  Future<LifecycleResult> dismissSessionComplete() async {
    final before = _engine.currentState;
    if (before.phase == EnginePhase.idle) {
      return _result(before);
    }
    _requirePhase(EnginePhase.sessionComplete);
    await _leaveSessionCompleteTerminal(retainTagContext: false);
    return _result(before);
  }

  /// After auto-saved session complete: start a new session with the same tag.
  Future<LifecycleResult> restartSameTag() async {
    final tagId = _context.tagId;
    final mode = _engine.currentState.mode;
    if (tagId == null || mode == null) {
      throw const ConflictError(
        code: 'TIMER_NO_ACTIVE_SESSION',
        message: 'Tidak ada tag untuk memulai ulang.',
      );
    }
    _requirePhase(EnginePhase.sessionComplete);
    await _leaveSessionCompleteTerminal(retainTagContext: true);

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

    _context.bindSession(
      sessionId: session.id,
      tagId: session.tagId,
      tagName: tag?.name,
      segmentIds: _stateBuilder.segmentIdsFromDb(dbSegments),
    );

    final rebuilt = _stateBuilder.fromPersisted(
      session: session,
      dbSegments: dbSegments,
      persisted: persisted,
    );
    final nowUtc = _clock.nowUtc();
    _engine.restoreFromPersisted(rebuilt, nowUtc);
    var after = _engine.currentState;
    final boundary = describeSegmentBoundary(
      before: rebuilt,
      after: after,
      nowUtc: nowUtc,
    );
    if (boundary.significant) {
      await _persistence.syncAfterTransition(
        before: rebuilt,
        reason: PersistReason.segmentTransition,
        boundary: boundary,
      );
      after = _engine.currentState;
    }
    await _persistence.persistActiveSnapshot(PersistReason.sessionStart);
    return _result(rebuilt, boundary: boundary);
  }

  Future<LifecycleResult> declineRecovery({ActiveTimerState? pending}) async {
    final before = _engine.currentState;
    final persisted = pending ?? await _activeTimerStateRepository.get();
    if (persisted != null) {
      await _sessionRepository.markAbandoned(
        persisted.sessionId,
        _clock.nowUtc(),
      );
      await _persistence.deleteActiveSnapshot();
    }
    _context.clearAll();
    return _result(before);
  }

  /// Wall-clock tick — MUST NOT persist unless phase/index changed (BR-TIMER-025).
  Future<LifecycleResult> tick() async {
    final before = _engine.currentState;
    final nowUtc = _clock.nowUtc();
    _engine.tick(nowUtc);
    final boundary = describeSegmentBoundary(
      before: before,
      after: _engine.currentState,
      nowUtc: nowUtc,
    );
    if (boundary.significant) {
      await _persistence.syncAfterTransition(
        before: before,
        reason: PersistReason.segmentTransition,
        boundary: boundary,
      );
    }
    return _result(before, boundary: boundary);
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
    if (_context.sessionId == null) {
      return _result(before);
    }
    await _persistence.writeTerminalSession(SessionStatus.completed);
    await _persistence.deleteActiveSnapshot();
    _context.clearSessionOnly();
    return _result(before);
  }

  Future<void> persistActiveState(PersistReason reason) =>
      _persistence.persistActiveSnapshot(reason);

  void acknowledgeFlexibleReminder() {
    _engine.acknowledgeFlexibleReminder(_clock.nowUtc());
  }

  int totalActiveSec([TimerEngineState? state]) =>
      _totals.totalActiveSec(state ?? _engine.currentState);

  int totalPausedSec([TimerEngineState? state]) =>
      _totals.totalPausedSec(state ?? _engine.currentState);

  bool _disposed = false;

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _engine.dispose();
  }

  LifecycleResult _result(
    TimerEngineState before, {
    SegmentBoundaryDescription? boundary,
  }) {
    final after = _engine.currentState;
    final nowUtc = _clock.nowUtc();
    return LifecycleResult(
      before: before,
      after: after,
      sessionId: _context.sessionId,
      segmentIds: _context.segmentIds,
      currentSegmentId: _context.currentSegmentId(after),
      segmentBoundary:
          boundary ??
          describeSegmentBoundary(before: before, after: after, nowUtc: nowUtc),
      terminalFollowUp: _terminalFollowUp(before: before, after: after),
    );
  }

  SessionTerminalFollowUp _terminalFollowUp({
    required TimerEngineState before,
    required TimerEngineState after,
  }) {
    final enteredSessionComplete =
        after.phase == EnginePhase.sessionComplete &&
        before.phase != EnginePhase.sessionComplete;
    if (!enteredSessionComplete || _context.sessionId == null) {
      return SessionTerminalFollowUp.none;
    }
    if (after.isFlexible) {
      return SessionTerminalFollowUp.persistCompletedKeepUi;
    }
    return SessionTerminalFollowUp.none;
  }

  /// Terminal completed write from session-complete prompt, then engine idle.
  Future<void> _leaveSessionCompleteTerminal({
    required bool retainTagContext,
  }) async {
    if (_context.sessionId != null) {
      await _persistence.writeTerminalSession(SessionStatus.completed);
      await _persistence.deleteActiveSnapshot();
      _context.clearAfterTerminal(retainTagContext: retainTagContext);
    }
    _engine.dismissSessionComplete();
    _engine.resetAfterTerminalHandled();
  }

  /// Terminal write + idle engine. [LifecycleResult.sessionId] is the
  /// finalized Session so the facade can build [SideEffectContext] after clear.
  Future<LifecycleResult> _finalizeThenIdle({
    required TimerEngineState before,
    required SessionStatus status,
    required void Function() resetEngine,
  }) async {
    final sessionId = _context.sessionId;
    final segmentIds = _context.segmentIds;
    final currentSegmentId = _context.currentSegmentId(before);
    await _persistence.writeTerminalSession(status);
    await _persistence.deleteActiveSnapshot();
    _context.clearAll();
    resetEngine();
    final after = _engine.currentState;
    final nowUtc = _clock.nowUtc();
    final boundary = describeSegmentBoundary(
      before: before,
      after: after,
      nowUtc: nowUtc,
    );
    return LifecycleResult(
      before: before,
      after: after,
      sessionId: sessionId,
      segmentIds: segmentIds,
      currentSegmentId: currentSegmentId,
      segmentBoundary: boundary,
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

    _context.bindSession(
      sessionId: sessionId,
      tagId: tagId,
      tagName: tagName,
      segmentIds: segmentIds,
    );

    startEngine(now);

    await _persistence.persistActiveSnapshot(PersistReason.sessionStart);
    return _result(before);
  }

  Future<LifecycleResult> _mutateAndPersist({
    required void Function(DateTime now) mutate,
    required PersistReason reason,
  }) async {
    final before = _engine.currentState;
    final nowUtc = _clock.nowUtc();
    mutate(nowUtc);
    final boundary = describeSegmentBoundary(
      before: before,
      after: _engine.currentState,
      nowUtc: nowUtc,
    );
    await _persistence.syncAfterTransition(
      before: before,
      reason: reason,
      boundary: boundary,
    );
    return _result(before, boundary: boundary);
  }

  Future<void> _discardActiveSession() async {
    final sessionId = _context.sessionId;
    if (sessionId == null) {
      return;
    }
    await _sessionRepository.deleteSession(sessionId);
    await _persistence.deleteActiveSnapshot();
    _context.clearAll();
  }

  String _localTimelineDate(DateTime nowUtc) {
    final local = nowUtc.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}-$m-$d';
  }

  Future<void> _guardNoActiveSession() async {
    if (_context.sessionId != null ||
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
    if (_context.sessionId == null &&
        _engine.currentState.phase == EnginePhase.idle) {
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

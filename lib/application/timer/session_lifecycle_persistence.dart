import 'package:pomodoro_app/application/timer/persist_reason.dart';
import 'package:pomodoro_app/application/timer/segment_boundary_description.dart';
import 'package:pomodoro_app/application/timer/session_runtime_context.dart';
import 'package:pomodoro_app/application/timer/session_segment_writer.dart';
import 'package:pomodoro_app/application/timer/session_wall_clock_totals.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/platform/clock/clock_adapter.dart';

/// Segment sync and [ActiveTimerState] writes for [SessionLifecycle].
class SessionLifecyclePersistence {
  SessionLifecyclePersistence({
    required SessionRuntimeContext context,
    required SessionWallClockTotals totals,
    required SessionSegmentWriter segmentWriter,
    required ActiveTimerStateRepository activeTimerStateRepository,
    required ClockAdapter clock,
    required TimerEngineState Function() currentEngineState,
  }) : _context = context,
       _totals = totals,
       _segmentWriter = segmentWriter,
       _activeTimerStateRepository = activeTimerStateRepository,
       _clock = clock,
       _currentEngineState = currentEngineState;

  final SessionRuntimeContext _context;
  final SessionWallClockTotals _totals;
  final SessionSegmentWriter _segmentWriter;
  final ActiveTimerStateRepository _activeTimerStateRepository;
  final ClockAdapter _clock;
  final TimerEngineState Function() _currentEngineState;

  /// Persist Segment progress + ActiveTimerState after an engine mutation.
  ///
  /// Pass a precomputed [boundary] so lifecycle and hub share one interpretation.
  /// Set [omitStartedSegment] when [SessionSegmentWriter.appendAndStart] already
  /// marked the new Segment active (Pomodoro Lanjutkan).
  Future<void> syncAfterTransition({
    required TimerEngineState before,
    required PersistReason reason,
    SegmentBoundaryDescription? boundary,
    bool omitStartedSegment = false,
  }) async {
    final resolved =
        boundary ??
        describeSegmentBoundary(
          before: before,
          after: _currentEngineState(),
          nowUtc: _clock.nowUtc(),
        );
    final after = resolved.after;
    final sessionId = _context.sessionId;
    if (sessionId != null && resolved.significant) {
      var boundaryForWriter = resolved;
      if (omitStartedSegment) {
        final semantics = resolved.completionSemantics;
        if (semantics != null) {
          final trimmed = semantics.withoutStartedSegment();
          if (trimmed != semantics) {
            boundaryForWriter = SegmentBoundaryDescription(
              before: resolved.before,
              after: resolved.after,
              significant: resolved.significant,
              segmentEndAlert: resolved.segmentEndAlert,
              segmentEndSemantics: resolved.segmentEndSemantics,
              completionSemantics: trimmed,
            );
          }
        }
      }
      await _segmentWriter.syncOnTransition(
        sessionId: sessionId,
        segmentIds: _context.segmentIds,
        boundary: boundaryForWriter,
        totalActiveSec: _totals.totalActiveSec(after),
        totalPausedSec: _totals.totalPausedSec(after),
      );
    }

    await persistActiveSnapshot(reason);
  }

  Future<void> persistActiveSnapshot(PersistReason reason) async {
    final state = _currentEngineState();
    final sessionId = _context.sessionId;
    if (sessionId == null || !_shouldPersistPhase(state.phase)) {
      return;
    }
    final nowMs = _clock.nowUtc().millisecondsSinceEpoch;
    await _activeTimerStateRepository.upsert(
      ActiveTimerState(
        sessionId: sessionId,
        enginePhase: state.phase,
        currentSegmentId: _context.currentSegmentId(state),
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

  Future<void> writeTerminalSession(SessionStatus terminalStatus) async {
    final sessionId = _context.sessionId;
    if (sessionId == null) {
      return;
    }
    final state = _currentEngineState();
    await _segmentWriter.writeTerminal(
      sessionId: sessionId,
      segmentIds: _context.segmentIds,
      state: state,
      terminalStatus: terminalStatus,
      totalActiveSec: _totals.totalActiveSec(state),
      totalPausedSec: _totals.totalPausedSec(state),
    );
  }

  Future<void> deleteActiveSnapshot() => _activeTimerStateRepository.delete();

  bool _shouldPersistPhase(EnginePhase phase) =>
      phase == EnginePhase.running ||
      phase == EnginePhase.paused ||
      phase == EnginePhase.segmentComplete ||
      phase == EnginePhase.sessionComplete;
}
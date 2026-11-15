import 'package:pomodoro_app/application/timer/segment_boundary_description.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/domain/timer/segment_completion_semantics.dart';
import 'package:pomodoro_app/platform/clock/clock_adapter.dart';

/// Durable Segment row writes for mid-Session transitions, terminal finalize,
/// and Pomodoro Lanjutkan append.
///
/// Stateless across Sessions: callers pass identity and active-time totals.
class SessionSegmentWriter {
  SessionSegmentWriter({
    required this._sessionRepository,
    required this._clock,
  });

  final SessionRepository _sessionRepository;
  final ClockAdapter _clock;

  /// Persist Segment progress after a phase/index change (not terminal finalize).
  Future<void> syncOnTransition({
    required String sessionId,
    required List<String> segmentIds,
    required SegmentBoundaryDescription boundary,
    required int totalActiveSec,
    required int totalPausedSec,
  }) async {
    if (!boundary.significant) {
      return;
    }
    final semantics = boundary.completionSemantics;
    if (semantics == null || !semantics.hasRowWrites) {
      return;
    }
    await _applyCompletionSemantics(
      sessionId: sessionId,
      segmentIds: segmentIds,
      semantics: semantics,
      after: boundary.after,
      totalActiveSec: totalActiveSec,
      totalPausedSec: totalPausedSec,
    );
  }

  /// Maps pre-derived [semantics] to Segment rows (tests and direct handoff).
  Future<void> applyCompletionSemantics({
    required String sessionId,
    required List<String> segmentIds,
    required SegmentCompletionSemantics semantics,
    required TimerEngineState after,
    required int totalActiveSec,
    required int totalPausedSec,
  }) async {
    if (!semantics.hasRowWrites) {
      return;
    }
    await _applyCompletionSemantics(
      sessionId: sessionId,
      segmentIds: segmentIds,
      semantics: semantics,
      after: after,
      totalActiveSec: totalActiveSec,
      totalPausedSec: totalPausedSec,
    );
  }

  Future<void> _applyCompletionSemantics({
    required String sessionId,
    required List<String> segmentIds,
    required SegmentCompletionSemantics semantics,
    required TimerEngineState after,
    required int totalActiveSec,
    required int totalPausedSec,
  }) async {
    final nowMs = _clock.nowUtc().millisecondsSinceEpoch;

    for (final completed in semantics.completedSegments) {
      if (!_indexInRange(completed.segmentIndex, segmentIds)) {
        continue;
      }
      await _sessionRepository.updateSegmentProgress(
        UpdateSegmentInput(
          sessionId: sessionId,
          segmentId: segmentIds[completed.segmentIndex],
          segmentStatus: SegmentStatus.completed,
          actualSec: completed.actualSec,
          segmentPausedSec: completed.segmentPausedSec,
          endedAtUtcMs: nowMs,
          pomodoroFocusCount: semantics.pomodoroFocusCount,
          pomodoroCyclesCompleted: semantics.pomodoroCyclesCompleted,
          totalActiveSec: totalActiveSec,
          totalPausedSec: totalPausedSec,
          updatedAtUtcMs: nowMs,
        ),
      );
    }

    for (final skipped in semantics.skippedRests) {
      if (!_indexInRange(skipped.segmentIndex, segmentIds)) {
        continue;
      }
      await _sessionRepository.updateSegmentProgress(
        UpdateSegmentInput(
          sessionId: sessionId,
          segmentId: segmentIds[skipped.segmentIndex],
          segmentStatus: SegmentStatus.skipped,
          actualSec: 0,
          endedAtUtcMs: nowMs,
          pomodoroFocusCount: semantics.pomodoroFocusCount,
          pomodoroCyclesCompleted: semantics.pomodoroCyclesCompleted,
          totalActiveSec: totalActiveSec,
          totalPausedSec: totalPausedSec,
          updatedAtUtcMs: nowMs,
        ),
      );
    }

    final started = semantics.startedSegmentIndex;
    if (started != null && _indexInRange(started, segmentIds)) {
      await _markSegmentStarted(
        sessionId: sessionId,
        segmentId: segmentIds[started],
        state: after,
        totalActiveSec: totalActiveSec,
        totalPausedSec: totalPausedSec,
        nowMs: nowMs,
        pomodoroFocusCount: semantics.pomodoroFocusCount,
        pomodoroCyclesCompleted: semantics.pomodoroCyclesCompleted,
      );
    }

    final counterSync = semantics.counterSyncSegmentIndex;
    if (counterSync != null && _indexInRange(counterSync, segmentIds)) {
      await _updateSessionCounters(
        sessionId: sessionId,
        segmentId: segmentIds[counterSync],
        pomodoroFocusCount: semantics.pomodoroFocusCount,
        pomodoroCyclesCompleted: semantics.pomodoroCyclesCompleted,
        totalActiveSec: totalActiveSec,
        totalPausedSec: totalPausedSec,
        nowMs: nowMs,
      );
    }
  }

  /// Load Segments and finalize Session for [terminalStatus].
  Future<void> writeTerminal({
    required String sessionId,
    required List<String> segmentIds,
    required TimerEngineState state,
    required SessionStatus terminalStatus,
    required int totalActiveSec,
    required int totalPausedSec,
  }) async {
    final now = _clock.nowUtc();
    final nowMs = now.millisecondsSinceEpoch;
    final dbSegments = await _sessionRepository.getSegmentsBySessionId(
      sessionId,
    );
    final currentId = _segmentIdAt(segmentIds, state.currentSegmentIndex);

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
        sessionId: sessionId,
        terminalStatus: terminalStatus,
        endedAtUtcMs: nowMs,
        totalActiveSec: totalActiveSec,
        totalPausedSec: totalPausedSec,
        segments: finalizeSegments,
        updatedAtUtcMs: nowMs,
      ),
    );
  }

  /// Persist Lanjutkan append rows and mark [activeSegmentId] active.
  Future<void> appendAndStart({
    required String sessionId,
    required List<CreateSegmentInput> newSegments,
    required int? pomodoroCyclesTarget,
    required String activeSegmentId,
    required TimerEngineState state,
    required int totalActiveSec,
    required int totalPausedSec,
  }) async {
    await _sessionRepository.appendSegments(
      sessionId,
      newSegments,
      pomodoroCyclesTarget: pomodoroCyclesTarget,
    );
    final nowMs = _clock.nowUtc().millisecondsSinceEpoch;
    await _markSegmentStarted(
      sessionId: sessionId,
      segmentId: activeSegmentId,
      state: state,
      totalActiveSec: totalActiveSec,
      totalPausedSec: totalPausedSec,
      nowMs: nowMs,
      pomodoroFocusCount: state.pomodoroFocusCount,
      pomodoroCyclesCompleted: state.pomodoroCyclesCompleted,
    );
  }

  bool _indexInRange(int index, List<String> segmentIds) =>
      index >= 0 && index < segmentIds.length;

  String? _segmentIdAt(List<String> segmentIds, int index) {
    if (index < 0 || index >= segmentIds.length) {
      return null;
    }
    return segmentIds[index];
  }

  Future<void> _markSegmentStarted({
    required String sessionId,
    required String segmentId,
    required TimerEngineState state,
    required int totalActiveSec,
    required int totalPausedSec,
    required int nowMs,
    required int pomodoroFocusCount,
    required int pomodoroCyclesCompleted,
  }) async {
    await _sessionRepository.updateSegmentProgress(
      UpdateSegmentInput(
        sessionId: sessionId,
        segmentId: segmentId,
        segmentStatus: SegmentStatus.active,
        startedAtUtcMs: nowMs,
        pomodoroFocusCount: pomodoroFocusCount,
        pomodoroCyclesCompleted: pomodoroCyclesCompleted,
        totalActiveSec: totalActiveSec,
        totalPausedSec: totalPausedSec,
        updatedAtUtcMs: nowMs,
      ),
    );
  }

  Future<void> _updateSessionCounters({
    required String sessionId,
    required String segmentId,
    required int pomodoroFocusCount,
    required int pomodoroCyclesCompleted,
    required int totalActiveSec,
    required int totalPausedSec,
    required int nowMs,
  }) async {
    await _sessionRepository.updateSegmentProgress(
      UpdateSegmentInput(
        sessionId: sessionId,
        segmentId: segmentId,
        pomodoroFocusCount: pomodoroFocusCount,
        pomodoroCyclesCompleted: pomodoroCyclesCompleted,
        totalActiveSec: totalActiveSec,
        totalPausedSec: totalPausedSec,
        updatedAtUtcMs: nowMs,
      ),
    );
  }
}
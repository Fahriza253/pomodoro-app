import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
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
    required TimerEngineState before,
    required TimerEngineState after,
    required int totalActiveSec,
    required int totalPausedSec,
  }) async {
    final nowMs = _clock.nowUtc().millisecondsSinceEpoch;
    final from = before.currentSegmentIndex;
    final to = after.currentSegmentIndex;

    if (from >= 0 && from < segmentIds.length && from != to) {
      final completedId = segmentIds[from];
      final segment = before.currentSegment;
      final actualSec = segment?.type == SegmentType.flexible
          ? before.elapsedActiveSecAt(_clock.nowUtc())
          : segment?.plannedSec ?? 0;
      await _sessionRepository.updateSegmentProgress(
        UpdateSegmentInput(
          sessionId: sessionId,
          segmentId: completedId,
          segmentStatus: SegmentStatus.completed,
          actualSec: actualSec,
          segmentPausedSec: before.segmentPausedSec,
          endedAtUtcMs: nowMs,
          pomodoroFocusCount: after.pomodoroFocusCount,
          pomodoroCyclesCompleted: after.pomodoroCyclesCompleted,
          totalActiveSec: totalActiveSec,
          totalPausedSec: totalPausedSec,
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
        if (i < 0 || i >= segmentIds.length || i >= before.segments.length) {
          break;
        }
        if (!before.segments[i].isRest) {
          continue;
        }
        await _sessionRepository.updateSegmentProgress(
          UpdateSegmentInput(
            sessionId: sessionId,
            segmentId: segmentIds[i],
            segmentStatus: SegmentStatus.skipped,
            actualSec: 0,
            endedAtUtcMs: nowMs,
            pomodoroFocusCount: after.pomodoroFocusCount,
            pomodoroCyclesCompleted: after.pomodoroCyclesCompleted,
            totalActiveSec: totalActiveSec,
            totalPausedSec: totalPausedSec,
            updatedAtUtcMs: nowMs,
          ),
        );
      }
    } else if (after.phase == EnginePhase.sessionComplete &&
        before.phase != EnginePhase.sessionComplete &&
        from == to &&
        from >= 0 &&
        from < segmentIds.length) {
      // Last segment completed without advancing index (typical final rest).
      final segment = before.currentSegment;
      final actualSec = segment?.type == SegmentType.flexible
          ? before.elapsedActiveSecAt(_clock.nowUtc())
          : segment?.plannedSec ?? 0;
      await _sessionRepository.updateSegmentProgress(
        UpdateSegmentInput(
          sessionId: sessionId,
          segmentId: segmentIds[from],
          segmentStatus: SegmentStatus.completed,
          actualSec: actualSec,
          segmentPausedSec: before.segmentPausedSec,
          endedAtUtcMs: nowMs,
          pomodoroFocusCount: after.pomodoroFocusCount,
          pomodoroCyclesCompleted: after.pomodoroCyclesCompleted,
          totalActiveSec: totalActiveSec,
          totalPausedSec: totalPausedSec,
          updatedAtUtcMs: nowMs,
        ),
      );
    }

    if (after.phase == EnginePhase.running &&
        to >= 0 &&
        to < segmentIds.length &&
        from != to) {
      await _markSegmentStarted(
        sessionId: sessionId,
        segmentId: segmentIds[to],
        state: after,
        totalActiveSec: totalActiveSec,
        totalPausedSec: totalPausedSec,
        nowMs: nowMs,
      );
    }

    if (after.phase == EnginePhase.sessionComplete ||
        after.phase == EnginePhase.segmentComplete) {
      await _updateSessionCounters(
        sessionId: sessionId,
        segmentIds: segmentIds,
        state: after,
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
    );
  }

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
  }) async {
    await _sessionRepository.updateSegmentProgress(
      UpdateSegmentInput(
        sessionId: sessionId,
        segmentId: segmentId,
        segmentStatus: SegmentStatus.active,
        startedAtUtcMs: nowMs,
        pomodoroFocusCount: state.pomodoroFocusCount,
        pomodoroCyclesCompleted: state.pomodoroCyclesCompleted,
        totalActiveSec: totalActiveSec,
        totalPausedSec: totalPausedSec,
        updatedAtUtcMs: nowMs,
      ),
    );
  }

  Future<void> _updateSessionCounters({
    required String sessionId,
    required List<String> segmentIds,
    required TimerEngineState state,
    required int totalActiveSec,
    required int totalPausedSec,
    required int nowMs,
  }) async {
    if (state.currentSegmentIndex < 0 ||
        state.currentSegmentIndex >= segmentIds.length) {
      return;
    }
    await _sessionRepository.updateSegmentProgress(
      UpdateSegmentInput(
        sessionId: sessionId,
        segmentId: segmentIds[state.currentSegmentIndex],
        pomodoroFocusCount: state.pomodoroFocusCount,
        pomodoroCyclesCompleted: state.pomodoroCyclesCompleted,
        totalActiveSec: totalActiveSec,
        totalPausedSec: totalPausedSec,
        updatedAtUtcMs: nowMs,
      ),
    );
  }
}

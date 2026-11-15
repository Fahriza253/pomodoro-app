import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';

/// Durable row update for a Segment that reached [SegmentStatus.completed].
class CompletedSegmentSemantics {
  const CompletedSegmentSemantics({
    required this.segmentIndex,
    required this.actualSec,
    required this.segmentPausedSec,
  });

  final int segmentIndex;
  final int actualSec;
  final int segmentPausedSec;
}

/// Pending or running rest marked [SegmentStatus.skipped] (BR-TIMER-004).
class SkippedRestSemantics {
  const SkippedRestSemantics({required this.segmentIndex});

  final int segmentIndex;
}

/// Engine-authoritative Segment row effects for one lifecycle transition.
class SegmentCompletionSemantics {
  const SegmentCompletionSemantics({
    this.completedSegments = const [],
    this.skippedRests = const [],
    this.startedSegmentIndex,
    this.counterSyncSegmentIndex,
    required this.pomodoroFocusCount,
    required this.pomodoroCyclesCompleted,
    required this.sessionReachedTerminal,
  });

  static const empty = SegmentCompletionSemantics(
    pomodoroFocusCount: 0,
    pomodoroCyclesCompleted: 0,
    sessionReachedTerminal: false,
  );

  final List<CompletedSegmentSemantics> completedSegments;
  final List<SkippedRestSemantics> skippedRests;
  final int? startedSegmentIndex;
  final int? counterSyncSegmentIndex;
  final int pomodoroFocusCount;
  final int pomodoroCyclesCompleted;

  /// Session entered [EnginePhase.sessionComplete] on this transition.
  final bool sessionReachedTerminal;

  bool get hasRowWrites =>
      completedSegments.isNotEmpty ||
      skippedRests.isNotEmpty ||
      startedSegmentIndex != null ||
      counterSyncSegmentIndex != null;

  /// Same row effects without marking a Segment started ([SessionSegmentWriter.appendAndStart] owns that).
  SegmentCompletionSemantics withoutStartedSegment() {
    if (startedSegmentIndex == null) {
      return this;
    }
    return SegmentCompletionSemantics(
      completedSegments: completedSegments,
      skippedRests: skippedRests,
      startedSegmentIndex: null,
      counterSyncSegmentIndex: counterSyncSegmentIndex,
      pomodoroFocusCount: pomodoroFocusCount,
      pomodoroCyclesCompleted: pomodoroCyclesCompleted,
      sessionReachedTerminal: sessionReachedTerminal,
    );
  }
}

/// Derives durable Segment effects from engine before/after snapshots.
///
/// Mirrors [TimerEngine] completion paths (tick, skip break, advance) so
/// persistence adapters do not re-interpret phase or index.
SegmentCompletionSemantics deriveSegmentCompletionSemantics({
  required TimerEngineState before,
  required TimerEngineState after,
  required DateTime nowUtc,
}) {
  final from = before.currentSegmentIndex;
  final to = after.currentSegmentIndex;

  final completed = <CompletedSegmentSemantics>[];
  final skipped = <SkippedRestSemantics>[];
  int? started;
  int? counterSync;

  int actualSecAt(int index) {
    if (index < 0 || index >= before.segments.length) {
      return 0;
    }
    final segment = before.segments[index];
    if (segment.type == SegmentType.flexible) {
      return before.elapsedActiveSecAt(nowUtc);
    }
    return segment.plannedSec;
  }

  if (from >= 0 && from < before.segments.length && from != to) {
    completed.add(
      CompletedSegmentSemantics(
        segmentIndex: from,
        actualSec: actualSecAt(from),
        segmentPausedSec: before.segmentPausedSec,
      ),
    );

    final skipEndExclusive =
        after.phase == EnginePhase.sessionComplete &&
            after.currentSegment?.isRest == true
        ? to + 1
        : to;
    for (var i = from + 1; i < skipEndExclusive; i++) {
      if (i < 0 || i >= before.segments.length) {
        break;
      }
      if (!before.segments[i].isRest) {
        continue;
      }
      skipped.add(SkippedRestSemantics(segmentIndex: i));
    }
  } else if (after.phase == EnginePhase.sessionComplete &&
      before.phase != EnginePhase.sessionComplete &&
      from == to &&
      from >= 0 &&
      from < before.segments.length) {
    completed.add(
      CompletedSegmentSemantics(
        segmentIndex: from,
        actualSec: actualSecAt(from),
        segmentPausedSec: before.segmentPausedSec,
      ),
    );
  }

  if (after.phase == EnginePhase.running && to >= 0 && from != to) {
    started = to;
  }

  if (after.phase == EnginePhase.sessionComplete ||
      after.phase == EnginePhase.segmentComplete) {
    counterSync = after.currentSegmentIndex;
  }

  return SegmentCompletionSemantics(
    completedSegments: completed,
    skippedRests: skipped,
    startedSegmentIndex: started,
    counterSyncSegmentIndex: counterSync,
    pomodoroFocusCount: after.pomodoroFocusCount,
    pomodoroCyclesCompleted: after.pomodoroCyclesCompleted,
    sessionReachedTerminal:
        after.phase == EnginePhase.sessionComplete &&
        before.phase != EnginePhase.sessionComplete,
  );
}
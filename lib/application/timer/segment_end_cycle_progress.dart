import 'package:pomodoro_app/domain/common/enums.dart';

/// Cycle progress shown on segment-end / session-complete copy.
typedef SegmentEndCycleProgress = ({int n, int total});

/// Derives user-facing cycle `{n}` / `{total}` after a Pomodoro segment ends.
///
/// [cyclesCompletedAfterSegment] must already reflect engine state *after*
/// the finished segment is applied (long rest increments the counter first).
SegmentEndCycleProgress segmentEndCycleProgress({
  required int cyclesCompletedAfterSegment,
  required int cyclesTarget,
  required SegmentType finished,
  required bool sessionComplete,
}) {
  final total = cyclesTarget;
  if (sessionComplete || finished == SegmentType.longRest) {
    return (n: cyclesCompletedAfterSegment, total: total);
  }
  return (n: cyclesCompletedAfterSegment + 1, total: total);
}

/// Predicted post-finish cycle count while [current] is still running
/// (used when scheduling the segment-end OS notification).
int cyclesCompletedAfterPredictedFinish({
  required int cyclesCompletedNow,
  required SegmentType current,
}) {
  if (current == SegmentType.longRest) {
    return cyclesCompletedNow + 1;
  }
  return cyclesCompletedNow;
}

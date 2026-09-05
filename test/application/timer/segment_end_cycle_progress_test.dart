import 'package:pomodoro_app/application/timer/segment_end_cycle_progress.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:test/test.dart';

void main() {
  group('segmentEndCycleProgress', () {
    test('mid-cycle focus uses current cycle (completed + 1)', () {
      final progress = segmentEndCycleProgress(
        cyclesCompletedAfterSegment: 0,
        cyclesTarget: 4,
        finished: SegmentType.focus,
        sessionComplete: false,
      );
      expect(progress.n, 1);
      expect(progress.total, 4);
    });

    test('long rest uses cyclesCompleted after close', () {
      final progress = segmentEndCycleProgress(
        cyclesCompletedAfterSegment: 1,
        cyclesTarget: 4,
        finished: SegmentType.longRest,
        sessionComplete: false,
      );
      expect(progress.n, 1);
      expect(progress.total, 4);
    });

    test('session complete uses cyclesCompleted', () {
      final progress = segmentEndCycleProgress(
        cyclesCompletedAfterSegment: 4,
        cyclesTarget: 4,
        finished: SegmentType.longRest,
        sessionComplete: true,
      );
      expect(progress.n, 4);
      expect(progress.total, 4);
    });

    test('default tag target stays 4 (never segment-row 32)', () {
      final progress = segmentEndCycleProgress(
        cyclesCompletedAfterSegment: 0,
        cyclesTarget: 4,
        finished: SegmentType.shortRest,
        sessionComplete: false,
      );
      expect(progress.total, 4);
      expect(progress.total, isNot(32));
    });
  });

  group('cyclesCompletedAfterPredictedFinish', () {
    test('long rest predicts +1 before engine increments', () {
      expect(
        cyclesCompletedAfterPredictedFinish(
          cyclesCompletedNow: 0,
          current: SegmentType.longRest,
        ),
        1,
      );
    });

    test('focus leaves completed unchanged', () {
      expect(
        cyclesCompletedAfterPredictedFinish(
          cyclesCompletedNow: 2,
          current: SegmentType.focus,
        ),
        2,
      );
    });
  });
}

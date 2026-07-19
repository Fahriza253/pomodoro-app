import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/domain/timeline/segment_detail_filter.dart';
import 'package:test/test.dart';

SessionSegment _segment({
  required String id,
  required int orderIndex,
  required SegmentStatus status,
}) {
  return SessionSegment(
    id: id,
    sessionId: 'session-1',
    type: SegmentType.focus,
    orderIndex: orderIndex,
    plannedSec: 1500,
    actualSec: status == SegmentStatus.pending ? 0 : 1500,
    segmentPausedSec: 0,
    segmentStatus: status,
  );
}

void main() {
  group('segmentsForTimelineDetail', () {
    test('excludes pending segments', () {
      final result = segmentsForTimelineDetail([
        _segment(id: 'a', orderIndex: 0, status: SegmentStatus.completed),
        _segment(id: 'b', orderIndex: 1, status: SegmentStatus.pending),
        _segment(id: 'c', orderIndex: 2, status: SegmentStatus.skipped),
      ]);

      expect(result, hasLength(2));
      expect(result.map((s) => s.id), ['a', 'c']);
    });

    test('sorts by orderIndex', () {
      final result = segmentsForTimelineDetail([
        _segment(id: 'c', orderIndex: 2, status: SegmentStatus.completed),
        _segment(id: 'a', orderIndex: 0, status: SegmentStatus.completed),
        _segment(id: 'b', orderIndex: 1, status: SegmentStatus.skipped),
      ]);

      expect(result.map((s) => s.orderIndex), [0, 1, 2]);
    });
  });
}

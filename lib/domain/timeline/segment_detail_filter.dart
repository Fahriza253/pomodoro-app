import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';

/// Segments visible in Timeline session detail — excludes pre-planned pending rows.
List<SessionSegment> segmentsForTimelineDetail(List<SessionSegment> segments) {
  final visible = segments
      .where((s) => s.segmentStatus != SegmentStatus.pending)
      .toList();
  visible.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  return visible;
}

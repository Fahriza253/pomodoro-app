import 'package:pomodoro_app/domain/common/enums.dart';

class SessionSegment {
  const SessionSegment({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.orderIndex,
    required this.plannedSec,
    required this.actualSec,
    required this.segmentPausedSec,
    required this.segmentStatus,
    this.startedAtUtcMs,
    this.endedAtUtcMs,
  });

  final String id;
  final String sessionId;
  final SegmentType type;
  final int orderIndex;
  final int plannedSec;
  final int actualSec;
  final int segmentPausedSec;
  final SegmentStatus segmentStatus;
  final int? startedAtUtcMs;
  final int? endedAtUtcMs;
}

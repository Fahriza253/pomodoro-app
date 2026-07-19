import 'package:pomodoro_app/domain/common/enums.dart';

/// Planned segment within a Pomodoro Session (BR-TIMER-001).
class SegmentPlan {
  const SegmentPlan({
    required this.type,
    required this.plannedSec,
    required this.orderIndex,
  });

  final SegmentType type;
  final int plannedSec;
  final int orderIndex;

  bool get isRest =>
      type == SegmentType.shortRest || type == SegmentType.longRest;

  SegmentPlan copyWith({SegmentType? type, int? plannedSec, int? orderIndex}) {
    return SegmentPlan(
      type: type ?? this.type,
      plannedSec: plannedSec ?? this.plannedSec,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SegmentPlan &&
          type == other.type &&
          plannedSec == other.plannedSec &&
          orderIndex == other.orderIndex;

  @override
  int get hashCode => Object.hash(type, plannedSec, orderIndex);
}

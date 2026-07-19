import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/domain/common/enums.dart';

/// Title + body for a Pomodoro segment transition (in-app + OS notification).
class SegmentEndCopy {
  const SegmentEndCopy({required this.title, required this.body});

  final String title;
  final String body;

  /// [completedCount] is 1-based and includes the segment that just finished.
  factory SegmentEndCopy.build({
    required NotificationStrings strings,
    required SegmentType finished,
    SegmentType? next,
    required int completedCount,
    required int totalCount,
    bool sessionComplete = false,
  }) {
    final finishedLabel = strings.segmentLabel(finished);
    final done = sessionComplete || next == null;
    if (done) {
      return SegmentEndCopy(
        title: strings.sessionCompleteTitle,
        body: strings.segmentEndBodySessionComplete(
          finishedLabel,
          completedCount,
          totalCount,
        ),
      );
    }
    return SegmentEndCopy(
      title: strings.segmentCompleteTitle(finishedLabel),
      body: strings.segmentEndBodyWithNext(
        finishedLabel,
        strings.segmentLabel(next),
        completedCount,
        totalCount,
      ),
    );
  }
}

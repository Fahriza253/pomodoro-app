import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/statistic/statistic_summary.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';

/// Aggregates session metrics (BR-STAT-001–008).
class StatsCalculator {
  const StatsCalculator();

  Set<SessionStatus> includedStatuses(AppSettings settings) {
    final included = {
      SessionStatus.completed,
      SessionStatus.abandoned,
      SessionStatus.manual,
    };
    if (settings.trackFailedSessions) {
      included.add(SessionStatus.failed);
    }
    return included;
  }

  StatisticSummary aggregate({
    required List<Session> sessions,
    required Map<String, List<SessionSegment>> segmentsBySessionId,
    required AppSettings settings,
    required Map<String, Tag> tagsById,
    String deletedTagLabel = 'Deleted tag',
  }) {
    final included = includedStatuses(settings);
    final eligible = sessions
        .where(
          (s) =>
              s.status != SessionStatus.active && included.contains(s.status),
        )
        .toList();

    var focusSec = 0;
    var breakSec = 0;
    final tagStats = <String, _TagAccumulator>{};

    for (final session in eligible) {
      final segments = segmentsBySessionId[session.id] ?? const [];
      var sessionFocus = 0;
      var sessionBreak = 0;

      for (final segment in segments) {
        if (segment.segmentStatus != SegmentStatus.completed &&
            segment.segmentStatus != SegmentStatus.skipped) {
          continue;
        }
        switch (segment.type) {
          case SegmentType.focus:
          case SegmentType.flexible:
            sessionFocus += segment.actualSec;
          case SegmentType.shortRest:
          case SegmentType.longRest:
            sessionBreak += segment.actualSec;
        }
      }

      focusSec += sessionFocus;
      breakSec += sessionBreak;

      final tag = tagsById[session.tagId];
      final acc = tagStats.putIfAbsent(
        session.tagId,
        () => _TagAccumulator(
          tagId: session.tagId,
          tagName: tag?.name ?? deletedTagLabel,
          tagColor: tag?.color ?? '#9CA3AF',
        ),
      );
      acc.sessionCount += 1;
      acc.focusDurationSec += sessionFocus;
      acc.breakDurationSec += sessionBreak;
    }

    final byTag =
        tagStats.values
            .map(
              (acc) => TagBreakdown(
                tagId: acc.tagId,
                tagName: acc.tagName,
                tagColor: acc.tagColor,
                sessionCount: acc.sessionCount,
                focusDurationSec: acc.focusDurationSec,
                breakDurationSec: acc.breakDurationSec,
              ),
            )
            .toList()
          ..sort((a, b) => b.focusDurationSec.compareTo(a.focusDurationSec));

    return StatisticSummary(
      sessionCount: eligible.length,
      focusDurationSec: focusSec,
      breakDurationSec: breakSec,
      totalDurationSec: focusSec + breakSec,
      byTag: byTag,
    );
  }
}

class _TagAccumulator {
  _TagAccumulator({
    required this.tagId,
    required this.tagName,
    required this.tagColor,
  });

  final String tagId;
  final String tagName;
  final String tagColor;
  int sessionCount = 0;
  int focusDurationSec = 0;
  int breakDurationSec = 0;
}

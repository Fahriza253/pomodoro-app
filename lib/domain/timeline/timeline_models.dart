import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';

class TimelineDay {
  const TimelineDay({
    required this.localDate,
    required this.timelineDate,
    required this.entries,
    required this.hasMore,
  });

  final DateTime localDate;
  final String timelineDate;
  final List<TimelineEntry> entries;
  final bool hasMore;
}

class TimelineEntry {
  const TimelineEntry({
    required this.sessionId,
    required this.tagId,
    required this.tagDisplayName,
    required this.tagColor,
    required this.mode,
    required this.status,
    required this.totalActiveSec,
    required this.focusDurationSec,
    required this.startedAtUtcMs,
    this.endedAtUtcMs,
  });

  final String sessionId;
  final String tagId;
  final String tagDisplayName;
  final String tagColor;
  final TimerMode mode;
  final SessionStatus status;
  final int totalActiveSec;
  final int focusDurationSec;
  final int startedAtUtcMs;
  final int? endedAtUtcMs;
}

class SessionDetail {
  const SessionDetail({
    required this.session,
    required this.segments,
    required this.tagDisplayName,
    required this.tagColor,
  });

  final Session session;
  final List<SessionSegment> segments;
  final String tagDisplayName;
  final String tagColor;
}

class TimelineDayGroup {
  const TimelineDayGroup({required this.day, required this.isEmpty});

  final TimelineDay day;
  final bool isEmpty;
}

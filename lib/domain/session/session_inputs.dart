import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';

class CreateSegmentInput {
  const CreateSegmentInput({
    required this.id,
    required this.type,
    required this.orderIndex,
    required this.plannedSec,
    this.segmentStatus = SegmentStatus.pending,
    this.startedAtUtcMs,
  });

  final String id;
  final SegmentType type;
  final int orderIndex;
  final int plannedSec;
  final SegmentStatus segmentStatus;
  final int? startedAtUtcMs;
}

class CreateSessionInput {
  const CreateSessionInput({
    required this.id,
    required this.tagId,
    required this.mode,
    required this.configSnapshot,
    required this.startedAtUtcMs,
    required this.timelineDate,
    required this.segments,
    this.pomodoroCyclesTarget,
  });

  final String id;
  final String tagId;
  final TimerMode mode;
  final ConfigSnapshot configSnapshot;
  final int startedAtUtcMs;
  final String timelineDate;
  final List<CreateSegmentInput> segments;
  final int? pomodoroCyclesTarget;
}

class UpdateSegmentInput {
  const UpdateSegmentInput({
    required this.sessionId,
    required this.segmentId,
    this.segmentStatus,
    this.actualSec,
    this.segmentPausedSec,
    this.startedAtUtcMs,
    this.endedAtUtcMs,
    this.pomodoroFocusCount,
    this.pomodoroCyclesCompleted,
    this.totalActiveSec,
    this.totalPausedSec,
    required this.updatedAtUtcMs,
  });

  final String sessionId;
  final String segmentId;
  final SegmentStatus? segmentStatus;
  final int? actualSec;
  final int? segmentPausedSec;
  final int? startedAtUtcMs;
  final int? endedAtUtcMs;
  final int? pomodoroFocusCount;
  final int? pomodoroCyclesCompleted;
  final int? totalActiveSec;
  final int? totalPausedSec;
  final int updatedAtUtcMs;
}

class FinalizeSegmentInput {
  const FinalizeSegmentInput({
    required this.segmentId,
    required this.actualSec,
    required this.segmentPausedSec,
    required this.segmentStatus,
    this.startedAtUtcMs,
    this.endedAtUtcMs,
  });

  final String segmentId;
  final int actualSec;
  final int segmentPausedSec;
  final SegmentStatus segmentStatus;
  final int? startedAtUtcMs;
  final int? endedAtUtcMs;
}

class FinalizeSessionInput {
  const FinalizeSessionInput({
    required this.sessionId,
    required this.terminalStatus,
    required this.endedAtUtcMs,
    required this.totalActiveSec,
    required this.totalPausedSec,
    required this.segments,
    required this.updatedAtUtcMs,
  });

  final String sessionId;
  final SessionStatus terminalStatus;
  final int endedAtUtcMs;
  final int totalActiveSec;
  final int totalPausedSec;
  final List<FinalizeSegmentInput> segments;
  final int updatedAtUtcMs;
}

class CreateManualSessionInput {
  const CreateManualSessionInput({
    required this.id,
    required this.tagId,
    required this.mode,
    required this.timelineDate,
    required this.startedAtUtcMs,
    required this.endedAtUtcMs,
    required this.focusDurationSec,
    required this.configSnapshot,
  });

  final String id;
  final String tagId;
  final TimerMode mode;
  final String timelineDate;
  final int startedAtUtcMs;
  final int endedAtUtcMs;
  final int focusDurationSec;
  final ConfigSnapshot configSnapshot;
}

class SessionQueryFilter {
  const SessionQueryFilter({this.tagId, this.mode, this.statuses});

  final String? tagId;
  final TimerMode? mode;
  final Set<SessionStatus>? statuses;
}

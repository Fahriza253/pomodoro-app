import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/app_database.dart' as db;
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/domain/common/enums.dart';

class SessionMapper {
  const SessionMapper();

  Session toDomain(db.SessionRow row) {
    return Session(
      id: row.id,
      tagId: row.tagId,
      mode: TimerMode.fromDb(row.mode),
      status: SessionStatus.fromDb(row.status),
      startedAtUtcMs: row.startedAt,
      endedAtUtcMs: row.endedAt,
      timelineDate: row.timelineDate,
      totalActiveSec: row.totalActiveSec,
      totalPausedSec: row.totalPausedSec,
      configSnapshot: row.configSnapshotJson,
      pomodoroFocusCount: row.pomodoroFocusCount,
      pomodoroCyclesCompleted: row.pomodoroCyclesCompleted,
      pomodoroCyclesTarget: row.pomodoroCyclesTarget,
      createdAtUtcMs: row.createdAt,
      updatedAtUtcMs: row.updatedAt,
    );
  }

  db.SessionsCompanion toCompanion(Session session) {
    return db.SessionsCompanion(
      id: Value(session.id),
      tagId: Value(session.tagId),
      mode: Value(session.mode.toDb()),
      status: Value(session.status.toDb()),
      startedAt: Value(session.startedAtUtcMs),
      endedAt: Value(session.endedAtUtcMs),
      timelineDate: Value(session.timelineDate),
      totalActiveSec: Value(session.totalActiveSec),
      totalPausedSec: Value(session.totalPausedSec),
      configSnapshotJson: Value(session.configSnapshot),
      pomodoroFocusCount: Value(session.pomodoroFocusCount),
      pomodoroCyclesCompleted: Value(session.pomodoroCyclesCompleted),
      pomodoroCyclesTarget: Value(session.pomodoroCyclesTarget),
      createdAt: Value(session.createdAtUtcMs),
      updatedAt: Value(session.updatedAtUtcMs),
    );
  }
}

class SessionSegmentMapper {
  const SessionSegmentMapper();

  SessionSegment toDomain(db.SessionSegment row) {
    return SessionSegment(
      id: row.id,
      sessionId: row.sessionId,
      type: SegmentType.fromDb(row.type),
      orderIndex: row.orderIndex,
      plannedSec: row.plannedSec,
      actualSec: row.actualSec,
      segmentPausedSec: row.segmentPausedSec,
      segmentStatus: SegmentStatus.fromDb(row.segmentStatus),
      startedAtUtcMs: row.startedAt,
      endedAtUtcMs: row.endedAt,
    );
  }

  db.SessionSegmentsCompanion toCompanion(SessionSegment segment) {
    return db.SessionSegmentsCompanion(
      id: Value(segment.id),
      sessionId: Value(segment.sessionId),
      type: Value(segment.type.toDb()),
      orderIndex: Value(segment.orderIndex),
      plannedSec: Value(segment.plannedSec),
      actualSec: Value(segment.actualSec),
      segmentPausedSec: Value(segment.segmentPausedSec),
      segmentStatus: Value(segment.segmentStatus.toDb()),
      startedAt: Value(segment.startedAtUtcMs),
      endedAt: Value(segment.endedAtUtcMs),
    );
  }
}

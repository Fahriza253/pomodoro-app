import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/app_database.dart' as db;
import 'package:pomodoro_app/data/mappers/session_mapper.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/date_range.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:uuid/uuid.dart';

abstract class SessionRepository {
  Future<Session> createSession(CreateSessionInput input);
  Future<void> updateSegmentProgress(UpdateSegmentInput input);
  Future<Session> finalizeSession(FinalizeSessionInput input);
  Future<Session> markAbandoned(String sessionId, DateTime endedAtUtc);

  /// Terminalizes an active session as [SessionStatus.completed] (recovery).
  Future<Session> markCompleted(String sessionId, DateTime endedAtUtc);

  Future<Session> createManualSession(CreateManualSessionInput input);

  /// Hard-deletes a session and its segments (BR-TIMER-026 early-stop discard).
  Future<void> deleteSession(String sessionId);

  Future<Session?> getById(String id);
  Future<Session?> getActiveSession();
  Future<List<Session>> queryByDateRange(
    DateRange range,
    SessionQueryFilter filter,
  );
  Future<List<Session>> queryByTimelineDate(
    String timelineDate, {
    int offset = 0,
    int limit = 20,
  });
  Future<int> countByTimelineDate(String timelineDate);
  Future<List<SessionSegment>> getSegmentsBySessionId(String sessionId);
  Future<Map<String, List<SessionSegment>>> getSegmentsBySessionIds(
    Iterable<String> sessionIds,
  );
  Future<int> countByDateRange(DateRange range, SessionQueryFilter filter);

  /// Appends Pomodoro extension segments (BR-TIMER-009).
  Future<void> appendSegments(
    String sessionId,
    List<CreateSegmentInput> segments, {
    int? pomodoroCyclesTarget,
  });

  Stream<Session?> watchActiveSession();
}

class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(
    db.AppDatabase database, {
    SessionMapper? sessionMapper,
    SessionSegmentMapper? segmentMapper,
    Uuid? uuid,
  }) : _db = database,
       _sessionMapper = sessionMapper ?? const SessionMapper(),
       _segmentMapper = segmentMapper ?? const SessionSegmentMapper(),
       _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final SessionMapper _sessionMapper;
  final SessionSegmentMapper _segmentMapper;
  final Uuid _uuid;

  @override
  Future<Session> createSession(CreateSessionInput input) async {
    final active = await getActiveSession();
    if (active != null) {
      throw const ConflictError(
        code: 'TIMER_ACTIVE_SESSION',
        message: 'Sesi timer sedang berjalan. Selesaikan atau hentikan dulu.',
      );
    }

    final now = input.startedAtUtcMs;
    try {
      return await _db.transaction(() async {
        await _db
            .into(_db.sessions)
            .insert(
              db.SessionsCompanion.insert(
                id: input.id,
                tagId: input.tagId,
                mode: input.mode.toDb(),
                status: Value(SessionStatus.active.toDb()),
                startedAt: input.startedAtUtcMs,
                timelineDate: input.timelineDate,
                configSnapshotJson: input.configSnapshot,
                pomodoroCyclesTarget: Value(input.pomodoroCyclesTarget),
                createdAt: now,
                updatedAt: now,
              ),
            );

        for (final segment in input.segments) {
          await _db
              .into(_db.sessionSegments)
              .insert(
                db.SessionSegmentsCompanion.insert(
                  id: segment.id,
                  sessionId: input.id,
                  type: segment.type.toDb(),
                  orderIndex: Value(segment.orderIndex),
                  plannedSec: segment.plannedSec,
                  segmentStatus: Value(segment.segmentStatus.toDb()),
                  startedAt: Value(segment.startedAtUtcMs),
                ),
              );
        }

        final created = await getById(input.id);
        if (created == null) {
          throw StorageError(
            code: 'STORAGE_WRITE_FAILED',
            message: 'Gagal membuat sesi.',
          );
        }
        return created;
      });
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal membuat sesi.',
        cause: e,
      );
    }
  }

  @override
  Future<void> updateSegmentProgress(UpdateSegmentInput input) async {
    try {
      await _db.transaction(() async {
        final segmentCompanion = db.SessionSegmentsCompanion(
          segmentStatus: input.segmentStatus == null
              ? const Value.absent()
              : Value(input.segmentStatus!.toDb()),
          actualSec: input.actualSec == null
              ? const Value.absent()
              : Value(input.actualSec!),
          segmentPausedSec: input.segmentPausedSec == null
              ? const Value.absent()
              : Value(input.segmentPausedSec!),
          startedAt: input.startedAtUtcMs == null
              ? const Value.absent()
              : Value(input.startedAtUtcMs),
          endedAt: input.endedAtUtcMs == null
              ? const Value.absent()
              : Value(input.endedAtUtcMs),
        );

        await (_db.update(_db.sessionSegments)..where(
              (t) =>
                  t.id.equals(input.segmentId) &
                  t.sessionId.equals(input.sessionId),
            ))
            .write(segmentCompanion);

        await (_db.update(
          _db.sessions,
        )..where((t) => t.id.equals(input.sessionId))).write(
          db.SessionsCompanion(
            pomodoroFocusCount: input.pomodoroFocusCount == null
                ? const Value.absent()
                : Value(input.pomodoroFocusCount!),
            pomodoroCyclesCompleted: input.pomodoroCyclesCompleted == null
                ? const Value.absent()
                : Value(input.pomodoroCyclesCompleted!),
            totalActiveSec: input.totalActiveSec == null
                ? const Value.absent()
                : Value(input.totalActiveSec!),
            totalPausedSec: input.totalPausedSec == null
                ? const Value.absent()
                : Value(input.totalPausedSec!),
            updatedAt: Value(input.updatedAtUtcMs),
          ),
        );
      });
    } catch (e) {
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal memperbarui progres segment.',
        cause: e,
      );
    }
  }

  @override
  Future<Session> finalizeSession(FinalizeSessionInput input) async {
    if (input.terminalStatus == SessionStatus.active) {
      throw const ValidationError(
        code: 'SESSION_INVALID_STATUS',
        message: 'Status terminal tidak valid.',
      );
    }

    try {
      return await _db.transaction(() async {
        for (final segment in input.segments) {
          await (_db.update(
            _db.sessionSegments,
          )..where((t) => t.id.equals(segment.segmentId))).write(
            db.SessionSegmentsCompanion(
              actualSec: Value(segment.actualSec),
              segmentPausedSec: Value(segment.segmentPausedSec),
              segmentStatus: Value(segment.segmentStatus.toDb()),
              startedAt: segment.startedAtUtcMs == null
                  ? const Value.absent()
                  : Value(segment.startedAtUtcMs),
              endedAt: segment.endedAtUtcMs == null
                  ? const Value.absent()
                  : Value(segment.endedAtUtcMs),
            ),
          );
        }

        await (_db.update(
          _db.sessions,
        )..where((t) => t.id.equals(input.sessionId))).write(
          db.SessionsCompanion(
            status: Value(input.terminalStatus.toDb()),
            endedAt: Value(input.endedAtUtcMs),
            totalActiveSec: Value(input.totalActiveSec),
            totalPausedSec: Value(input.totalPausedSec),
            updatedAt: Value(input.updatedAtUtcMs),
          ),
        );

        final session = await getById(input.sessionId);
        if (session == null || session.endedAtUtcMs == null) {
          throw StorageError(
            code: 'STORAGE_WRITE_FAILED',
            message: 'Finalisasi sesi gagal — ended_at wajib (BR-DATA-001).',
          );
        }
        return session;
      });
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal menyelesaikan sesi.',
        cause: e,
      );
    }
  }

  @override
  Future<Session> markAbandoned(String sessionId, DateTime endedAtUtc) async {
    final session = await getById(sessionId);
    if (session == null) {
      throw NotFoundError(
        code: 'SESSION_NOT_FOUND',
        message: 'Sesi tidak ditemukan.',
        details: {'sessionId': sessionId},
      );
    }

    final segments = await getSegmentsBySessionId(sessionId);
    return finalizeSession(
      FinalizeSessionInput(
        sessionId: sessionId,
        terminalStatus: SessionStatus.abandoned,
        endedAtUtcMs: endedAtUtc.toUtc().millisecondsSinceEpoch,
        totalActiveSec: session.totalActiveSec,
        totalPausedSec: session.totalPausedSec,
        updatedAtUtcMs: endedAtUtc.toUtc().millisecondsSinceEpoch,
        segments: segments
            .map(
              (s) => FinalizeSegmentInput(
                segmentId: s.id,
                actualSec: s.actualSec,
                segmentPausedSec: s.segmentPausedSec,
                // Active rows must not survive terminal abandon — Timeline
                // would otherwise show "Berjalan" with no running timer.
                segmentStatus: s.segmentStatus == SegmentStatus.active
                    ? SegmentStatus.skipped
                    : s.segmentStatus,
                startedAtUtcMs: s.startedAtUtcMs,
                endedAtUtcMs:
                    s.endedAtUtcMs ?? endedAtUtc.toUtc().millisecondsSinceEpoch,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Future<Session> markCompleted(String sessionId, DateTime endedAtUtc) async {
    final session = await getById(sessionId);
    if (session == null) {
      throw NotFoundError(
        code: 'SESSION_NOT_FOUND',
        message: 'Sesi tidak ditemukan.',
        details: {'sessionId': sessionId},
      );
    }

    final segments = await getSegmentsBySessionId(sessionId);
    final endedMs = endedAtUtc.toUtc().millisecondsSinceEpoch;
    return finalizeSession(
      FinalizeSessionInput(
        sessionId: sessionId,
        terminalStatus: SessionStatus.completed,
        endedAtUtcMs: endedMs,
        totalActiveSec: session.totalActiveSec,
        totalPausedSec: session.totalPausedSec,
        updatedAtUtcMs: endedMs,
        segments: segments
            .map(
              (s) => FinalizeSegmentInput(
                segmentId: s.id,
                actualSec: s.segmentStatus == SegmentStatus.active
                    ? (s.actualSec > 0 ? s.actualSec : s.plannedSec)
                    : s.actualSec,
                segmentPausedSec: s.segmentPausedSec,
                segmentStatus: s.segmentStatus == SegmentStatus.active
                    ? SegmentStatus.completed
                    : s.segmentStatus == SegmentStatus.pending
                    ? SegmentStatus.skipped
                    : s.segmentStatus,
                startedAtUtcMs: s.startedAtUtcMs,
                endedAtUtcMs: s.endedAtUtcMs ?? endedMs,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.sessionSegments,
      )..where((t) => t.sessionId.equals(sessionId))).go();
      final deleted = await (_db.delete(
        _db.sessions,
      )..where((t) => t.id.equals(sessionId))).go();
      if (deleted == 0) {
        throw NotFoundError(
          code: 'SESSION_NOT_FOUND',
          message: 'Sesi tidak ditemukan.',
          details: {'sessionId': sessionId},
        );
      }
    });
  }

  @override
  Future<Session> createManualSession(CreateManualSessionInput input) async {
    final segmentId = _uuid.v4();
    final now = input.endedAtUtcMs;

    try {
      return await _db.transaction(() async {
        await _db
            .into(_db.sessions)
            .insert(
              db.SessionsCompanion.insert(
                id: input.id,
                tagId: input.tagId,
                mode: input.mode.toDb(),
                status: Value(SessionStatus.manual.toDb()),
                startedAt: input.startedAtUtcMs,
                endedAt: Value(input.endedAtUtcMs),
                timelineDate: input.timelineDate,
                configSnapshotJson: input.configSnapshot,
                totalActiveSec: Value(input.focusDurationSec),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await _db
            .into(_db.sessionSegments)
            .insert(
              db.SessionSegmentsCompanion.insert(
                id: segmentId,
                sessionId: input.id,
                type: SegmentType.focus.toDb(),
                orderIndex: const Value(0),
                plannedSec: input.focusDurationSec,
                actualSec: Value(input.focusDurationSec),
                segmentStatus: Value(SegmentStatus.completed.toDb()),
                startedAt: Value(input.startedAtUtcMs),
                endedAt: Value(input.endedAtUtcMs),
              ),
            );

        final created = await getById(input.id);
        if (created == null || created.endedAtUtcMs == null) {
          throw StorageError(
            code: 'STORAGE_WRITE_FAILED',
            message: 'Gagal membuat sesi manual.',
          );
        }
        return created;
      });
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal membuat sesi manual.',
        cause: e,
      );
    }
  }

  @override
  Future<Session?> getById(String id) async {
    final row = await (_db.select(
      _db.sessions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _sessionMapper.toDomain(row);
  }

  @override
  Future<Session?> getActiveSession() async {
    final rows =
        await (_db.select(_db.sessions)
              ..where((t) => t.status.equals(SessionStatus.active.toDb()))
              ..limit(1))
            .get();
    if (rows.isEmpty) {
      return null;
    }
    return _sessionMapper.toDomain(rows.single);
  }

  @override
  Future<List<Session>> queryByDateRange(
    DateRange range,
    SessionQueryFilter filter,
  ) async {
    final query = _db.select(_db.sessions)
      ..where((t) {
        var expr =
            t.startedAt.isBiggerOrEqualValue(range.startUtcMs) &
            t.startedAt.isSmallerThanValue(range.endUtcMs);

        if (filter.tagId != null) {
          expr &= t.tagId.equals(filter.tagId!);
        }
        if (filter.mode != null) {
          expr &= t.mode.equals(filter.mode!.toDb());
        }
        if (filter.statuses != null && filter.statuses!.isNotEmpty) {
          expr &= t.status.isIn(filter.statuses!.map((s) => s.toDb()).toList());
        }
        return expr;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);

    final rows = await query.get();
    return rows.map(_sessionMapper.toDomain).toList();
  }

  @override
  Future<List<Session>> queryByTimelineDate(
    String timelineDate, {
    int offset = 0,
    int limit = 20,
  }) async {
    final rows =
        await (_db.select(_db.sessions)
              ..where((t) => t.timelineDate.equals(timelineDate))
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(limit, offset: offset))
            .get();
    return rows.map(_sessionMapper.toDomain).toList();
  }

  @override
  Future<int> countByTimelineDate(String timelineDate) async {
    final countExpr = _db.sessions.id.count();
    final query = _db.selectOnly(_db.sessions)..addColumns([countExpr]);
    query.where(_db.sessions.timelineDate.equals(timelineDate));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  @override
  Future<List<SessionSegment>> getSegmentsBySessionId(String sessionId) async {
    final rows =
        await (_db.select(_db.sessionSegments)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
            .get();
    return rows.map(_segmentMapper.toDomain).toList();
  }

  @override
  Future<Map<String, List<SessionSegment>>> getSegmentsBySessionIds(
    Iterable<String> sessionIds,
  ) async {
    final ids = sessionIds.toSet();
    if (ids.isEmpty) {
      return const {};
    }
    final rows =
        await (_db.select(_db.sessionSegments)
              ..where((t) => t.sessionId.isIn(ids))
              ..orderBy([
                (t) => OrderingTerm.asc(t.sessionId),
                (t) => OrderingTerm.asc(t.orderIndex),
              ]))
            .get();
    final map = <String, List<SessionSegment>>{};
    for (final row in rows) {
      final segment = _segmentMapper.toDomain(row);
      map.putIfAbsent(segment.sessionId, () => []).add(segment);
    }
    return map;
  }

  @override
  Future<int> countByDateRange(
    DateRange range,
    SessionQueryFilter filter,
  ) async {
    final sessions = await queryByDateRange(range, filter);
    return sessions.length;
  }

  @override
  Future<void> appendSegments(
    String sessionId,
    List<CreateSegmentInput> segments, {
    int? pomodoroCyclesTarget,
  }) async {
    if (segments.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    try {
      await _db.transaction(() async {
        for (final segment in segments) {
          await _db
              .into(_db.sessionSegments)
              .insert(
                db.SessionSegmentsCompanion.insert(
                  id: segment.id,
                  sessionId: sessionId,
                  type: segment.type.toDb(),
                  orderIndex: Value(segment.orderIndex),
                  plannedSec: segment.plannedSec,
                  segmentStatus: Value(segment.segmentStatus.toDb()),
                  startedAt: Value(segment.startedAtUtcMs),
                ),
              );
        }
        if (pomodoroCyclesTarget != null) {
          await (_db.update(
            _db.sessions,
          )..where((t) => t.id.equals(sessionId))).write(
            db.SessionsCompanion(
              pomodoroCyclesTarget: Value(pomodoroCyclesTarget),
              updatedAt: Value(now),
            ),
          );
        }
      });
    } catch (e) {
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal menambah segment sesi.',
        cause: e,
      );
    }
  }

  @override
  Stream<Session?> watchActiveSession() {
    return (_db.select(_db.sessions)
          ..where((t) => t.status.equals(SessionStatus.active.toDb()))
          ..limit(1))
        .watch()
        .map(
          (rows) => rows.isEmpty ? null : _sessionMapper.toDomain(rows.single),
        );
  }
}

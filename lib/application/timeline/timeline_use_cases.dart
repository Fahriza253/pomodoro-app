import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/domain/statistic/period_calculator.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/domain/timeline/segment_detail_filter.dart';
import 'package:pomodoro_app/domain/timeline/timeline_models.dart';

/// UC-06 — timeline list & detail (UC-08 backfill deferred).
class TimelineUseCases {
  TimelineUseCases({
    required this._sessionRepository,
    required this._tagRepository,
    PeriodCalculator? periodCalculator,
    this.deletedTagLabel = 'Deleted tag',
  }) : _periodCalculator = periodCalculator ?? const PeriodCalculator();

  static const defaultPageSize = 20;

  final SessionRepository _sessionRepository;
  final TagRepository _tagRepository;
  final PeriodCalculator _periodCalculator;
  final String deletedTagLabel;

  Future<AppResult<TimelineDay>> listByDay(
    DateTime localDate, {
    int page = 0,
    int pageSize = defaultPageSize,
  }) async {
    try {
      final timelineDate = _periodCalculator.formatTimelineDate(localDate);
      final offset = page * pageSize;
      final sessions = await _sessionRepository.queryByTimelineDate(
        timelineDate,
        offset: offset,
        limit: pageSize + 1,
      );
      final hasMore = sessions.length > pageSize;
      final pageSessions = hasMore ? sessions.sublist(0, pageSize) : sessions;

      final segmentsBySessionId = await _sessionRepository
          .getSegmentsBySessionIds(pageSessions.map((s) => s.id));
      final tagsById = await _tagRepository.getByIds(
        pageSessions.map((s) => s.tagId),
      );

      final entries = pageSessions
          .map(
            (session) => _toEntry(
              session,
              segmentsBySessionId[session.id] ?? const [],
              tagsById[session.tagId],
            ),
          )
          .toList();

      return ok(
        TimelineDay(
          localDate: DateTime(localDate.year, localDate.month, localDate.day),
          timelineDate: timelineDate,
          entries: entries,
          hasMore: hasMore,
        ),
      );
    } on AppError catch (e) {
      return err(e);
    }
  }

  Future<AppResult<List<TimelineDayGroup>>> listRecentDays({
    int dayCount = 14,
    int sessionsPerDay = defaultPageSize,
  }) async {
    try {
      final today = DateTime.now();
      final groups = <TimelineDayGroup>[];
      for (var i = 0; i < dayCount; i++) {
        final date = today.subtract(Duration(days: i));
        final result = await listByDay(date, pageSize: sessionsPerDay);
        if (result.isErr) {
          return err(result.error!);
        }
        final day = result.value!;
        groups.add(TimelineDayGroup(day: day, isEmpty: day.entries.isEmpty));
      }
      return ok(groups);
    } on AppError catch (e) {
      return err(e);
    }
  }

  Future<AppResult<SessionDetail>> getSessionDetail(String sessionId) async {
    try {
      final session = await _sessionRepository.getById(sessionId);
      if (session == null) {
        return err(
          NotFoundError(
            code: 'SESSION_NOT_FOUND',
            message: 'Sesi tidak ditemukan.',
            details: {'sessionId': sessionId},
          ),
        );
      }
      final segments = await _sessionRepository.getSegmentsBySessionId(
        sessionId,
      );
      final tag = await _tagRepository.getById(session.tagId);
      return ok(
        SessionDetail(
          session: session,
          segments: segmentsForTimelineDetail(segments),
          tagDisplayName: tag?.name ?? deletedTagLabel,
          tagColor: tag?.color ?? '#9CA3AF',
        ),
      );
    } on AppError catch (e) {
      return err(e);
    }
  }

  Future<AppResult<void>> createManualSession(
    CreateManualSessionInput input,
  ) async {
    // ponytail: UC-08 out of v1.0 — repo path exists; enable when form ships.
    return err(
      const ValidationError(
        code: 'MANUAL_BACKFILL_DISABLED',
        message: 'Manual session backfill is not available in this version.',
      ),
    );
  }

  TimelineEntry _toEntry(
    Session session,
    List<SessionSegment> segments,
    Tag? tag,
  ) {
    return TimelineEntry(
      sessionId: session.id,
      tagId: session.tagId,
      tagDisplayName: tag?.name ?? deletedTagLabel,
      tagColor: tag?.color ?? '#9CA3AF',
      mode: session.mode,
      status: session.status,
      totalActiveSec: session.totalActiveSec,
      focusDurationSec: _focusDurationSec(segments),
      startedAtUtcMs: session.startedAtUtcMs,
      endedAtUtcMs: session.endedAtUtcMs,
    );
  }

  int _focusDurationSec(List<SessionSegment> segments) {
    var total = 0;
    for (final segment in segments) {
      if (segment.type != SegmentType.focus &&
          segment.type != SegmentType.flexible) {
        continue;
      }
      if (segment.segmentStatus == SegmentStatus.completed ||
          segment.segmentStatus == SegmentStatus.skipped) {
        total += segment.actualSec;
      }
    }
    return total;
  }
}

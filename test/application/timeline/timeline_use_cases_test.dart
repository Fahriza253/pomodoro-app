import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/application/timeline/timeline_use_cases.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/statistic/period_calculator.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:uuid/uuid.dart';

import '../../data/test_database.dart';

void main() {
  group('TimelineUseCases', () {
    late DriftSessionRepository sessionRepository;
    late DriftTagRepository tagRepository;
    late TimelineUseCases useCases;
    final uuid = const Uuid();
    final periodCalculator = const PeriodCalculator();

    setUp(() async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      sessionRepository = DriftSessionRepository(db);
      tagRepository = DriftTagRepository(db);
      useCases = TimelineUseCases(
        sessionRepository: sessionRepository,
        tagRepository: tagRepository,
        periodCalculator: periodCalculator,
      );
    });

    test('listByDay returns sessions for timeline_date', () async {
      final tags = await tagRepository.listActiveOrdered();
      final tagId = tags.first.id;
      final now = DateTime.now();
      final timelineDate = periodCalculator.formatTimelineDate(now);
      final started = now.toUtc().millisecondsSinceEpoch;

      await sessionRepository.createManualSession(
        CreateManualSessionInput(
          id: uuid.v4(),
          tagId: tagId,
          mode: TimerMode.pomodoro,
          timelineDate: timelineDate,
          startedAtUtcMs: started,
          endedAtUtcMs: started + 1500,
          focusDurationSec: 1500,
          configSnapshot: const ConfigSnapshot(mode: TimerMode.pomodoro),
        ),
      );

      final result = await useCases.listByDay(now);
      expect(result.isOk, isTrue);
      expect(result.value!.entries, isNotEmpty);
      expect(result.value!.timelineDate, timelineDate);
    });

    test('createManualSession blocked when backfill skipped', () async {
      final result = await useCases.createManualSession(
        CreateManualSessionInput(
          id: uuid.v4(),
          tagId: 'x',
          mode: TimerMode.pomodoro,
          timelineDate: '2026-06-01',
          startedAtUtcMs: 1,
          endedAtUtcMs: 2,
          focusDurationSec: 60,
          configSnapshot: const ConfigSnapshot(mode: TimerMode.pomodoro),
        ),
      );
      expect(result.isErr, isTrue);
      expect(result.error!.code, 'MANUAL_BACKFILL_DISABLED');
    });

    test('getSessionDetail excludes pending pre-planned segments', () async {
      final tags = await tagRepository.listActiveOrdered();
      final tagId = tags.first.id;
      final sessionId = uuid.v4();
      final started = DateTime.utc(2026, 6, 28, 10).millisecondsSinceEpoch;
      final ended = started + 3600;

      final segmentIds = List.generate(5, (_) => uuid.v4());

      await sessionRepository.createSession(
        CreateSessionInput(
          id: sessionId,
          tagId: tagId,
          mode: TimerMode.pomodoro,
          configSnapshot: ConfigSnapshot.pomodoroDefaults(),
          startedAtUtcMs: started,
          timelineDate: '2026-06-28',
          pomodoroCyclesTarget: 4,
          segments: [
            CreateSegmentInput(
              id: segmentIds[0],
              type: SegmentType.focus,
              orderIndex: 0,
              plannedSec: 1500,
              segmentStatus: SegmentStatus.completed,
              startedAtUtcMs: started,
            ),
            CreateSegmentInput(
              id: segmentIds[1],
              type: SegmentType.shortRest,
              orderIndex: 1,
              plannedSec: 300,
              segmentStatus: SegmentStatus.skipped,
            ),
            CreateSegmentInput(
              id: segmentIds[2],
              type: SegmentType.focus,
              orderIndex: 2,
              plannedSec: 1500,
              segmentStatus: SegmentStatus.completed,
            ),
            CreateSegmentInput(
              id: segmentIds[3],
              type: SegmentType.shortRest,
              orderIndex: 3,
              plannedSec: 300,
              segmentStatus: SegmentStatus.pending,
            ),
            CreateSegmentInput(
              id: segmentIds[4],
              type: SegmentType.focus,
              orderIndex: 4,
              plannedSec: 1500,
              segmentStatus: SegmentStatus.pending,
            ),
          ],
        ),
      );

      await sessionRepository.finalizeSession(
        FinalizeSessionInput(
          sessionId: sessionId,
          terminalStatus: SessionStatus.abandoned,
          endedAtUtcMs: ended,
          totalActiveSec: 3000,
          totalPausedSec: 0,
          updatedAtUtcMs: ended,
          segments: [
            FinalizeSegmentInput(
              segmentId: segmentIds[0],
              actualSec: 1500,
              segmentPausedSec: 0,
              segmentStatus: SegmentStatus.completed,
              startedAtUtcMs: started,
              endedAtUtcMs: started + 1500,
            ),
            FinalizeSegmentInput(
              segmentId: segmentIds[1],
              actualSec: 0,
              segmentPausedSec: 0,
              segmentStatus: SegmentStatus.skipped,
              endedAtUtcMs: started + 1500,
            ),
            FinalizeSegmentInput(
              segmentId: segmentIds[2],
              actualSec: 1500,
              segmentPausedSec: 0,
              segmentStatus: SegmentStatus.completed,
              endedAtUtcMs: ended,
            ),
            FinalizeSegmentInput(
              segmentId: segmentIds[3],
              actualSec: 0,
              segmentPausedSec: 0,
              segmentStatus: SegmentStatus.pending,
            ),
            FinalizeSegmentInput(
              segmentId: segmentIds[4],
              actualSec: 0,
              segmentPausedSec: 0,
              segmentStatus: SegmentStatus.pending,
            ),
          ],
        ),
      );

      final result = await useCases.getSessionDetail(sessionId);
      expect(result.isOk, isTrue);
      expect(result.value!.segments, hasLength(3));
      expect(result.value!.segments.map((s) => s.segmentStatus), [
        SegmentStatus.completed,
        SegmentStatus.skipped,
        SegmentStatus.completed,
      ]);
    });
  });
}

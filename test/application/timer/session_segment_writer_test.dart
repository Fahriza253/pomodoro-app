import 'package:pomodoro_app/application/timer/session_segment_writer.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../data/test_database.dart';

void main() {
  const uuid = Uuid();

  group('SessionSegmentWriter.syncOnTransition', () {
    late FakeClockAdapter clock;
    late AppDatabase db;
    late SessionRepository sessions;
    late SessionSegmentWriter writer;
    late String tagId;

    setUp(() async {
      clock = FakeClockAdapter(DateTime.utc(2026, 6, 28, 10));
      db = await openTestDatabase();
      tagId = await generalTagId(db);
      sessions = DriftSessionRepository(db);
      writer = SessionSegmentWriter(
        sessionRepository: sessions,
        clock: clock,
      );
    });

    tearDown(() async {
      await db.close();
    });

    Future<({String sessionId, List<String> segmentIds})> seedPomodoro({
      required List<SegmentPlan> plans,
      int activeIndex = 0,
    }) async {
      final sessionId = uuid.v4();
      final segmentIds = List.generate(plans.length, (_) => uuid.v4());
      final nowMs = clock.nowUtc().millisecondsSinceEpoch;
      await sessions.createSession(
        CreateSessionInput(
          id: sessionId,
          tagId: tagId,
          mode: TimerMode.pomodoro,
          configSnapshot: ConfigSnapshot.pomodoroDefaults(),
          startedAtUtcMs: nowMs,
          timelineDate: '2026-06-28',
          pomodoroCyclesTarget: 2,
          segments: [
            for (var i = 0; i < plans.length; i++)
              CreateSegmentInput(
                id: segmentIds[i],
                type: plans[i].type,
                orderIndex: plans[i].orderIndex,
                plannedSec: plans[i].plannedSec,
                segmentStatus: i == activeIndex
                    ? SegmentStatus.active
                    : SegmentStatus.pending,
                startedAtUtcMs: i == activeIndex ? nowMs : null,
              ),
          ],
        ),
      );
      return (sessionId: sessionId, segmentIds: segmentIds);
    }

    test('skip pending rests marks jumped rests skipped with actualSec 0', () async {
      final plans = [
        const SegmentPlan(type: SegmentType.focus, plannedSec: 30, orderIndex: 0),
        const SegmentPlan(
          type: SegmentType.shortRest,
          plannedSec: 10,
          orderIndex: 1,
        ),
        const SegmentPlan(type: SegmentType.focus, plannedSec: 30, orderIndex: 2),
      ];
      final seeded = await seedPomodoro(plans: plans);
      final sessionStarted = clock.nowUtc();

      final before = TimerEngineState(
        phase: EnginePhase.segmentComplete,
        mode: TimerMode.pomodoro,
        config: ConfigSnapshot.pomodoroDefaults(),
        segments: plans,
        currentSegmentIndex: 0,
        pomodoroFocusCount: 1,
        pomodoroCyclesCompleted: 0,
        pomodoroCyclesTarget: 2,
        segmentStartedAtUtc: sessionStarted,
        sessionStartedAtUtc: sessionStarted,
      );
      final after = before.copyWith(
        phase: EnginePhase.running,
        currentSegmentIndex: 2,
        segmentStartedAtUtc: sessionStarted,
      );

      await writer.syncOnTransition(
        sessionId: seeded.sessionId,
        segmentIds: seeded.segmentIds,
        before: before,
        after: after,
        totalActiveSec: 30,
        totalPausedSec: 0,
      );

      final segs = await sessions.getSegmentsBySessionId(seeded.sessionId);
      final shortRest = segs.firstWhere((s) => s.type == SegmentType.shortRest);
      expect(shortRest.segmentStatus, SegmentStatus.skipped);
      expect(shortRest.actualSec, 0);

      final focus0 = segs.firstWhere((s) => s.id == seeded.segmentIds[0]);
      expect(focus0.segmentStatus, SegmentStatus.completed);
      expect(focus0.actualSec, 30);

      final focus2 = segs.firstWhere((s) => s.id == seeded.segmentIds[2]);
      expect(focus2.segmentStatus, SegmentStatus.active);
    });

    test(
      'last Segment complete without index advance marks current completed',
      () async {
        final plans = [
          const SegmentPlan(
            type: SegmentType.focus,
            plannedSec: 30,
            orderIndex: 0,
          ),
          const SegmentPlan(
            type: SegmentType.longRest,
            plannedSec: 20,
            orderIndex: 1,
          ),
        ];
        final seeded = await seedPomodoro(plans: plans, activeIndex: 1);
        final sessionStarted = clock.nowUtc();

        final before = TimerEngineState(
          phase: EnginePhase.running,
          mode: TimerMode.pomodoro,
          config: ConfigSnapshot.pomodoroDefaults(),
          segments: plans,
          currentSegmentIndex: 1,
          pomodoroFocusCount: 1,
          pomodoroCyclesCompleted: 1,
          pomodoroCyclesTarget: 1,
          segmentStartedAtUtc: sessionStarted,
          sessionStartedAtUtc: sessionStarted,
        );
        final after = before.copyWith(
          phase: EnginePhase.sessionComplete,
          pomodoroCyclesCompleted: 1,
        );

        await writer.syncOnTransition(
          sessionId: seeded.sessionId,
          segmentIds: seeded.segmentIds,
          before: before,
          after: after,
          totalActiveSec: 50,
          totalPausedSec: 0,
        );

        final segs = await sessions.getSegmentsBySessionId(seeded.sessionId);
        final longRest = segs.firstWhere((s) => s.type == SegmentType.longRest);
        expect(longRest.segmentStatus, SegmentStatus.completed);
        expect(longRest.actualSec, 20);
      },
    );

    test(
      'Flexible complete without index advance uses elapsed active actualSec',
      () async {
        final sessionId = uuid.v4();
        final segmentId = uuid.v4();
        final sessionStarted = clock.nowUtc();
        final nowMs = sessionStarted.millisecondsSinceEpoch;
        const plan = SegmentPlan(
          type: SegmentType.flexible,
          plannedSec: 0,
          orderIndex: 0,
        );
        await sessions.createSession(
          CreateSessionInput(
            id: sessionId,
            tagId: tagId,
            mode: TimerMode.flexible,
            configSnapshot: ConfigSnapshot.flexibleDefaults(),
            startedAtUtcMs: nowMs,
            timelineDate: '2026-06-28',
            segments: [
              CreateSegmentInput(
                id: segmentId,
                type: SegmentType.flexible,
                orderIndex: 0,
                plannedSec: 0,
                segmentStatus: SegmentStatus.active,
                startedAtUtcMs: nowMs,
              ),
            ],
          ),
        );

        clock.advanceSeconds(120);
        final before = TimerEngineState(
          phase: EnginePhase.running,
          mode: TimerMode.flexible,
          config: ConfigSnapshot.flexibleDefaults(),
          segments: const [plan],
          currentSegmentIndex: 0,
          segmentStartedAtUtc: sessionStarted,
          sessionStartedAtUtc: sessionStarted,
        );
        final after = before.copyWith(phase: EnginePhase.sessionComplete);

        await writer.syncOnTransition(
          sessionId: sessionId,
          segmentIds: [segmentId],
          before: before,
          after: after,
          totalActiveSec: 120,
          totalPausedSec: 0,
        );

        final segs = await sessions.getSegmentsBySessionId(sessionId);
        expect(segs.single.segmentStatus, SegmentStatus.completed);
        expect(segs.single.actualSec, 120);
      },
    );
  });
}

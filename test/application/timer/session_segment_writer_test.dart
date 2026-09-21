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

  group('SessionSegmentWriter.writeTerminal', () {
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

    test(
      'completed finalizes current Segment plannedSec; pending rests stay pending',
      () async {
        final sessionId = uuid.v4();
        final focusId = uuid.v4();
        final restId = uuid.v4();
        final sessionStarted = clock.nowUtc();
        final nowMs = sessionStarted.millisecondsSinceEpoch;
        final plans = [
          const SegmentPlan(
            type: SegmentType.focus,
            plannedSec: 30,
            orderIndex: 0,
          ),
          const SegmentPlan(
            type: SegmentType.shortRest,
            plannedSec: 10,
            orderIndex: 1,
          ),
        ];
        await sessions.createSession(
          CreateSessionInput(
            id: sessionId,
            tagId: tagId,
            mode: TimerMode.pomodoro,
            configSnapshot: ConfigSnapshot.pomodoroDefaults(),
            startedAtUtcMs: nowMs,
            timelineDate: '2026-06-28',
            pomodoroCyclesTarget: 1,
            segments: [
              CreateSegmentInput(
                id: focusId,
                type: SegmentType.focus,
                orderIndex: 0,
                plannedSec: 30,
                segmentStatus: SegmentStatus.active,
                startedAtUtcMs: nowMs,
              ),
              CreateSegmentInput(
                id: restId,
                type: SegmentType.shortRest,
                orderIndex: 1,
                plannedSec: 10,
                segmentStatus: SegmentStatus.pending,
              ),
            ],
          ),
        );

        final state = TimerEngineState(
          phase: EnginePhase.sessionComplete,
          mode: TimerMode.pomodoro,
          config: ConfigSnapshot.pomodoroDefaults(),
          segments: plans,
          currentSegmentIndex: 0,
          pomodoroFocusCount: 1,
          pomodoroCyclesCompleted: 1,
          pomodoroCyclesTarget: 1,
          segmentStartedAtUtc: sessionStarted,
          sessionStartedAtUtc: sessionStarted,
        );

        await writer.writeTerminal(
          sessionId: sessionId,
          segmentIds: [focusId, restId],
          state: state,
          terminalStatus: SessionStatus.completed,
          totalActiveSec: 30,
          totalPausedSec: 0,
        );

        final session = await sessions.getById(sessionId);
        expect(session!.status, SessionStatus.completed);
        expect(session.endedAtUtcMs, nowMs);
        expect(session.totalActiveSec, 30);

        final segs = await sessions.getSegmentsBySessionId(sessionId);
        final focus = segs.firstWhere((s) => s.id == focusId);
        expect(focus.segmentStatus, SegmentStatus.completed);
        expect(focus.actualSec, 30);
        expect(focus.endedAtUtcMs, nowMs);

        final rest = segs.firstWhere((s) => s.id == restId);
        expect(rest.segmentStatus, SegmentStatus.pending);
        expect(rest.actualSec, 0);
      },
    );

    test(
      'abandoned completes current with elapsed active; pending become skipped',
      () async {
        final sessionId = uuid.v4();
        final focusId = uuid.v4();
        final restId = uuid.v4();
        final sessionStarted = clock.nowUtc();
        final nowMs = sessionStarted.millisecondsSinceEpoch;
        final plans = [
          const SegmentPlan(
            type: SegmentType.focus,
            plannedSec: 1500,
            orderIndex: 0,
          ),
          const SegmentPlan(
            type: SegmentType.shortRest,
            plannedSec: 300,
            orderIndex: 1,
          ),
        ];
        await sessions.createSession(
          CreateSessionInput(
            id: sessionId,
            tagId: tagId,
            mode: TimerMode.pomodoro,
            configSnapshot: ConfigSnapshot.pomodoroDefaults(),
            startedAtUtcMs: nowMs,
            timelineDate: '2026-06-28',
            pomodoroCyclesTarget: 1,
            segments: [
              CreateSegmentInput(
                id: focusId,
                type: SegmentType.focus,
                orderIndex: 0,
                plannedSec: 1500,
                segmentStatus: SegmentStatus.active,
                startedAtUtcMs: nowMs,
              ),
              CreateSegmentInput(
                id: restId,
                type: SegmentType.shortRest,
                orderIndex: 1,
                plannedSec: 300,
                segmentStatus: SegmentStatus.pending,
              ),
            ],
          ),
        );

        clock.advanceSeconds(90);
        final state = TimerEngineState(
          phase: EnginePhase.running,
          mode: TimerMode.pomodoro,
          config: ConfigSnapshot.pomodoroDefaults(),
          segments: plans,
          currentSegmentIndex: 0,
          pomodoroFocusCount: 0,
          pomodoroCyclesCompleted: 0,
          pomodoroCyclesTarget: 1,
          segmentStartedAtUtc: sessionStarted,
          sessionStartedAtUtc: sessionStarted,
        );

        await writer.writeTerminal(
          sessionId: sessionId,
          segmentIds: [focusId, restId],
          state: state,
          terminalStatus: SessionStatus.abandoned,
          totalActiveSec: 90,
          totalPausedSec: 0,
        );

        final session = await sessions.getById(sessionId);
        expect(session!.status, SessionStatus.abandoned);

        final segs = await sessions.getSegmentsBySessionId(sessionId);
        final focus = segs.firstWhere((s) => s.id == focusId);
        expect(focus.segmentStatus, SegmentStatus.completed);
        expect(focus.actualSec, 90);

        final rest = segs.firstWhere((s) => s.id == restId);
        expect(rest.segmentStatus, SegmentStatus.skipped);
        expect(rest.actualSec, 0);
      },
    );

    test(
      'failed skips pending like abandoned; current keeps elapsed active',
      () async {
        final sessionId = uuid.v4();
        final focusId = uuid.v4();
        final restId = uuid.v4();
        final sessionStarted = clock.nowUtc();
        final nowMs = sessionStarted.millisecondsSinceEpoch;
        final plans = [
          const SegmentPlan(
            type: SegmentType.focus,
            plannedSec: 1500,
            orderIndex: 0,
          ),
          const SegmentPlan(
            type: SegmentType.shortRest,
            plannedSec: 300,
            orderIndex: 1,
          ),
        ];
        await sessions.createSession(
          CreateSessionInput(
            id: sessionId,
            tagId: tagId,
            mode: TimerMode.pomodoro,
            configSnapshot: ConfigSnapshot.pomodoroDefaults(),
            startedAtUtcMs: nowMs,
            timelineDate: '2026-06-28',
            pomodoroCyclesTarget: 1,
            segments: [
              CreateSegmentInput(
                id: focusId,
                type: SegmentType.focus,
                orderIndex: 0,
                plannedSec: 1500,
                segmentStatus: SegmentStatus.active,
                startedAtUtcMs: nowMs,
              ),
              CreateSegmentInput(
                id: restId,
                type: SegmentType.shortRest,
                orderIndex: 1,
                plannedSec: 300,
                segmentStatus: SegmentStatus.pending,
              ),
            ],
          ),
        );

        clock.advanceSeconds(45);
        final state = TimerEngineState(
          phase: EnginePhase.running,
          mode: TimerMode.pomodoro,
          config: ConfigSnapshot.pomodoroDefaults(),
          segments: plans,
          currentSegmentIndex: 0,
          segmentStartedAtUtc: sessionStarted,
          sessionStartedAtUtc: sessionStarted,
        );

        await writer.writeTerminal(
          sessionId: sessionId,
          segmentIds: [focusId, restId],
          state: state,
          terminalStatus: SessionStatus.failed,
          totalActiveSec: 45,
          totalPausedSec: 0,
        );

        final session = await sessions.getById(sessionId);
        expect(session!.status, SessionStatus.failed);

        final segs = await sessions.getSegmentsBySessionId(sessionId);
        expect(
          segs.firstWhere((s) => s.id == focusId).actualSec,
          45,
        );
        expect(
          segs.firstWhere((s) => s.id == restId).segmentStatus,
          SegmentStatus.skipped,
        );
      },
    );

    test(
      'completed Flexible uses elapsed active as current Segment actualSec',
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

        clock.advanceSeconds(200);
        final state = TimerEngineState(
          phase: EnginePhase.sessionComplete,
          mode: TimerMode.flexible,
          config: ConfigSnapshot.flexibleDefaults(),
          segments: const [plan],
          currentSegmentIndex: 0,
          segmentStartedAtUtc: sessionStarted,
          sessionStartedAtUtc: sessionStarted,
        );

        await writer.writeTerminal(
          sessionId: sessionId,
          segmentIds: [segmentId],
          state: state,
          terminalStatus: SessionStatus.completed,
          totalActiveSec: 200,
          totalPausedSec: 0,
        );

        final segs = await sessions.getSegmentsBySessionId(sessionId);
        expect(segs.single.segmentStatus, SegmentStatus.completed);
        expect(segs.single.actualSec, 200);
      },
    );
  });

  group('SessionSegmentWriter.appendAndStart', () {
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

    test(
      'persists Lanjutkan create inputs and marks new Segment active',
      () async {
        final sessionId = uuid.v4();
        final focus0Id = uuid.v4();
        final rest0Id = uuid.v4();
        final focus1Id = uuid.v4();
        final rest1Id = uuid.v4();
        final sessionStarted = clock.nowUtc();
        final nowMs = sessionStarted.millisecondsSinceEpoch;
        await sessions.createSession(
          CreateSessionInput(
            id: sessionId,
            tagId: tagId,
            mode: TimerMode.pomodoro,
            configSnapshot: ConfigSnapshot.pomodoroDefaults(),
            startedAtUtcMs: nowMs,
            timelineDate: '2026-06-28',
            pomodoroCyclesTarget: 1,
            segments: [
              CreateSegmentInput(
                id: focus0Id,
                type: SegmentType.focus,
                orderIndex: 0,
                plannedSec: 30,
                segmentStatus: SegmentStatus.completed,
                startedAtUtcMs: nowMs,
              ),
              CreateSegmentInput(
                id: rest0Id,
                type: SegmentType.longRest,
                orderIndex: 1,
                plannedSec: 20,
                segmentStatus: SegmentStatus.completed,
                startedAtUtcMs: nowMs,
              ),
            ],
          ),
        );

        final newInputs = [
          CreateSegmentInput(
            id: focus1Id,
            type: SegmentType.focus,
            orderIndex: 2,
            plannedSec: 30,
          ),
          CreateSegmentInput(
            id: rest1Id,
            type: SegmentType.longRest,
            orderIndex: 3,
            plannedSec: 20,
          ),
        ];
        final afterPlans = [
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
          const SegmentPlan(
            type: SegmentType.focus,
            plannedSec: 30,
            orderIndex: 2,
          ),
          const SegmentPlan(
            type: SegmentType.longRest,
            plannedSec: 20,
            orderIndex: 3,
          ),
        ];
        final state = TimerEngineState(
          phase: EnginePhase.running,
          mode: TimerMode.pomodoro,
          config: ConfigSnapshot.pomodoroDefaults(),
          segments: afterPlans,
          currentSegmentIndex: 2,
          pomodoroFocusCount: 1,
          pomodoroCyclesCompleted: 1,
          pomodoroCyclesTarget: 2,
          segmentStartedAtUtc: sessionStarted,
          sessionStartedAtUtc: sessionStarted,
        );

        await writer.appendAndStart(
          sessionId: sessionId,
          newSegments: newInputs,
          pomodoroCyclesTarget: 2,
          activeSegmentId: focus1Id,
          state: state,
          totalActiveSec: 50,
          totalPausedSec: 0,
        );

        final session = await sessions.getById(sessionId);
        expect(session!.pomodoroCyclesTarget, 2);

        final segs = await sessions.getSegmentsBySessionId(sessionId);
        expect(segs, hasLength(4));
        final newFocus = segs.firstWhere((s) => s.id == focus1Id);
        expect(newFocus.segmentStatus, SegmentStatus.active);
        expect(newFocus.startedAtUtcMs, nowMs);
        expect(newFocus.plannedSec, 30);

        final newRest = segs.firstWhere((s) => s.id == rest1Id);
        expect(newRest.segmentStatus, SegmentStatus.pending);
        expect(newRest.plannedSec, 20);
      },
    );
  });
}

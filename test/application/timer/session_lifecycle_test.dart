import 'package:pomodoro_app/application/timer/persist_reason.dart';
import 'package:pomodoro_app/application/timer/session_lifecycle.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:test/test.dart';

import '../../data/test_database.dart';

void main() {
  group('SessionLifecycle', () {
    late FakeClockAdapter clock;
    late AppDatabase db;
    late SessionRepository sessions;
    late ActiveTimerStateRepository activeState;
    late TagRepository tags;
    late SessionLifecycle lifecycle;
    late String tagId;

    setUp(() async {
      clock = FakeClockAdapter();
      db = await openTestDatabase();
      tagId = await generalTagId(db);
      sessions = DriftSessionRepository(db);
      activeState = DriftActiveTimerStateRepository(db);
      tags = DriftTagRepository(db);
      lifecycle = SessionLifecycle(
        sessionRepository: sessions,
        tagRepository: tags,
        activeTimerStateRepository: activeState,
        clock: clock,
      );
    });

    tearDown(() {
      lifecycle.dispose();
    });

    Future<void> shortFocusTag({
      int focusSec = 30,
      int shortBreakSec = 10,
      int sessionsBeforeLong = 2,
      int totalCycles = 2,
    }) async {
      final general = await tags.getById(tagId);
      await tags.update(
        UpdateTagInput(
          id: tagId,
          name: general!.name,
          color: general.color,
          pomodoro: TagModeConfigPomodoro(
            focusDurationSec: focusSec,
            shortBreakDurationSec: shortBreakSec,
            longBreakDurationSec: 20,
            sessionsBeforeLongBreak: sessionsBeforeLong,
            totalCycles: totalCycles,
          ),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );
    }

    Future<void> runToPomodoroSessionComplete() async {
      await shortFocusTag(sessionsBeforeLong: 1, totalCycles: 2);
      await lifecycle.startPomodoro(tagId);

      for (var i = 0; i < 40; i++) {
        final phase = lifecycle.currentState.phase;
        if (phase == EnginePhase.sessionComplete) {
          return;
        }
        if (phase == EnginePhase.running) {
          final planned = lifecycle.currentState.currentSegment!.plannedSec;
          clock.advanceSeconds(planned);
          await lifecycle.tick();
          continue;
        }
        if (phase == EnginePhase.segmentComplete) {
          await lifecycle.advanceSegment();
          continue;
        }
        fail('unexpected phase while driving Pomodoro: $phase');
      }
      fail('timed out waiting for sessionComplete');
    }

    test('startPomodoro creates active session and persists state', () async {
      final result = await lifecycle.startPomodoro(tagId);

      expect(result.after.phase, EnginePhase.running);
      expect(result.sessionId, isNotNull);

      final active = await sessions.getActiveSession();
      expect(active, isNotNull);
      expect(active!.mode, TimerMode.pomodoro);

      final persisted = await activeState.get();
      expect(persisted, isNotNull);
      expect(persisted!.enginePhase, EnginePhase.running);
      expect(lifecycle.hasActiveSession, isTrue);
    });

    test('startPomodoro rejects when session already active', () async {
      await lifecycle.startPomodoro(tagId);
      try {
        await lifecycle.startPomodoro(tagId);
        fail('expected ConflictError');
      } on ConflictError catch (e) {
        expect(e.code, 'TIMER_ACTIVE_SESSION');
      }
    });

    test('pause and resume persist phase transitions', () async {
      await lifecycle.startPomodoro(tagId);
      final paused = await lifecycle.pause();
      expect(paused.after.phase, EnginePhase.paused);
      expect((await activeState.get())!.enginePhase, EnginePhase.paused);

      final resumed = await lifecycle.resume();
      expect(resumed.after.phase, EnginePhase.running);
      expect((await activeState.get())!.enginePhase, EnginePhase.running);
    });

    test(
      'stop within early-stop grace discards session without abandon',
      () async {
        await lifecycle.startPomodoro(tagId);
        final sessionId = (await sessions.getActiveSession())!.id;
        clock.advanceSeconds(3);

        final result = await lifecycle.stop();
        expect(result.after.phase, EnginePhase.idle);
        expect(await sessions.getActiveSession(), isNull);
        expect(await sessions.getById(sessionId), isNull);
        expect(await activeState.get(), isNull);
      },
    );

    test('stop after grace abandons session', () async {
      await lifecycle.startPomodoro(tagId);
      final sessionId = (await sessions.getActiveSession())!.id;
      clock.advanceSeconds(12);

      final result = await lifecycle.stop();
      expect(result.after.phase, EnginePhase.idle);
      expect(await sessions.getActiveSession(), isNull);
      final finalized = await sessions.getById(sessionId);
      expect(finalized, isNotNull);
      expect(finalized!.status, SessionStatus.abandoned);
      expect(finalized.endedAtUtcMs, isNotNull);
    });

    test('stop mid-focus records elapsed actualSec on segment', () async {
      await lifecycle.startPomodoro(tagId);
      clock.advanceSeconds(120);
      final sessionId = (await sessions.getActiveSession())!.id;

      await lifecycle.stop();

      final segments = await sessions.getSegmentsBySessionId(sessionId);
      final focus = segments.firstWhere((s) => s.type == SegmentType.focus);
      expect(focus.actualSec, 120);
      expect(focus.segmentStatus, SegmentStatus.completed);

      final session = await sessions.getById(sessionId);
      expect(session!.status, SessionStatus.abandoned);
    });

    test('resumeFromPersisted restores engine phase', () async {
      await lifecycle.startPomodoro(tagId);
      await lifecycle.pause();
      final persisted = await activeState.get();
      lifecycle.dispose();

      final fresh = SessionLifecycle(
        sessionRepository: sessions,
        tagRepository: tags,
        activeTimerStateRepository: activeState,
        clock: clock,
      );
      addTearDown(fresh.dispose);

      final resume = await fresh.resumeFromPersisted(pending: persisted);
      expect(resume.after.phase, EnginePhase.paused);
      expect(fresh.currentState.phase, EnginePhase.paused);
    });

    test(
      'paused Pomodoro remaining survives lifecycle flush then recover',
      () async {
        await lifecycle.startPomodoro(tagId);
        clock.advanceSeconds(20);
        await lifecycle.pause();
        final remainingAtPause = lifecycle.currentState.remainingSecAt(
          clock.nowUtc(),
        );
        expect(remainingAtPause, greaterThan(0));

        clock.advance(const Duration(minutes: 30));
        await lifecycle.persistActiveState(PersistReason.lifecycleFlush);
        final persisted = await activeState.get();
        expect(persisted!.pauseStartedAtUtcMs, isNotNull);
        expect(persisted.frozenRemainingSec, remainingAtPause);

        lifecycle.dispose();
        final fresh = SessionLifecycle(
          sessionRepository: sessions,
          tagRepository: tags,
          activeTimerStateRepository: activeState,
          clock: clock,
        );
        addTearDown(fresh.dispose);

        final resume = await fresh.resumeFromPersisted(pending: persisted);
        expect(resume.after.remainingSecAt(clock.nowUtc()), remainingAtPause);
      },
    );

    test('paused Flexible recovers and resumes without error', () async {
      await lifecycle.startFlexible(tagId);
      clock.advanceSeconds(40);
      await lifecycle.pause();
      clock.advance(const Duration(minutes: 5));
      await lifecycle.persistActiveState(PersistReason.lifecycleFlush);
      final persisted = await activeState.get();
      expect(persisted!.pauseStartedAtUtcMs, isNotNull);

      lifecycle.dispose();
      final fresh = SessionLifecycle(
        sessionRepository: sessions,
        tagRepository: tags,
        activeTimerStateRepository: activeState,
        clock: clock,
      );
      addTearDown(fresh.dispose);

      final resume = await fresh.resumeFromPersisted(pending: persisted);
      expect(resume.after.phase, EnginePhase.paused);

      clock.advanceSeconds(10);
      final running = await fresh.resume();
      expect(running.after.phase, EnginePhase.running);
      expect(fresh.currentState.elapsedActiveSecAt(clock.nowUtc()), 40);
    });

    test(
      'skipBreak from post-focus prompt marks pending rest skipped',
      () async {
        await shortFocusTag();
        await lifecycle.startPomodoro(tagId);
        clock.advanceSeconds(30);
        final atEnd = await lifecycle.tick();

        expect(atEnd.after.phase, EnginePhase.segmentComplete);
        expect(atEnd.after.currentSegment?.type, SegmentType.focus);

        final skip = await lifecycle.skipBreak();
        expect(skip.after.phase, EnginePhase.running);
        expect(skip.after.currentSegment?.type, SegmentType.focus);

        final session = await sessions.getActiveSession();
        final segs = await sessions.getSegmentsBySessionId(session!.id);
        final shortRest = segs.firstWhere(
          (s) => s.type == SegmentType.shortRest,
        );
        expect(shortRest.segmentStatus, SegmentStatus.skipped);
        expect(shortRest.actualSec, 0);
      },
    );

    test('tick without phase change does not persist (BR-TIMER-025)', () async {
      await lifecycle.startPomodoro(tagId);
      final before = await activeState.get();
      expect(before, isNotNull);
      final lastPersisted = before!.lastPersistedAtUtcMs;

      clock.advanceSeconds(5);
      final tick = await lifecycle.tick();

      final after = await activeState.get();
      expect(after!.lastPersistedAtUtcMs, lastPersisted);
      expect(tick.after.phase, EnginePhase.running);
    });

    test(
      'Pomodoro sessionComplete stays soft: session still active, not completed',
      () async {
        await runToPomodoroSessionComplete();

        expect(lifecycle.currentState.phase, EnginePhase.sessionComplete);
        expect(lifecycle.hasActiveSession, isTrue);
        final active = await sessions.getActiveSession();
        expect(active, isNotNull);
        expect(active!.status, SessionStatus.active);
        expect(lifecycle.sessionId, active.id);
        expect(lifecycle.currentState.pomodoroCyclesCompleted, 2);
        expect(lifecycle.currentState.pomodoroCyclesTarget, 2);
      },
    );

    test(
      'continuePomodoro appends same session and grows cycle target',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await sessions.getActiveSession())!.id;
        final segmentsBefore = (await sessions.getSegmentsBySessionId(
          sessionId,
        )).length;

        final cont = await lifecycle.continuePomodoro();
        expect(cont.after.phase, EnginePhase.running);
        expect(cont.after.pomodoroCyclesTarget, 4);
        expect(cont.after.pomodoroCyclesCompleted, 2);
        expect(await sessions.getActiveSession(), isNotNull);
        expect((await sessions.getActiveSession())!.id, sessionId);
        final segmentsAfter = (await sessions.getSegmentsBySessionId(
          sessionId,
        )).length;
        expect(segmentsAfter, greaterThan(segmentsBefore));
      },
    );

    test(
      'restartSameTag from Pomodoro sessionComplete finalizes and starts new',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await sessions.getActiveSession())!.id;

        final restarted = await lifecycle.restartSameTag();
        expect(restarted.after.phase, EnginePhase.running);
        expect(restarted.after.mode, TimerMode.pomodoro);
        expect(lifecycle.hasActiveSession, isTrue);

        final finished = await sessions.getById(sessionId);
        expect(finished!.status, SessionStatus.completed);

        final newActive = await sessions.getActiveSession();
        expect(newActive, isNotNull);
        expect(newActive!.id, isNot(sessionId));
        expect(newActive.tagId, tagId);
        expect(newActive.mode, TimerMode.pomodoro);
      },
    );

    test(
      'dismissSessionComplete finalizes; next start is a new session',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await sessions.getActiveSession())!.id;

        final done = await lifecycle.dismissSessionComplete();
        expect(done.after.phase, EnginePhase.idle);
        expect(lifecycle.hasActiveSession, isFalse);
        expect(await sessions.getActiveSession(), isNull);
        expect(await activeState.get(), isNull);

        final finished = await sessions.getById(sessionId);
        expect(finished!.status, SessionStatus.completed);

        final next = await lifecycle.startPomodoro(tagId);
        expect(next.after.phase, EnginePhase.running);
        final newActive = await sessions.getActiveSession();
        expect(newActive, isNotNull);
        expect(newActive!.id, isNot(sessionId));
      },
    );

    test(
      'soft sessionComplete persists enginePhase for cold-start recovery',
      () async {
        await runToPomodoroSessionComplete();

        final persisted = await activeState.get();
        expect(persisted, isNotNull);
        expect(persisted!.enginePhase, EnginePhase.sessionComplete);
        expect(await sessions.getActiveSession(), isNotNull);
      },
    );

    test(
      'leaving soft sessionComplete matches Done finalize',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await sessions.getActiveSession())!.id;

        final leave = await lifecycle.dismissSessionComplete();
        expect(leave.after.phase, EnginePhase.idle);
        expect(await sessions.getActiveSession(), isNull);
        expect(await activeState.get(), isNull);
        expect(
          (await sessions.getById(sessionId))!.status,
          SessionStatus.completed,
        );
      },
    );

    test('failForFocusViolation marks session failed', () async {
      await lifecycle.startPomodoro(tagId);
      final sessionId = (await sessions.getActiveSession())!.id;

      final failed = await lifecycle.failForFocusViolation();
      expect(failed.after.phase, EnginePhase.idle);
      expect(await sessions.getActiveSession(), isNull);
      final finalized = await sessions.getById(sessionId);
      expect(finalized!.status, SessionStatus.failed);
    });
  });
}

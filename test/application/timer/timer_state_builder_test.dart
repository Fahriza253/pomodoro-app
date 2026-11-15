import 'package:pomodoro_app/application/timer/timer_state_builder.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:test/test.dart';

void main() {
  const builder = TimerStateBuilder();
  final sessionStart = DateTime.utc(2026, 6, 28, 9);
  final segmentStart = DateTime.utc(2026, 6, 28, 9, 5);
  final pauseStart = DateTime.utc(2026, 6, 28, 9, 10);
  final persistAt = DateTime.utc(2026, 6, 28, 9, 12);

  const sessionId = 'session-1';
  const focusId = 'seg-focus';
  const breakId = 'seg-break';

  ConfigSnapshot pomodoroConfig({bool autoStartBreak = false}) =>
      ConfigSnapshot(
        mode: TimerMode.pomodoro,
        focusDurationSec: 1500,
        shortBreakDurationSec: 300,
        longBreakDurationSec: 900,
        sessionsBeforeLongBreak: 4,
        totalCycles: 2,
        autoStartBreak: autoStartBreak,
      );

  Session pomodoroSession({int totalPausedSec = 0}) => Session(
        id: sessionId,
        tagId: 'tag-1',
        mode: TimerMode.pomodoro,
        status: SessionStatus.active,
        startedAtUtcMs: sessionStart.millisecondsSinceEpoch,
        timelineDate: '2026-06-28',
        totalActiveSec: 120,
        totalPausedSec: totalPausedSec,
        configSnapshot: pomodoroConfig(),
        pomodoroFocusCount: 1,
        pomodoroCyclesCompleted: 0,
        pomodoroCyclesTarget: 2,
        createdAtUtcMs: sessionStart.millisecondsSinceEpoch,
        updatedAtUtcMs: persistAt.millisecondsSinceEpoch,
      );

  List<SessionSegment> pomodoroSegments() => [
        SessionSegment(
          id: focusId,
          sessionId: sessionId,
          type: SegmentType.focus,
          orderIndex: 0,
          plannedSec: 1500,
          actualSec: 120,
          segmentPausedSec: 0,
          segmentStatus: SegmentStatus.active,
          startedAtUtcMs: segmentStart.millisecondsSinceEpoch,
        ),
        SessionSegment(
          id: breakId,
          sessionId: sessionId,
          type: SegmentType.shortRest,
          orderIndex: 1,
          plannedSec: 300,
          actualSec: 0,
          segmentPausedSec: 0,
          segmentStatus: SegmentStatus.pending,
        ),
      ];

  ActiveTimerState active({
    required EnginePhase phase,
    int? pauseStartedAtUtcMs,
    int? frozenRemainingSec,
    int flexibleReminderActiveSec = 0,
    String? currentSegmentId,
  }) =>
      ActiveTimerState(
        sessionId: sessionId,
        enginePhase: phase,
        currentSegmentId: currentSegmentId ?? focusId,
        segmentStartedAtUtcMs: segmentStart.millisecondsSinceEpoch,
        flexibleReminderActiveSec: flexibleReminderActiveSec,
        lastPersistedAtUtcMs: persistAt.millisecondsSinceEpoch,
        pauseStartedAtUtcMs: pauseStartedAtUtcMs,
        frozenRemainingSec: frozenRemainingSec,
      );

  group('TimerStateBuilder.fromPersisted', () {
    test('paused Pomodoro restores frozen remaining from persistence', () {
      const frozen = 880;
      final rebuilt = builder.fromPersisted(
        session: pomodoroSession(),
        dbSegments: pomodoroSegments(),
        persisted: active(
          phase: EnginePhase.paused,
          pauseStartedAtUtcMs: pauseStart.millisecondsSinceEpoch,
          frozenRemainingSec: frozen,
        ),
      );

      expect(rebuilt.phase, EnginePhase.paused);
      expect(rebuilt.frozenRemainingSec, frozen);
      expect(rebuilt.pauseStartedAtUtc, pauseStart);
      expect(
        rebuilt.remainingSecAt(pauseStart),
        frozen,
      );
    });

    test('running Flexible rebuilds reminder base from last persist', () {
      final session = Session(
        id: sessionId,
        tagId: 'tag-1',
        mode: TimerMode.flexible,
        status: SessionStatus.active,
        startedAtUtcMs: sessionStart.millisecondsSinceEpoch,
        timelineDate: '2026-06-28',
        totalActiveSec: 600,
        totalPausedSec: 60,
        configSnapshot: const ConfigSnapshot(
          mode: TimerMode.flexible,
          defaultDurationSec: 3600,
          reminderIntervalMin: 25,
          reminderEnabled: true,
        ),
        pomodoroFocusCount: 0,
        pomodoroCyclesCompleted: 0,
        createdAtUtcMs: sessionStart.millisecondsSinceEpoch,
        updatedAtUtcMs: persistAt.millisecondsSinceEpoch,
      );
      const flexId = 'seg-flex';
      final segments = [
        SessionSegment(
          id: flexId,
          sessionId: sessionId,
          type: SegmentType.focus,
          orderIndex: 0,
          plannedSec: 3600,
          actualSec: 600,
          segmentPausedSec: 0,
          segmentStatus: SegmentStatus.active,
          startedAtUtcMs: sessionStart.millisecondsSinceEpoch,
        ),
      ];

      const reminderActive = 120;
      final rebuilt = builder.fromPersisted(
        session: session,
        dbSegments: segments,
        persisted: active(
          phase: EnginePhase.running,
          flexibleReminderActiveSec: reminderActive,
          currentSegmentId: flexId,
        ),
      );

      final elapsedAtPersist =
          persistAt.difference(sessionStart).inSeconds - session.totalPausedSec;
      expect(rebuilt.flexibleReminderBaseElapsedSec, elapsedAtPersist - reminderActive);
      expect(
        rebuilt.flexibleReminderActiveSecAt(persistAt),
        reminderActive,
      );
    });

    test('segmentComplete persists zero remaining anchor', () {
      final rebuilt = builder.fromPersisted(
        session: pomodoroSession(),
        dbSegments: pomodoroSegments(),
        persisted: active(phase: EnginePhase.segmentComplete),
      );

      expect(rebuilt.phase, EnginePhase.segmentComplete);
      expect(rebuilt.frozenRemainingSec, 0);
      expect(rebuilt.remainingSecAt(persistAt), 0);
    });

    test('sessionComplete persists zero remaining anchor', () {
      final session = pomodoroSession();
      final rebuilt = builder.fromPersisted(
        session: Session(
          id: session.id,
          tagId: session.tagId,
          mode: session.mode,
          status: session.status,
          startedAtUtcMs: session.startedAtUtcMs,
          timelineDate: session.timelineDate,
          totalActiveSec: session.totalActiveSec,
          totalPausedSec: session.totalPausedSec,
          configSnapshot: session.configSnapshot,
          pomodoroFocusCount: session.pomodoroFocusCount,
          pomodoroCyclesCompleted: 1,
          pomodoroCyclesTarget: session.pomodoroCyclesTarget,
          createdAtUtcMs: session.createdAtUtcMs,
          updatedAtUtcMs: session.updatedAtUtcMs,
        ),
        dbSegments: pomodoroSegments(),
        persisted: active(phase: EnginePhase.sessionComplete),
      );

      expect(rebuilt.phase, EnginePhase.sessionComplete);
      expect(rebuilt.frozenRemainingSec, 0);
    });

    test('running Pomodoro overdue remaining is zero before catch-up', () {
      final rebuilt = builder.fromPersisted(
        session: pomodoroSession(),
        dbSegments: pomodoroSegments(),
        persisted: active(phase: EnginePhase.running),
      );

      final overdue = segmentStart.add(const Duration(hours: 1));
      expect(rebuilt.phase, EnginePhase.running);
      expect(rebuilt.remainingSecAt(overdue), 0);
    });

    test('resolves current segment index from persisted segment id', () {
      final rebuilt = builder.fromPersisted(
        session: pomodoroSession(),
        dbSegments: pomodoroSegments(),
        persisted: active(
          phase: EnginePhase.running,
          currentSegmentId: breakId,
        ),
      );

      expect(rebuilt.currentSegmentIndex, 1);
      expect(rebuilt.currentSegment?.type, SegmentType.shortRest);
    });

    test('throws when session has no segments', () {
      expect(
        () => builder.fromPersisted(
          session: pomodoroSession(),
          dbSegments: const [],
          persisted: active(phase: EnginePhase.running),
        ),
        throwsStateError,
      );
    });
  });
}
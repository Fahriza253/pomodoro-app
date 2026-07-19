import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'test_database.dart';
import 'package:uuid/uuid.dart';

void main() {
  const uuid = Uuid();

  group('DriftSessionRepository', () {
    late DriftSessionRepository repository;
    late String tagId;

    setUp(() async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      repository = DriftSessionRepository(db);
      tagId = await generalTagId(db);
    });

    test('createSession inserts active session with segments', () async {
      final sessionId = uuid.v4();
      final segmentId = uuid.v4();
      final now = DateTime.utc(2026, 6, 28, 10).millisecondsSinceEpoch;

      final session = await repository.createSession(
        CreateSessionInput(
          id: sessionId,
          tagId: tagId,
          mode: TimerMode.pomodoro,
          configSnapshot: ConfigSnapshot.pomodoroDefaults(),
          startedAtUtcMs: now,
          timelineDate: '2026-06-28',
          pomodoroCyclesTarget: 4,
          segments: [
            CreateSegmentInput(
              id: segmentId,
              type: SegmentType.focus,
              orderIndex: 0,
              plannedSec: 1500,
              segmentStatus: SegmentStatus.active,
              startedAtUtcMs: now,
            ),
          ],
        ),
      );

      expect(session.id, sessionId);
      expect(session.status, SessionStatus.active);
      expect(session.endedAtUtcMs, isNull);

      final segments = await repository.getSegmentsBySessionId(sessionId);
      expect(segments, hasLength(1));
      expect(segments.single.type, SegmentType.focus);
    });

    test(
      'createSession rejects second active session (BR-GLOBAL-002)',
      () async {
        final now = DateTime.utc(2026, 6, 28, 11).millisecondsSinceEpoch;

        await repository.createSession(
          CreateSessionInput(
            id: uuid.v4(),
            tagId: tagId,
            mode: TimerMode.flexible,
            configSnapshot: ConfigSnapshot.flexibleDefaults(),
            startedAtUtcMs: now,
            timelineDate: '2026-06-28',
            segments: [
              CreateSegmentInput(
                id: uuid.v4(),
                type: SegmentType.flexible,
                orderIndex: 0,
                plannedSec: 0,
              ),
            ],
          ),
        );

        expect(
          () => repository.createSession(
            CreateSessionInput(
              id: uuid.v4(),
              tagId: tagId,
              mode: TimerMode.flexible,
              configSnapshot: ConfigSnapshot.flexibleDefaults(),
              startedAtUtcMs: now + 1,
              timelineDate: '2026-06-28',
              segments: [
                CreateSegmentInput(
                  id: uuid.v4(),
                  type: SegmentType.flexible,
                  orderIndex: 0,
                  plannedSec: 0,
                ),
              ],
            ),
          ),
          throwsA(
            isA<ConflictError>().having(
              (e) => e.code,
              'code',
              'TIMER_ACTIVE_SESSION',
            ),
          ),
        );
      },
    );

    test(
      'finalizeSession sets ended_at for terminal status (BR-DATA-001)',
      () async {
        final sessionId = uuid.v4();
        final segmentId = uuid.v4();
        final started = DateTime.utc(2026, 6, 28, 12).millisecondsSinceEpoch;
        final ended = started + 1500;

        await repository.createSession(
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
                id: segmentId,
                type: SegmentType.focus,
                orderIndex: 0,
                plannedSec: 1500,
                segmentStatus: SegmentStatus.active,
                startedAtUtcMs: started,
              ),
            ],
          ),
        );

        final finalized = await repository.finalizeSession(
          FinalizeSessionInput(
            sessionId: sessionId,
            terminalStatus: SessionStatus.completed,
            endedAtUtcMs: ended,
            totalActiveSec: 1500,
            totalPausedSec: 0,
            updatedAtUtcMs: ended,
            segments: [
              FinalizeSegmentInput(
                segmentId: segmentId,
                actualSec: 1500,
                segmentPausedSec: 0,
                segmentStatus: SegmentStatus.completed,
                startedAtUtcMs: started,
                endedAtUtcMs: ended,
              ),
            ],
          ),
        );

        expect(finalized.status, SessionStatus.completed);
        expect(finalized.endedAtUtcMs, ended);
        expect(await repository.getActiveSession(), isNull);
      },
    );

    test(
      'createManualSession inserts manual session + one focus segment',
      () async {
        final sessionId = uuid.v4();
        final started = DateTime.utc(2026, 6, 28, 12).millisecondsSinceEpoch;
        const durationSec = 1800;
        final ended = started + durationSec * 1000;

        final session = await repository.createManualSession(
          CreateManualSessionInput(
            id: sessionId,
            tagId: tagId,
            mode: TimerMode.pomodoro,
            timelineDate: '2026-06-28',
            startedAtUtcMs: started,
            endedAtUtcMs: ended,
            focusDurationSec: durationSec,
            configSnapshot: ConfigSnapshot.pomodoroDefaults(),
          ),
        );

        expect(session.status, SessionStatus.manual);
        expect(session.totalActiveSec, durationSec);
        expect(session.endedAtUtcMs, ended);

        final segments = await repository.getSegmentsBySessionId(sessionId);
        expect(segments, hasLength(1));
        expect(segments.single.type, SegmentType.focus);
        expect(segments.single.segmentStatus, SegmentStatus.completed);
        expect(segments.single.actualSec, durationSec);
      },
    );

    test('markAbandoned rewrites active segments to skipped', () async {
      final sessionId = uuid.v4();
      final segmentId = uuid.v4();
      final started = DateTime.utc(2026, 6, 28, 10).millisecondsSinceEpoch;
      final abandonedAt = DateTime.utc(2026, 6, 29, 12);

      await repository.createSession(
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
              id: segmentId,
              type: SegmentType.focus,
              orderIndex: 0,
              plannedSec: 1500,
              segmentStatus: SegmentStatus.active,
              startedAtUtcMs: started,
            ),
          ],
        ),
      );

      final session = await repository.markAbandoned(sessionId, abandonedAt);
      expect(session.status, SessionStatus.abandoned);

      final segments = await repository.getSegmentsBySessionId(sessionId);
      expect(segments.single.segmentStatus, SegmentStatus.skipped);
      expect(segments.single.endedAtUtcMs, isNotNull);
    });
  });
}

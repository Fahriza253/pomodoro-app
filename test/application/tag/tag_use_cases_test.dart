import 'package:pomodoro_app/application/tag/tag_use_cases.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

import '../../data/test_database.dart';

void main() {
  group('TagUseCases', () {
    late TagUseCases useCases;
    late TagRepository tags;
    late SessionRepository sessions;
    late String seededGeneralId;

    setUp(() async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      seededGeneralId = await generalTagId(db);
      tags = DriftTagRepository(db);
      sessions = DriftSessionRepository(db);
      useCases = TagUseCases(tagRepository: tags, sessionRepository: sessions);
    });

    test('createTag returns tag on valid input', () async {
      final result = await useCases.createTag(
        CreateTagInput(
          name: 'Deep Work',
          color: '#8B5CF6',
          pomodoro: TagModeConfigPomodoro.defaults(),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );
      expect(result.isOk, isTrue);
      expect(result.value!.name, 'Deep Work');
    });

    test('updateTag blocked when active session exists (BR-TAG-005)', () async {
      final uuid = const Uuid();
      final sessionId = uuid.v4();
      final segmentId = uuid.v4();
      final now = DateTime.utc(2026, 6, 28).millisecondsSinceEpoch;

      await sessions.createSession(
        CreateSessionInput(
          id: sessionId,
          tagId: seededGeneralId,
          mode: TimerMode.flexible,
          configSnapshot: ConfigSnapshot.flexibleDefaults(),
          startedAtUtcMs: now,
          timelineDate: '2026-06-28',
          segments: [
            CreateSegmentInput(
              id: segmentId,
              type: SegmentType.flexible,
              orderIndex: 0,
              plannedSec: 0,
              segmentStatus: SegmentStatus.active,
              startedAtUtcMs: now,
            ),
          ],
        ),
      );

      final result = await useCases.updateTag(
        UpdateTagInput(
          id: seededGeneralId,
          name: 'General Renamed',
          color: '#6366F1',
          pomodoro: TagModeConfigPomodoro.defaults(),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );

      expect(result.isErr, isTrue);
      expect(result.error!.code, 'TAG_EDIT_BLOCKED_ACTIVE');
    });
  });
}

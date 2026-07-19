import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';

import 'test_database.dart';

void main() {
  group('DriftTagRepository', () {
    test('listActiveOrdered returns General tag from seeder', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftTagRepository(db);

      final tags = await repository.listActiveOrdered();

      expect(tags, isNotEmpty);
      expect(tags.first.name, DatabaseSeeder.generalTagName);
      expect(tags.first.isDeleted, isFalse);
    });

    test('getWithConfigs returns dual-mode configs (BR-TAG-002)', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftTagRepository(db);
      final tagId = await generalTagId(db);

      final withConfigs = await repository.getWithConfigs(tagId);

      expect(withConfigs.pomodoro.mode, TimerMode.pomodoro);
      expect(withConfigs.flexible.mode, TimerMode.flexible);
      expect(withConfigs.pomodoro.focusDurationSec, 1500);
      expect(withConfigs.flexible.reminderIntervalMin, 25);
    });

    test('getConfig returns mode-specific config', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftTagRepository(db);
      final tagId = await generalTagId(db);

      final config = await repository.getConfig(tagId, TimerMode.pomodoro);
      expect(config.totalCycles, 4);
    });

    test('create inserts tag with dual configs (BR-TAG-002)', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftTagRepository(db);

      final tag = await repository.create(
        CreateTagInput(
          name: 'Study',
          color: '#3B82F6',
          pomodoro: TagModeConfigPomodoro.defaults(),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );

      final withConfigs = await repository.getWithConfigs(tag.id);
      expect(withConfigs.pomodoro.mode, TimerMode.pomodoro);
      expect(withConfigs.flexible.mode, TimerMode.flexible);
    });

    test('create rejects duplicate active name (BR-DATA-003)', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftTagRepository(db);

      await repository.create(
        CreateTagInput(
          name: 'Work',
          color: '#10B981',
          pomodoro: TagModeConfigPomodoro.defaults(),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );

      expect(
        () => repository.create(
          CreateTagInput(
            name: 'Work',
            color: '#10B981',
            pomodoro: TagModeConfigPomodoro.defaults(),
            flexible: TagModeConfigFlexible.defaults(),
          ),
        ),
        throwsA(
          isA<ValidationError>().having(
            (e) => e.code,
            'code',
            'TAG_NAME_DUPLICATE',
          ),
        ),
      );
    });

    test('softDelete hides tag from active list (BR-TAG-004)', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftTagRepository(db);

      final tag = await repository.create(
        CreateTagInput(
          name: 'Temp',
          color: '#EF4444',
          pomodoro: TagModeConfigPomodoro.defaults(),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );

      await repository.softDelete(tag.id);
      final active = await repository.listActiveOrdered();
      expect(active.any((t) => t.id == tag.id), isFalse);

      final deleted = await repository.getById(tag.id);
      expect(deleted?.isDeleted, isTrue);
    });

    test('softDelete rejects General tag (BR-TAG-001)', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftTagRepository(db);
      final tagId = await generalTagId(db);

      expect(
        () => repository.softDelete(tagId),
        throwsA(
          isA<ValidationError>().having(
            (e) => e.code,
            'code',
            'TAG_DELETE_LAST',
          ),
        ),
      );
    });
  });
}

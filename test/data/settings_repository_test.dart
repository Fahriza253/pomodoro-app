import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';

import 'test_database.dart';

void main() {
  group('DriftSettingsRepository', () {
    test('get returns singleton defaults', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftSettingsRepository(db);

      final settings = await repository.get();

      expect(settings.id, DatabaseSeeder.settingsId);
      expect(settings.focusMode, FocusMode.loose);
      expect(settings.language, 'en');
      expect(settings.trackFailedSessions, isFalse);
    });

    test('update applies partial patch and bumps updatedAt', () async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      final repository = DriftSettingsRepository(db);
      final before = await repository.get();

      final updated = await repository.update(
        const AppSettingsPatch(
          focusMode: FocusMode.strict,
          trackFailedSessions: true,
        ),
      );

      expect(updated.focusMode, FocusMode.strict);
      expect(updated.trackFailedSessions, isTrue);
      expect(updated.updatedAtUtcMs, greaterThan(before.updatedAtUtcMs));
    });
  });
}

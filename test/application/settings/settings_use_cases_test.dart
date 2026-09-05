import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/application/settings/settings_use_cases.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter_stub.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter_stub.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_stub.dart';

import '../../data/test_database.dart';

void main() {
  group('SettingsUseCases', () {
    late DriftSettingsRepository repository;
    late SettingsUseCases useCases;
    var invalidationCount = 0;

    setUp(() async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      repository = DriftSettingsRepository(db);
      invalidationCount = 0;
      useCases = SettingsUseCases(
        settingsRepository: repository,
        focusAdapter: StubFocusAdapter(),
        notificationAdapter: StubNotificationAdapter(),
        aodAdapter: const StubAODAdapter(),
        flashAdapter: const StubFlashAdapter(),
        onStatisticInvalidation: () => invalidationCount++,
      );
    });

    test('getSettings returns defaults', () async {
      final settings = await useCases.getSettings();
      expect(settings.focusMode, FocusMode.loose);
      expect(settings.language, 'en');
    });

    test('updateSettings persists theme', () async {
      final result = await useCases.updateSettings(
        const AppSettingsPatch(theme: AppTheme.dark),
      );
      expect(result.isOk, isTrue);
      expect(result.value!.theme, AppTheme.dark);
    });

    test('updateSettings persists Alert Controls', () async {
      final result = await useCases.updateSettings(
        const AppSettingsPatch(
          alertHapticEnabled: false,
          alertSoundMuted: true,
          alertFlashEnabled: true,
        ),
      );
      expect(result.isOk, isTrue);
      expect(result.value!.alertHapticEnabled, isFalse);
      expect(result.value!.alertSoundMuted, isTrue);
      expect(result.value!.alertFlashEnabled, isTrue);

      final loaded = await useCases.getSettings();
      expect(loaded.alertHapticEnabled, isFalse);
      expect(loaded.alertSoundMuted, isTrue);
      expect(loaded.alertFlashEnabled, isTrue);
    });

    test('getSettings returns Alert Controls defaults', () async {
      final settings = await useCases.getSettings();
      expect(settings.alertHapticEnabled, isTrue);
      expect(settings.alertSoundMuted, isFalse);
      expect(settings.alertFlashEnabled, isFalse);
    });

    test('invalid patch returns SETTINGS_THRESHOLD_OUT_OF_RANGE', () async {
      final result = await useCases.updateSettings(
        const AppSettingsPatch(focusViolationThresholdSec: 1),
      );
      expect(result.isErr, isTrue);
      expect(result.error!.code, 'SETTINGS_THRESHOLD_OUT_OF_RANGE');
    });

    test('trackFailedSessions toggle debounce statistic invalidation 300ms', () async {
      await useCases.updateSettings(
        const AppSettingsPatch(trackFailedSessions: true),
      );
      expect(invalidationCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(invalidationCount, 1);
    });

    test('getFocusCapabilities from adapter', () {
      final caps = useCases.getFocusCapabilities();
      expect(caps.strictAvailable, isFalse);
      expect(caps.whitelistAvailable, isFalse);
    });
  });
}

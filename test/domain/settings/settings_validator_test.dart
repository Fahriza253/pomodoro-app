import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/settings/settings_validator.dart';
import 'package:test/test.dart';

void main() {
  const current = AppSettings(
    id: 'default',
    alertToneFocusSuccess: AlertToneCatalog.defaultFocusSuccess,
    alertToneBreakOver: AlertToneCatalog.defaultBreakOver,
    alertToneFocusFailure: AlertToneCatalog.defaultFocusFailure,
    focusMode: FocusMode.loose,
    whitelist: [],
    focusViolationThresholdSec: 5,
    theme: AppTheme.system,
    alwaysOnDisplay: false,
    language: 'en',
    weekStartDay: 1,
    timeFormat: TimeFormat.h24,
    trackFailedSessions: false,
    updatedAtUtcMs: 0,
  );

  const validator = SettingsValidator();

  group('SettingsValidator', () {
    test('accepts valid patch', () {
      final result = validator.validatePatch(
        current,
        const AppSettingsPatch(focusMode: FocusMode.strict),
      );
      expect(result.isValid, isTrue);
    });

    test('rejects threshold below minimum', () {
      final result = validator.validatePatch(
        current,
        const AppSettingsPatch(focusViolationThresholdSec: 1),
      );
      expect(result.isValid, isFalse);
    });

    test('rejects unsupported language', () {
      final result = validator.validatePatch(
        current,
        const AppSettingsPatch(language: 'fr'),
      );
      expect(result.isValid, isFalse);
    });

    test('rejects invalid focus success tone', () {
      final result = validator.validatePatch(
        current,
        const AppSettingsPatch(alertToneFocusSuccess: 'invalid'),
      );
      expect(result.isValid, isFalse);
    });
  });
}

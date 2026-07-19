import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';

class SettingsValidationResult {
  const SettingsValidationResult({
    required this.isValid,
    this.code,
    this.message,
  });

  final bool isValid;
  /// Stable code for presentation mapping — prefer over [message].
  final String? code;
  final String? message;
}

/// Validates AppSettings patches (BR-FOCUS-002, BR-SETTINGS).
class SettingsValidator {
  const SettingsValidator();

  static const minViolationThresholdSec = 3;
  static const maxViolationThresholdSec = 60;
  static const supportedLanguages = {'id', 'en'};

  SettingsValidationResult validatePatch(
    AppSettings current,
    AppSettingsPatch patch,
  ) {
    final threshold =
        patch.focusViolationThresholdSec ?? current.focusViolationThresholdSec;
    if (threshold < minViolationThresholdSec ||
        threshold > maxViolationThresholdSec) {
      return const SettingsValidationResult(
        isValid: false,
        code: 'SETTINGS_THRESHOLD_OUT_OF_RANGE',
        message: 'Violation threshold out of range.',
      );
    }

    final language = patch.language ?? current.language;
    if (!supportedLanguages.contains(language)) {
      return const SettingsValidationResult(
        isValid: false,
        code: 'SETTINGS_LANGUAGE_UNSUPPORTED',
        message: 'Language not supported.',
      );
    }

    final weekStart = patch.weekStartDay ?? current.weekStartDay;
    if (weekStart < 0 || weekStart > 6) {
      return const SettingsValidationResult(
        isValid: false,
        code: 'SETTINGS_WEEK_START_INVALID',
        message: 'Week start day is invalid.',
      );
    }

    final focusSuccess =
        patch.alertToneFocusSuccess ?? current.alertToneFocusSuccess;
    if (!AlertToneCatalog.isValidFocusSuccess(focusSuccess)) {
      return const SettingsValidationResult(
        isValid: false,
        code: 'SETTINGS_TONE_FOCUS_SUCCESS_INVALID',
        message: 'Focus-complete tone is invalid.',
      );
    }

    final breakOver = patch.alertToneBreakOver ?? current.alertToneBreakOver;
    if (!AlertToneCatalog.isValidBreakOver(breakOver)) {
      return const SettingsValidationResult(
        isValid: false,
        code: 'SETTINGS_TONE_BREAK_OVER_INVALID',
        message: 'Break-complete tone is invalid.',
      );
    }

    final focusFailure =
        patch.alertToneFocusFailure ?? current.alertToneFocusFailure;
    if (!AlertToneCatalog.isValidFocusFailure(focusFailure)) {
      return const SettingsValidationResult(
        isValid: false,
        code: 'SETTINGS_TONE_FOCUS_FAILURE_INVALID',
        message: 'Focus-failure tone is invalid.',
      );
    }

    final whitelist = patch.whitelist ?? current.whitelist;
    for (final entry in whitelist) {
      if (entry.trim().isEmpty) {
        return const SettingsValidationResult(
          isValid: false,
          code: 'SETTINGS_WHITELIST_ENTRY_EMPTY',
          message: 'Whitelist entry must not be empty.',
        );
      }
    }

    return const SettingsValidationResult(isValid: true);
  }
}

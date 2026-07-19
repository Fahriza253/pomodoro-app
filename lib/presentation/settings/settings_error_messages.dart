import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';

String settingsErrorMessage(AppError error, AppLocalizations l10n) {
  return switch (error.code) {
    'SETTINGS_THRESHOLD_OUT_OF_RANGE' =>
      l10n.violationThresholdOutOfRange(3, 60),
    'SETTINGS_LANGUAGE_UNSUPPORTED' => l10n.languageUnsupported,
    'SETTINGS_WEEK_START_INVALID' => l10n.weekStartInvalid,
    'SETTINGS_TONE_FOCUS_SUCCESS_INVALID' => l10n.alertToneFocusSuccessInvalid,
    'SETTINGS_TONE_BREAK_OVER_INVALID' => l10n.alertToneBreakOverInvalid,
    'SETTINGS_TONE_FOCUS_FAILURE_INVALID' => l10n.alertToneFocusFailureInvalid,
    'SETTINGS_WHITELIST_ENTRY_EMPTY' => l10n.whitelistEntryEmpty,
    'FOCUS_PERMISSION_DENIED' => l10n.errorFocusPermissionDenied,
    'STORAGE_WRITE_FAILED' => l10n.errorSaveSettingsFailed,
    _ => error.message,
  };
}

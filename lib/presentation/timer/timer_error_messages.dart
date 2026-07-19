import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';

/// Maps stable [AppError] codes to user-facing copy (no raw codes in UI).
String timerErrorMessage(AppError error, AppLocalizations l10n) {
  return switch (error.code) {
    'TIMER_ACTIVE_SESSION' => l10n.errorTimerActiveSession,
    'TIMER_NO_ACTIVE_SESSION' => l10n.errorNoActiveSession,
    'TIMER_INVALID_TRANSITION' => l10n.errorTimerInvalidTransition,
    'TIMER_RECOVERY_EXPIRED' => l10n.errorTimerRecoveryExpired,
    'TIMER_STOP_NOT_CONFIRMED' => l10n.errorTimerStopNotConfirmed,
    'SESSION_NOT_ACTIVE' => l10n.errorSessionNotActiveOrEnded,
    'STORAGE_WRITE_FAILED' => l10n.errorSaveFailedTryAgain,
    'TAG_NOT_FOUND' => l10n.errorTagNotFound,
    _ => error.message,
  };
}

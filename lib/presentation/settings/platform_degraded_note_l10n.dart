import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/platform/platform_degraded_note.dart';

String platformDegradedNoteMessage(
  PlatformDegradedNote note,
  AppLocalizations l10n,
) {
  return switch (note) {
    PlatformDegradedNote.notificationInitFailed =>
      l10n.capNotificationInitFailed,
    PlatformDegradedNote.androidNeedsNotificationPermission =>
      l10n.capAndroidNeedsNotificationPermission,
    PlatformDegradedNote.iosStrictBackgroundOnly =>
      l10n.capIosStrictBackgroundOnly,
    PlatformDegradedNote.iosBackgroundNotificationsBestEffort =>
      l10n.capIosBackgroundNotificationsBestEffort,
    PlatformDegradedNote.desktopFocusLimited => l10n.capDesktopFocusLimited,
    PlatformDegradedNote.scheduledNotificationsUnreliable =>
      l10n.capScheduledNotificationsUnreliable,
    PlatformDegradedNote.webFocusDowngradeToLoose =>
      l10n.capWebFocusDowngradeToLoose,
    PlatformDegradedNote.webNotificationsNeedActiveTab =>
      l10n.capWebNotificationsNeedActiveTab,
    PlatformDegradedNote.webAodWakeLock => l10n.capWebAodWakeLock,
    PlatformDegradedNote.focusModesDegradedToLoose =>
      l10n.capFocusModesDegradedToLoose,
    PlatformDegradedNote.aodUnsupported => l10n.capAodUnsupported,
  };
}

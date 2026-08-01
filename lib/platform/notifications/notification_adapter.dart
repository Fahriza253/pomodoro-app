import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';

/// Platform notification capabilities (degraded on stub).
class NotificationCapabilities {
  const NotificationCapabilities({
    required this.scheduledSegmentEnd,
    required this.reminders,
    required this.deepLinkOnTap,
    this.customSound = false,
    this.backgroundDelivery = false,
    this.initFailed = false,
    this.liveTimerStatus = false,
  });

  final bool scheduledSegmentEnd;
  final bool reminders;
  final bool deepLinkOnTap;
  final bool customSound;
  final bool backgroundDelivery;

  /// Plugin failed during bootstrap — alerts unavailable until app restart.
  final bool initFailed;

  /// OS-owned live timer (Android chronometer and/or iOS Live Activity).
  final bool liveTimerStatus;
}

abstract class NotificationAdapter {
  NotificationCapabilities capabilities();

  /// Schedules a segment-end alert that fires even when the app is backgrounded.
  ///
  /// [soundToneId] is an [AlertToneCatalog] id used for Android channel sound
  /// and iOS bundle sound.
  Future<void> scheduleSegmentEnd({
    required DateTime fireAtUtc,
    required String title,
    required String body,
    required int notificationId,
    required String sessionId,
    required String soundToneId,
    bool playSound = true,
  });

  /// Immediate alert (e.g. focus failure) with custom sound.
  ///
  /// [deepLinkSource] is appended to the tap payload (e.g. `segment_end`) so
  /// the app can suppress a duplicate in-app alert when opened from the tray.
  Future<void> showAlert({
    required String title,
    required String body,
    required String sessionId,
    required String soundToneId,
    int? notificationId,
    String? deepLinkSource,
    bool playSound = true,
  });

  Future<void> showReminder({
    required String title,
    required String body,
    required String sessionId,
    bool playSound = true,
  });

  /// Ongoing session timer while the app is backgrounded.
  /// Hide with [cancel] using [kRunningTimerNotificationId].
  Future<void> showRunningTimer(RunningTimerContent content);

  Future<void> cancel(int notificationId);
  Future<void> cancelAll();

  /// Body tap → `/timer?sessionId=…`; Exit → `/timer?sessionId=…&action=exit`.
  void setDeepLinkHandler(void Function(Uri uri) handler);

  /// Just-in-time notification permission (NFR-SEC-003). Safe to call repeatedly.
  Future<void> ensurePermission();
}

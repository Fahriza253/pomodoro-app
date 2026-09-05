import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';

/// No-op notification adapter for non-mobile / tests.
class StubNotificationAdapter implements NotificationAdapter {
  @override
  NotificationCapabilities capabilities() => const NotificationCapabilities(
    scheduledSegmentEnd: false,
    reminders: false,
    deepLinkOnTap: false,
  );

  @override
  Future<bool> scheduleSegmentEnd({
    required DateTime fireAtUtc,
    required String title,
    required String body,
    required int notificationId,
    required String sessionId,
    required String soundToneId,
    bool playSound = true,
  }) async => false;

  @override
  Future<bool> showAlert({
    required String title,
    required String body,
    required String sessionId,
    required String soundToneId,
    int? notificationId,
    String? deepLinkSource,
    bool playSound = true,
  }) async => false;

  @override
  Future<bool> showReminder({
    required String title,
    required String body,
    required String sessionId,
    bool playSound = true,
  }) async => false;

  @override
  Future<void> showRunningTimer(RunningTimerContent content) async {}

  @override
  Future<void> cancel(int notificationId) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  void setDeepLinkHandler(void Function(Uri uri) handler) {}

  @override
  Future<void> ensurePermission() async {}
}

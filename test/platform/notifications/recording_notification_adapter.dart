import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';

/// Test double that records schedule / alert / cancel calls.
class RecordingNotificationAdapter implements NotificationAdapter {
  final List<ScheduledSegmentEndCall> scheduledSegmentEnds = [];
  final List<String> showAlertTitles = [];
  final List<RunningTimerContent> showRunningTimers = [];
  int cancelAllCount = 0;
  final List<int> cancelledIds = [];

  @override
  NotificationCapabilities capabilities() => const NotificationCapabilities(
    scheduledSegmentEnd: true,
    reminders: true,
    deepLinkOnTap: true,
    customSound: true,
    backgroundDelivery: true,
  );

  @override
  Future<void> scheduleSegmentEnd({
    required DateTime fireAtUtc,
    required String title,
    required String body,
    required int notificationId,
    required String sessionId,
    required String soundToneId,
  }) async {
    scheduledSegmentEnds.add(
      ScheduledSegmentEndCall(
        fireAtUtc: fireAtUtc,
        title: title,
        body: body,
        notificationId: notificationId,
        sessionId: sessionId,
        soundToneId: soundToneId,
      ),
    );
  }

  @override
  Future<void> showAlert({
    required String title,
    required String body,
    required String sessionId,
    required String soundToneId,
    int? notificationId,
    String? deepLinkSource,
  }) async {
    showAlertTitles.add(title);
  }

  @override
  Future<void> showReminder({
    required String title,
    required String body,
    required String sessionId,
  }) async {}

  @override
  Future<void> showRunningTimer(RunningTimerContent content) async {
    showRunningTimers.add(content);
  }

  @override
  Future<void> cancel(int notificationId) async {
    cancelledIds.add(notificationId);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
  }

  @override
  void setDeepLinkHandler(void Function(Uri uri) handler) {}

  @override
  Future<void> ensurePermission() async {}
}

class ScheduledSegmentEndCall {
  const ScheduledSegmentEndCall({
    required this.fireAtUtc,
    required this.title,
    required this.body,
    required this.notificationId,
    required this.sessionId,
    required this.soundToneId,
  });

  final DateTime fireAtUtc;
  final String title;
  final String body;
  final int notificationId;
  final String sessionId;
  final String soundToneId;
}

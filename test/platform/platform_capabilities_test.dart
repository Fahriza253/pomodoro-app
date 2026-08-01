import 'package:pomodoro_app/platform/aod/aod_adapter_stub.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';
import 'package:pomodoro_app/platform/platform_capabilities.dart';
import 'package:pomodoro_app/platform/platform_degraded_note.dart';
import 'package:test/test.dart';

void main() {
  test('buildPlatformCapabilities reports stub degradation', () {
    final snapshot = buildPlatformCapabilities(
      focusAdapter: StubFocusAdapter(),
      notificationAdapter: StubNotificationAdapter(),
      aodAdapter: const StubAODAdapter(),
    );

    expect(snapshot.focus.strictAvailable, isFalse);
    expect(snapshot.notifications.scheduledSegmentEnd, isFalse);
    expect(snapshot.aod.alwaysOnDisplaySupported, isFalse);
    expect(snapshot.degradedNotes, isNotEmpty);
    expect(
      snapshot.degradedNotes,
      contains(PlatformDegradedNote.focusModesDegradedToLoose),
    );
  });

  test('notification initFailed surfaces a degraded note', () {
    final snapshot = buildPlatformCapabilities(
      focusAdapter: StubFocusAdapter(),
      notificationAdapter: _InitFailedNotificationAdapter(),
      aodAdapter: const StubAODAdapter(),
    );

    expect(snapshot.notifications.initFailed, isTrue);
    expect(
      snapshot.degradedNotes,
      contains(PlatformDegradedNote.notificationInitFailed),
    );
  });
}

class _InitFailedNotificationAdapter implements NotificationAdapter {
  @override
  NotificationCapabilities capabilities() => const NotificationCapabilities(
    scheduledSegmentEnd: false,
    reminders: false,
    deepLinkOnTap: false,
    initFailed: true,
  );

  @override
  Future<void> scheduleSegmentEnd({
    required DateTime fireAtUtc,
    required String title,
    required String body,
    required int notificationId,
    required String sessionId,
    required String soundToneId,
    bool playSound = true,
  }) async {}

  @override
  Future<void> showAlert({
    required String title,
    required String body,
    required String sessionId,
    required String soundToneId,
    int? notificationId,
    String? deepLinkSource,
    bool playSound = true,
  }) async {}

  @override
  Future<void> showReminder({
    required String title,
    required String body,
    required String sessionId,
    bool playSound = true,
  }) async {}

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

import 'dart:io';

import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/platform_degraded_note.dart';

/// Aggregated platform capability snapshot for Settings UI (BR-FOCUS-005).
class PlatformCapabilitiesSnapshot {
  const PlatformCapabilitiesSnapshot({
    required this.platformLabel,
    required this.focus,
    required this.notifications,
    required this.aod,
    required this.degradedNotes,
  });

  final String platformLabel;
  final FocusCapabilities focus;
  final NotificationCapabilities notifications;
  final AODCapabilities aod;
  final List<PlatformDegradedNote> degradedNotes;
}

PlatformCapabilitiesSnapshot buildPlatformCapabilities({
  required FocusAdapter focusAdapter,
  required NotificationAdapter notificationAdapter,
  required AODAdapter aodAdapter,
}) {
  final focus = focusAdapter.capabilities();
  final notifications = notificationAdapter.capabilities();
  final aod = aodAdapter.capabilities();
  final notes = <PlatformDegradedNote>{};

  if (notifications.initFailed) {
    notes.add(PlatformDegradedNote.notificationInitFailed);
  }

  if (Platform.isAndroid) {
    if (!notifications.initFailed && !notifications.scheduledSegmentEnd) {
      notes.add(PlatformDegradedNote.androidNeedsNotificationPermission);
    }
  } else if (Platform.isIOS) {
    if (!focus.strictAvailable) {
      notes.add(PlatformDegradedNote.iosStrictBackgroundOnly);
    }
    notes.add(PlatformDegradedNote.iosBackgroundNotificationsBestEffort);
  } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    notes.add(PlatformDegradedNote.desktopFocusLimited);
    if (!notifications.scheduledSegmentEnd) {
      notes.add(PlatformDegradedNote.scheduledNotificationsUnreliable);
    }
  } else {
    notes.add(PlatformDegradedNote.webFocusDowngradeToLoose);
    notes.add(PlatformDegradedNote.webNotificationsNeedActiveTab);
    if (aod.alwaysOnDisplaySupported) {
      notes.add(PlatformDegradedNote.webAodWakeLock);
    }
  }

  if (!focus.strictAvailable || !focus.whitelistAvailable) {
    notes.add(PlatformDegradedNote.focusModesDegradedToLoose);
  }
  if (!aod.alwaysOnDisplaySupported) {
    notes.add(PlatformDegradedNote.aodUnsupported);
  }

  return PlatformCapabilitiesSnapshot(
    platformLabel: _platformLabel(),
    focus: focus,
    notifications: notifications,
    aod: aod,
    degradedNotes: notes.toList(),
  );
}

String _platformLabel() {
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Web / lainnya';
}

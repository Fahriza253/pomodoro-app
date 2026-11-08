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
  return PlatformCapabilitiesSnapshot(
    platformLabel: _platformLabel(),
    focus: focus,
    notifications: notifications,
    aod: aod,
    degradedNotes: const [],
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

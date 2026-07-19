import 'dart:developer' as developer;
import 'dart:io';

import 'package:pomodoro_app/platform/notifications/notification_adapter_io.dart';

/// Initializes platform notifications before [runApp].
///
/// Failures are logged and ignored so a bad notification resource cannot
/// block app startup (splash forever).
Future<void> initializePlatformServices() async {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    return;
  }
  try {
    await LocalNotificationAdapter.instance.initialize();
  } on Object catch (e, st) {
    LocalNotificationAdapter.instance.markInitFailed();
    developer.log(
      'Notification init failed; continuing without alerts',
      name: 'platform_bootstrap',
      error: e,
      stackTrace: st,
    );
  }
}

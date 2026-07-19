import 'dart:io';

import 'package:flutter/services.dart';

/// Opens Android battery optimization settings when available.
class BatteryGuidance {
  BatteryGuidance._();

  static const _channel = MethodChannel('com.dpzstudio.pomodoro_app/battery');

  static bool get isAndroid => Platform.isAndroid;

  static Future<void> openBatterySettings() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
    } on MissingPluginException {
      // Non-Android host — ignore.
    }
  }
}

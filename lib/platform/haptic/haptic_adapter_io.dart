import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter_stub.dart';

HapticAdapter createHapticAdapter() {
  if (Platform.isAndroid || Platform.isIOS) {
    return const FlutterHapticAdapter();
  }
  return const StubHapticAdapter();
}

class FlutterHapticAdapter implements HapticAdapter {
  const FlutterHapticAdapter();

  @override
  HapticCapabilities capabilities() =>
      const HapticCapabilities(supported: true);

  @override
  Future<void> pulse() async {
    await HapticFeedback.mediumImpact();
  }
}

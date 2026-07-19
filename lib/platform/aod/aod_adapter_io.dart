import 'dart:io';

import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter_stub.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

AODAdapter createAodAdapter() {
  if (Platform.isAndroid || Platform.isIOS) {
    return WakelockAodAdapter();
  }
  return const StubAODAdapter();
}

/// AOD via wakelock_plus (BR-SETTINGS-004).
class WakelockAodAdapter implements AODAdapter {
  bool _enabled = false;

  @override
  AODCapabilities capabilities() =>
      const AODCapabilities(alwaysOnDisplaySupported: true);

  @override
  Future<void> enable() async {
    if (_enabled) {
      return;
    }
    await WakelockPlus.enable();
    _enabled = true;
  }

  @override
  Future<void> disable() async {
    if (!_enabled) {
      return;
    }
    await WakelockPlus.disable();
    _enabled = false;
  }
}

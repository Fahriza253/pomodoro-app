import 'package:pomodoro_app/platform/haptic/haptic_adapter.dart';

class StubHapticAdapter implements HapticAdapter {
  const StubHapticAdapter();

  @override
  HapticCapabilities capabilities() =>
      const HapticCapabilities(supported: false);

  @override
  Future<void> pulse() async {}
}

HapticAdapter createHapticAdapter() => const StubHapticAdapter();

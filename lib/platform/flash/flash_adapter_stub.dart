import 'package:pomodoro_app/platform/flash/flash_adapter.dart';

/// ponytail: no torch dependency yet — flash UI stays disabled until a capable
/// IO adapter ships (CameraX / torch plugin). Upgrade: FlashAdapter IO + permission.
class StubFlashAdapter implements FlashAdapter {
  const StubFlashAdapter();

  @override
  FlashCapabilities capabilities() => const FlashCapabilities(supported: false);

  @override
  Future<void> pulse() async {}
}

FlashAdapter createFlashAdapter() => const StubFlashAdapter();

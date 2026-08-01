class HapticCapabilities {
  const HapticCapabilities({required this.supported});

  final bool supported;
}

/// Short haptic pulse for Alert / Reminder fire (BR-SETTINGS-007).
abstract class HapticAdapter {
  HapticCapabilities capabilities();
  Future<void> pulse();
}

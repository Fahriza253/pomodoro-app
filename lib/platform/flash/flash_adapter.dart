class FlashCapabilities {
  const FlashCapabilities({required this.supported});

  final bool supported;
}

/// Brief flash for Alert / Reminder fire (BR-SETTINGS-009).
abstract class FlashAdapter {
  FlashCapabilities capabilities();
  Future<void> pulse();
}

class AODCapabilities {
  const AODCapabilities({required this.alwaysOnDisplaySupported});

  final bool alwaysOnDisplaySupported;
}

abstract class AODAdapter {
  AODCapabilities capabilities();
  Future<void> enable();
  Future<void> disable();
}

import 'package:pomodoro_app/platform/aod/aod_adapter.dart';

/// No-op AOD adapter for platforms without AOD support.
class StubAODAdapter implements AODAdapter {
  const StubAODAdapter();

  @override
  AODCapabilities capabilities() =>
      const AODCapabilities(alwaysOnDisplaySupported: false);

  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

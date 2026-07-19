import 'package:pomodoro_app/domain/common/enums.dart';

class FocusViolation {
  const FocusViolation({required this.packageOrUrl, required this.atUtc});

  final String packageOrUrl;
  final DateTime atUtc;
}

class AndroidFocusConfig {
  const AndroidFocusConfig({
    this.usageStatsPollInterval = const Duration(seconds: 2),
    this.lifecycleImmediateOnBackground = true,
  });

  final Duration usageStatsPollInterval;
  final bool lifecycleImmediateOnBackground;
}

class FocusCapabilities {
  const FocusCapabilities({
    required this.strictAvailable,
    required this.whitelistAvailable,
    this.android,
  });

  final bool strictAvailable;
  final bool whitelistAvailable;
  final AndroidFocusConfig? android;
}

class InstalledAppInfo {
  const InstalledAppInfo({required this.packageName, required this.label});

  final String packageName;
  final String label;
}

abstract class FocusAdapter {
  FocusCapabilities capabilities();
  Stream<FocusViolation> watchViolations();

  Future<void> startMonitoring({
    required FocusMode effectiveMode,
    required List<String> whitelist,
    required Duration threshold,
  });

  Future<void> stopMonitoring();

  /// Usage-access grant for Strict/Whitelist (Android). Stub → false.
  Future<bool> hasUsageAccess();

  /// Opens system Usage Access settings. Stub → no-op.
  Future<void> openUsageAccessSettings();

  /// Launchable apps for whitelist UI. Stub → empty.
  Future<List<InstalledAppInfo>> listInstalledApps();

  void dispose();
}

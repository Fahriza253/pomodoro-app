import 'dart:async';

import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';

/// No-op focus adapter — Strict/Whitelist unavailable (BR-FOCUS-005 fallback).
class StubFocusAdapter implements FocusAdapter {
  StubFocusAdapter()
    : _controller = StreamController<FocusViolation>.broadcast();

  final StreamController<FocusViolation> _controller;

  @override
  FocusCapabilities capabilities() => const FocusCapabilities(
    strictAvailable: false,
    whitelistAvailable: false,
  );

  @override
  Stream<FocusViolation> watchViolations() => _controller.stream;

  @override
  Future<void> startMonitoring({
    required FocusMode effectiveMode,
    required List<String> whitelist,
    required Duration threshold,
  }) async {}

  @override
  Future<void> stopMonitoring() async {}

  @override
  Future<bool> hasUsageAccess() async => false;

  @override
  Future<void> openUsageAccessSettings() async {}

  @override
  Future<List<InstalledAppInfo>> listInstalledApps() async => const [];

  @override
  void dispose() {
    _controller.close();
  }
}

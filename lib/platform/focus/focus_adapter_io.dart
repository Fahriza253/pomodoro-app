import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter_stub.dart';

FocusAdapter createFocusAdapter() {
  if (Platform.isAndroid) {
    return AndroidFocusAdapter();
  }
  return StubFocusAdapter();
}

/// Android focus monitoring via platform channel (BR-FOCUS-008, BR-FOCUS-009).
class AndroidFocusAdapter implements FocusAdapter {
  AndroidFocusAdapter()
    : _violations = StreamController<FocusViolation>.broadcast();

  static const _methodChannel = MethodChannel(
    'com.dpzstudio.pomodoro_app/focus',
  );
  static const _eventChannel = EventChannel(
    'com.dpzstudio.pomodoro_app/focus_events',
  );

  final StreamController<FocusViolation> _violations;
  StreamSubscription<dynamic>? _eventSubscription;
  bool _listening = false;

  @override
  FocusCapabilities capabilities() => const FocusCapabilities(
    strictAvailable: true,
    whitelistAvailable: true,
    android: AndroidFocusConfig(
      usageStatsPollInterval: Duration(seconds: 2),
      lifecycleImmediateOnBackground: true,
    ),
  );

  @override
  Stream<FocusViolation> watchViolations() => _violations.stream;

  @override
  Future<void> startMonitoring({
    required FocusMode effectiveMode,
    required List<String> whitelist,
    required Duration threshold,
  }) async {
    if (effectiveMode == FocusMode.loose) {
      await stopMonitoring();
      return;
    }

    await _ensureEventListening();
    await _methodChannel.invokeMethod<void>('startMonitoring', {
      'mode': effectiveMode.name,
      'whitelist': whitelist,
      'thresholdMs': threshold.inMilliseconds,
      'pollIntervalMs': 2000,
    });
  }

  @override
  Future<void> stopMonitoring() async {
    try {
      await _methodChannel.invokeMethod<void>('stopMonitoring');
    } on MissingPluginException {
      // Desktop test host — ignore.
    }
  }

  @override
  Future<bool> hasUsageAccess() async {
    try {
      final granted = await _methodChannel.invokeMethod<bool>('hasUsageAccess');
      return granted ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> openUsageAccessSettings() async {
    try {
      await _methodChannel.invokeMethod<void>('openUsageAccessSettings');
    } on MissingPluginException {
      // No-op on non-Android hosts.
    }
  }

  @override
  Future<List<InstalledAppInfo>> listInstalledApps() async {
    try {
      final raw = await _methodChannel.invokeMethod<List<dynamic>>(
        'listInstalledApps',
      );
      if (raw == null) {
        return const [];
      }
      return raw.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return InstalledAppInfo(
          packageName: map['packageName'] as String,
          label: map['label'] as String,
        );
      }).toList();
    } on MissingPluginException {
      return const [];
    }
  }

  Future<void> _ensureEventListening() async {
    if (_listening) {
      return;
    }
    _listening = true;
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is! Map) {
        return;
      }
      final map = Map<String, dynamic>.from(event);
      final type = map['type'] as String?;
      if (type != 'violation') {
        return;
      }
      final package = map['packageOrUrl'] as String? ?? 'unknown';
      final atMs = map['atUtcMs'] as int?;
      _violations.add(
        FocusViolation(
          packageOrUrl: package,
          atUtc: atMs != null
              ? DateTime.fromMillisecondsSinceEpoch(atMs, isUtc: true)
              : DateTime.now().toUtc(),
        ),
      );
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _violations.close();
  }
}

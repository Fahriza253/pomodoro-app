import 'dart:async';

import 'package:pomodoro_app/application/timer/timer_coordinator.dart';
import 'package:pomodoro_app/application/timer/timer_view_state.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';

import 'timer_test_stack.dart';

/// Observable durable + presentation snapshot for coordinator regression tests.
class CoordinatorObservation {
  const CoordinatorObservation({
    required this.view,
    required this.hasActiveSession,
    required this.activePersistedAtUtcMs,
    required this.activeEnginePhase,
    required this.sessionStatus,
  });

  final TimerViewState view;
  final bool hasActiveSession;
  final int? activePersistedAtUtcMs;
  final EnginePhase? activeEnginePhase;
  final SessionStatus? sessionStatus;
}

/// Drives [TimerCoordinator] through representative flows with deterministic time.
class TimerCoordinatorRegressionHarness {
  TimerCoordinatorRegressionHarness(this.stack);

  final TimerTestStack stack;

  TimerCoordinator get coordinator => stack.coordinator;

  TimerViewState view() => coordinator.currentViewState;

  Future<CoordinatorObservation> observe({String? sessionId}) async {
    final session = sessionId == null
        ? await stack.sessions.getActiveSession()
        : await stack.sessions.getById(sessionId);
    final active = await stack.activeState.get();
    return CoordinatorObservation(
      view: view(),
      hasActiveSession: coordinator.hasActiveSession,
      activePersistedAtUtcMs: active?.lastPersistedAtUtcMs,
      activeEnginePhase: active?.enginePhase,
      sessionStatus: session?.status,
    );
  }

  Future<void> configureShortPomodoroTag({
    int focusDurationSec = 30,
    int shortBreakDurationSec = 10,
    int sessionsBeforeLongBreak = 2,
    int totalCycles = 2,
    bool autoStartBreak = false,
  }) async {
    final tags = stack.tags as DriftTagRepository;
    final general = await tags.getById(stack.tagId);
    await tags.update(
      UpdateTagInput(
        id: stack.tagId,
        name: general!.name,
        color: general.color,
        pomodoro: TagModeConfigPomodoro(
          focusDurationSec: focusDurationSec,
          shortBreakDurationSec: shortBreakDurationSec,
          longBreakDurationSec: 20,
          sessionsBeforeLongBreak: sessionsBeforeLongBreak,
          totalCycles: totalCycles,
          autoStartBreak: autoStartBreak,
        ),
        flexible: TagModeConfigFlexible.defaults(),
      ),
    );
  }

  /// Ends the current running Pomodoro focus/rest segment via wall-clock tick.
  Future<void> elapseCurrentRunningSegment() async {
    final planned = view().currentPlannedSec;
    if (planned == null) {
      throw StateError('no planned segment while phase=${view().phase}');
    }
    stack.clock.advanceSeconds(planned);
    await coordinator.tick();
  }

  Future<void> drivePomodoroToSessionComplete({
    int sessionsBeforeLongBreak = 1,
    int totalCycles = 2,
  }) async {
    await configureShortPomodoroTag(
      sessionsBeforeLongBreak: sessionsBeforeLongBreak,
      totalCycles: totalCycles,
    );
    final start = await coordinator.startPomodoro(stack.tagId);
    if (start.isErr) {
      throw StateError('startPomodoro failed: ${start.error!.code}');
    }

    for (var i = 0; i < 40; i++) {
      final phase = view().phase;
      if (phase == EnginePhase.sessionComplete) {
        return;
      }
      if (phase == EnginePhase.running) {
        await elapseCurrentRunningSegment();
        continue;
      }
      if (phase == EnginePhase.segmentComplete) {
        final advanced = await coordinator.advanceSegment();
        if (advanced.isErr) {
          throw StateError('advanceSegment failed: ${advanced.error!.code}');
        }
        continue;
      }
      throw StateError('unexpected phase while driving Pomodoro: $phase');
    }
    throw StateError('timed out waiting for sessionComplete');
  }

  TimerTestStack recreateStack() => stack.recreate();

  void offerRecovery(ActiveTimerState persisted) {
    coordinator.setRecoveryOffer(persisted);
  }

  /// Collects view-state phases emitted during [action].
  Future<List<EnginePhase>> captureViewPhases(
    Future<void> Function() action,
  ) async {
    final phases = <EnginePhase>[];
    final sub = coordinator.viewState.listen((state) {
      phases.add(state.phase);
    });
    await action();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    return phases;
  }
}

/// Injects focus violations for coordinator-level failure regression.
class ControllableFocusAdapter implements FocusAdapter {
  ControllableFocusAdapter()
    : _controller = StreamController<FocusViolation>.broadcast();

  final StreamController<FocusViolation> _controller;

  @override
  FocusCapabilities capabilities() =>
      const FocusCapabilities(strictAvailable: true, whitelistAvailable: true);

  @override
  Stream<FocusViolation> watchViolations() => _controller.stream;

  void injectViolation() {
    _controller.add(
      FocusViolation(
        packageOrUrl: 'com.distraction.app',
        atUtc: DateTime.utc(2026, 1, 1),
      ),
    );
  }

  @override
  Future<void> startMonitoring({
    required FocusMode effectiveMode,
    required List<String> whitelist,
    required Duration threshold,
  }) async {}

  @override
  Future<void> stopMonitoring() async {}

  @override
  Future<bool> hasUsageAccess() async => true;

  @override
  Future<void> openUsageAccessSettings() async {}

  @override
  Future<List<InstalledAppInfo>> listInstalledApps() async => const [];

  @override
  void dispose() {
    _controller.close();
  }
}

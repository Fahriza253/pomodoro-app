import 'dart:async';

import 'package:pomodoro_app/application/timer/recovery_check_result.dart';
import 'package:pomodoro_app/application/timer/session_recovery_service.dart';
import 'package:pomodoro_app/application/timer/timer_coordinator.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter_stub.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';
import 'package:test/test.dart';

import '../../platform/notifications/recording_notification_adapter.dart';
import 'timer_test_stack.dart';

/// Test double that can inject focus violations (Strict/Whitelist available).
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

void main() {
  group('TimerCoordinator', () {
    late TimerTestStack stack;
    late TimerCoordinator coordinator;
    late RecordingNotificationAdapter notifications;
    late StubAlertSoundAdapter alertSounds;

    setUp(() async {
      stack = await TimerTestStack.open();
      coordinator = stack.coordinator;
      notifications = stack.notifications as RecordingNotificationAdapter;
      alertSounds = stack.alertSounds as StubAlertSoundAdapter;
    });

    tearDown(() {
      stack.dispose();
    });

    Future<void> shortFocusTag({bool autoStartBreak = false}) async {
      final tags = stack.tags as DriftTagRepository;
      final general = await tags.getById(stack.tagId);
      await tags.update(
        UpdateTagInput(
          id: stack.tagId,
          name: general!.name,
          color: general.color,
          pomodoro: TagModeConfigPomodoro(
            focusDurationSec: 30,
            shortBreakDurationSec: 10,
            longBreakDurationSec: 20,
            sessionsBeforeLongBreak: 2,
            totalCycles: 2,
            autoStartBreak: autoStartBreak,
          ),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );
    }

    Future<void> configureMinimalPomodoroTag() async {
      final tags = stack.tags as DriftTagRepository;
      final general = await tags.getById(stack.tagId);
      await tags.update(
        UpdateTagInput(
          id: stack.tagId,
          name: general!.name,
          color: general.color,
          pomodoro: const TagModeConfigPomodoro(
            focusDurationSec: 30,
            shortBreakDurationSec: 10,
            longBreakDurationSec: 20,
            sessionsBeforeLongBreak: 1,
            totalCycles: 2,
          ),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );
    }

    Future<void> runToPomodoroSessionComplete() async {
      await configureMinimalPomodoroTag();
      final start = await coordinator.startPomodoro(stack.tagId);
      expect(start.isOk, isTrue);

      for (var i = 0; i < 40; i++) {
        final phase = coordinator.currentViewState.phase;
        if (phase == EnginePhase.sessionComplete) {
          return;
        }
        if (phase == EnginePhase.running) {
          final planned = coordinator.currentViewState.currentPlannedSec!;
          stack.clock.advanceSeconds(planned);
          await coordinator.tick();
          continue;
        }
        if (phase == EnginePhase.segmentComplete) {
          final advanced = await coordinator.advanceSegment();
          expect(advanced.isOk, isTrue);
          continue;
        }
        fail('unexpected phase while driving Pomodoro: $phase');
      }
      fail('timed out waiting for sessionComplete');
    }

    test('stop requires confirmation', () async {
      await coordinator.startPomodoro(stack.tagId);
      final unconfirmed = await coordinator.stop(confirmed: false);
      expect(unconfirmed.isErr, isTrue);
      expect(unconfirmed.error!.code, 'TIMER_STOP_NOT_CONFIRMED');

      final confirmed = await coordinator.stop(confirmed: true);
      expect(confirmed.isOk, isTrue);
      expect(await stack.sessions.getActiveSession(), isNull);
      expect(await stack.activeState.get(), isNull);
    });

    test('startFlexible creates flexible session', () async {
      final result = await coordinator.startFlexible(stack.tagId);
      expect(result.isOk, isTrue);
      final active = await stack.sessions.getActiveSession();
      expect(active!.mode, TimerMode.flexible);
    });

    test('resumeFromPersisted clears recovery prompt', () async {
      await coordinator.startPomodoro(stack.tagId);
      await coordinator.pause();
      final persisted = await stack.activeState.get();

      final fresh = stack.recreate();
      addTearDown(fresh.dispose);
      stack.dispose();

      fresh.coordinator.setRecoveryOffer(persisted!);
      expect(fresh.coordinator.currentViewState.showRecoveryPrompt, isTrue);
      final resume = await fresh.coordinator.resumeFromPersisted();
      expect(resume.isOk, isTrue);
      expect(fresh.coordinator.currentViewState.showRecoveryPrompt, isFalse);
      expect(fresh.coordinator.currentViewState.phase, EnginePhase.paused);
    });

    test('completeFlexible auto-finalizes session as completed', () async {
      await coordinator.startFlexible(stack.tagId);
      stack.clock.advance(const Duration(minutes: 5));

      final result = await coordinator.completeFlexible();
      expect(result.isOk, isTrue);
      expect(
        coordinator.currentViewState.phase,
        EnginePhase.sessionComplete,
      );
      expect(await stack.sessions.getActiveSession(), isNull);
      expect(await stack.activeState.get(), isNull);
      expect(coordinator.hasActiveSession, isFalse);
      expect(coordinator.currentViewState.tagId, stack.tagId);
    });

    test(
      'dismissSessionComplete returns idle after auto-finalized flexible',
      () async {
        await coordinator.startFlexible(stack.tagId);
        stack.clock.advance(const Duration(minutes: 3));
        await coordinator.completeFlexible();

        final dismiss = await coordinator.dismissSessionComplete();
        expect(dismiss.isOk, isTrue);
        expect(coordinator.currentViewState.phase, EnginePhase.idle);
        expect(coordinator.hasActiveSession, isFalse);
        expect(await stack.activeState.get(), isNull);
      },
    );

    test('completeFlexible works from paused flexible session', () async {
      await coordinator.startFlexible(stack.tagId);
      await coordinator.pause();

      final result = await coordinator.completeFlexible();
      expect(result.isOk, isTrue);
      expect(
        coordinator.currentViewState.phase,
        EnginePhase.sessionComplete,
      );
    });

    test('dismissSessionComplete is ok when engine already idle', () async {
      final result = await coordinator.dismissSessionComplete();
      expect(result.isOk, isTrue);
      expect(coordinator.currentViewState.phase, EnginePhase.idle);
    });

    test(
      'onLifecycleBackground schedules Pomodoro segment-end notification',
      () async {
        await coordinator.startPomodoro(stack.tagId);
        expect(notifications.scheduledSegmentEnds, isEmpty);

        await coordinator.onLifecycleBackground();

        expect(notifications.scheduledSegmentEnds, isNotEmpty);
        final last = notifications.scheduledSegmentEnds.last;
        expect(last.title, 'Focus complete');
        expect(last.fireAtUtc.isAfter(stack.clock.nowUtc()), isTrue);
        expect(notifications.showRunningTimers, isNotEmpty);
        expect(notifications.showRunningTimers.last.title, 'Focusing');
      },
    );

    test(
      'onLifecycleBackground does not schedule when Flexible running',
      () async {
        await coordinator.startFlexible(stack.tagId);
        notifications.scheduledSegmentEnds.clear();

        await coordinator.onLifecycleBackground();

        expect(notifications.scheduledSegmentEnds, isEmpty);
        expect(notifications.showRunningTimers, isNotEmpty);
        expect(notifications.showRunningTimers.last.title, 'Focusing');
        expect(notifications.showRunningTimers.last.countDown, isFalse);
      },
    );

    test('onLifecycleForeground hides running timer notification', () async {
      await coordinator.startPomodoro(stack.tagId);
      await coordinator.onLifecycleBackground();
      expect(notifications.showRunningTimers, isNotEmpty);

      await coordinator.onLifecycleForeground();
      expect(notifications.cancelledIds, contains(kRunningTimerNotificationId));
    });

    test(
      'pause while backgrounded re-syncs running timer without chronometer',
      () async {
        await coordinator.startPomodoro(stack.tagId);
        await coordinator.onLifecycleBackground();
        final beforePause = notifications.showRunningTimers.length;
        expect(
          notifications.showRunningTimers.last.chronometerAnchorUtc,
          isNotNull,
        );

        final paused = await coordinator.pause();
        expect(paused.isOk, isTrue);
        expect(
          notifications.showRunningTimers.length,
          greaterThan(beforePause),
        );
        expect(
          notifications.showRunningTimers.last.chronometerAnchorUtc,
          isNull,
        );

        final resumed = await coordinator.resume();
        expect(resumed.isOk, isTrue);
        expect(
          notifications.showRunningTimers.last.chronometerAnchorUtc,
          isNotNull,
        );
      },
    );

    test(
      'segment end in foreground plays in-app once and skips OS alert',
      () async {
        await shortFocusTag();
        await coordinator.startPomodoro(stack.tagId);
        stack.clock.advanceSeconds(30);
        await coordinator.tick();

        expect(
          coordinator.currentViewState.phase,
          EnginePhase.segmentComplete,
        );
        expect(alertSounds.played, hasLength(1));
        expect(notifications.showAlertTitles, isEmpty);
      },
    );

    test('suppressNextSegmentAlert skips in-app after push open', () async {
      await shortFocusTag();
      await coordinator.startPomodoro(stack.tagId);
      await coordinator.onLifecycleBackground();
      stack.clock.advanceSeconds(30);
      coordinator.suppressNextSegmentAlert();
      await coordinator.onLifecycleForeground();

      expect(
        coordinator.currentViewState.phase,
        EnginePhase.segmentComplete,
      );
      expect(alertSounds.played, isEmpty);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test(
      'segment end while backgrounded uses scheduled OS alert only',
      () async {
        await shortFocusTag();
        await coordinator.startPomodoro(stack.tagId);
        await coordinator.onLifecycleBackground();
        expect(notifications.scheduledSegmentEnds, isNotEmpty);
        stack.clock.advanceSeconds(30);
        await coordinator.tick();

        expect(
          coordinator.currentViewState.phase,
          EnginePhase.segmentComplete,
        );
        expect(alertSounds.played, isEmpty);
        expect(notifications.showAlertTitles, isEmpty);
      },
    );

    test('resume after scheduled fire time is silent', () async {
      await shortFocusTag();
      await coordinator.startPomodoro(stack.tagId);
      await coordinator.onLifecycleBackground();
      stack.clock.advanceSeconds(30);
      await coordinator.onLifecycleForeground();

      expect(
        coordinator.currentViewState.phase,
        EnginePhase.segmentComplete,
      );
      expect(alertSounds.played, isEmpty);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('resume before fire time then complete is in-app only', () async {
      await shortFocusTag();
      await coordinator.startPomodoro(stack.tagId);
      await coordinator.onLifecycleBackground();
      stack.clock.advanceSeconds(10);
      await coordinator.onLifecycleForeground();
      expect(coordinator.currentViewState.phase, EnginePhase.running);

      stack.clock.advanceSeconds(20);
      await coordinator.tick();

      expect(
        coordinator.currentViewState.phase,
        EnginePhase.segmentComplete,
      );
      expect(alertSounds.played, hasLength(1));
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('failed schedule enqueue falls back to in-app on resume', () async {
      await shortFocusTag();
      notifications.scheduleSucceeds = false;
      await coordinator.startPomodoro(stack.tagId);
      await coordinator.onLifecycleBackground();
      expect(notifications.scheduledSegmentEnds, isEmpty);
      stack.clock.advanceSeconds(30);
      await coordinator.onLifecycleForeground();

      expect(
        coordinator.currentViewState.phase,
        EnginePhase.segmentComplete,
      );
      expect(alertSounds.played, hasLength(1));
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('auto-start in background does not post a second OS alert', () async {
      await shortFocusTag(autoStartBreak: true);

      await coordinator.startPomodoro(stack.tagId);
      await coordinator.onLifecycleBackground();
      final scheduledId =
          notifications.scheduledSegmentEnds.last.notificationId;
      stack.clock.advanceSeconds(30);
      await coordinator.tick();

      expect(coordinator.currentViewState.phase, EnginePhase.running);
      expect(
        coordinator.currentViewState.currentSegmentType,
        SegmentType.shortRest,
      );
      expect(notifications.showAlertTitles, isEmpty);
      expect(notifications.cancelledIds, isNot(contains(scheduledId)));
    });

    test(
      'Flexible Reminder while backgrounded posts one OS and resume is silent',
      () async {
        final tags = stack.tags as DriftTagRepository;
        final general = await tags.getById(stack.tagId);
        await tags.update(
          UpdateTagInput(
            id: stack.tagId,
            name: general!.name,
            color: general.color,
            pomodoro: TagModeConfigPomodoro.defaults(),
            flexible: const TagModeConfigFlexible(reminderIntervalMin: 1),
          ),
        );

        await coordinator.startFlexible(stack.tagId);
        await coordinator.onLifecycleBackground();
        stack.clock.advanceSeconds(60);
        await coordinator.tick();
        await Future<void>.delayed(Duration.zero);

        expect(notifications.showReminderTitles, ['Focus reminder']);
        expect(alertSounds.played, isEmpty);

        await coordinator.onLifecycleForeground();

        expect(notifications.showReminderTitles, ['Focus reminder']);
        expect(alertSounds.played, isEmpty);
        expect(notifications.showAlertTitles, isEmpty);
      },
    );

    test(
      'focus violation while backgrounded posts one OS and resume is silent',
      () async {
        final focus = ControllableFocusAdapter();
        addTearDown(focus.dispose);
        final focusStack = await TimerTestStack.open(focusAdapter: focus);
        addTearDown(focusStack.dispose);
        await (focusStack.settings as DriftSettingsRepository).update(
          const AppSettingsPatch(focusMode: FocusMode.strict),
        );
        final focusNotifications =
            focusStack.notifications as RecordingNotificationAdapter;
        final focusAlerts = focusStack.alertSounds as StubAlertSoundAdapter;

        await focusStack.coordinator.startPomodoro(focusStack.tagId);
        await focusStack.coordinator.onLifecycleBackground();
        focus.injectViolation();
        await Future<void>.delayed(Duration.zero);

        expect(focusNotifications.showAlertTitles, ['Focus session failed']);
        expect(focusAlerts.played, isEmpty);

        await focusStack.coordinator.onLifecycleForeground();

        expect(focusNotifications.showAlertTitles, ['Focus session failed']);
        expect(focusAlerts.played, isEmpty);
      },
    );

    test('failed focus-fail OS post plays in-app once on resume', () async {
      final focus = ControllableFocusAdapter();
      addTearDown(focus.dispose);
      final focusNotifications = RecordingNotificationAdapter()
        ..showSucceeds = false;
      final focusAlerts = StubAlertSoundAdapter();
      final focusStack = await TimerTestStack.open(
        focusAdapter: focus,
        notificationAdapter: focusNotifications,
        alertSoundAdapter: focusAlerts,
      );
      addTearDown(focusStack.dispose);
      await (focusStack.settings as DriftSettingsRepository).update(
        const AppSettingsPatch(focusMode: FocusMode.strict),
      );

      await focusStack.coordinator.startPomodoro(focusStack.tagId);
      await focusStack.coordinator.onLifecycleBackground();
      focus.injectViolation();
      await Future<void>.delayed(Duration.zero);

      expect(focusNotifications.showAlertTitles, isEmpty);
      expect(focusAlerts.played, isEmpty);

      await focusStack.coordinator.onLifecycleForeground();

      expect(focusAlerts.played, hasLength(1));
      expect(focusNotifications.showAlertTitles, isEmpty);
    });

    test('focus violation fails active session via facade order', () async {
      final focus = ControllableFocusAdapter();
      addTearDown(focus.dispose);

      final focusStack = await TimerTestStack.open(focusAdapter: focus);
      addTearDown(focusStack.dispose);
      await (focusStack.settings as DriftSettingsRepository).update(
        const AppSettingsPatch(focusMode: FocusMode.strict),
      );

      await focusStack.coordinator.startPomodoro(focusStack.tagId);
      final sessionId = (await focusStack.sessions.getActiveSession())!.id;

      focus.injectViolation();
      await Future<void>.delayed(Duration.zero);

      expect(await focusStack.sessions.getActiveSession(), isNull);
      final finalized = await focusStack.sessions.getById(sessionId);
      expect(finalized!.status, SessionStatus.failed);
      expect(focusStack.coordinator.currentViewState.phase, EnginePhase.idle);
    });

    test(
      'Pomodoro sessionComplete exposes soft complete on view-state',
      () async {
        await runToPomodoroSessionComplete();

        expect(
          coordinator.currentViewState.phase,
          EnginePhase.sessionComplete,
        );
        expect(coordinator.hasActiveSession, isTrue);
        expect(coordinator.currentViewState.sessionId, isNotNull);
      },
    );

    test(
      'restartSameTag from sessionComplete returns running view-state',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = coordinator.currentViewState.sessionId!;

        final restarted = await coordinator.restartSameTag();
        expect(restarted.isOk, isTrue);
        expect(coordinator.currentViewState.phase, EnginePhase.running);
        expect(coordinator.currentViewState.mode, TimerMode.pomodoro);
        expect(coordinator.hasActiveSession, isTrue);
        expect(coordinator.currentViewState.sessionId, isNot(sessionId));
      },
    );

    test(
      'dismissSessionComplete returns idle; next start ok',
      () async {
        await runToPomodoroSessionComplete();

        final done = await coordinator.dismissSessionComplete();
        expect(done.isOk, isTrue);
        expect(coordinator.currentViewState.phase, EnginePhase.idle);
        expect(coordinator.hasActiveSession, isFalse);

        final next = await coordinator.startPomodoro(stack.tagId);
        expect(next.isOk, isTrue);
        expect(coordinator.currentViewState.phase, EnginePhase.running);
      },
    );

    test(
      'recovery after soft sessionComplete auto-completes without resume',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await stack.sessions.getActiveSession())!.id;
        expect(
          (await stack.activeState.get())!.enginePhase,
          EnginePhase.sessionComplete,
        );

        final recovery = SessionRecoveryService(
          sessionRepository: stack.sessions,
          activeTimerStateRepository: stack.activeState,
        );
        final result = await recovery.check(stack.clock.nowUtc());
        expect(result, isA<RecoveryCheckAutoCompleted>());
        expect(await stack.sessions.getActiveSession(), isNull);
        expect(await stack.activeState.get(), isNull);
        expect(
          (await stack.sessions.getById(sessionId))!.status,
          SessionStatus.completed,
        );
      },
    );
  });
}

import 'dart:async';

import 'package:pomodoro_app/application/timer/recovery_check_result.dart';
import 'package:pomodoro_app/application/timer/session_recovery_service.dart';
import 'package:pomodoro_app/application/timer/timer_coordinator.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter_stub.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter_stub.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter_stub.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter_stub.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';
import 'package:test/test.dart';

import '../../data/test_database.dart';
import '../../platform/notifications/recording_notification_adapter.dart';

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
    late FakeClockAdapter clock;
    late TimerCoordinator coordinator;
    late SessionRepository sessions;
    late ActiveTimerStateRepository activeState;
    late String tagId;
    late AppDatabase db;
    late RecordingNotificationAdapter notifications;
    late StubAlertSoundAdapter alertSounds;

    setUp(() async {
      clock = FakeClockAdapter();
      db = await openTestDatabase();
      tagId = await generalTagId(db);
      sessions = DriftSessionRepository(db);
      activeState = DriftActiveTimerStateRepository(db);
      notifications = RecordingNotificationAdapter();
      alertSounds = StubAlertSoundAdapter();
      coordinator = TimerCoordinator(
        sessionRepository: sessions,
        tagRepository: DriftTagRepository(db),
        activeTimerStateRepository: activeState,
        settingsRepository: DriftSettingsRepository(db),
        notificationAdapter: notifications,
        alertSoundAdapter: alertSounds,
        hapticAdapter: const StubHapticAdapter(),
        flashAdapter: const StubFlashAdapter(),
        focusAdapter: StubFocusAdapter(),
        aodAdapter: const StubAODAdapter(),
        clock: clock,
      );
    });

    tearDown(() {
      coordinator.dispose();
    });

    test('startPomodoro creates active session and persists state', () async {
      final result = await coordinator.startPomodoro(tagId);
      expect(result.isOk, isTrue);

      final active = await sessions.getActiveSession();
      expect(active, isNotNull);
      expect(active!.mode, TimerMode.pomodoro);

      final persisted = await activeState.get();
      expect(persisted, isNotNull);
      expect(persisted!.enginePhase, EnginePhase.running);
      expect(coordinator.hasActiveSession, isTrue);
    });

    test('startPomodoro rejects when session already active', () async {
      await coordinator.startPomodoro(tagId);
      final second = await coordinator.startPomodoro(tagId);
      expect(second.isErr, isTrue);
      expect(second.error!.code, 'TIMER_ACTIVE_SESSION');
    });

    test('pause and resume persist phase transitions', () async {
      await coordinator.startPomodoro(tagId);
      await coordinator.pause();
      var persisted = await activeState.get();
      expect(persisted!.enginePhase, EnginePhase.paused);

      await coordinator.resume();
      persisted = await activeState.get();
      expect(persisted!.enginePhase, EnginePhase.running);
    });

    test(
      'stop within early-stop grace discards session without abandon',
      () async {
        await coordinator.startPomodoro(tagId);
        final sessionId = (await sessions.getActiveSession())!.id;
        clock.advanceSeconds(3);

        final result = await coordinator.stop(confirmed: true);
        expect(result.isOk, isTrue);
        expect(await sessions.getActiveSession(), isNull);
        expect(await sessions.getById(sessionId), isNull);
        expect(await activeState.get(), isNull);
        expect(coordinator.engine.currentState.phase, EnginePhase.idle);
      },
    );

    test('stop after grace abandons session', () async {
      await coordinator.startPomodoro(tagId);
      final sessionId = (await sessions.getActiveSession())!.id;
      clock.advanceSeconds(12);

      final result = await coordinator.stop(confirmed: true);
      expect(result.isOk, isTrue);
      expect(await sessions.getActiveSession(), isNull);
      final finalized = await sessions.getById(sessionId);
      expect(finalized, isNotNull);
      expect(finalized!.status, SessionStatus.abandoned);
      expect(finalized.endedAtUtcMs, isNotNull);
    });

    test('stop requires confirmation', () async {
      await coordinator.startPomodoro(tagId);
      final unconfirmed = await coordinator.stop(confirmed: false);
      expect(unconfirmed.isErr, isTrue);
      expect(unconfirmed.error!.code, 'TIMER_STOP_NOT_CONFIRMED');

      final confirmed = await coordinator.stop(confirmed: true);
      expect(confirmed.isOk, isTrue);
      expect(await sessions.getActiveSession(), isNull);
      expect(await activeState.get(), isNull);
    });

    test('startFlexible creates flexible session', () async {
      final result = await coordinator.startFlexible(tagId);
      expect(result.isOk, isTrue);
      final active = await sessions.getActiveSession();
      expect(active!.mode, TimerMode.flexible);
    });

    test('resumeFromPersisted restores engine phase', () async {
      await coordinator.startPomodoro(tagId);
      await coordinator.pause();
      final persisted = await activeState.get();
      coordinator.dispose();

      final freshCoordinator = TimerCoordinator(
        sessionRepository: sessions,
        tagRepository: DriftTagRepository(db),
        activeTimerStateRepository: activeState,
        settingsRepository: DriftSettingsRepository(db),
        notificationAdapter: StubNotificationAdapter(),
        alertSoundAdapter: StubAlertSoundAdapter(),
        hapticAdapter: const StubHapticAdapter(),
        flashAdapter: const StubFlashAdapter(),
        focusAdapter: StubFocusAdapter(),
        aodAdapter: const StubAODAdapter(),
        clock: clock,
      );
      addTearDown(freshCoordinator.dispose);

      freshCoordinator.setRecoveryOffer(persisted!);
      final resume = await freshCoordinator.resumeFromPersisted();
      expect(resume.isOk, isTrue);
      expect(freshCoordinator.engine.currentState.phase, EnginePhase.paused);
    });

    test(
      'paused Pomodoro remaining survives lifecycle flush then recover',
      () async {
        await coordinator.startPomodoro(tagId);
        clock.advanceSeconds(20);
        await coordinator.pause();
        final remainingAtPause = coordinator.engine.currentState.remainingSecAt(
          clock.nowUtc(),
        );
        expect(remainingAtPause, greaterThan(0));

        clock.advance(const Duration(minutes: 30));
        await coordinator.onLifecycleBackground();
        final persisted = await activeState.get();
        expect(persisted!.pauseStartedAtUtcMs, isNotNull);
        expect(persisted.frozenRemainingSec, remainingAtPause);

        coordinator.dispose();
        final fresh = TimerCoordinator(
          sessionRepository: sessions,
          tagRepository: DriftTagRepository(db),
          activeTimerStateRepository: activeState,
          settingsRepository: DriftSettingsRepository(db),
          notificationAdapter: StubNotificationAdapter(),
          alertSoundAdapter: StubAlertSoundAdapter(),
          hapticAdapter: const StubHapticAdapter(),
          flashAdapter: const StubFlashAdapter(),
          focusAdapter: StubFocusAdapter(),
          aodAdapter: const StubAODAdapter(),
          clock: clock,
        );
        addTearDown(fresh.dispose);

        fresh.setRecoveryOffer(persisted);
        final resume = await fresh.resumeFromPersisted();
        expect(resume.isOk, isTrue);
        expect(
          fresh.engine.currentState.remainingSecAt(clock.nowUtc()),
          remainingAtPause,
        );
      },
    );

    test('paused Flexible recovers and resumes without error', () async {
      await coordinator.startFlexible(tagId);
      clock.advanceSeconds(40);
      await coordinator.pause();
      clock.advance(const Duration(minutes: 5));
      await coordinator.onLifecycleBackground();
      final persisted = await activeState.get();
      expect(persisted!.pauseStartedAtUtcMs, isNotNull);

      coordinator.dispose();
      final fresh = TimerCoordinator(
        sessionRepository: sessions,
        tagRepository: DriftTagRepository(db),
        activeTimerStateRepository: activeState,
        settingsRepository: DriftSettingsRepository(db),
        notificationAdapter: StubNotificationAdapter(),
        alertSoundAdapter: StubAlertSoundAdapter(),
        hapticAdapter: const StubHapticAdapter(),
        flashAdapter: const StubFlashAdapter(),
        focusAdapter: StubFocusAdapter(),
        aodAdapter: const StubAODAdapter(),
        clock: clock,
      );
      addTearDown(fresh.dispose);

      fresh.setRecoveryOffer(persisted);
      expect((await fresh.resumeFromPersisted()).isOk, isTrue);
      expect(fresh.engine.currentState.phase, EnginePhase.paused);

      clock.advanceSeconds(10);
      expect((await fresh.resume()).isOk, isTrue);
      expect(fresh.engine.currentState.phase, EnginePhase.running);
      expect(fresh.engine.currentState.elapsedActiveSecAt(clock.nowUtc()), 40);
    });

    test('completeFlexible auto-finalizes session as completed', () async {
      await coordinator.startFlexible(tagId);
      clock.advance(const Duration(minutes: 5));

      final result = await coordinator.completeFlexible();
      expect(result.isOk, isTrue);
      expect(
        coordinator.engine.currentState.phase,
        EnginePhase.sessionComplete,
      );
      expect(coordinator.currentViewState.phase, EnginePhase.sessionComplete);
      expect(await sessions.getActiveSession(), isNull);
      expect(await activeState.get(), isNull);
      expect(coordinator.hasActiveSession, isFalse);
      expect(coordinator.currentViewState.tagId, tagId);
    });

    test(
      'dismissSessionComplete returns idle after auto-finalized flexible',
      () async {
        await coordinator.startFlexible(tagId);
        clock.advance(const Duration(minutes: 3));
        await coordinator.completeFlexible();

        final dismiss = await coordinator.dismissSessionComplete();
        expect(dismiss.isOk, isTrue);
        expect(coordinator.engine.currentState.phase, EnginePhase.idle);
        expect(coordinator.currentViewState.phase, EnginePhase.idle);
        expect(coordinator.hasActiveSession, isFalse);
        expect(await activeState.get(), isNull);
      },
    );

    test('stop mid-focus records elapsed actualSec on segment', () async {
      await coordinator.startPomodoro(tagId);
      clock.advanceSeconds(120);
      final sessionId = (await sessions.getActiveSession())!.id;

      final stop = await coordinator.stop(confirmed: true);
      expect(stop.isOk, isTrue);

      final segments = await sessions.getSegmentsBySessionId(sessionId);
      final focus = segments.firstWhere((s) => s.type == SegmentType.focus);
      expect(focus.actualSec, 120);
      expect(focus.segmentStatus, SegmentStatus.completed);

      final session = await sessions.getById(sessionId);
      expect(session!.status, SessionStatus.abandoned);
    });

    test('completeFlexible works from paused flexible session', () async {
      await coordinator.startFlexible(tagId);
      await coordinator.pause();

      final result = await coordinator.completeFlexible();
      expect(result.isOk, isTrue);
      expect(
        coordinator.engine.currentState.phase,
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
        await coordinator.startPomodoro(tagId);
        expect(notifications.scheduledSegmentEnds, isEmpty);

        await coordinator.onLifecycleBackground();

        expect(notifications.scheduledSegmentEnds, isNotEmpty);
        final last = notifications.scheduledSegmentEnds.last;
        expect(last.title, 'Focus complete');
        expect(last.fireAtUtc.isAfter(clock.nowUtc()), isTrue);
        expect(notifications.showRunningTimers, isNotEmpty);
        expect(notifications.showRunningTimers.last.title, 'Focusing');
      },
    );

    test(
      'onLifecycleBackground does not schedule when Flexible running',
      () async {
        await coordinator.startFlexible(tagId);
        notifications.scheduledSegmentEnds.clear();

        await coordinator.onLifecycleBackground();

        expect(notifications.scheduledSegmentEnds, isEmpty);
        expect(notifications.showRunningTimers, isNotEmpty);
        expect(notifications.showRunningTimers.last.title, 'Focusing');
        expect(notifications.showRunningTimers.last.countDown, isFalse);
      },
    );

    test('onLifecycleForeground hides running timer notification', () async {
      await coordinator.startPomodoro(tagId);
      await coordinator.onLifecycleBackground();
      expect(notifications.showRunningTimers, isNotEmpty);

      await coordinator.onLifecycleForeground();
      expect(notifications.cancelledIds, contains(kRunningTimerNotificationId));
    });

    test(
      'pause while backgrounded re-syncs running timer without chronometer',
      () async {
        await coordinator.startPomodoro(tagId);
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
      'skipBreak from post-focus prompt marks pending rest skipped',
      () async {
        final tags = DriftTagRepository(db);
        final general = await tags.getById(tagId);
        await tags.update(
          UpdateTagInput(
            id: tagId,
            name: general!.name,
            color: general.color,
            pomodoro: const TagModeConfigPomodoro(
              focusDurationSec: 30,
              shortBreakDurationSec: 10,
              longBreakDurationSec: 20,
              sessionsBeforeLongBreak: 2,
              totalCycles: 2,
            ),
            flexible: TagModeConfigFlexible.defaults(),
          ),
        );

        await coordinator.startPomodoro(tagId);
        clock.advanceSeconds(30);
        await coordinator.tick();

        expect(
          coordinator.engine.currentState.phase,
          EnginePhase.segmentComplete,
        );
        expect(
          coordinator.engine.currentState.currentSegment?.type,
          SegmentType.focus,
        );

        final skip = await coordinator.skipBreak();
        expect(skip.isOk, isTrue);
        expect(coordinator.engine.currentState.phase, EnginePhase.running);
        expect(
          coordinator.engine.currentState.currentSegment?.type,
          SegmentType.focus,
        );

        final session = await sessions.getActiveSession();
        final segs = await sessions.getSegmentsBySessionId(session!.id);
        final shortRest = segs.firstWhere(
          (s) => s.type == SegmentType.shortRest,
        );
        expect(shortRest.segmentStatus, SegmentStatus.skipped);
        expect(shortRest.actualSec, 0);
      },
    );

    Future<void> shortFocusTag() async {
      final tags = DriftTagRepository(db);
      final general = await tags.getById(tagId);
      await tags.update(
        UpdateTagInput(
          id: tagId,
          name: general!.name,
          color: general.color,
          pomodoro: const TagModeConfigPomodoro(
            focusDurationSec: 30,
            shortBreakDurationSec: 10,
            longBreakDurationSec: 20,
            sessionsBeforeLongBreak: 2,
            totalCycles: 2,
          ),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );
    }

    test(
      'segment end in foreground plays in-app once and skips OS alert',
      () async {
        await shortFocusTag();
        await coordinator.startPomodoro(tagId);
        clock.advanceSeconds(30);
        await coordinator.tick();

        expect(
          coordinator.engine.currentState.phase,
          EnginePhase.segmentComplete,
        );
        expect(alertSounds.played, hasLength(1));
        expect(notifications.showAlertTitles, isEmpty);
      },
    );

    test('suppressNextSegmentAlert skips in-app after push open', () async {
      await shortFocusTag();
      await coordinator.startPomodoro(tagId);
      await coordinator.onLifecycleBackground();
      clock.advanceSeconds(30);
      coordinator.suppressNextSegmentAlert();
      await coordinator.onLifecycleForeground();

      expect(
        coordinator.engine.currentState.phase,
        EnginePhase.segmentComplete,
      );
      expect(alertSounds.played, isEmpty);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test(
      'segment end while backgrounded uses scheduled OS alert only',
      () async {
        await shortFocusTag();
        await coordinator.startPomodoro(tagId);
        await coordinator.onLifecycleBackground();
        expect(notifications.scheduledSegmentEnds, isNotEmpty);
        clock.advanceSeconds(30);
        await coordinator.tick();

        expect(
          coordinator.engine.currentState.phase,
          EnginePhase.segmentComplete,
        );
        expect(alertSounds.played, isEmpty);
        expect(notifications.showAlertTitles, isEmpty);
      },
    );

    test('resume after scheduled fire time is silent', () async {
      await shortFocusTag();
      await coordinator.startPomodoro(tagId);
      await coordinator.onLifecycleBackground();
      clock.advanceSeconds(30);
      await coordinator.onLifecycleForeground();

      expect(
        coordinator.engine.currentState.phase,
        EnginePhase.segmentComplete,
      );
      expect(alertSounds.played, isEmpty);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('resume before fire time then complete is in-app only', () async {
      await shortFocusTag();
      await coordinator.startPomodoro(tagId);
      await coordinator.onLifecycleBackground();
      clock.advanceSeconds(10);
      await coordinator.onLifecycleForeground();
      expect(coordinator.engine.currentState.phase, EnginePhase.running);

      clock.advanceSeconds(20);
      await coordinator.tick();

      expect(
        coordinator.engine.currentState.phase,
        EnginePhase.segmentComplete,
      );
      expect(alertSounds.played, hasLength(1));
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('failed schedule enqueue falls back to in-app on resume', () async {
      await shortFocusTag();
      notifications.scheduleSucceeds = false;
      await coordinator.startPomodoro(tagId);
      await coordinator.onLifecycleBackground();
      expect(notifications.scheduledSegmentEnds, isEmpty);
      clock.advanceSeconds(30);
      await coordinator.onLifecycleForeground();

      expect(
        coordinator.engine.currentState.phase,
        EnginePhase.segmentComplete,
      );
      expect(alertSounds.played, hasLength(1));
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('auto-start in background does not post a second OS alert', () async {
      final tags = DriftTagRepository(db);
      final general = await tags.getById(tagId);
      await tags.update(
        UpdateTagInput(
          id: tagId,
          name: general!.name,
          color: general.color,
          pomodoro: const TagModeConfigPomodoro(
            focusDurationSec: 30,
            shortBreakDurationSec: 10,
            longBreakDurationSec: 20,
            sessionsBeforeLongBreak: 2,
            totalCycles: 2,
            autoStartBreak: true,
          ),
          flexible: TagModeConfigFlexible.defaults(),
        ),
      );

      await coordinator.startPomodoro(tagId);
      await coordinator.onLifecycleBackground();
      final scheduledId =
          notifications.scheduledSegmentEnds.last.notificationId;
      clock.advanceSeconds(30);
      await coordinator.tick();

      expect(coordinator.engine.currentState.phase, EnginePhase.running);
      expect(
        coordinator.engine.currentState.currentSegment?.type,
        SegmentType.shortRest,
      );
      expect(notifications.showAlertTitles, isEmpty);
      expect(notifications.cancelledIds, isNot(contains(scheduledId)));
    });

    test(
      'Flexible Reminder while backgrounded posts one OS and resume is silent',
      () async {
        final tags = DriftTagRepository(db);
        final general = await tags.getById(tagId);
        await tags.update(
          UpdateTagInput(
            id: tagId,
            name: general!.name,
            color: general.color,
            pomodoro: TagModeConfigPomodoro.defaults(),
            flexible: const TagModeConfigFlexible(reminderIntervalMin: 1),
          ),
        );

        await coordinator.startFlexible(tagId);
        await coordinator.onLifecycleBackground();
        clock.advanceSeconds(60);
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
        final settings = DriftSettingsRepository(db);
        await settings.update(
          const AppSettingsPatch(focusMode: FocusMode.strict),
        );

        final focusCoordinator = TimerCoordinator(
          sessionRepository: sessions,
          tagRepository: DriftTagRepository(db),
          activeTimerStateRepository: activeState,
          settingsRepository: settings,
          notificationAdapter: notifications,
          alertSoundAdapter: alertSounds,
          hapticAdapter: const StubHapticAdapter(),
          flashAdapter: const StubFlashAdapter(),
          focusAdapter: focus,
          aodAdapter: const StubAODAdapter(),
          clock: clock,
        );
        addTearDown(focusCoordinator.dispose);

        await focusCoordinator.startPomodoro(tagId);
        await focusCoordinator.onLifecycleBackground();
        focus.injectViolation();
        await Future<void>.delayed(Duration.zero);

        expect(notifications.showAlertTitles, ['Focus session failed']);
        expect(alertSounds.played, isEmpty);

        await focusCoordinator.onLifecycleForeground();

        expect(notifications.showAlertTitles, ['Focus session failed']);
        expect(alertSounds.played, isEmpty);
      },
    );

    test('failed focus-fail OS post plays in-app once on resume', () async {
      notifications.showSucceeds = false;
      final focus = ControllableFocusAdapter();
      addTearDown(focus.dispose);
      final settings = DriftSettingsRepository(db);
      await settings.update(
        const AppSettingsPatch(focusMode: FocusMode.strict),
      );

      final focusCoordinator = TimerCoordinator(
        sessionRepository: sessions,
        tagRepository: DriftTagRepository(db),
        activeTimerStateRepository: activeState,
        settingsRepository: settings,
        notificationAdapter: notifications,
        alertSoundAdapter: alertSounds,
        hapticAdapter: const StubHapticAdapter(),
        flashAdapter: const StubFlashAdapter(),
        focusAdapter: focus,
        aodAdapter: const StubAODAdapter(),
        clock: clock,
      );
      addTearDown(focusCoordinator.dispose);

      await focusCoordinator.startPomodoro(tagId);
      await focusCoordinator.onLifecycleBackground();
      focus.injectViolation();
      await Future<void>.delayed(Duration.zero);

      expect(notifications.showAlertTitles, isEmpty);
      expect(alertSounds.played, isEmpty);

      await focusCoordinator.onLifecycleForeground();

      expect(alertSounds.played, hasLength(1));
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('tick without phase change does not persist (BR-TIMER-025)', () async {
      await coordinator.startPomodoro(tagId);
      final before = await activeState.get();
      expect(before, isNotNull);
      final lastPersisted = before!.lastPersistedAtUtcMs;

      clock.advanceSeconds(5);
      await coordinator.tick();

      final after = await activeState.get();
      expect(after!.lastPersistedAtUtcMs, lastPersisted);
      expect(coordinator.engine.currentState.phase, EnginePhase.running);
    });

    test('focus violation fails active session', () async {
      final focus = ControllableFocusAdapter();
      addTearDown(focus.dispose);
      final settings = DriftSettingsRepository(db);
      await settings.update(
        const AppSettingsPatch(focusMode: FocusMode.strict),
      );

      final focusCoordinator = TimerCoordinator(
        sessionRepository: sessions,
        tagRepository: DriftTagRepository(db),
        activeTimerStateRepository: activeState,
        settingsRepository: settings,
        notificationAdapter: notifications,
        alertSoundAdapter: alertSounds,
        hapticAdapter: const StubHapticAdapter(),
        flashAdapter: const StubFlashAdapter(),
        focusAdapter: focus,
        aodAdapter: const StubAODAdapter(),
        clock: clock,
      );
      addTearDown(focusCoordinator.dispose);

      await focusCoordinator.startPomodoro(tagId);
      final sessionId = (await sessions.getActiveSession())!.id;

      focus.injectViolation();
      await Future<void>.delayed(Duration.zero);

      expect(await sessions.getActiveSession(), isNull);
      final finalized = await sessions.getById(sessionId);
      expect(finalized!.status, SessionStatus.failed);
      expect(focusCoordinator.engine.currentState.phase, EnginePhase.idle);
    });

    Future<void> configureMinimalPomodoroTag() async {
      final tags = DriftTagRepository(db);
      final general = await tags.getById(tagId);
      await tags.update(
        UpdateTagInput(
          id: tagId,
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

    /// Drive Pomodoro until soft [EnginePhase.sessionComplete].
    Future<void> runToPomodoroSessionComplete() async {
      await configureMinimalPomodoroTag();
      final start = await coordinator.startPomodoro(tagId);
      expect(start.isOk, isTrue);

      for (var i = 0; i < 40; i++) {
        final phase = coordinator.engine.currentState.phase;
        if (phase == EnginePhase.sessionComplete) {
          return;
        }
        if (phase == EnginePhase.running) {
          final planned =
              coordinator.engine.currentState.currentSegment!.plannedSec;
          clock.advanceSeconds(planned);
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

    test(
      'Pomodoro sessionComplete stays soft: session still active, not completed',
      () async {
        await runToPomodoroSessionComplete();

        expect(
          coordinator.engine.currentState.phase,
          EnginePhase.sessionComplete,
        );
        expect(coordinator.hasActiveSession, isTrue);
        final active = await sessions.getActiveSession();
        expect(active, isNotNull);
        expect(active!.status, SessionStatus.active);
        expect(coordinator.currentViewState.sessionId, active.id);
        expect(coordinator.engine.currentState.pomodoroCyclesCompleted, 2);
        expect(coordinator.engine.currentState.pomodoroCyclesTarget, 2);
      },
    );

    test(
      'continuePomodoro appends same session and grows cycle target',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await sessions.getActiveSession())!.id;
        final segmentsBefore = (await sessions.getSegmentsBySessionId(
          sessionId,
        )).length;

        final cont = await coordinator.continuePomodoro();
        expect(cont.isOk, isTrue);
        expect(coordinator.engine.currentState.phase, EnginePhase.running);
        expect(coordinator.engine.currentState.pomodoroCyclesTarget, 4);
        expect(coordinator.engine.currentState.pomodoroCyclesCompleted, 2);
        expect(await sessions.getActiveSession(), isNotNull);
        expect((await sessions.getActiveSession())!.id, sessionId);
        final segmentsAfter = (await sessions.getSegmentsBySessionId(
          sessionId,
        )).length;
        expect(segmentsAfter, greaterThan(segmentsBefore));
      },
    );

    test(
      'dismissSessionComplete finalizes; next start is a new session',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await sessions.getActiveSession())!.id;

        final done = await coordinator.dismissSessionComplete();
        expect(done.isOk, isTrue);
        expect(coordinator.engine.currentState.phase, EnginePhase.idle);
        expect(coordinator.hasActiveSession, isFalse);
        expect(await sessions.getActiveSession(), isNull);
        expect(await activeState.get(), isNull);

        final finished = await sessions.getById(sessionId);
        expect(finished!.status, SessionStatus.completed);

        final next = await coordinator.startPomodoro(tagId);
        expect(next.isOk, isTrue);
        final newActive = await sessions.getActiveSession();
        expect(newActive, isNotNull);
        expect(newActive!.id, isNot(sessionId));
      },
    );

    test(
      'soft sessionComplete persists enginePhase for cold-start recovery',
      () async {
        await runToPomodoroSessionComplete();

        final persisted = await activeState.get();
        expect(persisted, isNotNull);
        expect(persisted!.enginePhase, EnginePhase.sessionComplete);
        expect(await sessions.getActiveSession(), isNotNull);
      },
    );

    test(
      'leaving soft sessionComplete (back-equivalent) matches Done finalize',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await sessions.getActiveSession())!.id;

        // System back / navigate away uses the same finalize as Done.
        final leave = await coordinator.dismissSessionComplete();
        expect(leave.isOk, isTrue);
        expect(coordinator.engine.currentState.phase, EnginePhase.idle);
        expect(await sessions.getActiveSession(), isNull);
        expect(await activeState.get(), isNull);
        expect(
          (await sessions.getById(sessionId))!.status,
          SessionStatus.completed,
        );
      },
    );

    test(
      'recovery after soft sessionComplete auto-completes without resume',
      () async {
        await runToPomodoroSessionComplete();
        final sessionId = (await sessions.getActiveSession())!.id;
        expect(
          (await activeState.get())!.enginePhase,
          EnginePhase.sessionComplete,
        );

        final recovery = SessionRecoveryService(
          sessionRepository: sessions,
          activeTimerStateRepository: activeState,
        );
        final result = await recovery.check(clock.nowUtc());
        expect(result, isA<RecoveryCheckAutoCompleted>());
        expect(await sessions.getActiveSession(), isNull);
        expect(await activeState.get(), isNull);
        expect(
          (await sessions.getById(sessionId))!.status,
          SessionStatus.completed,
        );
      },
    );
  });
}

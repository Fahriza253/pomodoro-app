import 'dart:async';

import 'package:pomodoro_app/application/timer/side_effect_context.dart';
import 'package:pomodoro_app/application/timer/timer_side_effect_hub.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter_stub.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter_stub.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter.dart';
import 'package:test/test.dart';

import '../../platform/notifications/recording_notification_adapter.dart';

void main() {
  group('TimerSideEffectHub', () {
    late MemorySettingsRepository settings;
    late RecordingNotificationAdapter notifications;
    late StubAlertSoundAdapter sounds;
    late RecordingHapticAdapter haptics;
    late RecordingFocusAdapter focus;
    late RecordingAODAdapter aod;
    late TimerSideEffectHub hub;

    final now = DateTime.utc(2026, 1, 1, 12);

    setUp(() {
      settings = MemorySettingsRepository();
      notifications = RecordingNotificationAdapter();
      sounds = StubAlertSoundAdapter();
      haptics = RecordingHapticAdapter();
      focus = RecordingFocusAdapter();
      aod = RecordingAODAdapter();
      hub = TimerSideEffectHub(
        settingsRepository: settings,
        notificationAdapter: notifications,
        alertSoundAdapter: sounds,
        hapticAdapter: haptics,
        flashAdapter: const StubFlashAdapter(),
        focusAdapter: focus,
        aodAdapter: aod,
      );
    });

    test(
      'segment end in foreground plays in-app tone and skips OS alert',
      () async {
        final consumed = await hub.onSegmentTransition(
          _focusEndedContext(now: now, isForeground: true),
        );

        expect(consumed, isFalse);
        expect(sounds.played, [AlertToneCatalog.defaultFocusSuccess]);
        expect(notifications.showAlertTitles, isEmpty);
      },
    );

    test(
      'segment end in background uses OS alert and skips in-app tone',
      () async {
        final consumed = await hub.onSegmentTransition(
          _focusEndedContext(now: now, isForeground: false),
        );

        expect(consumed, isFalse);
        expect(sounds.played, isEmpty);
        expect(notifications.showAlertTitles, ['Focus complete']);
      },
    );

    test('suppress-next-Alert skips in-app and OS segment alert', () async {
      final consumed = await hub.onSegmentTransition(
        _focusEndedContext(
          now: now,
          isForeground: true,
          suppressNextSegmentAlert: true,
        ),
      );

      expect(consumed, isTrue);
      expect(sounds.played, isEmpty);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('focus failed in foreground plays failure tone', () async {
      await hub.onFocusFailed(
        _runningPomodoroContext(now: now, isForeground: true),
      );

      expect(sounds.played, [AlertToneCatalog.defaultFocusFailure]);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test(
      'focus failed in background posts one OS alert and skips in-app tone',
      () async {
        await hub.onFocusFailed(
          _runningPomodoroContext(now: now, isForeground: false),
        );

        expect(sounds.played, isEmpty);
        expect(notifications.showAlertTitles, ['Focus session failed']);
      },
    );

    test('resume after focus-fail OS post is silent', () async {
      await hub.onFocusFailed(
        _runningPomodoroContext(now: now, isForeground: false),
      );

      await hub.onLifecycleForeground(
        _runningPomodoroContext(now: now, isForeground: true),
      );
      await hub.onFocusFailed(
        _runningPomodoroContext(now: now, isForeground: true),
      );

      expect(sounds.played, isEmpty);
      expect(notifications.showAlertTitles, ['Focus session failed']);
    });

    test('failed focus-fail OS post falls back to in-app on resume', () async {
      notifications.showSucceeds = false;
      await hub.onFocusFailed(
        _runningPomodoroContext(now: now, isForeground: false),
      );
      expect(notifications.showAlertTitles, isEmpty);

      await hub.onLifecycleForeground(
        _runningPomodoroContext(now: now, isForeground: true),
      );

      expect(sounds.played, [AlertToneCatalog.defaultFocusFailure]);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('idle tears down focus, AOD, and notifications', () async {
      await hub.onIdle();

      expect(focus.stopCount, 1);
      expect(aod.disableCount, 1);
      expect(notifications.cancelAllCount, 1);
    });

    test(
      'Flexible Reminder in background shows OS reminder, not in-app tone',
      () async {
        await hub.maybeFlexibleReminder(
          _flexibleRunningContext(now: now, isForeground: false),
        );

        expect(notifications.showReminderTitles, ['Focus reminder']);
        expect(sounds.played, isEmpty);
      },
    );

    test(
      'Flexible Reminder in foreground is in-app only and skips OS',
      () async {
        await hub.maybeFlexibleReminder(
          _flexibleRunningContext(now: now, isForeground: true),
        );

        expect(notifications.showReminderTitles, isEmpty);
        expect(haptics.pulseCount, 1);
      },
    );

    test('resume after reminder OS post is silent', () async {
      await hub.maybeFlexibleReminder(
        _flexibleRunningContext(now: now, isForeground: false),
      );

      await hub.onLifecycleForeground(
        _flexibleRunningContext(now: now, isForeground: true),
      );
      await hub.maybeFlexibleReminder(
        _flexibleRunningContext(now: now, isForeground: true),
      );

      expect(notifications.showReminderTitles, ['Focus reminder']);
      expect(haptics.pulseCount, 0);
      expect(sounds.played, isEmpty);
    });

    test('failed reminder OS post falls back to in-app on resume', () async {
      notifications.showSucceeds = false;
      await hub.maybeFlexibleReminder(
        _flexibleRunningContext(now: now, isForeground: false),
      );
      expect(notifications.showReminderTitles, isEmpty);

      await hub.onLifecycleForeground(
        _flexibleRunningContext(now: now, isForeground: true),
      );

      expect(notifications.showReminderTitles, isEmpty);
      expect(haptics.pulseCount, 1);
    });

    test(
      'next Flexible Reminder after a successful OS post still fires',
      () async {
        await hub.maybeFlexibleReminder(
          _flexibleRunningContext(now: now, isForeground: false),
        );
        final later = now.add(const Duration(minutes: 25));

        await hub.maybeFlexibleReminder(
          _flexibleRunningContext(
            started: now,
            now: later,
            isForeground: false,
          ),
        );

        expect(notifications.showReminderTitles, [
          'Focus reminder',
          'Focus reminder',
        ]);
      },
    );

    test(
      'lifecycle background refreshes segment-end schedule and running tray',
      () async {
        await hub.onLifecycleBackground(
          _runningPomodoroContext(now: now, isForeground: false),
        );

        expect(notifications.scheduledSegmentEnds, isNotEmpty);
        expect(notifications.scheduledSegmentEnds.last.title, 'Focus complete');
        expect(
          notifications.scheduledSegmentEnds.last.fireAtUtc.isAfter(now),
          isTrue,
        );
        expect(notifications.showRunningTimers, isNotEmpty);
        expect(notifications.showRunningTimers.last.title, 'Focusing');
        expect(notifications.showRunningTimers.last.sessionId, 'session-1');
      },
    );

    test(
      'running in foreground does not schedule segment-end OS notification',
      () async {
        await hub.onSegmentTransition(
          _runningPomodoroContext(now: now, isForeground: true),
        );

        expect(notifications.scheduledSegmentEnds, isEmpty);
      },
    );

    test(
      'scheduled background complete does not post immediate OS alert',
      () async {
        await hub.onLifecycleBackground(
          _runningPomodoroContext(now: now, isForeground: false),
        );
        final scheduledId =
            notifications.scheduledSegmentEnds.last.notificationId;

        await hub.onSegmentTransition(
          _focusEndedContext(
            now: now.add(const Duration(seconds: 1500)),
            isForeground: false,
          ),
        );

        expect(notifications.showAlertTitles, isEmpty);
        expect(sounds.played, isEmpty);
        expect(notifications.cancelledIds, isNot(contains(scheduledId)));
      },
    );

    test('resume after due schedule is silent', () async {
      await hub.onLifecycleBackground(
        _runningPomodoroContext(now: now, isForeground: false),
      );
      final later = now.add(const Duration(seconds: 1500));

      await hub.onLifecycleForeground(
        _runningPomodoroContext(now: later, isForeground: true),
      );
      await hub.onSegmentTransition(
        _focusEndedContext(now: later, isForeground: true),
      );

      expect(sounds.played, isEmpty);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test(
      'resume before fire time cancels schedule; later complete is in-app',
      () async {
        await hub.onLifecycleBackground(
          _runningPomodoroContext(now: now, isForeground: false),
        );
        final scheduledId =
            notifications.scheduledSegmentEnds.last.notificationId;
        final mid = now.add(const Duration(seconds: 10));

        await hub.onLifecycleForeground(
          _runningPomodoroContext(now: mid, isForeground: true),
        );

        expect(notifications.cancelledIds, contains(scheduledId));

        await hub.onSegmentTransition(
          _focusEndedContext(now: mid, isForeground: true),
        );

        expect(sounds.played, [AlertToneCatalog.defaultFocusSuccess]);
        expect(notifications.showAlertTitles, isEmpty);
      },
    );

    test('failed enqueue catch-up plays in-app once', () async {
      notifications.scheduleSucceeds = false;
      await hub.onLifecycleBackground(
        _runningPomodoroContext(now: now, isForeground: false),
      );
      expect(notifications.scheduledSegmentEnds, isEmpty);

      final later = now.add(const Duration(seconds: 1500));
      await hub.onLifecycleForeground(
        _runningPomodoroContext(now: later, isForeground: true),
      );
      await hub.onSegmentTransition(
        _focusEndedContext(now: later, isForeground: true),
      );

      expect(sounds.played, [AlertToneCatalog.defaultFocusSuccess]);
      expect(notifications.showAlertTitles, isEmpty);
    });

    test('auto-advance at fire time does not cancel due schedule', () async {
      await hub.onLifecycleBackground(
        _runningPomodoroContext(now: now, isForeground: false),
      );
      final scheduled = notifications.scheduledSegmentEnds.last;
      final fireAt = scheduled.fireAtUtc;

      await hub.onSegmentTransition(
        _autoAdvancedContext(started: now, now: fireAt),
      );

      expect(notifications.showAlertTitles, isEmpty);
      expect(
        notifications.cancelledIds,
        isNot(contains(scheduled.notificationId)),
      );
    });

    test('next segment schedule uses a different notification id', () async {
      await hub.onLifecycleBackground(
        _runningPomodoroContext(now: now, isForeground: false),
      );
      final firstId = notifications.scheduledSegmentEnds.last.notificationId;
      final fireAt = notifications.scheduledSegmentEnds.last.fireAtUtc;

      await hub.onSegmentTransition(
        _autoAdvancedContext(started: now, now: fireAt),
      );
      expect(notifications.scheduledSegmentEnds, hasLength(1));

      await hub.onSegmentTransition(
        _restRunningContext(
          started: fireAt,
          now: fireAt.add(const Duration(seconds: 1)),
        ),
      );

      expect(notifications.scheduledSegmentEnds, hasLength(2));
      expect(
        notifications.scheduledSegmentEnds.last.notificationId,
        isNot(firstId),
      );
    });
  });
}

const _focusPlan = SegmentPlan(
  type: SegmentType.focus,
  plannedSec: 1500,
  orderIndex: 0,
);
const _restPlan = SegmentPlan(
  type: SegmentType.shortRest,
  plannedSec: 300,
  orderIndex: 1,
);

TimerEngineState _pomodoroRunning(DateTime now) {
  return TimerEngineState(
    phase: EnginePhase.running,
    mode: TimerMode.pomodoro,
    config: ConfigSnapshot.pomodoroDefaults(),
    segments: const [_focusPlan, _restPlan],
    currentSegmentIndex: 0,
    segmentStartedAtUtc: now,
    sessionStartedAtUtc: now,
  );
}

SideEffectContext _runningPomodoroContext({
  required DateTime now,
  required bool isForeground,
}) {
  final state = _pomodoroRunning(now);
  return SideEffectContext(
    sessionId: 'session-1',
    before: state,
    after: state,
    isForeground: isForeground,
    suppressNextSegmentAlert: false,
    nowUtc: now,
  );
}

SideEffectContext _focusEndedContext({
  required DateTime now,
  required bool isForeground,
  bool suppressNextSegmentAlert = false,
}) {
  final before = _pomodoroRunning(now);
  final after = TimerEngineState(
    phase: EnginePhase.segmentComplete,
    mode: TimerMode.pomodoro,
    config: ConfigSnapshot.pomodoroDefaults(),
    segments: const [_focusPlan, _restPlan],
    currentSegmentIndex: 0,
    segmentStartedAtUtc: now,
    sessionStartedAtUtc: now,
  );
  return SideEffectContext(
    sessionId: 'session-1',
    before: before,
    after: after,
    isForeground: isForeground,
    suppressNextSegmentAlert: suppressNextSegmentAlert,
    nowUtc: now,
  );
}

SideEffectContext _autoAdvancedContext({
  required DateTime started,
  required DateTime now,
}) {
  final before = _pomodoroRunning(started);
  final after = TimerEngineState(
    phase: EnginePhase.running,
    mode: TimerMode.pomodoro,
    config: ConfigSnapshot.pomodoroDefaults(),
    segments: const [_focusPlan, _restPlan],
    currentSegmentIndex: 1,
    segmentStartedAtUtc: now,
    sessionStartedAtUtc: started,
  );
  return SideEffectContext(
    sessionId: 'session-1',
    before: before,
    after: after,
    isForeground: false,
    suppressNextSegmentAlert: false,
    nowUtc: now,
  );
}

SideEffectContext _restRunningContext({
  required DateTime started,
  required DateTime now,
}) {
  final state = TimerEngineState(
    phase: EnginePhase.running,
    mode: TimerMode.pomodoro,
    config: ConfigSnapshot.pomodoroDefaults(),
    segments: const [_focusPlan, _restPlan],
    currentSegmentIndex: 1,
    segmentStartedAtUtc: started,
    sessionStartedAtUtc: started,
  );
  return SideEffectContext(
    sessionId: 'session-1',
    before: state,
    after: state,
    isForeground: false,
    suppressNextSegmentAlert: false,
    nowUtc: now,
  );
}

SideEffectContext _flexibleRunningContext({
  required DateTime now,
  required bool isForeground,
  DateTime? started,
}) {
  const flexible = SegmentPlan(
    type: SegmentType.flexible,
    plannedSec: 0,
    orderIndex: 0,
  );
  final sessionStarted = started ?? now;
  final state = TimerEngineState(
    phase: EnginePhase.running,
    mode: TimerMode.flexible,
    config: ConfigSnapshot.flexibleDefaults(),
    segments: const [flexible],
    currentSegmentIndex: 0,
    segmentStartedAtUtc: sessionStarted,
    sessionStartedAtUtc: sessionStarted,
  );
  return SideEffectContext(
    sessionId: 'session-1',
    before: state,
    after: state,
    isForeground: isForeground,
    suppressNextSegmentAlert: false,
    nowUtc: now,
  );
}

class MemorySettingsRepository implements SettingsRepository {
  MemorySettingsRepository([AppSettings? settings])
    : _settings = settings ?? _hubTestSettings;

  final AppSettings _settings;

  @override
  Future<AppSettings> get() async => _settings;

  @override
  Future<AppSettings> update(AppSettingsPatch patch) async => _settings;

  @override
  Stream<AppSettings> watch() => Stream.value(_settings);
}

const _hubTestSettings = AppSettings(
  id: 'default',
  alertToneFocusSuccess: AlertToneCatalog.defaultFocusSuccess,
  alertToneBreakOver: AlertToneCatalog.defaultBreakOver,
  alertToneFocusFailure: AlertToneCatalog.defaultFocusFailure,
  alertHapticEnabled: true,
  alertSoundMuted: false,
  alertFlashEnabled: false,
  focusMode: FocusMode.loose,
  whitelist: [],
  focusViolationThresholdSec: 5,
  theme: AppTheme.system,
  alwaysOnDisplay: true,
  language: 'en',
  weekStartDay: 1,
  timeFormat: TimeFormat.h24,
  trackFailedSessions: false,
  updatedAtUtcMs: 0,
);

class RecordingFocusAdapter implements FocusAdapter {
  int startCount = 0;
  int stopCount = 0;

  @override
  FocusCapabilities capabilities() =>
      const FocusCapabilities(strictAvailable: true, whitelistAvailable: true);

  @override
  Stream<FocusViolation> watchViolations() => const Stream.empty();

  @override
  Future<void> startMonitoring({
    required FocusMode effectiveMode,
    required List<String> whitelist,
    required Duration threshold,
  }) async {
    startCount++;
  }

  @override
  Future<void> stopMonitoring() async {
    stopCount++;
  }

  @override
  Future<bool> hasUsageAccess() async => true;

  @override
  Future<void> openUsageAccessSettings() async {}

  @override
  Future<List<InstalledAppInfo>> listInstalledApps() async => const [];

  @override
  void dispose() {}
}

class RecordingAODAdapter implements AODAdapter {
  int enableCount = 0;
  int disableCount = 0;

  @override
  AODCapabilities capabilities() =>
      const AODCapabilities(alwaysOnDisplaySupported: true);

  @override
  Future<void> enable() async {
    enableCount++;
  }

  @override
  Future<void> disable() async {
    disableCount++;
  }
}

class RecordingHapticAdapter implements HapticAdapter {
  int pulseCount = 0;

  @override
  HapticCapabilities capabilities() =>
      const HapticCapabilities(supported: true);

  @override
  Future<void> pulse() async {
    pulseCount++;
  }
}

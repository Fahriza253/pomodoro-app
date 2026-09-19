import 'package:pomodoro_app/application/timer/session_lifecycle.dart';
import 'package:pomodoro_app/application/timer/timer_coordinator.dart';
import 'package:pomodoro_app/application/timer/timer_side_effect_hub.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter_stub.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter_stub.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter_stub.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter_stub.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_stub.dart';

import '../../data/test_database.dart';
import '../../platform/notifications/recording_notification_adapter.dart';

/// Shared DI stack for timer application tests (Lifecycle + Hub + Coordinator).
class TimerTestStack {
  TimerTestStack({
    required this.clock,
    required this.db,
    required this.tagId,
    required this.sessions,
    required this.activeState,
    required this.tags,
    required this.settings,
    required this.lifecycle,
    required this.hub,
    required this.coordinator,
    required this.notifications,
    required this.alertSounds,
    required this.focus,
  });

  final FakeClockAdapter clock;
  final AppDatabase db;
  final String tagId;
  final SessionRepository sessions;
  final ActiveTimerStateRepository activeState;
  final TagRepository tags;
  final SettingsRepository settings;
  final SessionLifecycle lifecycle;
  final TimerSideEffectHub hub;
  final TimerCoordinator coordinator;
  final NotificationAdapter notifications;
  final AlertSoundAdapter alertSounds;
  final FocusAdapter focus;

  bool _disposed = false;

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    coordinator.dispose();
    lifecycle.dispose();
  }

  /// Fresh Coordinator+Lifecycle sharing the same DB/repos/clock (recovery tests).
  TimerTestStack recreate({
    NotificationAdapter? notificationAdapter,
    AlertSoundAdapter? alertSoundAdapter,
    FocusAdapter? focusAdapter,
  }) {
    final nextFocus = focusAdapter ?? StubFocusAdapter();
    final nextNotifications =
        notificationAdapter ?? StubNotificationAdapter();
    final nextAlerts = alertSoundAdapter ?? StubAlertSoundAdapter();
    final nextLifecycle = SessionLifecycle(
      sessionRepository: sessions,
      tagRepository: tags,
      activeTimerStateRepository: activeState,
      clock: clock,
    );
    final nextHub = TimerSideEffectHub(
      settingsRepository: settings,
      notificationAdapter: nextNotifications,
      alertSoundAdapter: nextAlerts,
      hapticAdapter: const StubHapticAdapter(),
      flashAdapter: const StubFlashAdapter(),
      focusAdapter: nextFocus,
      aodAdapter: const StubAODAdapter(),
    );
    final nextCoordinator = TimerCoordinator(
      sessionLifecycle: nextLifecycle,
      sideEffectHub: nextHub,
      settingsRepository: settings,
      focusAdapter: nextFocus,
      clock: clock,
    );
    return TimerTestStack(
      clock: clock,
      db: db,
      tagId: tagId,
      sessions: sessions,
      activeState: activeState,
      tags: tags,
      settings: settings,
      lifecycle: nextLifecycle,
      hub: nextHub,
      coordinator: nextCoordinator,
      notifications: nextNotifications,
      alertSounds: nextAlerts,
      focus: nextFocus,
    );
  }

  static Future<TimerTestStack> open({
    FakeClockAdapter? clock,
    FocusAdapter? focusAdapter,
    NotificationAdapter? notificationAdapter,
    AlertSoundAdapter? alertSoundAdapter,
    AODAdapter? aodAdapter,
    HapticAdapter? hapticAdapter,
    FlashAdapter? flashAdapter,
    SettingsRepository? settingsRepository,
  }) async {
    final nextClock = clock ?? FakeClockAdapter();
    final db = await openTestDatabase();
    final tagId = await generalTagId(db);
    final sessions = DriftSessionRepository(db);
    final activeState = DriftActiveTimerStateRepository(db);
    final tags = DriftTagRepository(db);
    final settings = settingsRepository ?? DriftSettingsRepository(db);
    final focus = focusAdapter ?? StubFocusAdapter();
    final notifications =
        notificationAdapter ?? RecordingNotificationAdapter();
    final alertSounds = alertSoundAdapter ?? StubAlertSoundAdapter();

    final lifecycle = SessionLifecycle(
      sessionRepository: sessions,
      tagRepository: tags,
      activeTimerStateRepository: activeState,
      clock: nextClock,
    );
    final hub = TimerSideEffectHub(
      settingsRepository: settings,
      notificationAdapter: notifications,
      alertSoundAdapter: alertSounds,
      hapticAdapter: hapticAdapter ?? const StubHapticAdapter(),
      flashAdapter: flashAdapter ?? const StubFlashAdapter(),
      focusAdapter: focus,
      aodAdapter: aodAdapter ?? const StubAODAdapter(),
    );
    final coordinator = TimerCoordinator(
      sessionLifecycle: lifecycle,
      sideEffectHub: hub,
      settingsRepository: settings,
      focusAdapter: focus,
      clock: nextClock,
    );

    return TimerTestStack(
      clock: nextClock,
      db: db,
      tagId: tagId,
      sessions: sessions,
      activeState: activeState,
      tags: tags,
      settings: settings,
      lifecycle: lifecycle,
      hub: hub,
      coordinator: coordinator,
      notifications: notifications,
      alertSounds: alertSounds,
      focus: focus,
    );
  }
}

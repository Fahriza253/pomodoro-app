import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/application/timer/recovery_check_result.dart';
import 'package:pomodoro_app/application/timer/session_recovery_service.dart';
import 'package:pomodoro_app/application/timer/timer_coordinator.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter_io.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter_stub.dart'
    if (dart.library.io) 'package:pomodoro_app/platform/audio/alert_sound_adapter_io.dart';
import 'package:pomodoro_app/platform/clock/clock_adapter.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter_stub.dart'
    if (dart.library.io) 'package:pomodoro_app/platform/flash/flash_adapter_io.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter_io.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter_stub.dart'
    if (dart.library.io) 'package:pomodoro_app/platform/haptic/haptic_adapter_io.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_io.dart';

final clockAdapterProvider = Provider<ClockAdapter>(
  (ref) => const SystemClockAdapter(),
);

final notificationAdapterProvider = Provider<NotificationAdapter>((ref) {
  return createNotificationAdapter();
});

final focusAdapterProvider = Provider<FocusAdapter>((ref) {
  final adapter = createFocusAdapter();
  ref.onDispose(adapter.dispose);
  return adapter;
});

final aodAdapterProvider = Provider<AODAdapter>((ref) => createAodAdapter());

final alertSoundAdapterProvider = Provider<AlertSoundAdapter>((ref) {
  final adapter = createAlertSoundAdapter();
  ref.onDispose(adapter.dispose);
  return adapter;
});

final hapticAdapterProvider = Provider<HapticAdapter>(
  (ref) => createHapticAdapter(),
);

final flashAdapterProvider = Provider<FlashAdapter>(
  (ref) => createFlashAdapter(),
);

final sessionRecoveryServiceProvider = Provider<SessionRecoveryService>((ref) {
  return SessionRecoveryService(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    activeTimerStateRepository: ref.watch(activeTimerStateRepositoryProvider),
  );
});

final timerCoordinatorProvider = Provider<TimerCoordinator>((ref) {
  final coordinator = TimerCoordinator(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    activeTimerStateRepository: ref.watch(activeTimerStateRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    notificationAdapter: ref.watch(notificationAdapterProvider),
    alertSoundAdapter: ref.watch(alertSoundAdapterProvider),
    hapticAdapter: ref.watch(hapticAdapterProvider),
    flashAdapter: ref.watch(flashAdapterProvider),
    focusAdapter: ref.watch(focusAdapterProvider),
    aodAdapter: ref.watch(aodAdapterProvider),
    clock: ref.watch(clockAdapterProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// Runs recovery check once after DB is ready; sets coordinator prompt if needed.
final sessionRecoveryBootstrapProvider = FutureProvider<void>((ref) async {
  final recovery = ref.watch(sessionRecoveryServiceProvider);
  final coordinator = ref.watch(timerCoordinatorProvider);
  final clock = ref.watch(clockAdapterProvider);
  final result = await recovery.check(clock.nowUtc());
  switch (result) {
    case RecoveryCheckOfferResume(:final state):
      coordinator.setRecoveryOffer(state);
    case RecoveryCheckAutoAbandoned():
    case RecoveryCheckAutoCompleted():
    case RecoveryCheckNone():
      break;
  }
});

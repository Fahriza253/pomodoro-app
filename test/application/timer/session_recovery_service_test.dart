import 'package:pomodoro_app/application/timer/recovery_check_result.dart';
import 'package:pomodoro_app/application/timer/session_recovery_service.dart';
import 'package:pomodoro_app/application/timer/timer_coordinator.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter_stub.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter_stub.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter_stub.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter_stub.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_stub.dart';
import 'package:test/test.dart';

import '../../data/test_database.dart';

void main() {
  group('SessionRecoveryService', () {
    late FakeClockAdapter clock;
    late SessionRecoveryService recovery;
    late SessionRepository sessions;
    late ActiveTimerStateRepository activeState;
    late TimerCoordinator coordinator;
    late String tagId;

    setUp(() async {
      clock = FakeClockAdapter();
      final db = await openTestDatabase();
      tagId = await generalTagId(db);
      sessions = DriftSessionRepository(db);
      activeState = DriftActiveTimerStateRepository(db);
      recovery = SessionRecoveryService(
        sessionRepository: sessions,
        activeTimerStateRepository: activeState,
      );
      coordinator = TimerCoordinator(
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
    });

    tearDown(() {
      coordinator.dispose();
    });

    test('returns none when no persisted state', () async {
      final result = await recovery.check(clock.nowUtc());
      expect(result, isA<RecoveryCheckNone>());
    });

    test(
      'offers resume when state and session both active under 24h',
      () async {
        await coordinator.startPomodoro(tagId);
        final result = await recovery.check(clock.nowUtc());
        expect(result, isA<RecoveryCheckOfferResume>());
      },
    );

    test('auto-abandons when last persist older than 24h', () async {
      await coordinator.startPomodoro(tagId);
      clock.advance(
        SessionRecoveryService.recoveryWindow + const Duration(minutes: 1),
      );
      final result = await recovery.check(clock.nowUtc());
      expect(result, isA<RecoveryCheckAutoAbandoned>());
      expect(await sessions.getActiveSession(), isNull);
      expect(await activeState.get(), isNull);
    });

    test('cleans orphan active session without timer state', () async {
      await coordinator.startPomodoro(tagId);
      await activeState.delete();
      final result = await recovery.check(clock.nowUtc());
      expect(result, isA<RecoveryCheckAutoAbandoned>());
      expect(await sessions.getActiveSession(), isNull);
    });

    test(
      'sessionComplete phase auto-completes without resume offer',
      () async {
        await coordinator.startFlexible(tagId);
        final session = (await sessions.getActiveSession())!;
        final persisted = (await activeState.get())!;
        await activeState.upsert(
          ActiveTimerState(
            sessionId: session.id,
            enginePhase: EnginePhase.sessionComplete,
            segmentStartedAtUtcMs: persisted.segmentStartedAtUtcMs,
            flexibleReminderActiveSec: persisted.flexibleReminderActiveSec,
            lastPersistedAtUtcMs: persisted.lastPersistedAtUtcMs,
            currentSegmentId: persisted.currentSegmentId,
          ),
        );

        final result = await recovery.check(clock.nowUtc());
        expect(result, isA<RecoveryCheckAutoCompleted>());
        expect(await sessions.getActiveSession(), isNull);
        expect(await activeState.get(), isNull);
        final finalized = await sessions.getById(session.id);
        expect(finalized!.status, SessionStatus.completed);
      },
    );
  });
}

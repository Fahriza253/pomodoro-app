import 'package:pomodoro_app/application/timer/timer_coordinator.dart';
import 'package:pomodoro_app/application/timer/timer_flow_state.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import '../../platform/notifications/recording_notification_adapter.dart';
import 'timer_coordinator_regression_harness.dart';
import 'timer_test_stack.dart';

void main() {
  group('TimerCoordinator regression contract', () {
    late TimerTestStack stack;
    late TimerCoordinatorRegressionHarness harness;
    late TimerCoordinator coordinator;

    setUp(() async {
      stack = await TimerTestStack.open();
      harness = TimerCoordinatorRegressionHarness(stack);
      coordinator = harness.coordinator;
    });

    tearDown(() {
      stack.dispose();
    });

    group('presentation flow phases', () {
      test('idle setup exposes idle phase without active session', () async {
        final obs = await harness.observe();
        expect(obs.view.phase, EnginePhase.idle);
        expect(obs.hasActiveSession, isFalse);
        expect(obs.activeEnginePhase, isNull);
        expect(await stack.sessions.getActiveSession(), isNull);
      });

      test('Pomodoro pre-start countdown is visible before session create', () {
        fakeAsync((async) {
          final begin = coordinator.beginPomodoroStart(stack.tagId);
          expect(begin.isOk, isTrue);
          expect(harness.view().preStartCountdown, 3);
          expect(harness.view().phase, EnginePhase.idle);
          expect(coordinator.hasActiveSession, isFalse);

          async.elapse(const Duration(seconds: 3));
          async.flushMicrotasks();
          expect(harness.view().phase, EnginePhase.running);
          expect(harness.view().preStartCountdown, isNull);
          expect(coordinator.hasActiveSession, isTrue);
        });
      });

      test('Flexible start enters running flexible session', () async {
        final result = await coordinator.startFlexible(stack.tagId);
        expect(result.isOk, isTrue);

        final obs = await harness.observe();
        expect(obs.view.phase, EnginePhase.running);
        expect(obs.view.mode, TimerMode.flexible);
        expect(obs.view.isCountdown, isFalse);
        expect(obs.sessionStatus, SessionStatus.active);
        expect(obs.activeEnginePhase, EnginePhase.running);
        expect(coordinator.currentFlowState, isA<TimerActiveRunningFlow>());
      });

      test('pause and resume expose paused then running view-state', () async {
        await coordinator.startPomodoro(stack.tagId);

        final paused = await coordinator.pause();
        expect(paused.isOk, isTrue);
        expect(harness.view().phase, EnginePhase.paused);

        final resumed = await coordinator.resume();
        expect(resumed.isOk, isTrue);
        expect(harness.view().phase, EnginePhase.running);
      });

      test('segment complete exposes segment-end summary on view-state', () async {
        await harness.configureShortPomodoroTag();
        await coordinator.startPomodoro(stack.tagId);
        await harness.elapseCurrentRunningSegment();

        expect(harness.view().phase, EnginePhase.segmentComplete);
        expect(harness.view().hasSegmentEndSummary, isTrue);
        expect(harness.view().segmentEndFinishedType, SegmentType.focus);
      });

      test('Pomodoro session complete keeps soft-complete session active', () async {
        await harness.drivePomodoroToSessionComplete();

        final obs = await harness.observe();
        expect(obs.view.phase, EnginePhase.sessionComplete);
        expect(obs.hasActiveSession, isTrue);
        expect(obs.sessionStatus, SessionStatus.active);
        expect(obs.view.sessionId, isNotNull);
      });
    });

    group('segment and terminal outcomes', () {
      test('manual advance waits at segment complete until user advances', () async {
        await harness.configureShortPomodoroTag();
        await coordinator.startPomodoro(stack.tagId);
        await harness.elapseCurrentRunningSegment();
        expect(harness.view().phase, EnginePhase.segmentComplete);

        final advanced = await coordinator.advanceSegment();
        expect(advanced.isOk, isTrue);
        expect(harness.view().phase, EnginePhase.running);
        expect(
          harness.view().currentSegmentType,
          SegmentType.shortRest,
        );
      });

      test('auto-start break advances without manual advanceSegment', () async {
        await harness.configureShortPomodoroTag(autoStartBreak: true);
        await coordinator.startPomodoro(stack.tagId);
        await harness.elapseCurrentRunningSegment();

        expect(harness.view().phase, EnginePhase.running);
        expect(
          harness.view().currentSegmentType,
          SegmentType.shortRest,
        );
      });

      test('skipBreak records skipped rest with zero actual duration', () async {
        await harness.configureShortPomodoroTag();
        await coordinator.startPomodoro(stack.tagId);
        await harness.elapseCurrentRunningSegment();
        expect(harness.view().phase, EnginePhase.segmentComplete);

        final skipped = await coordinator.skipBreak();
        expect(skipped.isOk, isTrue);
        expect(harness.view().phase, EnginePhase.running);
        expect(harness.view().currentSegmentType, SegmentType.focus);

        final session = await stack.sessions.getActiveSession();
        final segments = await stack.sessions.getSegmentsBySessionId(session!.id);
        final rest = segments.firstWhere((s) => s.type == SegmentType.shortRest);
        expect(rest.segmentStatus, SegmentStatus.skipped);
        expect(rest.actualSec, 0);
      });

      test('Flexible complete finalizes session as completed', () async {
        await coordinator.startFlexible(stack.tagId);
        final sessionId = (await stack.sessions.getActiveSession())!.id;
        stack.clock.advance(const Duration(minutes: 2));

        final done = await coordinator.completeFlexible();
        expect(done.isOk, isTrue);
        expect(harness.view().phase, EnginePhase.sessionComplete);
        expect(await stack.sessions.getActiveSession(), isNull);

        await coordinator.dismissSessionComplete();

        final finalized = await stack.sessions.getById(sessionId);
        expect(finalized!.status, SessionStatus.completed);
        expect(await stack.activeState.get(), isNull);
      });

      test('stop after early-stop grace abandons session', () async {
        await coordinator.startPomodoro(stack.tagId);
        final sessionId = (await stack.sessions.getActiveSession())!.id;
        stack.clock.advanceSeconds(12);

        final stopped = await coordinator.stop(confirmed: true);
        expect(stopped.isOk, isTrue);
        expect(harness.view().phase, EnginePhase.idle);
        expect(await stack.sessions.getActiveSession(), isNull);

        final finalized = await stack.sessions.getById(sessionId);
        expect(finalized!.status, SessionStatus.abandoned);
      });

      test('stop within early-stop grace discards session', () async {
        await coordinator.startPomodoro(stack.tagId);
        final sessionId = (await stack.sessions.getActiveSession())!.id;
        stack.clock.advanceSeconds(3);

        final stopped = await coordinator.stop(confirmed: true);
        expect(stopped.isOk, isTrue);
        expect(harness.view().phase, EnginePhase.idle);
        expect(await stack.sessions.getById(sessionId), isNull);
        expect(await stack.activeState.get(), isNull);
      });

      test('focus violation fails running session', () async {
        final focus = ControllableFocusAdapter();
        addTearDown(focus.dispose);
        final focusStack = await TimerTestStack.open(focusAdapter: focus);
        addTearDown(focusStack.dispose);
        await (focusStack.settings as DriftSettingsRepository).update(
          const AppSettingsPatch(focusMode: FocusMode.strict),
        );
        final focusHarness = TimerCoordinatorRegressionHarness(focusStack);

        await focusStack.coordinator.startPomodoro(focusStack.tagId);
        final sessionId = (await focusStack.sessions.getActiveSession())!.id;

        focus.injectViolation();
        await Future<void>.delayed(Duration.zero);

        final obs = await focusHarness.observe(sessionId: sessionId);
        expect(obs.view.phase, EnginePhase.idle);
        expect(obs.sessionStatus, SessionStatus.failed);
        expect(await focusStack.sessions.getActiveSession(), isNull);
      });
    });

    group('BR-TIMER-025 persistence through coordinator', () {
      test('display tick does not update lastPersistedAtUtcMs', () async {
        await coordinator.startPomodoro(stack.tagId);
        final before = (await stack.activeState.get())!.lastPersistedAtUtcMs;

        stack.clock.advanceSeconds(5);
        await coordinator.tick();

        final after = (await stack.activeState.get())!.lastPersistedAtUtcMs;
        expect(after, before);
        expect(harness.view().phase, EnginePhase.running);
      });

      test('pause transition updates persisted phase', () async {
        await coordinator.startPomodoro(stack.tagId);
        final beforePhase = (await stack.activeState.get())!.enginePhase;
        stack.clock.advance(const Duration(seconds: 1));

        await coordinator.pause();

        final after = await stack.activeState.get();
        expect(beforePhase, EnginePhase.running);
        expect(after!.enginePhase, EnginePhase.paused);
        expect(after.pauseStartedAtUtcMs, isNotNull);
      });

      test('lifecycle background flush persists paused anchors', () async {
        await coordinator.startPomodoro(stack.tagId);
        stack.clock.advanceSeconds(15);
        await coordinator.pause();
        final remainingAtPause = harness.view().displaySec;

        stack.clock.advance(const Duration(minutes: 20));
        await coordinator.onLifecycleBackground();

        final persisted = await stack.activeState.get();
        expect(persisted!.pauseStartedAtUtcMs, isNotNull);
        expect(persisted.frozenRemainingSec, remainingAtPause);
      });
    });

    group('recovery and lifecycle catch-up', () {
      test('resumeFromPersisted clears recovery prompt and restores phase', () async {
        await coordinator.startPomodoro(stack.tagId);
        await coordinator.pause();
        final persisted = await stack.activeState.get();

        final fresh = harness.recreateStack();
        addTearDown(fresh.dispose);
        stack.dispose();

        final freshHarness = TimerCoordinatorRegressionHarness(fresh);
        freshHarness.offerRecovery(persisted!);
        expect(freshHarness.view().showRecoveryPrompt, isTrue);

        final resume = await fresh.coordinator.resumeFromPersisted();
        expect(resume.isOk, isTrue);
        expect(freshHarness.view().showRecoveryPrompt, isFalse);
        expect(freshHarness.view().phase, EnginePhase.paused);
        expect(fresh.coordinator.hasActiveSession, isTrue);
      });

      test('declineRecovery abandons session and clears durable state', () async {
        await coordinator.startPomodoro(stack.tagId);
        await coordinator.pause();
        final sessionId = (await stack.sessions.getActiveSession())!.id;
        final persisted = await stack.activeState.get();

        final fresh = harness.recreateStack();
        addTearDown(fresh.dispose);
        stack.dispose();

        final freshHarness = TimerCoordinatorRegressionHarness(fresh);
        freshHarness.offerRecovery(persisted!);

        final declined = await fresh.coordinator.declineRecovery();
        expect(declined.isOk, isTrue);
        expect(freshHarness.view().phase, EnginePhase.idle);
        expect(freshHarness.view().showRecoveryPrompt, isFalse);
        expect(await fresh.sessions.getActiveSession(), isNull);
        expect(await fresh.activeState.get(), isNull);
        expect(
          (await fresh.sessions.getById(sessionId))!.status,
          SessionStatus.abandoned,
        );
      });

      test(
        'foreground lifecycle catches up overdue Pomodoro segment end',
        () async {
          await harness.configureShortPomodoroTag();
          await coordinator.startPomodoro(stack.tagId);
          await coordinator.onLifecycleBackground();

          stack.clock.advanceSeconds(30);
          await coordinator.onLifecycleForeground();

          expect(harness.view().phase, EnginePhase.segmentComplete);
          final notifications = stack.notifications as RecordingNotificationAdapter;
          expect(notifications.showAlertTitles, isEmpty);
        },
      );
    });

    group('observable view-state stream', () {
      test('phase transitions emit on viewState stream', () async {
        final phases = await harness.captureViewPhases(() async {
          await coordinator.startPomodoro(stack.tagId);
          await coordinator.pause();
        });

        expect(phases, contains(EnginePhase.running));
        expect(phases, contains(EnginePhase.paused));
      });
    });
  });
}

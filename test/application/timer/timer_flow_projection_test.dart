import 'package:pomodoro_app/application/timer/timer_flow_change.dart';
import 'package:pomodoro_app/application/timer/timer_flow_projection.dart';
import 'package:pomodoro_app/application/timer/timer_flow_state.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 6, 1, 12);
  const focusPlan = SegmentPlan(
    type: SegmentType.focus,
    plannedSec: 1500,
    orderIndex: 0,
  );
  const restPlan = SegmentPlan(
    type: SegmentType.shortRest,
    plannedSec: 300,
    orderIndex: 1,
  );

  TimerProjectionContext baseContext({
    TimerEngineState? engineState,
    bool showRecovery = false,
    ActiveTimerState? pending,
    int? preStart,
    String? preStartTag,
    bool hasActiveSession = true,
    String? sessionId = 'session-1',
  }) {
    return TimerProjectionContext(
      engineState: engineState ?? TimerEngineState.initial(),
      nowUtc: now,
      totalActiveSec: 42,
      lifecycleTagId: 'tag-1',
      lifecycleTagName: 'General',
      lifecycleSessionId: sessionId,
      hasActiveSession: hasActiveSession,
      showRecoveryPrompt: showRecovery,
      pendingRecovery: pending,
      preStartCountdown: preStart,
      preStartTagId: preStartTag,
    );
  }

  group('projectTimerFlowState', () {
    test('idle setup when engine idle without overlays', () {
      final flow = projectTimerFlowState(baseContext());
      expect(flow, isA<TimerIdleSetupFlow>());
      expect((flow as TimerIdleSetupFlow).actions.canStartSession, isTrue);
    });

    test('recovery offer takes precedence over idle and pre-start', () {
      final pending = ActiveTimerState(
        sessionId: 'session-1',
        enginePhase: EnginePhase.paused,
        segmentStartedAtUtcMs: now.millisecondsSinceEpoch,
        flexibleReminderActiveSec: 0,
        lastPersistedAtUtcMs: now.millisecondsSinceEpoch,
      );
      final flow = projectTimerFlowState(
        baseContext(
          showRecovery: true,
          pending: pending,
          preStart: 2,
          preStartTag: 'tag-1',
        ),
      );
      expect(flow, isA<TimerRecoveryOfferFlow>());
      final recovery = flow as TimerRecoveryOfferFlow;
      expect(recovery.restoreEnginePhase, EnginePhase.paused);
      expect(recovery.actions.canResume, isTrue);
      expect(recovery.actions.canDecline, isTrue);
    });

    test('Pomodoro pre-start exposes countdown actions only', () {
      final flow = projectTimerFlowState(
        baseContext(preStart: 3, preStartTag: 'tag-1'),
      );
      expect(flow, isA<TimerPomodoroPreStartFlow>());
      final preStart = flow as TimerPomodoroPreStartFlow;
      expect(preStart.countdownSeconds, 3);
      expect(preStart.actions.canSkip, isTrue);
      expect(preStart.actions.canCancel, isTrue);
    });

    test('running exposes pause/stop and rest-only skip break', () {
      final running = TimerEngineState(
        phase: EnginePhase.running,
        mode: TimerMode.pomodoro,
        config: ConfigSnapshot.pomodoroDefaults(),
        segments: const [focusPlan, restPlan],
        currentSegmentIndex: 1,
        segmentStartedAtUtc: now,
        sessionStartedAtUtc: now,
      );
      final flow = projectTimerFlowState(baseContext(engineState: running));
      expect(flow, isA<TimerActiveRunningFlow>());
      final active = flow as TimerActiveRunningFlow;
      expect(active.durableSessionStatus, SessionStatus.active);
      expect(active.actions.canPause, isTrue);
      expect(active.actions.canSkipBreak, isTrue);
      expect(active.actions.canCompleteFlexible, isFalse);
    });

    test('paused flexible can complete', () {
      final paused = TimerEngineState(
        phase: EnginePhase.paused,
        mode: TimerMode.flexible,
        config: ConfigSnapshot.flexibleDefaults(),
        segments: const [focusPlan],
        currentSegmentIndex: 0,
        segmentStartedAtUtc: now,
        sessionStartedAtUtc: now,
        frozenRemainingSec: 0,
      );
      final flow = projectTimerFlowState(baseContext(engineState: paused));
      expect(flow, isA<TimerActivePausedFlow>());
      expect(
        (flow as TimerActivePausedFlow).actions.canCompleteFlexible,
        isTrue,
      );
    });

    test('segment complete exposes advance and optional skip break', () {
      final segmentEnd = TimerEngineState(
        phase: EnginePhase.segmentComplete,
        mode: TimerMode.pomodoro,
        config: ConfigSnapshot.pomodoroDefaults(),
        segments: const [focusPlan, restPlan],
        currentSegmentIndex: 0,
        segmentStartedAtUtc: now,
        sessionStartedAtUtc: now,
      );
      final flow = projectTimerFlowState(baseContext(engineState: segmentEnd));
      expect(flow, isA<TimerSegmentCompleteFlow>());
      final complete = flow as TimerSegmentCompleteFlow;
      expect(complete.pomodoroSummary, isNotNull);
      expect(complete.actions.canAdvanceSegment, isTrue);
      expect(complete.actions.canSkipBreak, isTrue);
    });

    test('Pomodoro session complete keeps durable status active', () {
      final sessionEnd = TimerEngineState(
        phase: EnginePhase.sessionComplete,
        mode: TimerMode.pomodoro,
        config: ConfigSnapshot.pomodoroDefaults(),
        segments: const [focusPlan],
        currentSegmentIndex: 0,
        pomodoroCyclesCompleted: 2,
        pomodoroCyclesTarget: 2,
        segmentStartedAtUtc: now,
        sessionStartedAtUtc: now,
      );
      final flow = projectTimerFlowState(
        baseContext(engineState: sessionEnd, hasActiveSession: true),
      );
      expect(flow, isA<TimerSessionCompleteFlow>());
      expect(
        (flow as TimerSessionCompleteFlow).durableSessionStatus,
        SessionStatus.active,
      );
    });

    test('Flexible session complete after finalize uses completed status', () {
      final sessionEnd = TimerEngineState(
        phase: EnginePhase.sessionComplete,
        mode: TimerMode.flexible,
        config: ConfigSnapshot.flexibleDefaults(),
        segments: const [focusPlan],
        currentSegmentIndex: 0,
        segmentStartedAtUtc: now,
        sessionStartedAtUtc: now,
      );
      final flow = projectTimerFlowState(
        baseContext(
          engineState: sessionEnd,
          hasActiveSession: false,
          sessionId: null,
        ),
      );
      expect(flow, isA<TimerSessionCompleteFlow>());
      expect(
        (flow as TimerSessionCompleteFlow).durableSessionStatus,
        SessionStatus.completed,
      );
    });
  });

  group('projectTimerViewState parity', () {
    test('legacy view-state stays aligned for running session', () {
      final engine = TimerEngineState(
        phase: EnginePhase.running,
        mode: TimerMode.pomodoro,
        config: ConfigSnapshot.pomodoroDefaults(),
        segments: const [focusPlan],
        currentSegmentIndex: 0,
        segmentStartedAtUtc: now,
        sessionStartedAtUtc: now,
      );
      final context = baseContext(engineState: engine);
      final view = projectTimerViewState(context);
      expect(view.phase, EnginePhase.running);
      expect(view.sessionId, 'session-1');
      expect(view.tagId, 'tag-1');
    });
  });

  group('classifyTimerFlowChange', () {
    TimerActiveRunningFlow running({int displaySec = 100}) {
      return TimerActiveRunningFlow(
        mode: TimerMode.pomodoro,
        durableSessionStatus: SessionStatus.active,
        tagId: 'tag-1',
        tagName: 'General',
        sessionId: 'session-1',
        displaySec: displaySec,
        isCountdown: true,
        currentSegmentType: SegmentType.focus,
        completedFocusCount: 0,
        totalFocusInCycle: 4,
        completedCycleCount: 0,
        totalCycleTarget: 2,
        currentPlannedSec: 1500,
        earlyStopGraceRemainingSec: 5,
        actions: const ActiveRunningActions(
          canPause: true,
          canStop: true,
          canSkipBreak: false,
          canCompleteFlexible: false,
        ),
      );
    }

    test('display tick only between running snapshots', () {
      final a = running(displaySec: 100);
      final b = running(displaySec: 99);
      expect(classifyTimerFlowChange(a, b), TimerFlowChangeKind.displayTick);
      expect(sameTimerFlowChrome(a, b), isTrue);
    });

    test('pause transition is active session change', () {
      final a = running();
      final b = TimerActivePausedFlow(
        mode: a.mode,
        durableSessionStatus: a.durableSessionStatus,
        tagId: a.tagId,
        tagName: a.tagName,
        sessionId: a.sessionId,
        displaySec: a.displaySec,
        isCountdown: a.isCountdown,
        currentSegmentType: a.currentSegmentType,
        completedFocusCount: a.completedFocusCount,
        totalFocusInCycle: a.totalFocusInCycle,
        completedCycleCount: a.completedCycleCount,
        totalCycleTarget: a.totalCycleTarget,
        currentPlannedSec: a.currentPlannedSec,
        earlyStopGraceRemainingSec: a.earlyStopGraceRemainingSec,
        actions: const ActivePausedActions(
          canResume: true,
          canStop: true,
          canCompleteFlexible: false,
        ),
      );
      expect(
        classifyTimerFlowChange(a, b),
        TimerFlowChangeKind.activeSession,
      );
    });

    test('pre-start to running is recovery/completion class', () {
      final preStart = TimerPomodoroPreStartFlow(
        tagId: 'tag-1',
        countdownSeconds: 1,
        actions: const PomodoroPreStartActions(canSkip: true, canCancel: true),
      );
      final runningFlow = running();
      expect(
        classifyTimerFlowChange(preStart, runningFlow),
        TimerFlowChangeKind.recoveryOrCompletion,
      );
    });
  });
}

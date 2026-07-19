import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';
import 'package:test/test.dart';

void main() {
  group('buildRunningTimerContent', () {
    final now = DateTime.utc(2026, 7, 11, 12, 0, 0);

    test('Focusing countdown while running', () {
      final content = buildRunningTimerContent(
        state: TimerEngineState(
          phase: EnginePhase.running,
          mode: TimerMode.pomodoro,
          segments: const [
            SegmentPlan(
              type: SegmentType.focus,
              plannedSec: 1500,
              orderIndex: 0,
            ),
          ],
          currentSegmentIndex: 0,
          segmentStartedAtUtc: now.subtract(const Duration(seconds: 60)),
          sessionStartedAtUtc: now.subtract(const Duration(seconds: 60)),
        ),
        sessionId: 's1',
        nowUtc: now,
      );

      expect(content!.title, 'Focusing');
      expect(content.timerLabel, '24:00');
      expect(content.countDown, isTrue);
      expect(
        content.chronometerAnchorUtc,
        now.add(const Duration(seconds: 1440)),
      );
    });

    test('Resting while running', () {
      final content = buildRunningTimerContent(
        state: TimerEngineState(
          phase: EnginePhase.running,
          mode: TimerMode.pomodoro,
          segments: const [
            SegmentPlan(
              type: SegmentType.shortRest,
              plannedSec: 300,
              orderIndex: 1,
            ),
          ],
          currentSegmentIndex: 0,
          segmentStartedAtUtc: now,
          sessionStartedAtUtc: now,
        ),
        sessionId: 's1',
        nowUtc: now,
      );

      expect(content!.title, 'Resting');
      expect(content.timerLabel, '05:00');
    });

    test('paused has static label, no chronometer', () {
      final content = buildRunningTimerContent(
        state: TimerEngineState(
          phase: EnginePhase.paused,
          mode: TimerMode.pomodoro,
          segments: const [
            SegmentPlan(
              type: SegmentType.focus,
              plannedSec: 1500,
              orderIndex: 0,
            ),
          ],
          currentSegmentIndex: 0,
          frozenRemainingSec: 900,
          segmentStartedAtUtc: now.subtract(const Duration(seconds: 600)),
          sessionStartedAtUtc: now.subtract(const Duration(seconds: 600)),
        ),
        sessionId: 's1',
        nowUtc: now,
      );

      expect(content!.timerLabel, '15:00');
      expect(content.chronometerAnchorUtc, isNull);
    });

    test('null when idle', () {
      expect(
        buildRunningTimerContent(
          state: TimerEngineState.initial(),
          sessionId: 's1',
          nowUtc: now,
        ),
        isNull,
      );
    });
  });
}

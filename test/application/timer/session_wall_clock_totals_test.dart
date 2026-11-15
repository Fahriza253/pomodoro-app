import 'package:pomodoro_app/application/timer/session_wall_clock_totals.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/platform/clock/fake_clock_adapter.dart';
import 'package:test/test.dart';

void main() {
  group('SessionWallClockTotals', () {
    late FakeClockAdapter clock;
    late SessionWallClockTotals totals;

    setUp(() {
      clock = FakeClockAdapter();
      totals = SessionWallClockTotals(clock);
    });

    test('Pomodoro active sec subtracts recorded pause', () {
      final started = clock.nowUtc().subtract(const Duration(minutes: 10));
      final state = TimerEngineState(
        phase: EnginePhase.running,
        mode: TimerMode.pomodoro,
        sessionStartedAtUtc: started,
        sessionTotalPausedSec: 120,
      );

      expect(totals.totalActiveSec(state), 480);
      expect(totals.totalPausedSec(state), 120);
    });

    test('flexible active sec uses elapsed helper at clock', () {
      final started = clock.nowUtc().subtract(const Duration(seconds: 90));
      final state = TimerEngineState(
        phase: EnginePhase.running,
        mode: TimerMode.flexible,
        sessionStartedAtUtc: started,
      );

      expect(totals.totalActiveSec(state), 90);
    });
  });
}
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/platform/clock/clock_adapter.dart';

/// Wall-clock active and paused seconds for durable Session/Segment rows.
class SessionWallClockTotals {
  SessionWallClockTotals(this._clock);

  final ClockAdapter _clock;

  int totalActiveSec(TimerEngineState state) {
    if (state.isFlexible) {
      return state.elapsedActiveSecAt(_clock.nowUtc());
    }
    return state.sessionStartedAtUtc == null
        ? 0
        : _clock.nowUtc().difference(state.sessionStartedAtUtc!).inSeconds -
              totalPausedSec(state);
  }

  int totalPausedSec(TimerEngineState state) {
    var paused = state.sessionTotalPausedSec + state.segmentPausedSec;
    if (state.phase == EnginePhase.paused && state.pauseStartedAtUtc != null) {
      paused +=
          _clock.nowUtc().difference(state.pauseStartedAtUtc!).inSeconds;
    }
    return paused < 0 ? 0 : paused;
  }
}
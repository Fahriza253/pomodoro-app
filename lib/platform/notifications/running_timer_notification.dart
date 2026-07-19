import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';

/// Stable id for the ongoing running-timer notification (not segment-end).
const int kRunningTimerNotificationId = 0x52554E54; // 'RUNT'

/// iOS category id registered for the Exit action.
const String kRunningTimerCategoryId = 'running_timer';

/// Snapshot for the background running-timer notification.
class RunningTimerContent {
  const RunningTimerContent({
    required this.title,
    required this.timerLabel,
    required this.sessionId,
    required this.countDown,
    this.chronometerAnchorUtc,
  });

  final String title; // Focusing | Resting
  final String timerLabel; // MM:SS
  final String sessionId;
  final bool countDown;

  /// Android chronometer end (countdown) or start (count-up). Null when paused.
  final DateTime? chronometerAnchorUtc;
}

/// Builds content from engine state, or `null` if nothing to show.
RunningTimerContent? buildRunningTimerContent({
  required TimerEngineState state,
  required String sessionId,
  required DateTime nowUtc,
  String focusingTitle = 'Focusing',
  String restingTitle = 'Resting',
}) {
  if (state.phase != EnginePhase.running && state.phase != EnginePhase.paused) {
    return null;
  }
  final segment = state.currentSegment;
  if (segment == null) return null;

  final countDown = state.isPomodoro;
  final sec = countDown
      ? state.remainingSecAt(nowUtc)
      : state.elapsedActiveSecAt(nowUtc);

  DateTime? anchor;
  if (state.phase == EnginePhase.running) {
    anchor = countDown
        ? nowUtc.add(Duration(seconds: sec))
        : nowUtc.subtract(Duration(seconds: sec));
  }

  return RunningTimerContent(
    title: segment.isRest ? restingTitle : focusingTitle,
    timerLabel: _mmSs(sec),
    sessionId: sessionId,
    countDown: countDown,
    chronometerAnchorUtc: anchor,
  );
}

String _mmSs(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  final s = safe % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '${h.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
}

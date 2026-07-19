import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';

class Session {
  const Session({
    required this.id,
    required this.tagId,
    required this.mode,
    required this.status,
    required this.startedAtUtcMs,
    required this.timelineDate,
    required this.totalActiveSec,
    required this.totalPausedSec,
    required this.configSnapshot,
    required this.pomodoroFocusCount,
    required this.pomodoroCyclesCompleted,
    required this.createdAtUtcMs,
    required this.updatedAtUtcMs,
    this.endedAtUtcMs,
    this.pomodoroCyclesTarget,
  });

  final String id;
  final String tagId;
  final TimerMode mode;
  final SessionStatus status;
  final int startedAtUtcMs;
  final int? endedAtUtcMs;
  final String timelineDate;
  final int totalActiveSec;
  final int totalPausedSec;
  final ConfigSnapshot configSnapshot;
  final int pomodoroFocusCount;
  final int pomodoroCyclesCompleted;
  final int? pomodoroCyclesTarget;
  final int createdAtUtcMs;
  final int updatedAtUtcMs;

  bool get isTerminal => status != SessionStatus.active;
}

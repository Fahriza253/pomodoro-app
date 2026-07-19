import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';

/// Initial plan passed to [TimerEngine.startPomodoro].
class SessionPlan {
  const SessionPlan({
    required this.config,
    required this.segments,
    required this.cyclesTarget,
  });

  final ConfigSnapshot config;
  final List<SegmentPlan> segments;
  final int cyclesTarget;
}

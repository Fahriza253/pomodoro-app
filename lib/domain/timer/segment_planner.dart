import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/models/segment_plan.dart';

/// Builds Pomodoro segment sequences from config snapshot (BR-TIMER-001–004).
class SegmentPlanner {
  const SegmentPlanner();

  /// One Pomodoro cycle: N × focus + (N−1) × short_rest + long_rest.
  List<SegmentPlan> buildCycleSegments(
    ConfigSnapshot config, {
    int startOrderIndex = 0,
  }) {
    _assertPomodoroConfig(config);
    final n = config.sessionsBeforeLongBreak!;
    final segments = <SegmentPlan>[];
    var order = startOrderIndex;

    for (var i = 0; i < n; i++) {
      segments.add(
        SegmentPlan(
          type: SegmentType.focus,
          plannedSec: config.focusDurationSec!,
          orderIndex: order++,
        ),
      );
      if (i < n - 1) {
        segments.add(
          SegmentPlan(
            type: SegmentType.shortRest,
            plannedSec: config.shortBreakDurationSec!,
            orderIndex: order++,
          ),
        );
      }
    }

    segments.add(
      SegmentPlan(
        type: SegmentType.longRest,
        plannedSec: config.longBreakDurationSec!,
        orderIndex: order++,
      ),
    );

    return segments;
  }

  /// Full block: [totalCycles] cycles concatenated (BR-TIMER-007).
  List<SegmentPlan> buildBlockPlan(
    ConfigSnapshot config, {
    int? cycleCount,
    int startOrderIndex = 0,
  }) {
    _assertPomodoroConfig(config);
    final cycles = cycleCount ?? config.totalCycles!;
    final segments = <SegmentPlan>[];
    var order = startOrderIndex;

    for (var c = 0; c < cycles; c++) {
      final cycle = buildCycleSegments(config, startOrderIndex: order);
      segments.addAll(cycle);
      if (cycle.isNotEmpty) {
        order = cycle.last.orderIndex + 1;
      }
    }

    return segments;
  }

  /// Extension block for **Lanjutkan** (BR-TIMER-009).
  List<SegmentPlan> buildExtensionBlock(
    ConfigSnapshot config, {
    required int startOrderIndex,
  }) {
    return buildBlockPlan(
      config,
      cycleCount: config.totalCycles!,
      startOrderIndex: startOrderIndex,
    );
  }

  /// Flexible session: exactly one open-ended segment (BR-SESSION-004).
  SegmentPlan buildFlexibleSegment(ConfigSnapshot config) {
    if (config.mode != TimerMode.flexible) {
      throw ArgumentError('Config mode must be flexible');
    }
    return SegmentPlan(
      type: SegmentType.flexible,
      plannedSec: config.defaultDurationSec ?? 0,
      orderIndex: 0,
    );
  }

  void _assertPomodoroConfig(ConfigSnapshot config) {
    if (config.mode != TimerMode.pomodoro) {
      throw ArgumentError('Config mode must be pomodoro');
    }
    if (config.focusDurationSec == null ||
        config.shortBreakDurationSec == null ||
        config.longBreakDurationSec == null ||
        config.sessionsBeforeLongBreak == null ||
        config.totalCycles == null) {
      throw ArgumentError('Incomplete pomodoro config snapshot');
    }
    if (config.sessionsBeforeLongBreak! < 1) {
      throw ArgumentError('sessionsBeforeLongBreak must be >= 1');
    }
    if (config.totalCycles! < 2 || config.totalCycles! > 8) {
      throw ArgumentError('totalCycles must be between 2 and 8');
    }
  }
}

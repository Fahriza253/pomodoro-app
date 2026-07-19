import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/timer/segment_planner.dart';
import 'package:test/test.dart';

void main() {
  const planner = SegmentPlanner();

  group('SegmentPlanner', () {
    final config = ConfigSnapshot.pomodoroDefaults().copyWith(
      sessionsBeforeLongBreak: 2,
      totalCycles: 2,
      focusDurationSec: 1500,
      shortBreakDurationSec: 300,
      longBreakDurationSec: 900,
    );

    test('buildCycleSegments follows focus → short_rest → long_rest', () {
      final cycle = planner.buildCycleSegments(config);

      expect(cycle, hasLength(4));
      expect(cycle[0].type, SegmentType.focus);
      expect(cycle[1].type, SegmentType.shortRest);
      expect(cycle[2].type, SegmentType.focus);
      expect(cycle[3].type, SegmentType.longRest);
    });

    test('buildBlockPlan concatenates totalCycles cycles', () {
      final plan = planner.buildBlockPlan(config);

      expect(plan, hasLength(8));
      expect(plan.first.orderIndex, 0);
      expect(plan.last.orderIndex, 7);
      expect(plan.where((s) => s.type == SegmentType.longRest), hasLength(2));
    });

    test('buildExtensionBlock appends with continuous orderIndex', () {
      final extension = planner.buildBlockPlan(
        config,
        cycleCount: 1,
        startOrderIndex: 6,
      );

      expect(extension, hasLength(4));
      expect(extension.first.orderIndex, 6);
    });

    test('buildFlexibleSegment is single open-ended segment', () {
      final flex = planner.buildFlexibleSegment(
        ConfigSnapshot.flexibleDefaults(),
      );

      expect(flex.type, SegmentType.flexible);
      expect(flex.plannedSec, 0);
      expect(flex.orderIndex, 0);
    });
  });
}

extension _ConfigCopy on ConfigSnapshot {
  ConfigSnapshot copyWith({
    TimerMode? mode,
    int? focusDurationSec,
    int? shortBreakDurationSec,
    int? longBreakDurationSec,
    int? sessionsBeforeLongBreak,
    int? totalCycles,
    bool? autoStartBreak,
    bool? autoStartFocus,
    int? defaultDurationSec,
    int? reminderIntervalMin,
    bool? reminderEnabled,
  }) {
    return ConfigSnapshot(
      mode: mode ?? this.mode,
      focusDurationSec: focusDurationSec ?? this.focusDurationSec,
      shortBreakDurationSec:
          shortBreakDurationSec ?? this.shortBreakDurationSec,
      longBreakDurationSec: longBreakDurationSec ?? this.longBreakDurationSec,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      totalCycles: totalCycles ?? this.totalCycles,
      autoStartBreak: autoStartBreak ?? this.autoStartBreak,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      defaultDurationSec: defaultDurationSec ?? this.defaultDurationSec,
      reminderIntervalMin: reminderIntervalMin ?? this.reminderIntervalMin,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }
}

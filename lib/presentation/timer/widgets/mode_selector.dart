import 'package:flutter/material.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final TimerMode selected;
  final ValueChanged<TimerMode> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kTimerModeTabMaxWidth * 2),
        child: SizedBox(
          width: double.infinity,
          child: SegmentedButton<TimerMode>(
            segments: [
              ButtonSegment(
                value: TimerMode.pomodoro,
                label: Text(l10n.modePomodoro),
              ),
              ButtonSegment(
                value: TimerMode.flexible,
                label: Text(l10n.modeFlexible),
              ),
            ],
            selected: {selected},
            onSelectionChanged: enabled
                ? (modes) => onChanged(modes.first)
                : null,
            showSelectedIcon: false,
          ),
        ),
      ),
    );
  }
}

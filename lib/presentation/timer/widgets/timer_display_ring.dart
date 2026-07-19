import 'package:flutter/material.dart';
import 'package:pomodoro_app/presentation/timer/timer_format.dart';

/// Large timer readout with optional circular progress for an active session.
class TimerDisplayRing extends StatelessWidget {
  const TimerDisplayRing({
    required this.displaySec,
    required this.isCountdown,
    this.plannedSec,
    this.subtitle,
    this.centerChild,
    this.showRing = true,
    super.key,
  });

  final int displaySec;
  final bool isCountdown;
  final int? plannedSec;
  final String? subtitle;
  final Widget? centerChild;

  /// When false (e.g. pre-start 3-2-1), only the label/text is shown.
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readout = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        centerChild ??
            Text(
              formatTimerSeconds(
                displaySec,
                forceHours: !isCountdown && displaySec >= 3600,
              ),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (!showRing) {
      return readout;
    }

    final progress = _progressValue();

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: progress != null
                ? CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  )
                : CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    color: theme.colorScheme.surfaceContainerHighest,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
          ),
          readout,
        ],
      ),
    );
  }

  double? _progressValue() {
    if (!isCountdown || plannedSec == null || plannedSec! <= 0) {
      return null;
    }
    final remaining = displaySec.clamp(0, plannedSec!);
    return 1 - (remaining / plannedSec!);
  }
}

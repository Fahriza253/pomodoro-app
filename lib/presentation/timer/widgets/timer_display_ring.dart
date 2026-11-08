import 'package:flutter/material.dart';
import 'package:pomodoro_app/app/theme/segment_semantic_color.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/timer/timer_format.dart';

/// Large timer readout with optional circular progress for an active session.
class TimerDisplayRing extends StatelessWidget {
  const TimerDisplayRing({
    required this.displaySec,
    required this.isCountdown,
    required this.segmentType,
    this.plannedSec,
    this.subtitle,
    this.centerChild,
    this.showRing = true,
    super.key,
  });

  final int displaySec;
  final bool isCountdown;
  final SegmentType segmentType;
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
              style: theme.textTheme.displaySmall,
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
    final ringColor = segmentSemanticColor(theme.colorScheme, segmentType);
    final trackColor = theme.colorScheme.surfaceContainerHighest;

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
                    color: ringColor,
                    backgroundColor: trackColor,
                  )
                : CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    color: ringColor,
                    backgroundColor: trackColor,
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

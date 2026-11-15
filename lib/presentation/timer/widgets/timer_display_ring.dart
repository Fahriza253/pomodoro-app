import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:pomodoro_app/app/theme/segment_semantic_color.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/timer/timer_format.dart';

/// Large timer readout with optional circular progress for an active session.
class TimerDisplayRing extends StatefulWidget {
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
  State<TimerDisplayRing> createState() => _TimerDisplayRingState();
}

class _TimerDisplayRingState extends State<TimerDisplayRing>
    with SingleTickerProviderStateMixin {
  static const _ringSize = 220.0;
  static const _strokeWidth = 10.0;
  static const _progressAnimMs = 220;

  late final AnimationController _progressController;
  double _animatedProgress = 0;
  double _fromProgress = 0;
  double _toProgress = 0;

  @override
  void initState() {
    super.initState();
    _toProgress = _progressValue() ?? 0;
    _animatedProgress = _toProgress;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _progressAnimMs),
    )..addListener(_onProgressTick);
  }

  @override
  void didUpdateWidget(TimerDisplayRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextTarget = _progressValue() ?? _toProgress;
    if (nextTarget == _toProgress && oldWidget.displaySec == widget.displaySec) {
      return;
    }
    _fromProgress = _animatedProgress;
    _toProgress = nextTarget;
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      _progressController.stop();
      setState(() => _animatedProgress = _toProgress);
      return;
    }
    _progressController
      ..stop()
      ..reset();
    _progressController.forward();
  }

  void _onProgressTick() {
    final t = Curves.easeOutCubic.transform(_progressController.value);
    setState(() {
      _animatedProgress = lerpDouble(_fromProgress, _toProgress, t)!;
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final heroStyle = theme.textTheme.displayMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final readout = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.centerChild ??
            Text(
              formatTimerSeconds(
                widget.displaySec,
                forceHours: !widget.isCountdown && widget.displaySec >= 3600,
              ),
              style: heroStyle,
            ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.subtitle!,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (!widget.showRing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: readout,
      );
    }

    final ringColor = segmentSemanticColor(scheme, widget.segmentType);
    final trackColor = scheme.surfaceContainerHighest;
    final progress = widget.isCountdown && widget.plannedSec != null
        ? _animatedProgress.clamp(0.0, 1.0)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: _ringSize,
        height: _ringSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(_ringSize, _ringSize),
              painter: _TimerRingPainter(
                progress: progress,
                ringColor: ringColor,
                trackColor: trackColor,
                strokeWidth: _strokeWidth,
                indeterminate: progress == null,
              ),
            ),
            readout,
          ],
        ),
      ),
    );
  }

  double? _progressValue() {
    if (!widget.isCountdown || widget.plannedSec == null || widget.plannedSec! <= 0) {
      return null;
    }
    final remaining = widget.displaySec.clamp(0, widget.plannedSec!);
    return 1 - (remaining / widget.plannedSec!);
  }
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
    required this.indeterminate,
  });

  final double? progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;
  final bool indeterminate;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final arcPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (indeterminate) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.2,
        2.4,
        false,
        arcPaint,
      );
      return;
    }

    final sweep = (progress ?? 0).clamp(0.0, 1.0) * 6.283185307179586;
    if (sweep <= 0) {
      return;
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963267948966,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.indeterminate != indeterminate;
  }
}
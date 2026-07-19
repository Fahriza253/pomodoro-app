import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';

/// Progress thresholds for [SlideToStop].
@visibleForTesting
abstract final class SlideToStopThresholds {
  /// Red fill starts appearing at this fraction of the track.
  static const reveal = 0.25;

  /// Release commits stop at/above this fraction.
  static const release = 0.80;
}

/// 0 below [SlideToStopThresholds.reveal]; ramps 0→1 from reveal→release; 1 above.
@visibleForTesting
double slideToStopRedIntensity(double progress) {
  final p = progress.clamp(0.0, 1.0);
  if (p < SlideToStopThresholds.reveal) return 0;
  if (p >= SlideToStopThresholds.release) return 1;
  return (p - SlideToStopThresholds.reveal) /
      (SlideToStopThresholds.release - SlideToStopThresholds.reveal);
}

/// Horizontal slide-to-confirm stop control (no dialog).
///
/// Idle is neutral (no red). Red fill appears from 25% slide; at 80% the control
/// arms ("Release to Stop") with haptic. Releasing while armed calls [onStop];
/// otherwise the thumb snaps back.
class SlideToStop extends StatefulWidget {
  const SlideToStop({
    required this.onStop,
    required this.idleLabel,
    this.width = 220,
    this.height = 56,
    super.key,
  });

  final Future<void> Function() onStop;
  final String idleLabel;
  final double width;
  final double height;

  @override
  State<SlideToStop> createState() => _SlideToStopState();
}

class _SlideToStopState extends State<SlideToStop>
    with SingleTickerProviderStateMixin {
  static const _thumbSize = 48.0;
  static const _trackPadding = 4.0;

  double _dragExtent = 0;
  bool _armed = false;
  bool _stopping = false;

  late final AnimationController _snapController;
  Animation<double>? _snapAnimation;

  double get _maxDrag => widget.width - _thumbSize - (_trackPadding * 2);

  double get _progress =>
      _maxDrag <= 0 ? 0 : (_dragExtent / _maxDrag).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _snapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 280),
        )..addListener(() {
          final anim = _snapAnimation;
          if (anim == null) {
            return;
          }
          setState(() => _dragExtent = anim.value);
        });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_stopping) {
      return;
    }
    _snapController.stop();
    setState(() {
      _dragExtent = (_dragExtent + details.delta.dx).clamp(0.0, _maxDrag);
      final wasArmed = _armed;
      _armed = _progress >= SlideToStopThresholds.release;
      if (_armed && !wasArmed) {
        HapticFeedback.mediumImpact();
      }
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (_stopping) {
      return;
    }
    if (_armed) {
      setState(() => _stopping = true);
      HapticFeedback.heavyImpact();
      try {
        await widget.onStop();
      } finally {
        if (mounted) {
          setState(() {
            _stopping = false;
            _dragExtent = 0;
            _armed = false;
          });
        }
      }
      return;
    }
    _snapBack();
  }

  void _snapBack() {
    _snapAnimation = Tween<double>(begin: _dragExtent, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController
      ..reset()
      ..forward();
    setState(() => _armed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = _progress;
    final red = slideToStopRedIntensity(progress);
    final l10n = context.l10n;

    final trackFill = red <= 0
        ? Colors.transparent
        : Color.lerp(
            scheme.errorContainer.withValues(alpha: 0.25),
            scheme.error.withValues(alpha: 0.55),
            red,
          )!;

    final thumbColor = Color.lerp(scheme.surface, scheme.error, red)!;
    final thumbIconColor = Color.lerp(
      scheme.onSurfaceVariant,
      scheme.onError,
      red,
    )!;

    return Semantics(
      button: true,
      label: l10n.slideToStopSemantics,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              onHorizontalDragCancel: _snapBack,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 40),
                        width: _trackPadding + _dragExtent + _thumbSize / 2,
                        decoration: BoxDecoration(color: trackFill),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: Text(
                          _armed ? l10n.releaseToStop : widget.idleLabel,
                          key: ValueKey(_armed ? 'release' : widget.idleLabel),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: _armed
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _trackPadding + _dragExtent,
                    child: AnimatedScale(
                      scale: _armed ? 1.06 : 1,
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutBack,
                      child: Material(
                        color: thumbColor,
                        elevation: 2,
                        shadowColor: scheme.shadow.withValues(alpha: 0.35),
                        shape: const CircleBorder(),
                        child: SizedBox(
                          width: _thumbSize,
                          height: _thumbSize,
                          child: Icon(
                            Icons.stop_rounded,
                            color: thumbIconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

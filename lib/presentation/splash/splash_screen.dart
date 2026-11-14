import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:pomodoro_app/presentation/splash/splash_reveal_painter.dart';

/// Brand splash while the local database opens / seeds.
///
/// Transparent except the overlay paint so a parent [Stack] can show home
/// through the circle hole.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    this.onSequenceComplete,
    this.destinationReady = true,
    super.key,
  });

  /// Marketing beat length when motion is enabled.
  static const sequenceDuration = Duration(milliseconds: 2000);

  /// Wordmark intro ends here; circle exit reveal runs until `1.0`.
  static const wordmarkPhaseEnd = 0.42;

  /// Fired once when the beat finishes, or immediately when animations are disabled.
  final VoidCallback? onSequenceComplete;

  /// When false, hold at the end of the wordmark until home can show through the hole.
  final bool destinationReady;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<double> _scale;
  late final Animation<double> _reveal;
  var _notified = false;
  var _holdingForDestination = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SplashScreen.sequenceDuration,
    );
    _wordmarkOpacity = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1),
          weight: SplashScreen.wordmarkPhaseEnd * 100,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 0),
          weight: (1 - SplashScreen.wordmarkPhaseEnd) * 100,
        ),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _scale = TweenSequence<double>(
      [
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.92, end: 1),
          weight: SplashScreen.wordmarkPhaseEnd * 100,
        ),
        TweenSequenceItem(
          tween: ConstantTween<double>(1),
          weight: (1 - SplashScreen.wordmarkPhaseEnd) * 100,
        ),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _reveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          SplashScreen.wordmarkPhaseEnd,
          1,
          curve: Curves.easeInCubic,
        ),
      ),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _notifyComplete();
      }
    });
    _controller.addListener(_holdForDestination);
    SchedulerBinding.instance.scheduleFrameCallback((_) => _startSequence());
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinationReady && !oldWidget.destinationReady) {
      _onDestinationReady();
    }
  }

  void _holdForDestination() {
    if (widget.destinationReady || _holdingForDestination) {
      return;
    }
    if (_controller.value < SplashScreen.wordmarkPhaseEnd) {
      return;
    }
    _holdingForDestination = true;
    _controller.stop();
    if (_controller.value != SplashScreen.wordmarkPhaseEnd) {
      _controller.value = SplashScreen.wordmarkPhaseEnd;
    }
  }

  void _onDestinationReady() {
    if (!mounted || _controller.isCompleted) {
      return;
    }
    _holdingForDestination = false;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _notifyComplete();
      return;
    }
    if (!_controller.isAnimating) {
      _controller.forward();
    }
  }

  void _startSequence() {
    if (!mounted || _controller.isAnimating || _controller.isCompleted) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      if (widget.destinationReady) {
        _controller.value = 1;
        _notifyComplete();
      } else {
        _controller.value = SplashScreen.wordmarkPhaseEnd;
      }
      return;
    }
    _controller.forward();
  }

  void _notifyComplete() {
    if (_notified) {
      return;
    }
    _notified = true;
    final onComplete = widget.onSequenceComplete;
    if (onComplete == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_holdForDestination);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final origin = Offset(size.width / 2, size.height / 2);

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (context, _) {
                return CustomPaint(
                  painter: SplashRevealPainter(
                    reveal: _reveal.value,
                    origin: origin,
                    overlayColor: colors.surface,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _wordmarkOpacity.value,
                  child: Transform.scale(scale: _scale.value, child: child),
                );
              },
              child: Center(
                child: Text(
                  'Pomodoro',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Brand splash while the local database opens / seeds.
///
/// Must be placed under a parent [MaterialApp] (see [PomodoroApp] loading branch).
class SplashScreen extends StatefulWidget {
  const SplashScreen({this.onSequenceComplete, super.key});

  /// Marketing beat length when motion is enabled.
  static const sequenceDuration = Duration(milliseconds: 800);

  /// Fired once when the beat finishes, or immediately when animations are disabled.
  final VoidCallback? onSequenceComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  var _notified = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SplashScreen.sequenceDuration,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curved;
    _scale = Tween<double>(begin: 0.92, end: 1).animate(curved);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _notifyComplete();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSequence());
  }

  void _startSequence() {
    if (!mounted || _controller.isAnimating || _controller.isCompleted) {
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _notifyComplete();
      return;
    }
    _controller.forward();
  }

  void _notifyComplete() {
    if (_notified) {
      return;
    }
    _notified = true;
    widget.onSequenceComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fade.value,
              child: Transform.scale(scale: _scale.value, child: child),
            );
          },
          child: Text(
            'Pomodoro',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Pomodoro session-complete Lottie per `docs/design/MASTER.md` (once, ≤1.5s).
class SessionCompleteLottie extends StatefulWidget {
  const SessionCompleteLottie({required this.asset, super.key});

  final String asset;

  static const maxDuration = Duration(milliseconds: 1500);

  @override
  State<SessionCompleteLottie> createState() => _SessionCompleteLottieState();
}

class _SessionCompleteLottieState extends State<SessionCompleteLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 160,
      width: 160,
      child: Lottie.asset(
        widget.asset,
        controller: _controller,
        repeat: false,
        fit: BoxFit.contain,
        onLoaded: (composition) {
          final clip = composition.duration > SessionCompleteLottie.maxDuration
              ? SessionCompleteLottie.maxDuration
              : composition.duration;
          _controller
            ..duration = clip
            ..forward(from: 0);
        },
      ),
    );
  }
}

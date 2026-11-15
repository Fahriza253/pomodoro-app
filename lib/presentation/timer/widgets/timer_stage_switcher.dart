import 'package:flutter/material.dart';

/// State-chrome cross-fade between timer stage bodies (idle → session, pre-start → run).
class TimerStageSwitcher extends StatelessWidget {
  const TimerStageSwitcher({
    required this.stageKey,
    required this.child,
    super.key,
  });

  final String stageKey;
  final Widget child;

  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduced ? Duration.zero : _duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) {
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            ...previous,
            ?current,
          ],
        );
      },
      transitionBuilder: _stageTransition,
      child: KeyedSubtree(
        key: ValueKey(stageKey),
        child: child,
      ),
    );
  }

  static Widget _stageTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
        child: child,
      ),
    );
  }
}
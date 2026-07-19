import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/timer_providers.dart';

/// Persists active timer state on background (BR-TIMER-025).
class TimerLifecycleObserver extends ConsumerStatefulWidget {
  const TimerLifecycleObserver({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<TimerLifecycleObserver> createState() =>
      _TimerLifecycleObserverState();
}

class _TimerLifecycleObserverState extends ConsumerState<TimerLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final coordinator = ref.read(timerCoordinatorProvider);
    if (state == AppLifecycleState.resumed) {
      coordinator.onLifecycleForeground();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      coordinator.onLifecycleBackground();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

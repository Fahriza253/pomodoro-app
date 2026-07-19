/// Invalid state-machine transition in [TimerEngine].
class TimerTransitionError implements Exception {
  TimerTransitionError(this.message, {this.code = 'TIMER_INVALID_TRANSITION'});

  final String message;
  final String code;

  @override
  String toString() => 'TimerTransitionError($code): $message';
}

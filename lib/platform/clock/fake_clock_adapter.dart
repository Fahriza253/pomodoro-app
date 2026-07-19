import 'package:pomodoro_app/platform/clock/clock_adapter.dart';

/// Controllable clock for domain unit tests.
class FakeClockAdapter implements ClockAdapter {
  FakeClockAdapter([DateTime? initial])
      : _now = (initial ?? DateTime.utc(2026, 6, 28, 8)).toUtc();

  DateTime _now;

  @override
  DateTime nowUtc() => _now;

  void set(DateTime value) {
    _now = value.toUtc();
  }

  void advance(Duration duration) {
    _now = _now.add(duration);
  }

  void advanceSeconds(int seconds) {
    advance(Duration(seconds: seconds));
  }
}

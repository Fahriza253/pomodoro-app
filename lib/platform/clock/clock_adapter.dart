/// Injectable UTC clock for timer engine tests (BR-GLOBAL-003).
abstract class ClockAdapter {
  DateTime nowUtc();
}

/// Production clock — returns [DateTime.now] in UTC.
class SystemClockAdapter implements ClockAdapter {
  const SystemClockAdapter();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

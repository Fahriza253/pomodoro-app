/// Truncates [utc] to whole seconds so iOS NSISO8601DateFormatter can parse
/// flutter_local_notifications calendar triggers (microsecond ISO often fails).
DateTime truncateUtcToSeconds(DateTime utc) {
  final u = utc.toUtc();
  return DateTime.utc(u.year, u.month, u.day, u.hour, u.minute, u.second);
}

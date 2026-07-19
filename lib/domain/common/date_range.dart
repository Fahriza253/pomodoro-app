/// UTC millisecond range for repository queries (exclusive end).
class DateRange {
  const DateRange({required this.startUtcMs, required this.endUtcMs});

  final int startUtcMs;
  final int endUtcMs;
}

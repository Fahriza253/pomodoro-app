import 'package:pomodoro_app/domain/common/date_range.dart';
import 'package:pomodoro_app/domain/common/enums.dart';

/// Converts local calendar periods to UTC query ranges (BR-STAT-004, BR-STAT-005).
class PeriodCalculator {
  const PeriodCalculator();

  String formatTimelineDate(DateTime localDate) {
    final y = localDate.year.toString().padLeft(4, '0');
    final m = localDate.month.toString().padLeft(2, '0');
    final d = localDate.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DateTime parseTimelineDate(String timelineDate) {
    final parts = timelineDate.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  DateRange dayBounds(DateTime localDate) {
    final start = DateTime(localDate.year, localDate.month, localDate.day);
    final end = start.add(const Duration(days: 1));
    return DateRange(
      startUtcMs: start.toUtc().millisecondsSinceEpoch,
      endUtcMs: end.toUtc().millisecondsSinceEpoch,
    );
  }

  DateRange weekBounds(DateTime localNow, int weekStartDay) {
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final targetWeekday = _weekdayFromSettings(weekStartDay);
    var cursor = today;
    while (cursor.weekday != targetWeekday) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    final end = cursor.add(const Duration(days: 7));
    return DateRange(
      startUtcMs: cursor.toUtc().millisecondsSinceEpoch,
      endUtcMs: end.toUtc().millisecondsSinceEpoch,
    );
  }

  DateRange monthBounds(DateTime localNow) {
    final start = DateTime(localNow.year, localNow.month);
    final end = DateTime(localNow.year, localNow.month + 1);
    return DateRange(
      startUtcMs: start.toUtc().millisecondsSinceEpoch,
      endUtcMs: end.toUtc().millisecondsSinceEpoch,
    );
  }

  DateRange yearBounds(DateTime localNow) {
    final start = DateTime(localNow.year);
    final end = DateTime(localNow.year + 1);
    return DateRange(
      startUtcMs: start.toUtc().millisecondsSinceEpoch,
      endUtcMs: end.toUtc().millisecondsSinceEpoch,
    );
  }

  DateRange totalBounds(DateTime localNow) {
    final end = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
    ).add(const Duration(days: 1));
    return DateRange(
      startUtcMs: 0,
      endUtcMs: end.toUtc().millisecondsSinceEpoch,
    );
  }

  DateRange rangeForPeriod({
    required StatisticPeriod period,
    required DateTime anchorLocal,
    required int weekStartDay,
  }) {
    return switch (period) {
      StatisticPeriod.daily => dayBounds(anchorLocal),
      StatisticPeriod.weekly => weekBounds(anchorLocal, weekStartDay),
      StatisticPeriod.monthly => monthBounds(anchorLocal),
      StatisticPeriod.yearly => yearBounds(anchorLocal),
      StatisticPeriod.total => totalBounds(anchorLocal),
    };
  }

  int _weekdayFromSettings(int weekStartDay) =>
      weekStartDay == 0 ? DateTime.sunday : weekStartDay;
}

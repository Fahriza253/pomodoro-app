import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';

void main() {
  final anchor = DateTime(2026, 7, 11);

  test('recentMonths ends at anchor month', () {
    final months = recentMonths(anchor: anchor, count: 12);
    expect(months, hasLength(12));
    expect(months.first, DateTime(2025, 8));
    expect(months.last, DateTime(2026, 7));
  });

  test('daysInMonthUntil caps current month at today', () {
    expect(daysInMonthUntil(DateTime(2026, 7), anchor), [
      for (var d = 1; d <= 11; d++) DateTime(2026, 7, d),
    ]);
    expect(daysInMonthUntil(DateTime(2026, 8), anchor), isEmpty);
    expect(daysInMonthUntil(DateTime(2026, 6), anchor), hasLength(30));
  });

  test('clampDayToMonth keeps day in range', () {
    expect(
      clampDayToMonth(DateTime(2026, 1, 31), DateTime(2026, 2), anchor),
      DateTime(2026, 2, 28),
    );
    expect(
      clampDayToMonth(DateTime(2026, 7, 20), DateTime(2026, 7), anchor),
      DateTime(2026, 7, 11),
    );
  });
}

import 'package:pomodoro_app/domain/statistic/period_calculator.dart';
import 'package:test/test.dart';

void main() {
  const calculator = PeriodCalculator();

  group('PeriodCalculator', () {
    test('dayBounds covers single local day', () {
      final local = DateTime(2026, 6, 15, 14, 30);
      final range = calculator.dayBounds(local);
      final startLocal = DateTime.fromMillisecondsSinceEpoch(
        range.startUtcMs,
        isUtc: true,
      ).toLocal();
      final endLocal = DateTime.fromMillisecondsSinceEpoch(
        range.endUtcMs,
        isUtc: true,
      ).toLocal();
      expect(startLocal.day, 15);
      expect(endLocal.difference(startLocal).inHours, 24);
    });

    test('weekBounds starts on Monday when weekStartDay=1 (BR-STAT-005)', () {
      final wednesday = DateTime(2026, 6, 17);
      final range = calculator.weekBounds(wednesday, 1);
      final startLocal = DateTime.fromMillisecondsSinceEpoch(
        range.startUtcMs,
        isUtc: true,
      ).toLocal();
      expect(startLocal.weekday, DateTime.monday);
      expect(startLocal.day, 15);
    });

    test('formatTimelineDate returns YYYY-MM-DD', () {
      expect(calculator.formatTimelineDate(DateTime(2026, 6, 5)), '2026-06-05');
    });
  });
}

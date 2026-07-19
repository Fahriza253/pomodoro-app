import 'package:pomodoro_app/platform/notifications/notification_schedule_time.dart';
import 'package:test/test.dart';

void main() {
  group('truncateUtcToSeconds', () {
    test('strips microseconds for iOS calendar trigger safety', () {
      final raw = DateTime.utc(2026, 7, 11, 10, 30, 45, 123, 456);
      final truncated = truncateUtcToSeconds(raw);
      expect(truncated.isUtc, isTrue);
      expect(truncated.year, 2026);
      expect(truncated.month, 7);
      expect(truncated.day, 11);
      expect(truncated.hour, 10);
      expect(truncated.minute, 30);
      expect(truncated.second, 45);
      expect(truncated.millisecond, 0);
      expect(truncated.microsecond, 0);
    });

    test('converts local input to UTC before truncating', () {
      final local = DateTime(2026, 7, 11, 17, 0, 1, 999);
      final truncated = truncateUtcToSeconds(local);
      expect(truncated.isUtc, isTrue);
      expect(truncated.microsecond, 0);
      expect(truncated.millisecond, 0);
    });
  });
}

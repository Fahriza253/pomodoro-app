import 'package:pomodoro_app/application/timer/segment_end_delivery.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);
  final fireAt = now.add(const Duration(seconds: 30));
  final due = now;

  group('planSegmentEndFire', () {
    test('foreground live complete is in-app', () {
      expect(
        planSegmentEndFire(
          foreground: true,
          suppress: false,
          scheduleEnqueued: false,
          scheduledFireAtUtc: null,
          nowUtc: now,
        ),
        SegmentEndFireDelivery.inApp,
      );
    });

    test('foreground catch-up after successful due schedule is silent', () {
      expect(
        planSegmentEndFire(
          foreground: true,
          suppress: false,
          scheduleEnqueued: true,
          scheduledFireAtUtc: due,
          nowUtc: now,
        ),
        SegmentEndFireDelivery.silent,
      );
    });

    test('foreground catch-up after failed enqueue is in-app fallback', () {
      expect(
        planSegmentEndFire(
          foreground: true,
          suppress: false,
          scheduleEnqueued: false,
          scheduledFireAtUtc: due,
          nowUtc: now,
          enqueueAttempted: true,
        ),
        SegmentEndFireDelivery.inApp,
      );
    });

    test('background with successful schedule is silent (OS owns)', () {
      expect(
        planSegmentEndFire(
          foreground: false,
          suppress: false,
          scheduleEnqueued: true,
          scheduledFireAtUtc: fireAt,
          nowUtc: now,
        ),
        SegmentEndFireDelivery.silent,
      );
    });

    test('background with nothing scheduled posts OS immediately', () {
      expect(
        planSegmentEndFire(
          foreground: false,
          suppress: false,
          scheduleEnqueued: false,
          scheduledFireAtUtc: null,
          nowUtc: now,
        ),
        SegmentEndFireDelivery.osImmediate,
      );
    });

    test('suppress is silent', () {
      expect(
        planSegmentEndFire(
          foreground: true,
          suppress: true,
          scheduleEnqueued: false,
          scheduledFireAtUtc: null,
          nowUtc: now,
        ),
        SegmentEndFireDelivery.silent,
      );
    });

    test('cold-start catch-up assumes OS owned', () {
      expect(
        planSegmentEndFire(
          foreground: true,
          suppress: false,
          scheduleEnqueued: false,
          scheduledFireAtUtc: null,
          nowUtc: now,
          osOwnedCatchUp: true,
        ),
        SegmentEndFireDelivery.silent,
      );
    });
  });

  group('planSegmentEndSchedule', () {
    test('foreground does not schedule', () {
      expect(
        planSegmentEndSchedule(
          foreground: true,
          remainingSec: 30,
          existingFireAtUtc: null,
          nowUtc: now,
        ),
        SegmentEndScheduleDecision.skip,
      );
    });

    test('background with remaining schedules', () {
      expect(
        planSegmentEndSchedule(
          foreground: false,
          remainingSec: 30,
          existingFireAtUtc: null,
          nowUtc: now,
        ),
        SegmentEndScheduleDecision.replace,
      );
    });

    test('remaining zero skips (cannot schedule in the past)', () {
      expect(
        planSegmentEndSchedule(
          foreground: false,
          remainingSec: 0,
          existingFireAtUtc: null,
          nowUtc: now,
        ),
        SegmentEndScheduleDecision.skip,
      );
    });

    test('due pending schedule is left alone', () {
      expect(
        planSegmentEndSchedule(
          foreground: false,
          remainingSec: 300,
          existingFireAtUtc: now,
          nowUtc: now,
        ),
        SegmentEndScheduleDecision.leaveDue,
      );
    });

    test('after due fire time, next segment may replace', () {
      expect(
        planSegmentEndSchedule(
          foreground: false,
          remainingSec: 300,
          existingFireAtUtc: now.subtract(const Duration(seconds: 1)),
          nowUtc: now,
        ),
        SegmentEndScheduleDecision.replace,
      );
    });
  });
}

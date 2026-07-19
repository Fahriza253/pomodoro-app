import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/application/timer/segment_end_copy.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:test/test.dart';

void main() {
  group('SegmentEndCopy', () {
    test('focus → short break includes finished, next, and progress', () {
      final copy = SegmentEndCopy.build(
        strings: NotificationStrings.en,
        finished: SegmentType.focus,
        next: SegmentType.shortRest,
        completedCount: 1,
        totalCount: 8,
      );
      expect(copy.title, 'Focus complete');
      expect(
        copy.body,
        'Focus finished. Next: Short break. 1 of 8 segments done.',
      );
    });

    test('short break → focus', () {
      final copy = SegmentEndCopy.build(
        strings: NotificationStrings.en,
        finished: SegmentType.shortRest,
        next: SegmentType.focus,
        completedCount: 2,
        totalCount: 8,
      );
      expect(copy.title, 'Short break complete');
      expect(
        copy.body,
        'Short break finished. Next: Focus. 2 of 8 segments done.',
      );
    });

    test('last segment uses session-complete copy', () {
      final copy = SegmentEndCopy.build(
        strings: NotificationStrings.id,
        finished: SegmentType.longRest,
        next: null,
        completedCount: 8,
        totalCount: 8,
        sessionComplete: true,
      );
      expect(copy.title, 'Session selesai');
      expect(
        copy.body,
        'Istirahat panjang selesai. Session selesai. 8 dari 8 segmen selesai.',
      );
    });
  });
}

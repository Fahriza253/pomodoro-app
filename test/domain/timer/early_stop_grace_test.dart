import 'package:pomodoro_app/domain/timer/early_stop_grace.dart';
import 'package:test/test.dart';

void main() {
  group('earlyStopGrace', () {
    test('remaining is full grace at zero elapsed', () {
      expect(earlyStopGraceRemainingSec(0), kEarlyStopGraceSec);
      expect(isWithinEarlyStopGrace(0), isTrue);
    });

    test('remaining decreases with active elapsed', () {
      expect(earlyStopGraceRemainingSec(3), 7);
      expect(isWithinEarlyStopGrace(3), isTrue);
    });

    test('grace ends at threshold', () {
      expect(earlyStopGraceRemainingSec(kEarlyStopGraceSec), 0);
      expect(isWithinEarlyStopGrace(kEarlyStopGraceSec), isFalse);
      expect(isWithinEarlyStopGrace(kEarlyStopGraceSec + 5), isFalse);
    });
  });
}

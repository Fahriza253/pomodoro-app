import 'package:pomodoro_app/presentation/timer/widgets/slide_to_stop.dart';
import 'package:test/test.dart';

void main() {
  group('slideToStopRedIntensity', () {
    test('is zero below reveal threshold', () {
      expect(slideToStopRedIntensity(0), 0);
      expect(slideToStopRedIntensity(0.24), 0);
    });

    test('ramps between reveal and release', () {
      expect(slideToStopRedIntensity(SlideToStopThresholds.reveal), 0);
      expect(slideToStopRedIntensity(0.525), closeTo(0.5, 0.001));
      expect(slideToStopRedIntensity(SlideToStopThresholds.release), 1);
    });

    test('is full at and above release', () {
      expect(slideToStopRedIntensity(0.9), 1);
      expect(slideToStopRedIntensity(1), 1);
    });
  });
}

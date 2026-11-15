import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/shared/fluid_overscroll.dart';

void main() {
  group('fluidRubberBand', () {
    test('maps one dimension of overscroll to about 35 percent', () {
      expect(
        fluidRubberBand(overscroll: 100, dimension: 100),
        closeTo(35.4839, 0.001),
      );
    });

    test('zero overscroll or dimension is zero', () {
      expect(fluidRubberBand(overscroll: 0, dimension: 100), 0);
      expect(fluidRubberBand(overscroll: 50, dimension: 0), 0);
    });
  });

  group('fluidVisualOverscroll', () {
    test('passes through values inside the rest range', () {
      expect(fluidVisualOverscroll(0.4, min: 0, max: 1), 0.4);
    });

    test('clamps below min and rubber-bands above max', () {
      expect(fluidVisualOverscroll(-0.2, min: 0, max: 1), 0);
      expect(fluidVisualOverscroll(2, min: 0, max: 1), closeTo(1.3548, 0.001));
    });
  });

  group('tagSelectSheetHeight', () {
    test('clamps content between 50 and 80 percent of the viewport', () {
      expect(
        tagSelectSheetHeight(viewportHeight: 1000, contentHeight: 100),
        500,
      );
      expect(
        tagSelectSheetHeight(viewportHeight: 1000, contentHeight: 900),
        800,
      );
      expect(
        tagSelectSheetHeight(viewportHeight: 1000, contentHeight: 650),
        650,
      );
    });
  });

  group('tagSelectSheetTranslationY', () {
    test('closed is one sheet height down, open is zero', () {
      expect(
        tagSelectSheetTranslationY(
          linearProgress: 0,
          sheetHeight: 400,
          viewportHeight: 800,
        ),
        400,
      );
      expect(
        tagSelectSheetTranslationY(
          linearProgress: 1,
          sheetHeight: 400,
          viewportHeight: 800,
        ),
        0,
      );
    });

    test('overshoot does not translate; height grows instead', () {
      expect(
        tagSelectSheetTranslationY(
          linearProgress: 3,
          sheetHeight: 640,
          viewportHeight: 800,
        ),
        0,
      );
    });
  });

  group('tagSelectSheetDisplayHeight', () {
    test('rest height is unchanged at and below fully open', () {
      expect(
        tagSelectSheetDisplayHeight(
          linearProgress: 1,
          restHeight: 400,
          availableHeight: 800,
        ),
        400,
      );
    });

    test('overshoot grows height but stays within available space', () {
      final height = tagSelectSheetDisplayHeight(
        linearProgress: 3,
        restHeight: 640,
        availableHeight: 800,
      );
      expect(height, greaterThan(640));
      expect(height, lessThanOrEqualTo(800));
    });
  });

  group('tagSwipeActionIconOpacity', () {
    test('stays hidden until 40 percent then reaches 1 at full reveal', () {
      expect(tagSwipeActionIconOpacity(0.4), 0);
      expect(tagSwipeActionIconOpacity(0.7), closeTo(0.5, 0.001));
      expect(tagSwipeActionIconOpacity(1), 1);
    });
  });
}

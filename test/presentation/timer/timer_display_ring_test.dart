import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/theme/app_theme.dart';
import 'package:pomodoro_app/app/theme/segment_semantic_color.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_display_ring.dart';

void main() {
  group('TimerDisplayRing', () {
    Future<Color?> ringForegroundColor(WidgetTester tester) async {
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      return indicator.color;
    }

    testWidgets('progress stroke uses segment semantic color', (tester) async {
      final theme = AppThemeData.light();
      final scheme = theme.colorScheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: TimerDisplayRing(
            displaySec: 60,
            isCountdown: true,
            plannedSec: 120,
            segmentType: SegmentType.shortRest,
          ),
        ),
      );

      expect(
        await ringForegroundColor(tester),
        segmentSemanticColor(scheme, SegmentType.shortRest),
      );
    });

    testWidgets('count-up flexible session ring uses primary segment color', (
      tester,
    ) async {
      final theme = AppThemeData.light();
      final scheme = theme.colorScheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: TimerDisplayRing(
            displaySec: 90,
            isCountdown: false,
            segmentType: SegmentType.flexible,
          ),
        ),
      );

      expect(
        await ringForegroundColor(tester),
        segmentSemanticColor(scheme, SegmentType.flexible),
      );
    });

    testWidgets('hide ring when showRing is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TimerDisplayRing(
            displaySec: 3,
            isCountdown: true,
            plannedSec: 3,
            showRing: false,
            segmentType: SegmentType.focus,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('00:03'), findsOneWidget);
    });
  });
}

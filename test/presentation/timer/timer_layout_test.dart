import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';

void main() {
  group('TimerStageLayout', () {
    testWidgets(
      'pins top and bottom rows to 100 px and centers children in leftover',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerStageLayout(
                header: SizedBox(key: Key('header'), height: 40, width: 120),
                visual: SizedBox(key: Key('visual'), height: 80, width: 120),
                footer: SizedBox(key: Key('footer'), height: 40, width: 120),
              ),
            ),
          ),
        );

        final stage = tester.getRect(find.byType(TimerStageLayout));
        final header = tester.getRect(find.byKey(const Key('header')));
        final visual = tester.getRect(find.byKey(const Key('visual')));
        final footer = tester.getRect(find.byKey(const Key('footer')));
        final innerTop = stage.top + kTimerStagePadding.top;
        final innerBottom = stage.bottom - kTimerStagePadding.bottom;
        final innerHeight = innerBottom - innerTop;
        final centerHeight =
            innerHeight - (kTimerStageRowMinHeight * 2);

        expect(header.center.dy, closeTo(innerTop + kTimerStageRowMinHeight / 2, 0.5));
        expect(
          visual.center.dy,
          closeTo(
            innerTop + kTimerStageRowMinHeight + centerHeight / 2,
            0.5,
          ),
        );
        expect(
          footer.center.dy,
          closeTo(innerBottom - kTimerStageRowMinHeight / 2, 0.5),
        );
        expect(header.center.dx, closeTo(stage.center.dx, 0.5));
        expect(visual.center.dx, closeTo(stage.center.dx, 0.5));
        expect(footer.center.dx, closeTo(stage.center.dx, 0.5));
      },
    );

    testWidgets('grows a row past 100 px when its child is taller', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerStageLayout(
              header: SizedBox(key: Key('header'), height: 140, width: 80),
              visual: SizedBox(key: Key('visual'), height: 40, width: 80),
              footer: SizedBox(key: Key('footer'), height: 40, width: 80),
            ),
          ),
        ),
      );

      final stage = tester.getRect(find.byType(TimerStageLayout));
      final header = tester.getRect(find.byKey(const Key('header')));
      final innerTop = stage.top + kTimerStagePadding.top;

      expect(header.height, 140);
      expect(header.top, closeTo(innerTop, 0.5));
    });

    testWidgets('reserves 100 px when header or footer is missing', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerStageLayout(
              visual: SizedBox(key: Key('visual'), height: 80, width: 120),
            ),
          ),
        ),
      );

      final stage = tester.getRect(find.byType(TimerStageLayout));
      final visual = tester.getRect(find.byKey(const Key('visual')));
      final innerTop = stage.top + kTimerStagePadding.top;
      final innerBottom = stage.bottom - kTimerStagePadding.bottom;
      final innerHeight = innerBottom - innerTop;
      final centerHeight = innerHeight - (kTimerStageRowMinHeight * 2);

      expect(
        visual.center.dy,
        closeTo(
          innerTop + kTimerStageRowMinHeight + centerHeight / 2,
          0.5,
        ),
      );
    });
  });
}

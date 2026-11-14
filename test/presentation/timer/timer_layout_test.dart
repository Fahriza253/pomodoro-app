import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/timer/timer_layout.dart';

void main() {
  group('TimerStageLayout', () {
    testWidgets(
      'gives the visual 30% of leftover height as equal inner margin',
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

        final leftover =
            stage.height -
            kTimerStagePadding.vertical -
            header.height -
            visual.height -
            footer.height;
        final inner = timerStageInnerSlotGap(leftover);

        expect(visual.top - header.bottom, closeTo(inner, 0.5));
        expect(footer.top - visual.bottom, closeTo(inner, 0.5));
        expect(
          (visual.top - header.bottom) + (footer.top - visual.bottom),
          closeTo(leftover * kTimerStageVisualMarginFraction, 0.5),
        );
      },
    );

    testWidgets('keeps the 30% inner margin on a shorter window', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerStageLayout(
              header: SizedBox(key: Key('header'), height: 24, width: 80),
              visual: SizedBox(key: Key('visual'), height: 48, width: 80),
              footer: SizedBox(key: Key('footer'), height: 24, width: 80),
            ),
          ),
        ),
      );

      final stage = tester.getRect(find.byType(TimerStageLayout));
      final header = tester.getRect(find.byKey(const Key('header')));
      final visual = tester.getRect(find.byKey(const Key('visual')));
      final footer = tester.getRect(find.byKey(const Key('footer')));
      final leftover =
          stage.height -
          kTimerStagePadding.vertical -
          header.height -
          visual.height -
          footer.height;
      final inner = timerStageInnerSlotGap(leftover);

      expect(visual.top - header.bottom, closeTo(inner, 0.5));
    });
  });
}

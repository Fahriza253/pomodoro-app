import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/shared/fluid_bottom_sheet.dart';
import 'package:pomodoro_app/presentation/shared/fluid_overscroll.dart';

void main() {
  testWidgets('fluid sheet pins to the overlay bottom at min height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showFluidBottomSheet<void>(
                    context,
                    builder: (context, close) {
                      return FluidSheetColumn(
                        title: 'Sheet title',
                        child: TextButton(
                          onPressed: () => close(null),
                          child: const Text('Done'),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet title'), findsOneWidget);
    final viewportH =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final panel = tester.getSize(
      find
          .ancestor(
            of: find.text('Sheet title'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(panel.height, closeTo(viewportH * kFluidSheetMinHeightFraction, 1));

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet title'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/timer/widgets/timer_info_chip.dart';

void main() {
  testWidgets('pads 10 px on the sides and 10 px between icon and label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TimerInfoChip(
              icon: Icons.tag,
              label: 'Work',
              iconColor: Colors.black,
              background: Colors.grey,
              foreground: Colors.black,
            ),
          ),
        ),
      ),
    );

    final chip = tester.getRect(find.byType(TimerInfoChip));
    final icon = tester.getRect(find.byIcon(Icons.tag));
    final label = tester.getRect(find.text('Work'));

    expect(icon.left - chip.left, closeTo(kTimerInfoChipHorizontalPadding, 0.5));
    expect(chip.right - label.right, closeTo(kTimerInfoChipHorizontalPadding, 0.5));
    expect(label.left - icon.right, closeTo(kTimerInfoChipIconLabelGap, 0.5));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:pomodoro_app/presentation/timer/widgets/session_complete_lottie.dart';

void main() {
  testWidgets('skips Lottie when reduced motion is enabled', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SessionCompleteLottie(asset: 'assets/lottie/winner.json'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Lottie), findsNothing);
  });

  test('max Lottie duration is 1.5 seconds', () {
    expect(
      SessionCompleteLottie.maxDuration,
      const Duration(milliseconds: 1500),
    );
  });
}

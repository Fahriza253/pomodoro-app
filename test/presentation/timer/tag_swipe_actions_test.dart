import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/presentation/timer/widgets/tag_swipe_actions.dart';

void main() {
  group('clampTagSwipeExtent', () {
    test('opens on left drag in LTR', () {
      expect(
        clampTagSwipeExtent(
          current: 0,
          deltaDx: -40,
          maxExtent: 112,
          isRtl: false,
        ),
        40,
      );
    });

    test('ignores right drag past zero in LTR', () {
      expect(
        clampTagSwipeExtent(
          current: 10,
          deltaDx: 40,
          maxExtent: 112,
          isRtl: false,
        ),
        0,
      );
    });

    test('opens on right drag in RTL', () {
      expect(
        clampTagSwipeExtent(
          current: 0,
          deltaDx: 40,
          maxExtent: 112,
          isRtl: true,
        ),
        40,
      );
    });
  });

  group('tagSwipeShouldSnapOpen', () {
    test('snaps at 40 percent of max', () {
      expect(tagSwipeShouldSnapOpen(44, 112), isFalse);
      expect(tagSwipeShouldSnapOpen(45, 112), isTrue);
      expect(tagSwipeShouldSnapOpen(0, 0), isFalse);
    });
  });

  testWidgets('drag past threshold reports open', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TagSwipeActions(
            actionsWidth: 112,
            isOpen: false,
            onOpenChanged: (open) => opened = open,
            actions: const SizedBox(
              width: 112,
              height: 56,
              child: Text('ACTIONS'),
            ),
            child: const SizedBox(
              width: 300,
              height: 56,
              child: ColoredBox(
                color: Colors.white,
                child: Center(child: Text('ROW')),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.text('ROW'), const Offset(-80, 0));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    expect(find.text('ACTIONS'), findsOneWidget);
  });
}

import 'package:pomodoro_app/application/timer/immediate_event_delivery.dart';
import 'package:test/test.dart';

void main() {
  group('planImmediateEventFire', () {
    test('foreground first fire is in-app', () {
      expect(
        planImmediateEventFire(
          foreground: true,
          osPosted: false,
          osPostAttempted: false,
          inAppPlayed: false,
        ),
        ImmediateEventDelivery.inApp,
      );
    });

    test('background first fire posts OS immediately', () {
      expect(
        planImmediateEventFire(
          foreground: false,
          osPosted: false,
          osPostAttempted: false,
          inAppPlayed: false,
        ),
        ImmediateEventDelivery.osImmediate,
      );
    });

    test('successful OS post is silent on resume', () {
      expect(
        planImmediateEventFire(
          foreground: true,
          osPosted: true,
          osPostAttempted: true,
          inAppPlayed: false,
        ),
        ImmediateEventDelivery.silent,
      );
    });

    test('successful OS post is not posted a second time', () {
      expect(
        planImmediateEventFire(
          foreground: false,
          osPosted: true,
          osPostAttempted: true,
          inAppPlayed: false,
        ),
        ImmediateEventDelivery.silent,
      );
    });

    test('failed OS post falls back to in-app when visible', () {
      expect(
        planImmediateEventFire(
          foreground: true,
          osPosted: false,
          osPostAttempted: true,
          inAppPlayed: false,
        ),
        ImmediateEventDelivery.inApp,
      );
    });

    test('failed OS post stays silent while still background', () {
      expect(
        planImmediateEventFire(
          foreground: false,
          osPosted: false,
          osPostAttempted: true,
          inAppPlayed: false,
        ),
        ImmediateEventDelivery.silent,
      );
    });

    test('in-app delivery is not replayed', () {
      expect(
        planImmediateEventFire(
          foreground: true,
          osPosted: false,
          osPostAttempted: false,
          inAppPlayed: true,
        ),
        ImmediateEventDelivery.silent,
      );
    });
  });
}

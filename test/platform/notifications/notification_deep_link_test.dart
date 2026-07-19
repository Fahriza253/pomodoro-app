import 'package:pomodoro_app/platform/notifications/notification_deep_link.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationDeepLink', () {
    test('timerSessionUri embeds sessionId query param', () {
      final uri = NotificationDeepLink.timerSessionUri('abc-123');
      expect(uri.path, '/timer');
      expect(uri.queryParameters['sessionId'], 'abc-123');
    });

    test('uriFromPayload treats plain string as sessionId', () {
      final uri = NotificationDeepLink.uriFromPayload('session-xyz');
      expect(uri?.queryParameters['sessionId'], 'session-xyz');
    });

    test('uriFromPayload parses path payload', () {
      final uri = NotificationDeepLink.uriFromPayload('/timer?sessionId=abc');
      expect(uri?.queryParameters['sessionId'], 'abc');
    });

    test('uriFromResponse maps Exit action to exit deep link', () {
      final uri = NotificationDeepLink.uriFromResponse(
        actionId: NotificationDeepLink.actionExit,
        isAction: true,
        payload: '/timer?sessionId=abc',
      );
      expect(NotificationDeepLink.isExit(uri!), isTrue);
      expect(uri.queryParameters['sessionId'], 'abc');
    });

    test('uriFromResponse keeps body tap as session deep link', () {
      final uri = NotificationDeepLink.uriFromResponse(
        actionId: null,
        isAction: false,
        payload: '/timer?sessionId=abc',
      );
      expect(NotificationDeepLink.isExit(uri!), isFalse);
      expect(uri.queryParameters['sessionId'], 'abc');
    });

    test('timerSessionUri can mark segment_end source', () {
      final uri = NotificationDeepLink.timerSessionUri(
        'abc',
        source: NotificationDeepLink.sourceSegmentEnd,
      );
      expect(NotificationDeepLink.isSegmentEnd(uri), isTrue);
    });

    test('isSegmentEnd is false without source', () {
      final uri = NotificationDeepLink.timerSessionUri('abc');
      expect(NotificationDeepLink.isSegmentEnd(uri), isFalse);
    });

    test('uriFromPayload rejects non-/timer paths', () {
      expect(NotificationDeepLink.uriFromPayload('/settings'), isNull);
      expect(
        NotificationDeepLink.uriFromPayload('/timeline?sessionId=abc'),
        isNull,
      );
    });

    test('timerSessionUri percent-encodes sessionId', () {
      final uri = NotificationDeepLink.timerSessionUri('a b/c?d');
      expect(uri.queryParameters['sessionId'], 'a b/c?d');
      // Dart encodes space as `+` in form-urlencoded query components.
      expect(uri.toString(), contains('sessionId=a+b%2Fc%3Fd'));
    });

    test('matchesActiveSession requires sessionId equality', () {
      final uri = NotificationDeepLink.timerExitUri('active-1');
      expect(
        NotificationDeepLink.matchesActiveSession(uri, 'active-1'),
        isTrue,
      );
      expect(NotificationDeepLink.matchesActiveSession(uri, 'other'), isFalse);
      expect(NotificationDeepLink.matchesActiveSession(uri, null), isFalse);
    });
  });
}

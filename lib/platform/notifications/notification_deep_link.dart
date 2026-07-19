/// Deep link helpers for notification tap (BR-NAV-001).
class NotificationDeepLink {
  const NotificationDeepLink._();

  static const timerPath = '/timer';
  static const actionExit = 'exit';
  static const sourceSegmentEnd = 'segment_end';

  static Uri timerSessionUri(String sessionId, {String? source}) => Uri(
    path: timerPath,
    queryParameters: {'sessionId': sessionId, 'source': ?source},
  );

  /// Exit action from the running-timer notification.
  static Uri timerExitUri(String sessionId) => Uri(
    path: timerPath,
    queryParameters: {'sessionId': sessionId, 'action': actionExit},
  );

  static bool isTimerPath(Uri uri) => uri.path == timerPath;

  static bool isExit(Uri uri) => uri.queryParameters['action'] == actionExit;

  static bool isSegmentEnd(Uri uri) =>
      uri.queryParameters['source'] == sourceSegmentEnd;

  /// True when [uri] carries a sessionId that matches the active session.
  static bool matchesActiveSession(Uri uri, String? activeSessionId) {
    final sessionId = uri.queryParameters['sessionId'];
    return sessionId != null && sessionId == activeSessionId;
  }

  static Uri? uriFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    if (payload.startsWith('/')) {
      final uri = Uri.parse(payload);
      return isTimerPath(uri) ? uri : null;
    }
    return timerSessionUri(payload);
  }

  /// Maps a notification response to a deep-link URI (body tap or Exit action).
  static Uri? uriFromResponse({
    required String? actionId,
    required bool isAction,
    required String? payload,
  }) {
    final base = uriFromPayload(payload);
    if (isAction && actionId == actionExit) {
      final sessionId = base?.queryParameters['sessionId'];
      return sessionId == null ? null : timerExitUri(sessionId);
    }
    return base;
  }
}

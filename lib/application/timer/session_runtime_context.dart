import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';

/// In-memory Session identity and Segment row ids aligned with the engine.
class SessionRuntimeContext {
  String? sessionId;
  String? tagId;
  String? tagName;
  List<String> segmentIds = const [];

  bool get hasActiveSession => sessionId != null;

  String? segmentIdAtIndex(int index) {
    if (index < 0 || index >= segmentIds.length) {
      return null;
    }
    return segmentIds[index];
  }

  String? currentSegmentId(TimerEngineState state) =>
      segmentIdAtIndex(state.currentSegmentIndex);

  void bindSession({
    required String sessionId,
    required String tagId,
    required String? tagName,
    required List<String> segmentIds,
  }) {
    this.sessionId = sessionId;
    this.tagId = tagId;
    this.tagName = tagName;
    this.segmentIds = segmentIds;
  }

  void appendSegmentIds(Iterable<String> ids) {
    segmentIds = [...segmentIds, ...ids];
  }

  void clearAfterTerminal({required bool retainTagContext}) {
    if (retainTagContext) {
      sessionId = null;
      segmentIds = const [];
      return;
    }
    clearAll();
  }

  void clearSessionOnly() {
    sessionId = null;
    segmentIds = const [];
  }

  void clearAll() {
    sessionId = null;
    tagId = null;
    tagName = null;
    segmentIds = const [];
  }
}
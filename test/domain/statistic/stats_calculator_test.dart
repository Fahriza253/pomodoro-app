import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/statistic/stats_calculator.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:test/test.dart';

void main() {
  const settings = AppSettings(
    id: 'default',
    alertToneFocusSuccess: AlertToneCatalog.defaultFocusSuccess,
    alertToneBreakOver: AlertToneCatalog.defaultBreakOver,
    alertToneFocusFailure: AlertToneCatalog.defaultFocusFailure,
    alertHapticEnabled: true,
    alertSoundMuted: false,
    alertFlashEnabled: false,
    focusMode: FocusMode.loose,
    whitelist: [],
    focusViolationThresholdSec: 5,
    theme: AppTheme.system,
    alwaysOnDisplay: false,
    language: 'en',
    weekStartDay: 1,
    timeFormat: TimeFormat.h24,
    trackFailedSessions: false,
    updatedAtUtcMs: 1,
  );

  const snapshot = ConfigSnapshot(mode: TimerMode.pomodoro);

  Session session({
    required String id,
    required SessionStatus status,
    String tagId = 'tag-1',
  }) {
    return Session(
      id: id,
      tagId: tagId,
      mode: TimerMode.pomodoro,
      status: status,
      startedAtUtcMs: 1_000,
      endedAtUtcMs: 2_000,
      timelineDate: '2026-06-01',
      totalActiveSec: 100,
      totalPausedSec: 0,
      configSnapshot: snapshot,
      pomodoroFocusCount: 1,
      pomodoroCyclesCompleted: 1,
      createdAtUtcMs: 1,
      updatedAtUtcMs: 1,
    );
  }

  const calculator = StatsCalculator();

  group('StatsCalculator', () {
    test('excludes active sessions (BR-STAT-001)', () {
      final summary = calculator.aggregate(
        sessions: [
          session(id: 's1', status: SessionStatus.active),
          session(id: 's2', status: SessionStatus.completed),
        ],
        segmentsBySessionId: {
          's2': const [
            SessionSegment(
              id: 'seg',
              sessionId: 's2',
              type: SegmentType.focus,
              orderIndex: 0,
              plannedSec: 100,
              actualSec: 100,
              segmentPausedSec: 0,
              segmentStatus: SegmentStatus.completed,
            ),
          ],
        },
        settings: settings,
        tagsById: const {
          'tag-1': Tag(
            id: 'tag-1',
            name: 'General',
            color: '#6366F1',
            sortOrder: 0,
            createdAtUtcMs: 1,
            updatedAtUtcMs: 1,
          ),
        },
      );

      expect(summary.sessionCount, 1);
      expect(summary.focusDurationSec, 100);
    });

    test('excludes failed when trackFailedSessions false (BR-STAT-006)', () {
      final summary = calculator.aggregate(
        sessions: [session(id: 's1', status: SessionStatus.failed)],
        segmentsBySessionId: const {},
        settings: settings,
        tagsById: const {},
      );
      expect(summary.sessionCount, 0);
    });

    test('includes failed focus seconds when trackFailedSessions true', () {
      final withFailed = AppSettings(
        id: 'default',
        alertToneFocusSuccess: AlertToneCatalog.defaultFocusSuccess,
        alertToneBreakOver: AlertToneCatalog.defaultBreakOver,
        alertToneFocusFailure: AlertToneCatalog.defaultFocusFailure,
        alertHapticEnabled: true,
        alertSoundMuted: false,
        alertFlashEnabled: false,
        focusMode: FocusMode.loose,
        whitelist: const [],
        focusViolationThresholdSec: 5,
        theme: AppTheme.system,
        alwaysOnDisplay: false,
        language: 'en',
        weekStartDay: 1,
        timeFormat: TimeFormat.h24,
        trackFailedSessions: true,
        updatedAtUtcMs: 1,
      );
      final summary = calculator.aggregate(
        sessions: [session(id: 's1', status: SessionStatus.failed)],
        segmentsBySessionId: {
          's1': const [
            SessionSegment(
              id: 'seg',
              sessionId: 's1',
              type: SegmentType.focus,
              orderIndex: 0,
              plannedSec: 1500,
              actualSec: 420,
              segmentPausedSec: 0,
              segmentStatus: SegmentStatus.completed,
            ),
          ],
        },
        settings: withFailed,
        tagsById: const {},
      );
      expect(summary.sessionCount, 1);
      expect(summary.focusDurationSec, 420);
    });

    test('includes manual sessions (BR-STAT-008)', () {
      final summary = calculator.aggregate(
        sessions: [session(id: 's1', status: SessionStatus.manual)],
        segmentsBySessionId: {
          's1': const [
            SessionSegment(
              id: 'seg',
              sessionId: 's1',
              type: SegmentType.focus,
              orderIndex: 0,
              plannedSec: 600,
              actualSec: 600,
              segmentPausedSec: 0,
              segmentStatus: SegmentStatus.completed,
            ),
          ],
        },
        settings: settings,
        tagsById: const {},
      );
      expect(summary.sessionCount, 1);
      expect(summary.focusDurationSec, 600);
      expect(summary.breakDurationSec, 0);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/timeline/segment_detail_visual.dart';

SessionSegment _segment({
  required SegmentType type,
  required SegmentStatus status,
  required int plannedSec,
  required int actualSec,
  int? endedAtUtcMs,
}) {
  return SessionSegment(
    id: 'seg-1',
    sessionId: 'session-1',
    type: type,
    orderIndex: 0,
    plannedSec: plannedSec,
    actualSec: actualSec,
    segmentPausedSec: 0,
    segmentStatus: status,
    endedAtUtcMs: endedAtUtcMs,
  );
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('SegmentDetailVisual.fromSegment', () {
    test('completed focus with full duration is success', () {
      final visual = SegmentDetailVisual.fromSegment(
        _segment(
          type: SegmentType.focus,
          status: SegmentStatus.completed,
          plannedSec: 1500,
          actualSec: 1500,
        ),
        l10n: l10n,
      );

      expect(visual.outcome, SegmentDetailOutcome.success);
      expect(visual.icon, Icons.check_circle_outline);
    });

    test('completed focus with partial duration is warning', () {
      final visual = SegmentDetailVisual.fromSegment(
        _segment(
          type: SegmentType.focus,
          status: SegmentStatus.completed,
          plannedSec: 1500,
          actualSec: 900,
        ),
        l10n: l10n,
      );

      expect(visual.outcome, SegmentDetailOutcome.partial);
      expect(visual.icon, Icons.warning_amber_outlined);
      expect(visual.statusLabel, l10n.segmentIncomplete);
    });

    test('skipped rest is skipped visual', () {
      final visual = SegmentDetailVisual.fromSegment(
        _segment(
          type: SegmentType.shortRest,
          status: SegmentStatus.skipped,
          plannedSec: 300,
          actualSec: 0,
        ),
        l10n: l10n,
      );

      expect(visual.outcome, SegmentDetailOutcome.skipped);
      expect(visual.icon, Icons.skip_next);
      expect(visual.statusLabel, l10n.segmentSkipped);
    });

    test('active segment without end shows in progress', () {
      final visual = SegmentDetailVisual.fromSegment(
        _segment(
          type: SegmentType.focus,
          status: SegmentStatus.active,
          plannedSec: 1500,
          actualSec: 600,
        ),
        sessionStatus: SessionStatus.active,
        l10n: l10n,
      );

      expect(visual.outcome, SegmentDetailOutcome.active);
      expect(visual.statusLabel, l10n.segmentRunning);
    });

    test('active segment with endedAt is not running', () {
      final visual = SegmentDetailVisual.fromSegment(
        _segment(
          type: SegmentType.focus,
          status: SegmentStatus.active,
          plannedSec: 1500,
          actualSec: 600,
          endedAtUtcMs: 1,
        ),
        l10n: l10n,
      );

      expect(visual.outcome, isNot(SegmentDetailOutcome.active));
      expect(visual.statusLabel, isNot(l10n.segmentRunning));
    });

    test('active segment on terminal session is not running', () {
      final visual = SegmentDetailVisual.fromSegment(
        _segment(
          type: SegmentType.focus,
          status: SegmentStatus.active,
          plannedSec: 1500,
          actualSec: 600,
        ),
        sessionStatus: SessionStatus.abandoned,
        l10n: l10n,
      );

      expect(visual.outcome, isNot(SegmentDetailOutcome.active));
      expect(visual.statusLabel, isNot(l10n.segmentRunning));
    });

    test('stale active focus with partial actual shows partial', () {
      final visual = SegmentDetailVisual.fromSegment(
        _segment(
          type: SegmentType.focus,
          status: SegmentStatus.active,
          plannedSec: 1500,
          actualSec: 900,
          endedAtUtcMs: 1,
        ),
        sessionStatus: SessionStatus.abandoned,
        l10n: l10n,
      );

      expect(visual.outcome, SegmentDetailOutcome.partial);
      expect(visual.statusLabel, l10n.segmentIncomplete);
    });

    test('stale active with zero actual shows skipped', () {
      final visual = SegmentDetailVisual.fromSegment(
        _segment(
          type: SegmentType.focus,
          status: SegmentStatus.active,
          plannedSec: 1500,
          actualSec: 0,
          endedAtUtcMs: 1,
        ),
        sessionStatus: SessionStatus.abandoned,
        l10n: l10n,
      );

      expect(visual.outcome, SegmentDetailOutcome.skipped);
      expect(visual.statusLabel, l10n.segmentSkipped);
    });
  });
}

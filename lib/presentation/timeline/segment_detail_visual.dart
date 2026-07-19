import 'package:flutter/material.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';

enum SegmentDetailOutcome { success, partial, skipped, active }

class SegmentDetailVisual {
  const SegmentDetailVisual({
    required this.outcome,
    required this.icon,
    required this.iconColor,
    this.statusLabel,
  });

  final SegmentDetailOutcome outcome;
  final IconData icon;
  final Color Function(ColorScheme scheme) iconColor;
  final String? statusLabel;

  /// Maps a segment to timeline detail chrome.
  ///
  /// [sessionStatus] gates "Berjalan": only a live [SessionStatus.active]
  /// session may show an in-progress segment. Stale `active` rows (e.g. after
  /// auto-abandon) MUST NOT look like a running timer.
  static SegmentDetailVisual fromSegment(
    SessionSegment segment, {
    SessionStatus? sessionStatus,
    required AppLocalizations l10n,
  }) {
    if (segment.segmentStatus == SegmentStatus.skipped) {
      return SegmentDetailVisual(
        outcome: SegmentDetailOutcome.skipped,
        icon: Icons.skip_next,
        iconColor: (scheme) => scheme.onSurfaceVariant,
        statusLabel: l10n.segmentSkipped,
      );
    }

    if (segment.segmentStatus == SegmentStatus.active) {
      final isLive =
          (sessionStatus == null || sessionStatus == SessionStatus.active) &&
          segment.endedAtUtcMs == null;
      if (isLive) {
        return SegmentDetailVisual(
          outcome: SegmentDetailOutcome.active,
          icon: Icons.play_circle_outline,
          iconColor: (scheme) => scheme.primary,
          statusLabel: l10n.segmentRunning,
        );
      }
      return _interrupted(segment, l10n);
    }

    if (segment.segmentStatus == SegmentStatus.completed) {
      return _completed(segment, l10n);
    }

    return SegmentDetailVisual(
      outcome: SegmentDetailOutcome.skipped,
      icon: Icons.more_horiz,
      iconColor: (scheme) => scheme.onSurfaceVariant,
    );
  }

  static SegmentDetailVisual _interrupted(
    SessionSegment segment,
    AppLocalizations l10n,
  ) {
    final isFocusLike =
        segment.type == SegmentType.focus ||
        segment.type == SegmentType.flexible;
    if (isFocusLike &&
        segment.actualSec > 0 &&
        segment.actualSec < segment.plannedSec) {
      return SegmentDetailVisual(
        outcome: SegmentDetailOutcome.partial,
        icon: Icons.warning_amber_outlined,
        iconColor: (scheme) => scheme.tertiary,
        statusLabel: l10n.segmentIncomplete,
      );
    }
    return SegmentDetailVisual(
      outcome: SegmentDetailOutcome.skipped,
      icon: Icons.skip_next,
      iconColor: (scheme) => scheme.onSurfaceVariant,
      statusLabel: l10n.segmentSkipped,
    );
  }

  static SegmentDetailVisual _completed(
    SessionSegment segment,
    AppLocalizations l10n,
  ) {
    final isFocusLike =
        segment.type == SegmentType.focus ||
        segment.type == SegmentType.flexible;
    if (isFocusLike && segment.actualSec < segment.plannedSec) {
      return SegmentDetailVisual(
        outcome: SegmentDetailOutcome.partial,
        icon: Icons.warning_amber_outlined,
        iconColor: (scheme) => scheme.tertiary,
        statusLabel: l10n.segmentIncomplete,
      );
    }
    return SegmentDetailVisual(
      outcome: SegmentDetailOutcome.success,
      icon: Icons.check_circle_outline,
      iconColor: (scheme) => scheme.primary,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timeline/timeline_models.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';
import 'package:pomodoro_app/presentation/shared/tag_color_dot.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/session_segment_tile.dart';

class TimelineSessionDetailBody extends StatelessWidget {
  const TimelineSessionDetailBody({
    required this.detail,
    required this.timeFormat,
    super.key,
  });

  final SessionDetail detail;
  final TimeFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final session = detail.session;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            TagColorDot(hex: detail.tagColor, size: 12),
            const SizedBox(width: 8),
            Text(
              l10n.sessionTagAndMode(
                detail.tagDisplayName,
                timerModeLabel(session.mode, l10n),
              ),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.sessionStatusPrefix(sessionStatusLabel(session.status, l10n))),
        Text(
          formatTimeRange(
            session.startedAtUtcMs,
            session.endedAtUtcMs,
            timeFormat,
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.totalActive(formatDurationSec(session.totalActiveSec, l10n))),
        Text(l10n.totalPaused(formatDurationSec(session.totalPausedSec, l10n))),
        if (session.mode == TimerMode.pomodoro &&
            session.pomodoroCyclesTarget != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.cycleProgress(
              session.pomodoroCyclesCompleted,
              session.pomodoroCyclesTarget!,
            ),
            style: theme.textTheme.titleSmall,
          ),
        ],
        const SizedBox(height: 16),
        Text(l10n.segments, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (detail.segments.isEmpty)
          Text(
            l10n.noSegmentsRecorded,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...detail.segments.map(
            (segment) => SessionSegmentTile(
              segment: segment,
              sessionStatus: session.status,
            ),
          ),
      ],
    );
  }
}

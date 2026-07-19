import 'package:flutter/material.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/session/session_segment.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';
import 'package:pomodoro_app/presentation/timeline/segment_detail_visual.dart';

class SessionSegmentTile extends StatelessWidget {
  const SessionSegmentTile({
    required this.segment,
    required this.sessionStatus,
    super.key,
  });

  final SessionSegment segment;
  final SessionStatus sessionStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final visual = SegmentDetailVisual.fromSegment(
      segment,
      sessionStatus: sessionStatus,
      l10n: l10n,
    );
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatHelpersSegmentTypeLabel(segment.type, l10n),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.plannedDuration(
                      formatDurationSec(segment.plannedSec, l10n),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    l10n.actualDuration(formatDurationSec(segment.actualSec, l10n)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (visual.statusLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      visual.statusLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: visual.iconColor(colorScheme),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(visual.icon, color: visual.iconColor(colorScheme)),
          ],
        ),
      ),
    );
  }
}

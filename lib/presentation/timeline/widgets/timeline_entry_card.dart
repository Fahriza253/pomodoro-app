import 'package:flutter/material.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timeline/timeline_models.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';
import 'package:pomodoro_app/presentation/shared/tag_color_dot.dart';

class TimelineEntryCard extends StatelessWidget {
  const TimelineEntryCard({
    required this.entry,
    required this.timeFormat,
    required this.onTap,
    super.key,
  });

  final TimelineEntry entry;
  final TimeFormat timeFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TagColorDot(hex: entry.tagColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.tagDisplayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatTimeRange(
                        entry.startedAtUtcMs,
                        entry.endedAtUtcMs,
                        timeFormat,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.focusDurationLabel(
                        formatDurationSec(entry.focusDurationSec, context.l10n),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

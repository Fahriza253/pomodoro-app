import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timeline/timeline_models.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/timeline_empty_day.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/timeline_entry_card.dart';

class TimelineDayList extends StatelessWidget {
  const TimelineDayList({
    required this.day,
    required this.timeFormat,
    required this.onRefresh,
    super.key,
  });

  final TimelineDay day;
  final TimeFormat timeFormat;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final entries = day.entries;
    final isEmpty = entries.isEmpty;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: isEmpty
            ? const EdgeInsets.all(16)
            : const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: isEmpty ? 1 : entries.length,
        itemBuilder: (context, index) {
          if (isEmpty) {
            return const TimelineEmptyDay();
          }
          final entry = entries[index];
          return TimelineEntryCard(
            entry: entry,
            timeFormat: timeFormat,
            onTap: () => context.push('/timeline/session/${entry.sessionId}'),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';
import 'package:pomodoro_app/presentation/timeline/timeline_providers.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/timeline_date_strip.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/timeline_day_list.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/timeline_month_filter.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(timelineSelectedDateProvider);
    final selectedMonth = ref.watch(timelineSelectedMonthProvider);
    final dayAsync = ref.watch(timelineSelectedDayProvider);
    final timeFormat = ref.watch(timelineTimeFormatProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timelineTitle),
        actions: [
          TimelineMonthFilter(
            selected: selectedMonth,
            options: ref.watch(timelineMonthOptionsProvider),
            onSelected: (m) => selectTimelineMonth(ref, m),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TimelineDateStrip(
            dates: ref.watch(timelineStripDatesProvider),
            selectedDate: selectedDate,
            onSelected: (date) {
              ref.read(timelineSelectedDateProvider.notifier).state = date;
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(formatDayHeading(selectedDate, l10n)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Expanded(
            child: dayAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: FilledButton(
                  onPressed: () => ref.invalidate(timelineSelectedDayProvider),
                  child: Text(l10n.tryAgain),
                ),
              ),
              data: (day) => TimelineDayList(
                day: day,
                timeFormat: timeFormat,
                onRefresh: () async {
                  ref.invalidate(timelineSelectedDayProvider);
                  await ref.read(timelineSelectedDayProvider.future);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/statistic/statistic_summary.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';
import 'package:pomodoro_app/presentation/shared/tag_color_dot.dart';

// --- Period / filters -------------------------------------------------------

class StatisticPeriodChips extends StatelessWidget {
  const StatisticPeriodChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final StatisticPeriod selected;
  final ValueChanged<StatisticPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final p in StatisticPeriod.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_periodLabel(p, l10n)),
                selected: selected == p,
                onSelected: (_) => onSelected(p),
              ),
            ),
        ],
      ),
    );
  }
}

String _periodLabel(StatisticPeriod period, AppLocalizations l10n) =>
    switch (period) {
      StatisticPeriod.daily => l10n.periodDaily,
      StatisticPeriod.weekly => l10n.periodWeekly,
      StatisticPeriod.monthly => l10n.periodMonthly,
      StatisticPeriod.yearly => l10n.periodYearly,
      StatisticPeriod.total => l10n.periodTotal,
    };

class StatisticFilterRow extends StatelessWidget {
  const StatisticFilterRow({
    required this.tags,
    required this.selectedTagId,
    required this.selectedMode,
    required this.onTagChanged,
    required this.onModeChanged,
    super.key,
  });

  final List<Tag> tags;
  final String? selectedTagId;
  final TimerMode? selectedMode;
  final ValueChanged<String?> onTagChanged;
  final ValueChanged<TimerMode?> onModeChanged;

  static const _denseOutline = InputDecoration(
    border: OutlineInputBorder(),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            key: ValueKey('stat-tag-${selectedTagId ?? 'all'}'),
            initialValue: selectedTagId,
            decoration: _denseOutline.copyWith(labelText: l10n.tag),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.allTags)),
              ...tags.map(
                (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
              ),
            ],
            onChanged: onTagChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<TimerMode?>(
            key: ValueKey('stat-mode-${selectedMode?.name ?? 'all'}'),
            initialValue: selectedMode,
            decoration: _denseOutline.copyWith(labelText: l10n.mode),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.allModes)),
              DropdownMenuItem(
                value: TimerMode.pomodoro,
                child: Text(l10n.modePomodoro),
              ),
              DropdownMenuItem(
                value: TimerMode.flexible,
                child: Text(l10n.modeFlexible),
              ),
            ],
            onChanged: onModeChanged,
          ),
        ),
      ],
    );
  }
}

// --- Metrics ----------------------------------------------------------------

class StatisticMetricGrid extends StatelessWidget {
  const StatisticMetricGrid({required this.summary, super.key});

  final StatisticSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cells = [
      (l10n.metricSessions, '${summary.sessionCount}'),
      (l10n.metricFocus, formatDurationSec(summary.focusDurationSec, l10n)),
      (l10n.metricBreak, formatDurationSec(summary.breakDurationSec, l10n)),
      (l10n.metricTotal, formatDurationSec(summary.totalDurationSec, l10n)),
    ];
    return Column(
      children: [
        for (var r = 0; r < 2; r++) ...[
          if (r > 0) const SizedBox(height: 12),
          Row(
            children: [
              for (var c = 0; c < 2; c++) ...[
                if (c > 0) const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cells[r * 2 + c].$2,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cells[r * 2 + c].$1,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

String statisticMetricsKey(StatisticSummary s) =>
    '${s.sessionCount}-${s.focusDurationSec}-'
    '${s.breakDurationSec}-${s.totalDurationSec}';

// --- Breakdown / empty ------------------------------------------------------

class StatisticTagBreakdown extends StatelessWidget {
  const StatisticTagBreakdown({required this.summary, super.key});

  final StatisticSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (summary.byTag.isEmpty) {
      return Text(l10n.noTagBreakdown);
    }
    final maxFocus = summary.byTag.first.focusDurationSec;
    return Column(
      children: [
        for (final item in summary.byTag)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TagColorDot(hex: item.tagColor, size: 12),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.tagName)),
                      Text(formatDurationSec(item.focusDurationSec, l10n)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: maxFocus == 0
                        ? 0.0
                        : item.focusDurationSec / maxFocus,
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.sessionCount(item.sessionCount)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

String statisticBreakdownKey(StatisticSummary s) => s.byTag
    .map((i) => '${i.tagId}:${i.sessionCount}:${i.focusDurationSec}')
    .join('|');

class StatisticNoData extends StatelessWidget {
  const StatisticNoData({required this.hasFilters, super.key});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            hasFilters ? l10n.noDataForFilter : l10n.noStatisticData,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters ? l10n.adjustFiltersHint : l10n.startSessionHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Loading / refresh chrome -----------------------------------------------

class StatisticRefreshFade extends StatelessWidget {
  const StatisticRefreshFade({
    required this.refreshing,
    required this.child,
    super.key,
  });

  final bool refreshing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: refreshing ? 0.55 : 1,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: child,
      ),
    );
  }
}

class StatisticPlaceholder extends StatelessWidget {
  const StatisticPlaceholder({required this.height, this.width, super.key});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

Widget _pairRow(double height) => Row(
  children: [
    Expanded(child: StatisticPlaceholder(height: height)),
    const SizedBox(width: 12),
    Expanded(child: StatisticPlaceholder(height: height)),
  ],
);

class StatisticMetricsSkeleton extends StatelessWidget {
  const StatisticMetricsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _pairRow(88),
        const SizedBox(height: 12),
        _pairRow(88),
      ],
    );
  }
}

class StatisticFilterSkeleton extends StatelessWidget {
  const StatisticFilterSkeleton({super.key});

  @override
  Widget build(BuildContext context) => _pairRow(56);
}

class StatisticBreakdownSkeleton extends StatelessWidget {
  const StatisticBreakdownSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        StatisticPlaceholder(height: 18, width: 140),
        SizedBox(height: 12),
        StatisticPlaceholder(height: 88),
        SizedBox(height: 8),
        StatisticPlaceholder(height: 88),
      ],
    );
  }
}

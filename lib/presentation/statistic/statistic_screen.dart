import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/presentation/l10n/l10n_extensions.dart';
import 'package:pomodoro_app/presentation/statistic/statistic_providers.dart';
import 'package:pomodoro_app/presentation/statistic/widgets/statistic_widgets.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';

class StatisticScreen extends ConsumerWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(statisticSummaryProvider);
    final query = ref.watch(statisticQueryProvider);
    final tagsAsync = ref.watch(tagListProvider);
    final summary = summaryAsync.valueOrNull;
    final isInitialLoad = summaryAsync.isLoading && summary == null;
    final isRefreshing = summaryAsync.isRefreshing;
    final l10n = context.l10n;

    void updateQuery(StatisticQuery next) {
      ref.read(statisticQueryProvider.notifier).state = next;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticTitle)),
      body: summaryAsync.hasError && summary == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      l10n.loadStatisticFailed,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => ref.invalidate(statisticSummaryProvider),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isRefreshing
                      ? const LinearProgressIndicator(
                          key: ValueKey('stat-progress'),
                          minHeight: 2,
                        )
                      : const SizedBox(
                          key: ValueKey('stat-progress-spacer'),
                          height: 2,
                        ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(statisticSummaryProvider),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        StatisticPeriodChips(
                          selected: query.period,
                          onSelected: (p) =>
                              updateQuery(query.copyWith(period: p)),
                        ),
                        const SizedBox(height: 16),
                        if (isInitialLoad)
                          const StatisticMetricsSkeleton()
                        else
                          StatisticRefreshFade(
                            refreshing: isRefreshing,
                            child: StatisticMetricGrid(
                              key: ValueKey(statisticMetricsKey(summary!)),
                              summary: summary,
                            ),
                          ),
                        const SizedBox(height: 16),
                        tagsAsync.when(
                          loading: () => const StatisticFilterSkeleton(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (tags) => _filterRow(query, tags, updateQuery),
                        ),
                        if (isInitialLoad) ...[
                          const SizedBox(height: 16),
                          const StatisticBreakdownSkeleton(),
                        ] else if (summary!.sessionCount == 0) ...[
                          const SizedBox(height: 24),
                          StatisticNoData(
                            hasFilters:
                                query.tagId != null || query.mode != null,
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          Text(
                            l10n.tagBreakdown,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          StatisticRefreshFade(
                            refreshing: isRefreshing,
                            child: StatisticTagBreakdown(
                              key: ValueKey(statisticBreakdownKey(summary)),
                              summary: summary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  StatisticFilterRow _filterRow(
    StatisticQuery query,
    List<Tag> tags,
    void Function(StatisticQuery) update,
  ) {
    return StatisticFilterRow(
      tags: tags,
      selectedTagId: query.tagId,
      selectedMode: query.mode,
      onTagChanged: (id) =>
          update(query.copyWith(tagId: id, clearTag: id == null)),
      onModeChanged: (mode) =>
          update(query.copyWith(mode: mode, clearMode: mode == null)),
    );
  }
}

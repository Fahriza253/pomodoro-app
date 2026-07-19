import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/application/statistic/statistic_use_cases.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/statistic/statistic_summary.dart';

import 'package:pomodoro_app/presentation/l10n/locale_providers.dart';

/// Incremented when settings inclusion toggles change (BR-SETTINGS-005).
final statisticRefreshTokenProvider = StateProvider<int>((ref) => 0);

class StatisticQuery {
  const StatisticQuery({
    this.period = StatisticPeriod.daily,
    this.tagId,
    this.mode,
  });

  static const defaults = StatisticQuery();

  final StatisticPeriod period;
  final String? tagId;
  final TimerMode? mode;

  StatisticQuery copyWith({
    StatisticPeriod? period,
    String? tagId,
    TimerMode? mode,
    bool clearTag = false,
    bool clearMode = false,
  }) {
    return StatisticQuery(
      period: period ?? this.period,
      tagId: clearTag ? null : (tagId ?? this.tagId),
      mode: clearMode ? null : (mode ?? this.mode),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticQuery &&
          period == other.period &&
          tagId == other.tagId &&
          mode == other.mode;

  @override
  int get hashCode => Object.hash(period, tagId, mode);
}

final statisticUseCasesProvider = Provider<StatisticUseCases>((ref) {
  final l10n = ref.watch(appLocalizationsProvider);
  return StatisticUseCases(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    deletedTagLabel: l10n.deletedTag,
  );
});

final statisticQueryProvider = StateProvider<StatisticQuery>(
  (ref) => const StatisticQuery(),
);

final statisticSummaryProvider =
    AsyncNotifierProvider<StatisticSummaryNotifier, StatisticSummary>(
  StatisticSummaryNotifier.new,
);

class StatisticSummaryNotifier extends AsyncNotifier<StatisticSummary> {
  @override
  Future<StatisticSummary> build() async {
    ref.watch(statisticRefreshTokenProvider);
    final query = ref.watch(statisticQueryProvider);
    final useCases = ref.watch(statisticUseCasesProvider);
    final result = await useCases.getStatistic(
      period: query.period,
      tagId: query.tagId,
      mode: query.mode,
    );
    if (result.isErr) {
      throw result.error!;
    }
    return result.value!;
  }
}

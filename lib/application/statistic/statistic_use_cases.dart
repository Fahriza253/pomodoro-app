import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/session/session_inputs.dart';
import 'package:pomodoro_app/domain/statistic/period_calculator.dart';
import 'package:pomodoro_app/domain/statistic/statistic_summary.dart';
import 'package:pomodoro_app/domain/statistic/stats_calculator.dart';

/// UC-05 — statistic aggregation with inclusion rules (BR-STAT-001–008).
class StatisticUseCases {
  StatisticUseCases({
    required this._sessionRepository,
    required this._settingsRepository,
    required this._tagRepository,
    StatsCalculator? statsCalculator,
    PeriodCalculator? periodCalculator,
    this.deletedTagLabel = 'Deleted tag',
  }) : _statsCalculator = statsCalculator ?? const StatsCalculator(),
       _periodCalculator = periodCalculator ?? const PeriodCalculator();

  final SessionRepository _sessionRepository;
  final SettingsRepository _settingsRepository;
  final TagRepository _tagRepository;
  final StatsCalculator _statsCalculator;
  final PeriodCalculator _periodCalculator;
  final String deletedTagLabel;

  Future<AppResult<StatisticSummary>> getStatistic({
    required StatisticPeriod period,
    String? tagId,
    TimerMode? mode,
    DateTime? anchorDateLocal,
  }) async {
    try {
      final settings = await _settingsRepository.get();
      final anchor = anchorDateLocal ?? DateTime.now();
      final range = _periodCalculator.rangeForPeriod(
        period: period,
        anchorLocal: anchor,
        weekStartDay: settings.weekStartDay,
      );

      final sessions = await _sessionRepository.queryByDateRange(
        range,
        SessionQueryFilter(tagId: tagId, mode: mode),
      );

      final segmentsBySessionId = await _sessionRepository
          .getSegmentsBySessionIds(sessions.map((s) => s.id));

      final tagIds = sessions.map((s) => s.tagId).toSet();
      final tagsById = await _tagRepository.getByIds(tagIds);

      final summary = _statsCalculator.aggregate(
        sessions: sessions,
        segmentsBySessionId: segmentsBySessionId,
        settings: settings,
        tagsById: tagsById,
        deletedTagLabel: deletedTagLabel,
      );

      return ok(summary);
    } on AppError catch (e) {
      return err(e);
    }
  }
}

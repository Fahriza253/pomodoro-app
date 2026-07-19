import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/application/statistic/statistic_use_cases.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';

import '../../data/test_database.dart';

void main() {
  group('StatisticUseCases', () {
    late DriftSessionRepository sessionRepository;
    late DriftSettingsRepository settingsRepository;
    late DriftTagRepository tagRepository;
    late StatisticUseCases useCases;

    setUp(() async {
      final db = await openTestDatabase();
      addTearDown(db.close);
      sessionRepository = DriftSessionRepository(db);
      settingsRepository = DriftSettingsRepository(db);
      tagRepository = DriftTagRepository(db);
      useCases = StatisticUseCases(
        sessionRepository: sessionRepository,
        settingsRepository: settingsRepository,
        tagRepository: tagRepository,
      );
    });

    test('returns empty summary when no terminal sessions', () async {
      final result = await useCases.getStatistic(period: StatisticPeriod.total);
      expect(result.isOk, isTrue);
      expect(result.value!.sessionCount, 0);
    });
  });
}

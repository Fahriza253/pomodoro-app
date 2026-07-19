import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/application/timeline/timeline_use_cases.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/common/result.dart';
import 'package:pomodoro_app/domain/timeline/timeline_models.dart';
import 'package:pomodoro_app/presentation/l10n/locale_providers.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/presentation/shared/format_helpers.dart';

final timelineUseCasesProvider = Provider<TimelineUseCases>((ref) {
  final l10n = ref.watch(appLocalizationsProvider);
  return TimelineUseCases(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    tagRepository: ref.watch(tagRepositoryProvider),
    deletedTagLabel: l10n.deletedTag,
  );
});

final timelineSelectedDateProvider = StateProvider<DateTime>(
  (ref) => dateOnly(DateTime.now()),
);

final timelineSelectedMonthProvider = Provider<DateTime>((ref) {
  final d = ref.watch(timelineSelectedDateProvider);
  return DateTime(d.year, d.month);
});

final timelineMonthOptionsProvider = Provider<List<DateTime>>(
  (ref) => recentMonths(),
);

final timelineStripDatesProvider = Provider<List<DateTime>>((ref) {
  return daysInMonthUntil(
    ref.watch(timelineSelectedMonthProvider),
    DateTime.now(),
  );
});

final timelineTimeFormatProvider = Provider<TimeFormat>((ref) {
  return ref
      .watch(appSettingsStreamProvider)
      .maybeWhen(data: (s) => s.timeFormat, orElse: () => TimeFormat.h24);
});

final timelineSelectedDayProvider = FutureProvider<TimelineDay>((ref) async {
  final result = await ref
      .watch(timelineUseCasesProvider)
      .listByDay(ref.watch(timelineSelectedDateProvider));
  if (result.isErr) {
    throw result.error!;
  }
  return result.value!;
});

final sessionDetailProvider = FutureProvider.family<SessionDetail, String>((
  ref,
  sessionId,
) async {
  final result = await ref
      .watch(timelineUseCasesProvider)
      .getSessionDetail(sessionId);
  if (result.isErr) {
    throw result.error!;
  }
  return result.value!;
});

void selectTimelineMonth(WidgetRef ref, DateTime month) {
  ref.read(timelineSelectedDateProvider.notifier).state = clampDayToMonth(
    ref.read(timelineSelectedDateProvider),
    month,
    DateTime.now(),
  );
}

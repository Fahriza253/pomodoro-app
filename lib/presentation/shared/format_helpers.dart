import 'package:intl/intl.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';

String formatDurationSec(int seconds, AppLocalizations l10n) {
  if (seconds <= 0) {
    return l10n.durationZero;
  }
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (hours > 0) {
    return l10n.durationHoursMinutes(hours, minutes);
  }
  return l10n.durationMinutesOnly(minutes);
}

String formatTimeOfDay(int utcMs, TimeFormat format, {bool local = true}) {
  final dt = DateTime.fromMillisecondsSinceEpoch(utcMs, isUtc: true);
  final value = local ? dt.toLocal() : dt;
  final minute = value.minute.toString().padLeft(2, '0');
  if (format == TimeFormat.h24) {
    return '${value.hour.toString().padLeft(2, '0')}:$minute';
  }
  final period = value.hour >= 12 ? 'PM' : 'AM';
  final h12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return '$h12:$minute $period';
}

/// Formats `HH:mm – HH:mm` (or `—` when [endUtcMs] is null).
String formatTimeRange(int startUtcMs, int? endUtcMs, TimeFormat format) {
  final start = formatTimeOfDay(startUtcMs, format);
  final end = endUtcMs == null ? '—' : formatTimeOfDay(endUtcMs, format);
  return '$start – $end';
}

String formatMonthYear(DateTime month, String languageCode) {
  return DateFormat.yMMM(languageCode).format(month);
}

String formatWeekdayShort(DateTime date, String languageCode) {
  return DateFormat.E(languageCode).format(date);
}

String formatDayHeading(
  DateTime localDate,
  AppLocalizations l10n, {
  DateTime? reference,
  String? languageCode,
}) {
  final today = dateOnly(reference ?? DateTime.now());
  final target = dateOnly(localDate);
  final diff = today.difference(target).inDays;
  final code = languageCode ?? l10n.localeName;
  final label = DateFormat.yMMMd(code).format(localDate);
  return switch (diff) {
    0 => l10n.todayDate(label),
    1 => l10n.yesterdayDate(label),
    _ => label,
  };
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

/// Days in [month] up to [until] (inclusive), oldest → newest.
List<DateTime> daysInMonthUntil(DateTime month, DateTime until) {
  final last = DateTime(month.year, month.month + 1, 0);
  final end = until.isBefore(last) ? dateOnly(until) : last;
  if (end.year != month.year || end.month != month.month) {
    return const [];
  }
  return [
    for (var d = 1; d <= end.day; d++) DateTime(month.year, month.month, d),
  ];
}

/// Last [count] calendar months ending at [anchor] (oldest → newest).
List<DateTime> recentMonths({DateTime? anchor, int count = 12}) {
  final now = dateOnly(anchor ?? DateTime.now());
  final start = DateTime(now.year, now.month);
  return [
    for (var i = count - 1; i >= 0; i--) DateTime(start.year, start.month - i),
  ];
}

/// Keep [day] inside [month], not after [today].
DateTime clampDayToMonth(DateTime day, DateTime month, DateTime today) {
  final last = DateTime(month.year, month.month + 1, 0).day;
  var next = DateTime(month.year, month.month, day.day.clamp(1, last));
  final cap = isSameMonth(month, today)
      ? dateOnly(today)
      : DateTime(month.year, month.month, last);
  if (next.isAfter(cap)) {
    next = cap;
  }
  return next;
}

String sessionStatusLabel(SessionStatus status, AppLocalizations l10n) =>
    switch (status) {
      SessionStatus.completed => l10n.sessionStatusCompleted,
      SessionStatus.abandoned => l10n.sessionStatusAbandoned,
      SessionStatus.failed => l10n.sessionStatusFailed,
      SessionStatus.manual => l10n.sessionStatusManual,
      SessionStatus.active => l10n.sessionStatusActive,
    };

String timerModeLabel(TimerMode mode, AppLocalizations l10n) => switch (mode) {
  TimerMode.pomodoro => l10n.modePomodoro,
  TimerMode.flexible => l10n.modeFlexible,
};

String formatHelpersSegmentTypeLabel(
  SegmentType type,
  AppLocalizations l10n,
) => switch (type) {
  SegmentType.focus => l10n.segmentFocus,
  SegmentType.shortRest => l10n.segmentShortRest,
  SegmentType.longRest => l10n.segmentLongRest,
  SegmentType.flexible => l10n.segmentFlexible,
};

String statisticPeriodLabel(StatisticPeriod period, AppLocalizations l10n) =>
    switch (period) {
      StatisticPeriod.daily => l10n.periodDaily,
      StatisticPeriod.weekly => l10n.periodWeekly,
      StatisticPeriod.monthly => l10n.periodMonthly,
      StatisticPeriod.yearly => l10n.periodYearly,
      StatisticPeriod.total => l10n.periodTotal,
    };

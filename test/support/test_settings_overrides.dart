import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';

/// Default AppSettings matching database seeder for widget test overrides.
AppSettings testAppSettings({int updatedAtUtcMs = 1}) {
  return AppSettings(
    id: 'default',
    alertToneFocusSuccess: AlertToneCatalog.defaultFocusSuccess,
    alertToneBreakOver: AlertToneCatalog.defaultBreakOver,
    alertToneFocusFailure: AlertToneCatalog.defaultFocusFailure,
    focusMode: FocusMode.loose,
    whitelist: const [],
    focusViolationThresholdSec: 5,
    theme: AppTheme.system,
    alwaysOnDisplay: false,
    language: 'en',
    weekStartDay: 1,
    timeFormat: TimeFormat.h24,
    trackFailedSessions: false,
    updatedAtUtcMs: updatedAtUtcMs,
  );
}

/// Avoids Drift watch timers pending in widget tests when [PomodoroApp] loads theme.
final testAppSettingsStreamOverride = appSettingsStreamProvider.overrideWith(
  (ref) => Stream.value(testAppSettings()),
);

/// Seeded "General" tag for widget tests (matches [DatabaseSeeder.generalTagName]).
Tag testGeneralTag({int updatedAtUtcMs = 1}) {
  return Tag(
    id: 'test-general-tag',
    name: 'General',
    color: '#6366F1',
    sortOrder: 0,
    createdAtUtcMs: updatedAtUtcMs,
    updatedAtUtcMs: updatedAtUtcMs,
  );
}

/// Avoids Drift watch timers pending in widget tests when timer tab loads tags.
final testTagListOverride = tagListProvider.overrideWith(
  (ref) => Stream.value([testGeneralTag()]),
);

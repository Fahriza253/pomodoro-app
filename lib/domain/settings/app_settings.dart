import 'package:pomodoro_app/domain/common/enums.dart';

class AppSettings {
  const AppSettings({
    required this.id,
    required this.alertToneFocusSuccess,
    required this.alertToneBreakOver,
    required this.alertToneFocusFailure,
    required this.focusMode,
    required this.whitelist,
    required this.focusViolationThresholdSec,
    required this.theme,
    required this.alwaysOnDisplay,
    required this.language,
    required this.weekStartDay,
    required this.timeFormat,
    required this.trackFailedSessions,
    required this.updatedAtUtcMs,
  });

  final String id;
  final String alertToneFocusSuccess;
  final String alertToneBreakOver;
  final String alertToneFocusFailure;
  final FocusMode focusMode;
  final List<String> whitelist;
  final int focusViolationThresholdSec;
  final AppTheme theme;
  final bool alwaysOnDisplay;
  final String language;
  final int weekStartDay;
  final TimeFormat timeFormat;
  final bool trackFailedSessions;
  final int updatedAtUtcMs;
}

class AppSettingsPatch {
  const AppSettingsPatch({
    this.alertToneFocusSuccess,
    this.alertToneBreakOver,
    this.alertToneFocusFailure,
    this.focusMode,
    this.whitelist,
    this.focusViolationThresholdSec,
    this.theme,
    this.alwaysOnDisplay,
    this.language,
    this.weekStartDay,
    this.timeFormat,
    this.trackFailedSessions,
  });

  final String? alertToneFocusSuccess;
  final String? alertToneBreakOver;
  final String? alertToneFocusFailure;
  final FocusMode? focusMode;
  final List<String>? whitelist;
  final int? focusViolationThresholdSec;
  final AppTheme? theme;
  final bool? alwaysOnDisplay;
  final String? language;
  final int? weekStartDay;
  final TimeFormat? timeFormat;
  final bool? trackFailedSessions;
}

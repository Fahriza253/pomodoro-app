import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/app_database.dart' as db;
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';

class AppSettingsMapper {
  const AppSettingsMapper();

  AppSettings toDomain(db.AppSettingsTableData row) {
    return AppSettings(
      id: row.id,
      alertToneFocusSuccess: row.alertToneFocusSuccess,
      alertToneBreakOver: row.alertToneBreakOver,
      alertToneFocusFailure: row.alertToneFocusFailure,
      alertHapticEnabled: row.alertHapticEnabled == 1,
      alertSoundMuted: row.alertSoundMuted == 1,
      alertFlashEnabled: row.alertFlashEnabled == 1,
      focusMode: FocusMode.fromDb(row.focusMode),
      whitelist: List<String>.from(row.whitelistJson),
      focusViolationThresholdSec: row.focusViolationThresholdSec,
      theme: AppTheme.fromDb(row.theme),
      alwaysOnDisplay: row.alwaysOnDisplay == 1,
      language: row.language,
      weekStartDay: row.weekStartDay,
      timeFormat: TimeFormat.fromDb(row.timeFormat),
      trackFailedSessions: row.trackFailedSessions == 1,
      updatedAtUtcMs: row.updatedAt,
    );
  }

  db.AppSettingsTableCompanion applyPatch(
    AppSettings current,
    AppSettingsPatch patch,
    int updatedAtUtcMs,
  ) {
    return db.AppSettingsTableCompanion(
      id: Value(current.id),
      alertToneFocusSuccess: Value(
        patch.alertToneFocusSuccess ?? current.alertToneFocusSuccess,
      ),
      alertToneBreakOver: Value(
        patch.alertToneBreakOver ?? current.alertToneBreakOver,
      ),
      alertToneFocusFailure: Value(
        patch.alertToneFocusFailure ?? current.alertToneFocusFailure,
      ),
      alertHapticEnabled: Value(
        (patch.alertHapticEnabled ?? current.alertHapticEnabled) ? 1 : 0,
      ),
      alertSoundMuted: Value(
        (patch.alertSoundMuted ?? current.alertSoundMuted) ? 1 : 0,
      ),
      alertFlashEnabled: Value(
        (patch.alertFlashEnabled ?? current.alertFlashEnabled) ? 1 : 0,
      ),
      focusMode: Value((patch.focusMode ?? current.focusMode).toDb()),
      whitelistJson: Value(patch.whitelist ?? current.whitelist),
      focusViolationThresholdSec: Value(
        patch.focusViolationThresholdSec ?? current.focusViolationThresholdSec,
      ),
      theme: Value((patch.theme ?? current.theme).toDb()),
      alwaysOnDisplay: Value(
        (patch.alwaysOnDisplay ?? current.alwaysOnDisplay) ? 1 : 0,
      ),
      language: Value(patch.language ?? current.language),
      weekStartDay: Value(patch.weekStartDay ?? current.weekStartDay),
      timeFormat: Value((patch.timeFormat ?? current.timeFormat).toDb()),
      trackFailedSessions: Value(
        (patch.trackFailedSessions ?? current.trackFailedSessions) ? 1 : 0,
      ),
      updatedAt: Value(updatedAtUtcMs),
    );
  }
}

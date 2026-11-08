// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pomodoro';

  @override
  String get tryAgain => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get saveUpper => 'SAVE';

  @override
  String get discard => 'Discard';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get navTimer => 'Timer';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navStatistic => 'Statistic';

  @override
  String get navSettings => 'Settings';

  @override
  String get databaseNotReadyTitle => 'Preparing your data';

  @override
  String get databaseNotReadyBody =>
      'The database is not ready yet. Please wait a moment.';

  @override
  String get timerTitle => 'Timer';

  @override
  String get timerLoadStateFailed => 'Failed to load timer state';

  @override
  String get selectTagFirst => 'Select a tag first';

  @override
  String get sessionNotActiveOrEnded =>
      'This session is no longer active or has ended';

  @override
  String flexibleReminderEveryMinutes(int minutes) {
    return 'Reminder: every $minutes minutes';
  }

  @override
  String get start => 'Start';

  @override
  String get skip => 'Skip';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String stopWithGraceSeconds(int seconds) {
    return 'Stop (${seconds}s)';
  }

  @override
  String get skipBreakUpper => 'SKIP BREAK';

  @override
  String get finish => 'Finish';

  @override
  String get focusCompleteTitle => 'Focus complete';

  @override
  String get breakCompleteTitle => 'Break complete';

  @override
  String get timeForBreak => 'Time for a break';

  @override
  String get readyForNextFocus => 'Ready for the next focus session';

  @override
  String get startBreakUpper => 'START BREAK';

  @override
  String get startFocusUpper => 'START FOCUS';

  @override
  String get skipBreak => 'Skip break';

  @override
  String get sessionCompleteTitle => 'Session complete';

  @override
  String get sessionCompleteYouDidIt => 'You did it!';

  @override
  String get sessionCompleteBodyCasual =>
      'Nice work — session done! Keep going or take a breather?';

  @override
  String get sessionCompleteBodyBrief =>
      'Session done! Keep going or rest a bit?';

  @override
  String get sessionCompleteBodyMotivational =>
      'Great job! Keep your rhythm or rest first?';

  @override
  String get startNewSession => 'Start New Session';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get sessionSavedBody =>
      'Session saved. Start again with the same tag, or return home.';

  @override
  String get startAgainUpper => 'START AGAIN';

  @override
  String get doneUpper => 'DONE';

  @override
  String activeDuration(String duration) {
    return 'Active: $duration';
  }

  @override
  String cycleProgress(int completed, int total) {
    return 'Cycle $completed of $total';
  }

  @override
  String get continueUpper => 'CONTINUE';

  @override
  String get loadingTags => 'Loading tags…';

  @override
  String get loadTagsFailed => 'Failed to load tags';

  @override
  String get selectTag => 'Select tag';

  @override
  String get manageTags => 'Manage tags';

  @override
  String get selectTagTitle => 'Select a tag';

  @override
  String get recoveryDialogTitle => 'Resume previous session?';

  @override
  String get recoveryDialogBody =>
      'We found an unfinished session. Would you like to resume it?';

  @override
  String get resumeSession => 'Resume session';

  @override
  String get slideToStopSemantics => 'Slide to stop the session';

  @override
  String get releaseToStop => 'Release to stop';

  @override
  String get segmentFocus => 'Focus';

  @override
  String get segmentShortRest => 'Short rest';

  @override
  String get segmentLongRest => 'Long rest';

  @override
  String get segmentFlexible => 'Flexible';

  @override
  String get segmentSkipped => 'Skipped';

  @override
  String get segmentRunning => 'Running';

  @override
  String get segmentIncomplete => 'Incomplete';

  @override
  String get modePomodoro => 'Pomodoro';

  @override
  String get modeFlexible => 'Flexible';

  @override
  String get errorTimerActiveSession => 'A session is already active';

  @override
  String get errorNoActiveSession => 'No active session';

  @override
  String get errorTimerInvalidTransition =>
      'This action isn\'t allowed right now';

  @override
  String get errorTimerRecoveryExpired =>
      'The previous session can no longer be recovered';

  @override
  String get errorTimerStopNotConfirmed => 'Stop wasn\'t confirmed';

  @override
  String get errorSaveFailedTryAgain => 'Failed to save, please try again';

  @override
  String get errorTagNotFound => 'Tag not found';

  @override
  String get errorSessionNotActiveOrEnded =>
      'This session is no longer active or has ended';

  @override
  String get manageTagsTitle => 'Manage tags';

  @override
  String get newTagTooltip => 'New tag';

  @override
  String get loadTagListFailed => 'Failed to load tag list';

  @override
  String get noTagsYet => 'No tags yet';

  @override
  String get loadTagFailed => 'Failed to load tag';

  @override
  String get tagNameLabel => 'Tag name';

  @override
  String get color => 'Color';

  @override
  String get newTag => 'New tag';

  @override
  String get editTag => 'Edit tag';

  @override
  String get focusDuration => 'Focus duration';

  @override
  String get shortBreakDuration => 'Short break duration';

  @override
  String get longBreakDuration => 'Long break duration';

  @override
  String get focusBeforeLongBreak => 'Focus sessions before long break';

  @override
  String get totalCycles => 'Total cycles';

  @override
  String get minutesUnit => 'min';

  @override
  String get timesUnit => 'x';

  @override
  String get autoStartBreak => 'Auto-start break';

  @override
  String get autoStartFocus => 'Auto-start focus';

  @override
  String get unlimitedDefaultDuration => 'Unlimited';

  @override
  String get defaultDuration => 'Default duration';

  @override
  String get reminderEnabled => 'Reminder enabled';

  @override
  String get reminderInterval => 'Reminder interval';

  @override
  String get deleteTag => 'Delete tag';

  @override
  String deleteTagConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteTagConfirmBody =>
      'This tag will be permanently deleted. This action cannot be undone.';

  @override
  String get errorTagNameDuplicate => 'A tag with this name already exists';

  @override
  String get errorTagEditBlockedActive =>
      'Can\'t edit this tag while its session is active';

  @override
  String get errorTagDeleteLast => 'Can\'t delete the last remaining tag';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get sessionDetailTitle => 'Session detail';

  @override
  String get filterMonthTooltip => 'Filter by month';

  @override
  String get noSessionsOnDate => 'No sessions on this date';

  @override
  String focusDurationLabel(String duration) {
    return 'Focus duration: $duration';
  }

  @override
  String sessionTagAndMode(String tagName, String mode) {
    return '$tagName · $mode';
  }

  @override
  String sessionStatusPrefix(String status) {
    return 'Status: $status';
  }

  @override
  String totalActive(String duration) {
    return 'Total active: $duration';
  }

  @override
  String totalPaused(String duration) {
    return 'Total paused: $duration';
  }

  @override
  String get segments => 'Segments';

  @override
  String get noSegmentsRecorded => 'No segments recorded';

  @override
  String plannedDuration(String duration) {
    return 'Planned: $duration';
  }

  @override
  String actualDuration(String duration) {
    return 'Actual: $duration';
  }

  @override
  String get statisticTitle => 'Statistic';

  @override
  String get loadStatisticFailed => 'Failed to load statistic';

  @override
  String get tagBreakdown => 'Tag breakdown';

  @override
  String get tag => 'Tag';

  @override
  String get allTags => 'All tags';

  @override
  String get mode => 'Mode';

  @override
  String get allModes => 'All modes';

  @override
  String get metricSessions => 'Sessions';

  @override
  String get metricFocus => 'Focus';

  @override
  String get metricBreak => 'Break';

  @override
  String get metricTotal => 'Total';

  @override
  String get noTagBreakdown => 'No tag breakdown available';

  @override
  String sessionCount(int count) {
    return '$count sessions';
  }

  @override
  String get noDataForFilter => 'No data for this filter';

  @override
  String get noStatisticData => 'No statistic data yet';

  @override
  String get adjustFiltersHint => 'Try adjusting your filters';

  @override
  String get startSessionHint => 'Start a session to see your statistic here';

  @override
  String get periodDaily => 'Daily';

  @override
  String get periodWeekly => 'Weekly';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get periodYearly => 'Yearly';

  @override
  String get periodTotal => 'Total';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get loadSettingsFailed => 'Failed to load settings';

  @override
  String get settingsSectionAlert => 'Alert';

  @override
  String get alertTones => 'Alert tones';

  @override
  String get settingsSectionFocus => 'Focus';

  @override
  String get focusMode => 'Focus mode';

  @override
  String get whitelistApps => 'Whitelisted apps';

  @override
  String appCount(int count) {
    return '$count apps';
  }

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get themeAndDisplay => 'Theme & display';

  @override
  String themeAodSummary(String theme, String status) {
    return '$theme · AOD $status';
  }

  @override
  String get settingsSectionTimeLanguage => 'Time & language';

  @override
  String get timeAndLanguage => 'Time & language';

  @override
  String get settingsSectionStatistic => 'Statistic';

  @override
  String get statisticInclusion => 'Statistic inclusion';

  @override
  String statisticInclusionSummary(String failed) {
    return 'Failed sessions: $failed';
  }

  @override
  String get settingsSectionPlatform => 'Platform';

  @override
  String get platformAndBattery => 'Platform & battery';

  @override
  String get platformSubtitle =>
      'Platform-specific behavior and battery settings';

  @override
  String alertTonesSummary(String focus, String breakTone) {
    return 'Focus $focus · Break $breakTone';
  }

  @override
  String get focusLoose => 'Loose';

  @override
  String get focusStrict => 'Strict';

  @override
  String get focusWhitelist => 'Whitelist';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeFollowSystem => 'Follow system';

  @override
  String get languageIndonesian => 'Indonesian';

  @override
  String get languageEnglish => 'English';

  @override
  String get timeFormat12h => '12-hour';

  @override
  String get timeFormat24h => '24-hour';

  @override
  String get weekStartMonday => 'Monday';

  @override
  String get weekStartSunday => 'Sunday';

  @override
  String get language => 'Language';

  @override
  String get timeFormat => 'Time format';

  @override
  String get weekStart => 'Week starts on';

  @override
  String get timeLanguageTitle => 'Time & language';

  @override
  String get alertTonesTitle => 'Alert';

  @override
  String get focusComplete => 'Focus complete';

  @override
  String get breakComplete => 'Break complete';

  @override
  String get focusFailed => 'Focus failed';

  @override
  String get alertTonePreviewHint => 'Tap a tone to preview it';

  @override
  String get alertControlsSection => 'Alert Controls';

  @override
  String get alertControlsHint =>
      'Haptic, sound, and flash for Alerts and Reminders';

  @override
  String get alertHaptic => 'Haptic';

  @override
  String get alertSoundMute => 'Mute sound';

  @override
  String get alertFlash => 'Flash';

  @override
  String get alertFlashUnsupported => 'Flash is not supported on this device';

  @override
  String get alertControlsSheetTitle => 'Alert Controls';

  @override
  String get muted => 'Muted';

  @override
  String get unmuted => 'On';

  @override
  String get focusModeTitle => 'Focus mode';

  @override
  String get focusModeDegradedBanner =>
      'Focus mode is running in a degraded state';

  @override
  String get focusLooseSubtitle =>
      'No restrictions, just a gentle reminder to stay focused';

  @override
  String get focusStrictSubtitle => 'Leaving the app counts as a violation';

  @override
  String get focusWhitelistSubtitle =>
      'Only whitelisted apps are allowed during focus';

  @override
  String get usageAccessRequired => 'Usage access permission is required';

  @override
  String get openSettings => 'Open settings';

  @override
  String get violationThreshold => 'Violation threshold';

  @override
  String get seconds => 'seconds';

  @override
  String secondsCount(int sec) {
    return '${sec}s';
  }

  @override
  String get manageWhitelist => 'Manage whitelist';

  @override
  String get notAvailableOnDevice => 'Not available on this device';

  @override
  String get whitelistAppsTitle => 'Whitelisted apps';

  @override
  String get installedAppsUnavailable => 'Installed apps list is unavailable';

  @override
  String get selectApp => 'Select app';

  @override
  String get addApp => 'Add app';

  @override
  String get whitelistEmpty => 'Whitelist is empty';

  @override
  String get whitelistOnlyWhenActive =>
      'Whitelist only applies while a focus session is active';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get alwaysOnDisplay => 'Always-on display (AOD)';

  @override
  String get aodEnabledDescription =>
      'Keep the timer visible on screen while focusing';

  @override
  String get notSupportedOnDevice => 'Not supported on this device';

  @override
  String get statisticInclusionTitle => 'Statistic inclusion';

  @override
  String get trackFailedSessions => 'Track failed sessions';

  @override
  String get trackFailedSessionsSubtitle =>
      'Include failed sessions and their focus time in your statistic';

  @override
  String get platformBatteryTitle => 'Platform & battery';

  @override
  String platformLabel(String label) {
    return 'Platform: $label';
  }

  @override
  String get segmentNotifications => 'Segment notifications';

  @override
  String get notificationDeepLinkAvailable =>
      'Notifications can open the app directly';

  @override
  String get deepLinkUnavailable => 'Deep link is unavailable on this device';

  @override
  String get flexibleReminders => 'Flexible reminders';

  @override
  String get platformNotes => 'Platform notes';

  @override
  String get batteryOptimization => 'Battery optimization';

  @override
  String get batteryOptimizationBody =>
      'Disable battery optimization for this app to keep the timer running reliably in the background';

  @override
  String get openBatterySettings => 'Open battery settings';

  @override
  String get errorFocusPermissionDenied => 'Focus permission was denied';

  @override
  String get errorSaveSettingsFailed => 'Failed to save settings';

  @override
  String get errorStorageWriteFailed => 'Failed to write to storage';

  @override
  String get sessionStatusCompleted => 'Completed';

  @override
  String get sessionStatusAbandoned => 'Abandoned';

  @override
  String get sessionStatusFailed => 'Failed';

  @override
  String get sessionStatusManual => 'Manual';

  @override
  String get sessionStatusActive => 'Active';

  @override
  String get durationZero => '0m';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String todayDate(String date) {
    return 'Today, $date';
  }

  @override
  String yesterdayDate(String date) {
    return 'Yesterday, $date';
  }

  @override
  String get deletedTag => 'Deleted tag';

  @override
  String get languageUnsupported => 'Language is not supported.';

  @override
  String get weekStartInvalid => 'Week start day is invalid.';

  @override
  String violationThresholdOutOfRange(int min, int max) {
    return 'Violation threshold must be between $min–$max seconds.';
  }

  @override
  String get alertToneFocusSuccessInvalid => 'Focus-complete tone is invalid.';

  @override
  String get alertToneBreakOverInvalid => 'Break-complete tone is invalid.';

  @override
  String get alertToneFocusFailureInvalid => 'Focus-failure tone is invalid.';

  @override
  String get whitelistEntryEmpty => 'Whitelist entry must not be empty.';

  @override
  String get notificationFocusing => 'Focusing';

  @override
  String get notificationResting => 'Resting';

  @override
  String get notificationExit => 'Tap to return to the session';

  @override
  String get notificationSessionStoppedTitle => 'Session stopped';

  @override
  String get notificationSessionStoppedBody => 'Your session has been stopped';

  @override
  String get notificationFocusCompleteTitle => 'Focus complete';

  @override
  String get notificationBreakCompleteTitle => 'Break complete';

  @override
  String get notificationTimeForBreak => 'Time for a break';

  @override
  String get notificationTimeForFocus => 'Time to focus';

  @override
  String get notificationFocusFailedTitle => 'Focus session failed';

  @override
  String get notificationFocusViolationBody =>
      'You left the app during focus mode';

  @override
  String get notificationFocusReminderTitle => 'Focus reminder';

  @override
  String get notificationFocusReminderBody =>
      'Stay focused, your session is still running';

  @override
  String get capNotificationInitFailed =>
      'Notification service failed to start. Alerts are unavailable; try restarting the app.';

  @override
  String get capAndroidNeedsNotificationPermission =>
      'Segment notifications require notification permission.';

  @override
  String get capIosStrictBackgroundOnly =>
      'iOS: other-app detection is unavailable — Strict only applies when this app is in the background.';

  @override
  String get capIosBackgroundNotificationsBestEffort =>
      'iOS background notifications are best-effort.';

  @override
  String get capDesktopFocusLimited =>
      'Desktop: Strict/Whitelist focus is limited.';

  @override
  String get capScheduledNotificationsUnreliable =>
      'Scheduled notifications may be unreliable when the app is closed.';

  @override
  String get capWebFocusDowngradeToLoose =>
      'Web: Strict/Whitelist downgrade to Loose.';

  @override
  String get capWebNotificationsNeedActiveTab =>
      'Web notifications require an active tab or browser permission.';

  @override
  String get capWebAodWakeLock =>
      'Web AOD uses Wake Lock — the screen must stay visible.';

  @override
  String get capFocusModesDegradedToLoose =>
      'Strict/Whitelist is not fully available — sessions run as Loose.';

  @override
  String get capAodUnsupported =>
      'Always-on display is not supported on this platform.';
}

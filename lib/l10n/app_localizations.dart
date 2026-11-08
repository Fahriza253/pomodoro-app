import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get appTitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveUpper.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get saveUpper;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @navTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @navTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get navTimeline;

  /// No description provided for @navStatistic.
  ///
  /// In en, this message translates to:
  /// **'Statistic'**
  String get navStatistic;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @databaseNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your data'**
  String get databaseNotReadyTitle;

  /// No description provided for @databaseNotReadyBody.
  ///
  /// In en, this message translates to:
  /// **'The database is not ready yet. Please wait a moment.'**
  String get databaseNotReadyBody;

  /// No description provided for @timerTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerTitle;

  /// No description provided for @timerLoadStateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load timer state'**
  String get timerLoadStateFailed;

  /// No description provided for @selectTagFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a tag first'**
  String get selectTagFirst;

  /// No description provided for @sessionNotActiveOrEnded.
  ///
  /// In en, this message translates to:
  /// **'This session is no longer active or has ended'**
  String get sessionNotActiveOrEnded;

  /// No description provided for @flexibleReminderEveryMinutes.
  ///
  /// In en, this message translates to:
  /// **'Reminder: every {minutes} minutes'**
  String flexibleReminderEveryMinutes(int minutes);

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @stopWithGraceSeconds.
  ///
  /// In en, this message translates to:
  /// **'Stop ({seconds}s)'**
  String stopWithGraceSeconds(int seconds);

  /// No description provided for @skipBreakUpper.
  ///
  /// In en, this message translates to:
  /// **'SKIP BREAK'**
  String get skipBreakUpper;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @focusCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus complete'**
  String get focusCompleteTitle;

  /// No description provided for @breakCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Break complete'**
  String get breakCompleteTitle;

  /// No description provided for @timeForBreak.
  ///
  /// In en, this message translates to:
  /// **'Time for a break'**
  String get timeForBreak;

  /// No description provided for @readyForNextFocus.
  ///
  /// In en, this message translates to:
  /// **'Ready for the next focus session'**
  String get readyForNextFocus;

  /// No description provided for @startBreakUpper.
  ///
  /// In en, this message translates to:
  /// **'START BREAK'**
  String get startBreakUpper;

  /// No description provided for @startFocusUpper.
  ///
  /// In en, this message translates to:
  /// **'START FOCUS'**
  String get startFocusUpper;

  /// No description provided for @skipBreak.
  ///
  /// In en, this message translates to:
  /// **'Skip break'**
  String get skipBreak;

  /// No description provided for @sessionCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get sessionCompleteTitle;

  /// No description provided for @sessionCompleteYouDidIt.
  ///
  /// In en, this message translates to:
  /// **'You did it!'**
  String get sessionCompleteYouDidIt;

  /// No description provided for @sessionCompleteBodyCasual.
  ///
  /// In en, this message translates to:
  /// **'Nice work — session done! Keep going or take a breather?'**
  String get sessionCompleteBodyCasual;

  /// No description provided for @sessionCompleteBodyBrief.
  ///
  /// In en, this message translates to:
  /// **'Session done! Keep going or rest a bit?'**
  String get sessionCompleteBodyBrief;

  /// No description provided for @sessionCompleteBodyMotivational.
  ///
  /// In en, this message translates to:
  /// **'Great job! Keep your rhythm or rest first?'**
  String get sessionCompleteBodyMotivational;

  /// No description provided for @startNewSession.
  ///
  /// In en, this message translates to:
  /// **'Start New Session'**
  String get startNewSession;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @sessionSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Session saved. Start again with the same tag, or return home.'**
  String get sessionSavedBody;

  /// No description provided for @startAgainUpper.
  ///
  /// In en, this message translates to:
  /// **'START AGAIN'**
  String get startAgainUpper;

  /// No description provided for @doneUpper.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get doneUpper;

  /// No description provided for @activeDuration.
  ///
  /// In en, this message translates to:
  /// **'Active: {duration}'**
  String activeDuration(String duration);

  /// No description provided for @cycleProgress.
  ///
  /// In en, this message translates to:
  /// **'Cycle {completed} of {total}'**
  String cycleProgress(int completed, int total);

  /// No description provided for @continueUpper.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueUpper;

  /// No description provided for @loadingTags.
  ///
  /// In en, this message translates to:
  /// **'Loading tags…'**
  String get loadingTags;

  /// No description provided for @loadTagsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tags'**
  String get loadTagsFailed;

  /// No description provided for @selectTag.
  ///
  /// In en, this message translates to:
  /// **'Select tag'**
  String get selectTag;

  /// No description provided for @manageTags.
  ///
  /// In en, this message translates to:
  /// **'Manage tags'**
  String get manageTags;

  /// No description provided for @selectTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a tag'**
  String get selectTagTitle;

  /// No description provided for @recoveryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume previous session?'**
  String get recoveryDialogTitle;

  /// No description provided for @recoveryDialogBody.
  ///
  /// In en, this message translates to:
  /// **'We found an unfinished session. Would you like to resume it?'**
  String get recoveryDialogBody;

  /// No description provided for @resumeSession.
  ///
  /// In en, this message translates to:
  /// **'Resume session'**
  String get resumeSession;

  /// No description provided for @slideToStopSemantics.
  ///
  /// In en, this message translates to:
  /// **'Slide to stop the session'**
  String get slideToStopSemantics;

  /// No description provided for @releaseToStop.
  ///
  /// In en, this message translates to:
  /// **'Release to stop'**
  String get releaseToStop;

  /// No description provided for @segmentFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get segmentFocus;

  /// No description provided for @segmentShortRest.
  ///
  /// In en, this message translates to:
  /// **'Short rest'**
  String get segmentShortRest;

  /// No description provided for @segmentLongRest.
  ///
  /// In en, this message translates to:
  /// **'Long rest'**
  String get segmentLongRest;

  /// No description provided for @segmentFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get segmentFlexible;

  /// No description provided for @segmentSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get segmentSkipped;

  /// No description provided for @segmentRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get segmentRunning;

  /// No description provided for @segmentIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get segmentIncomplete;

  /// No description provided for @modePomodoro.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get modePomodoro;

  /// No description provided for @modeFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get modeFlexible;

  /// No description provided for @errorTimerActiveSession.
  ///
  /// In en, this message translates to:
  /// **'A session is already active'**
  String get errorTimerActiveSession;

  /// No description provided for @errorNoActiveSession.
  ///
  /// In en, this message translates to:
  /// **'No active session'**
  String get errorNoActiveSession;

  /// No description provided for @errorTimerInvalidTransition.
  ///
  /// In en, this message translates to:
  /// **'This action isn\'t allowed right now'**
  String get errorTimerInvalidTransition;

  /// No description provided for @errorTimerRecoveryExpired.
  ///
  /// In en, this message translates to:
  /// **'The previous session can no longer be recovered'**
  String get errorTimerRecoveryExpired;

  /// No description provided for @errorTimerStopNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Stop wasn\'t confirmed'**
  String get errorTimerStopNotConfirmed;

  /// No description provided for @errorSaveFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to save, please try again'**
  String get errorSaveFailedTryAgain;

  /// No description provided for @errorTagNotFound.
  ///
  /// In en, this message translates to:
  /// **'Tag not found'**
  String get errorTagNotFound;

  /// No description provided for @errorSessionNotActiveOrEnded.
  ///
  /// In en, this message translates to:
  /// **'This session is no longer active or has ended'**
  String get errorSessionNotActiveOrEnded;

  /// No description provided for @manageTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage tags'**
  String get manageTagsTitle;

  /// No description provided for @newTagTooltip.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTagTooltip;

  /// No description provided for @loadTagListFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tag list'**
  String get loadTagListFailed;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTagsYet;

  /// No description provided for @loadTagFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load tag'**
  String get loadTagFailed;

  /// No description provided for @tagNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagNameLabel;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTag;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get editTag;

  /// No description provided for @focusDuration.
  ///
  /// In en, this message translates to:
  /// **'Focus duration'**
  String get focusDuration;

  /// No description provided for @shortBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Short break duration'**
  String get shortBreakDuration;

  /// No description provided for @longBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Long break duration'**
  String get longBreakDuration;

  /// No description provided for @focusBeforeLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Focus sessions before long break'**
  String get focusBeforeLongBreak;

  /// No description provided for @totalCycles.
  ///
  /// In en, this message translates to:
  /// **'Total cycles'**
  String get totalCycles;

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesUnit;

  /// No description provided for @timesUnit.
  ///
  /// In en, this message translates to:
  /// **'x'**
  String get timesUnit;

  /// No description provided for @autoStartBreak.
  ///
  /// In en, this message translates to:
  /// **'Auto-start break'**
  String get autoStartBreak;

  /// No description provided for @autoStartFocus.
  ///
  /// In en, this message translates to:
  /// **'Auto-start focus'**
  String get autoStartFocus;

  /// No description provided for @unlimitedDefaultDuration.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimitedDefaultDuration;

  /// No description provided for @defaultDuration.
  ///
  /// In en, this message translates to:
  /// **'Default duration'**
  String get defaultDuration;

  /// No description provided for @reminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Reminder enabled'**
  String get reminderEnabled;

  /// No description provided for @reminderInterval.
  ///
  /// In en, this message translates to:
  /// **'Reminder interval'**
  String get reminderInterval;

  /// No description provided for @deleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete tag'**
  String get deleteTag;

  /// No description provided for @deleteTagConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteTagConfirmTitle(String name);

  /// No description provided for @deleteTagConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This tag will be permanently deleted. This action cannot be undone.'**
  String get deleteTagConfirmBody;

  /// No description provided for @errorTagNameDuplicate.
  ///
  /// In en, this message translates to:
  /// **'A tag with this name already exists'**
  String get errorTagNameDuplicate;

  /// No description provided for @errorTagEditBlockedActive.
  ///
  /// In en, this message translates to:
  /// **'Can\'t edit this tag while its session is active'**
  String get errorTagEditBlockedActive;

  /// No description provided for @errorTagDeleteLast.
  ///
  /// In en, this message translates to:
  /// **'Can\'t delete the last remaining tag'**
  String get errorTagDeleteLast;

  /// No description provided for @timelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineTitle;

  /// No description provided for @sessionDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Session detail'**
  String get sessionDetailTitle;

  /// No description provided for @filterMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter by month'**
  String get filterMonthTooltip;

  /// No description provided for @noSessionsOnDate.
  ///
  /// In en, this message translates to:
  /// **'No sessions on this date'**
  String get noSessionsOnDate;

  /// No description provided for @focusDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus duration: {duration}'**
  String focusDurationLabel(String duration);

  /// No description provided for @sessionTagAndMode.
  ///
  /// In en, this message translates to:
  /// **'{tagName} · {mode}'**
  String sessionTagAndMode(String tagName, String mode);

  /// No description provided for @sessionStatusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String sessionStatusPrefix(String status);

  /// No description provided for @totalActive.
  ///
  /// In en, this message translates to:
  /// **'Total active: {duration}'**
  String totalActive(String duration);

  /// No description provided for @totalPaused.
  ///
  /// In en, this message translates to:
  /// **'Total paused: {duration}'**
  String totalPaused(String duration);

  /// No description provided for @segments.
  ///
  /// In en, this message translates to:
  /// **'Segments'**
  String get segments;

  /// No description provided for @noSegmentsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No segments recorded'**
  String get noSegmentsRecorded;

  /// No description provided for @plannedDuration.
  ///
  /// In en, this message translates to:
  /// **'Planned: {duration}'**
  String plannedDuration(String duration);

  /// No description provided for @actualDuration.
  ///
  /// In en, this message translates to:
  /// **'Actual: {duration}'**
  String actualDuration(String duration);

  /// No description provided for @statisticTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistic'**
  String get statisticTitle;

  /// No description provided for @loadStatisticFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load statistic'**
  String get loadStatisticFailed;

  /// No description provided for @tagBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Tag breakdown'**
  String get tagBreakdown;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @allTags.
  ///
  /// In en, this message translates to:
  /// **'All tags'**
  String get allTags;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @allModes.
  ///
  /// In en, this message translates to:
  /// **'All modes'**
  String get allModes;

  /// No description provided for @metricSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get metricSessions;

  /// No description provided for @metricFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get metricFocus;

  /// No description provided for @metricBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get metricBreak;

  /// No description provided for @metricTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get metricTotal;

  /// No description provided for @noTagBreakdown.
  ///
  /// In en, this message translates to:
  /// **'No tag breakdown available'**
  String get noTagBreakdown;

  /// No description provided for @sessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String sessionCount(int count);

  /// No description provided for @noDataForFilter.
  ///
  /// In en, this message translates to:
  /// **'No data for this filter'**
  String get noDataForFilter;

  /// No description provided for @noStatisticData.
  ///
  /// In en, this message translates to:
  /// **'No statistic data yet'**
  String get noStatisticData;

  /// No description provided for @adjustFiltersHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get adjustFiltersHint;

  /// No description provided for @startSessionHint.
  ///
  /// In en, this message translates to:
  /// **'Start a session to see your statistic here'**
  String get startSessionHint;

  /// No description provided for @periodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get periodDaily;

  /// No description provided for @periodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get periodWeekly;

  /// No description provided for @periodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// No description provided for @periodYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get periodYearly;

  /// No description provided for @periodTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get periodTotal;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @loadSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings'**
  String get loadSettingsFailed;

  /// No description provided for @settingsSectionAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get settingsSectionAlert;

  /// No description provided for @alertTones.
  ///
  /// In en, this message translates to:
  /// **'Alert tones'**
  String get alertTones;

  /// No description provided for @settingsSectionFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get settingsSectionFocus;

  /// No description provided for @focusMode.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get focusMode;

  /// No description provided for @whitelistApps.
  ///
  /// In en, this message translates to:
  /// **'Whitelisted apps'**
  String get whitelistApps;

  /// No description provided for @appCount.
  ///
  /// In en, this message translates to:
  /// **'{count} apps'**
  String appCount(int count);

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @themeAndDisplay.
  ///
  /// In en, this message translates to:
  /// **'Theme & display'**
  String get themeAndDisplay;

  /// No description provided for @themeAodSummary.
  ///
  /// In en, this message translates to:
  /// **'{theme} · AOD {status}'**
  String themeAodSummary(String theme, String status);

  /// No description provided for @settingsSectionTimeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Time & language'**
  String get settingsSectionTimeLanguage;

  /// No description provided for @timeAndLanguage.
  ///
  /// In en, this message translates to:
  /// **'Time & language'**
  String get timeAndLanguage;

  /// No description provided for @settingsSectionStatistic.
  ///
  /// In en, this message translates to:
  /// **'Statistic'**
  String get settingsSectionStatistic;

  /// No description provided for @statisticInclusion.
  ///
  /// In en, this message translates to:
  /// **'Statistic inclusion'**
  String get statisticInclusion;

  /// No description provided for @statisticInclusionSummary.
  ///
  /// In en, this message translates to:
  /// **'Failed sessions: {failed}'**
  String statisticInclusionSummary(String failed);

  /// No description provided for @settingsSectionPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get settingsSectionPlatform;

  /// No description provided for @platformAndBattery.
  ///
  /// In en, this message translates to:
  /// **'Platform & battery'**
  String get platformAndBattery;

  /// No description provided for @platformSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform-specific behavior and battery settings'**
  String get platformSubtitle;

  /// No description provided for @alertTonesSummary.
  ///
  /// In en, this message translates to:
  /// **'Focus {focus} · Break {breakTone}'**
  String alertTonesSummary(String focus, String breakTone);

  /// No description provided for @focusLoose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get focusLoose;

  /// No description provided for @focusStrict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get focusStrict;

  /// No description provided for @focusWhitelist.
  ///
  /// In en, this message translates to:
  /// **'Whitelist'**
  String get focusWhitelist;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeFollowSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeFollowSystem;

  /// No description provided for @languageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get languageIndonesian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @timeFormat12h.
  ///
  /// In en, this message translates to:
  /// **'12-hour'**
  String get timeFormat12h;

  /// No description provided for @timeFormat24h.
  ///
  /// In en, this message translates to:
  /// **'24-hour'**
  String get timeFormat24h;

  /// No description provided for @weekStartMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekStartMonday;

  /// No description provided for @weekStartSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekStartSunday;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get timeFormat;

  /// No description provided for @weekStart.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStart;

  /// No description provided for @timeLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Time & language'**
  String get timeLanguageTitle;

  /// No description provided for @alertTonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alertTonesTitle;

  /// No description provided for @focusComplete.
  ///
  /// In en, this message translates to:
  /// **'Focus complete'**
  String get focusComplete;

  /// No description provided for @breakComplete.
  ///
  /// In en, this message translates to:
  /// **'Break complete'**
  String get breakComplete;

  /// No description provided for @focusFailed.
  ///
  /// In en, this message translates to:
  /// **'Focus failed'**
  String get focusFailed;

  /// No description provided for @alertTonePreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a tone to preview it'**
  String get alertTonePreviewHint;

  /// No description provided for @alertControlsSection.
  ///
  /// In en, this message translates to:
  /// **'Alert Controls'**
  String get alertControlsSection;

  /// No description provided for @alertControlsHint.
  ///
  /// In en, this message translates to:
  /// **'Haptic, sound, and flash for Alerts and Reminders'**
  String get alertControlsHint;

  /// No description provided for @alertHaptic.
  ///
  /// In en, this message translates to:
  /// **'Haptic'**
  String get alertHaptic;

  /// No description provided for @alertSoundMute.
  ///
  /// In en, this message translates to:
  /// **'Mute sound'**
  String get alertSoundMute;

  /// No description provided for @alertFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get alertFlash;

  /// No description provided for @alertFlashUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Flash is not supported on this device'**
  String get alertFlashUnsupported;

  /// No description provided for @alertControlsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert Controls'**
  String get alertControlsSheetTitle;

  /// No description provided for @muted.
  ///
  /// In en, this message translates to:
  /// **'Muted'**
  String get muted;

  /// No description provided for @unmuted.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get unmuted;

  /// No description provided for @focusModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get focusModeTitle;

  /// No description provided for @focusModeDegradedBanner.
  ///
  /// In en, this message translates to:
  /// **'Focus mode is running in a degraded state'**
  String get focusModeDegradedBanner;

  /// No description provided for @focusLooseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No restrictions, just a gentle reminder to stay focused'**
  String get focusLooseSubtitle;

  /// No description provided for @focusStrictSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leaving the app counts as a violation'**
  String get focusStrictSubtitle;

  /// No description provided for @focusWhitelistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only whitelisted apps are allowed during focus'**
  String get focusWhitelistSubtitle;

  /// No description provided for @usageAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Usage access permission is required'**
  String get usageAccessRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @violationThreshold.
  ///
  /// In en, this message translates to:
  /// **'Violation threshold'**
  String get violationThreshold;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @secondsCount.
  ///
  /// In en, this message translates to:
  /// **'{sec}s'**
  String secondsCount(int sec);

  /// No description provided for @manageWhitelist.
  ///
  /// In en, this message translates to:
  /// **'Manage whitelist'**
  String get manageWhitelist;

  /// No description provided for @notAvailableOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get notAvailableOnDevice;

  /// No description provided for @whitelistAppsTitle.
  ///
  /// In en, this message translates to:
  /// **'Whitelisted apps'**
  String get whitelistAppsTitle;

  /// No description provided for @installedAppsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Installed apps list is unavailable'**
  String get installedAppsUnavailable;

  /// No description provided for @selectApp.
  ///
  /// In en, this message translates to:
  /// **'Select app'**
  String get selectApp;

  /// No description provided for @addApp.
  ///
  /// In en, this message translates to:
  /// **'Add app'**
  String get addApp;

  /// No description provided for @whitelistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Whitelist is empty'**
  String get whitelistEmpty;

  /// No description provided for @whitelistOnlyWhenActive.
  ///
  /// In en, this message translates to:
  /// **'Whitelist only applies while a focus session is active'**
  String get whitelistOnlyWhenActive;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @alwaysOnDisplay.
  ///
  /// In en, this message translates to:
  /// **'Always-on display (AOD)'**
  String get alwaysOnDisplay;

  /// No description provided for @aodEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep the timer visible on screen while focusing'**
  String get aodEnabledDescription;

  /// No description provided for @notSupportedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Not supported on this device'**
  String get notSupportedOnDevice;

  /// No description provided for @statisticInclusionTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistic inclusion'**
  String get statisticInclusionTitle;

  /// No description provided for @trackFailedSessions.
  ///
  /// In en, this message translates to:
  /// **'Track failed sessions'**
  String get trackFailedSessions;

  /// No description provided for @trackFailedSessionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include failed sessions and their focus time in your statistic'**
  String get trackFailedSessionsSubtitle;

  /// No description provided for @platformBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform & battery'**
  String get platformBatteryTitle;

  /// No description provided for @platformLabel.
  ///
  /// In en, this message translates to:
  /// **'Platform: {label}'**
  String platformLabel(String label);

  /// No description provided for @segmentNotifications.
  ///
  /// In en, this message translates to:
  /// **'Segment notifications'**
  String get segmentNotifications;

  /// No description provided for @notificationDeepLinkAvailable.
  ///
  /// In en, this message translates to:
  /// **'Notifications can open the app directly'**
  String get notificationDeepLinkAvailable;

  /// No description provided for @deepLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Deep link is unavailable on this device'**
  String get deepLinkUnavailable;

  /// No description provided for @flexibleReminders.
  ///
  /// In en, this message translates to:
  /// **'Flexible reminders'**
  String get flexibleReminders;

  /// No description provided for @platformNotes.
  ///
  /// In en, this message translates to:
  /// **'Platform notes'**
  String get platformNotes;

  /// No description provided for @batteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Battery optimization'**
  String get batteryOptimization;

  /// No description provided for @batteryOptimizationBody.
  ///
  /// In en, this message translates to:
  /// **'Disable battery optimization for this app to keep the timer running reliably in the background'**
  String get batteryOptimizationBody;

  /// No description provided for @openBatterySettings.
  ///
  /// In en, this message translates to:
  /// **'Open battery settings'**
  String get openBatterySettings;

  /// No description provided for @errorFocusPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Focus permission was denied'**
  String get errorFocusPermissionDenied;

  /// No description provided for @errorSaveSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get errorSaveSettingsFailed;

  /// No description provided for @errorStorageWriteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to write to storage'**
  String get errorStorageWriteFailed;

  /// No description provided for @sessionStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sessionStatusCompleted;

  /// No description provided for @sessionStatusAbandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get sessionStatusAbandoned;

  /// No description provided for @sessionStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get sessionStatusFailed;

  /// No description provided for @sessionStatusManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get sessionStatusManual;

  /// No description provided for @sessionStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get sessionStatusActive;

  /// No description provided for @durationZero.
  ///
  /// In en, this message translates to:
  /// **'0m'**
  String get durationZero;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutesOnly(int minutes);

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String todayDate(String date);

  /// No description provided for @yesterdayDate.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {date}'**
  String yesterdayDate(String date);

  /// No description provided for @deletedTag.
  ///
  /// In en, this message translates to:
  /// **'Deleted tag'**
  String get deletedTag;

  /// No description provided for @languageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Language is not supported.'**
  String get languageUnsupported;

  /// No description provided for @weekStartInvalid.
  ///
  /// In en, this message translates to:
  /// **'Week start day is invalid.'**
  String get weekStartInvalid;

  /// No description provided for @violationThresholdOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Violation threshold must be between {min}–{max} seconds.'**
  String violationThresholdOutOfRange(int min, int max);

  /// No description provided for @alertToneFocusSuccessInvalid.
  ///
  /// In en, this message translates to:
  /// **'Focus-complete tone is invalid.'**
  String get alertToneFocusSuccessInvalid;

  /// No description provided for @alertToneBreakOverInvalid.
  ///
  /// In en, this message translates to:
  /// **'Break-complete tone is invalid.'**
  String get alertToneBreakOverInvalid;

  /// No description provided for @alertToneFocusFailureInvalid.
  ///
  /// In en, this message translates to:
  /// **'Focus-failure tone is invalid.'**
  String get alertToneFocusFailureInvalid;

  /// No description provided for @whitelistEntryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Whitelist entry must not be empty.'**
  String get whitelistEntryEmpty;

  /// No description provided for @notificationFocusing.
  ///
  /// In en, this message translates to:
  /// **'Focusing'**
  String get notificationFocusing;

  /// No description provided for @notificationResting.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get notificationResting;

  /// No description provided for @notificationExit.
  ///
  /// In en, this message translates to:
  /// **'Tap to return to the session'**
  String get notificationExit;

  /// No description provided for @notificationSessionStoppedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session stopped'**
  String get notificationSessionStoppedTitle;

  /// No description provided for @notificationSessionStoppedBody.
  ///
  /// In en, this message translates to:
  /// **'Your session has been stopped'**
  String get notificationSessionStoppedBody;

  /// No description provided for @notificationFocusCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus complete'**
  String get notificationFocusCompleteTitle;

  /// No description provided for @notificationBreakCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Break complete'**
  String get notificationBreakCompleteTitle;

  /// No description provided for @notificationTimeForBreak.
  ///
  /// In en, this message translates to:
  /// **'Time for a break'**
  String get notificationTimeForBreak;

  /// No description provided for @notificationTimeForFocus.
  ///
  /// In en, this message translates to:
  /// **'Time to focus'**
  String get notificationTimeForFocus;

  /// No description provided for @notificationFocusFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus session failed'**
  String get notificationFocusFailedTitle;

  /// No description provided for @notificationFocusViolationBody.
  ///
  /// In en, this message translates to:
  /// **'You left the app during focus mode'**
  String get notificationFocusViolationBody;

  /// No description provided for @notificationFocusReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus reminder'**
  String get notificationFocusReminderTitle;

  /// No description provided for @notificationFocusReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Stay focused, your session is still running'**
  String get notificationFocusReminderBody;

  /// No description provided for @capNotificationInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Notification service failed to start. Alerts are unavailable; try restarting the app.'**
  String get capNotificationInitFailed;

  /// No description provided for @capAndroidNeedsNotificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Segment notifications require notification permission.'**
  String get capAndroidNeedsNotificationPermission;

  /// No description provided for @capIosStrictBackgroundOnly.
  ///
  /// In en, this message translates to:
  /// **'iOS: other-app detection is unavailable — Strict only applies when this app is in the background.'**
  String get capIosStrictBackgroundOnly;

  /// No description provided for @capIosBackgroundNotificationsBestEffort.
  ///
  /// In en, this message translates to:
  /// **'iOS background notifications are best-effort.'**
  String get capIosBackgroundNotificationsBestEffort;

  /// No description provided for @capDesktopFocusLimited.
  ///
  /// In en, this message translates to:
  /// **'Desktop: Strict/Whitelist focus is limited.'**
  String get capDesktopFocusLimited;

  /// No description provided for @capScheduledNotificationsUnreliable.
  ///
  /// In en, this message translates to:
  /// **'Scheduled notifications may be unreliable when the app is closed.'**
  String get capScheduledNotificationsUnreliable;

  /// No description provided for @capWebFocusDowngradeToLoose.
  ///
  /// In en, this message translates to:
  /// **'Web: Strict/Whitelist downgrade to Loose.'**
  String get capWebFocusDowngradeToLoose;

  /// No description provided for @capWebNotificationsNeedActiveTab.
  ///
  /// In en, this message translates to:
  /// **'Web notifications require an active tab or browser permission.'**
  String get capWebNotificationsNeedActiveTab;

  /// No description provided for @capWebAodWakeLock.
  ///
  /// In en, this message translates to:
  /// **'Web AOD uses Wake Lock — the screen must stay visible.'**
  String get capWebAodWakeLock;

  /// No description provided for @capFocusModesDegradedToLoose.
  ///
  /// In en, this message translates to:
  /// **'Strict/Whitelist is not fully available — sessions run as Loose.'**
  String get capFocusModesDegradedToLoose;

  /// No description provided for @capAodUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Always-on display is not supported on this platform.'**
  String get capAodUnsupported;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

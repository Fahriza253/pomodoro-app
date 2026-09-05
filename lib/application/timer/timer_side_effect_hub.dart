import 'package:pomodoro_app/application/timer/alert_modality.dart';
import 'package:pomodoro_app/application/timer/immediate_event_delivery.dart';
import 'package:pomodoro_app/application/timer/notification_strings.dart';
import 'package:pomodoro_app/application/timer/segment_end_copy.dart';
import 'package:pomodoro_app/application/timer/segment_end_cycle_progress.dart';
import 'package:pomodoro_app/application/timer/segment_end_delivery.dart';
import 'package:pomodoro_app/application/timer/side_effect_context.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';
import 'package:pomodoro_app/domain/timer/models/timer_engine_state.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter.dart';
import 'package:pomodoro_app/platform/audio/alert_sound_adapter.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/platform/haptic/haptic_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_deep_link.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';

/// Owns Alert / OS notification / Focus / AOD / Flexible Reminder side effects.
///
/// Loads [AppSettings] itself; does not hold a facade back-pointer.
class TimerSideEffectHub {
  TimerSideEffectHub({
    required this._settingsRepository,
    required this._notificationAdapter,
    required this._alertSoundAdapter,
    required this._hapticAdapter,
    required this._flashAdapter,
    required this._focusAdapter,
    required this._aodAdapter,
  });

  final SettingsRepository _settingsRepository;
  final NotificationAdapter _notificationAdapter;
  final AlertSoundAdapter _alertSoundAdapter;
  final HapticAdapter _hapticAdapter;
  final FlashAdapter _flashAdapter;
  final FocusAdapter _focusAdapter;
  final AODAdapter _aodAdapter;

  /// Process-local schedule ownership (no schema token).
  ///
  /// ponytail: lost on process death; cold start with remaining ≤ 0 assumes
  /// the OS already posted. Upgrade: persist last delivered segment token on
  /// ActiveTimerState if silent-miss reports show up.
  DateTime? _scheduledFireAtUtc;
  bool _scheduleEnqueued = false;
  bool _enqueueAttempted = false;
  bool _osOwnedCatchUp = false;
  int? _scheduledNotificationId;
  final _failureDelivery = _ImmediateDeliveryMemory();
  final _reminderDelivery = _ImmediateDeliveryMemory();

  /// Segment / session phase transition Alert + platform sync.
  ///
  /// Returns `true` when [SideEffectContext.suppressNextSegmentAlert] was
  /// consumed (facade should clear its flag).
  Future<bool> onSegmentTransition(SideEffectContext context) async {
    final suppressConsumed = await _maybePlaySegmentAlert(context);
    await _syncPlatformAdapters(context);
    if (!context.isForeground) {
      await _syncRunningTimerNotification(context);
    }
    return suppressConsumed;
  }

  /// Failure Alert (focus violation or stop). Default copy is focus-failed.
  Future<void> onFocusFailed(
    SideEffectContext context, {
    String? title,
    String? body,
    bool osNotification = true,
  }) async {
    final settings = await _settingsRepository.get();
    final copy = NotificationStrings.forLanguage(settings.language);
    await _playFailureAlert(
      context: context,
      settings: settings,
      title: title ?? copy.focusFailedTitle,
      body: body ?? copy.focusViolationBody,
      osNotification: osNotification,
    );
  }

  /// Background lifecycle flush of tray / scheduled segment-end.
  Future<void> onLifecycleBackground(SideEffectContext context) async {
    await _scheduleSegmentNotification(context);
    await _syncRunningTimerNotification(context);
  }

  /// Foreground return — drop the running-timer tray; Dart takes schedule if
  /// fire time is still in the future.
  Future<void> onLifecycleForeground(SideEffectContext context) async {
    await _notificationAdapter.cancel(kRunningTimerNotificationId);
    await _catchUpFailedImmediatePosts();
    final sessionId = context.sessionId;
    final fireAt = _scheduledFireAtUtc;
    final now = context.nowUtc;
    if (fireAt != null && now.isBefore(fireAt)) {
      final id =
          _scheduledNotificationId ??
          (sessionId == null
              ? null
              : _scheduledSegmentEndNotificationId(sessionId, 0));
      if (id != null) {
        await _notificationAdapter.cancel(id);
      }
      _clearScheduleMemory();
      _osOwnedCatchUp = false;
      return;
    }
    if (_scheduleEnqueued && fireAt != null) {
      _osOwnedCatchUp = true;
      return;
    }
    if (_enqueueAttempted && !_scheduleEnqueued) {
      _osOwnedCatchUp = false;
      return;
    }
    final state = context.after;
    final remaining = state?.remainingSecAt(now) ?? 1;
    _osOwnedCatchUp =
        state != null && state.phase == EnginePhase.running && remaining <= 0;
  }

  /// Idle teardown of platform surfaces (no active Session).
  Future<void> onIdle() async {
    await _focusAdapter.stopMonitoring();
    await _aodAdapter.disable();
    await _notificationAdapter.cancelAll();
    _clearScheduleMemory();
    _osOwnedCatchUp = false;
    _failureDelivery.reset();
    _reminderDelivery.reset();
  }

  /// Flexible Reminder delivery (engine ack stays on [SessionLifecycle]).
  Future<void> maybeFlexibleReminder(SideEffectContext context) async {
    final sessionId = context.sessionId;
    final state = context.after;
    if (sessionId == null || state == null) {
      return;
    }
    if (!state.isFlexible || state.phase != EnginePhase.running) {
      return;
    }
    _reminderDelivery.bind(
      '$sessionId:${state.elapsedActiveSecAt(context.nowUtc)}',
    );
    final settings = await _settingsRepository.get();
    final copy = NotificationStrings.forLanguage(settings.language);
    final delivery = planImmediateEventFire(
      foreground: context.isForeground,
      osPosted: _reminderDelivery.osPosted,
      osPostAttempted: _reminderDelivery.osPostAttempted,
      inAppPlayed: _reminderDelivery.inAppPlayed,
    );
    if (delivery == ImmediateEventDelivery.silent) {
      return;
    }
    if (delivery == ImmediateEventDelivery.inApp) {
      await _applyAlertModalities(
        settings,
        foreground: true,
        soundToneId: null,
      );
      _reminderDelivery.inAppPlayed = true;
      return;
    }
    final plan = _planFor(settings, foreground: false);
    final posted = await _notificationAdapter.showReminder(
      title: copy.focusReminderTitle,
      body: copy.focusReminderBody,
      sessionId: sessionId,
      playSound: plan.osNotificationPlaySound,
    );
    _reminderDelivery.osPostAttempted = true;
    _reminderDelivery.osPosted = posted;
  }

  Future<bool> _maybePlaySegmentAlert(SideEffectContext context) async {
    final before = context.before;
    final after = context.after;
    final sessionId = context.sessionId;
    if (before == null || after == null || sessionId == null) {
      return false;
    }

    final completedPrompt =
        after.phase == EnginePhase.segmentComplete ||
        after.phase == EnginePhase.sessionComplete;
    final autoAdvanced =
        before.phase == EnginePhase.running &&
        after.phase == EnginePhase.running &&
        before.currentSegmentIndex != after.currentSegmentIndex;
    if ((!completedPrompt && !autoAdvanced) ||
        before.phase != EnginePhase.running) {
      return false;
    }
    final segment = before.currentSegment;
    if (segment == null) {
      return false;
    }

    final settings = await _settingsRepository.get();
    final isFocusLike =
        segment.type == SegmentType.focus ||
        segment.type == SegmentType.flexible;
    if (!isFocusLike && !segment.isRest) {
      return false;
    }

    final soundToneId = isFocusLike
        ? settings.alertToneFocusSuccess
        : settings.alertToneBreakOver;

    final delivery = planSegmentEndFire(
      foreground: context.isForeground,
      suppress: context.suppressNextSegmentAlert,
      scheduleEnqueued: _scheduleEnqueued,
      scheduledFireAtUtc: _scheduledFireAtUtc,
      nowUtc: context.nowUtc,
      enqueueAttempted: _enqueueAttempted,
      osOwnedCatchUp: _osOwnedCatchUp,
    );
    _osOwnedCatchUp = false;

    if (delivery == SegmentEndFireDelivery.silent) {
      if (context.suppressNextSegmentAlert) {
        await _cancelSegmentEndNotifications(sessionId);
        _clearScheduleMemory();
      } else if (context.isForeground || after.phase != EnginePhase.running) {
        _clearScheduleMemory();
      }
      return context.suppressNextSegmentAlert;
    }

    if (delivery == SegmentEndFireDelivery.inApp) {
      await _cancelSegmentEndNotifications(sessionId);
      await _applyAlertModalities(
        settings,
        foreground: true,
        soundToneId: soundToneId,
      );
      _clearScheduleMemory();
      return false;
    }

    final copy = NotificationStrings.forLanguage(settings.language);
    final endCopy = _segmentEndCopyForTransition(
      before: before,
      after: after,
      strings: copy,
    );
    final plan = _planFor(settings, foreground: false);
    await _notificationAdapter.showAlert(
      title: endCopy.title,
      body: endCopy.body,
      sessionId: sessionId,
      soundToneId: soundToneId,
      notificationId: _immediateSegmentEndNotificationId(sessionId),
      deepLinkSource: NotificationDeepLink.sourceSegmentEnd,
      playSound: plan.osNotificationPlaySound,
    );
    await _applyAlertModalities(settings, foreground: false, soundToneId: null);
    _clearScheduleMemory();
    return false;
  }

  Future<void> _playFailureAlert({
    required SideEffectContext context,
    required AppSettings settings,
    required String title,
    required String body,
    required bool osNotification,
  }) async {
    final toneId = settings.alertToneFocusFailure;
    final sessionId = context.sessionId;
    _failureDelivery.bind(sessionId ?? '');

    if (!osNotification) {
      await _applyAlertModalities(
        settings,
        foreground: true,
        soundToneId: toneId,
      );
      _failureDelivery.inAppPlayed = true;
      return;
    }

    final delivery = planImmediateEventFire(
      foreground: context.isForeground,
      osPosted: _failureDelivery.osPosted,
      osPostAttempted: _failureDelivery.osPostAttempted,
      inAppPlayed: _failureDelivery.inAppPlayed,
    );
    if (delivery == ImmediateEventDelivery.silent) {
      return;
    }
    if (delivery == ImmediateEventDelivery.inApp) {
      await _applyAlertModalities(
        settings,
        foreground: true,
        soundToneId: toneId,
      );
      _failureDelivery.inAppPlayed = true;
      return;
    }
    if (sessionId == null) {
      return;
    }
    final plan = _planFor(settings, foreground: false);
    await _notificationAdapter.cancel(sessionId.hashCode);
    final posted = await _notificationAdapter.showAlert(
      title: title,
      body: body,
      sessionId: sessionId,
      soundToneId: toneId,
      notificationId: sessionId.hashCode ^ 0x4641494c, // 'FAIL'
      playSound: plan.osNotificationPlaySound,
    );
    _failureDelivery.osPostAttempted = true;
    _failureDelivery.osPosted = posted;
  }

  Future<void> _syncPlatformAdapters(SideEffectContext context) async {
    final state = context.after;
    if (state == null) {
      return;
    }
    final phase = state.phase;
    final settings = await _settingsRepository.get();

    if (phase == EnginePhase.running) {
      await _startFocusMonitoring(settings);
      await _scheduleSegmentNotification(context);
      if (settings.alwaysOnDisplay) {
        await _aodAdapter.enable();
      }
    } else if (phase == EnginePhase.paused ||
        phase == EnginePhase.segmentComplete ||
        phase == EnginePhase.sessionComplete) {
      await _focusAdapter.stopMonitoring();
      if (settings.alwaysOnDisplay) {
        await _aodAdapter.enable();
      }
    } else {
      await _focusAdapter.stopMonitoring();
      await _aodAdapter.disable();
      await _notificationAdapter.cancelAll();
    }
  }

  Future<void> _syncRunningTimerNotification(SideEffectContext context) async {
    final sessionId = context.sessionId;
    if (sessionId == null) {
      await _notificationAdapter.cancel(kRunningTimerNotificationId);
      return;
    }
    final state = context.after;
    if (state == null) {
      await _notificationAdapter.cancel(kRunningTimerNotificationId);
      return;
    }
    final settings = await _settingsRepository.get();
    final copy = NotificationStrings.forLanguage(settings.language);
    final content = buildRunningTimerContent(
      state: state,
      sessionId: sessionId,
      nowUtc: context.nowUtc,
      focusingTitle: copy.focusing,
      restingTitle: copy.resting,
    );
    if (content == null) {
      await _notificationAdapter.cancel(kRunningTimerNotificationId);
    } else {
      await _notificationAdapter.showRunningTimer(content);
    }
  }

  Future<void> _scheduleSegmentNotification(SideEffectContext context) async {
    final sessionId = context.sessionId;
    final state = context.after;
    if (sessionId == null || state == null) {
      return;
    }
    if (!state.isPomodoro || state.phase != EnginePhase.running) {
      return;
    }
    final segment = state.currentSegment;
    if (segment == null) {
      return;
    }
    final now = context.nowUtc;
    final remaining = state.remainingSecAt(now);
    final decision = planSegmentEndSchedule(
      foreground: context.isForeground,
      remainingSec: remaining,
      existingFireAtUtc: _scheduledFireAtUtc,
      nowUtc: now,
    );
    if (decision == SegmentEndScheduleDecision.skip ||
        decision == SegmentEndScheduleDecision.leaveDue) {
      return;
    }

    final settings = await _settingsRepository.get();
    final isFocus = segment.type == SegmentType.focus;
    final soundToneId = isFocus
        ? settings.alertToneFocusSuccess
        : settings.alertToneBreakOver;
    final copy = NotificationStrings.forLanguage(settings.language);
    final index = state.currentSegmentIndex;
    final nextIndex = index + 1;
    final nextType = nextIndex < state.segments.length
        ? state.segments[nextIndex].type
        : null;
    final sessionComplete = nextType == null;
    final cyclesAfter = cyclesCompletedAfterPredictedFinish(
      cyclesCompletedNow: state.pomodoroCyclesCompleted,
      current: segment.type,
    );
    final progress = segmentEndCycleProgress(
      cyclesCompletedAfterSegment: cyclesAfter,
      cyclesTarget: state.pomodoroCyclesTarget,
      finished: segment.type,
      sessionComplete: sessionComplete,
    );
    final endCopy = SegmentEndCopy.build(
      strings: copy,
      finished: segment.type,
      next: nextType,
      completedCount: progress.n,
      totalCount: progress.total,
      sessionComplete: sessionComplete,
    );

    final scheduledId = _scheduledSegmentEndNotificationId(sessionId, index);
    final fireAt = now.add(Duration(seconds: remaining));
    final enqueued = await _notificationAdapter.scheduleSegmentEnd(
      fireAtUtc: fireAt,
      title: endCopy.title,
      body: endCopy.body,
      notificationId: scheduledId,
      sessionId: sessionId,
      soundToneId: soundToneId,
      playSound: _planFor(
        settings,
        foreground: context.isForeground,
      ).osNotificationPlaySound,
    );
    _enqueueAttempted = true;
    _scheduledFireAtUtc = fireAt;
    _scheduleEnqueued = enqueued;
    _scheduledNotificationId = scheduledId;
  }

  void _clearScheduleMemory() {
    _scheduledFireAtUtc = null;
    _scheduleEnqueued = false;
    _enqueueAttempted = false;
    _scheduledNotificationId = null;
  }

  /// Visible catch-up after a failed immediate OS post (BR-SETTINGS-010).
  Future<void> _catchUpFailedImmediatePosts() async {
    final failureCatchUp = _needsVisibleCatchUp(_failureDelivery);
    final reminderCatchUp = _needsVisibleCatchUp(_reminderDelivery);
    if (!failureCatchUp && !reminderCatchUp) {
      return;
    }
    final settings = await _settingsRepository.get();
    if (failureCatchUp) {
      await _applyAlertModalities(
        settings,
        foreground: true,
        soundToneId: settings.alertToneFocusFailure,
      );
      _failureDelivery.inAppPlayed = true;
    }
    if (reminderCatchUp) {
      await _applyAlertModalities(
        settings,
        foreground: true,
        soundToneId: null,
      );
      _reminderDelivery.inAppPlayed = true;
    }
  }

  bool _needsVisibleCatchUp(_ImmediateDeliveryMemory memory) =>
      memory.osPostAttempted && !memory.osPosted && !memory.inAppPlayed;

  Future<void> _startFocusMonitoring(AppSettings settings) async {
    final effective = _effectiveFocusMode(settings);
    await _focusAdapter.startMonitoring(
      effectiveMode: effective,
      whitelist: settings.whitelist,
      threshold: Duration(seconds: settings.focusViolationThresholdSec),
    );
  }

  FocusMode _effectiveFocusMode(AppSettings settings) {
    final caps = _focusAdapter.capabilities();
    return switch (settings.focusMode) {
      FocusMode.strict =>
        caps.strictAvailable ? FocusMode.strict : FocusMode.loose,
      FocusMode.whitelist =>
        caps.whitelistAvailable ? FocusMode.whitelist : FocusMode.loose,
      FocusMode.loose => FocusMode.loose,
    };
  }

  AlertModalityPlan _planFor(AppSettings settings, {required bool foreground}) {
    return planAlertModalities(
      foreground: foreground,
      soundMuted: settings.alertSoundMuted,
      hapticEnabled: settings.alertHapticEnabled,
      flashEnabled: settings.alertFlashEnabled,
      flashCapable: _flashAdapter.capabilities().supported,
    );
  }

  Future<void> _applyAlertModalities(
    AppSettings settings, {
    required bool foreground,
    required String? soundToneId,
  }) async {
    final plan = _planFor(settings, foreground: foreground);
    if (plan.playInAppSound && soundToneId != null) {
      await _alertSoundAdapter.play(soundToneId);
    }
    if (plan.triggerHaptic) {
      await _hapticAdapter.pulse();
    }
    if (plan.triggerFlash) {
      await _flashAdapter.pulse();
    }
  }

  Future<void> _cancelSegmentEndNotifications(String sessionId) async {
    final scheduled = _scheduledNotificationId;
    if (scheduled != null) {
      await _notificationAdapter.cancel(scheduled);
    }
    await _notificationAdapter.cancel(
      _scheduledSegmentEndNotificationId(sessionId, 0),
    );
    await _notificationAdapter.cancel(
      _immediateSegmentEndNotificationId(sessionId),
    );
  }

  SegmentEndCopy _segmentEndCopyForTransition({
    required TimerEngineState before,
    required TimerEngineState after,
    required NotificationStrings strings,
  }) {
    final finished = before.currentSegment!;
    final index = before.currentSegmentIndex;
    final nextIndex = index + 1;
    final nextType = nextIndex < before.segments.length
        ? before.segments[nextIndex].type
        : null;
    final sessionComplete = after.phase == EnginePhase.sessionComplete;
    final progress = segmentEndCycleProgress(
      cyclesCompletedAfterSegment: after.pomodoroCyclesCompleted,
      cyclesTarget: after.pomodoroCyclesTarget,
      finished: finished.type,
      sessionComplete: sessionComplete,
    );
    return SegmentEndCopy.build(
      strings: strings,
      finished: finished.type,
      next: nextType,
      completedCount: progress.n,
      totalCount: progress.total,
      sessionComplete: sessionComplete,
    );
  }

  int _scheduledSegmentEndNotificationId(String sessionId, int segmentIndex) =>
      sessionId.hashCode ^ segmentIndex;

  int _immediateSegmentEndNotificationId(String sessionId) =>
      sessionId.hashCode ^ 0x454E44; // 'END'
}

/// Process-local once-only token for a now-firing event (failure or Reminder).
///
/// ponytail: lost on process death; process-killed Reminder/failure delivery
/// is out of scope (no OS schedule). Upgrade: persist last delivered token.
class _ImmediateDeliveryMemory {
  String? token;
  bool osPosted = false;
  bool osPostAttempted = false;
  bool inAppPlayed = false;

  void bind(String nextToken) {
    if (token == nextToken) {
      return;
    }
    token = nextToken;
    osPosted = false;
    osPostAttempted = false;
    inAppPlayed = false;
  }

  void reset() {
    token = null;
    osPosted = false;
    osPostAttempted = false;
    inAppPlayed = false;
  }
}

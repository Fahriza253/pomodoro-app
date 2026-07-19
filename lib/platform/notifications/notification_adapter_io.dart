import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pomodoro_app/domain/settings/alert_tone_catalog.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/notification_deep_link.dart';
import 'package:pomodoro_app/platform/notifications/notification_schedule_time.dart';
import 'package:pomodoro_app/platform/notifications/running_timer_notification.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

NotificationAdapter createNotificationAdapter() {
  if (Platform.isAndroid || Platform.isIOS) {
    return LocalNotificationAdapter.instance;
  }
  return StubNotificationAdapter();
}

/// Android/iOS notifications via flutter_local_notifications (BR-TIMER-012).
class LocalNotificationAdapter implements NotificationAdapter {
  LocalNotificationAdapter._();

  static final LocalNotificationAdapter instance = LocalNotificationAdapter._();

  static const _channelPrefix = 'timer_alerts';
  static const _reminderChannelId = 'timer_reminders';
  static const _runningChannelId = 'timer_running';
  // White-alpha silhouette — full-color mipmaps look like a blank placeholder.
  static const _androidIcon = '@drawable/ic_stat_pomodoro';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _initFailed = false;
  bool _permissionGranted = false;
  bool _permissionRequested = false;
  final Set<String> _createdChannels = {};
  void Function(Uri uri)? _deepLinkHandler;
  Uri? _pendingLaunchUri;

  Uri? consumePendingLaunchUri() {
    final uri = _pendingLaunchUri;
    _pendingLaunchUri = null;
    return uri;
  }

  /// Marks bootstrap failure so Settings can show degraded notification state.
  void markInitFailed() {
    _initFailed = true;
  }

  Future<void> initialize() async {
    if (_initialized || _initFailed) return;
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings(_androidIcon);
    // Do not prompt at cold start (NFR-SEC-003) — [ensurePermission] is JIT.
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: false,
      defaultPresentBanner: true,
      defaultPresentList: true,
      notificationCategories: [
        DarwinNotificationCategory(
          kRunningTimerCategoryId,
          actions: [
            DarwinNotificationAction.plain(
              NotificationDeepLink.actionExit,
              'Exit',
              options: {DarwinNotificationActionOption.destructive},
            ),
          ],
        ),
      ],
    );

    await _plugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      _permissionGranted = await android?.areNotificationsEnabled() ?? true;
      await _ensureAndroidChannel(
        channelId: _reminderChannelId,
        channelName: 'Timer Reminders',
        description: 'Pengingat sesi Flexible',
        soundToneId: null,
      );
      await _ensureAndroidChannel(
        channelId: _runningChannelId,
        channelName: 'Timer Running',
        description: 'Timer sesi saat app di background',
        soundToneId: null,
        importance: Importance.low,
        playSound: false,
      );
      for (final toneId in {
        ...AlertToneCatalog.sharedSegmentToneIds,
        ...AlertToneCatalog.focusFailureToneIds,
      }) {
        await _ensureAndroidChannel(
          channelId: _channelIdForTone(toneId),
          channelName: 'Timer · ${AlertToneCatalog.label(toneId)}',
          description: 'Notifikasi segment selesai dengan nada kustom',
          soundToneId: toneId,
        );
      }
    }

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails!.notificationResponse;
      _pendingLaunchUri = NotificationDeepLink.uriFromResponse(
        actionId: response?.actionId,
        isAction:
            response?.notificationResponseType ==
            NotificationResponseType.selectedNotificationAction,
        payload: response?.payload,
      );
    }

    _initialized = true;
  }

  @override
  Future<void> ensurePermission() async {
    if (_initFailed) return;
    if (!_initialized) await initialize();
    if (_initFailed || _permissionGranted || _permissionRequested) {
      return;
    }
    _permissionRequested = true;

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      _permissionGranted =
          await android?.requestNotificationsPermission() ??
          await android?.areNotificationsEnabled() ??
          true;
      return;
    }

    if (Platform.isIOS) {
      _permissionGranted =
          await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true, badge: false) ??
          false;
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on Object {
      tz.setLocalLocation(tz.UTC);
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final uri = NotificationDeepLink.uriFromResponse(
      actionId: response.actionId,
      isAction:
          response.notificationResponseType ==
          NotificationResponseType.selectedNotificationAction,
      payload: response.payload,
    );
    if (uri == null) return;
    final handler = _deepLinkHandler;
    if (handler != null) {
      // Synchronous: suppress before any resumed tick that yields on Duration.zero.
      handler(uri);
    } else {
      _pendingLaunchUri = uri;
    }
  }

  @override
  NotificationCapabilities capabilities() {
    if (_initFailed) {
      return const NotificationCapabilities(
        scheduledSegmentEnd: false,
        reminders: false,
        deepLinkOnTap: false,
        initFailed: true,
      );
    }
    return NotificationCapabilities(
      scheduledSegmentEnd: _permissionGranted,
      reminders: _permissionGranted,
      deepLinkOnTap: true,
      customSound: true,
      backgroundDelivery: _permissionGranted,
    );
  }

  @override
  Future<void> scheduleSegmentEnd({
    required DateTime fireAtUtc,
    required String title,
    required String body,
    required int notificationId,
    required String sessionId,
    required String soundToneId,
  }) async {
    await _ensureReady();
    final scheduled = tz.TZDateTime.from(
      truncateUtcToSeconds(fireAtUtc),
      tz.local,
    );
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      notificationId.abs(),
      title,
      body,
      scheduled,
      await _notificationDetails(soundToneId),
      androidScheduleMode: await _androidScheduleMode(),
      payload: NotificationDeepLink.timerSessionUri(
        sessionId,
        source: NotificationDeepLink.sourceSegmentEnd,
      ).toString(),
    );
  }

  /// Prefer exact when [SCHEDULE_EXACT_ALARM] is granted; else inexact.
  Future<AndroidScheduleMode> _androidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canExact = await android?.canScheduleExactNotifications() ?? false;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  @override
  Future<void> showAlert({
    required String title,
    required String body,
    required String sessionId,
    required String soundToneId,
    int? notificationId,
    String? deepLinkSource,
  }) async {
    await _ensureReady();
    final id = (notificationId ?? sessionId.hashCode ^ soundToneId.hashCode)
        .abs();
    await _plugin.show(
      id,
      title,
      body,
      await _notificationDetails(soundToneId),
      payload: NotificationDeepLink.timerSessionUri(
        sessionId,
        source: deepLinkSource,
      ).toString(),
    );
  }

  @override
  Future<void> showReminder({
    required String title,
    required String body,
    required String sessionId,
  }) async {
    await _ensureReady();
    await _plugin.show(
      sessionId.hashCode.abs(),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          'Timer Reminders',
          channelDescription: 'Pengingat sesi Flexible',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.private,
          category: AndroidNotificationCategory.reminder,
          icon: _androidIcon,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
        ),
      ),
      payload: NotificationDeepLink.timerSessionUri(sessionId).toString(),
    );
  }

  @override
  Future<void> showRunningTimer(RunningTimerContent content) async {
    await _ensureReady();
    final anchor = content.chronometerAnchorUtc;
    final useChronometer = Platform.isAndroid && anchor != null;

    await _plugin.show(
      kRunningTimerNotificationId,
      content.title,
      content.timerLabel,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _runningChannelId,
          'Timer Running',
          channelDescription: 'Timer sesi saat app di background',
          importance: Importance.low,
          priority: Priority.low,
          icon: _androidIcon,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          silent: true,
          visibility: NotificationVisibility.private,
          showWhen: useChronometer,
          when: useChronometer ? anchor.millisecondsSinceEpoch : null,
          usesChronometer: useChronometer,
          chronometerCountDown: useChronometer && content.countDown,
          actions: const [
            AndroidNotificationAction(
              NotificationDeepLink.actionExit,
              'Exit',
              cancelNotification: true,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: false,
          presentBanner: true,
          presentList: true,
          categoryIdentifier: kRunningTimerCategoryId,
          interruptionLevel: InterruptionLevel.passive,
        ),
      ),
      payload: NotificationDeepLink.timerSessionUri(
        content.sessionId,
      ).toString(),
    );
  }

  @override
  Future<void> cancel(int notificationId) async {
    if (!_initialized) return;
    await _plugin.cancel(notificationId.abs());
  }

  @override
  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  @override
  void setDeepLinkHandler(void Function(Uri uri) handler) {
    _deepLinkHandler = handler;
    final pending = _pendingLaunchUri;
    if (pending != null) {
      _pendingLaunchUri = null;
      handler(pending);
    }
  }

  String _channelIdForTone(String toneId) =>
      '${_channelPrefix}_${AlertToneCatalog.androidRawName(toneId)}';

  Future<void> _ensureAndroidChannel({
    required String channelId,
    required String channelName,
    required String description,
    required String? soundToneId,
    Importance importance = Importance.high,
    bool playSound = true,
  }) async {
    if (!Platform.isAndroid || _createdChannels.contains(channelId)) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        channelId,
        channelName,
        description: description,
        importance: importance,
        playSound: playSound,
        sound: soundToneId == null
            ? null
            : RawResourceAndroidNotificationSound(
                AlertToneCatalog.androidRawName(soundToneId),
              ),
        enableVibration: playSound,
      ),
    );
    _createdChannels.add(channelId);
  }

  Future<NotificationDetails> _notificationDetails(String soundToneId) async {
    final channelId = _channelIdForTone(soundToneId);
    await _ensureAndroidChannel(
      channelId: channelId,
      channelName: 'Timer · ${AlertToneCatalog.label(soundToneId)}',
      description: 'Notifikasi segment selesai dengan nada kustom',
      soundToneId: soundToneId,
    );

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Timer · ${AlertToneCatalog.label(soundToneId)}',
        channelDescription: 'Notifikasi segment selesai dengan nada kustom',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.private,
        category: AndroidNotificationCategory.alarm,
        icon: _androidIcon,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(
          AlertToneCatalog.androidRawName(soundToneId),
        ),
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        sound: AlertToneCatalog.iosBundleSound(soundToneId),
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  Future<void> _ensureReady() async {
    if (_initFailed) return;
    if (!_initialized) await initialize();
    if (_initFailed) return;
    await ensurePermission();
  }
}

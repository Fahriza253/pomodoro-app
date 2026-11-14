import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/app_bootstrap.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/app/router.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_io.dart';
import 'package:pomodoro_app/platform/notifications/notification_deep_link.dart';
import 'package:pomodoro_app/presentation/l10n/locale_providers.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/app/theme/app_theme.dart';
import 'package:pomodoro_app/presentation/timer/timer_lifecycle_observer.dart';

/// Persisted theme as soon as the DB is open (including splash), not only after handoff.
final bootstrapThemeModeProvider = Provider<ThemeMode>((ref) {
  final db = ref.watch(appDatabaseProvider);
  if (!db.hasValue) {
    return ThemeMode.system;
  }
  return ref.watch(appSettingsStreamProvider).maybeWhen(
    data: (settings) => switch (settings.theme) {
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
      AppTheme.system => ThemeMode.system,
    },
    orElse: () => ThemeMode.system,
  );
});

class PomodoroApp extends ConsumerWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrapComplete = ref.watch(bootstrapReadyProvider);
    final themeMode = ref.watch(bootstrapThemeModeProvider);

    if (bootstrapComplete) {
      ref.watch(sessionRecoveryBootstrapProvider);
      ref.watch(notificationDeepLinkBootstrapProvider);
    }

    final router = ref.watch(routerProvider);

    Locale? locale;
    if (bootstrapComplete) {
      locale = Locale(ref.watch(localeCodeProvider));
    }

    return TimerLifecycleObserver(
      child: MaterialApp.router(
        title: 'Pomodoro',
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: themeMode,
        theme: AppThemeData.light(),
        darkTheme: AppThemeData.dark(),
        routerConfig: router,
      ),
    );
  }
}

/// Wires notification deep links once after DB is ready (not on every rebuild).
final notificationDeepLinkBootstrapProvider = Provider<void>((ref) {
  final adapter = ref.watch(notificationAdapterProvider);
  final router = ref.watch(routerProvider);

  void handle(Uri uri) {
    if (!NotificationDeepLink.isTimerPath(uri)) {
      return;
    }
    if (NotificationDeepLink.isExit(uri)) {
      final activeSessionId = ref
          .read(timerCoordinatorProvider)
          .currentViewState
          .sessionId;
      if (NotificationDeepLink.matchesActiveSession(uri, activeSessionId)) {
        unawaited(ref.read(timerCoordinatorProvider).stop(confirmed: true));
      }
      return;
    }
    if (NotificationDeepLink.isSegmentEnd(uri)) {
      ref.read(timerCoordinatorProvider).suppressNextSegmentAlert();
    }
    final sessionId = uri.queryParameters['sessionId'];
    if (sessionId != null) {
      router.go(
        NotificationDeepLink.timerSessionUri(
          sessionId,
          source: uri.queryParameters['source'],
        ).toString(),
      );
    }
  }

  adapter.setDeepLinkHandler(handle);
  if (adapter is LocalNotificationAdapter) {
    final pending = adapter.consumePendingLaunchUri();
    if (pending != null) {
      handle(pending);
    }
  }
});
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/app/router.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_io.dart';
import 'package:pomodoro_app/platform/notifications/notification_deep_link.dart';
import 'package:pomodoro_app/presentation/l10n/locale_providers.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';
import 'package:pomodoro_app/presentation/splash/database_error_screen.dart';
import 'package:pomodoro_app/presentation/splash/splash_screen.dart';
import 'package:pomodoro_app/presentation/timer/timer_lifecycle_observer.dart';

class PomodoroApp extends ConsumerWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbAsync = ref.watch(appDatabaseProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: dbAsync.when(
        loading: () => MaterialApp(
          key: const ValueKey('splash'),
          debugShowCheckedModeBanner: false,
          // System locale (no hardcoded EN).
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: SplashScreen.seed),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        ),
        error: (_, _) => DatabaseErrorScreen(
          key: const ValueKey('db-error'),
          onRetry: () => ref.invalidate(appDatabaseProvider),
        ),
        data: (_) {
          ref.watch(sessionRecoveryBootstrapProvider);
          ref.watch(notificationDeepLinkBootstrapProvider);
          final router = ref.watch(routerProvider);
          final settingsAsync = ref.watch(appSettingsStreamProvider);
          final localeCode = ref.watch(localeCodeProvider);
          final themeMode = settingsAsync.maybeWhen(
            data: (settings) => switch (settings.theme) {
              AppTheme.light => ThemeMode.light,
              AppTheme.dark => ThemeMode.dark,
              AppTheme.system => ThemeMode.system,
            },
            orElse: () => ThemeMode.system,
          );
          return TimerLifecycleObserver(
            key: const ValueKey('main-app'),
            child: MaterialApp.router(
              title: 'Pomodoro',
              locale: Locale(localeCode),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              themeMode: themeMode,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: SplashScreen.seed),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: SplashScreen.seed,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              routerConfig: router,
            ),
          );
        },
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

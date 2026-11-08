import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/timer_providers.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/platform/aod/aod_adapter_stub.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter_stub.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter_stub.dart';
import 'package:pomodoro_app/platform/notifications/notification_adapter_stub.dart';
import 'package:pomodoro_app/presentation/settings/platform_settings_screen.dart';

void main() {
  testWidgets('lists supported capabilities only', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          focusAdapterProvider.overrideWithValue(StubFocusAdapter()),
          notificationAdapterProvider.overrideWithValue(
            StubNotificationAdapter(),
          ),
          aodAdapterProvider.overrideWithValue(const StubAODAdapter()),
          flashAdapterProvider.overrideWithValue(const StubFlashAdapter()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PlatformSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
    expect(find.text('Platform notes'), findsNothing);
  });
}

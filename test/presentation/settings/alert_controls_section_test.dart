import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/platform/flash/flash_adapter.dart';
import 'package:pomodoro_app/presentation/settings/alert_controls_section.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

import '../../support/test_settings_overrides.dart';

void main() {
  testWidgets('hides flash toggle when flash unsupported', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          testAppSettingsStreamOverride,
          flashCapabilitiesProvider.overrideWithValue(
            const FlashCapabilities(supported: false),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AlertControlsSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SwitchListTile), findsNWidgets(2));
  });
}

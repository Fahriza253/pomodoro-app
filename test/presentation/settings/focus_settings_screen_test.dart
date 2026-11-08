import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/platform/focus/focus_adapter.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/settings/focus_settings_screen.dart';
import 'package:pomodoro_app/presentation/settings/settings_providers.dart';

import '../../support/test_settings_overrides.dart';

void main() {
  testWidgets('shows only capability-allowed focus modes', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          testAppSettingsStreamOverride,
          focusCapabilitiesProvider.overrideWithValue(
            const FocusCapabilities(
              strictAvailable: false,
              whitelistAvailable: false,
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FocusSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RadioListTile<FocusMode>), findsOneWidget);
    expect(
      find.textContaining('degraded', findRichText: true),
      findsNothing,
    );
    expect(find.text('Manage whitelist'), findsNothing);
  });
}

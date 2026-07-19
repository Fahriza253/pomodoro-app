import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/settings/settings_screen.dart';

import '../../support/test_settings_overrides.dart';

void main() {
  testWidgets('SettingsScreen shows grouped sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [testAppSettingsStreamOverride],
        child: MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Setelan'), findsOneWidget);
    expect(find.text('FOCUS'), findsOneWidget);
    expect(find.text('Mode focus'), findsOneWidget);
  });
}

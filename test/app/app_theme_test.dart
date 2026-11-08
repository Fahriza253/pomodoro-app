import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/theme/app_theme.dart';
import 'package:pomodoro_app/app/theme/material_theme.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';

void main() {
  test('light and dark themes use MaterialTheme color schemes', () {
    expect(
      AppThemeData.light().colorScheme.primary,
      MaterialTheme.lightScheme().primary,
    );
    expect(
      AppThemeData.dark().colorScheme.primary,
      MaterialTheme.darkScheme().primary,
    );
  });

  group('Inter typography', () {
    test('light and dark share Inter-backed body styles', () {
      final lightBody = AppThemeData.light().textTheme.bodyMedium;
      final darkBody = AppThemeData.dark().textTheme.bodyMedium;
      expect(lightBody?.fontFamily, isNotNull);
      expect(lightBody?.fontFamily, darkBody?.fontFamily);
    });

    test('displaySmall uses weight 600 and tabular figures for timer', () {
      final displaySmall = AppThemeData.light().textTheme.displaySmall;
      expect(displaySmall?.fontWeight, FontWeight.w600);
      expect(
        displaySmall?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(
        AppThemeData.dark().textTheme.displaySmall?.fontFeatures,
        displaySmall?.fontFeatures,
      );
    });
  });

  testWidgets('EN and ID locales use the same theme typography', (tester) async {
    final light = AppThemeData.light();

    Future<String?> bodyFamily(Locale locale) async {
      late final String? family;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: light,
          home: Builder(
            builder: (context) {
              family = Theme.of(context).textTheme.bodyMedium?.fontFamily;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return family;
    }

    final enFamily = await bodyFamily(const Locale('en'));
    final idFamily = await bodyFamily(const Locale('id'));
    expect(enFamily, idFamily);
  });
}

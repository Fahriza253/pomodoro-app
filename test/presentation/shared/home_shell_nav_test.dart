import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/l10n/app_localizations_en.dart';
import 'package:pomodoro_app/presentation/shared/home_shell_nav.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('PresentationPhosphor icons use packaged font families', () {
    expect(PresentationPhosphorIcons.tag.fontFamily, 'PhosphorRegular');
    expect(
      PresentationPhosphorIcons.pause(filled: true).fontFamily,
      'PhosphorFill',
    );
  });

  test('Phosphor regular/fill pairs use packaged font families', () {
    expect(
      HomeShellPhosphorIcons.timer(selected: false).fontFamily,
      'PhosphorRegular',
    );
    expect(HomeShellPhosphorIcons.timer(selected: true).fontFamily, 'PhosphorFill');
    expect(HomeShellPhosphorIcons.clock(selected: false).fontPackage, 'phosphor_flutter');
  });

  testWidgets('uses Phosphor icons for all tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            destinations: homeShellNavigationDestinations(
              hasActiveSession: false,
              l10n: l10n,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Icon), findsNWidgets(4));
    expect(find.byIcon(Icons.timer_outlined), findsNothing);
    expect(find.byIcon(Icons.settings_outlined), findsNothing);
  });

  testWidgets('shows active-session badge on Timer when requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            destinations: homeShellNavigationDestinations(
              hasActiveSession: true,
              l10n: l10n,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Badge), findsOneWidget);
    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isTrue);
  });

  testWidgets('glyph hit target is at least 48 logical px', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: homeShellNavGlyph(
            HomeShellPhosphorIcons.timer(selected: false),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(SizedBox).first);
    expect(size.width, 48);
    expect(size.height, 48);
  });
}

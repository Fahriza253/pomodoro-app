import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/l10n/app_localizations_en.dart';
import 'package:pomodoro_app/presentation/shared/home_shell_nav.dart';
import 'package:pomodoro_app/presentation/shared/home_shell_navigation_bar_theme.dart';
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
    expect(
      HomeShellPhosphorIcons.clockCounterClockwise(selected: false).fontPackage,
      'phosphor_flutter',
    );
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

    final destinations = homeShellNavigationDestinations(
      hasActiveSession: false,
      l10n: l10n,
    );
    for (final destination in destinations) {
      expect(destination.tooltip, '');
    }

    expect(find.byType(Icon), findsNWidgets(4));
    expect(
      find.byIcon(HomeShellPhosphorIcons.clockCounterClockwise(selected: false)),
      findsOneWidget,
    );
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

  testWidgets('glyph is 24 px tall with 48 px width', (tester) async {
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
    expect(size.height, 24);
  });

  testWidgets('keeps 10 px between nav icon and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          navigationBarTheme: homeShellNavigationBarTheme(),
        ),
        home: Scaffold(
          bottomNavigationBar: Theme(
            data: homeShellNavigationBarWrapperTheme(ThemeData()),
            child: NavigationBar(
              destinations: homeShellNavigationDestinations(
                hasActiveSession: false,
                l10n: l10n,
              ),
            ),
          ),
        ),
      ),
    );

    final icon = tester.getRect(
      find.byIcon(HomeShellPhosphorIcons.timer(selected: true)),
    );
    final label = tester.getRect(find.text(l10n.navTimer));
    expect(label.top - icon.bottom, closeTo(kHomeShellNavIconLabelGap, 0.5));
  });
}

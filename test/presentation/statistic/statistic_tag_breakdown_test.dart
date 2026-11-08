import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/theme/app_theme.dart';
import 'package:pomodoro_app/app/theme/chart_series_colors.dart';
import 'package:pomodoro_app/domain/statistic/statistic_summary.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/statistic/widgets/statistic_widgets.dart';

void main() {
  testWidgets('tag breakdown uses theme series color, not TagColorDot', (
    tester,
  ) async {
    const summary = StatisticSummary(
      sessionCount: 2,
      focusDurationSec: 300,
      breakDurationSec: 0,
      totalDurationSec: 300,
      byTag: [
        TagBreakdown(
          tagId: 'a',
          tagName: 'Alpha',
          sessionCount: 1,
          focusDurationSec: 200,
          breakDurationSec: 0,
        ),
        TagBreakdown(
          tagId: 'b',
          tagName: 'Beta',
          sessionCount: 1,
          focusDurationSec: 100,
          breakDurationSec: 0,
        ),
      ],
    );

    final theme = AppThemeData.light();
    final expected = chartSeriesColorForIndex(theme.colorScheme, 0);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatisticTagBreakdown(summary: summary),
        ),
      ),
    );

    expect(find.text('Alpha'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).first,
    );
    expect(bar.color, expected);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/timeline/timeline_models.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/timeline/widgets/timeline_entry_card.dart';

void main() {
  testWidgets('entry card shows tag name without color swatch', (tester) async {
    const entry = TimelineEntry(
      sessionId: 's1',
      tagId: 't1',
      tagDisplayName: 'Deep Work',
      mode: TimerMode.pomodoro,
      status: SessionStatus.completed,
      totalActiveSec: 1500,
      focusDurationSec: 1500,
      startedAtUtcMs: 1_700_000_000_000,
      endedAtUtcMs: 1_700_000_901_000,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TimelineEntryCard(
            entry: entry,
            timeFormat: TimeFormat.h24,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Deep Work'), findsOneWidget);
  });
}

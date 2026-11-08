import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/tag/tag_list_screen.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';

void main() {
  testWidgets('tag list shows name only without color swatch', (tester) async {
    final tags = [
      Tag(
        id: 'a',
        name: 'Deep Work',
        sortOrder: 0,
        createdAtUtcMs: 1,
        updatedAtUtcMs: 1,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tagListProvider.overrideWith((ref) => Stream.value(tags)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TagListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsNothing);
  });
}

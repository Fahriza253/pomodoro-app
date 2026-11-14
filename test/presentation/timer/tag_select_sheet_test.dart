import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/l10n/app_localizations.dart';
import 'package:pomodoro_app/presentation/shared/phosphor_icon_data.dart';
import 'package:pomodoro_app/presentation/tag/tag_providers.dart';
import 'package:pomodoro_app/presentation/timer/widgets/tag_picker_field.dart';
import 'package:pomodoro_app/presentation/timer/widgets/tag_select_sheet.dart';

void main() {
  group('tagSelectPanelProgressFromDrag', () {
    test('downward drag reduces progress', () {
      expect(
        tagSelectPanelProgressFromDrag(
          current: 1,
          deltaDy: 52,
          sheetHeight: 520,
        ),
        closeTo(0.9, 0.001),
      );
    });

    test('clamps to 0 and 1', () {
      expect(
        tagSelectPanelProgressFromDrag(
          current: 0.1,
          deltaDy: 400,
          sheetHeight: 200,
        ),
        0,
      );
      expect(
        tagSelectPanelProgressFromDrag(
          current: 0.9,
          deltaDy: -400,
          sheetHeight: 200,
        ),
        1,
      );
    });
  });

  group('tagSelectPanelSnapDuration', () {
    test('scales with travel and stays in 120-240ms', () {
      expect(
        tagSelectPanelSnapDuration(0, 1),
        const Duration(milliseconds: 240),
      );
      expect(
        tagSelectPanelSnapDuration(0.9, 1),
        const Duration(milliseconds: 120),
      );
    });
  });

  testWidgets('select a tag sheet hosts mode tabs and manage tags', (
    tester,
  ) async {
    final tags = [
      Tag(
        id: 'a',
        name: 'Deep Work',
        sortOrder: 0,
        createdAtUtcMs: 1,
        updatedAtUtcMs: 1,
      ),
      Tag(
        id: 'b',
        name: 'General',
        sortOrder: 1,
        createdAtUtcMs: 1,
        updatedAtUtcMs: 1,
      ),
    ];

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: TagPickerField(enabled: true)),
        ),
        GoRoute(
          path: '/tags',
          builder: (context, state) =>
              const Scaffold(body: Text('manage-tags-page')),
        ),
        GoRoute(
          path: '/tags/:id',
          builder: (context, state) =>
              Scaffold(body: Text('edit-${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timerTagListProvider.overrideWith((ref) => Stream.value(tags)),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Flexible'), findsNothing);

    await tester.tap(find.byType(TagPickerField));
    await tester.pumpAndSettle();

    expect(find.text('Select a tag'), findsOneWidget);
    expect(find.text('Pomodoro'), findsWidgets);
    expect(find.text('Flexible'), findsOneWidget);
    expect(find.text('Manage tags'), findsOneWidget);
    expect(find.text('Deep Work'), findsWidgets);

    await tester.drag(find.text('Deep Work').last, const Offset(-120, 0));
    await tester.pumpAndSettle();

    expect(find.byIcon(PresentationPhosphorIcons.pencilSimple), findsWidgets);
    expect(find.byIcon(PresentationPhosphorIcons.trashSimple), findsOneWidget);

    await tester.tap(find.byIcon(PresentationPhosphorIcons.pencilSimple).first);
    await tester.pumpAndSettle();

    expect(find.text('edit-a'), findsOneWidget);
  });
}

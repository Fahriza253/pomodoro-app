import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/app.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/application/tag/tag_use_cases.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';

import '../../support/test_settings_overrides.dart';

const _validPomodoro = TagModeConfigPomodoro(
  focusDurationSec: 25 * 60,
  shortBreakDurationSec: 5 * 60,
  longBreakDurationSec: 10 * 60,
  sessionsBeforeLongBreak: 4,
  totalCycles: 4,
);

void main() {
  testWidgets('timer idle shows mode selector and start button', (
    tester,
  ) async {
    final db = openAppDatabase(inMemory: true);
    addTearDown(db.close);
    await DatabaseSeeder(db).seedIfNeeded();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => db),
          testAppSettingsStreamOverride,
          testTagListOverride,
          testTimerTagListOverride,
        ],
        child: const PomodoroApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pomodoro'), findsOneWidget);
    expect(find.text('Flexible'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.textContaining('General'), findsOneWidget);
  });

  testWidgets(
    'idle Pomodoro preview updates after selected Tag config is persisted',
    (tester) async {
      final db = await _pumpIdleTimer(tester);

      expect(find.text('25:00'), findsOneWidget);

      await _persistSelectedTagConfig(
        db,
        pomodoro: const TagModeConfigPomodoro(
          focusDurationSec: 50 * 60,
          shortBreakDurationSec: 5 * 60,
          longBreakDurationSec: 10 * 60,
          sessionsBeforeLongBreak: 4,
          totalCycles: 4,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('50:00'), findsOneWidget);
      expect(find.text('25:00'), findsNothing);

      await _flushDriftWatches(tester);
    },
  );

  testWidgets(
    'idle Flexible Reminder copy updates after selected Tag config is persisted',
    (tester) async {
      final db = await _pumpIdleTimer(tester);

      await tester.tap(find.text('Flexible'));
      await tester.pumpAndSettle();

      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('Reminder: every 25 minutes'), findsOneWidget);

      await _persistSelectedTagConfig(
        db,
        flexible: const TagModeConfigFlexible(
          reminderEnabled: true,
          reminderIntervalMin: 40,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('Reminder: every 40 minutes'), findsOneWidget);
      expect(find.text('Reminder: every 25 minutes'), findsNothing);

      await _persistSelectedTagConfig(
        db,
        flexible: const TagModeConfigFlexible(
          reminderEnabled: false,
          reminderIntervalMin: 40,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('Reminder: every 40 minutes'), findsNothing);

      await _flushDriftWatches(tester);
    },
  );

  testWidgets('Pomodoro pre-start shows countdown and skip launches session', (
    tester,
  ) async {
    await _pumpIdleTimer(tester);

    await tester.tap(find.text('START'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('3'), findsOneWidget);
    expect(find.text('START'), findsNothing);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('START'), findsNothing);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.text('3'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await _flushDriftWatches(tester);
  });

  testWidgets('recovery offer shows dialog without idle start actions', (
    tester,
  ) async {
    final db = openAppDatabase(inMemory: true);
    addTearDown(db.close);
    await DatabaseSeeder(db).seedIfNeeded();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => db),
          testAppSettingsStreamOverride,
        ],
        child: const PomodoroApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flexible'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('START'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
    await _flushDriftWatches(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => db),
          testAppSettingsStreamOverride,
        ],
        child: const PomodoroApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Resume previous session?'), findsOneWidget);
    expect(find.text('START'), findsNothing);

    await tester.tap(find.text('Discard'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Resume previous session?'), findsNothing);
    expect(find.text('START'), findsOneWidget);

    await _flushDriftWatches(tester);
  });
}

Future<AppDatabase> _pumpIdleTimer(WidgetTester tester) async {
  final db = openAppDatabase(inMemory: true);
  addTearDown(db.close);
  await DatabaseSeeder(db).seedIfNeeded();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => db),
        testAppSettingsStreamOverride,
      ],
      child: const PomodoroApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

/// Drift query streams schedule a zero-length timer on cancel.
Future<void> _flushDriftWatches(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(Duration.zero);
}

Future<void> _persistSelectedTagConfig(
  AppDatabase db, {
  TagModeConfigPomodoro? pomodoro,
  TagModeConfigFlexible? flexible,
}) async {
  final tags = DriftTagRepository(db);
  final useCases = TagUseCases(
    tagRepository: tags,
    sessionRepository: DriftSessionRepository(db),
  );
  final tag = (await tags.listActiveOrdered()).single;
  final result = await useCases.updateTag(
    UpdateTagInput(
      id: tag.id,
      name: tag.name,
      color: tag.color,
      pomodoro: pomodoro ?? _validPomodoro,
      flexible: flexible ?? TagModeConfigFlexible.defaults(),
    ),
  );
  expect(result.error, isNull);
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/app/app.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/presentation/splash/splash_screen.dart';

import '../../support/test_settings_overrides.dart';

void main() {
  testWidgets('splash shows only the Pomodoro wordmark', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('Pomodoro'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('reduced motion completes the splash sequence immediately', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(onSequenceComplete: () => completed = true),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(completed, isTrue);
  });

  test('splash sequence duration is 2000ms per design', () {
    expect(SplashScreen.sequenceDuration, const Duration(milliseconds: 2000));
  });

  testWidgets('motion sequence completes after 2000ms', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(onSequenceComplete: () => completed = true),
      ),
    );
    await tester.pump();
    expect(completed, isFalse);

    await tester.pump(const Duration(milliseconds: 1999));
    expect(completed, isFalse);

    await tester.pump(const Duration(milliseconds: 2));
    await tester.pump();
    expect(completed, isTrue);
  });

  testWidgets(
    'app stays on splash until the sequence finishes when DB is ready',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures();
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

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
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('START'), findsOneWidget);
    },
  );

  testWidgets('app stays on splash until DB is ready after the sequence', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final db = openAppDatabase(inMemory: true);
    addTearDown(db.close);
    await DatabaseSeeder(db).seedIfNeeded();
    final opened = Completer<AppDatabase>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) => opened.future),
          testAppSettingsStreamOverride,
          testTagListOverride,
          testTimerTagListOverride,
        ],
        child: const PomodoroApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('START'), findsNothing);

    opened.complete(db);
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('holds the wordmark until destinationReady then completes', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures();
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    var completed = false;
    const splashKey = Key('splash');
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          key: splashKey,
          destinationReady: false,
          onSequenceComplete: () => completed = true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));
    expect(completed, isFalse);
    expect(find.text('Pomodoro'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          key: splashKey,
          destinationReady: true,
          onSequenceComplete: () => completed = true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2000));
    expect(completed, isTrue);
  });
}

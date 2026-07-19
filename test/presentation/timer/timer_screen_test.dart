import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/app.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_settings_overrides.dart';

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
}

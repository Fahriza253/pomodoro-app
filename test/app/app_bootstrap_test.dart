import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app/app_bootstrap.dart';
import 'package:pomodoro_app/app/providers.dart';
import 'package:pomodoro_app/application/bootstrap/bootstrap_gate.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bootstrapPhaseProvider', () {
    test('starts on splash', () {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith(
            (ref) => Completer<AppDatabase>().future,
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(bootstrapPhaseProvider), BootstrapPhase.splash);
    });

    test('becomes ready when DB and beat complete', () async {
      final db = openAppDatabase(inMemory: true);
      addTearDown(db.close);
      await DatabaseSeeder(db).seedIfNeeded();

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWith((ref) async => db)],
      );
      addTearDown(container.dispose);

      await container.read(appDatabaseProvider.future);
      container.read(marketingBeatCompleteProvider.notifier).state = true;

      expect(container.read(bootstrapPhaseProvider), BootstrapPhase.ready);
      expect(container.read(bootstrapReadyProvider), isTrue);
    });
  });
}
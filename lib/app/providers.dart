import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/data/repositories/active_timer_state_repository.dart';
import 'package:pomodoro_app/data/repositories/session_repository.dart';
import 'package:pomodoro_app/data/repositories/settings_repository.dart';
import 'package:pomodoro_app/data/repositories/tag_repository.dart';
import 'package:pomodoro_app/domain/tag/system_tags.dart';

/// Lazily opens DB, runs migrations, and seeds on first access.
///
/// Errors surface as [AsyncError] → friendly retry UI in the app shell.
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = openAppDatabase();
  ref.onDispose(db.close);
  await DatabaseSeeder(db).seedIfNeeded();
  // QA-only: `--dart-define=DEBUG_SHORT_TAG=true` upserts reserved Debug 5s Tag.
  await DriftTagRepository(db).ensureDebugShortTag();
  return db;
});

final databaseSeededProvider = FutureProvider<bool>((ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  final tags = await db.select(db.tags).get();
  return tags.any((t) => t.name == SystemTags.generalName);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return DriftSessionRepository(db);
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return DriftTagRepository(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return DriftSettingsRepository(db);
});

final activeTimerStateRepositoryProvider = Provider<ActiveTimerStateRepository>(
  (ref) {
    final db = ref.watch(appDatabaseProvider).requireValue;
    return DriftActiveTimerStateRepository(db);
  },
);

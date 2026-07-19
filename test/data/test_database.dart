import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';

Future<AppDatabase> openTestDatabase() async {
  final db = openAppDatabase(inMemory: true);
  await DatabaseSeeder(db).seedIfNeeded();
  return db;
}

Future<String> generalTagId(AppDatabase db) async {
  final tag = await (db.select(
    db.tags,
  )..where((t) => t.name.equals(DatabaseSeeder.generalTagName))).getSingle();
  return tag.id;
}

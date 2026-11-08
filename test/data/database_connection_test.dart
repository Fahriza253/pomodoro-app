import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/data/database/database_connection.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';

void main() {
  test('openAppDatabase(inMemory) opens and seeds on the VM runner', () async {
    final db = openAppDatabase(inMemory: true);
    addTearDown(db.close);

    await DatabaseSeeder(db).seedIfNeeded();
    final tags = await db.select(db.tags).get();
    expect(tags, isNotEmpty);
  });

  test(
    'public connection entry does not import native SQLite; IO/web are split',
    () {
      final entry = File('lib/data/database/database_connection.dart')
          .readAsStringSync();
      expect(entry.contains("package:drift/native.dart"), isFalse);
      expect(entry.contains('dart.library.ffi'), isTrue);
      expect(entry.contains('database_connection_io.dart'), isTrue);
      expect(entry.contains('database_connection_web.dart'), isTrue);

      final web = File(
        'lib/data/database/database_connection_web.dart',
      ).readAsStringSync();
      expect(web.contains("package:drift/native.dart"), isFalse);
      expect(web.contains('drift_flutter'), isTrue);
    },
  );
}

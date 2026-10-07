import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Native (mobile/desktop/VM) executor — SQLite via drift_flutter / native.
QueryExecutor connect({
  String name = 'pomodoro',
  bool inMemory = false,
  Future<String> Function()? databaseDirectory,
}) {
  if (inMemory) {
    return NativeDatabase.memory();
  }

  return driftDatabase(
    name: name,
    native: DriftNativeOptions(databaseDirectory: databaseDirectory),
  );
}

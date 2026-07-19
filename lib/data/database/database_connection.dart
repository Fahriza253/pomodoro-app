import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:pomodoro_app/data/database/app_database.dart';

/// Opens SQLite lazily on first query (ADR-003, NFR-PERF-004).
QueryExecutor connect({String name = 'pomodoro', bool inMemory = false}) {
  if (inMemory) {
    return NativeDatabase.memory();
  }

  return driftDatabase(
    name: name,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}

AppDatabase openAppDatabase({bool inMemory = false}) {
  return AppDatabase(connect(inMemory: inMemory));
}

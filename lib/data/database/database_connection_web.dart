import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Web executor — sqlite3 wasm via drift_flutter (no native SQLite imports).
QueryExecutor connect({String name = 'pomodoro', bool inMemory = false}) {
  if (inMemory) {
    // VM tests use the IO connection; web smoke uses the persisted wasm open.
    throw UnsupportedError(
      'inMemory open is for the VM test runner; use the shared web open path.',
    );
  }

  return driftDatabase(
    name: name,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}

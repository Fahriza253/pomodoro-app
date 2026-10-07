import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/database/database_connection_stub.dart'
    if (dart.library.ffi) 'package:pomodoro_app/data/database/database_connection_io.dart'
    if (dart.library.js_interop) 'package:pomodoro_app/data/database/database_connection_web.dart';

/// Opens SQLite lazily on first query (ADR-003, NFR-PERF-004).
///
/// Callers use this factory only — never choose native vs web engines.
/// [databaseDirectory] overrides the native file location (ignored on web).
AppDatabase openAppDatabase({
  bool inMemory = false,
  Future<String> Function()? databaseDirectory,
}) {
  return AppDatabase(
    connect(inMemory: inMemory, databaseDirectory: databaseDirectory),
  );
}

import 'package:drift/drift.dart';

/// Fallback when neither IO nor web libraries are available.
QueryExecutor connect({
  String name = 'pomodoro',
  bool inMemory = false,
  Future<String> Function()? databaseDirectory,
}) {
  throw UnsupportedError(
    'No database connection available on this platform '
    '(name=$name, inMemory=$inMemory).',
  );
}

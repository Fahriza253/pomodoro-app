import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/platform/storage/database_directory_io.dart';

void main() {
  test('desktop overrides the DB directory away from Documents', () {
    // Test runner host is desktop (Linux/macOS/Windows), never mobile.
    expect(Platform.isAndroid || Platform.isIOS, isFalse);
    expect(databaseDirectoryOverride(), isNotNull);
  });
}

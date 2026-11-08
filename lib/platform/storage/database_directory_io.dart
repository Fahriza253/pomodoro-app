import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Desktop stores the DB in app support (XDG data home / %APPDATA% /
/// Application Support) instead of the user's Documents folder.
///
/// Mobile keeps the drift_flutter default (app-private documents) — changing
/// it would orphan existing installs' data.
Future<String> Function()? databaseDirectoryOverride() {
  if (Platform.isAndroid || Platform.isIOS) {
    return null;
  }
  return () async => (await getApplicationSupportDirectory()).path;
}

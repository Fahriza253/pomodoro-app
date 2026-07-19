import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pomodoro_app/domain/tag/config_snapshot.dart';

class ConfigSnapshotConverter extends TypeConverter<ConfigSnapshot, String> {
  const ConfigSnapshotConverter();

  @override
  ConfigSnapshot fromSql(String fromDb) {
    return ConfigSnapshot.fromJson(
      jsonDecode(fromDb) as Map<String, dynamic>,
    );
  }

  @override
  String toSql(ConfigSnapshot value) => jsonEncode(value.toJson());
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is! List) {
      throw FormatException('Expected JSON array for whitelist_json');
    }
    return decoded.cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

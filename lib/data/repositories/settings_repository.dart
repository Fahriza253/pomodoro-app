import 'package:pomodoro_app/data/database/app_database.dart';
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/data/mappers/app_settings_mapper.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/settings/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> get();
  Future<AppSettings> update(AppSettingsPatch patch);
  Stream<AppSettings> watch();
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db, {AppSettingsMapper? mapper})
    : _mapper = mapper ?? const AppSettingsMapper();

  final AppDatabase _db;
  final AppSettingsMapper _mapper;

  @override
  Future<AppSettings> get() async {
    final row = await (_db.select(
      _db.appSettingsTable,
    )..where((t) => t.id.equals(DatabaseSeeder.settingsId))).getSingleOrNull();
    if (row == null) {
      throw const NotFoundError(
        code: 'SETTINGS_NOT_FOUND',
        message: 'Pengaturan default belum di-seed.',
      );
    }
    return _mapper.toDomain(row);
  }

  @override
  Future<AppSettings> update(AppSettingsPatch patch) async {
    try {
      return await _db.transaction(() async {
        final current = await get();
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await (_db.update(_db.appSettingsTable)
              ..where((t) => t.id.equals(DatabaseSeeder.settingsId)))
            .write(_mapper.applyPatch(current, patch, now));

        return get();
      });
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal menyimpan pengaturan.',
        cause: e,
      );
    }
  }

  @override
  Stream<AppSettings> watch() {
    return (_db.select(_db.appSettingsTable)
          ..where((t) => t.id.equals(DatabaseSeeder.settingsId)))
        .watchSingleOrNull()
        .map((row) {
          if (row == null) {
            throw const NotFoundError(
              code: 'SETTINGS_NOT_FOUND',
              message: 'Pengaturan default belum di-seed.',
            );
          }
          return _mapper.toDomain(row);
        });
  }
}

import 'package:pomodoro_app/data/database/app_database.dart' hide ActiveTimerState;
import 'package:pomodoro_app/data/database/database_seeder.dart';
import 'package:pomodoro_app/data/mappers/active_timer_state_mapper.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/timer/active_timer_state.dart';

abstract class ActiveTimerStateRepository {
  Future<ActiveTimerState?> get();
  Future<void> upsert(ActiveTimerState state);
  Future<void> delete();
}

class DriftActiveTimerStateRepository implements ActiveTimerStateRepository {
  DriftActiveTimerStateRepository(this._db, {ActiveTimerStateMapper? mapper})
      : _mapper = mapper ?? const ActiveTimerStateMapper();

  final AppDatabase _db;
  final ActiveTimerStateMapper _mapper;

  @override
  Future<ActiveTimerState?> get() async {
    final row = await (_db.select(_db.activeTimerStates)
          ..where((t) => t.id.equals(ActiveTimerStateMapper.singletonId)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _mapper.toDomain(row);
  }

  @override
  Future<void> upsert(ActiveTimerState state) async {
    try {
      await _db.into(_db.activeTimerStates).insertOnConflictUpdate(
            _mapper.toCompanion(state),
          );
    } catch (e, st) {
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal menyimpan active timer state.',
        cause: e,
        details: {'stackTrace': st.toString()},
      );
    }
  }

  @override
  Future<void> delete() async {
    await (_db.delete(_db.activeTimerStates)
          ..where((t) => t.id.equals(DatabaseSeeder.activeTimerStateId)))
        .go();
  }
}

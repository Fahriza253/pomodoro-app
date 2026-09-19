import 'package:drift/drift.dart';
import 'package:pomodoro_app/data/database/app_database.dart' as db;
import 'package:pomodoro_app/data/mappers/tag_mapper.dart';
import 'package:pomodoro_app/domain/common/app_error.dart';
import 'package:pomodoro_app/domain/common/enums.dart';
import 'package:pomodoro_app/domain/tag/debug_short_tag.dart';
import 'package:pomodoro_app/domain/tag/system_tags.dart';
import 'package:pomodoro_app/domain/tag/tag.dart';
import 'package:pomodoro_app/domain/tag/tag_inputs.dart';
import 'package:pomodoro_app/domain/tag/tag_mode_config.dart';
import 'package:uuid/uuid.dart';

abstract class TagRepository {
  Future<List<Tag>> listActiveOrdered();
  Future<Tag?> getById(String id);
  Future<Map<String, Tag>> getByIds(Iterable<String> ids);
  Future<TagWithConfigs> getWithConfigs(String id);
  Future<TagModeConfig> getConfig(String tagId, TimerMode mode);
  Future<bool> existsActiveName(String name, {String? excludeTagId});

  Future<Tag> create(CreateTagInput input);
  Future<Tag> update(UpdateTagInput input);
  Future<void> softDelete(String id);
  Future<void> reorder(List<String> tagIdsInOrder);

  /// Upserts reserved [SystemTags.debugName] when [DebugShortTag.enabled].
  Future<void> ensureDebugShortTag();

  Stream<List<Tag>> watchActiveOrdered();
}

class DriftTagRepository implements TagRepository {
  DriftTagRepository(
    db.AppDatabase database, {
    TagMapper? tagMapper,
    TagModeConfigMapper? configMapper,
    Uuid? uuid,
  }) : _db = database,
       _tagMapper = tagMapper ?? const TagMapper(),
       _configMapper = configMapper ?? const TagModeConfigMapper(),
       _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final TagMapper _tagMapper;
  final TagModeConfigMapper _configMapper;
  final Uuid _uuid;

  @override
  Future<List<Tag>> listActiveOrdered() async {
    final rows =
        await (_db.select(_db.tags)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return rows.map(_tagMapper.toDomain).toList();
  }

  @override
  Future<Tag?> getById(String id) async {
    final row = await (_db.select(
      _db.tags,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _tagMapper.toDomain(row);
  }

  @override
  Future<Map<String, Tag>> getByIds(Iterable<String> ids) async {
    final idSet = ids.toSet();
    if (idSet.isEmpty) {
      return const {};
    }
    final rows = await (_db.select(
      _db.tags,
    )..where((t) => t.id.isIn(idSet))).get();
    return {for (final row in rows) row.id: _tagMapper.toDomain(row)};
  }

  @override
  Future<TagWithConfigs> getWithConfigs(String id) async {
    final tag = await getById(id);
    if (tag == null || tag.isDeleted) {
      throw NotFoundError(
        code: 'TAG_NOT_FOUND',
        message: 'Tag tidak ditemukan.',
        details: {'tagId': id},
      );
    }

    final pomodoro = await getConfig(id, TimerMode.pomodoro);
    final flexible = await getConfig(id, TimerMode.flexible);
    return TagWithConfigs(tag: tag, pomodoro: pomodoro, flexible: flexible);
  }

  @override
  Future<TagModeConfig> getConfig(String tagId, TimerMode mode) async {
    final row =
        await (_db.select(
              _db.tagModeConfigs,
            )..where((t) => t.tagId.equals(tagId) & t.mode.equals(mode.toDb())))
            .getSingleOrNull();

    if (row == null) {
      throw NotFoundError(
        code: 'TAG_NOT_FOUND',
        message: 'Konfigurasi tag tidak ditemukan.',
        details: {'tagId': tagId, 'mode': mode.toDb()},
      );
    }
    return _configMapper.toDomain(row);
  }

  @override
  Future<bool> existsActiveName(String name, {String? excludeTagId}) async {
    final normalized = name.trim();
    final query = _db.select(_db.tags)
      ..where(
        (t) =>
            t.name.equals(normalized) &
            t.deletedAt.isNull() &
            (excludeTagId == null
                ? const Constant(true)
                : t.id.equals(excludeTagId).not()),
      );
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Future<Tag> create(CreateTagInput input) async {
    if (DebugShortTag.isReservedName(input.name)) {
      throw const ValidationError(
        code: 'TAG_NAME_RESERVED',
        message: 'Nama tag ini dilindungi.',
      );
    }
    if (await existsActiveName(input.name)) {
      throw const ValidationError(
        code: 'TAG_NAME_DUPLICATE',
        message: 'Nama tag sudah digunakan.',
      );
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final tagId = _uuid.v4();
    final pomodoroId = _uuid.v4();
    final flexibleId = _uuid.v4();
    final sortOrder = await _nextSortOrder();

    try {
      return await _db.transaction(() async {
        await _db
            .into(_db.tags)
            .insert(
              db.TagsCompanion.insert(
                id: tagId,
                name: input.name.trim(),
                color: Value(input.color),
                sortOrder: Value(sortOrder),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await _db.batch((batch) {
          batch.insertAll(_db.tagModeConfigs, [
            _pomodoroCompanion(
              id: pomodoroId,
              tagId: tagId,
              config: input.pomodoro,
              updatedAt: now,
            ),
            _flexibleCompanion(
              id: flexibleId,
              tagId: tagId,
              config: input.flexible,
              updatedAt: now,
            ),
          ]);
        });

        final created = await getById(tagId);
        if (created == null) {
          throw StorageError(
            code: 'STORAGE_WRITE_FAILED',
            message: 'Gagal membuat tag.',
          );
        }
        return created;
      });
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal membuat tag.',
        cause: e,
      );
    }
  }

  @override
  Future<Tag> update(UpdateTagInput input) async {
    final existing = await getById(input.id);
    if (existing == null || existing.isDeleted) {
      throw NotFoundError(
        code: 'TAG_NOT_FOUND',
        message: 'Tag tidak ditemukan.',
        details: {'tagId': input.id},
      );
    }
    if (existing.name == SystemTags.debugName ||
        DebugShortTag.isReservedName(input.name)) {
      throw const ValidationError(
        code: 'TAG_NAME_RESERVED',
        message: 'Nama tag ini dilindungi.',
      );
    }

    if (await existsActiveName(input.name, excludeTagId: input.id)) {
      throw const ValidationError(
        code: 'TAG_NAME_DUPLICATE',
        message: 'Nama tag sudah digunakan.',
      );
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    try {
      return await _db.transaction(() async {
        await (_db.update(_db.tags)..where((t) => t.id.equals(input.id))).write(
          db.TagsCompanion(
            name: Value(input.name.trim()),
            color: Value(input.color),
            updatedAt: Value(now),
          ),
        );

        final pomodoro = await getConfig(input.id, TimerMode.pomodoro);
        final flexible = await getConfig(input.id, TimerMode.flexible);

        await (_db.update(
          _db.tagModeConfigs,
        )..where((t) => t.id.equals(pomodoro.id))).write(
          db.TagModeConfigsCompanion(
            focusDurationSec: Value(input.pomodoro.focusDurationSec),
            shortBreakDurationSec: Value(input.pomodoro.shortBreakDurationSec),
            longBreakDurationSec: Value(input.pomodoro.longBreakDurationSec),
            sessionsBeforeLongBreak: Value(
              input.pomodoro.sessionsBeforeLongBreak,
            ),
            totalCycles: Value(input.pomodoro.totalCycles),
            autoStartBreak: Value(input.pomodoro.autoStartBreak ? 1 : 0),
            autoStartFocus: Value(input.pomodoro.autoStartFocus ? 1 : 0),
            updatedAt: Value(now),
          ),
        );

        await (_db.update(
          _db.tagModeConfigs,
        )..where((t) => t.id.equals(flexible.id))).write(
          db.TagModeConfigsCompanion(
            defaultDurationSec: Value(input.flexible.defaultDurationSec),
            reminderIntervalMin: Value(input.flexible.reminderIntervalMin),
            reminderEnabled: Value(input.flexible.reminderEnabled ? 1 : 0),
            updatedAt: Value(now),
          ),
        );

        final updated = await getById(input.id);
        if (updated == null) {
          throw StorageError(
            code: 'STORAGE_WRITE_FAILED',
            message: 'Gagal memperbarui tag.',
          );
        }
        return updated;
      });
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal memperbarui tag.',
        cause: e,
      );
    }
  }

  @override
  Future<void> softDelete(String id) async {
    final tag = await getById(id);
    if (tag == null || tag.isDeleted) {
      throw NotFoundError(
        code: 'TAG_NOT_FOUND',
        message: 'Tag tidak ditemukan.',
        details: {'tagId': id},
      );
    }
    if (tag.name == SystemTags.generalName) {
      throw const ValidationError(
        code: 'TAG_DELETE_LAST',
        message: 'Tag default tidak dapat dihapus.',
      );
    }
    if (tag.name == SystemTags.debugName) {
      throw const ValidationError(
        code: 'TAG_NAME_RESERVED',
        message: 'Tag ini dilindungi dan tidak dapat dihapus.',
      );
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
      db.TagsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  @override
  Future<void> reorder(List<String> tagIdsInOrder) async {
    if (tagIdsInOrder.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _db.transaction(() async {
      for (var i = 0; i < tagIdsInOrder.length; i++) {
        await (_db.update(
          _db.tags,
        )..where((t) => t.id.equals(tagIdsInOrder[i]))).write(
          db.TagsCompanion(sortOrder: Value(i), updatedAt: Value(now)),
        );
      }
    });
  }

  Future<int> _nextSortOrder() async {
    final rows =
        await (_db.select(_db.tags)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
              ..limit(1))
            .get();
    if (rows.isEmpty) {
      return 0;
    }
    return rows.single.sortOrder + 1;
  }

  db.TagModeConfigsCompanion _pomodoroCompanion({
    required String id,
    required String tagId,
    required TagModeConfigPomodoro config,
    required int updatedAt,
  }) {
    return db.TagModeConfigsCompanion.insert(
      id: id,
      tagId: tagId,
      mode: TimerMode.pomodoro.toDb(),
      focusDurationSec: Value(config.focusDurationSec),
      shortBreakDurationSec: Value(config.shortBreakDurationSec),
      longBreakDurationSec: Value(config.longBreakDurationSec),
      sessionsBeforeLongBreak: Value(config.sessionsBeforeLongBreak),
      totalCycles: Value(config.totalCycles),
      autoStartBreak: Value(config.autoStartBreak ? 1 : 0),
      autoStartFocus: Value(config.autoStartFocus ? 1 : 0),
      updatedAt: updatedAt,
    );
  }

  db.TagModeConfigsCompanion _flexibleCompanion({
    required String id,
    required String tagId,
    required TagModeConfigFlexible config,
    required int updatedAt,
  }) {
    return db.TagModeConfigsCompanion.insert(
      id: id,
      tagId: tagId,
      mode: TimerMode.flexible.toDb(),
      defaultDurationSec: Value(config.defaultDurationSec),
      reminderIntervalMin: Value(config.reminderIntervalMin),
      reminderEnabled: Value(config.reminderEnabled ? 1 : 0),
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> ensureDebugShortTag() async {
    if (!DebugShortTag.enabled) {
      return;
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final existing =
        await (_db.select(_db.tags)
              ..where((t) => t.name.equals(SystemTags.debugName)))
            .getSingleOrNull();

    try {
      await _db.transaction(() async {
        late final String tagId;
        if (existing == null) {
          tagId = _uuid.v4();
          final sortOrder = await _nextSortOrder();
          await _db
              .into(_db.tags)
              .insert(
                db.TagsCompanion.insert(
                  id: tagId,
                  name: SystemTags.debugName,
                  color: const Value(DebugShortTag.color),
                  sortOrder: Value(sortOrder),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
          await _db.batch((batch) {
            batch.insertAll(_db.tagModeConfigs, [
              _pomodoroCompanion(
                id: _uuid.v4(),
                tagId: tagId,
                config: DebugShortTag.pomodoroConfig,
                updatedAt: now,
              ),
              _flexibleCompanion(
                id: _uuid.v4(),
                tagId: tagId,
                config: DebugShortTag.flexibleConfig,
                updatedAt: now,
              ),
            ]);
          });
          return;
        }

        tagId = existing.id;
        await (_db.update(_db.tags)..where((t) => t.id.equals(tagId))).write(
          db.TagsCompanion(
            color: const Value(DebugShortTag.color),
            deletedAt: const Value(null),
            updatedAt: Value(now),
          ),
        );

        final pomodoro = DebugShortTag.pomodoroConfig;
        final flexible = DebugShortTag.flexibleConfig;

        final pomodoroRow =
            await (_db.select(_db.tagModeConfigs)..where(
                  (t) =>
                      t.tagId.equals(tagId) &
                      t.mode.equals(TimerMode.pomodoro.toDb()),
                ))
                .getSingleOrNull();
        if (pomodoroRow == null) {
          await _db
              .into(_db.tagModeConfigs)
              .insert(
                _pomodoroCompanion(
                  id: _uuid.v4(),
                  tagId: tagId,
                  config: pomodoro,
                  updatedAt: now,
                ),
              );
        } else {
          await (_db.update(
            _db.tagModeConfigs,
          )..where((t) => t.id.equals(pomodoroRow.id))).write(
            db.TagModeConfigsCompanion(
              focusDurationSec: Value(pomodoro.focusDurationSec),
              shortBreakDurationSec: Value(pomodoro.shortBreakDurationSec),
              longBreakDurationSec: Value(pomodoro.longBreakDurationSec),
              sessionsBeforeLongBreak: Value(pomodoro.sessionsBeforeLongBreak),
              totalCycles: Value(pomodoro.totalCycles),
              autoStartBreak: Value(pomodoro.autoStartBreak ? 1 : 0),
              autoStartFocus: Value(pomodoro.autoStartFocus ? 1 : 0),
              updatedAt: Value(now),
            ),
          );
        }

        final flexibleRow =
            await (_db.select(_db.tagModeConfigs)..where(
                  (t) =>
                      t.tagId.equals(tagId) &
                      t.mode.equals(TimerMode.flexible.toDb()),
                ))
                .getSingleOrNull();
        if (flexibleRow == null) {
          await _db
              .into(_db.tagModeConfigs)
              .insert(
                _flexibleCompanion(
                  id: _uuid.v4(),
                  tagId: tagId,
                  config: flexible,
                  updatedAt: now,
                ),
              );
        } else {
          await (_db.update(
            _db.tagModeConfigs,
          )..where((t) => t.id.equals(flexibleRow.id))).write(
            db.TagModeConfigsCompanion(
              defaultDurationSec: Value(flexible.defaultDurationSec),
              reminderIntervalMin: Value(flexible.reminderIntervalMin),
              reminderEnabled: Value(flexible.reminderEnabled ? 1 : 0),
              updatedAt: Value(now),
            ),
          );
        }
      });
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw StorageError(
        code: 'STORAGE_WRITE_FAILED',
        message: 'Gagal memastikan debug tag.',
        cause: e,
      );
    }
  }

  @override
  Stream<List<Tag>> watchActiveOrdered() {
    return (_db.select(_db.tags)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_tagMapper.toDomain).toList());
  }
}

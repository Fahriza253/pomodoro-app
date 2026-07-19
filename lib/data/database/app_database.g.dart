// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#6366F1'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    sortOrder,
    deletedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String color;
  final int sortOrder;
  final int? deletedAt;
  final int createdAt;
  final int updatedAt;
  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    int? sortOrder,
    Value<int?> deletedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, sortOrder, deletedAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<int?> deletedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<int>? deletedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<int?>? deletedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagModeConfigsTable extends TagModeConfigs
    with TableInfo<$TagModeConfigsTable, TagModeConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagModeConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focusDurationSecMeta = const VerificationMeta(
    'focusDurationSec',
  );
  @override
  late final GeneratedColumn<int> focusDurationSec = GeneratedColumn<int>(
    'focus_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shortBreakDurationSecMeta =
      const VerificationMeta('shortBreakDurationSec');
  @override
  late final GeneratedColumn<int> shortBreakDurationSec = GeneratedColumn<int>(
    'short_break_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longBreakDurationSecMeta =
      const VerificationMeta('longBreakDurationSec');
  @override
  late final GeneratedColumn<int> longBreakDurationSec = GeneratedColumn<int>(
    'long_break_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionsBeforeLongBreakMeta =
      const VerificationMeta('sessionsBeforeLongBreak');
  @override
  late final GeneratedColumn<int> sessionsBeforeLongBreak =
      GeneratedColumn<int>(
        'sessions_before_long_break',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalCyclesMeta = const VerificationMeta(
    'totalCycles',
  );
  @override
  late final GeneratedColumn<int> totalCycles = GeneratedColumn<int>(
    'total_cycles',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoStartBreakMeta = const VerificationMeta(
    'autoStartBreak',
  );
  @override
  late final GeneratedColumn<int> autoStartBreak = GeneratedColumn<int>(
    'auto_start_break',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoStartFocusMeta = const VerificationMeta(
    'autoStartFocus',
  );
  @override
  late final GeneratedColumn<int> autoStartFocus = GeneratedColumn<int>(
    'auto_start_focus',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultDurationSecMeta =
      const VerificationMeta('defaultDurationSec');
  @override
  late final GeneratedColumn<int> defaultDurationSec = GeneratedColumn<int>(
    'default_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderIntervalMinMeta =
      const VerificationMeta('reminderIntervalMin');
  @override
  late final GeneratedColumn<int> reminderIntervalMin = GeneratedColumn<int>(
    'reminder_interval_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<int> reminderEnabled = GeneratedColumn<int>(
    'reminder_enabled',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tagId,
    mode,
    focusDurationSec,
    shortBreakDurationSec,
    longBreakDurationSec,
    sessionsBeforeLongBreak,
    totalCycles,
    autoStartBreak,
    autoStartFocus,
    defaultDurationSec,
    reminderIntervalMin,
    reminderEnabled,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_mode_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagModeConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('focus_duration_sec')) {
      context.handle(
        _focusDurationSecMeta,
        focusDurationSec.isAcceptableOrUnknown(
          data['focus_duration_sec']!,
          _focusDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('short_break_duration_sec')) {
      context.handle(
        _shortBreakDurationSecMeta,
        shortBreakDurationSec.isAcceptableOrUnknown(
          data['short_break_duration_sec']!,
          _shortBreakDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('long_break_duration_sec')) {
      context.handle(
        _longBreakDurationSecMeta,
        longBreakDurationSec.isAcceptableOrUnknown(
          data['long_break_duration_sec']!,
          _longBreakDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('sessions_before_long_break')) {
      context.handle(
        _sessionsBeforeLongBreakMeta,
        sessionsBeforeLongBreak.isAcceptableOrUnknown(
          data['sessions_before_long_break']!,
          _sessionsBeforeLongBreakMeta,
        ),
      );
    }
    if (data.containsKey('total_cycles')) {
      context.handle(
        _totalCyclesMeta,
        totalCycles.isAcceptableOrUnknown(
          data['total_cycles']!,
          _totalCyclesMeta,
        ),
      );
    }
    if (data.containsKey('auto_start_break')) {
      context.handle(
        _autoStartBreakMeta,
        autoStartBreak.isAcceptableOrUnknown(
          data['auto_start_break']!,
          _autoStartBreakMeta,
        ),
      );
    }
    if (data.containsKey('auto_start_focus')) {
      context.handle(
        _autoStartFocusMeta,
        autoStartFocus.isAcceptableOrUnknown(
          data['auto_start_focus']!,
          _autoStartFocusMeta,
        ),
      );
    }
    if (data.containsKey('default_duration_sec')) {
      context.handle(
        _defaultDurationSecMeta,
        defaultDurationSec.isAcceptableOrUnknown(
          data['default_duration_sec']!,
          _defaultDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('reminder_interval_min')) {
      context.handle(
        _reminderIntervalMinMeta,
        reminderIntervalMin.isAcceptableOrUnknown(
          data['reminder_interval_min']!,
          _reminderIntervalMinMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tagId, mode},
  ];
  @override
  TagModeConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagModeConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      focusDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_duration_sec'],
      ),
      shortBreakDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}short_break_duration_sec'],
      ),
      longBreakDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}long_break_duration_sec'],
      ),
      sessionsBeforeLongBreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessions_before_long_break'],
      ),
      totalCycles: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cycles'],
      ),
      autoStartBreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_start_break'],
      ),
      autoStartFocus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_start_focus'],
      ),
      defaultDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_duration_sec'],
      ),
      reminderIntervalMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_interval_min'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_enabled'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagModeConfigsTable createAlias(String alias) {
    return $TagModeConfigsTable(attachedDatabase, alias);
  }
}

class TagModeConfig extends DataClass implements Insertable<TagModeConfig> {
  final String id;
  final String tagId;
  final String mode;
  final int? focusDurationSec;
  final int? shortBreakDurationSec;
  final int? longBreakDurationSec;
  final int? sessionsBeforeLongBreak;
  final int? totalCycles;
  final int? autoStartBreak;
  final int? autoStartFocus;
  final int? defaultDurationSec;
  final int? reminderIntervalMin;
  final int? reminderEnabled;
  final int updatedAt;
  const TagModeConfig({
    required this.id,
    required this.tagId,
    required this.mode,
    this.focusDurationSec,
    this.shortBreakDurationSec,
    this.longBreakDurationSec,
    this.sessionsBeforeLongBreak,
    this.totalCycles,
    this.autoStartBreak,
    this.autoStartFocus,
    this.defaultDurationSec,
    this.reminderIntervalMin,
    this.reminderEnabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tag_id'] = Variable<String>(tagId);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || focusDurationSec != null) {
      map['focus_duration_sec'] = Variable<int>(focusDurationSec);
    }
    if (!nullToAbsent || shortBreakDurationSec != null) {
      map['short_break_duration_sec'] = Variable<int>(shortBreakDurationSec);
    }
    if (!nullToAbsent || longBreakDurationSec != null) {
      map['long_break_duration_sec'] = Variable<int>(longBreakDurationSec);
    }
    if (!nullToAbsent || sessionsBeforeLongBreak != null) {
      map['sessions_before_long_break'] = Variable<int>(
        sessionsBeforeLongBreak,
      );
    }
    if (!nullToAbsent || totalCycles != null) {
      map['total_cycles'] = Variable<int>(totalCycles);
    }
    if (!nullToAbsent || autoStartBreak != null) {
      map['auto_start_break'] = Variable<int>(autoStartBreak);
    }
    if (!nullToAbsent || autoStartFocus != null) {
      map['auto_start_focus'] = Variable<int>(autoStartFocus);
    }
    if (!nullToAbsent || defaultDurationSec != null) {
      map['default_duration_sec'] = Variable<int>(defaultDurationSec);
    }
    if (!nullToAbsent || reminderIntervalMin != null) {
      map['reminder_interval_min'] = Variable<int>(reminderIntervalMin);
    }
    if (!nullToAbsent || reminderEnabled != null) {
      map['reminder_enabled'] = Variable<int>(reminderEnabled);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TagModeConfigsCompanion toCompanion(bool nullToAbsent) {
    return TagModeConfigsCompanion(
      id: Value(id),
      tagId: Value(tagId),
      mode: Value(mode),
      focusDurationSec: focusDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(focusDurationSec),
      shortBreakDurationSec: shortBreakDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(shortBreakDurationSec),
      longBreakDurationSec: longBreakDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(longBreakDurationSec),
      sessionsBeforeLongBreak: sessionsBeforeLongBreak == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionsBeforeLongBreak),
      totalCycles: totalCycles == null && nullToAbsent
          ? const Value.absent()
          : Value(totalCycles),
      autoStartBreak: autoStartBreak == null && nullToAbsent
          ? const Value.absent()
          : Value(autoStartBreak),
      autoStartFocus: autoStartFocus == null && nullToAbsent
          ? const Value.absent()
          : Value(autoStartFocus),
      defaultDurationSec: defaultDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultDurationSec),
      reminderIntervalMin: reminderIntervalMin == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderIntervalMin),
      reminderEnabled: reminderEnabled == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory TagModeConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagModeConfig(
      id: serializer.fromJson<String>(json['id']),
      tagId: serializer.fromJson<String>(json['tagId']),
      mode: serializer.fromJson<String>(json['mode']),
      focusDurationSec: serializer.fromJson<int?>(json['focusDurationSec']),
      shortBreakDurationSec: serializer.fromJson<int?>(
        json['shortBreakDurationSec'],
      ),
      longBreakDurationSec: serializer.fromJson<int?>(
        json['longBreakDurationSec'],
      ),
      sessionsBeforeLongBreak: serializer.fromJson<int?>(
        json['sessionsBeforeLongBreak'],
      ),
      totalCycles: serializer.fromJson<int?>(json['totalCycles']),
      autoStartBreak: serializer.fromJson<int?>(json['autoStartBreak']),
      autoStartFocus: serializer.fromJson<int?>(json['autoStartFocus']),
      defaultDurationSec: serializer.fromJson<int?>(json['defaultDurationSec']),
      reminderIntervalMin: serializer.fromJson<int?>(
        json['reminderIntervalMin'],
      ),
      reminderEnabled: serializer.fromJson<int?>(json['reminderEnabled']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tagId': serializer.toJson<String>(tagId),
      'mode': serializer.toJson<String>(mode),
      'focusDurationSec': serializer.toJson<int?>(focusDurationSec),
      'shortBreakDurationSec': serializer.toJson<int?>(shortBreakDurationSec),
      'longBreakDurationSec': serializer.toJson<int?>(longBreakDurationSec),
      'sessionsBeforeLongBreak': serializer.toJson<int?>(
        sessionsBeforeLongBreak,
      ),
      'totalCycles': serializer.toJson<int?>(totalCycles),
      'autoStartBreak': serializer.toJson<int?>(autoStartBreak),
      'autoStartFocus': serializer.toJson<int?>(autoStartFocus),
      'defaultDurationSec': serializer.toJson<int?>(defaultDurationSec),
      'reminderIntervalMin': serializer.toJson<int?>(reminderIntervalMin),
      'reminderEnabled': serializer.toJson<int?>(reminderEnabled),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TagModeConfig copyWith({
    String? id,
    String? tagId,
    String? mode,
    Value<int?> focusDurationSec = const Value.absent(),
    Value<int?> shortBreakDurationSec = const Value.absent(),
    Value<int?> longBreakDurationSec = const Value.absent(),
    Value<int?> sessionsBeforeLongBreak = const Value.absent(),
    Value<int?> totalCycles = const Value.absent(),
    Value<int?> autoStartBreak = const Value.absent(),
    Value<int?> autoStartFocus = const Value.absent(),
    Value<int?> defaultDurationSec = const Value.absent(),
    Value<int?> reminderIntervalMin = const Value.absent(),
    Value<int?> reminderEnabled = const Value.absent(),
    int? updatedAt,
  }) => TagModeConfig(
    id: id ?? this.id,
    tagId: tagId ?? this.tagId,
    mode: mode ?? this.mode,
    focusDurationSec: focusDurationSec.present
        ? focusDurationSec.value
        : this.focusDurationSec,
    shortBreakDurationSec: shortBreakDurationSec.present
        ? shortBreakDurationSec.value
        : this.shortBreakDurationSec,
    longBreakDurationSec: longBreakDurationSec.present
        ? longBreakDurationSec.value
        : this.longBreakDurationSec,
    sessionsBeforeLongBreak: sessionsBeforeLongBreak.present
        ? sessionsBeforeLongBreak.value
        : this.sessionsBeforeLongBreak,
    totalCycles: totalCycles.present ? totalCycles.value : this.totalCycles,
    autoStartBreak: autoStartBreak.present
        ? autoStartBreak.value
        : this.autoStartBreak,
    autoStartFocus: autoStartFocus.present
        ? autoStartFocus.value
        : this.autoStartFocus,
    defaultDurationSec: defaultDurationSec.present
        ? defaultDurationSec.value
        : this.defaultDurationSec,
    reminderIntervalMin: reminderIntervalMin.present
        ? reminderIntervalMin.value
        : this.reminderIntervalMin,
    reminderEnabled: reminderEnabled.present
        ? reminderEnabled.value
        : this.reminderEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TagModeConfig copyWithCompanion(TagModeConfigsCompanion data) {
    return TagModeConfig(
      id: data.id.present ? data.id.value : this.id,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      mode: data.mode.present ? data.mode.value : this.mode,
      focusDurationSec: data.focusDurationSec.present
          ? data.focusDurationSec.value
          : this.focusDurationSec,
      shortBreakDurationSec: data.shortBreakDurationSec.present
          ? data.shortBreakDurationSec.value
          : this.shortBreakDurationSec,
      longBreakDurationSec: data.longBreakDurationSec.present
          ? data.longBreakDurationSec.value
          : this.longBreakDurationSec,
      sessionsBeforeLongBreak: data.sessionsBeforeLongBreak.present
          ? data.sessionsBeforeLongBreak.value
          : this.sessionsBeforeLongBreak,
      totalCycles: data.totalCycles.present
          ? data.totalCycles.value
          : this.totalCycles,
      autoStartBreak: data.autoStartBreak.present
          ? data.autoStartBreak.value
          : this.autoStartBreak,
      autoStartFocus: data.autoStartFocus.present
          ? data.autoStartFocus.value
          : this.autoStartFocus,
      defaultDurationSec: data.defaultDurationSec.present
          ? data.defaultDurationSec.value
          : this.defaultDurationSec,
      reminderIntervalMin: data.reminderIntervalMin.present
          ? data.reminderIntervalMin.value
          : this.reminderIntervalMin,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagModeConfig(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('mode: $mode, ')
          ..write('focusDurationSec: $focusDurationSec, ')
          ..write('shortBreakDurationSec: $shortBreakDurationSec, ')
          ..write('longBreakDurationSec: $longBreakDurationSec, ')
          ..write('sessionsBeforeLongBreak: $sessionsBeforeLongBreak, ')
          ..write('totalCycles: $totalCycles, ')
          ..write('autoStartBreak: $autoStartBreak, ')
          ..write('autoStartFocus: $autoStartFocus, ')
          ..write('defaultDurationSec: $defaultDurationSec, ')
          ..write('reminderIntervalMin: $reminderIntervalMin, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tagId,
    mode,
    focusDurationSec,
    shortBreakDurationSec,
    longBreakDurationSec,
    sessionsBeforeLongBreak,
    totalCycles,
    autoStartBreak,
    autoStartFocus,
    defaultDurationSec,
    reminderIntervalMin,
    reminderEnabled,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagModeConfig &&
          other.id == this.id &&
          other.tagId == this.tagId &&
          other.mode == this.mode &&
          other.focusDurationSec == this.focusDurationSec &&
          other.shortBreakDurationSec == this.shortBreakDurationSec &&
          other.longBreakDurationSec == this.longBreakDurationSec &&
          other.sessionsBeforeLongBreak == this.sessionsBeforeLongBreak &&
          other.totalCycles == this.totalCycles &&
          other.autoStartBreak == this.autoStartBreak &&
          other.autoStartFocus == this.autoStartFocus &&
          other.defaultDurationSec == this.defaultDurationSec &&
          other.reminderIntervalMin == this.reminderIntervalMin &&
          other.reminderEnabled == this.reminderEnabled &&
          other.updatedAt == this.updatedAt);
}

class TagModeConfigsCompanion extends UpdateCompanion<TagModeConfig> {
  final Value<String> id;
  final Value<String> tagId;
  final Value<String> mode;
  final Value<int?> focusDurationSec;
  final Value<int?> shortBreakDurationSec;
  final Value<int?> longBreakDurationSec;
  final Value<int?> sessionsBeforeLongBreak;
  final Value<int?> totalCycles;
  final Value<int?> autoStartBreak;
  final Value<int?> autoStartFocus;
  final Value<int?> defaultDurationSec;
  final Value<int?> reminderIntervalMin;
  final Value<int?> reminderEnabled;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TagModeConfigsCompanion({
    this.id = const Value.absent(),
    this.tagId = const Value.absent(),
    this.mode = const Value.absent(),
    this.focusDurationSec = const Value.absent(),
    this.shortBreakDurationSec = const Value.absent(),
    this.longBreakDurationSec = const Value.absent(),
    this.sessionsBeforeLongBreak = const Value.absent(),
    this.totalCycles = const Value.absent(),
    this.autoStartBreak = const Value.absent(),
    this.autoStartFocus = const Value.absent(),
    this.defaultDurationSec = const Value.absent(),
    this.reminderIntervalMin = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagModeConfigsCompanion.insert({
    required String id,
    required String tagId,
    required String mode,
    this.focusDurationSec = const Value.absent(),
    this.shortBreakDurationSec = const Value.absent(),
    this.longBreakDurationSec = const Value.absent(),
    this.sessionsBeforeLongBreak = const Value.absent(),
    this.totalCycles = const Value.absent(),
    this.autoStartBreak = const Value.absent(),
    this.autoStartFocus = const Value.absent(),
    this.defaultDurationSec = const Value.absent(),
    this.reminderIntervalMin = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tagId = Value(tagId),
       mode = Value(mode),
       updatedAt = Value(updatedAt);
  static Insertable<TagModeConfig> custom({
    Expression<String>? id,
    Expression<String>? tagId,
    Expression<String>? mode,
    Expression<int>? focusDurationSec,
    Expression<int>? shortBreakDurationSec,
    Expression<int>? longBreakDurationSec,
    Expression<int>? sessionsBeforeLongBreak,
    Expression<int>? totalCycles,
    Expression<int>? autoStartBreak,
    Expression<int>? autoStartFocus,
    Expression<int>? defaultDurationSec,
    Expression<int>? reminderIntervalMin,
    Expression<int>? reminderEnabled,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tagId != null) 'tag_id': tagId,
      if (mode != null) 'mode': mode,
      if (focusDurationSec != null) 'focus_duration_sec': focusDurationSec,
      if (shortBreakDurationSec != null)
        'short_break_duration_sec': shortBreakDurationSec,
      if (longBreakDurationSec != null)
        'long_break_duration_sec': longBreakDurationSec,
      if (sessionsBeforeLongBreak != null)
        'sessions_before_long_break': sessionsBeforeLongBreak,
      if (totalCycles != null) 'total_cycles': totalCycles,
      if (autoStartBreak != null) 'auto_start_break': autoStartBreak,
      if (autoStartFocus != null) 'auto_start_focus': autoStartFocus,
      if (defaultDurationSec != null)
        'default_duration_sec': defaultDurationSec,
      if (reminderIntervalMin != null)
        'reminder_interval_min': reminderIntervalMin,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagModeConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? tagId,
    Value<String>? mode,
    Value<int?>? focusDurationSec,
    Value<int?>? shortBreakDurationSec,
    Value<int?>? longBreakDurationSec,
    Value<int?>? sessionsBeforeLongBreak,
    Value<int?>? totalCycles,
    Value<int?>? autoStartBreak,
    Value<int?>? autoStartFocus,
    Value<int?>? defaultDurationSec,
    Value<int?>? reminderIntervalMin,
    Value<int?>? reminderEnabled,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TagModeConfigsCompanion(
      id: id ?? this.id,
      tagId: tagId ?? this.tagId,
      mode: mode ?? this.mode,
      focusDurationSec: focusDurationSec ?? this.focusDurationSec,
      shortBreakDurationSec:
          shortBreakDurationSec ?? this.shortBreakDurationSec,
      longBreakDurationSec: longBreakDurationSec ?? this.longBreakDurationSec,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      totalCycles: totalCycles ?? this.totalCycles,
      autoStartBreak: autoStartBreak ?? this.autoStartBreak,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
      defaultDurationSec: defaultDurationSec ?? this.defaultDurationSec,
      reminderIntervalMin: reminderIntervalMin ?? this.reminderIntervalMin,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (focusDurationSec.present) {
      map['focus_duration_sec'] = Variable<int>(focusDurationSec.value);
    }
    if (shortBreakDurationSec.present) {
      map['short_break_duration_sec'] = Variable<int>(
        shortBreakDurationSec.value,
      );
    }
    if (longBreakDurationSec.present) {
      map['long_break_duration_sec'] = Variable<int>(
        longBreakDurationSec.value,
      );
    }
    if (sessionsBeforeLongBreak.present) {
      map['sessions_before_long_break'] = Variable<int>(
        sessionsBeforeLongBreak.value,
      );
    }
    if (totalCycles.present) {
      map['total_cycles'] = Variable<int>(totalCycles.value);
    }
    if (autoStartBreak.present) {
      map['auto_start_break'] = Variable<int>(autoStartBreak.value);
    }
    if (autoStartFocus.present) {
      map['auto_start_focus'] = Variable<int>(autoStartFocus.value);
    }
    if (defaultDurationSec.present) {
      map['default_duration_sec'] = Variable<int>(defaultDurationSec.value);
    }
    if (reminderIntervalMin.present) {
      map['reminder_interval_min'] = Variable<int>(reminderIntervalMin.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<int>(reminderEnabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagModeConfigsCompanion(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('mode: $mode, ')
          ..write('focusDurationSec: $focusDurationSec, ')
          ..write('shortBreakDurationSec: $shortBreakDurationSec, ')
          ..write('longBreakDurationSec: $longBreakDurationSec, ')
          ..write('sessionsBeforeLongBreak: $sessionsBeforeLongBreak, ')
          ..write('totalCycles: $totalCycles, ')
          ..write('autoStartBreak: $autoStartBreak, ')
          ..write('autoStartFocus: $autoStartFocus, ')
          ..write('defaultDurationSec: $defaultDurationSec, ')
          ..write('reminderIntervalMin: $reminderIntervalMin, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timelineDateMeta = const VerificationMeta(
    'timelineDate',
  );
  @override
  late final GeneratedColumn<String> timelineDate = GeneratedColumn<String>(
    'timeline_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalActiveSecMeta = const VerificationMeta(
    'totalActiveSec',
  );
  @override
  late final GeneratedColumn<int> totalActiveSec = GeneratedColumn<int>(
    'total_active_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPausedSecMeta = const VerificationMeta(
    'totalPausedSec',
  );
  @override
  late final GeneratedColumn<int> totalPausedSec = GeneratedColumn<int>(
    'total_paused_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ConfigSnapshot, String>
  configSnapshotJson = GeneratedColumn<String>(
    'config_snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ConfigSnapshot>($SessionsTable.$converterconfigSnapshotJson);
  static const VerificationMeta _pomodoroFocusCountMeta =
      const VerificationMeta('pomodoroFocusCount');
  @override
  late final GeneratedColumn<int> pomodoroFocusCount = GeneratedColumn<int>(
    'pomodoro_focus_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pomodoroCyclesCompletedMeta =
      const VerificationMeta('pomodoroCyclesCompleted');
  @override
  late final GeneratedColumn<int> pomodoroCyclesCompleted =
      GeneratedColumn<int>(
        'pomodoro_cycles_completed',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _pomodoroCyclesTargetMeta =
      const VerificationMeta('pomodoroCyclesTarget');
  @override
  late final GeneratedColumn<int> pomodoroCyclesTarget = GeneratedColumn<int>(
    'pomodoro_cycles_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tagId,
    mode,
    status,
    startedAt,
    endedAt,
    timelineDate,
    totalActiveSec,
    totalPausedSec,
    configSnapshotJson,
    pomodoroFocusCount,
    pomodoroCyclesCompleted,
    pomodoroCyclesTarget,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('timeline_date')) {
      context.handle(
        _timelineDateMeta,
        timelineDate.isAcceptableOrUnknown(
          data['timeline_date']!,
          _timelineDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timelineDateMeta);
    }
    if (data.containsKey('total_active_sec')) {
      context.handle(
        _totalActiveSecMeta,
        totalActiveSec.isAcceptableOrUnknown(
          data['total_active_sec']!,
          _totalActiveSecMeta,
        ),
      );
    }
    if (data.containsKey('total_paused_sec')) {
      context.handle(
        _totalPausedSecMeta,
        totalPausedSec.isAcceptableOrUnknown(
          data['total_paused_sec']!,
          _totalPausedSecMeta,
        ),
      );
    }
    if (data.containsKey('pomodoro_focus_count')) {
      context.handle(
        _pomodoroFocusCountMeta,
        pomodoroFocusCount.isAcceptableOrUnknown(
          data['pomodoro_focus_count']!,
          _pomodoroFocusCountMeta,
        ),
      );
    }
    if (data.containsKey('pomodoro_cycles_completed')) {
      context.handle(
        _pomodoroCyclesCompletedMeta,
        pomodoroCyclesCompleted.isAcceptableOrUnknown(
          data['pomodoro_cycles_completed']!,
          _pomodoroCyclesCompletedMeta,
        ),
      );
    }
    if (data.containsKey('pomodoro_cycles_target')) {
      context.handle(
        _pomodoroCyclesTargetMeta,
        pomodoroCyclesTarget.isAcceptableOrUnknown(
          data['pomodoro_cycles_target']!,
          _pomodoroCyclesTargetMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
      timelineDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timeline_date'],
      )!,
      totalActiveSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_active_sec'],
      )!,
      totalPausedSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_paused_sec'],
      )!,
      configSnapshotJson: $SessionsTable.$converterconfigSnapshotJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}config_snapshot_json'],
        )!,
      ),
      pomodoroFocusCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pomodoro_focus_count'],
      )!,
      pomodoroCyclesCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pomodoro_cycles_completed'],
      )!,
      pomodoroCyclesTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pomodoro_cycles_target'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static TypeConverter<ConfigSnapshot, String> $converterconfigSnapshotJson =
      const ConfigSnapshotConverter();
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String tagId;
  final String mode;
  final String status;
  final int startedAt;
  final int? endedAt;
  final String timelineDate;
  final int totalActiveSec;
  final int totalPausedSec;
  final ConfigSnapshot configSnapshotJson;
  final int pomodoroFocusCount;
  final int pomodoroCyclesCompleted;
  final int? pomodoroCyclesTarget;
  final int createdAt;
  final int updatedAt;
  const SessionRow({
    required this.id,
    required this.tagId,
    required this.mode,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.timelineDate,
    required this.totalActiveSec,
    required this.totalPausedSec,
    required this.configSnapshotJson,
    required this.pomodoroFocusCount,
    required this.pomodoroCyclesCompleted,
    this.pomodoroCyclesTarget,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tag_id'] = Variable<String>(tagId);
    map['mode'] = Variable<String>(mode);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['timeline_date'] = Variable<String>(timelineDate);
    map['total_active_sec'] = Variable<int>(totalActiveSec);
    map['total_paused_sec'] = Variable<int>(totalPausedSec);
    {
      map['config_snapshot_json'] = Variable<String>(
        $SessionsTable.$converterconfigSnapshotJson.toSql(configSnapshotJson),
      );
    }
    map['pomodoro_focus_count'] = Variable<int>(pomodoroFocusCount);
    map['pomodoro_cycles_completed'] = Variable<int>(pomodoroCyclesCompleted);
    if (!nullToAbsent || pomodoroCyclesTarget != null) {
      map['pomodoro_cycles_target'] = Variable<int>(pomodoroCyclesTarget);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      tagId: Value(tagId),
      mode: Value(mode),
      status: Value(status),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      timelineDate: Value(timelineDate),
      totalActiveSec: Value(totalActiveSec),
      totalPausedSec: Value(totalPausedSec),
      configSnapshotJson: Value(configSnapshotJson),
      pomodoroFocusCount: Value(pomodoroFocusCount),
      pomodoroCyclesCompleted: Value(pomodoroCyclesCompleted),
      pomodoroCyclesTarget: pomodoroCyclesTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(pomodoroCyclesTarget),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      tagId: serializer.fromJson<String>(json['tagId']),
      mode: serializer.fromJson<String>(json['mode']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      timelineDate: serializer.fromJson<String>(json['timelineDate']),
      totalActiveSec: serializer.fromJson<int>(json['totalActiveSec']),
      totalPausedSec: serializer.fromJson<int>(json['totalPausedSec']),
      configSnapshotJson: serializer.fromJson<ConfigSnapshot>(
        json['configSnapshotJson'],
      ),
      pomodoroFocusCount: serializer.fromJson<int>(json['pomodoroFocusCount']),
      pomodoroCyclesCompleted: serializer.fromJson<int>(
        json['pomodoroCyclesCompleted'],
      ),
      pomodoroCyclesTarget: serializer.fromJson<int?>(
        json['pomodoroCyclesTarget'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tagId': serializer.toJson<String>(tagId),
      'mode': serializer.toJson<String>(mode),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'timelineDate': serializer.toJson<String>(timelineDate),
      'totalActiveSec': serializer.toJson<int>(totalActiveSec),
      'totalPausedSec': serializer.toJson<int>(totalPausedSec),
      'configSnapshotJson': serializer.toJson<ConfigSnapshot>(
        configSnapshotJson,
      ),
      'pomodoroFocusCount': serializer.toJson<int>(pomodoroFocusCount),
      'pomodoroCyclesCompleted': serializer.toJson<int>(
        pomodoroCyclesCompleted,
      ),
      'pomodoroCyclesTarget': serializer.toJson<int?>(pomodoroCyclesTarget),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SessionRow copyWith({
    String? id,
    String? tagId,
    String? mode,
    String? status,
    int? startedAt,
    Value<int?> endedAt = const Value.absent(),
    String? timelineDate,
    int? totalActiveSec,
    int? totalPausedSec,
    ConfigSnapshot? configSnapshotJson,
    int? pomodoroFocusCount,
    int? pomodoroCyclesCompleted,
    Value<int?> pomodoroCyclesTarget = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => SessionRow(
    id: id ?? this.id,
    tagId: tagId ?? this.tagId,
    mode: mode ?? this.mode,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    timelineDate: timelineDate ?? this.timelineDate,
    totalActiveSec: totalActiveSec ?? this.totalActiveSec,
    totalPausedSec: totalPausedSec ?? this.totalPausedSec,
    configSnapshotJson: configSnapshotJson ?? this.configSnapshotJson,
    pomodoroFocusCount: pomodoroFocusCount ?? this.pomodoroFocusCount,
    pomodoroCyclesCompleted:
        pomodoroCyclesCompleted ?? this.pomodoroCyclesCompleted,
    pomodoroCyclesTarget: pomodoroCyclesTarget.present
        ? pomodoroCyclesTarget.value
        : this.pomodoroCyclesTarget,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      mode: data.mode.present ? data.mode.value : this.mode,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      timelineDate: data.timelineDate.present
          ? data.timelineDate.value
          : this.timelineDate,
      totalActiveSec: data.totalActiveSec.present
          ? data.totalActiveSec.value
          : this.totalActiveSec,
      totalPausedSec: data.totalPausedSec.present
          ? data.totalPausedSec.value
          : this.totalPausedSec,
      configSnapshotJson: data.configSnapshotJson.present
          ? data.configSnapshotJson.value
          : this.configSnapshotJson,
      pomodoroFocusCount: data.pomodoroFocusCount.present
          ? data.pomodoroFocusCount.value
          : this.pomodoroFocusCount,
      pomodoroCyclesCompleted: data.pomodoroCyclesCompleted.present
          ? data.pomodoroCyclesCompleted.value
          : this.pomodoroCyclesCompleted,
      pomodoroCyclesTarget: data.pomodoroCyclesTarget.present
          ? data.pomodoroCyclesTarget.value
          : this.pomodoroCyclesTarget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('timelineDate: $timelineDate, ')
          ..write('totalActiveSec: $totalActiveSec, ')
          ..write('totalPausedSec: $totalPausedSec, ')
          ..write('configSnapshotJson: $configSnapshotJson, ')
          ..write('pomodoroFocusCount: $pomodoroFocusCount, ')
          ..write('pomodoroCyclesCompleted: $pomodoroCyclesCompleted, ')
          ..write('pomodoroCyclesTarget: $pomodoroCyclesTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tagId,
    mode,
    status,
    startedAt,
    endedAt,
    timelineDate,
    totalActiveSec,
    totalPausedSec,
    configSnapshotJson,
    pomodoroFocusCount,
    pomodoroCyclesCompleted,
    pomodoroCyclesTarget,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.tagId == this.tagId &&
          other.mode == this.mode &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.timelineDate == this.timelineDate &&
          other.totalActiveSec == this.totalActiveSec &&
          other.totalPausedSec == this.totalPausedSec &&
          other.configSnapshotJson == this.configSnapshotJson &&
          other.pomodoroFocusCount == this.pomodoroFocusCount &&
          other.pomodoroCyclesCompleted == this.pomodoroCyclesCompleted &&
          other.pomodoroCyclesTarget == this.pomodoroCyclesTarget &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> tagId;
  final Value<String> mode;
  final Value<String> status;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<String> timelineDate;
  final Value<int> totalActiveSec;
  final Value<int> totalPausedSec;
  final Value<ConfigSnapshot> configSnapshotJson;
  final Value<int> pomodoroFocusCount;
  final Value<int> pomodoroCyclesCompleted;
  final Value<int?> pomodoroCyclesTarget;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.tagId = const Value.absent(),
    this.mode = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.timelineDate = const Value.absent(),
    this.totalActiveSec = const Value.absent(),
    this.totalPausedSec = const Value.absent(),
    this.configSnapshotJson = const Value.absent(),
    this.pomodoroFocusCount = const Value.absent(),
    this.pomodoroCyclesCompleted = const Value.absent(),
    this.pomodoroCyclesTarget = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String tagId,
    required String mode,
    this.status = const Value.absent(),
    required int startedAt,
    this.endedAt = const Value.absent(),
    required String timelineDate,
    this.totalActiveSec = const Value.absent(),
    this.totalPausedSec = const Value.absent(),
    required ConfigSnapshot configSnapshotJson,
    this.pomodoroFocusCount = const Value.absent(),
    this.pomodoroCyclesCompleted = const Value.absent(),
    this.pomodoroCyclesTarget = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tagId = Value(tagId),
       mode = Value(mode),
       startedAt = Value(startedAt),
       timelineDate = Value(timelineDate),
       configSnapshotJson = Value(configSnapshotJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? tagId,
    Expression<String>? mode,
    Expression<String>? status,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<String>? timelineDate,
    Expression<int>? totalActiveSec,
    Expression<int>? totalPausedSec,
    Expression<String>? configSnapshotJson,
    Expression<int>? pomodoroFocusCount,
    Expression<int>? pomodoroCyclesCompleted,
    Expression<int>? pomodoroCyclesTarget,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tagId != null) 'tag_id': tagId,
      if (mode != null) 'mode': mode,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (timelineDate != null) 'timeline_date': timelineDate,
      if (totalActiveSec != null) 'total_active_sec': totalActiveSec,
      if (totalPausedSec != null) 'total_paused_sec': totalPausedSec,
      if (configSnapshotJson != null)
        'config_snapshot_json': configSnapshotJson,
      if (pomodoroFocusCount != null)
        'pomodoro_focus_count': pomodoroFocusCount,
      if (pomodoroCyclesCompleted != null)
        'pomodoro_cycles_completed': pomodoroCyclesCompleted,
      if (pomodoroCyclesTarget != null)
        'pomodoro_cycles_target': pomodoroCyclesTarget,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? tagId,
    Value<String>? mode,
    Value<String>? status,
    Value<int>? startedAt,
    Value<int?>? endedAt,
    Value<String>? timelineDate,
    Value<int>? totalActiveSec,
    Value<int>? totalPausedSec,
    Value<ConfigSnapshot>? configSnapshotJson,
    Value<int>? pomodoroFocusCount,
    Value<int>? pomodoroCyclesCompleted,
    Value<int?>? pomodoroCyclesTarget,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      tagId: tagId ?? this.tagId,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      timelineDate: timelineDate ?? this.timelineDate,
      totalActiveSec: totalActiveSec ?? this.totalActiveSec,
      totalPausedSec: totalPausedSec ?? this.totalPausedSec,
      configSnapshotJson: configSnapshotJson ?? this.configSnapshotJson,
      pomodoroFocusCount: pomodoroFocusCount ?? this.pomodoroFocusCount,
      pomodoroCyclesCompleted:
          pomodoroCyclesCompleted ?? this.pomodoroCyclesCompleted,
      pomodoroCyclesTarget: pomodoroCyclesTarget ?? this.pomodoroCyclesTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (timelineDate.present) {
      map['timeline_date'] = Variable<String>(timelineDate.value);
    }
    if (totalActiveSec.present) {
      map['total_active_sec'] = Variable<int>(totalActiveSec.value);
    }
    if (totalPausedSec.present) {
      map['total_paused_sec'] = Variable<int>(totalPausedSec.value);
    }
    if (configSnapshotJson.present) {
      map['config_snapshot_json'] = Variable<String>(
        $SessionsTable.$converterconfigSnapshotJson.toSql(
          configSnapshotJson.value,
        ),
      );
    }
    if (pomodoroFocusCount.present) {
      map['pomodoro_focus_count'] = Variable<int>(pomodoroFocusCount.value);
    }
    if (pomodoroCyclesCompleted.present) {
      map['pomodoro_cycles_completed'] = Variable<int>(
        pomodoroCyclesCompleted.value,
      );
    }
    if (pomodoroCyclesTarget.present) {
      map['pomodoro_cycles_target'] = Variable<int>(pomodoroCyclesTarget.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('timelineDate: $timelineDate, ')
          ..write('totalActiveSec: $totalActiveSec, ')
          ..write('totalPausedSec: $totalPausedSec, ')
          ..write('configSnapshotJson: $configSnapshotJson, ')
          ..write('pomodoroFocusCount: $pomodoroFocusCount, ')
          ..write('pomodoroCyclesCompleted: $pomodoroCyclesCompleted, ')
          ..write('pomodoroCyclesTarget: $pomodoroCyclesTarget, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionSegmentsTable extends SessionSegments
    with TableInfo<$SessionSegmentsTable, SessionSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _plannedSecMeta = const VerificationMeta(
    'plannedSec',
  );
  @override
  late final GeneratedColumn<int> plannedSec = GeneratedColumn<int>(
    'planned_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualSecMeta = const VerificationMeta(
    'actualSec',
  );
  @override
  late final GeneratedColumn<int> actualSec = GeneratedColumn<int>(
    'actual_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _segmentPausedSecMeta = const VerificationMeta(
    'segmentPausedSec',
  );
  @override
  late final GeneratedColumn<int> segmentPausedSec = GeneratedColumn<int>(
    'segment_paused_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _segmentStatusMeta = const VerificationMeta(
    'segmentStatus',
  );
  @override
  late final GeneratedColumn<String> segmentStatus = GeneratedColumn<String>(
    'segment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    type,
    orderIndex,
    plannedSec,
    actualSec,
    segmentPausedSec,
    segmentStatus,
    startedAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('planned_sec')) {
      context.handle(
        _plannedSecMeta,
        plannedSec.isAcceptableOrUnknown(data['planned_sec']!, _plannedSecMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedSecMeta);
    }
    if (data.containsKey('actual_sec')) {
      context.handle(
        _actualSecMeta,
        actualSec.isAcceptableOrUnknown(data['actual_sec']!, _actualSecMeta),
      );
    }
    if (data.containsKey('segment_paused_sec')) {
      context.handle(
        _segmentPausedSecMeta,
        segmentPausedSec.isAcceptableOrUnknown(
          data['segment_paused_sec']!,
          _segmentPausedSecMeta,
        ),
      );
    }
    if (data.containsKey('segment_status')) {
      context.handle(
        _segmentStatusMeta,
        segmentStatus.isAcceptableOrUnknown(
          data['segment_status']!,
          _segmentStatusMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId, orderIndex},
  ];
  @override
  SessionSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      plannedSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_sec'],
      )!,
      actualSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_sec'],
      )!,
      segmentPausedSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_paused_sec'],
      )!,
      segmentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $SessionSegmentsTable createAlias(String alias) {
    return $SessionSegmentsTable(attachedDatabase, alias);
  }
}

class SessionSegment extends DataClass implements Insertable<SessionSegment> {
  final String id;
  final String sessionId;
  final String type;
  final int orderIndex;
  final int plannedSec;
  final int actualSec;
  final int segmentPausedSec;
  final String segmentStatus;
  final int? startedAt;
  final int? endedAt;
  const SessionSegment({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.orderIndex,
    required this.plannedSec,
    required this.actualSec,
    required this.segmentPausedSec,
    required this.segmentStatus,
    this.startedAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['type'] = Variable<String>(type);
    map['order_index'] = Variable<int>(orderIndex);
    map['planned_sec'] = Variable<int>(plannedSec);
    map['actual_sec'] = Variable<int>(actualSec);
    map['segment_paused_sec'] = Variable<int>(segmentPausedSec);
    map['segment_status'] = Variable<String>(segmentStatus);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    return map;
  }

  SessionSegmentsCompanion toCompanion(bool nullToAbsent) {
    return SessionSegmentsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      type: Value(type),
      orderIndex: Value(orderIndex),
      plannedSec: Value(plannedSec),
      actualSec: Value(actualSec),
      segmentPausedSec: Value(segmentPausedSec),
      segmentStatus: Value(segmentStatus),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory SessionSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSegment(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      plannedSec: serializer.fromJson<int>(json['plannedSec']),
      actualSec: serializer.fromJson<int>(json['actualSec']),
      segmentPausedSec: serializer.fromJson<int>(json['segmentPausedSec']),
      segmentStatus: serializer.fromJson<String>(json['segmentStatus']),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'type': serializer.toJson<String>(type),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'plannedSec': serializer.toJson<int>(plannedSec),
      'actualSec': serializer.toJson<int>(actualSec),
      'segmentPausedSec': serializer.toJson<int>(segmentPausedSec),
      'segmentStatus': serializer.toJson<String>(segmentStatus),
      'startedAt': serializer.toJson<int?>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
    };
  }

  SessionSegment copyWith({
    String? id,
    String? sessionId,
    String? type,
    int? orderIndex,
    int? plannedSec,
    int? actualSec,
    int? segmentPausedSec,
    String? segmentStatus,
    Value<int?> startedAt = const Value.absent(),
    Value<int?> endedAt = const Value.absent(),
  }) => SessionSegment(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    type: type ?? this.type,
    orderIndex: orderIndex ?? this.orderIndex,
    plannedSec: plannedSec ?? this.plannedSec,
    actualSec: actualSec ?? this.actualSec,
    segmentPausedSec: segmentPausedSec ?? this.segmentPausedSec,
    segmentStatus: segmentStatus ?? this.segmentStatus,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  SessionSegment copyWithCompanion(SessionSegmentsCompanion data) {
    return SessionSegment(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      plannedSec: data.plannedSec.present
          ? data.plannedSec.value
          : this.plannedSec,
      actualSec: data.actualSec.present ? data.actualSec.value : this.actualSec,
      segmentPausedSec: data.segmentPausedSec.present
          ? data.segmentPausedSec.value
          : this.segmentPausedSec,
      segmentStatus: data.segmentStatus.present
          ? data.segmentStatus.value
          : this.segmentStatus,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSegment(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('plannedSec: $plannedSec, ')
          ..write('actualSec: $actualSec, ')
          ..write('segmentPausedSec: $segmentPausedSec, ')
          ..write('segmentStatus: $segmentStatus, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    type,
    orderIndex,
    plannedSec,
    actualSec,
    segmentPausedSec,
    segmentStatus,
    startedAt,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSegment &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.orderIndex == this.orderIndex &&
          other.plannedSec == this.plannedSec &&
          other.actualSec == this.actualSec &&
          other.segmentPausedSec == this.segmentPausedSec &&
          other.segmentStatus == this.segmentStatus &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class SessionSegmentsCompanion extends UpdateCompanion<SessionSegment> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> type;
  final Value<int> orderIndex;
  final Value<int> plannedSec;
  final Value<int> actualSec;
  final Value<int> segmentPausedSec;
  final Value<String> segmentStatus;
  final Value<int?> startedAt;
  final Value<int?> endedAt;
  final Value<int> rowid;
  const SessionSegmentsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.plannedSec = const Value.absent(),
    this.actualSec = const Value.absent(),
    this.segmentPausedSec = const Value.absent(),
    this.segmentStatus = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionSegmentsCompanion.insert({
    required String id,
    required String sessionId,
    required String type,
    this.orderIndex = const Value.absent(),
    required int plannedSec,
    this.actualSec = const Value.absent(),
    this.segmentPausedSec = const Value.absent(),
    this.segmentStatus = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       type = Value(type),
       plannedSec = Value(plannedSec);
  static Insertable<SessionSegment> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? type,
    Expression<int>? orderIndex,
    Expression<int>? plannedSec,
    Expression<int>? actualSec,
    Expression<int>? segmentPausedSec,
    Expression<String>? segmentStatus,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (orderIndex != null) 'order_index': orderIndex,
      if (plannedSec != null) 'planned_sec': plannedSec,
      if (actualSec != null) 'actual_sec': actualSec,
      if (segmentPausedSec != null) 'segment_paused_sec': segmentPausedSec,
      if (segmentStatus != null) 'segment_status': segmentStatus,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? type,
    Value<int>? orderIndex,
    Value<int>? plannedSec,
    Value<int>? actualSec,
    Value<int>? segmentPausedSec,
    Value<String>? segmentStatus,
    Value<int?>? startedAt,
    Value<int?>? endedAt,
    Value<int>? rowid,
  }) {
    return SessionSegmentsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      orderIndex: orderIndex ?? this.orderIndex,
      plannedSec: plannedSec ?? this.plannedSec,
      actualSec: actualSec ?? this.actualSec,
      segmentPausedSec: segmentPausedSec ?? this.segmentPausedSec,
      segmentStatus: segmentStatus ?? this.segmentStatus,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (plannedSec.present) {
      map['planned_sec'] = Variable<int>(plannedSec.value);
    }
    if (actualSec.present) {
      map['actual_sec'] = Variable<int>(actualSec.value);
    }
    if (segmentPausedSec.present) {
      map['segment_paused_sec'] = Variable<int>(segmentPausedSec.value);
    }
    if (segmentStatus.present) {
      map['segment_status'] = Variable<String>(segmentStatus.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('plannedSec: $plannedSec, ')
          ..write('actualSec: $actualSec, ')
          ..write('segmentPausedSec: $segmentPausedSec, ')
          ..write('segmentStatus: $segmentStatus, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActiveTimerStatesTable extends ActiveTimerStates
    with TableInfo<$ActiveTimerStatesTable, ActiveTimerState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveTimerStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _engineStateMeta = const VerificationMeta(
    'engineState',
  );
  @override
  late final GeneratedColumn<String> engineState = GeneratedColumn<String>(
    'engine_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentSegmentIdMeta = const VerificationMeta(
    'currentSegmentId',
  );
  @override
  late final GeneratedColumn<String> currentSegmentId = GeneratedColumn<String>(
    'current_segment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES session_segments (id)',
    ),
  );
  static const VerificationMeta _segmentStartedAtMeta = const VerificationMeta(
    'segmentStartedAt',
  );
  @override
  late final GeneratedColumn<int> segmentStartedAt = GeneratedColumn<int>(
    'segment_started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flexibleReminderActiveSecMeta =
      const VerificationMeta('flexibleReminderActiveSec');
  @override
  late final GeneratedColumn<int> flexibleReminderActiveSec =
      GeneratedColumn<int>(
        'flexible_reminder_active_sec',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastPersistedAtMeta = const VerificationMeta(
    'lastPersistedAt',
  );
  @override
  late final GeneratedColumn<int> lastPersistedAt = GeneratedColumn<int>(
    'last_persisted_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pauseStartedAtMeta = const VerificationMeta(
    'pauseStartedAt',
  );
  @override
  late final GeneratedColumn<int> pauseStartedAt = GeneratedColumn<int>(
    'pause_started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frozenRemainingSecMeta =
      const VerificationMeta('frozenRemainingSec');
  @override
  late final GeneratedColumn<int> frozenRemainingSec = GeneratedColumn<int>(
    'frozen_remaining_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    engineState,
    currentSegmentId,
    segmentStartedAt,
    flexibleReminderActiveSec,
    lastPersistedAt,
    pauseStartedAt,
    frozenRemainingSec,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_timer_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveTimerState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('engine_state')) {
      context.handle(
        _engineStateMeta,
        engineState.isAcceptableOrUnknown(
          data['engine_state']!,
          _engineStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineStateMeta);
    }
    if (data.containsKey('current_segment_id')) {
      context.handle(
        _currentSegmentIdMeta,
        currentSegmentId.isAcceptableOrUnknown(
          data['current_segment_id']!,
          _currentSegmentIdMeta,
        ),
      );
    }
    if (data.containsKey('segment_started_at')) {
      context.handle(
        _segmentStartedAtMeta,
        segmentStartedAt.isAcceptableOrUnknown(
          data['segment_started_at']!,
          _segmentStartedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentStartedAtMeta);
    }
    if (data.containsKey('flexible_reminder_active_sec')) {
      context.handle(
        _flexibleReminderActiveSecMeta,
        flexibleReminderActiveSec.isAcceptableOrUnknown(
          data['flexible_reminder_active_sec']!,
          _flexibleReminderActiveSecMeta,
        ),
      );
    }
    if (data.containsKey('last_persisted_at')) {
      context.handle(
        _lastPersistedAtMeta,
        lastPersistedAt.isAcceptableOrUnknown(
          data['last_persisted_at']!,
          _lastPersistedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPersistedAtMeta);
    }
    if (data.containsKey('pause_started_at')) {
      context.handle(
        _pauseStartedAtMeta,
        pauseStartedAt.isAcceptableOrUnknown(
          data['pause_started_at']!,
          _pauseStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('frozen_remaining_sec')) {
      context.handle(
        _frozenRemainingSecMeta,
        frozenRemainingSec.isAcceptableOrUnknown(
          data['frozen_remaining_sec']!,
          _frozenRemainingSecMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActiveTimerState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveTimerState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      engineState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_state'],
      )!,
      currentSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_segment_id'],
      ),
      segmentStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_started_at'],
      )!,
      flexibleReminderActiveSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flexible_reminder_active_sec'],
      )!,
      lastPersistedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_persisted_at'],
      )!,
      pauseStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_started_at'],
      ),
      frozenRemainingSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frozen_remaining_sec'],
      ),
    );
  }

  @override
  $ActiveTimerStatesTable createAlias(String alias) {
    return $ActiveTimerStatesTable(attachedDatabase, alias);
  }
}

class ActiveTimerState extends DataClass
    implements Insertable<ActiveTimerState> {
  final String id;
  final String sessionId;
  final String engineState;
  final String? currentSegmentId;
  final int segmentStartedAt;
  final int flexibleReminderActiveSec;
  final int lastPersistedAt;

  /// Wall-clock pause start (UTC ms). Nullable — only set while paused.
  final int? pauseStartedAt;

  /// Pomodoro remaining frozen at pause. Null when not applicable.
  final int? frozenRemainingSec;
  const ActiveTimerState({
    required this.id,
    required this.sessionId,
    required this.engineState,
    this.currentSegmentId,
    required this.segmentStartedAt,
    required this.flexibleReminderActiveSec,
    required this.lastPersistedAt,
    this.pauseStartedAt,
    this.frozenRemainingSec,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['engine_state'] = Variable<String>(engineState);
    if (!nullToAbsent || currentSegmentId != null) {
      map['current_segment_id'] = Variable<String>(currentSegmentId);
    }
    map['segment_started_at'] = Variable<int>(segmentStartedAt);
    map['flexible_reminder_active_sec'] = Variable<int>(
      flexibleReminderActiveSec,
    );
    map['last_persisted_at'] = Variable<int>(lastPersistedAt);
    if (!nullToAbsent || pauseStartedAt != null) {
      map['pause_started_at'] = Variable<int>(pauseStartedAt);
    }
    if (!nullToAbsent || frozenRemainingSec != null) {
      map['frozen_remaining_sec'] = Variable<int>(frozenRemainingSec);
    }
    return map;
  }

  ActiveTimerStatesCompanion toCompanion(bool nullToAbsent) {
    return ActiveTimerStatesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      engineState: Value(engineState),
      currentSegmentId: currentSegmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentSegmentId),
      segmentStartedAt: Value(segmentStartedAt),
      flexibleReminderActiveSec: Value(flexibleReminderActiveSec),
      lastPersistedAt: Value(lastPersistedAt),
      pauseStartedAt: pauseStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseStartedAt),
      frozenRemainingSec: frozenRemainingSec == null && nullToAbsent
          ? const Value.absent()
          : Value(frozenRemainingSec),
    );
  }

  factory ActiveTimerState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveTimerState(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      engineState: serializer.fromJson<String>(json['engineState']),
      currentSegmentId: serializer.fromJson<String?>(json['currentSegmentId']),
      segmentStartedAt: serializer.fromJson<int>(json['segmentStartedAt']),
      flexibleReminderActiveSec: serializer.fromJson<int>(
        json['flexibleReminderActiveSec'],
      ),
      lastPersistedAt: serializer.fromJson<int>(json['lastPersistedAt']),
      pauseStartedAt: serializer.fromJson<int?>(json['pauseStartedAt']),
      frozenRemainingSec: serializer.fromJson<int?>(json['frozenRemainingSec']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'engineState': serializer.toJson<String>(engineState),
      'currentSegmentId': serializer.toJson<String?>(currentSegmentId),
      'segmentStartedAt': serializer.toJson<int>(segmentStartedAt),
      'flexibleReminderActiveSec': serializer.toJson<int>(
        flexibleReminderActiveSec,
      ),
      'lastPersistedAt': serializer.toJson<int>(lastPersistedAt),
      'pauseStartedAt': serializer.toJson<int?>(pauseStartedAt),
      'frozenRemainingSec': serializer.toJson<int?>(frozenRemainingSec),
    };
  }

  ActiveTimerState copyWith({
    String? id,
    String? sessionId,
    String? engineState,
    Value<String?> currentSegmentId = const Value.absent(),
    int? segmentStartedAt,
    int? flexibleReminderActiveSec,
    int? lastPersistedAt,
    Value<int?> pauseStartedAt = const Value.absent(),
    Value<int?> frozenRemainingSec = const Value.absent(),
  }) => ActiveTimerState(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    engineState: engineState ?? this.engineState,
    currentSegmentId: currentSegmentId.present
        ? currentSegmentId.value
        : this.currentSegmentId,
    segmentStartedAt: segmentStartedAt ?? this.segmentStartedAt,
    flexibleReminderActiveSec:
        flexibleReminderActiveSec ?? this.flexibleReminderActiveSec,
    lastPersistedAt: lastPersistedAt ?? this.lastPersistedAt,
    pauseStartedAt: pauseStartedAt.present
        ? pauseStartedAt.value
        : this.pauseStartedAt,
    frozenRemainingSec: frozenRemainingSec.present
        ? frozenRemainingSec.value
        : this.frozenRemainingSec,
  );
  ActiveTimerState copyWithCompanion(ActiveTimerStatesCompanion data) {
    return ActiveTimerState(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      engineState: data.engineState.present
          ? data.engineState.value
          : this.engineState,
      currentSegmentId: data.currentSegmentId.present
          ? data.currentSegmentId.value
          : this.currentSegmentId,
      segmentStartedAt: data.segmentStartedAt.present
          ? data.segmentStartedAt.value
          : this.segmentStartedAt,
      flexibleReminderActiveSec: data.flexibleReminderActiveSec.present
          ? data.flexibleReminderActiveSec.value
          : this.flexibleReminderActiveSec,
      lastPersistedAt: data.lastPersistedAt.present
          ? data.lastPersistedAt.value
          : this.lastPersistedAt,
      pauseStartedAt: data.pauseStartedAt.present
          ? data.pauseStartedAt.value
          : this.pauseStartedAt,
      frozenRemainingSec: data.frozenRemainingSec.present
          ? data.frozenRemainingSec.value
          : this.frozenRemainingSec,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimerState(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('engineState: $engineState, ')
          ..write('currentSegmentId: $currentSegmentId, ')
          ..write('segmentStartedAt: $segmentStartedAt, ')
          ..write('flexibleReminderActiveSec: $flexibleReminderActiveSec, ')
          ..write('lastPersistedAt: $lastPersistedAt, ')
          ..write('pauseStartedAt: $pauseStartedAt, ')
          ..write('frozenRemainingSec: $frozenRemainingSec')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    engineState,
    currentSegmentId,
    segmentStartedAt,
    flexibleReminderActiveSec,
    lastPersistedAt,
    pauseStartedAt,
    frozenRemainingSec,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveTimerState &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.engineState == this.engineState &&
          other.currentSegmentId == this.currentSegmentId &&
          other.segmentStartedAt == this.segmentStartedAt &&
          other.flexibleReminderActiveSec == this.flexibleReminderActiveSec &&
          other.lastPersistedAt == this.lastPersistedAt &&
          other.pauseStartedAt == this.pauseStartedAt &&
          other.frozenRemainingSec == this.frozenRemainingSec);
}

class ActiveTimerStatesCompanion extends UpdateCompanion<ActiveTimerState> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> engineState;
  final Value<String?> currentSegmentId;
  final Value<int> segmentStartedAt;
  final Value<int> flexibleReminderActiveSec;
  final Value<int> lastPersistedAt;
  final Value<int?> pauseStartedAt;
  final Value<int?> frozenRemainingSec;
  final Value<int> rowid;
  const ActiveTimerStatesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.engineState = const Value.absent(),
    this.currentSegmentId = const Value.absent(),
    this.segmentStartedAt = const Value.absent(),
    this.flexibleReminderActiveSec = const Value.absent(),
    this.lastPersistedAt = const Value.absent(),
    this.pauseStartedAt = const Value.absent(),
    this.frozenRemainingSec = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActiveTimerStatesCompanion.insert({
    required String id,
    required String sessionId,
    required String engineState,
    this.currentSegmentId = const Value.absent(),
    required int segmentStartedAt,
    this.flexibleReminderActiveSec = const Value.absent(),
    required int lastPersistedAt,
    this.pauseStartedAt = const Value.absent(),
    this.frozenRemainingSec = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       engineState = Value(engineState),
       segmentStartedAt = Value(segmentStartedAt),
       lastPersistedAt = Value(lastPersistedAt);
  static Insertable<ActiveTimerState> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? engineState,
    Expression<String>? currentSegmentId,
    Expression<int>? segmentStartedAt,
    Expression<int>? flexibleReminderActiveSec,
    Expression<int>? lastPersistedAt,
    Expression<int>? pauseStartedAt,
    Expression<int>? frozenRemainingSec,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (engineState != null) 'engine_state': engineState,
      if (currentSegmentId != null) 'current_segment_id': currentSegmentId,
      if (segmentStartedAt != null) 'segment_started_at': segmentStartedAt,
      if (flexibleReminderActiveSec != null)
        'flexible_reminder_active_sec': flexibleReminderActiveSec,
      if (lastPersistedAt != null) 'last_persisted_at': lastPersistedAt,
      if (pauseStartedAt != null) 'pause_started_at': pauseStartedAt,
      if (frozenRemainingSec != null)
        'frozen_remaining_sec': frozenRemainingSec,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActiveTimerStatesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? engineState,
    Value<String?>? currentSegmentId,
    Value<int>? segmentStartedAt,
    Value<int>? flexibleReminderActiveSec,
    Value<int>? lastPersistedAt,
    Value<int?>? pauseStartedAt,
    Value<int?>? frozenRemainingSec,
    Value<int>? rowid,
  }) {
    return ActiveTimerStatesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      engineState: engineState ?? this.engineState,
      currentSegmentId: currentSegmentId ?? this.currentSegmentId,
      segmentStartedAt: segmentStartedAt ?? this.segmentStartedAt,
      flexibleReminderActiveSec:
          flexibleReminderActiveSec ?? this.flexibleReminderActiveSec,
      lastPersistedAt: lastPersistedAt ?? this.lastPersistedAt,
      pauseStartedAt: pauseStartedAt ?? this.pauseStartedAt,
      frozenRemainingSec: frozenRemainingSec ?? this.frozenRemainingSec,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (engineState.present) {
      map['engine_state'] = Variable<String>(engineState.value);
    }
    if (currentSegmentId.present) {
      map['current_segment_id'] = Variable<String>(currentSegmentId.value);
    }
    if (segmentStartedAt.present) {
      map['segment_started_at'] = Variable<int>(segmentStartedAt.value);
    }
    if (flexibleReminderActiveSec.present) {
      map['flexible_reminder_active_sec'] = Variable<int>(
        flexibleReminderActiveSec.value,
      );
    }
    if (lastPersistedAt.present) {
      map['last_persisted_at'] = Variable<int>(lastPersistedAt.value);
    }
    if (pauseStartedAt.present) {
      map['pause_started_at'] = Variable<int>(pauseStartedAt.value);
    }
    if (frozenRemainingSec.present) {
      map['frozen_remaining_sec'] = Variable<int>(frozenRemainingSec.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimerStatesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('engineState: $engineState, ')
          ..write('currentSegmentId: $currentSegmentId, ')
          ..write('segmentStartedAt: $segmentStartedAt, ')
          ..write('flexibleReminderActiveSec: $flexibleReminderActiveSec, ')
          ..write('lastPersistedAt: $lastPersistedAt, ')
          ..write('pauseStartedAt: $pauseStartedAt, ')
          ..write('frozenRemainingSec: $frozenRemainingSec, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alertToneFocusSuccessMeta =
      const VerificationMeta('alertToneFocusSuccess');
  @override
  late final GeneratedColumn<String> alertToneFocusSuccess =
      GeneratedColumn<String>(
        'alert_tone',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('success_arpeggio'),
      );
  static const VerificationMeta _alertToneBreakOverMeta =
      const VerificationMeta('alertToneBreakOver');
  @override
  late final GeneratedColumn<String> alertToneBreakOver =
      GeneratedColumn<String>(
        'alert_tone_break_over',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('break_coin'),
      );
  static const VerificationMeta _alertToneFocusFailureMeta =
      const VerificationMeta('alertToneFocusFailure');
  @override
  late final GeneratedColumn<String> alertToneFocusFailure =
      GeneratedColumn<String>(
        'alert_tone_focus_failure',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('failure_wrong'),
      );
  static const VerificationMeta _focusModeMeta = const VerificationMeta(
    'focusMode',
  );
  @override
  late final GeneratedColumn<String> focusMode = GeneratedColumn<String>(
    'focus_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('loose'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  whitelistJson = GeneratedColumn<String>(
    'whitelist_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($AppSettingsTableTable.$converterwhitelistJson);
  static const VerificationMeta _focusViolationThresholdSecMeta =
      const VerificationMeta('focusViolationThresholdSec');
  @override
  late final GeneratedColumn<int> focusViolationThresholdSec =
      GeneratedColumn<int>(
        'focus_violation_threshold_sec',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(5),
      );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _alwaysOnDisplayMeta = const VerificationMeta(
    'alwaysOnDisplay',
  );
  @override
  late final GeneratedColumn<int> alwaysOnDisplay = GeneratedColumn<int>(
    'always_on_display',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _weekStartDayMeta = const VerificationMeta(
    'weekStartDay',
  );
  @override
  late final GeneratedColumn<int> weekStartDay = GeneratedColumn<int>(
    'week_start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _timeFormatMeta = const VerificationMeta(
    'timeFormat',
  );
  @override
  late final GeneratedColumn<String> timeFormat = GeneratedColumn<String>(
    'time_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('24h'),
  );
  static const VerificationMeta _trackFailedSessionsMeta =
      const VerificationMeta('trackFailedSessions');
  @override
  late final GeneratedColumn<int> trackFailedSessions = GeneratedColumn<int>(
    'track_failed_sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    alertToneFocusSuccess,
    alertToneBreakOver,
    alertToneFocusFailure,
    focusMode,
    whitelistJson,
    focusViolationThresholdSec,
    theme,
    alwaysOnDisplay,
    language,
    weekStartDay,
    timeFormat,
    trackFailedSessions,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alert_tone')) {
      context.handle(
        _alertToneFocusSuccessMeta,
        alertToneFocusSuccess.isAcceptableOrUnknown(
          data['alert_tone']!,
          _alertToneFocusSuccessMeta,
        ),
      );
    }
    if (data.containsKey('alert_tone_break_over')) {
      context.handle(
        _alertToneBreakOverMeta,
        alertToneBreakOver.isAcceptableOrUnknown(
          data['alert_tone_break_over']!,
          _alertToneBreakOverMeta,
        ),
      );
    }
    if (data.containsKey('alert_tone_focus_failure')) {
      context.handle(
        _alertToneFocusFailureMeta,
        alertToneFocusFailure.isAcceptableOrUnknown(
          data['alert_tone_focus_failure']!,
          _alertToneFocusFailureMeta,
        ),
      );
    }
    if (data.containsKey('focus_mode')) {
      context.handle(
        _focusModeMeta,
        focusMode.isAcceptableOrUnknown(data['focus_mode']!, _focusModeMeta),
      );
    }
    if (data.containsKey('focus_violation_threshold_sec')) {
      context.handle(
        _focusViolationThresholdSecMeta,
        focusViolationThresholdSec.isAcceptableOrUnknown(
          data['focus_violation_threshold_sec']!,
          _focusViolationThresholdSecMeta,
        ),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('always_on_display')) {
      context.handle(
        _alwaysOnDisplayMeta,
        alwaysOnDisplay.isAcceptableOrUnknown(
          data['always_on_display']!,
          _alwaysOnDisplayMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('week_start_day')) {
      context.handle(
        _weekStartDayMeta,
        weekStartDay.isAcceptableOrUnknown(
          data['week_start_day']!,
          _weekStartDayMeta,
        ),
      );
    }
    if (data.containsKey('time_format')) {
      context.handle(
        _timeFormatMeta,
        timeFormat.isAcceptableOrUnknown(data['time_format']!, _timeFormatMeta),
      );
    }
    if (data.containsKey('track_failed_sessions')) {
      context.handle(
        _trackFailedSessionsMeta,
        trackFailedSessions.isAcceptableOrUnknown(
          data['track_failed_sessions']!,
          _trackFailedSessionsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      alertToneFocusSuccess: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_tone'],
      )!,
      alertToneBreakOver: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_tone_break_over'],
      )!,
      alertToneFocusFailure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_tone_focus_failure'],
      )!,
      focusMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus_mode'],
      )!,
      whitelistJson: $AppSettingsTableTable.$converterwhitelistJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}whitelist_json'],
        )!,
      ),
      focusViolationThresholdSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_violation_threshold_sec'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      alwaysOnDisplay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}always_on_display'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      weekStartDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_start_day'],
      )!,
      timeFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_format'],
      )!,
      trackFailedSessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_failed_sessions'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterwhitelistJson =
      const StringListConverter();
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String id;
  final String alertToneFocusSuccess;
  final String alertToneBreakOver;
  final String alertToneFocusFailure;
  final String focusMode;
  final List<String> whitelistJson;
  final int focusViolationThresholdSec;
  final String theme;
  final int alwaysOnDisplay;
  final String language;
  final int weekStartDay;
  final String timeFormat;
  final int trackFailedSessions;
  final int updatedAt;
  const AppSettingsTableData({
    required this.id,
    required this.alertToneFocusSuccess,
    required this.alertToneBreakOver,
    required this.alertToneFocusFailure,
    required this.focusMode,
    required this.whitelistJson,
    required this.focusViolationThresholdSec,
    required this.theme,
    required this.alwaysOnDisplay,
    required this.language,
    required this.weekStartDay,
    required this.timeFormat,
    required this.trackFailedSessions,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['alert_tone'] = Variable<String>(alertToneFocusSuccess);
    map['alert_tone_break_over'] = Variable<String>(alertToneBreakOver);
    map['alert_tone_focus_failure'] = Variable<String>(alertToneFocusFailure);
    map['focus_mode'] = Variable<String>(focusMode);
    {
      map['whitelist_json'] = Variable<String>(
        $AppSettingsTableTable.$converterwhitelistJson.toSql(whitelistJson),
      );
    }
    map['focus_violation_threshold_sec'] = Variable<int>(
      focusViolationThresholdSec,
    );
    map['theme'] = Variable<String>(theme);
    map['always_on_display'] = Variable<int>(alwaysOnDisplay);
    map['language'] = Variable<String>(language);
    map['week_start_day'] = Variable<int>(weekStartDay);
    map['time_format'] = Variable<String>(timeFormat);
    map['track_failed_sessions'] = Variable<int>(trackFailedSessions);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      id: Value(id),
      alertToneFocusSuccess: Value(alertToneFocusSuccess),
      alertToneBreakOver: Value(alertToneBreakOver),
      alertToneFocusFailure: Value(alertToneFocusFailure),
      focusMode: Value(focusMode),
      whitelistJson: Value(whitelistJson),
      focusViolationThresholdSec: Value(focusViolationThresholdSec),
      theme: Value(theme),
      alwaysOnDisplay: Value(alwaysOnDisplay),
      language: Value(language),
      weekStartDay: Value(weekStartDay),
      timeFormat: Value(timeFormat),
      trackFailedSessions: Value(trackFailedSessions),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      id: serializer.fromJson<String>(json['id']),
      alertToneFocusSuccess: serializer.fromJson<String>(
        json['alertToneFocusSuccess'],
      ),
      alertToneBreakOver: serializer.fromJson<String>(
        json['alertToneBreakOver'],
      ),
      alertToneFocusFailure: serializer.fromJson<String>(
        json['alertToneFocusFailure'],
      ),
      focusMode: serializer.fromJson<String>(json['focusMode']),
      whitelistJson: serializer.fromJson<List<String>>(json['whitelistJson']),
      focusViolationThresholdSec: serializer.fromJson<int>(
        json['focusViolationThresholdSec'],
      ),
      theme: serializer.fromJson<String>(json['theme']),
      alwaysOnDisplay: serializer.fromJson<int>(json['alwaysOnDisplay']),
      language: serializer.fromJson<String>(json['language']),
      weekStartDay: serializer.fromJson<int>(json['weekStartDay']),
      timeFormat: serializer.fromJson<String>(json['timeFormat']),
      trackFailedSessions: serializer.fromJson<int>(
        json['trackFailedSessions'],
      ),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'alertToneFocusSuccess': serializer.toJson<String>(alertToneFocusSuccess),
      'alertToneBreakOver': serializer.toJson<String>(alertToneBreakOver),
      'alertToneFocusFailure': serializer.toJson<String>(alertToneFocusFailure),
      'focusMode': serializer.toJson<String>(focusMode),
      'whitelistJson': serializer.toJson<List<String>>(whitelistJson),
      'focusViolationThresholdSec': serializer.toJson<int>(
        focusViolationThresholdSec,
      ),
      'theme': serializer.toJson<String>(theme),
      'alwaysOnDisplay': serializer.toJson<int>(alwaysOnDisplay),
      'language': serializer.toJson<String>(language),
      'weekStartDay': serializer.toJson<int>(weekStartDay),
      'timeFormat': serializer.toJson<String>(timeFormat),
      'trackFailedSessions': serializer.toJson<int>(trackFailedSessions),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AppSettingsTableData copyWith({
    String? id,
    String? alertToneFocusSuccess,
    String? alertToneBreakOver,
    String? alertToneFocusFailure,
    String? focusMode,
    List<String>? whitelistJson,
    int? focusViolationThresholdSec,
    String? theme,
    int? alwaysOnDisplay,
    String? language,
    int? weekStartDay,
    String? timeFormat,
    int? trackFailedSessions,
    int? updatedAt,
  }) => AppSettingsTableData(
    id: id ?? this.id,
    alertToneFocusSuccess: alertToneFocusSuccess ?? this.alertToneFocusSuccess,
    alertToneBreakOver: alertToneBreakOver ?? this.alertToneBreakOver,
    alertToneFocusFailure: alertToneFocusFailure ?? this.alertToneFocusFailure,
    focusMode: focusMode ?? this.focusMode,
    whitelistJson: whitelistJson ?? this.whitelistJson,
    focusViolationThresholdSec:
        focusViolationThresholdSec ?? this.focusViolationThresholdSec,
    theme: theme ?? this.theme,
    alwaysOnDisplay: alwaysOnDisplay ?? this.alwaysOnDisplay,
    language: language ?? this.language,
    weekStartDay: weekStartDay ?? this.weekStartDay,
    timeFormat: timeFormat ?? this.timeFormat,
    trackFailedSessions: trackFailedSessions ?? this.trackFailedSessions,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      alertToneFocusSuccess: data.alertToneFocusSuccess.present
          ? data.alertToneFocusSuccess.value
          : this.alertToneFocusSuccess,
      alertToneBreakOver: data.alertToneBreakOver.present
          ? data.alertToneBreakOver.value
          : this.alertToneBreakOver,
      alertToneFocusFailure: data.alertToneFocusFailure.present
          ? data.alertToneFocusFailure.value
          : this.alertToneFocusFailure,
      focusMode: data.focusMode.present ? data.focusMode.value : this.focusMode,
      whitelistJson: data.whitelistJson.present
          ? data.whitelistJson.value
          : this.whitelistJson,
      focusViolationThresholdSec: data.focusViolationThresholdSec.present
          ? data.focusViolationThresholdSec.value
          : this.focusViolationThresholdSec,
      theme: data.theme.present ? data.theme.value : this.theme,
      alwaysOnDisplay: data.alwaysOnDisplay.present
          ? data.alwaysOnDisplay.value
          : this.alwaysOnDisplay,
      language: data.language.present ? data.language.value : this.language,
      weekStartDay: data.weekStartDay.present
          ? data.weekStartDay.value
          : this.weekStartDay,
      timeFormat: data.timeFormat.present
          ? data.timeFormat.value
          : this.timeFormat,
      trackFailedSessions: data.trackFailedSessions.present
          ? data.trackFailedSessions.value
          : this.trackFailedSessions,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('id: $id, ')
          ..write('alertToneFocusSuccess: $alertToneFocusSuccess, ')
          ..write('alertToneBreakOver: $alertToneBreakOver, ')
          ..write('alertToneFocusFailure: $alertToneFocusFailure, ')
          ..write('focusMode: $focusMode, ')
          ..write('whitelistJson: $whitelistJson, ')
          ..write('focusViolationThresholdSec: $focusViolationThresholdSec, ')
          ..write('theme: $theme, ')
          ..write('alwaysOnDisplay: $alwaysOnDisplay, ')
          ..write('language: $language, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('timeFormat: $timeFormat, ')
          ..write('trackFailedSessions: $trackFailedSessions, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    alertToneFocusSuccess,
    alertToneBreakOver,
    alertToneFocusFailure,
    focusMode,
    whitelistJson,
    focusViolationThresholdSec,
    theme,
    alwaysOnDisplay,
    language,
    weekStartDay,
    timeFormat,
    trackFailedSessions,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.id == this.id &&
          other.alertToneFocusSuccess == this.alertToneFocusSuccess &&
          other.alertToneBreakOver == this.alertToneBreakOver &&
          other.alertToneFocusFailure == this.alertToneFocusFailure &&
          other.focusMode == this.focusMode &&
          other.whitelistJson == this.whitelistJson &&
          other.focusViolationThresholdSec == this.focusViolationThresholdSec &&
          other.theme == this.theme &&
          other.alwaysOnDisplay == this.alwaysOnDisplay &&
          other.language == this.language &&
          other.weekStartDay == this.weekStartDay &&
          other.timeFormat == this.timeFormat &&
          other.trackFailedSessions == this.trackFailedSessions &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> id;
  final Value<String> alertToneFocusSuccess;
  final Value<String> alertToneBreakOver;
  final Value<String> alertToneFocusFailure;
  final Value<String> focusMode;
  final Value<List<String>> whitelistJson;
  final Value<int> focusViolationThresholdSec;
  final Value<String> theme;
  final Value<int> alwaysOnDisplay;
  final Value<String> language;
  final Value<int> weekStartDay;
  final Value<String> timeFormat;
  final Value<int> trackFailedSessions;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.id = const Value.absent(),
    this.alertToneFocusSuccess = const Value.absent(),
    this.alertToneBreakOver = const Value.absent(),
    this.alertToneFocusFailure = const Value.absent(),
    this.focusMode = const Value.absent(),
    this.whitelistJson = const Value.absent(),
    this.focusViolationThresholdSec = const Value.absent(),
    this.theme = const Value.absent(),
    this.alwaysOnDisplay = const Value.absent(),
    this.language = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.timeFormat = const Value.absent(),
    this.trackFailedSessions = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String id,
    this.alertToneFocusSuccess = const Value.absent(),
    this.alertToneBreakOver = const Value.absent(),
    this.alertToneFocusFailure = const Value.absent(),
    this.focusMode = const Value.absent(),
    this.whitelistJson = const Value.absent(),
    this.focusViolationThresholdSec = const Value.absent(),
    this.theme = const Value.absent(),
    this.alwaysOnDisplay = const Value.absent(),
    this.language = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.timeFormat = const Value.absent(),
    this.trackFailedSessions = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? id,
    Expression<String>? alertToneFocusSuccess,
    Expression<String>? alertToneBreakOver,
    Expression<String>? alertToneFocusFailure,
    Expression<String>? focusMode,
    Expression<String>? whitelistJson,
    Expression<int>? focusViolationThresholdSec,
    Expression<String>? theme,
    Expression<int>? alwaysOnDisplay,
    Expression<String>? language,
    Expression<int>? weekStartDay,
    Expression<String>? timeFormat,
    Expression<int>? trackFailedSessions,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alertToneFocusSuccess != null) 'alert_tone': alertToneFocusSuccess,
      if (alertToneBreakOver != null)
        'alert_tone_break_over': alertToneBreakOver,
      if (alertToneFocusFailure != null)
        'alert_tone_focus_failure': alertToneFocusFailure,
      if (focusMode != null) 'focus_mode': focusMode,
      if (whitelistJson != null) 'whitelist_json': whitelistJson,
      if (focusViolationThresholdSec != null)
        'focus_violation_threshold_sec': focusViolationThresholdSec,
      if (theme != null) 'theme': theme,
      if (alwaysOnDisplay != null) 'always_on_display': alwaysOnDisplay,
      if (language != null) 'language': language,
      if (weekStartDay != null) 'week_start_day': weekStartDay,
      if (timeFormat != null) 'time_format': timeFormat,
      if (trackFailedSessions != null)
        'track_failed_sessions': trackFailedSessions,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? alertToneFocusSuccess,
    Value<String>? alertToneBreakOver,
    Value<String>? alertToneFocusFailure,
    Value<String>? focusMode,
    Value<List<String>>? whitelistJson,
    Value<int>? focusViolationThresholdSec,
    Value<String>? theme,
    Value<int>? alwaysOnDisplay,
    Value<String>? language,
    Value<int>? weekStartDay,
    Value<String>? timeFormat,
    Value<int>? trackFailedSessions,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      id: id ?? this.id,
      alertToneFocusSuccess:
          alertToneFocusSuccess ?? this.alertToneFocusSuccess,
      alertToneBreakOver: alertToneBreakOver ?? this.alertToneBreakOver,
      alertToneFocusFailure:
          alertToneFocusFailure ?? this.alertToneFocusFailure,
      focusMode: focusMode ?? this.focusMode,
      whitelistJson: whitelistJson ?? this.whitelistJson,
      focusViolationThresholdSec:
          focusViolationThresholdSec ?? this.focusViolationThresholdSec,
      theme: theme ?? this.theme,
      alwaysOnDisplay: alwaysOnDisplay ?? this.alwaysOnDisplay,
      language: language ?? this.language,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      timeFormat: timeFormat ?? this.timeFormat,
      trackFailedSessions: trackFailedSessions ?? this.trackFailedSessions,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alertToneFocusSuccess.present) {
      map['alert_tone'] = Variable<String>(alertToneFocusSuccess.value);
    }
    if (alertToneBreakOver.present) {
      map['alert_tone_break_over'] = Variable<String>(alertToneBreakOver.value);
    }
    if (alertToneFocusFailure.present) {
      map['alert_tone_focus_failure'] = Variable<String>(
        alertToneFocusFailure.value,
      );
    }
    if (focusMode.present) {
      map['focus_mode'] = Variable<String>(focusMode.value);
    }
    if (whitelistJson.present) {
      map['whitelist_json'] = Variable<String>(
        $AppSettingsTableTable.$converterwhitelistJson.toSql(
          whitelistJson.value,
        ),
      );
    }
    if (focusViolationThresholdSec.present) {
      map['focus_violation_threshold_sec'] = Variable<int>(
        focusViolationThresholdSec.value,
      );
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (alwaysOnDisplay.present) {
      map['always_on_display'] = Variable<int>(alwaysOnDisplay.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (weekStartDay.present) {
      map['week_start_day'] = Variable<int>(weekStartDay.value);
    }
    if (timeFormat.present) {
      map['time_format'] = Variable<String>(timeFormat.value);
    }
    if (trackFailedSessions.present) {
      map['track_failed_sessions'] = Variable<int>(trackFailedSessions.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('alertToneFocusSuccess: $alertToneFocusSuccess, ')
          ..write('alertToneBreakOver: $alertToneBreakOver, ')
          ..write('alertToneFocusFailure: $alertToneFocusFailure, ')
          ..write('focusMode: $focusMode, ')
          ..write('whitelistJson: $whitelistJson, ')
          ..write('focusViolationThresholdSec: $focusViolationThresholdSec, ')
          ..write('theme: $theme, ')
          ..write('alwaysOnDisplay: $alwaysOnDisplay, ')
          ..write('language: $language, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('timeFormat: $timeFormat, ')
          ..write('trackFailedSessions: $trackFailedSessions, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TagModeConfigsTable tagModeConfigs = $TagModeConfigsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionSegmentsTable sessionSegments = $SessionSegmentsTable(
    this,
  );
  late final $ActiveTimerStatesTable activeTimerStates =
      $ActiveTimerStatesTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tags,
    tagModeConfigs,
    sessions,
    sessionSegments,
    activeTimerStates,
    appSettingsTable,
  ];
}

typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      Value<String> color,
      Value<int> sortOrder,
      Value<int?> deletedAt,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> color,
      Value<int> sortOrder,
      Value<int?> deletedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TagModeConfigsTable, List<TagModeConfig>>
  _tagModeConfigsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tagModeConfigs,
    aliasName: 'tags__id__tag_mode_configs__tag_id',
  );

  $$TagModeConfigsTableProcessedTableManager get tagModeConfigsRefs {
    final manager = $$TagModeConfigsTableTableManager(
      $_db,
      $_db.tagModeConfigs,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tagModeConfigsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<SessionRow>>
  _sessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'tags__id__sessions__tag_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tagModeConfigsRefs(
    Expression<bool> Function($$TagModeConfigsTableFilterComposer f) f,
  ) {
    final $$TagModeConfigsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tagModeConfigs,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagModeConfigsTableFilterComposer(
            $db: $db,
            $table: $db.tagModeConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tagModeConfigsRefs<T extends Object>(
    Expression<T> Function($$TagModeConfigsTableAnnotationComposer a) f,
  ) {
    final $$TagModeConfigsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tagModeConfigs,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagModeConfigsTableAnnotationComposer(
            $db: $db,
            $table: $db.tagModeConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool tagModeConfigsRefs, bool sessionsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({tagModeConfigsRefs = false, sessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tagModeConfigsRefs) db.tagModeConfigs,
                    if (sessionsRefs) db.sessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tagModeConfigsRefs)
                        await $_getPrefetchedData<
                          Tag,
                          $TagsTable,
                          TagModeConfig
                        >(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._tagModeConfigsRefsTable(db),
                          managerFromTypedResult: (p0) => $$TagsTableReferences(
                            db,
                            table,
                            p0,
                          ).tagModeConfigsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, SessionRow>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagsTableReferences(db, table, p0).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool tagModeConfigsRefs, bool sessionsRefs})
    >;
typedef $$TagModeConfigsTableCreateCompanionBuilder =
    TagModeConfigsCompanion Function({
      required String id,
      required String tagId,
      required String mode,
      Value<int?> focusDurationSec,
      Value<int?> shortBreakDurationSec,
      Value<int?> longBreakDurationSec,
      Value<int?> sessionsBeforeLongBreak,
      Value<int?> totalCycles,
      Value<int?> autoStartBreak,
      Value<int?> autoStartFocus,
      Value<int?> defaultDurationSec,
      Value<int?> reminderIntervalMin,
      Value<int?> reminderEnabled,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TagModeConfigsTableUpdateCompanionBuilder =
    TagModeConfigsCompanion Function({
      Value<String> id,
      Value<String> tagId,
      Value<String> mode,
      Value<int?> focusDurationSec,
      Value<int?> shortBreakDurationSec,
      Value<int?> longBreakDurationSec,
      Value<int?> sessionsBeforeLongBreak,
      Value<int?> totalCycles,
      Value<int?> autoStartBreak,
      Value<int?> autoStartFocus,
      Value<int?> defaultDurationSec,
      Value<int?> reminderIntervalMin,
      Value<int?> reminderEnabled,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$TagModeConfigsTableReferences
    extends BaseReferences<_$AppDatabase, $TagModeConfigsTable, TagModeConfig> {
  $$TagModeConfigsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('tag_mode_configs__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TagModeConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $TagModeConfigsTable> {
  $$TagModeConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusDurationSec => $composableBuilder(
    column: $table.focusDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortBreakDurationSec => $composableBuilder(
    column: $table.shortBreakDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longBreakDurationSec => $composableBuilder(
    column: $table.longBreakDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionsBeforeLongBreak => $composableBuilder(
    column: $table.sessionsBeforeLongBreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCycles => $composableBuilder(
    column: $table.totalCycles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoStartBreak => $composableBuilder(
    column: $table.autoStartBreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoStartFocus => $composableBuilder(
    column: $table.autoStartFocus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultDurationSec => $composableBuilder(
    column: $table.defaultDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderIntervalMin => $composableBuilder(
    column: $table.reminderIntervalMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagModeConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $TagModeConfigsTable> {
  $$TagModeConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusDurationSec => $composableBuilder(
    column: $table.focusDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortBreakDurationSec => $composableBuilder(
    column: $table.shortBreakDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longBreakDurationSec => $composableBuilder(
    column: $table.longBreakDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionsBeforeLongBreak => $composableBuilder(
    column: $table.sessionsBeforeLongBreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCycles => $composableBuilder(
    column: $table.totalCycles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoStartBreak => $composableBuilder(
    column: $table.autoStartBreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoStartFocus => $composableBuilder(
    column: $table.autoStartFocus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultDurationSec => $composableBuilder(
    column: $table.defaultDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderIntervalMin => $composableBuilder(
    column: $table.reminderIntervalMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagModeConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagModeConfigsTable> {
  $$TagModeConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get focusDurationSec => $composableBuilder(
    column: $table.focusDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shortBreakDurationSec => $composableBuilder(
    column: $table.shortBreakDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longBreakDurationSec => $composableBuilder(
    column: $table.longBreakDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionsBeforeLongBreak => $composableBuilder(
    column: $table.sessionsBeforeLongBreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCycles => $composableBuilder(
    column: $table.totalCycles,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoStartBreak => $composableBuilder(
    column: $table.autoStartBreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoStartFocus => $composableBuilder(
    column: $table.autoStartFocus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultDurationSec => $composableBuilder(
    column: $table.defaultDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderIntervalMin => $composableBuilder(
    column: $table.reminderIntervalMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagModeConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagModeConfigsTable,
          TagModeConfig,
          $$TagModeConfigsTableFilterComposer,
          $$TagModeConfigsTableOrderingComposer,
          $$TagModeConfigsTableAnnotationComposer,
          $$TagModeConfigsTableCreateCompanionBuilder,
          $$TagModeConfigsTableUpdateCompanionBuilder,
          (TagModeConfig, $$TagModeConfigsTableReferences),
          TagModeConfig,
          PrefetchHooks Function({bool tagId})
        > {
  $$TagModeConfigsTableTableManager(
    _$AppDatabase db,
    $TagModeConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagModeConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagModeConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagModeConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int?> focusDurationSec = const Value.absent(),
                Value<int?> shortBreakDurationSec = const Value.absent(),
                Value<int?> longBreakDurationSec = const Value.absent(),
                Value<int?> sessionsBeforeLongBreak = const Value.absent(),
                Value<int?> totalCycles = const Value.absent(),
                Value<int?> autoStartBreak = const Value.absent(),
                Value<int?> autoStartFocus = const Value.absent(),
                Value<int?> defaultDurationSec = const Value.absent(),
                Value<int?> reminderIntervalMin = const Value.absent(),
                Value<int?> reminderEnabled = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagModeConfigsCompanion(
                id: id,
                tagId: tagId,
                mode: mode,
                focusDurationSec: focusDurationSec,
                shortBreakDurationSec: shortBreakDurationSec,
                longBreakDurationSec: longBreakDurationSec,
                sessionsBeforeLongBreak: sessionsBeforeLongBreak,
                totalCycles: totalCycles,
                autoStartBreak: autoStartBreak,
                autoStartFocus: autoStartFocus,
                defaultDurationSec: defaultDurationSec,
                reminderIntervalMin: reminderIntervalMin,
                reminderEnabled: reminderEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tagId,
                required String mode,
                Value<int?> focusDurationSec = const Value.absent(),
                Value<int?> shortBreakDurationSec = const Value.absent(),
                Value<int?> longBreakDurationSec = const Value.absent(),
                Value<int?> sessionsBeforeLongBreak = const Value.absent(),
                Value<int?> totalCycles = const Value.absent(),
                Value<int?> autoStartBreak = const Value.absent(),
                Value<int?> autoStartFocus = const Value.absent(),
                Value<int?> defaultDurationSec = const Value.absent(),
                Value<int?> reminderIntervalMin = const Value.absent(),
                Value<int?> reminderEnabled = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TagModeConfigsCompanion.insert(
                id: id,
                tagId: tagId,
                mode: mode,
                focusDurationSec: focusDurationSec,
                shortBreakDurationSec: shortBreakDurationSec,
                longBreakDurationSec: longBreakDurationSec,
                sessionsBeforeLongBreak: sessionsBeforeLongBreak,
                totalCycles: totalCycles,
                autoStartBreak: autoStartBreak,
                autoStartFocus: autoStartFocus,
                defaultDurationSec: defaultDurationSec,
                reminderIntervalMin: reminderIntervalMin,
                reminderEnabled: reminderEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TagModeConfigsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$TagModeConfigsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn:
                                    $$TagModeConfigsTableReferences
                                        ._tagIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TagModeConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagModeConfigsTable,
      TagModeConfig,
      $$TagModeConfigsTableFilterComposer,
      $$TagModeConfigsTableOrderingComposer,
      $$TagModeConfigsTableAnnotationComposer,
      $$TagModeConfigsTableCreateCompanionBuilder,
      $$TagModeConfigsTableUpdateCompanionBuilder,
      (TagModeConfig, $$TagModeConfigsTableReferences),
      TagModeConfig,
      PrefetchHooks Function({bool tagId})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required String tagId,
      required String mode,
      Value<String> status,
      required int startedAt,
      Value<int?> endedAt,
      required String timelineDate,
      Value<int> totalActiveSec,
      Value<int> totalPausedSec,
      required ConfigSnapshot configSnapshotJson,
      Value<int> pomodoroFocusCount,
      Value<int> pomodoroCyclesCompleted,
      Value<int?> pomodoroCyclesTarget,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> tagId,
      Value<String> mode,
      Value<String> status,
      Value<int> startedAt,
      Value<int?> endedAt,
      Value<String> timelineDate,
      Value<int> totalActiveSec,
      Value<int> totalPausedSec,
      Value<ConfigSnapshot> configSnapshotJson,
      Value<int> pomodoroFocusCount,
      Value<int> pomodoroCyclesCompleted,
      Value<int?> pomodoroCyclesTarget,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('sessions__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SessionSegmentsTable, List<SessionSegment>>
  _sessionSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionSegments,
    aliasName: 'sessions__id__session_segments__session_id',
  );

  $$SessionSegmentsTableProcessedTableManager get sessionSegmentsRefs {
    final manager = $$SessionSegmentsTableTableManager(
      $_db,
      $_db.sessionSegments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActiveTimerStatesTable, List<ActiveTimerState>>
  _activeTimerStatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activeTimerStates,
        aliasName: 'sessions__id__active_timer_states__session_id',
      );

  $$ActiveTimerStatesTableProcessedTableManager get activeTimerStatesRefs {
    final manager = $$ActiveTimerStatesTableTableManager(
      $_db,
      $_db.activeTimerStates,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activeTimerStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timelineDate => $composableBuilder(
    column: $table.timelineDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalActiveSec => $composableBuilder(
    column: $table.totalActiveSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPausedSec => $composableBuilder(
    column: $table.totalPausedSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ConfigSnapshot, ConfigSnapshot, String>
  get configSnapshotJson => $composableBuilder(
    column: $table.configSnapshotJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get pomodoroFocusCount => $composableBuilder(
    column: $table.pomodoroFocusCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pomodoroCyclesCompleted => $composableBuilder(
    column: $table.pomodoroCyclesCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pomodoroCyclesTarget => $composableBuilder(
    column: $table.pomodoroCyclesTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionSegmentsRefs(
    Expression<bool> Function($$SessionSegmentsTableFilterComposer f) f,
  ) {
    final $$SessionSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activeTimerStatesRefs(
    Expression<bool> Function($$ActiveTimerStatesTableFilterComposer f) f,
  ) {
    final $$ActiveTimerStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activeTimerStates,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiveTimerStatesTableFilterComposer(
            $db: $db,
            $table: $db.activeTimerStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timelineDate => $composableBuilder(
    column: $table.timelineDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalActiveSec => $composableBuilder(
    column: $table.totalActiveSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPausedSec => $composableBuilder(
    column: $table.totalPausedSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configSnapshotJson => $composableBuilder(
    column: $table.configSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pomodoroFocusCount => $composableBuilder(
    column: $table.pomodoroFocusCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pomodoroCyclesCompleted => $composableBuilder(
    column: $table.pomodoroCyclesCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pomodoroCyclesTarget => $composableBuilder(
    column: $table.pomodoroCyclesTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get timelineDate => $composableBuilder(
    column: $table.timelineDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalActiveSec => $composableBuilder(
    column: $table.totalActiveSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPausedSec => $composableBuilder(
    column: $table.totalPausedSec,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ConfigSnapshot, String>
  get configSnapshotJson => $composableBuilder(
    column: $table.configSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pomodoroFocusCount => $composableBuilder(
    column: $table.pomodoroFocusCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pomodoroCyclesCompleted => $composableBuilder(
    column: $table.pomodoroCyclesCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pomodoroCyclesTarget => $composableBuilder(
    column: $table.pomodoroCyclesTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionSegmentsRefs<T extends Object>(
    Expression<T> Function($$SessionSegmentsTableAnnotationComposer a) f,
  ) {
    final $$SessionSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activeTimerStatesRefs<T extends Object>(
    Expression<T> Function($$ActiveTimerStatesTableAnnotationComposer a) f,
  ) {
    final $$ActiveTimerStatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activeTimerStates,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActiveTimerStatesTableAnnotationComposer(
                $db: $db,
                $table: $db.activeTimerStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({
            bool tagId,
            bool sessionSegmentsRefs,
            bool activeTimerStatesRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<String> timelineDate = const Value.absent(),
                Value<int> totalActiveSec = const Value.absent(),
                Value<int> totalPausedSec = const Value.absent(),
                Value<ConfigSnapshot> configSnapshotJson = const Value.absent(),
                Value<int> pomodoroFocusCount = const Value.absent(),
                Value<int> pomodoroCyclesCompleted = const Value.absent(),
                Value<int?> pomodoroCyclesTarget = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                tagId: tagId,
                mode: mode,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                timelineDate: timelineDate,
                totalActiveSec: totalActiveSec,
                totalPausedSec: totalPausedSec,
                configSnapshotJson: configSnapshotJson,
                pomodoroFocusCount: pomodoroFocusCount,
                pomodoroCyclesCompleted: pomodoroCyclesCompleted,
                pomodoroCyclesTarget: pomodoroCyclesTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tagId,
                required String mode,
                Value<String> status = const Value.absent(),
                required int startedAt,
                Value<int?> endedAt = const Value.absent(),
                required String timelineDate,
                Value<int> totalActiveSec = const Value.absent(),
                Value<int> totalPausedSec = const Value.absent(),
                required ConfigSnapshot configSnapshotJson,
                Value<int> pomodoroFocusCount = const Value.absent(),
                Value<int> pomodoroCyclesCompleted = const Value.absent(),
                Value<int?> pomodoroCyclesTarget = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                tagId: tagId,
                mode: mode,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                timelineDate: timelineDate,
                totalActiveSec: totalActiveSec,
                totalPausedSec: totalPausedSec,
                configSnapshotJson: configSnapshotJson,
                pomodoroFocusCount: pomodoroFocusCount,
                pomodoroCyclesCompleted: pomodoroCyclesCompleted,
                pomodoroCyclesTarget: pomodoroCyclesTarget,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tagId = false,
                sessionSegmentsRefs = false,
                activeTimerStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionSegmentsRefs) db.sessionSegments,
                    if (activeTimerStatesRefs) db.activeTimerStates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tagId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tagId,
                                    referencedTable: $$SessionsTableReferences
                                        ._tagIdTable(db),
                                    referencedColumn: $$SessionsTableReferences
                                        ._tagIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionSegmentsRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          SessionSegment
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionSegmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activeTimerStatesRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          ActiveTimerState
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._activeTimerStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).activeTimerStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({
        bool tagId,
        bool sessionSegmentsRefs,
        bool activeTimerStatesRefs,
      })
    >;
typedef $$SessionSegmentsTableCreateCompanionBuilder =
    SessionSegmentsCompanion Function({
      required String id,
      required String sessionId,
      required String type,
      Value<int> orderIndex,
      required int plannedSec,
      Value<int> actualSec,
      Value<int> segmentPausedSec,
      Value<String> segmentStatus,
      Value<int?> startedAt,
      Value<int?> endedAt,
      Value<int> rowid,
    });
typedef $$SessionSegmentsTableUpdateCompanionBuilder =
    SessionSegmentsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> type,
      Value<int> orderIndex,
      Value<int> plannedSec,
      Value<int> actualSec,
      Value<int> segmentPausedSec,
      Value<String> segmentStatus,
      Value<int?> startedAt,
      Value<int?> endedAt,
      Value<int> rowid,
    });

final class $$SessionSegmentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SessionSegmentsTable, SessionSegment> {
  $$SessionSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_segments__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActiveTimerStatesTable, List<ActiveTimerState>>
  _activeTimerStatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activeTimerStates,
        aliasName:
            'session_segments__id__active_timer_states__current_segment_id',
      );

  $$ActiveTimerStatesTableProcessedTableManager get activeTimerStatesRefs {
    final manager =
        $$ActiveTimerStatesTableTableManager(
          $_db,
          $_db.activeTimerStates,
        ).filter(
          (f) => f.currentSegmentId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _activeTimerStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionSegmentsTable> {
  $$SessionSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedSec => $composableBuilder(
    column: $table.plannedSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualSec => $composableBuilder(
    column: $table.actualSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentPausedSec => $composableBuilder(
    column: $table.segmentPausedSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmentStatus => $composableBuilder(
    column: $table.segmentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activeTimerStatesRefs(
    Expression<bool> Function($$ActiveTimerStatesTableFilterComposer f) f,
  ) {
    final $$ActiveTimerStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activeTimerStates,
      getReferencedColumn: (t) => t.currentSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiveTimerStatesTableFilterComposer(
            $db: $db,
            $table: $db.activeTimerStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionSegmentsTable> {
  $$SessionSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedSec => $composableBuilder(
    column: $table.plannedSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualSec => $composableBuilder(
    column: $table.actualSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentPausedSec => $composableBuilder(
    column: $table.segmentPausedSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentStatus => $composableBuilder(
    column: $table.segmentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionSegmentsTable> {
  $$SessionSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedSec => $composableBuilder(
    column: $table.plannedSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualSec =>
      $composableBuilder(column: $table.actualSec, builder: (column) => column);

  GeneratedColumn<int> get segmentPausedSec => $composableBuilder(
    column: $table.segmentPausedSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get segmentStatus => $composableBuilder(
    column: $table.segmentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> activeTimerStatesRefs<T extends Object>(
    Expression<T> Function($$ActiveTimerStatesTableAnnotationComposer a) f,
  ) {
    final $$ActiveTimerStatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activeTimerStates,
          getReferencedColumn: (t) => t.currentSegmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActiveTimerStatesTableAnnotationComposer(
                $db: $db,
                $table: $db.activeTimerStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SessionSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionSegmentsTable,
          SessionSegment,
          $$SessionSegmentsTableFilterComposer,
          $$SessionSegmentsTableOrderingComposer,
          $$SessionSegmentsTableAnnotationComposer,
          $$SessionSegmentsTableCreateCompanionBuilder,
          $$SessionSegmentsTableUpdateCompanionBuilder,
          (SessionSegment, $$SessionSegmentsTableReferences),
          SessionSegment,
          PrefetchHooks Function({bool sessionId, bool activeTimerStatesRefs})
        > {
  $$SessionSegmentsTableTableManager(
    _$AppDatabase db,
    $SessionSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> plannedSec = const Value.absent(),
                Value<int> actualSec = const Value.absent(),
                Value<int> segmentPausedSec = const Value.absent(),
                Value<String> segmentStatus = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSegmentsCompanion(
                id: id,
                sessionId: sessionId,
                type: type,
                orderIndex: orderIndex,
                plannedSec: plannedSec,
                actualSec: actualSec,
                segmentPausedSec: segmentPausedSec,
                segmentStatus: segmentStatus,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String type,
                Value<int> orderIndex = const Value.absent(),
                required int plannedSec,
                Value<int> actualSec = const Value.absent(),
                Value<int> segmentPausedSec = const Value.absent(),
                Value<String> segmentStatus = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSegmentsCompanion.insert(
                id: id,
                sessionId: sessionId,
                type: type,
                orderIndex: orderIndex,
                plannedSec: plannedSec,
                actualSec: actualSec,
                segmentPausedSec: segmentPausedSec,
                segmentStatus: segmentStatus,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, activeTimerStatesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activeTimerStatesRefs) db.activeTimerStates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$SessionSegmentsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$SessionSegmentsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activeTimerStatesRefs)
                        await $_getPrefetchedData<
                          SessionSegment,
                          $SessionSegmentsTable,
                          ActiveTimerState
                        >(
                          currentTable: table,
                          referencedTable: $$SessionSegmentsTableReferences
                              ._activeTimerStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionSegmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).activeTimerStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.currentSegmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionSegmentsTable,
      SessionSegment,
      $$SessionSegmentsTableFilterComposer,
      $$SessionSegmentsTableOrderingComposer,
      $$SessionSegmentsTableAnnotationComposer,
      $$SessionSegmentsTableCreateCompanionBuilder,
      $$SessionSegmentsTableUpdateCompanionBuilder,
      (SessionSegment, $$SessionSegmentsTableReferences),
      SessionSegment,
      PrefetchHooks Function({bool sessionId, bool activeTimerStatesRefs})
    >;
typedef $$ActiveTimerStatesTableCreateCompanionBuilder =
    ActiveTimerStatesCompanion Function({
      required String id,
      required String sessionId,
      required String engineState,
      Value<String?> currentSegmentId,
      required int segmentStartedAt,
      Value<int> flexibleReminderActiveSec,
      required int lastPersistedAt,
      Value<int?> pauseStartedAt,
      Value<int?> frozenRemainingSec,
      Value<int> rowid,
    });
typedef $$ActiveTimerStatesTableUpdateCompanionBuilder =
    ActiveTimerStatesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> engineState,
      Value<String?> currentSegmentId,
      Value<int> segmentStartedAt,
      Value<int> flexibleReminderActiveSec,
      Value<int> lastPersistedAt,
      Value<int?> pauseStartedAt,
      Value<int?> frozenRemainingSec,
      Value<int> rowid,
    });

final class $$ActiveTimerStatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActiveTimerStatesTable,
          ActiveTimerState
        > {
  $$ActiveTimerStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('active_timer_states__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SessionSegmentsTable _currentSegmentIdTable(_$AppDatabase db) =>
      db.sessionSegments.createAlias(
        'active_timer_states__current_segment_id__session_segments__id',
      );

  $$SessionSegmentsTableProcessedTableManager? get currentSegmentId {
    final $_column = $_itemColumn<String>('current_segment_id');
    if ($_column == null) return null;
    final manager = $$SessionSegmentsTableTableManager(
      $_db,
      $_db.sessionSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currentSegmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActiveTimerStatesTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveTimerStatesTable> {
  $$ActiveTimerStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineState => $composableBuilder(
    column: $table.engineState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentStartedAt => $composableBuilder(
    column: $table.segmentStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flexibleReminderActiveSec => $composableBuilder(
    column: $table.flexibleReminderActiveSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPersistedAt => $composableBuilder(
    column: $table.lastPersistedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frozenRemainingSec => $composableBuilder(
    column: $table.frozenRemainingSec,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionSegmentsTableFilterComposer get currentSegmentId {
    final $$SessionSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentSegmentId,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveTimerStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveTimerStatesTable> {
  $$ActiveTimerStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineState => $composableBuilder(
    column: $table.engineState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentStartedAt => $composableBuilder(
    column: $table.segmentStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flexibleReminderActiveSec => $composableBuilder(
    column: $table.flexibleReminderActiveSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPersistedAt => $composableBuilder(
    column: $table.lastPersistedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frozenRemainingSec => $composableBuilder(
    column: $table.frozenRemainingSec,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionSegmentsTableOrderingComposer get currentSegmentId {
    final $$SessionSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentSegmentId,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveTimerStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveTimerStatesTable> {
  $$ActiveTimerStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get engineState => $composableBuilder(
    column: $table.engineState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get segmentStartedAt => $composableBuilder(
    column: $table.segmentStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flexibleReminderActiveSec => $composableBuilder(
    column: $table.flexibleReminderActiveSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPersistedAt => $composableBuilder(
    column: $table.lastPersistedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frozenRemainingSec => $composableBuilder(
    column: $table.frozenRemainingSec,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionSegmentsTableAnnotationComposer get currentSegmentId {
    final $$SessionSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currentSegmentId,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveTimerStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveTimerStatesTable,
          ActiveTimerState,
          $$ActiveTimerStatesTableFilterComposer,
          $$ActiveTimerStatesTableOrderingComposer,
          $$ActiveTimerStatesTableAnnotationComposer,
          $$ActiveTimerStatesTableCreateCompanionBuilder,
          $$ActiveTimerStatesTableUpdateCompanionBuilder,
          (ActiveTimerState, $$ActiveTimerStatesTableReferences),
          ActiveTimerState,
          PrefetchHooks Function({bool sessionId, bool currentSegmentId})
        > {
  $$ActiveTimerStatesTableTableManager(
    _$AppDatabase db,
    $ActiveTimerStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveTimerStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveTimerStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveTimerStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> engineState = const Value.absent(),
                Value<String?> currentSegmentId = const Value.absent(),
                Value<int> segmentStartedAt = const Value.absent(),
                Value<int> flexibleReminderActiveSec = const Value.absent(),
                Value<int> lastPersistedAt = const Value.absent(),
                Value<int?> pauseStartedAt = const Value.absent(),
                Value<int?> frozenRemainingSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveTimerStatesCompanion(
                id: id,
                sessionId: sessionId,
                engineState: engineState,
                currentSegmentId: currentSegmentId,
                segmentStartedAt: segmentStartedAt,
                flexibleReminderActiveSec: flexibleReminderActiveSec,
                lastPersistedAt: lastPersistedAt,
                pauseStartedAt: pauseStartedAt,
                frozenRemainingSec: frozenRemainingSec,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String engineState,
                Value<String?> currentSegmentId = const Value.absent(),
                required int segmentStartedAt,
                Value<int> flexibleReminderActiveSec = const Value.absent(),
                required int lastPersistedAt,
                Value<int?> pauseStartedAt = const Value.absent(),
                Value<int?> frozenRemainingSec = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActiveTimerStatesCompanion.insert(
                id: id,
                sessionId: sessionId,
                engineState: engineState,
                currentSegmentId: currentSegmentId,
                segmentStartedAt: segmentStartedAt,
                flexibleReminderActiveSec: flexibleReminderActiveSec,
                lastPersistedAt: lastPersistedAt,
                pauseStartedAt: pauseStartedAt,
                frozenRemainingSec: frozenRemainingSec,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActiveTimerStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, currentSegmentId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$ActiveTimerStatesTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$ActiveTimerStatesTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (currentSegmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.currentSegmentId,
                                    referencedTable:
                                        $$ActiveTimerStatesTableReferences
                                            ._currentSegmentIdTable(db),
                                    referencedColumn:
                                        $$ActiveTimerStatesTableReferences
                                            ._currentSegmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ActiveTimerStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveTimerStatesTable,
      ActiveTimerState,
      $$ActiveTimerStatesTableFilterComposer,
      $$ActiveTimerStatesTableOrderingComposer,
      $$ActiveTimerStatesTableAnnotationComposer,
      $$ActiveTimerStatesTableCreateCompanionBuilder,
      $$ActiveTimerStatesTableUpdateCompanionBuilder,
      (ActiveTimerState, $$ActiveTimerStatesTableReferences),
      ActiveTimerState,
      PrefetchHooks Function({bool sessionId, bool currentSegmentId})
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String id,
      Value<String> alertToneFocusSuccess,
      Value<String> alertToneBreakOver,
      Value<String> alertToneFocusFailure,
      Value<String> focusMode,
      Value<List<String>> whitelistJson,
      Value<int> focusViolationThresholdSec,
      Value<String> theme,
      Value<int> alwaysOnDisplay,
      Value<String> language,
      Value<int> weekStartDay,
      Value<String> timeFormat,
      Value<int> trackFailedSessions,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> id,
      Value<String> alertToneFocusSuccess,
      Value<String> alertToneBreakOver,
      Value<String> alertToneFocusFailure,
      Value<String> focusMode,
      Value<List<String>> whitelistJson,
      Value<int> focusViolationThresholdSec,
      Value<String> theme,
      Value<int> alwaysOnDisplay,
      Value<String> language,
      Value<int> weekStartDay,
      Value<String> timeFormat,
      Value<int> trackFailedSessions,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertToneFocusSuccess => $composableBuilder(
    column: $table.alertToneFocusSuccess,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertToneBreakOver => $composableBuilder(
    column: $table.alertToneBreakOver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertToneFocusFailure => $composableBuilder(
    column: $table.alertToneFocusFailure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focusMode => $composableBuilder(
    column: $table.focusMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get whitelistJson => $composableBuilder(
    column: $table.whitelistJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get focusViolationThresholdSec => $composableBuilder(
    column: $table.focusViolationThresholdSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get alwaysOnDisplay => $composableBuilder(
    column: $table.alwaysOnDisplay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeFormat => $composableBuilder(
    column: $table.timeFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackFailedSessions => $composableBuilder(
    column: $table.trackFailedSessions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertToneFocusSuccess => $composableBuilder(
    column: $table.alertToneFocusSuccess,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertToneBreakOver => $composableBuilder(
    column: $table.alertToneBreakOver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertToneFocusFailure => $composableBuilder(
    column: $table.alertToneFocusFailure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focusMode => $composableBuilder(
    column: $table.focusMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whitelistJson => $composableBuilder(
    column: $table.whitelistJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusViolationThresholdSec => $composableBuilder(
    column: $table.focusViolationThresholdSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get alwaysOnDisplay => $composableBuilder(
    column: $table.alwaysOnDisplay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeFormat => $composableBuilder(
    column: $table.timeFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackFailedSessions => $composableBuilder(
    column: $table.trackFailedSessions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alertToneFocusSuccess => $composableBuilder(
    column: $table.alertToneFocusSuccess,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertToneBreakOver => $composableBuilder(
    column: $table.alertToneBreakOver,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alertToneFocusFailure => $composableBuilder(
    column: $table.alertToneFocusFailure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get focusMode =>
      $composableBuilder(column: $table.focusMode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get whitelistJson =>
      $composableBuilder(
        column: $table.whitelistJson,
        builder: (column) => column,
      );

  GeneratedColumn<int> get focusViolationThresholdSec => $composableBuilder(
    column: $table.focusViolationThresholdSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<int> get alwaysOnDisplay => $composableBuilder(
    column: $table.alwaysOnDisplay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get weekStartDay => $composableBuilder(
    column: $table.weekStartDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeFormat => $composableBuilder(
    column: $table.timeFormat,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trackFailedSessions => $composableBuilder(
    column: $table.trackFailedSessions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> alertToneFocusSuccess = const Value.absent(),
                Value<String> alertToneBreakOver = const Value.absent(),
                Value<String> alertToneFocusFailure = const Value.absent(),
                Value<String> focusMode = const Value.absent(),
                Value<List<String>> whitelistJson = const Value.absent(),
                Value<int> focusViolationThresholdSec = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<int> alwaysOnDisplay = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> weekStartDay = const Value.absent(),
                Value<String> timeFormat = const Value.absent(),
                Value<int> trackFailedSessions = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                id: id,
                alertToneFocusSuccess: alertToneFocusSuccess,
                alertToneBreakOver: alertToneBreakOver,
                alertToneFocusFailure: alertToneFocusFailure,
                focusMode: focusMode,
                whitelistJson: whitelistJson,
                focusViolationThresholdSec: focusViolationThresholdSec,
                theme: theme,
                alwaysOnDisplay: alwaysOnDisplay,
                language: language,
                weekStartDay: weekStartDay,
                timeFormat: timeFormat,
                trackFailedSessions: trackFailedSessions,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> alertToneFocusSuccess = const Value.absent(),
                Value<String> alertToneBreakOver = const Value.absent(),
                Value<String> alertToneFocusFailure = const Value.absent(),
                Value<String> focusMode = const Value.absent(),
                Value<List<String>> whitelistJson = const Value.absent(),
                Value<int> focusViolationThresholdSec = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<int> alwaysOnDisplay = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int> weekStartDay = const Value.absent(),
                Value<String> timeFormat = const Value.absent(),
                Value<int> trackFailedSessions = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                id: id,
                alertToneFocusSuccess: alertToneFocusSuccess,
                alertToneBreakOver: alertToneBreakOver,
                alertToneFocusFailure: alertToneFocusFailure,
                focusMode: focusMode,
                whitelistJson: whitelistJson,
                focusViolationThresholdSec: focusViolationThresholdSec,
                theme: theme,
                alwaysOnDisplay: alwaysOnDisplay,
                language: language,
                weekStartDay: weekStartDay,
                timeFormat: timeFormat,
                trackFailedSessions: trackFailedSessions,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TagModeConfigsTableTableManager get tagModeConfigs =>
      $$TagModeConfigsTableTableManager(_db, _db.tagModeConfigs);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionSegmentsTableTableManager get sessionSegments =>
      $$SessionSegmentsTableTableManager(_db, _db.sessionSegments);
  $$ActiveTimerStatesTableTableManager get activeTimerStates =>
      $$ActiveTimerStatesTableTableManager(_db, _db.activeTimerStates);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
}

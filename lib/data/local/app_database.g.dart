// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    createdAt,
    updatedAt,
    remoteId,
    syncStatus,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
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
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String displayName;
  final int createdAt;
  final int updatedAt;
  final String? remoteId;
  final String? syncStatus;
  final int? serverUpdatedAt;
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.syncStatus,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'remoteId': serializer.toJson<String?>(remoteId),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    int? createdAt,
    int? updatedAt,
    Value<String?> remoteId = const Value.absent(),
    Value<String?> syncStatus = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => UserProfile(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    createdAt,
    updatedAt,
    remoteId,
    syncStatus,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.syncStatus == this.syncStatus &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> remoteId;
  final Value<String?> syncStatus;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String displayName,
    required int createdAt,
    required int updatedAt,
    this.remoteId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? remoteId,
    Expression<String>? syncStatus,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? remoteId,
    Value<String?>? syncStatus,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringPaymentsTable extends RecurringPayments
    with TableInfo<$RecurringPaymentsTable, RecurringPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorSuggestedMeta =
      const VerificationMeta('amountMinorSuggested');
  @override
  late final GeneratedColumn<int> amountMinorSuggested = GeneratedColumn<int>(
    'amount_minor_suggested',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMonthKeyMeta = const VerificationMeta(
    'endMonthKey',
  );
  @override
  late final GeneratedColumn<String> endMonthKey = GeneratedColumn<String>(
    'end_month_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    title,
    categoryId,
    amountMinorSuggested,
    currencyCode,
    dayOfMonth,
    endMonthKey,
    isEnabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount_minor_suggested')) {
      context.handle(
        _amountMinorSuggestedMeta,
        amountMinorSuggested.isAcceptableOrUnknown(
          data['amount_minor_suggested']!,
          _amountMinorSuggestedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorSuggestedMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('end_month_key')) {
      context.handle(
        _endMonthKeyMeta,
        endMonthKey.isAcceptableOrUnknown(
          data['end_month_key']!,
          _endMonthKeyMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
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
  RecurringPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      amountMinorSuggested: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor_suggested'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      endMonthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_month_key'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
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
  $RecurringPaymentsTable createAlias(String alias) {
    return $RecurringPaymentsTable(attachedDatabase, alias);
  }
}

class RecurringPayment extends DataClass
    implements Insertable<RecurringPayment> {
  final String id;
  final String title;
  final String categoryId;
  final int amountMinorSuggested;
  final String currencyCode;
  final int dayOfMonth;

  /// Optional inclusive end month for this recurring template (`YYYY-MM` in local calendar).
  /// When null, the template recurs indefinitely.
  final String? endMonthKey;

  /// When false, the template is hidden from Expenses → Recurring and home; management screen still lists it.
  final bool isEnabled;
  final int createdAt;
  final int updatedAt;
  const RecurringPayment({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.amountMinorSuggested,
    required this.currencyCode,
    required this.dayOfMonth,
    this.endMonthKey,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category_id'] = Variable<String>(categoryId);
    map['amount_minor_suggested'] = Variable<int>(amountMinorSuggested);
    map['currency_code'] = Variable<String>(currencyCode);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    if (!nullToAbsent || endMonthKey != null) {
      map['end_month_key'] = Variable<String>(endMonthKey);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RecurringPaymentsCompanion toCompanion(bool nullToAbsent) {
    return RecurringPaymentsCompanion(
      id: Value(id),
      title: Value(title),
      categoryId: Value(categoryId),
      amountMinorSuggested: Value(amountMinorSuggested),
      currencyCode: Value(currencyCode),
      dayOfMonth: Value(dayOfMonth),
      endMonthKey: endMonthKey == null && nullToAbsent
          ? const Value.absent()
          : Value(endMonthKey),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecurringPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringPayment(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amountMinorSuggested: serializer.fromJson<int>(
        json['amountMinorSuggested'],
      ),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      endMonthKey: serializer.fromJson<String?>(json['endMonthKey']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'categoryId': serializer.toJson<String>(categoryId),
      'amountMinorSuggested': serializer.toJson<int>(amountMinorSuggested),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'endMonthKey': serializer.toJson<String?>(endMonthKey),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RecurringPayment copyWith({
    String? id,
    String? title,
    String? categoryId,
    int? amountMinorSuggested,
    String? currencyCode,
    int? dayOfMonth,
    Value<String?> endMonthKey = const Value.absent(),
    bool? isEnabled,
    int? createdAt,
    int? updatedAt,
  }) => RecurringPayment(
    id: id ?? this.id,
    title: title ?? this.title,
    categoryId: categoryId ?? this.categoryId,
    amountMinorSuggested: amountMinorSuggested ?? this.amountMinorSuggested,
    currencyCode: currencyCode ?? this.currencyCode,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    endMonthKey: endMonthKey.present ? endMonthKey.value : this.endMonthKey,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RecurringPayment copyWithCompanion(RecurringPaymentsCompanion data) {
    return RecurringPayment(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountMinorSuggested: data.amountMinorSuggested.present
          ? data.amountMinorSuggested.value
          : this.amountMinorSuggested,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      endMonthKey: data.endMonthKey.present
          ? data.endMonthKey.value
          : this.endMonthKey,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPayment(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinorSuggested: $amountMinorSuggested, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('endMonthKey: $endMonthKey, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    categoryId,
    amountMinorSuggested,
    currencyCode,
    dayOfMonth,
    endMonthKey,
    isEnabled,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringPayment &&
          other.id == this.id &&
          other.title == this.title &&
          other.categoryId == this.categoryId &&
          other.amountMinorSuggested == this.amountMinorSuggested &&
          other.currencyCode == this.currencyCode &&
          other.dayOfMonth == this.dayOfMonth &&
          other.endMonthKey == this.endMonthKey &&
          other.isEnabled == this.isEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringPaymentsCompanion extends UpdateCompanion<RecurringPayment> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> categoryId;
  final Value<int> amountMinorSuggested;
  final Value<String> currencyCode;
  final Value<int> dayOfMonth;
  final Value<String?> endMonthKey;
  final Value<bool> isEnabled;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RecurringPaymentsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinorSuggested = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.endMonthKey = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringPaymentsCompanion.insert({
    required String id,
    required String title,
    required String categoryId,
    required int amountMinorSuggested,
    required String currencyCode,
    required int dayOfMonth,
    this.endMonthKey = const Value.absent(),
    this.isEnabled = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       categoryId = Value(categoryId),
       amountMinorSuggested = Value(amountMinorSuggested),
       currencyCode = Value(currencyCode),
       dayOfMonth = Value(dayOfMonth),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecurringPayment> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? categoryId,
    Expression<int>? amountMinorSuggested,
    Expression<String>? currencyCode,
    Expression<int>? dayOfMonth,
    Expression<String>? endMonthKey,
    Expression<bool>? isEnabled,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinorSuggested != null)
        'amount_minor_suggested': amountMinorSuggested,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (endMonthKey != null) 'end_month_key': endMonthKey,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? categoryId,
    Value<int>? amountMinorSuggested,
    Value<String>? currencyCode,
    Value<int>? dayOfMonth,
    Value<String?>? endMonthKey,
    Value<bool>? isEnabled,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return RecurringPaymentsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      amountMinorSuggested: amountMinorSuggested ?? this.amountMinorSuggested,
      currencyCode: currencyCode ?? this.currencyCode,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      endMonthKey: endMonthKey ?? this.endMonthKey,
      isEnabled: isEnabled ?? this.isEnabled,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountMinorSuggested.present) {
      map['amount_minor_suggested'] = Variable<int>(amountMinorSuggested.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (endMonthKey.present) {
      map['end_month_key'] = Variable<String>(endMonthKey.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
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
    return (StringBuffer('RecurringPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinorSuggested: $amountMinorSuggested, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('endMonthKey: $endMonthKey, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetBucketMeta = const VerificationMeta(
    'budgetBucket',
  );
  @override
  late final GeneratedColumn<String> budgetBucket = GeneratedColumn<String>(
    'budget_bucket',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
    'created_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id)',
    ),
  );
  static const VerificationMeta _recurringPaymentIdMeta =
      const VerificationMeta('recurringPaymentId');
  @override
  late final GeneratedColumn<String> recurringPaymentId =
      GeneratedColumn<String>(
        'recurring_payment_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_payments (id)',
        ),
      );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountMinor,
    currencyCode,
    categoryId,
    budgetBucket,
    note,
    occurredAt,
    createdAt,
    updatedAt,
    createdByUserId,
    recurringPaymentId,
    remoteId,
    syncStatus,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('budget_bucket')) {
      context.handle(
        _budgetBucketMeta,
        budgetBucket.isAcceptableOrUnknown(
          data['budget_bucket']!,
          _budgetBucketMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
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
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByUserIdMeta);
    }
    if (data.containsKey('recurring_payment_id')) {
      context.handle(
        _recurringPaymentIdMeta,
        recurringPaymentId.isAcceptableOrUnknown(
          data['recurring_payment_id']!,
          _recurringPaymentIdMeta,
        ),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      budgetBucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_bucket'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_user_id'],
      )!,
      recurringPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_payment_id'],
      ),
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final int amountMinor;
  final String currencyCode;
  final String categoryId;
  final String? budgetBucket;
  final String? note;
  final int occurredAt;
  final int createdAt;
  final int updatedAt;
  final String createdByUserId;
  final String? recurringPaymentId;
  final String? remoteId;
  final String? syncStatus;
  final int? serverUpdatedAt;
  const Expense({
    required this.id,
    required this.amountMinor,
    required this.currencyCode,
    required this.categoryId,
    this.budgetBucket,
    this.note,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByUserId,
    this.recurringPaymentId,
    this.remoteId,
    this.syncStatus,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || budgetBucket != null) {
      map['budget_bucket'] = Variable<String>(budgetBucket);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['occurred_at'] = Variable<int>(occurredAt);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['created_by_user_id'] = Variable<String>(createdByUserId);
    if (!nullToAbsent || recurringPaymentId != null) {
      map['recurring_payment_id'] = Variable<String>(recurringPaymentId);
    }
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      categoryId: Value(categoryId),
      budgetBucket: budgetBucket == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetBucket),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      occurredAt: Value(occurredAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      createdByUserId: Value(createdByUserId),
      recurringPaymentId: recurringPaymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringPaymentId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      budgetBucket: serializer.fromJson<String?>(json['budgetBucket']),
      note: serializer.fromJson<String?>(json['note']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      createdByUserId: serializer.fromJson<String>(json['createdByUserId']),
      recurringPaymentId: serializer.fromJson<String?>(
        json['recurringPaymentId'],
      ),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'categoryId': serializer.toJson<String>(categoryId),
      'budgetBucket': serializer.toJson<String?>(budgetBucket),
      'note': serializer.toJson<String?>(note),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'createdByUserId': serializer.toJson<String>(createdByUserId),
      'recurringPaymentId': serializer.toJson<String?>(recurringPaymentId),
      'remoteId': serializer.toJson<String?>(remoteId),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  Expense copyWith({
    String? id,
    int? amountMinor,
    String? currencyCode,
    String? categoryId,
    Value<String?> budgetBucket = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? occurredAt,
    int? createdAt,
    int? updatedAt,
    String? createdByUserId,
    Value<String?> recurringPaymentId = const Value.absent(),
    Value<String?> remoteId = const Value.absent(),
    Value<String?> syncStatus = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => Expense(
    id: id ?? this.id,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    categoryId: categoryId ?? this.categoryId,
    budgetBucket: budgetBucket.present ? budgetBucket.value : this.budgetBucket,
    note: note.present ? note.value : this.note,
    occurredAt: occurredAt ?? this.occurredAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    createdByUserId: createdByUserId ?? this.createdByUserId,
    recurringPaymentId: recurringPaymentId.present
        ? recurringPaymentId.value
        : this.recurringPaymentId,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      budgetBucket: data.budgetBucket.present
          ? data.budgetBucket.value
          : this.budgetBucket,
      note: data.note.present ? data.note.value : this.note,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      recurringPaymentId: data.recurringPaymentId.present
          ? data.recurringPaymentId.value
          : this.recurringPaymentId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryId: $categoryId, ')
          ..write('budgetBucket: $budgetBucket, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('recurringPaymentId: $recurringPaymentId, ')
          ..write('remoteId: $remoteId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountMinor,
    currencyCode,
    categoryId,
    budgetBucket,
    note,
    occurredAt,
    createdAt,
    updatedAt,
    createdByUserId,
    recurringPaymentId,
    remoteId,
    syncStatus,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.categoryId == this.categoryId &&
          other.budgetBucket == this.budgetBucket &&
          other.note == this.note &&
          other.occurredAt == this.occurredAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.createdByUserId == this.createdByUserId &&
          other.recurringPaymentId == this.recurringPaymentId &&
          other.remoteId == this.remoteId &&
          other.syncStatus == this.syncStatus &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String> categoryId;
  final Value<String?> budgetBucket;
  final Value<String?> note;
  final Value<int> occurredAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> createdByUserId;
  final Value<String?> recurringPaymentId;
  final Value<String?> remoteId;
  final Value<String?> syncStatus;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.budgetBucket = const Value.absent(),
    this.note = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.recurringPaymentId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required int amountMinor,
    required String currencyCode,
    required String categoryId,
    this.budgetBucket = const Value.absent(),
    this.note = const Value.absent(),
    required int occurredAt,
    required int createdAt,
    required int updatedAt,
    required String createdByUserId,
    this.recurringPaymentId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       categoryId = Value(categoryId),
       occurredAt = Value(occurredAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       createdByUserId = Value(createdByUserId);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? categoryId,
    Expression<String>? budgetBucket,
    Expression<String>? note,
    Expression<int>? occurredAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? createdByUserId,
    Expression<String>? recurringPaymentId,
    Expression<String>? remoteId,
    Expression<String>? syncStatus,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (categoryId != null) 'category_id': categoryId,
      if (budgetBucket != null) 'budget_bucket': budgetBucket,
      if (note != null) 'note': note,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (recurringPaymentId != null)
        'recurring_payment_id': recurringPaymentId,
      if (remoteId != null) 'remote_id': remoteId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String>? categoryId,
    Value<String?>? budgetBucket,
    Value<String?>? note,
    Value<int>? occurredAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String>? createdByUserId,
    Value<String?>? recurringPaymentId,
    Value<String?>? remoteId,
    Value<String?>? syncStatus,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      budgetBucket: budgetBucket ?? this.budgetBucket,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      recurringPaymentId: recurringPaymentId ?? this.recurringPaymentId,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (budgetBucket.present) {
      map['budget_bucket'] = Variable<String>(budgetBucket.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (recurringPaymentId.present) {
      map['recurring_payment_id'] = Variable<String>(recurringPaymentId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryId: $categoryId, ')
          ..write('budgetBucket: $budgetBucket, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('recurringPaymentId: $recurringPaymentId, ')
          ..write('remoteId: $remoteId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringPaymentOccurrencesTable extends RecurringPaymentOccurrences
    with
        TableInfo<
          $RecurringPaymentOccurrencesTable,
          RecurringPaymentOccurrence
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringPaymentOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurringPaymentIdMeta =
      const VerificationMeta('recurringPaymentId');
  @override
  late final GeneratedColumn<String> recurringPaymentId =
      GeneratedColumn<String>(
        'recurring_payment_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_payments (id)',
        ),
      );
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES expenses (id)',
    ),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recurringPaymentId,
    monthKey,
    expenseId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_payment_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringPaymentOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recurring_payment_id')) {
      context.handle(
        _recurringPaymentIdMeta,
        recurringPaymentId.isAcceptableOrUnknown(
          data['recurring_payment_id']!,
          _recurringPaymentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recurringPaymentIdMeta);
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringPaymentOccurrence map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringPaymentOccurrence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recurringPaymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_payment_id'],
      )!,
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecurringPaymentOccurrencesTable createAlias(String alias) {
    return $RecurringPaymentOccurrencesTable(attachedDatabase, alias);
  }
}

class RecurringPaymentOccurrence extends DataClass
    implements Insertable<RecurringPaymentOccurrence> {
  final String id;
  final String recurringPaymentId;
  final String monthKey;
  final String? expenseId;
  final int createdAt;
  const RecurringPaymentOccurrence({
    required this.id,
    required this.recurringPaymentId,
    required this.monthKey,
    this.expenseId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recurring_payment_id'] = Variable<String>(recurringPaymentId);
    map['month_key'] = Variable<String>(monthKey);
    if (!nullToAbsent || expenseId != null) {
      map['expense_id'] = Variable<String>(expenseId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  RecurringPaymentOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return RecurringPaymentOccurrencesCompanion(
      id: Value(id),
      recurringPaymentId: Value(recurringPaymentId),
      monthKey: Value(monthKey),
      expenseId: expenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseId),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringPaymentOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringPaymentOccurrence(
      id: serializer.fromJson<String>(json['id']),
      recurringPaymentId: serializer.fromJson<String>(
        json['recurringPaymentId'],
      ),
      monthKey: serializer.fromJson<String>(json['monthKey']),
      expenseId: serializer.fromJson<String?>(json['expenseId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recurringPaymentId': serializer.toJson<String>(recurringPaymentId),
      'monthKey': serializer.toJson<String>(monthKey),
      'expenseId': serializer.toJson<String?>(expenseId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  RecurringPaymentOccurrence copyWith({
    String? id,
    String? recurringPaymentId,
    String? monthKey,
    Value<String?> expenseId = const Value.absent(),
    int? createdAt,
  }) => RecurringPaymentOccurrence(
    id: id ?? this.id,
    recurringPaymentId: recurringPaymentId ?? this.recurringPaymentId,
    monthKey: monthKey ?? this.monthKey,
    expenseId: expenseId.present ? expenseId.value : this.expenseId,
    createdAt: createdAt ?? this.createdAt,
  );
  RecurringPaymentOccurrence copyWithCompanion(
    RecurringPaymentOccurrencesCompanion data,
  ) {
    return RecurringPaymentOccurrence(
      id: data.id.present ? data.id.value : this.id,
      recurringPaymentId: data.recurringPaymentId.present
          ? data.recurringPaymentId.value
          : this.recurringPaymentId,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPaymentOccurrence(')
          ..write('id: $id, ')
          ..write('recurringPaymentId: $recurringPaymentId, ')
          ..write('monthKey: $monthKey, ')
          ..write('expenseId: $expenseId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recurringPaymentId, monthKey, expenseId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringPaymentOccurrence &&
          other.id == this.id &&
          other.recurringPaymentId == this.recurringPaymentId &&
          other.monthKey == this.monthKey &&
          other.expenseId == this.expenseId &&
          other.createdAt == this.createdAt);
}

class RecurringPaymentOccurrencesCompanion
    extends UpdateCompanion<RecurringPaymentOccurrence> {
  final Value<String> id;
  final Value<String> recurringPaymentId;
  final Value<String> monthKey;
  final Value<String?> expenseId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const RecurringPaymentOccurrencesCompanion({
    this.id = const Value.absent(),
    this.recurringPaymentId = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringPaymentOccurrencesCompanion.insert({
    required String id,
    required String recurringPaymentId,
    required String monthKey,
    this.expenseId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recurringPaymentId = Value(recurringPaymentId),
       monthKey = Value(monthKey),
       createdAt = Value(createdAt);
  static Insertable<RecurringPaymentOccurrence> custom({
    Expression<String>? id,
    Expression<String>? recurringPaymentId,
    Expression<String>? monthKey,
    Expression<String>? expenseId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recurringPaymentId != null)
        'recurring_payment_id': recurringPaymentId,
      if (monthKey != null) 'month_key': monthKey,
      if (expenseId != null) 'expense_id': expenseId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringPaymentOccurrencesCompanion copyWith({
    Value<String>? id,
    Value<String>? recurringPaymentId,
    Value<String>? monthKey,
    Value<String?>? expenseId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return RecurringPaymentOccurrencesCompanion(
      id: id ?? this.id,
      recurringPaymentId: recurringPaymentId ?? this.recurringPaymentId,
      monthKey: monthKey ?? this.monthKey,
      expenseId: expenseId ?? this.expenseId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recurringPaymentId.present) {
      map['recurring_payment_id'] = Variable<String>(recurringPaymentId.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPaymentOccurrencesCompanion(')
          ..write('id: $id, ')
          ..write('recurringPaymentId: $recurringPaymentId, ')
          ..write('monthKey: $monthKey, ')
          ..write('expenseId: $expenseId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseLimitPreferencesTable extends ExpenseLimitPreferences
    with TableInfo<$ExpenseLimitPreferencesTable, ExpenseLimitPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseLimitPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id)',
    ),
  );
  static const VerificationMeta _monthlyIncomeMinorMeta =
      const VerificationMeta('monthlyIncomeMinor');
  @override
  late final GeneratedColumn<int> monthlyIncomeMinor = GeneratedColumn<int>(
    'monthly_income_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlySavingsMinorMeta =
      const VerificationMeta('monthlySavingsMinor');
  @override
  late final GeneratedColumn<int> monthlySavingsMinor = GeneratedColumn<int>(
    'monthly_savings_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _excludeUnpaidRecurringMeta =
      const VerificationMeta('excludeUnpaidRecurring');
  @override
  late final GeneratedColumn<bool> excludeUnpaidRecurring =
      GeneratedColumn<bool>(
        'exclude_unpaid_recurring',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("exclude_unpaid_recurring" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    monthlyIncomeMinor,
    monthlySavingsMinor,
    excludeUnpaidRecurring,
    updatedAt,
    remoteId,
    syncStatus,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_limit_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseLimitPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('monthly_income_minor')) {
      context.handle(
        _monthlyIncomeMinorMeta,
        monthlyIncomeMinor.isAcceptableOrUnknown(
          data['monthly_income_minor']!,
          _monthlyIncomeMinorMeta,
        ),
      );
    }
    if (data.containsKey('monthly_savings_minor')) {
      context.handle(
        _monthlySavingsMinorMeta,
        monthlySavingsMinor.isAcceptableOrUnknown(
          data['monthly_savings_minor']!,
          _monthlySavingsMinorMeta,
        ),
      );
    }
    if (data.containsKey('exclude_unpaid_recurring')) {
      context.handle(
        _excludeUnpaidRecurringMeta,
        excludeUnpaidRecurring.isAcceptableOrUnknown(
          data['exclude_unpaid_recurring']!,
          _excludeUnpaidRecurringMeta,
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
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ExpenseLimitPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseLimitPreference(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      monthlyIncomeMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_income_minor'],
      ),
      monthlySavingsMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_savings_minor'],
      ),
      excludeUnpaidRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exclude_unpaid_recurring'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $ExpenseLimitPreferencesTable createAlias(String alias) {
    return $ExpenseLimitPreferencesTable(attachedDatabase, alias);
  }
}

class ExpenseLimitPreference extends DataClass
    implements Insertable<ExpenseLimitPreference> {
  final String userId;
  final int? monthlyIncomeMinor;
  final int? monthlySavingsMinor;
  final bool excludeUnpaidRecurring;
  final int updatedAt;
  final String? remoteId;
  final String? syncStatus;
  final int? serverUpdatedAt;
  const ExpenseLimitPreference({
    required this.userId,
    this.monthlyIncomeMinor,
    this.monthlySavingsMinor,
    required this.excludeUnpaidRecurring,
    required this.updatedAt,
    this.remoteId,
    this.syncStatus,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || monthlyIncomeMinor != null) {
      map['monthly_income_minor'] = Variable<int>(monthlyIncomeMinor);
    }
    if (!nullToAbsent || monthlySavingsMinor != null) {
      map['monthly_savings_minor'] = Variable<int>(monthlySavingsMinor);
    }
    map['exclude_unpaid_recurring'] = Variable<bool>(excludeUnpaidRecurring);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    if (!nullToAbsent || syncStatus != null) {
      map['sync_status'] = Variable<String>(syncStatus);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  ExpenseLimitPreferencesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseLimitPreferencesCompanion(
      userId: Value(userId),
      monthlyIncomeMinor: monthlyIncomeMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyIncomeMinor),
      monthlySavingsMinor: monthlySavingsMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlySavingsMinor),
      excludeUnpaidRecurring: Value(excludeUnpaidRecurring),
      updatedAt: Value(updatedAt),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      syncStatus: syncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(syncStatus),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory ExpenseLimitPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseLimitPreference(
      userId: serializer.fromJson<String>(json['userId']),
      monthlyIncomeMinor: serializer.fromJson<int?>(json['monthlyIncomeMinor']),
      monthlySavingsMinor: serializer.fromJson<int?>(
        json['monthlySavingsMinor'],
      ),
      excludeUnpaidRecurring: serializer.fromJson<bool>(
        json['excludeUnpaidRecurring'],
      ),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      syncStatus: serializer.fromJson<String?>(json['syncStatus']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'monthlyIncomeMinor': serializer.toJson<int?>(monthlyIncomeMinor),
      'monthlySavingsMinor': serializer.toJson<int?>(monthlySavingsMinor),
      'excludeUnpaidRecurring': serializer.toJson<bool>(excludeUnpaidRecurring),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'remoteId': serializer.toJson<String?>(remoteId),
      'syncStatus': serializer.toJson<String?>(syncStatus),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  ExpenseLimitPreference copyWith({
    String? userId,
    Value<int?> monthlyIncomeMinor = const Value.absent(),
    Value<int?> monthlySavingsMinor = const Value.absent(),
    bool? excludeUnpaidRecurring,
    int? updatedAt,
    Value<String?> remoteId = const Value.absent(),
    Value<String?> syncStatus = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => ExpenseLimitPreference(
    userId: userId ?? this.userId,
    monthlyIncomeMinor: monthlyIncomeMinor.present
        ? monthlyIncomeMinor.value
        : this.monthlyIncomeMinor,
    monthlySavingsMinor: monthlySavingsMinor.present
        ? monthlySavingsMinor.value
        : this.monthlySavingsMinor,
    excludeUnpaidRecurring:
        excludeUnpaidRecurring ?? this.excludeUnpaidRecurring,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    syncStatus: syncStatus.present ? syncStatus.value : this.syncStatus,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  ExpenseLimitPreference copyWithCompanion(
    ExpenseLimitPreferencesCompanion data,
  ) {
    return ExpenseLimitPreference(
      userId: data.userId.present ? data.userId.value : this.userId,
      monthlyIncomeMinor: data.monthlyIncomeMinor.present
          ? data.monthlyIncomeMinor.value
          : this.monthlyIncomeMinor,
      monthlySavingsMinor: data.monthlySavingsMinor.present
          ? data.monthlySavingsMinor.value
          : this.monthlySavingsMinor,
      excludeUnpaidRecurring: data.excludeUnpaidRecurring.present
          ? data.excludeUnpaidRecurring.value
          : this.excludeUnpaidRecurring,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseLimitPreference(')
          ..write('userId: $userId, ')
          ..write('monthlyIncomeMinor: $monthlyIncomeMinor, ')
          ..write('monthlySavingsMinor: $monthlySavingsMinor, ')
          ..write('excludeUnpaidRecurring: $excludeUnpaidRecurring, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    monthlyIncomeMinor,
    monthlySavingsMinor,
    excludeUnpaidRecurring,
    updatedAt,
    remoteId,
    syncStatus,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseLimitPreference &&
          other.userId == this.userId &&
          other.monthlyIncomeMinor == this.monthlyIncomeMinor &&
          other.monthlySavingsMinor == this.monthlySavingsMinor &&
          other.excludeUnpaidRecurring == this.excludeUnpaidRecurring &&
          other.updatedAt == this.updatedAt &&
          other.remoteId == this.remoteId &&
          other.syncStatus == this.syncStatus &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class ExpenseLimitPreferencesCompanion
    extends UpdateCompanion<ExpenseLimitPreference> {
  final Value<String> userId;
  final Value<int?> monthlyIncomeMinor;
  final Value<int?> monthlySavingsMinor;
  final Value<bool> excludeUnpaidRecurring;
  final Value<int> updatedAt;
  final Value<String?> remoteId;
  final Value<String?> syncStatus;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const ExpenseLimitPreferencesCompanion({
    this.userId = const Value.absent(),
    this.monthlyIncomeMinor = const Value.absent(),
    this.monthlySavingsMinor = const Value.absent(),
    this.excludeUnpaidRecurring = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseLimitPreferencesCompanion.insert({
    required String userId,
    this.monthlyIncomeMinor = const Value.absent(),
    this.monthlySavingsMinor = const Value.absent(),
    this.excludeUnpaidRecurring = const Value.absent(),
    required int updatedAt,
    this.remoteId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseLimitPreference> custom({
    Expression<String>? userId,
    Expression<int>? monthlyIncomeMinor,
    Expression<int>? monthlySavingsMinor,
    Expression<bool>? excludeUnpaidRecurring,
    Expression<int>? updatedAt,
    Expression<String>? remoteId,
    Expression<String>? syncStatus,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (monthlyIncomeMinor != null)
        'monthly_income_minor': monthlyIncomeMinor,
      if (monthlySavingsMinor != null)
        'monthly_savings_minor': monthlySavingsMinor,
      if (excludeUnpaidRecurring != null)
        'exclude_unpaid_recurring': excludeUnpaidRecurring,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteId != null) 'remote_id': remoteId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseLimitPreferencesCompanion copyWith({
    Value<String>? userId,
    Value<int?>? monthlyIncomeMinor,
    Value<int?>? monthlySavingsMinor,
    Value<bool>? excludeUnpaidRecurring,
    Value<int>? updatedAt,
    Value<String?>? remoteId,
    Value<String?>? syncStatus,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return ExpenseLimitPreferencesCompanion(
      userId: userId ?? this.userId,
      monthlyIncomeMinor: monthlyIncomeMinor ?? this.monthlyIncomeMinor,
      monthlySavingsMinor: monthlySavingsMinor ?? this.monthlySavingsMinor,
      excludeUnpaidRecurring:
          excludeUnpaidRecurring ?? this.excludeUnpaidRecurring,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (monthlyIncomeMinor.present) {
      map['monthly_income_minor'] = Variable<int>(monthlyIncomeMinor.value);
    }
    if (monthlySavingsMinor.present) {
      map['monthly_savings_minor'] = Variable<int>(monthlySavingsMinor.value);
    }
    if (excludeUnpaidRecurring.present) {
      map['exclude_unpaid_recurring'] = Variable<bool>(
        excludeUnpaidRecurring.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseLimitPreferencesCompanion(')
          ..write('userId: $userId, ')
          ..write('monthlyIncomeMinor: $monthlyIncomeMinor, ')
          ..write('monthlySavingsMinor: $monthlySavingsMinor, ')
          ..write('excludeUnpaidRecurring: $excludeUnpaidRecurring, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteId: $remoteId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id)',
    ),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _numberFormatMeta = const VerificationMeta(
    'numberFormat',
  );
  @override
  late final GeneratedColumn<String> numberFormat = GeneratedColumn<String>(
    'number_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('us'),
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
    userId,
    currencyCode,
    languageCode,
    numberFormat,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('number_format')) {
      context.handle(
        _numberFormatMeta,
        numberFormat.isAcceptableOrUnknown(
          data['number_format']!,
          _numberFormatMeta,
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
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      numberFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number_format'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final String userId;
  final String currencyCode;
  final String languageCode;
  final String numberFormat;
  final int updatedAt;
  const UserPreference({
    required this.userId,
    required this.currencyCode,
    required this.languageCode,
    required this.numberFormat,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['currency_code'] = Variable<String>(currencyCode);
    map['language_code'] = Variable<String>(languageCode);
    map['number_format'] = Variable<String>(numberFormat);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      userId: Value(userId),
      currencyCode: Value(currencyCode),
      languageCode: Value(languageCode),
      numberFormat: Value(numberFormat),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      userId: serializer.fromJson<String>(json['userId']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      numberFormat: serializer.fromJson<String>(json['numberFormat']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'languageCode': serializer.toJson<String>(languageCode),
      'numberFormat': serializer.toJson<String>(numberFormat),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  UserPreference copyWith({
    String? userId,
    String? currencyCode,
    String? languageCode,
    String? numberFormat,
    int? updatedAt,
  }) => UserPreference(
    userId: userId ?? this.userId,
    currencyCode: currencyCode ?? this.currencyCode,
    languageCode: languageCode ?? this.languageCode,
    numberFormat: numberFormat ?? this.numberFormat,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      userId: data.userId.present ? data.userId.value : this.userId,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      numberFormat: data.numberFormat.present
          ? data.numberFormat.value
          : this.numberFormat,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('userId: $userId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('languageCode: $languageCode, ')
          ..write('numberFormat: $numberFormat, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, currencyCode, languageCode, numberFormat, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.userId == this.userId &&
          other.currencyCode == this.currencyCode &&
          other.languageCode == this.languageCode &&
          other.numberFormat == this.numberFormat &&
          other.updatedAt == this.updatedAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<String> userId;
  final Value<String> currencyCode;
  final Value<String> languageCode;
  final Value<String> numberFormat;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const UserPreferencesCompanion({
    this.userId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.numberFormat = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    required String userId,
    this.currencyCode = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.numberFormat = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<UserPreference> custom({
    Expression<String>? userId,
    Expression<String>? currencyCode,
    Expression<String>? languageCode,
    Expression<String>? numberFormat,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (languageCode != null) 'language_code': languageCode,
      if (numberFormat != null) 'number_format': numberFormat,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<String>? userId,
    Value<String>? currencyCode,
    Value<String>? languageCode,
    Value<String>? numberFormat,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserPreferencesCompanion(
      userId: userId ?? this.userId,
      currencyCode: currencyCode ?? this.currencyCode,
      languageCode: languageCode ?? this.languageCode,
      numberFormat: numberFormat ?? this.numberFormat,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (numberFormat.present) {
      map['number_format'] = Variable<String>(numberFormat.value);
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
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('userId: $userId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('languageCode: $languageCode, ')
          ..write('numberFormat: $numberFormat, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    label,
    bucket,
    isBuiltIn,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
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
  ExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
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
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategory extends DataClass implements Insertable<ExpenseCategory> {
  final String id;
  final String label;
  final String bucket;
  final bool isBuiltIn;
  final int createdAt;
  final int updatedAt;
  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.bucket,
    required this.isBuiltIn,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['bucket'] = Variable<String>(bucket);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      label: Value(label),
      bucket: Value(bucket),
      isBuiltIn: Value(isBuiltIn),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExpenseCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategory(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      bucket: serializer.fromJson<String>(json['bucket']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'bucket': serializer.toJson<String>(bucket),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ExpenseCategory copyWith({
    String? id,
    String? label,
    String? bucket,
    bool? isBuiltIn,
    int? createdAt,
    int? updatedAt,
  }) => ExpenseCategory(
    id: id ?? this.id,
    label: label ?? this.label,
    bucket: bucket ?? this.bucket,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExpenseCategory copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategory(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('bucket: $bucket, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, label, bucket, isBuiltIn, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategory &&
          other.id == this.id &&
          other.label == this.label &&
          other.bucket == this.bucket &&
          other.isBuiltIn == this.isBuiltIn &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategory> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> bucket;
  final Value<bool> isBuiltIn;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.bucket = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    required String id,
    required String label,
    required String bucket,
    this.isBuiltIn = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       bucket = Value(bucket),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseCategory> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? bucket,
    Expression<bool>? isBuiltIn,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (bucket != null) 'bucket': bucket,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? bucket,
    Value<bool>? isBuiltIn,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      bucket: bucket ?? this.bucket,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
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
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
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
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('bucket: $bucket, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $RecurringPaymentsTable recurringPayments =
      $RecurringPaymentsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $RecurringPaymentOccurrencesTable recurringPaymentOccurrences =
      $RecurringPaymentOccurrencesTable(this);
  late final $ExpenseLimitPreferencesTable expenseLimitPreferences =
      $ExpenseLimitPreferencesTable(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final Index expensesOccurredAt = Index(
    'expenses_occurred_at',
    'CREATE INDEX expenses_occurred_at ON expenses (occurred_at)',
  );
  late final Index expensesCategoryOccurred = Index(
    'expenses_category_occurred',
    'CREATE INDEX expenses_category_occurred ON expenses (category_id, occurred_at)',
  );
  late final Index expensesCreatedBy = Index(
    'expenses_created_by',
    'CREATE INDEX expenses_created_by ON expenses (created_by_user_id)',
  );
  late final Index idxRpOccurrenceUnique = Index(
    'idx_rp_occurrence_unique',
    'CREATE UNIQUE INDEX idx_rp_occurrence_unique ON recurring_payment_occurrences (recurring_payment_id, month_key)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    recurringPayments,
    expenses,
    recurringPaymentOccurrences,
    expenseLimitPreferences,
    userPreferences,
    expenseCategories,
    expensesOccurredAt,
    expensesCategoryOccurred,
    expensesCreatedBy,
    idxRpOccurrenceUnique,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String displayName,
      required int createdAt,
      required int updatedAt,
      Value<String?> remoteId,
      Value<String?> syncStatus,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> remoteId,
      Value<String?> syncStatus,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(
      db.userProfiles.id,
      db.expenses.createdByUserId,
    ),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
      (f) => f.createdByUserId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExpenseLimitPreferencesTable,
    List<ExpenseLimitPreference>
  >
  _expenseLimitPreferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.expenseLimitPreferences,
        aliasName: $_aliasNameGenerator(
          db.userProfiles.id,
          db.expenseLimitPreferences.userId,
        ),
      );

  $$ExpenseLimitPreferencesTableProcessedTableManager
  get expenseLimitPreferencesRefs {
    final manager = $$ExpenseLimitPreferencesTableTableManager(
      $_db,
      $_db.expenseLimitPreferences,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _expenseLimitPreferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserPreferencesTable, List<UserPreference>>
  _userPreferencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userPreferences,
    aliasName: $_aliasNameGenerator(
      db.userProfiles.id,
      db.userPreferences.userId,
    ),
  );

  $$UserPreferencesTableProcessedTableManager get userPreferencesRefs {
    final manager = $$UserPreferencesTableTableManager(
      $_db,
      $_db.userPreferences,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userPreferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.createdByUserId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expenseLimitPreferencesRefs(
    Expression<bool> Function($$ExpenseLimitPreferencesTableFilterComposer f) f,
  ) {
    final $$ExpenseLimitPreferencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.expenseLimitPreferences,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseLimitPreferencesTableFilterComposer(
                $db: $db,
                $table: $db.expenseLimitPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> userPreferencesRefs(
    Expression<bool> Function($$UserPreferencesTableFilterComposer f) f,
  ) {
    final $$UserPreferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPreferences,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPreferencesTableFilterComposer(
            $db: $db,
            $table: $db.userPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.createdByUserId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expenseLimitPreferencesRefs<T extends Object>(
    Expression<T> Function($$ExpenseLimitPreferencesTableAnnotationComposer a)
    f,
  ) {
    final $$ExpenseLimitPreferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.expenseLimitPreferences,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseLimitPreferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseLimitPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> userPreferencesRefs<T extends Object>(
    Expression<T> Function($$UserPreferencesTableAnnotationComposer a) f,
  ) {
    final $$UserPreferencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPreferences,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPreferencesTableAnnotationComposer(
            $db: $db,
            $table: $db.userPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfile, $$UserProfilesTableReferences),
          UserProfile,
          PrefetchHooks Function({
            bool expensesRefs,
            bool expenseLimitPreferencesRefs,
            bool userPreferencesRefs,
          })
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                syncStatus: syncStatus,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required int createdAt,
                required int updatedAt,
                Value<String?> remoteId = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                remoteId: remoteId,
                syncStatus: syncStatus,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                expensesRefs = false,
                expenseLimitPreferencesRefs = false,
                userPreferencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expensesRefs) db.expenses,
                    if (expenseLimitPreferencesRefs) db.expenseLimitPreferences,
                    if (userPreferencesRefs) db.userPreferences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.createdByUserId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expenseLimitPreferencesRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          ExpenseLimitPreference
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._expenseLimitPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).expenseLimitPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userPreferencesRefs)
                        await $_getPrefetchedData<
                          UserProfile,
                          $UserProfilesTable,
                          UserPreference
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._userPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).userPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
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

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfile, $$UserProfilesTableReferences),
      UserProfile,
      PrefetchHooks Function({
        bool expensesRefs,
        bool expenseLimitPreferencesRefs,
        bool userPreferencesRefs,
      })
    >;
typedef $$RecurringPaymentsTableCreateCompanionBuilder =
    RecurringPaymentsCompanion Function({
      required String id,
      required String title,
      required String categoryId,
      required int amountMinorSuggested,
      required String currencyCode,
      required int dayOfMonth,
      Value<String?> endMonthKey,
      Value<bool> isEnabled,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$RecurringPaymentsTableUpdateCompanionBuilder =
    RecurringPaymentsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> categoryId,
      Value<int> amountMinorSuggested,
      Value<String> currencyCode,
      Value<int> dayOfMonth,
      Value<String?> endMonthKey,
      Value<bool> isEnabled,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$RecurringPaymentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringPaymentsTable,
          RecurringPayment
        > {
  $$RecurringPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(
      db.recurringPayments.id,
      db.expenses.recurringPaymentId,
    ),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
      (f) => f.recurringPaymentId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringPaymentOccurrencesTable,
    List<RecurringPaymentOccurrence>
  >
  _recurringPaymentOccurrencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringPaymentOccurrences,
        aliasName: $_aliasNameGenerator(
          db.recurringPayments.id,
          db.recurringPaymentOccurrences.recurringPaymentId,
        ),
      );

  $$RecurringPaymentOccurrencesTableProcessedTableManager
  get recurringPaymentOccurrencesRefs {
    final manager =
        $$RecurringPaymentOccurrencesTableTableManager(
          $_db,
          $_db.recurringPaymentOccurrences,
        ).filter(
          (f) => f.recurringPaymentId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _recurringPaymentOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringPaymentsTable> {
  $$RecurringPaymentsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinorSuggested => $composableBuilder(
    column: $table.amountMinorSuggested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endMonthKey => $composableBuilder(
    column: $table.endMonthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
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

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.recurringPaymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringPaymentOccurrencesRefs(
    Expression<bool> Function(
      $$RecurringPaymentOccurrencesTableFilterComposer f,
    )
    f,
  ) {
    final $$RecurringPaymentOccurrencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringPaymentOccurrences,
          getReferencedColumn: (t) => t.recurringPaymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentOccurrencesTableFilterComposer(
                $db: $db,
                $table: $db.recurringPaymentOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RecurringPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringPaymentsTable> {
  $$RecurringPaymentsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinorSuggested => $composableBuilder(
    column: $table.amountMinorSuggested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endMonthKey => $composableBuilder(
    column: $table.endMonthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
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

class $$RecurringPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringPaymentsTable> {
  $$RecurringPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinorSuggested => $composableBuilder(
    column: $table.amountMinorSuggested,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endMonthKey => $composableBuilder(
    column: $table.endMonthKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.recurringPaymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringPaymentOccurrencesRefs<T extends Object>(
    Expression<T> Function(
      $$RecurringPaymentOccurrencesTableAnnotationComposer a,
    )
    f,
  ) {
    final $$RecurringPaymentOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringPaymentOccurrences,
          getReferencedColumn: (t) => t.recurringPaymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringPaymentOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RecurringPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringPaymentsTable,
          RecurringPayment,
          $$RecurringPaymentsTableFilterComposer,
          $$RecurringPaymentsTableOrderingComposer,
          $$RecurringPaymentsTableAnnotationComposer,
          $$RecurringPaymentsTableCreateCompanionBuilder,
          $$RecurringPaymentsTableUpdateCompanionBuilder,
          (RecurringPayment, $$RecurringPaymentsTableReferences),
          RecurringPayment,
          PrefetchHooks Function({
            bool expensesRefs,
            bool recurringPaymentOccurrencesRefs,
          })
        > {
  $$RecurringPaymentsTableTableManager(
    _$AppDatabase db,
    $RecurringPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringPaymentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> amountMinorSuggested = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<String?> endMonthKey = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringPaymentsCompanion(
                id: id,
                title: title,
                categoryId: categoryId,
                amountMinorSuggested: amountMinorSuggested,
                currencyCode: currencyCode,
                dayOfMonth: dayOfMonth,
                endMonthKey: endMonthKey,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String categoryId,
                required int amountMinorSuggested,
                required String currencyCode,
                required int dayOfMonth,
                Value<String?> endMonthKey = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecurringPaymentsCompanion.insert(
                id: id,
                title: title,
                categoryId: categoryId,
                amountMinorSuggested: amountMinorSuggested,
                currencyCode: currencyCode,
                dayOfMonth: dayOfMonth,
                endMonthKey: endMonthKey,
                isEnabled: isEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                expensesRefs = false,
                recurringPaymentOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expensesRefs) db.expenses,
                    if (recurringPaymentOccurrencesRefs)
                      db.recurringPaymentOccurrences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          RecurringPayment,
                          $RecurringPaymentsTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$RecurringPaymentsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringPaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recurringPaymentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringPaymentOccurrencesRefs)
                        await $_getPrefetchedData<
                          RecurringPayment,
                          $RecurringPaymentsTable,
                          RecurringPaymentOccurrence
                        >(
                          currentTable: table,
                          referencedTable: $$RecurringPaymentsTableReferences
                              ._recurringPaymentOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringPaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringPaymentOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recurringPaymentId == item.id,
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

typedef $$RecurringPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringPaymentsTable,
      RecurringPayment,
      $$RecurringPaymentsTableFilterComposer,
      $$RecurringPaymentsTableOrderingComposer,
      $$RecurringPaymentsTableAnnotationComposer,
      $$RecurringPaymentsTableCreateCompanionBuilder,
      $$RecurringPaymentsTableUpdateCompanionBuilder,
      (RecurringPayment, $$RecurringPaymentsTableReferences),
      RecurringPayment,
      PrefetchHooks Function({
        bool expensesRefs,
        bool recurringPaymentOccurrencesRefs,
      })
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required int amountMinor,
      required String currencyCode,
      required String categoryId,
      Value<String?> budgetBucket,
      Value<String?> note,
      required int occurredAt,
      required int createdAt,
      required int updatedAt,
      required String createdByUserId,
      Value<String?> recurringPaymentId,
      Value<String?> remoteId,
      Value<String?> syncStatus,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String> categoryId,
      Value<String?> budgetBucket,
      Value<String?> note,
      Value<int> occurredAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String> createdByUserId,
      Value<String?> recurringPaymentId,
      Value<String?> remoteId,
      Value<String?> syncStatus,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _createdByUserIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.expenses.createdByUserId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get createdByUserId {
    final $_column = $_itemColumn<String>('created_by_user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_createdByUserIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurringPaymentsTable _recurringPaymentIdTable(_$AppDatabase db) =>
      db.recurringPayments.createAlias(
        $_aliasNameGenerator(
          db.expenses.recurringPaymentId,
          db.recurringPayments.id,
        ),
      );

  $$RecurringPaymentsTableProcessedTableManager? get recurringPaymentId {
    final $_column = $_itemColumn<String>('recurring_payment_id');
    if ($_column == null) return null;
    final manager = $$RecurringPaymentsTableTableManager(
      $_db,
      $_db.recurringPayments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringPaymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $RecurringPaymentOccurrencesTable,
    List<RecurringPaymentOccurrence>
  >
  _recurringPaymentOccurrencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringPaymentOccurrences,
        aliasName: $_aliasNameGenerator(
          db.expenses.id,
          db.recurringPaymentOccurrences.expenseId,
        ),
      );

  $$RecurringPaymentOccurrencesTableProcessedTableManager
  get recurringPaymentOccurrencesRefs {
    final manager = $$RecurringPaymentOccurrencesTableTableManager(
      $_db,
      $_db.recurringPaymentOccurrences,
    ).filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringPaymentOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetBucket => $composableBuilder(
    column: $table.budgetBucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get createdByUserId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByUserId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringPaymentsTableFilterComposer get recurringPaymentId {
    final $$RecurringPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPaymentId,
      referencedTable: $db.recurringPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.recurringPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> recurringPaymentOccurrencesRefs(
    Expression<bool> Function(
      $$RecurringPaymentOccurrencesTableFilterComposer f,
    )
    f,
  ) {
    final $$RecurringPaymentOccurrencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringPaymentOccurrences,
          getReferencedColumn: (t) => t.expenseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentOccurrencesTableFilterComposer(
                $db: $db,
                $table: $db.recurringPaymentOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetBucket => $composableBuilder(
    column: $table.budgetBucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get createdByUserId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByUserId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringPaymentsTableOrderingComposer get recurringPaymentId {
    final $$RecurringPaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPaymentId,
      referencedTable: $db.recurringPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.recurringPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get budgetBucket => $composableBuilder(
    column: $table.budgetBucket,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  $$UserProfilesTableAnnotationComposer get createdByUserId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.createdByUserId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringPaymentsTableAnnotationComposer get recurringPaymentId {
    final $$RecurringPaymentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringPaymentId,
          referencedTable: $db.recurringPayments,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringPayments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> recurringPaymentOccurrencesRefs<T extends Object>(
    Expression<T> Function(
      $$RecurringPaymentOccurrencesTableAnnotationComposer a,
    )
    f,
  ) {
    final $$RecurringPaymentOccurrencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringPaymentOccurrences,
          getReferencedColumn: (t) => t.expenseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentOccurrencesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringPaymentOccurrences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({
            bool createdByUserId,
            bool recurringPaymentId,
            bool recurringPaymentOccurrencesRefs,
          })
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> budgetBucket = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String> createdByUserId = const Value.absent(),
                Value<String?> recurringPaymentId = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                categoryId: categoryId,
                budgetBucket: budgetBucket,
                note: note,
                occurredAt: occurredAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                createdByUserId: createdByUserId,
                recurringPaymentId: recurringPaymentId,
                remoteId: remoteId,
                syncStatus: syncStatus,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountMinor,
                required String currencyCode,
                required String categoryId,
                Value<String?> budgetBucket = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int occurredAt,
                required int createdAt,
                required int updatedAt,
                required String createdByUserId,
                Value<String?> recurringPaymentId = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                categoryId: categoryId,
                budgetBucket: budgetBucket,
                note: note,
                occurredAt: occurredAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                createdByUserId: createdByUserId,
                recurringPaymentId: recurringPaymentId,
                remoteId: remoteId,
                syncStatus: syncStatus,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                createdByUserId = false,
                recurringPaymentId = false,
                recurringPaymentOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recurringPaymentOccurrencesRefs)
                      db.recurringPaymentOccurrences,
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
                        if (createdByUserId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.createdByUserId,
                                    referencedTable: $$ExpensesTableReferences
                                        ._createdByUserIdTable(db),
                                    referencedColumn: $$ExpensesTableReferences
                                        ._createdByUserIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (recurringPaymentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recurringPaymentId,
                                    referencedTable: $$ExpensesTableReferences
                                        ._recurringPaymentIdTable(db),
                                    referencedColumn: $$ExpensesTableReferences
                                        ._recurringPaymentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recurringPaymentOccurrencesRefs)
                        await $_getPrefetchedData<
                          Expense,
                          $ExpensesTable,
                          RecurringPaymentOccurrence
                        >(
                          currentTable: table,
                          referencedTable: $$ExpensesTableReferences
                              ._recurringPaymentOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpensesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringPaymentOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.expenseId == item.id,
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

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({
        bool createdByUserId,
        bool recurringPaymentId,
        bool recurringPaymentOccurrencesRefs,
      })
    >;
typedef $$RecurringPaymentOccurrencesTableCreateCompanionBuilder =
    RecurringPaymentOccurrencesCompanion Function({
      required String id,
      required String recurringPaymentId,
      required String monthKey,
      Value<String?> expenseId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$RecurringPaymentOccurrencesTableUpdateCompanionBuilder =
    RecurringPaymentOccurrencesCompanion Function({
      Value<String> id,
      Value<String> recurringPaymentId,
      Value<String> monthKey,
      Value<String?> expenseId,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$RecurringPaymentOccurrencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringPaymentOccurrencesTable,
          RecurringPaymentOccurrence
        > {
  $$RecurringPaymentOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecurringPaymentsTable _recurringPaymentIdTable(_$AppDatabase db) =>
      db.recurringPayments.createAlias(
        $_aliasNameGenerator(
          db.recurringPaymentOccurrences.recurringPaymentId,
          db.recurringPayments.id,
        ),
      );

  $$RecurringPaymentsTableProcessedTableManager get recurringPaymentId {
    final $_column = $_itemColumn<String>('recurring_payment_id')!;

    final manager = $$RecurringPaymentsTableTableManager(
      $_db,
      $_db.recurringPayments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringPaymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias(
        $_aliasNameGenerator(
          db.recurringPaymentOccurrences.expenseId,
          db.expenses.id,
        ),
      );

  $$ExpensesTableProcessedTableManager? get expenseId {
    final $_column = $_itemColumn<String>('expense_id');
    if ($_column == null) return null;
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringPaymentOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringPaymentOccurrencesTable> {
  $$RecurringPaymentOccurrencesTableFilterComposer({
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

  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RecurringPaymentsTableFilterComposer get recurringPaymentId {
    final $$RecurringPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPaymentId,
      referencedTable: $db.recurringPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.recurringPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableFilterComposer get expenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringPaymentOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringPaymentOccurrencesTable> {
  $$RecurringPaymentOccurrencesTableOrderingComposer({
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

  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecurringPaymentsTableOrderingComposer get recurringPaymentId {
    final $$RecurringPaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurringPaymentId,
      referencedTable: $db.recurringPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringPaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.recurringPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpensesTableOrderingComposer get expenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableOrderingComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringPaymentOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringPaymentOccurrencesTable> {
  $$RecurringPaymentOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RecurringPaymentsTableAnnotationComposer get recurringPaymentId {
    final $$RecurringPaymentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringPaymentId,
          referencedTable: $db.recurringPayments,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringPaymentsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringPayments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ExpensesTableAnnotationComposer get expenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringPaymentOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringPaymentOccurrencesTable,
          RecurringPaymentOccurrence,
          $$RecurringPaymentOccurrencesTableFilterComposer,
          $$RecurringPaymentOccurrencesTableOrderingComposer,
          $$RecurringPaymentOccurrencesTableAnnotationComposer,
          $$RecurringPaymentOccurrencesTableCreateCompanionBuilder,
          $$RecurringPaymentOccurrencesTableUpdateCompanionBuilder,
          (
            RecurringPaymentOccurrence,
            $$RecurringPaymentOccurrencesTableReferences,
          ),
          RecurringPaymentOccurrence,
          PrefetchHooks Function({bool recurringPaymentId, bool expenseId})
        > {
  $$RecurringPaymentOccurrencesTableTableManager(
    _$AppDatabase db,
    $RecurringPaymentOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringPaymentOccurrencesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringPaymentOccurrencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringPaymentOccurrencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recurringPaymentId = const Value.absent(),
                Value<String> monthKey = const Value.absent(),
                Value<String?> expenseId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringPaymentOccurrencesCompanion(
                id: id,
                recurringPaymentId: recurringPaymentId,
                monthKey: monthKey,
                expenseId: expenseId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recurringPaymentId,
                required String monthKey,
                Value<String?> expenseId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RecurringPaymentOccurrencesCompanion.insert(
                id: id,
                recurringPaymentId: recurringPaymentId,
                monthKey: monthKey,
                expenseId: expenseId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringPaymentOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recurringPaymentId = false, expenseId = false}) {
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
                    if (recurringPaymentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recurringPaymentId,
                                referencedTable:
                                    $$RecurringPaymentOccurrencesTableReferences
                                        ._recurringPaymentIdTable(db),
                                referencedColumn:
                                    $$RecurringPaymentOccurrencesTableReferences
                                        ._recurringPaymentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (expenseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.expenseId,
                                referencedTable:
                                    $$RecurringPaymentOccurrencesTableReferences
                                        ._expenseIdTable(db),
                                referencedColumn:
                                    $$RecurringPaymentOccurrencesTableReferences
                                        ._expenseIdTable(db)
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

typedef $$RecurringPaymentOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringPaymentOccurrencesTable,
      RecurringPaymentOccurrence,
      $$RecurringPaymentOccurrencesTableFilterComposer,
      $$RecurringPaymentOccurrencesTableOrderingComposer,
      $$RecurringPaymentOccurrencesTableAnnotationComposer,
      $$RecurringPaymentOccurrencesTableCreateCompanionBuilder,
      $$RecurringPaymentOccurrencesTableUpdateCompanionBuilder,
      (
        RecurringPaymentOccurrence,
        $$RecurringPaymentOccurrencesTableReferences,
      ),
      RecurringPaymentOccurrence,
      PrefetchHooks Function({bool recurringPaymentId, bool expenseId})
    >;
typedef $$ExpenseLimitPreferencesTableCreateCompanionBuilder =
    ExpenseLimitPreferencesCompanion Function({
      required String userId,
      Value<int?> monthlyIncomeMinor,
      Value<int?> monthlySavingsMinor,
      Value<bool> excludeUnpaidRecurring,
      required int updatedAt,
      Value<String?> remoteId,
      Value<String?> syncStatus,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$ExpenseLimitPreferencesTableUpdateCompanionBuilder =
    ExpenseLimitPreferencesCompanion Function({
      Value<String> userId,
      Value<int?> monthlyIncomeMinor,
      Value<int?> monthlySavingsMinor,
      Value<bool> excludeUnpaidRecurring,
      Value<int> updatedAt,
      Value<String?> remoteId,
      Value<String?> syncStatus,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

final class $$ExpenseLimitPreferencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExpenseLimitPreferencesTable,
          ExpenseLimitPreference
        > {
  $$ExpenseLimitPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(
          db.expenseLimitPreferences.userId,
          db.userProfiles.id,
        ),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpenseLimitPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseLimitPreferencesTable> {
  $$ExpenseLimitPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get monthlyIncomeMinor => $composableBuilder(
    column: $table.monthlyIncomeMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlySavingsMinor => $composableBuilder(
    column: $table.monthlySavingsMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excludeUnpaidRecurring => $composableBuilder(
    column: $table.excludeUnpaidRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseLimitPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseLimitPreferencesTable> {
  $$ExpenseLimitPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get monthlyIncomeMinor => $composableBuilder(
    column: $table.monthlyIncomeMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlySavingsMinor => $composableBuilder(
    column: $table.monthlySavingsMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excludeUnpaidRecurring => $composableBuilder(
    column: $table.excludeUnpaidRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseLimitPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseLimitPreferencesTable> {
  $$ExpenseLimitPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get monthlyIncomeMinor => $composableBuilder(
    column: $table.monthlyIncomeMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlySavingsMinor => $composableBuilder(
    column: $table.monthlySavingsMinor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excludeUnpaidRecurring => $composableBuilder(
    column: $table.excludeUnpaidRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpenseLimitPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseLimitPreferencesTable,
          ExpenseLimitPreference,
          $$ExpenseLimitPreferencesTableFilterComposer,
          $$ExpenseLimitPreferencesTableOrderingComposer,
          $$ExpenseLimitPreferencesTableAnnotationComposer,
          $$ExpenseLimitPreferencesTableCreateCompanionBuilder,
          $$ExpenseLimitPreferencesTableUpdateCompanionBuilder,
          (ExpenseLimitPreference, $$ExpenseLimitPreferencesTableReferences),
          ExpenseLimitPreference,
          PrefetchHooks Function({bool userId})
        > {
  $$ExpenseLimitPreferencesTableTableManager(
    _$AppDatabase db,
    $ExpenseLimitPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseLimitPreferencesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExpenseLimitPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExpenseLimitPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int?> monthlyIncomeMinor = const Value.absent(),
                Value<int?> monthlySavingsMinor = const Value.absent(),
                Value<bool> excludeUnpaidRecurring = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseLimitPreferencesCompanion(
                userId: userId,
                monthlyIncomeMinor: monthlyIncomeMinor,
                monthlySavingsMinor: monthlySavingsMinor,
                excludeUnpaidRecurring: excludeUnpaidRecurring,
                updatedAt: updatedAt,
                remoteId: remoteId,
                syncStatus: syncStatus,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<int?> monthlyIncomeMinor = const Value.absent(),
                Value<int?> monthlySavingsMinor = const Value.absent(),
                Value<bool> excludeUnpaidRecurring = const Value.absent(),
                required int updatedAt,
                Value<String?> remoteId = const Value.absent(),
                Value<String?> syncStatus = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseLimitPreferencesCompanion.insert(
                userId: userId,
                monthlyIncomeMinor: monthlyIncomeMinor,
                monthlySavingsMinor: monthlySavingsMinor,
                excludeUnpaidRecurring: excludeUnpaidRecurring,
                updatedAt: updatedAt,
                remoteId: remoteId,
                syncStatus: syncStatus,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpenseLimitPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$ExpenseLimitPreferencesTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$ExpenseLimitPreferencesTableReferences
                                        ._userIdTable(db)
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

typedef $$ExpenseLimitPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseLimitPreferencesTable,
      ExpenseLimitPreference,
      $$ExpenseLimitPreferencesTableFilterComposer,
      $$ExpenseLimitPreferencesTableOrderingComposer,
      $$ExpenseLimitPreferencesTableAnnotationComposer,
      $$ExpenseLimitPreferencesTableCreateCompanionBuilder,
      $$ExpenseLimitPreferencesTableUpdateCompanionBuilder,
      (ExpenseLimitPreference, $$ExpenseLimitPreferencesTableReferences),
      ExpenseLimitPreference,
      PrefetchHooks Function({bool userId})
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      required String userId,
      Value<String> currencyCode,
      Value<String> languageCode,
      Value<String> numberFormat,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<String> userId,
      Value<String> currencyCode,
      Value<String> languageCode,
      Value<String> numberFormat,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$UserPreferencesTableReferences
    extends
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference> {
  $$UserPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.userPreferences.userId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numberFormat => $composableBuilder(
    column: $table.numberFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numberFormat => $composableBuilder(
    column: $table.numberFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get numberFormat => $composableBuilder(
    column: $table.numberFormat,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (UserPreference, $$UserPreferencesTableReferences),
          UserPreference,
          PrefetchHooks Function({bool userId})
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> numberFormat = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesCompanion(
                userId: userId,
                currencyCode: currencyCode,
                languageCode: languageCode,
                numberFormat: numberFormat,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String> currencyCode = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> numberFormat = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesCompanion.insert(
                userId: userId,
                currencyCode: currencyCode,
                languageCode: languageCode,
                numberFormat: numberFormat,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
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
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$UserPreferencesTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$UserPreferencesTableReferences
                                        ._userIdTable(db)
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

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (UserPreference, $$UserPreferencesTableReferences),
      UserPreference,
      PrefetchHooks Function({bool userId})
    >;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      required String id,
      required String label,
      required String bucket,
      Value<bool> isBuiltIn,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> bucket,
      Value<bool> isBuiltIn,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
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
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
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

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ExpenseCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategory,
          $$ExpenseCategoriesTableFilterComposer,
          $$ExpenseCategoriesTableOrderingComposer,
          $$ExpenseCategoriesTableAnnotationComposer,
          $$ExpenseCategoriesTableCreateCompanionBuilder,
          $$ExpenseCategoriesTableUpdateCompanionBuilder,
          (
            ExpenseCategory,
            BaseReferences<
              _$AppDatabase,
              $ExpenseCategoriesTable,
              ExpenseCategory
            >,
          ),
          ExpenseCategory,
          PrefetchHooks Function()
        > {
  $$ExpenseCategoriesTableTableManager(
    _$AppDatabase db,
    $ExpenseCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> bucket = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion(
                id: id,
                label: label,
                bucket: bucket,
                isBuiltIn: isBuiltIn,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String bucket,
                Value<bool> isBuiltIn = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion.insert(
                id: id,
                label: label,
                bucket: bucket,
                isBuiltIn: isBuiltIn,
                createdAt: createdAt,
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

typedef $$ExpenseCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCategoriesTable,
      ExpenseCategory,
      $$ExpenseCategoriesTableFilterComposer,
      $$ExpenseCategoriesTableOrderingComposer,
      $$ExpenseCategoriesTableAnnotationComposer,
      $$ExpenseCategoriesTableCreateCompanionBuilder,
      $$ExpenseCategoriesTableUpdateCompanionBuilder,
      (
        ExpenseCategory,
        BaseReferences<_$AppDatabase, $ExpenseCategoriesTable, ExpenseCategory>,
      ),
      ExpenseCategory,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$RecurringPaymentsTableTableManager get recurringPayments =>
      $$RecurringPaymentsTableTableManager(_db, _db.recurringPayments);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$RecurringPaymentOccurrencesTableTableManager
  get recurringPaymentOccurrences =>
      $$RecurringPaymentOccurrencesTableTableManager(
        _db,
        _db.recurringPaymentOccurrences,
      );
  $$ExpenseLimitPreferencesTableTableManager get expenseLimitPreferences =>
      $$ExpenseLimitPreferencesTableTableManager(
        _db,
        _db.expenseLimitPreferences,
      );
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
}

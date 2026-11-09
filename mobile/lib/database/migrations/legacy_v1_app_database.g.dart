// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legacy_v1_app_database.dart';

// ignore_for_file: type=lint
class $LocalBusinessTable extends LocalBusiness
    with TableInfo<$LocalBusinessTable, LocalBusinessRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBusinessTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonIdMeta = const VerificationMeta(
    'singletonId',
  );
  @override
  late final GeneratedColumn<int> singletonId = GeneratedColumn<int>(
    'singleton_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legalNameMeta = const VerificationMeta(
    'legalName',
  );
  @override
  late final GeneratedColumn<String> legalName = GeneratedColumn<String>(
    'legal_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneIdMeta = const VerificationMeta(
    'timezoneId',
  );
  @override
  late final GeneratedColumn<String> timezoneId = GeneratedColumn<String>(
    'timezone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Karachi'),
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
    defaultValue: const Constant('PKR'),
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonId,
    businessId,
    name,
    legalName,
    phone,
    address,
    timezoneId,
    currencyCode,
    settingsJson,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_business';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBusinessRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_id')) {
      context.handle(
        _singletonIdMeta,
        singletonId.isAcceptableOrUnknown(
          data['singleton_id']!,
          _singletonIdMeta,
        ),
      );
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('legal_name')) {
      context.handle(
        _legalNameMeta,
        legalName.isAcceptableOrUnknown(data['legal_name']!, _legalNameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('timezone_id')) {
      context.handle(
        _timezoneIdMeta,
        timezoneId.isAcceptableOrUnknown(data['timezone_id']!, _timezoneIdMeta),
      );
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
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonId};
  @override
  LocalBusinessRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBusinessRow(
      singletonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      legalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      timezoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone_id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $LocalBusinessTable createAlias(String alias) {
    return $LocalBusinessTable(attachedDatabase, alias);
  }
}

class LocalBusinessRow extends DataClass
    implements Insertable<LocalBusinessRow> {
  final int singletonId;
  final String businessId;
  final String name;
  final String? legalName;
  final String? phone;
  final String? address;
  final String timezoneId;
  final String currencyCode;
  final String settingsJson;
  final int createdAtMs;
  final int updatedAtMs;
  const LocalBusinessRow({
    required this.singletonId,
    required this.businessId,
    required this.name,
    this.legalName,
    this.phone,
    this.address,
    required this.timezoneId,
    required this.currencyCode,
    required this.settingsJson,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_id'] = Variable<int>(singletonId);
    map['business_id'] = Variable<String>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || legalName != null) {
      map['legal_name'] = Variable<String>(legalName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['timezone_id'] = Variable<String>(timezoneId);
    map['currency_code'] = Variable<String>(currencyCode);
    map['settings_json'] = Variable<String>(settingsJson);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  LocalBusinessCompanion toCompanion(bool nullToAbsent) {
    return LocalBusinessCompanion(
      singletonId: Value(singletonId),
      businessId: Value(businessId),
      name: Value(name),
      legalName: legalName == null && nullToAbsent
          ? const Value.absent()
          : Value(legalName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      timezoneId: Value(timezoneId),
      currencyCode: Value(currencyCode),
      settingsJson: Value(settingsJson),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory LocalBusinessRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBusinessRow(
      singletonId: serializer.fromJson<int>(json['singletonId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      legalName: serializer.fromJson<String?>(json['legalName']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      timezoneId: serializer.fromJson<String>(json['timezoneId']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonId': serializer.toJson<int>(singletonId),
      'businessId': serializer.toJson<String>(businessId),
      'name': serializer.toJson<String>(name),
      'legalName': serializer.toJson<String?>(legalName),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'timezoneId': serializer.toJson<String>(timezoneId),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  LocalBusinessRow copyWith({
    int? singletonId,
    String? businessId,
    String? name,
    Value<String?> legalName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    String? timezoneId,
    String? currencyCode,
    String? settingsJson,
    int? createdAtMs,
    int? updatedAtMs,
  }) => LocalBusinessRow(
    singletonId: singletonId ?? this.singletonId,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    legalName: legalName.present ? legalName.value : this.legalName,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    timezoneId: timezoneId ?? this.timezoneId,
    currencyCode: currencyCode ?? this.currencyCode,
    settingsJson: settingsJson ?? this.settingsJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  LocalBusinessRow copyWithCompanion(LocalBusinessCompanion data) {
    return LocalBusinessRow(
      singletonId: data.singletonId.present
          ? data.singletonId.value
          : this.singletonId,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      legalName: data.legalName.present ? data.legalName.value : this.legalName,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      timezoneId: data.timezoneId.present
          ? data.timezoneId.value
          : this.timezoneId,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBusinessRow(')
          ..write('singletonId: $singletonId, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('legalName: $legalName, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('timezoneId: $timezoneId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singletonId,
    businessId,
    name,
    legalName,
    phone,
    address,
    timezoneId,
    currencyCode,
    settingsJson,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBusinessRow &&
          other.singletonId == this.singletonId &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.legalName == this.legalName &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.timezoneId == this.timezoneId &&
          other.currencyCode == this.currencyCode &&
          other.settingsJson == this.settingsJson &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class LocalBusinessCompanion extends UpdateCompanion<LocalBusinessRow> {
  final Value<int> singletonId;
  final Value<String> businessId;
  final Value<String> name;
  final Value<String?> legalName;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String> timezoneId;
  final Value<String> currencyCode;
  final Value<String> settingsJson;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  const LocalBusinessCompanion({
    this.singletonId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.legalName = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.timezoneId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  LocalBusinessCompanion.insert({
    this.singletonId = const Value.absent(),
    required String businessId,
    required String name,
    this.legalName = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.timezoneId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.settingsJson = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
  }) : businessId = Value(businessId),
       name = Value(name),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalBusinessRow> custom({
    Expression<int>? singletonId,
    Expression<String>? businessId,
    Expression<String>? name,
    Expression<String>? legalName,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? timezoneId,
    Expression<String>? currencyCode,
    Expression<String>? settingsJson,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (singletonId != null) 'singleton_id': singletonId,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (legalName != null) 'legal_name': legalName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (timezoneId != null) 'timezone_id': timezoneId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  LocalBusinessCompanion copyWith({
    Value<int>? singletonId,
    Value<String>? businessId,
    Value<String>? name,
    Value<String?>? legalName,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String>? timezoneId,
    Value<String>? currencyCode,
    Value<String>? settingsJson,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
  }) {
    return LocalBusinessCompanion(
      singletonId: singletonId ?? this.singletonId,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      legalName: legalName ?? this.legalName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      timezoneId: timezoneId ?? this.timezoneId,
      currencyCode: currencyCode ?? this.currencyCode,
      settingsJson: settingsJson ?? this.settingsJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonId.present) {
      map['singleton_id'] = Variable<int>(singletonId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (legalName.present) {
      map['legal_name'] = Variable<String>(legalName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (timezoneId.present) {
      map['timezone_id'] = Variable<String>(timezoneId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBusinessCompanion(')
          ..write('singletonId: $singletonId, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('legalName: $legalName, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('timezoneId: $timezoneId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $LocalDeviceTable extends LocalDevice
    with TableInfo<$LocalDeviceTable, LocalDeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDeviceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonIdMeta = const VerificationMeta(
    'singletonId',
  );
  @override
  late final GeneratedColumn<int> singletonId = GeneratedColumn<int>(
    'singleton_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_business (business_id)',
    ),
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activationStatusMeta = const VerificationMeta(
    'activationStatus',
  );
  @override
  late final GeneratedColumn<String> activationStatus = GeneratedColumn<String>(
    'activation_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activatedAtMsMeta = const VerificationMeta(
    'activatedAtMs',
  );
  @override
  late final GeneratedColumn<int> activatedAtMs = GeneratedColumn<int>(
    'activated_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastOnlineValidatedAtMsMeta =
      const VerificationMeta('lastOnlineValidatedAtMs');
  @override
  late final GeneratedColumn<int> lastOnlineValidatedAtMs =
      GeneratedColumn<int>(
        'last_online_validated_at_ms',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _offlineValidUntilMsMeta =
      const VerificationMeta('offlineValidUntilMs');
  @override
  late final GeneratedColumn<int> offlineValidUntilMs = GeneratedColumn<int>(
    'offline_valid_until_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonId,
    deviceId,
    businessId,
    platform,
    label,
    activationStatus,
    activatedAtMs,
    lastOnlineValidatedAtMs,
    offlineValidUntilMs,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_device';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_id')) {
      context.handle(
        _singletonIdMeta,
        singletonId.isAcceptableOrUnknown(
          data['singleton_id']!,
          _singletonIdMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('activation_status')) {
      context.handle(
        _activationStatusMeta,
        activationStatus.isAcceptableOrUnknown(
          data['activation_status']!,
          _activationStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activationStatusMeta);
    }
    if (data.containsKey('activated_at_ms')) {
      context.handle(
        _activatedAtMsMeta,
        activatedAtMs.isAcceptableOrUnknown(
          data['activated_at_ms']!,
          _activatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('last_online_validated_at_ms')) {
      context.handle(
        _lastOnlineValidatedAtMsMeta,
        lastOnlineValidatedAtMs.isAcceptableOrUnknown(
          data['last_online_validated_at_ms']!,
          _lastOnlineValidatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('offline_valid_until_ms')) {
      context.handle(
        _offlineValidUntilMsMeta,
        offlineValidUntilMs.isAcceptableOrUnknown(
          data['offline_valid_until_ms']!,
          _offlineValidUntilMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonId};
  @override
  LocalDeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDeviceRow(
      singletonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      activationStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activation_status'],
      )!,
      activatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activated_at_ms'],
      ),
      lastOnlineValidatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_online_validated_at_ms'],
      ),
      offlineValidUntilMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offline_valid_until_ms'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $LocalDeviceTable createAlias(String alias) {
    return $LocalDeviceTable(attachedDatabase, alias);
  }
}

class LocalDeviceRow extends DataClass implements Insertable<LocalDeviceRow> {
  final int singletonId;
  final String deviceId;
  final String businessId;
  final String platform;
  final String? label;
  final String activationStatus;
  final int? activatedAtMs;
  final int? lastOnlineValidatedAtMs;
  final int? offlineValidUntilMs;
  final int createdAtMs;
  final int updatedAtMs;
  const LocalDeviceRow({
    required this.singletonId,
    required this.deviceId,
    required this.businessId,
    required this.platform,
    this.label,
    required this.activationStatus,
    this.activatedAtMs,
    this.lastOnlineValidatedAtMs,
    this.offlineValidUntilMs,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_id'] = Variable<int>(singletonId);
    map['device_id'] = Variable<String>(deviceId);
    map['business_id'] = Variable<String>(businessId);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['activation_status'] = Variable<String>(activationStatus);
    if (!nullToAbsent || activatedAtMs != null) {
      map['activated_at_ms'] = Variable<int>(activatedAtMs);
    }
    if (!nullToAbsent || lastOnlineValidatedAtMs != null) {
      map['last_online_validated_at_ms'] = Variable<int>(
        lastOnlineValidatedAtMs,
      );
    }
    if (!nullToAbsent || offlineValidUntilMs != null) {
      map['offline_valid_until_ms'] = Variable<int>(offlineValidUntilMs);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  LocalDeviceCompanion toCompanion(bool nullToAbsent) {
    return LocalDeviceCompanion(
      singletonId: Value(singletonId),
      deviceId: Value(deviceId),
      businessId: Value(businessId),
      platform: Value(platform),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      activationStatus: Value(activationStatus),
      activatedAtMs: activatedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(activatedAtMs),
      lastOnlineValidatedAtMs: lastOnlineValidatedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOnlineValidatedAtMs),
      offlineValidUntilMs: offlineValidUntilMs == null && nullToAbsent
          ? const Value.absent()
          : Value(offlineValidUntilMs),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory LocalDeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDeviceRow(
      singletonId: serializer.fromJson<int>(json['singletonId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      platform: serializer.fromJson<String>(json['platform']),
      label: serializer.fromJson<String?>(json['label']),
      activationStatus: serializer.fromJson<String>(json['activationStatus']),
      activatedAtMs: serializer.fromJson<int?>(json['activatedAtMs']),
      lastOnlineValidatedAtMs: serializer.fromJson<int?>(
        json['lastOnlineValidatedAtMs'],
      ),
      offlineValidUntilMs: serializer.fromJson<int?>(
        json['offlineValidUntilMs'],
      ),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonId': serializer.toJson<int>(singletonId),
      'deviceId': serializer.toJson<String>(deviceId),
      'businessId': serializer.toJson<String>(businessId),
      'platform': serializer.toJson<String>(platform),
      'label': serializer.toJson<String?>(label),
      'activationStatus': serializer.toJson<String>(activationStatus),
      'activatedAtMs': serializer.toJson<int?>(activatedAtMs),
      'lastOnlineValidatedAtMs': serializer.toJson<int?>(
        lastOnlineValidatedAtMs,
      ),
      'offlineValidUntilMs': serializer.toJson<int?>(offlineValidUntilMs),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  LocalDeviceRow copyWith({
    int? singletonId,
    String? deviceId,
    String? businessId,
    String? platform,
    Value<String?> label = const Value.absent(),
    String? activationStatus,
    Value<int?> activatedAtMs = const Value.absent(),
    Value<int?> lastOnlineValidatedAtMs = const Value.absent(),
    Value<int?> offlineValidUntilMs = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
  }) => LocalDeviceRow(
    singletonId: singletonId ?? this.singletonId,
    deviceId: deviceId ?? this.deviceId,
    businessId: businessId ?? this.businessId,
    platform: platform ?? this.platform,
    label: label.present ? label.value : this.label,
    activationStatus: activationStatus ?? this.activationStatus,
    activatedAtMs: activatedAtMs.present
        ? activatedAtMs.value
        : this.activatedAtMs,
    lastOnlineValidatedAtMs: lastOnlineValidatedAtMs.present
        ? lastOnlineValidatedAtMs.value
        : this.lastOnlineValidatedAtMs,
    offlineValidUntilMs: offlineValidUntilMs.present
        ? offlineValidUntilMs.value
        : this.offlineValidUntilMs,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  LocalDeviceRow copyWithCompanion(LocalDeviceCompanion data) {
    return LocalDeviceRow(
      singletonId: data.singletonId.present
          ? data.singletonId.value
          : this.singletonId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      platform: data.platform.present ? data.platform.value : this.platform,
      label: data.label.present ? data.label.value : this.label,
      activationStatus: data.activationStatus.present
          ? data.activationStatus.value
          : this.activationStatus,
      activatedAtMs: data.activatedAtMs.present
          ? data.activatedAtMs.value
          : this.activatedAtMs,
      lastOnlineValidatedAtMs: data.lastOnlineValidatedAtMs.present
          ? data.lastOnlineValidatedAtMs.value
          : this.lastOnlineValidatedAtMs,
      offlineValidUntilMs: data.offlineValidUntilMs.present
          ? data.offlineValidUntilMs.value
          : this.offlineValidUntilMs,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDeviceRow(')
          ..write('singletonId: $singletonId, ')
          ..write('deviceId: $deviceId, ')
          ..write('businessId: $businessId, ')
          ..write('platform: $platform, ')
          ..write('label: $label, ')
          ..write('activationStatus: $activationStatus, ')
          ..write('activatedAtMs: $activatedAtMs, ')
          ..write('lastOnlineValidatedAtMs: $lastOnlineValidatedAtMs, ')
          ..write('offlineValidUntilMs: $offlineValidUntilMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singletonId,
    deviceId,
    businessId,
    platform,
    label,
    activationStatus,
    activatedAtMs,
    lastOnlineValidatedAtMs,
    offlineValidUntilMs,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDeviceRow &&
          other.singletonId == this.singletonId &&
          other.deviceId == this.deviceId &&
          other.businessId == this.businessId &&
          other.platform == this.platform &&
          other.label == this.label &&
          other.activationStatus == this.activationStatus &&
          other.activatedAtMs == this.activatedAtMs &&
          other.lastOnlineValidatedAtMs == this.lastOnlineValidatedAtMs &&
          other.offlineValidUntilMs == this.offlineValidUntilMs &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class LocalDeviceCompanion extends UpdateCompanion<LocalDeviceRow> {
  final Value<int> singletonId;
  final Value<String> deviceId;
  final Value<String> businessId;
  final Value<String> platform;
  final Value<String?> label;
  final Value<String> activationStatus;
  final Value<int?> activatedAtMs;
  final Value<int?> lastOnlineValidatedAtMs;
  final Value<int?> offlineValidUntilMs;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  const LocalDeviceCompanion({
    this.singletonId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.platform = const Value.absent(),
    this.label = const Value.absent(),
    this.activationStatus = const Value.absent(),
    this.activatedAtMs = const Value.absent(),
    this.lastOnlineValidatedAtMs = const Value.absent(),
    this.offlineValidUntilMs = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  LocalDeviceCompanion.insert({
    this.singletonId = const Value.absent(),
    required String deviceId,
    required String businessId,
    required String platform,
    this.label = const Value.absent(),
    required String activationStatus,
    this.activatedAtMs = const Value.absent(),
    this.lastOnlineValidatedAtMs = const Value.absent(),
    this.offlineValidUntilMs = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
  }) : deviceId = Value(deviceId),
       businessId = Value(businessId),
       platform = Value(platform),
       activationStatus = Value(activationStatus),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalDeviceRow> custom({
    Expression<int>? singletonId,
    Expression<String>? deviceId,
    Expression<String>? businessId,
    Expression<String>? platform,
    Expression<String>? label,
    Expression<String>? activationStatus,
    Expression<int>? activatedAtMs,
    Expression<int>? lastOnlineValidatedAtMs,
    Expression<int>? offlineValidUntilMs,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (singletonId != null) 'singleton_id': singletonId,
      if (deviceId != null) 'device_id': deviceId,
      if (businessId != null) 'business_id': businessId,
      if (platform != null) 'platform': platform,
      if (label != null) 'label': label,
      if (activationStatus != null) 'activation_status': activationStatus,
      if (activatedAtMs != null) 'activated_at_ms': activatedAtMs,
      if (lastOnlineValidatedAtMs != null)
        'last_online_validated_at_ms': lastOnlineValidatedAtMs,
      if (offlineValidUntilMs != null)
        'offline_valid_until_ms': offlineValidUntilMs,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  LocalDeviceCompanion copyWith({
    Value<int>? singletonId,
    Value<String>? deviceId,
    Value<String>? businessId,
    Value<String>? platform,
    Value<String?>? label,
    Value<String>? activationStatus,
    Value<int?>? activatedAtMs,
    Value<int?>? lastOnlineValidatedAtMs,
    Value<int?>? offlineValidUntilMs,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
  }) {
    return LocalDeviceCompanion(
      singletonId: singletonId ?? this.singletonId,
      deviceId: deviceId ?? this.deviceId,
      businessId: businessId ?? this.businessId,
      platform: platform ?? this.platform,
      label: label ?? this.label,
      activationStatus: activationStatus ?? this.activationStatus,
      activatedAtMs: activatedAtMs ?? this.activatedAtMs,
      lastOnlineValidatedAtMs:
          lastOnlineValidatedAtMs ?? this.lastOnlineValidatedAtMs,
      offlineValidUntilMs: offlineValidUntilMs ?? this.offlineValidUntilMs,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonId.present) {
      map['singleton_id'] = Variable<int>(singletonId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (activationStatus.present) {
      map['activation_status'] = Variable<String>(activationStatus.value);
    }
    if (activatedAtMs.present) {
      map['activated_at_ms'] = Variable<int>(activatedAtMs.value);
    }
    if (lastOnlineValidatedAtMs.present) {
      map['last_online_validated_at_ms'] = Variable<int>(
        lastOnlineValidatedAtMs.value,
      );
    }
    if (offlineValidUntilMs.present) {
      map['offline_valid_until_ms'] = Variable<int>(offlineValidUntilMs.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDeviceCompanion(')
          ..write('singletonId: $singletonId, ')
          ..write('deviceId: $deviceId, ')
          ..write('businessId: $businessId, ')
          ..write('platform: $platform, ')
          ..write('label: $label, ')
          ..write('activationStatus: $activationStatus, ')
          ..write('activatedAtMs: $activatedAtMs, ')
          ..write('lastOnlineValidatedAtMs: $lastOnlineValidatedAtMs, ')
          ..write('offlineValidUntilMs: $offlineValidUntilMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $UsersCacheTable extends UsersCache
    with TableInfo<$UsersCacheTable, UsersCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_business (business_id)',
    ),
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
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncedAtMsMeta = const VerificationMeta(
    'lastSyncedAtMs',
  );
  @override
  late final GeneratedColumn<int> lastSyncedAtMs = GeneratedColumn<int>(
    'last_synced_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    businessId,
    displayName,
    role,
    isActive,
    lastSyncedAtMs,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersCacheRow> instance, {
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
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
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
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_synced_at_ms')) {
      context.handle(
        _lastSyncedAtMsMeta,
        lastSyncedAtMs.isAcceptableOrUnknown(
          data['last_synced_at_ms']!,
          _lastSyncedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UsersCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersCacheRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastSyncedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at_ms'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $UsersCacheTable createAlias(String alias) {
    return $UsersCacheTable(attachedDatabase, alias);
  }
}

class UsersCacheRow extends DataClass implements Insertable<UsersCacheRow> {
  final String userId;
  final String businessId;
  final String displayName;
  final String role;
  final bool isActive;
  final int? lastSyncedAtMs;
  final int createdAtMs;
  final int updatedAtMs;
  const UsersCacheRow({
    required this.userId,
    required this.businessId,
    required this.displayName,
    required this.role,
    required this.isActive,
    this.lastSyncedAtMs,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['business_id'] = Variable<String>(businessId);
    map['display_name'] = Variable<String>(displayName);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastSyncedAtMs != null) {
      map['last_synced_at_ms'] = Variable<int>(lastSyncedAtMs);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  UsersCacheCompanion toCompanion(bool nullToAbsent) {
    return UsersCacheCompanion(
      userId: Value(userId),
      businessId: Value(businessId),
      displayName: Value(displayName),
      role: Value(role),
      isActive: Value(isActive),
      lastSyncedAtMs: lastSyncedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAtMs),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory UsersCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersCacheRow(
      userId: serializer.fromJson<String>(json['userId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastSyncedAtMs: serializer.fromJson<int?>(json['lastSyncedAtMs']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'businessId': serializer.toJson<String>(businessId),
      'displayName': serializer.toJson<String>(displayName),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'lastSyncedAtMs': serializer.toJson<int?>(lastSyncedAtMs),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  UsersCacheRow copyWith({
    String? userId,
    String? businessId,
    String? displayName,
    String? role,
    bool? isActive,
    Value<int?> lastSyncedAtMs = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
  }) => UsersCacheRow(
    userId: userId ?? this.userId,
    businessId: businessId ?? this.businessId,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    lastSyncedAtMs: lastSyncedAtMs.present
        ? lastSyncedAtMs.value
        : this.lastSyncedAtMs,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  UsersCacheRow copyWithCompanion(UsersCacheCompanion data) {
    return UsersCacheRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastSyncedAtMs: data.lastSyncedAtMs.present
          ? data.lastSyncedAtMs.value
          : this.lastSyncedAtMs,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersCacheRow(')
          ..write('userId: $userId, ')
          ..write('businessId: $businessId, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncedAtMs: $lastSyncedAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    businessId,
    displayName,
    role,
    isActive,
    lastSyncedAtMs,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersCacheRow &&
          other.userId == this.userId &&
          other.businessId == this.businessId &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.lastSyncedAtMs == this.lastSyncedAtMs &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class UsersCacheCompanion extends UpdateCompanion<UsersCacheRow> {
  final Value<String> userId;
  final Value<String> businessId;
  final Value<String> displayName;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<int?> lastSyncedAtMs;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const UsersCacheCompanion({
    this.userId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSyncedAtMs = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCacheCompanion.insert({
    required String userId,
    required String businessId,
    required String displayName,
    required String role,
    this.isActive = const Value.absent(),
    this.lastSyncedAtMs = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       businessId = Value(businessId),
       displayName = Value(displayName),
       role = Value(role),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<UsersCacheRow> custom({
    Expression<String>? userId,
    Expression<String>? businessId,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<int>? lastSyncedAtMs,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (businessId != null) 'business_id': businessId,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (lastSyncedAtMs != null) 'last_synced_at_ms': lastSyncedAtMs,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCacheCompanion copyWith({
    Value<String>? userId,
    Value<String>? businessId,
    Value<String>? displayName,
    Value<String>? role,
    Value<bool>? isActive,
    Value<int?>? lastSyncedAtMs,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return UsersCacheCompanion(
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastSyncedAtMs: lastSyncedAtMs ?? this.lastSyncedAtMs,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastSyncedAtMs.present) {
      map['last_synced_at_ms'] = Variable<int>(lastSyncedAtMs.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCacheCompanion(')
          ..write('userId: $userId, ')
          ..write('businessId: $businessId, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncedAtMs: $lastSyncedAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_business (business_id)',
    ),
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByUserIdMeta = const VerificationMeta(
    'updatedByUserId',
  );
  @override
  late final GeneratedColumn<String> updatedByUserId = GeneratedColumn<String>(
    'updated_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    settingKey,
    businessId,
    valueJson,
    updatedAtMs,
    updatedByUserId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('updated_by_user_id')) {
      context.handle(
        _updatedByUserIdMeta,
        updatedByUserId.isAcceptableOrUnknown(
          data['updated_by_user_id']!,
          _updatedByUserIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      updatedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by_user_id'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String settingKey;
  final String businessId;
  final String valueJson;
  final int updatedAtMs;
  final String? updatedByUserId;
  const AppSettingRow({
    required this.settingKey,
    required this.businessId,
    required this.valueJson,
    required this.updatedAtMs,
    this.updatedByUserId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['business_id'] = Variable<String>(businessId);
    map['value_json'] = Variable<String>(valueJson);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || updatedByUserId != null) {
      map['updated_by_user_id'] = Variable<String>(updatedByUserId);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      settingKey: Value(settingKey),
      businessId: Value(businessId),
      valueJson: Value(valueJson),
      updatedAtMs: Value(updatedAtMs),
      updatedByUserId: updatedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedByUserId),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      businessId: serializer.fromJson<String>(json['businessId']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      updatedByUserId: serializer.fromJson<String?>(json['updatedByUserId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'businessId': serializer.toJson<String>(businessId),
      'valueJson': serializer.toJson<String>(valueJson),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'updatedByUserId': serializer.toJson<String?>(updatedByUserId),
    };
  }

  AppSettingRow copyWith({
    String? settingKey,
    String? businessId,
    String? valueJson,
    int? updatedAtMs,
    Value<String?> updatedByUserId = const Value.absent(),
  }) => AppSettingRow(
    settingKey: settingKey ?? this.settingKey,
    businessId: businessId ?? this.businessId,
    valueJson: valueJson ?? this.valueJson,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    updatedByUserId: updatedByUserId.present
        ? updatedByUserId.value
        : this.updatedByUserId,
  );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      updatedByUserId: data.updatedByUserId.present
          ? data.updatedByUserId.value
          : this.updatedByUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('settingKey: $settingKey, ')
          ..write('businessId: $businessId, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByUserId: $updatedByUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    settingKey,
    businessId,
    valueJson,
    updatedAtMs,
    updatedByUserId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.settingKey == this.settingKey &&
          other.businessId == this.businessId &&
          other.valueJson == this.valueJson &&
          other.updatedAtMs == this.updatedAtMs &&
          other.updatedByUserId == this.updatedByUserId);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> settingKey;
  final Value<String> businessId;
  final Value<String> valueJson;
  final Value<int> updatedAtMs;
  final Value<String?> updatedByUserId;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.settingKey = const Value.absent(),
    this.businessId = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.updatedByUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String settingKey,
    required String businessId,
    required String valueJson,
    required int updatedAtMs,
    this.updatedByUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       businessId = Value(businessId),
       valueJson = Value(valueJson),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<AppSettingRow> custom({
    Expression<String>? settingKey,
    Expression<String>? businessId,
    Expression<String>? valueJson,
    Expression<int>? updatedAtMs,
    Expression<String>? updatedByUserId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (businessId != null) 'business_id': businessId,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (updatedByUserId != null) 'updated_by_user_id': updatedByUserId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? businessId,
    Value<String>? valueJson,
    Value<int>? updatedAtMs,
    Value<String?>? updatedByUserId,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      businessId: businessId ?? this.businessId,
      valueJson: valueJson ?? this.valueJson,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (updatedByUserId.present) {
      map['updated_by_user_id'] = Variable<String>(updatedByUserId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('businessId: $businessId, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('updatedByUserId: $updatedByUserId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_business (business_id)',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dependsOnOperationIdMeta =
      const VerificationMeta('dependsOnOperationId');
  @override
  late final GeneratedColumn<String> dependsOnOperationId =
      GeneratedColumn<String>(
        'depends_on_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES sync_operations (operation_id)',
        ),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMessageMeta = const VerificationMeta(
    'lastErrorMessage',
  );
  @override
  late final GeneratedColumn<String> lastErrorMessage = GeneratedColumn<String>(
    'last_error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAttemptAtMsMeta = const VerificationMeta(
    'lastAttemptAtMs',
  );
  @override
  late final GeneratedColumn<int> lastAttemptAtMs = GeneratedColumn<int>(
    'last_attempt_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acknowledgedAtMsMeta = const VerificationMeta(
    'acknowledgedAtMs',
  );
  @override
  late final GeneratedColumn<int> acknowledgedAtMs = GeneratedColumn<int>(
    'acknowledged_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    businessId,
    deviceId,
    entityType,
    entityId,
    operationType,
    payloadJson,
    dependsOnOperationId,
    status,
    retryCount,
    lastErrorCode,
    lastErrorMessage,
    lastAttemptAtMs,
    acknowledgedAtMs,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOperationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('depends_on_operation_id')) {
      context.handle(
        _dependsOnOperationIdMeta,
        dependsOnOperationId.isAcceptableOrUnknown(
          data['depends_on_operation_id']!,
          _dependsOnOperationIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('last_error_message')) {
      context.handle(
        _lastErrorMessageMeta,
        lastErrorMessage.isAcceptableOrUnknown(
          data['last_error_message']!,
          _lastErrorMessageMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at_ms')) {
      context.handle(
        _lastAttemptAtMsMeta,
        lastAttemptAtMs.isAcceptableOrUnknown(
          data['last_attempt_at_ms']!,
          _lastAttemptAtMsMeta,
        ),
      );
    }
    if (data.containsKey('acknowledged_at_ms')) {
      context.handle(
        _acknowledgedAtMsMeta,
        acknowledgedAtMs.isAcceptableOrUnknown(
          data['acknowledged_at_ms']!,
          _acknowledgedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncOperationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperationRow(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      dependsOnOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depends_on_operation_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      lastErrorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_message'],
      ),
      lastAttemptAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_attempt_at_ms'],
      ),
      acknowledgedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}acknowledged_at_ms'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }
}

class SyncOperationRow extends DataClass
    implements Insertable<SyncOperationRow> {
  final String operationId;
  final String businessId;
  final String deviceId;
  final String entityType;
  final String entityId;
  final String operationType;
  final String payloadJson;
  final String? dependsOnOperationId;
  final String status;
  final int retryCount;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final int? lastAttemptAtMs;
  final int? acknowledgedAtMs;
  final int createdAtMs;
  final int updatedAtMs;
  const SyncOperationRow({
    required this.operationId,
    required this.businessId,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payloadJson,
    this.dependsOnOperationId,
    required this.status,
    required this.retryCount,
    this.lastErrorCode,
    this.lastErrorMessage,
    this.lastAttemptAtMs,
    this.acknowledgedAtMs,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['business_id'] = Variable<String>(businessId);
    map['device_id'] = Variable<String>(deviceId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || dependsOnOperationId != null) {
      map['depends_on_operation_id'] = Variable<String>(dependsOnOperationId);
    }
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    if (!nullToAbsent || lastErrorMessage != null) {
      map['last_error_message'] = Variable<String>(lastErrorMessage);
    }
    if (!nullToAbsent || lastAttemptAtMs != null) {
      map['last_attempt_at_ms'] = Variable<int>(lastAttemptAtMs);
    }
    if (!nullToAbsent || acknowledgedAtMs != null) {
      map['acknowledged_at_ms'] = Variable<int>(acknowledgedAtMs);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      operationId: Value(operationId),
      businessId: Value(businessId),
      deviceId: Value(deviceId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      payloadJson: Value(payloadJson),
      dependsOnOperationId: dependsOnOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOnOperationId),
      status: Value(status),
      retryCount: Value(retryCount),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      lastErrorMessage: lastErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorMessage),
      lastAttemptAtMs: lastAttemptAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAtMs),
      acknowledgedAtMs: acknowledgedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(acknowledgedAtMs),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory SyncOperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperationRow(
      operationId: serializer.fromJson<String>(json['operationId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      dependsOnOperationId: serializer.fromJson<String?>(
        json['dependsOnOperationId'],
      ),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      lastErrorMessage: serializer.fromJson<String?>(json['lastErrorMessage']),
      lastAttemptAtMs: serializer.fromJson<int?>(json['lastAttemptAtMs']),
      acknowledgedAtMs: serializer.fromJson<int?>(json['acknowledgedAtMs']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'businessId': serializer.toJson<String>(businessId),
      'deviceId': serializer.toJson<String>(deviceId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'dependsOnOperationId': serializer.toJson<String?>(dependsOnOperationId),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'lastErrorMessage': serializer.toJson<String?>(lastErrorMessage),
      'lastAttemptAtMs': serializer.toJson<int?>(lastAttemptAtMs),
      'acknowledgedAtMs': serializer.toJson<int?>(acknowledgedAtMs),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  SyncOperationRow copyWith({
    String? operationId,
    String? businessId,
    String? deviceId,
    String? entityType,
    String? entityId,
    String? operationType,
    String? payloadJson,
    Value<String?> dependsOnOperationId = const Value.absent(),
    String? status,
    int? retryCount,
    Value<String?> lastErrorCode = const Value.absent(),
    Value<String?> lastErrorMessage = const Value.absent(),
    Value<int?> lastAttemptAtMs = const Value.absent(),
    Value<int?> acknowledgedAtMs = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
  }) => SyncOperationRow(
    operationId: operationId ?? this.operationId,
    businessId: businessId ?? this.businessId,
    deviceId: deviceId ?? this.deviceId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    payloadJson: payloadJson ?? this.payloadJson,
    dependsOnOperationId: dependsOnOperationId.present
        ? dependsOnOperationId.value
        : this.dependsOnOperationId,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    lastErrorMessage: lastErrorMessage.present
        ? lastErrorMessage.value
        : this.lastErrorMessage,
    lastAttemptAtMs: lastAttemptAtMs.present
        ? lastAttemptAtMs.value
        : this.lastAttemptAtMs,
    acknowledgedAtMs: acknowledgedAtMs.present
        ? acknowledgedAtMs.value
        : this.acknowledgedAtMs,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  SyncOperationRow copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperationRow(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      dependsOnOperationId: data.dependsOnOperationId.present
          ? data.dependsOnOperationId.value
          : this.dependsOnOperationId,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      lastErrorMessage: data.lastErrorMessage.present
          ? data.lastErrorMessage.value
          : this.lastErrorMessage,
      lastAttemptAtMs: data.lastAttemptAtMs.present
          ? data.lastAttemptAtMs.value
          : this.lastAttemptAtMs,
      acknowledgedAtMs: data.acknowledgedAtMs.present
          ? data.acknowledgedAtMs.value
          : this.acknowledgedAtMs,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationRow(')
          ..write('operationId: $operationId, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependsOnOperationId: $dependsOnOperationId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('lastAttemptAtMs: $lastAttemptAtMs, ')
          ..write('acknowledgedAtMs: $acknowledgedAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    businessId,
    deviceId,
    entityType,
    entityId,
    operationType,
    payloadJson,
    dependsOnOperationId,
    status,
    retryCount,
    lastErrorCode,
    lastErrorMessage,
    lastAttemptAtMs,
    acknowledgedAtMs,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperationRow &&
          other.operationId == this.operationId &&
          other.businessId == this.businessId &&
          other.deviceId == this.deviceId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.payloadJson == this.payloadJson &&
          other.dependsOnOperationId == this.dependsOnOperationId &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastErrorCode == this.lastErrorCode &&
          other.lastErrorMessage == this.lastErrorMessage &&
          other.lastAttemptAtMs == this.lastAttemptAtMs &&
          other.acknowledgedAtMs == this.acknowledgedAtMs &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperationRow> {
  final Value<String> operationId;
  final Value<String> businessId;
  final Value<String> deviceId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<String> payloadJson;
  final Value<String?> dependsOnOperationId;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastErrorCode;
  final Value<String?> lastErrorMessage;
  final Value<int?> lastAttemptAtMs;
  final Value<int?> acknowledgedAtMs;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const SyncOperationsCompanion({
    this.operationId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.dependsOnOperationId = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.lastAttemptAtMs = const Value.absent(),
    this.acknowledgedAtMs = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    required String operationId,
    required String businessId,
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operationType,
    required String payloadJson,
    this.dependsOnOperationId = const Value.absent(),
    required String status,
    this.retryCount = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
    this.lastAttemptAtMs = const Value.absent(),
    this.acknowledgedAtMs = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       businessId = Value(businessId),
       deviceId = Value(deviceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       payloadJson = Value(payloadJson),
       status = Value(status),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<SyncOperationRow> custom({
    Expression<String>? operationId,
    Expression<String>? businessId,
    Expression<String>? deviceId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? payloadJson,
    Expression<String>? dependsOnOperationId,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastErrorCode,
    Expression<String>? lastErrorMessage,
    Expression<int>? lastAttemptAtMs,
    Expression<int>? acknowledgedAtMs,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (businessId != null) 'business_id': businessId,
      if (deviceId != null) 'device_id': deviceId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (dependsOnOperationId != null)
        'depends_on_operation_id': dependsOnOperationId,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (lastErrorMessage != null) 'last_error_message': lastErrorMessage,
      if (lastAttemptAtMs != null) 'last_attempt_at_ms': lastAttemptAtMs,
      if (acknowledgedAtMs != null) 'acknowledged_at_ms': acknowledgedAtMs,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOperationsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? businessId,
    Value<String>? deviceId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operationType,
    Value<String>? payloadJson,
    Value<String?>? dependsOnOperationId,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? lastErrorCode,
    Value<String?>? lastErrorMessage,
    Value<int?>? lastAttemptAtMs,
    Value<int?>? acknowledgedAtMs,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return SyncOperationsCompanion(
      operationId: operationId ?? this.operationId,
      businessId: businessId ?? this.businessId,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payloadJson: payloadJson ?? this.payloadJson,
      dependsOnOperationId: dependsOnOperationId ?? this.dependsOnOperationId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      lastAttemptAtMs: lastAttemptAtMs ?? this.lastAttemptAtMs,
      acknowledgedAtMs: acknowledgedAtMs ?? this.acknowledgedAtMs,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (dependsOnOperationId.present) {
      map['depends_on_operation_id'] = Variable<String>(
        dependsOnOperationId.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (lastErrorMessage.present) {
      map['last_error_message'] = Variable<String>(lastErrorMessage.value);
    }
    if (lastAttemptAtMs.present) {
      map['last_attempt_at_ms'] = Variable<int>(lastAttemptAtMs.value);
    }
    if (acknowledgedAtMs.present) {
      map['acknowledged_at_ms'] = Variable<int>(acknowledgedAtMs.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('dependsOnOperationId: $dependsOnOperationId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('lastErrorMessage: $lastErrorMessage, ')
          ..write('lastAttemptAtMs: $lastAttemptAtMs, ')
          ..write('acknowledgedAtMs: $acknowledgedAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _streamNameMeta = const VerificationMeta(
    'streamName',
  );
  @override
  late final GeneratedColumn<String> streamName = GeneratedColumn<String>(
    'stream_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_business (business_id)',
    ),
  );
  static const VerificationMeta _cursorValueMeta = const VerificationMeta(
    'cursorValue',
  );
  @override
  late final GeneratedColumn<String> cursorValue = GeneratedColumn<String>(
    'cursor_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    streamName,
    businessId,
    cursorValue,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stream_name')) {
      context.handle(
        _streamNameMeta,
        streamName.isAcceptableOrUnknown(data['stream_name']!, _streamNameMeta),
      );
    } else if (isInserting) {
      context.missing(_streamNameMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('cursor_value')) {
      context.handle(
        _cursorValueMeta,
        cursorValue.isAcceptableOrUnknown(
          data['cursor_value']!,
          _cursorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cursorValueMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {streamName};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      streamName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stream_name'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      cursorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor_value'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String streamName;
  final String businessId;
  final String cursorValue;
  final int updatedAtMs;
  const SyncCursorRow({
    required this.streamName,
    required this.businessId,
    required this.cursorValue,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stream_name'] = Variable<String>(streamName);
    map['business_id'] = Variable<String>(businessId);
    map['cursor_value'] = Variable<String>(cursorValue);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      streamName: Value(streamName),
      businessId: Value(businessId),
      cursorValue: Value(cursorValue),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      streamName: serializer.fromJson<String>(json['streamName']),
      businessId: serializer.fromJson<String>(json['businessId']),
      cursorValue: serializer.fromJson<String>(json['cursorValue']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'streamName': serializer.toJson<String>(streamName),
      'businessId': serializer.toJson<String>(businessId),
      'cursorValue': serializer.toJson<String>(cursorValue),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  SyncCursorRow copyWith({
    String? streamName,
    String? businessId,
    String? cursorValue,
    int? updatedAtMs,
  }) => SyncCursorRow(
    streamName: streamName ?? this.streamName,
    businessId: businessId ?? this.businessId,
    cursorValue: cursorValue ?? this.cursorValue,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      streamName: data.streamName.present
          ? data.streamName.value
          : this.streamName,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      cursorValue: data.cursorValue.present
          ? data.cursorValue.value
          : this.cursorValue,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('streamName: $streamName, ')
          ..write('businessId: $businessId, ')
          ..write('cursorValue: $cursorValue, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(streamName, businessId, cursorValue, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.streamName == this.streamName &&
          other.businessId == this.businessId &&
          other.cursorValue == this.cursorValue &&
          other.updatedAtMs == this.updatedAtMs);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> streamName;
  final Value<String> businessId;
  final Value<String> cursorValue;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.streamName = const Value.absent(),
    this.businessId = const Value.absent(),
    this.cursorValue = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String streamName,
    required String businessId,
    required String cursorValue,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : streamName = Value(streamName),
       businessId = Value(businessId),
       cursorValue = Value(cursorValue),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? streamName,
    Expression<String>? businessId,
    Expression<String>? cursorValue,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (streamName != null) 'stream_name': streamName,
      if (businessId != null) 'business_id': businessId,
      if (cursorValue != null) 'cursor_value': cursorValue,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? streamName,
    Value<String>? businessId,
    Value<String>? cursorValue,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      streamName: streamName ?? this.streamName,
      businessId: businessId ?? this.businessId,
      cursorValue: cursorValue ?? this.cursorValue,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (streamName.present) {
      map['stream_name'] = Variable<String>(streamName.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (cursorValue.present) {
      map['cursor_value'] = Variable<String>(cursorValue.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('streamName: $streamName, ')
          ..write('businessId: $businessId, ')
          ..write('cursorValue: $cursorValue, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conflictIdMeta = const VerificationMeta(
    'conflictId',
  );
  @override
  late final GeneratedColumn<String> conflictId = GeneratedColumn<String>(
    'conflict_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_business (business_id)',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localSnapshotJsonMeta = const VerificationMeta(
    'localSnapshotJson',
  );
  @override
  late final GeneratedColumn<String> localSnapshotJson =
      GeneratedColumn<String>(
        'local_snapshot_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _remoteSnapshotJsonMeta =
      const VerificationMeta('remoteSnapshotJson');
  @override
  late final GeneratedColumn<String> remoteSnapshotJson =
      GeneratedColumn<String>(
        'remote_snapshot_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMsMeta = const VerificationMeta(
    'resolvedAtMs',
  );
  @override
  late final GeneratedColumn<int> resolvedAtMs = GeneratedColumn<int>(
    'resolved_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    conflictId,
    businessId,
    entityType,
    entityId,
    localSnapshotJson,
    remoteSnapshotJson,
    status,
    createdAtMs,
    resolvedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conflict_id')) {
      context.handle(
        _conflictIdMeta,
        conflictId.isAcceptableOrUnknown(data['conflict_id']!, _conflictIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conflictIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_snapshot_json')) {
      context.handle(
        _localSnapshotJsonMeta,
        localSnapshotJson.isAcceptableOrUnknown(
          data['local_snapshot_json']!,
          _localSnapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localSnapshotJsonMeta);
    }
    if (data.containsKey('remote_snapshot_json')) {
      context.handle(
        _remoteSnapshotJsonMeta,
        remoteSnapshotJson.isAcceptableOrUnknown(
          data['remote_snapshot_json']!,
          _remoteSnapshotJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('resolved_at_ms')) {
      context.handle(
        _resolvedAtMsMeta,
        resolvedAtMs.isAcceptableOrUnknown(
          data['resolved_at_ms']!,
          _resolvedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conflictId};
  @override
  SyncConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictRow(
      conflictId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_snapshot_json'],
      )!,
      remoteSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_snapshot_json'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      resolvedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at_ms'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflictRow extends DataClass implements Insertable<SyncConflictRow> {
  final String conflictId;
  final String businessId;
  final String entityType;
  final String entityId;
  final String localSnapshotJson;
  final String? remoteSnapshotJson;
  final String status;
  final int createdAtMs;
  final int? resolvedAtMs;
  const SyncConflictRow({
    required this.conflictId,
    required this.businessId,
    required this.entityType,
    required this.entityId,
    required this.localSnapshotJson,
    this.remoteSnapshotJson,
    required this.status,
    required this.createdAtMs,
    this.resolvedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conflict_id'] = Variable<String>(conflictId);
    map['business_id'] = Variable<String>(businessId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['local_snapshot_json'] = Variable<String>(localSnapshotJson);
    if (!nullToAbsent || remoteSnapshotJson != null) {
      map['remote_snapshot_json'] = Variable<String>(remoteSnapshotJson);
    }
    map['status'] = Variable<String>(status);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    if (!nullToAbsent || resolvedAtMs != null) {
      map['resolved_at_ms'] = Variable<int>(resolvedAtMs);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      conflictId: Value(conflictId),
      businessId: Value(businessId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localSnapshotJson: Value(localSnapshotJson),
      remoteSnapshotJson: remoteSnapshotJson == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteSnapshotJson),
      status: Value(status),
      createdAtMs: Value(createdAtMs),
      resolvedAtMs: resolvedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAtMs),
    );
  }

  factory SyncConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictRow(
      conflictId: serializer.fromJson<String>(json['conflictId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localSnapshotJson: serializer.fromJson<String>(json['localSnapshotJson']),
      remoteSnapshotJson: serializer.fromJson<String?>(
        json['remoteSnapshotJson'],
      ),
      status: serializer.fromJson<String>(json['status']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      resolvedAtMs: serializer.fromJson<int?>(json['resolvedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conflictId': serializer.toJson<String>(conflictId),
      'businessId': serializer.toJson<String>(businessId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localSnapshotJson': serializer.toJson<String>(localSnapshotJson),
      'remoteSnapshotJson': serializer.toJson<String?>(remoteSnapshotJson),
      'status': serializer.toJson<String>(status),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'resolvedAtMs': serializer.toJson<int?>(resolvedAtMs),
    };
  }

  SyncConflictRow copyWith({
    String? conflictId,
    String? businessId,
    String? entityType,
    String? entityId,
    String? localSnapshotJson,
    Value<String?> remoteSnapshotJson = const Value.absent(),
    String? status,
    int? createdAtMs,
    Value<int?> resolvedAtMs = const Value.absent(),
  }) => SyncConflictRow(
    conflictId: conflictId ?? this.conflictId,
    businessId: businessId ?? this.businessId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localSnapshotJson: localSnapshotJson ?? this.localSnapshotJson,
    remoteSnapshotJson: remoteSnapshotJson.present
        ? remoteSnapshotJson.value
        : this.remoteSnapshotJson,
    status: status ?? this.status,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    resolvedAtMs: resolvedAtMs.present ? resolvedAtMs.value : this.resolvedAtMs,
  );
  SyncConflictRow copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflictRow(
      conflictId: data.conflictId.present
          ? data.conflictId.value
          : this.conflictId,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localSnapshotJson: data.localSnapshotJson.present
          ? data.localSnapshotJson.value
          : this.localSnapshotJson,
      remoteSnapshotJson: data.remoteSnapshotJson.present
          ? data.remoteSnapshotJson.value
          : this.remoteSnapshotJson,
      status: data.status.present ? data.status.value : this.status,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      resolvedAtMs: data.resolvedAtMs.present
          ? data.resolvedAtMs.value
          : this.resolvedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRow(')
          ..write('conflictId: $conflictId, ')
          ..write('businessId: $businessId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localSnapshotJson: $localSnapshotJson, ')
          ..write('remoteSnapshotJson: $remoteSnapshotJson, ')
          ..write('status: $status, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('resolvedAtMs: $resolvedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conflictId,
    businessId,
    entityType,
    entityId,
    localSnapshotJson,
    remoteSnapshotJson,
    status,
    createdAtMs,
    resolvedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictRow &&
          other.conflictId == this.conflictId &&
          other.businessId == this.businessId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localSnapshotJson == this.localSnapshotJson &&
          other.remoteSnapshotJson == this.remoteSnapshotJson &&
          other.status == this.status &&
          other.createdAtMs == this.createdAtMs &&
          other.resolvedAtMs == this.resolvedAtMs);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflictRow> {
  final Value<String> conflictId;
  final Value<String> businessId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> localSnapshotJson;
  final Value<String?> remoteSnapshotJson;
  final Value<String> status;
  final Value<int> createdAtMs;
  final Value<int?> resolvedAtMs;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.conflictId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localSnapshotJson = const Value.absent(),
    this.remoteSnapshotJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.resolvedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String conflictId,
    required String businessId,
    required String entityType,
    required String entityId,
    required String localSnapshotJson,
    this.remoteSnapshotJson = const Value.absent(),
    required String status,
    required int createdAtMs,
    this.resolvedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conflictId = Value(conflictId),
       businessId = Value(businessId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localSnapshotJson = Value(localSnapshotJson),
       status = Value(status),
       createdAtMs = Value(createdAtMs);
  static Insertable<SyncConflictRow> custom({
    Expression<String>? conflictId,
    Expression<String>? businessId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? localSnapshotJson,
    Expression<String>? remoteSnapshotJson,
    Expression<String>? status,
    Expression<int>? createdAtMs,
    Expression<int>? resolvedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conflictId != null) 'conflict_id': conflictId,
      if (businessId != null) 'business_id': businessId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localSnapshotJson != null) 'local_snapshot_json': localSnapshotJson,
      if (remoteSnapshotJson != null)
        'remote_snapshot_json': remoteSnapshotJson,
      if (status != null) 'status': status,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (resolvedAtMs != null) 'resolved_at_ms': resolvedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? conflictId,
    Value<String>? businessId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? localSnapshotJson,
    Value<String?>? remoteSnapshotJson,
    Value<String>? status,
    Value<int>? createdAtMs,
    Value<int?>? resolvedAtMs,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      conflictId: conflictId ?? this.conflictId,
      businessId: businessId ?? this.businessId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localSnapshotJson: localSnapshotJson ?? this.localSnapshotJson,
      remoteSnapshotJson: remoteSnapshotJson ?? this.remoteSnapshotJson,
      status: status ?? this.status,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      resolvedAtMs: resolvedAtMs ?? this.resolvedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conflictId.present) {
      map['conflict_id'] = Variable<String>(conflictId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localSnapshotJson.present) {
      map['local_snapshot_json'] = Variable<String>(localSnapshotJson.value);
    }
    if (remoteSnapshotJson.present) {
      map['remote_snapshot_json'] = Variable<String>(remoteSnapshotJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (resolvedAtMs.present) {
      map['resolved_at_ms'] = Variable<int>(resolvedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('conflictId: $conflictId, ')
          ..write('businessId: $businessId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localSnapshotJson: $localSnapshotJson, ')
          ..write('remoteSnapshotJson: $remoteSnapshotJson, ')
          ..write('status: $status, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('resolvedAtMs: $resolvedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditEventsTable extends AuditEvents
    with TableInfo<$AuditEventsTable, AuditEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES local_business (business_id)',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorUserIdMeta = const VerificationMeta(
    'actorUserId',
  );
  @override
  late final GeneratedColumn<String> actorUserId = GeneratedColumn<String>(
    'actor_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    businessId,
    deviceId,
    actorUserId,
    eventType,
    entityType,
    entityId,
    metadataJson,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('actor_user_id')) {
      context.handle(
        _actorUserIdMeta,
        actorUserId.isAcceptableOrUnknown(
          data['actor_user_id']!,
          _actorUserIdMeta,
        ),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  AuditEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditEventRow(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      actorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_user_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $AuditEventsTable createAlias(String alias) {
    return $AuditEventsTable(attachedDatabase, alias);
  }
}

class AuditEventRow extends DataClass implements Insertable<AuditEventRow> {
  final String eventId;
  final String businessId;
  final String deviceId;
  final String? actorUserId;
  final String eventType;
  final String? entityType;
  final String? entityId;
  final String metadataJson;
  final int createdAtMs;
  const AuditEventRow({
    required this.eventId,
    required this.businessId,
    required this.deviceId,
    this.actorUserId,
    required this.eventType,
    this.entityType,
    this.entityId,
    required this.metadataJson,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['business_id'] = Variable<String>(businessId);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || actorUserId != null) {
      map['actor_user_id'] = Variable<String>(actorUserId);
    }
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || entityType != null) {
      map['entity_type'] = Variable<String>(entityType);
    }
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['metadata_json'] = Variable<String>(metadataJson);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  AuditEventsCompanion toCompanion(bool nullToAbsent) {
    return AuditEventsCompanion(
      eventId: Value(eventId),
      businessId: Value(businessId),
      deviceId: Value(deviceId),
      actorUserId: actorUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorUserId),
      eventType: Value(eventType),
      entityType: entityType == null && nullToAbsent
          ? const Value.absent()
          : Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      metadataJson: Value(metadataJson),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory AuditEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditEventRow(
      eventId: serializer.fromJson<String>(json['eventId']),
      businessId: serializer.fromJson<String>(json['businessId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      actorUserId: serializer.fromJson<String?>(json['actorUserId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      entityType: serializer.fromJson<String?>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'businessId': serializer.toJson<String>(businessId),
      'deviceId': serializer.toJson<String>(deviceId),
      'actorUserId': serializer.toJson<String?>(actorUserId),
      'eventType': serializer.toJson<String>(eventType),
      'entityType': serializer.toJson<String?>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  AuditEventRow copyWith({
    String? eventId,
    String? businessId,
    String? deviceId,
    Value<String?> actorUserId = const Value.absent(),
    String? eventType,
    Value<String?> entityType = const Value.absent(),
    Value<String?> entityId = const Value.absent(),
    String? metadataJson,
    int? createdAtMs,
  }) => AuditEventRow(
    eventId: eventId ?? this.eventId,
    businessId: businessId ?? this.businessId,
    deviceId: deviceId ?? this.deviceId,
    actorUserId: actorUserId.present ? actorUserId.value : this.actorUserId,
    eventType: eventType ?? this.eventType,
    entityType: entityType.present ? entityType.value : this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    metadataJson: metadataJson ?? this.metadataJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  AuditEventRow copyWithCompanion(AuditEventsCompanion data) {
    return AuditEventRow(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      actorUserId: data.actorUserId.present
          ? data.actorUserId.value
          : this.actorUserId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditEventRow(')
          ..write('eventId: $eventId, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    businessId,
    deviceId,
    actorUserId,
    eventType,
    entityType,
    entityId,
    metadataJson,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditEventRow &&
          other.eventId == this.eventId &&
          other.businessId == this.businessId &&
          other.deviceId == this.deviceId &&
          other.actorUserId == this.actorUserId &&
          other.eventType == this.eventType &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.metadataJson == this.metadataJson &&
          other.createdAtMs == this.createdAtMs);
}

class AuditEventsCompanion extends UpdateCompanion<AuditEventRow> {
  final Value<String> eventId;
  final Value<String> businessId;
  final Value<String> deviceId;
  final Value<String?> actorUserId;
  final Value<String> eventType;
  final Value<String?> entityType;
  final Value<String?> entityId;
  final Value<String> metadataJson;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const AuditEventsCompanion({
    this.eventId = const Value.absent(),
    this.businessId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.actorUserId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditEventsCompanion.insert({
    required String eventId,
    required String businessId,
    required String deviceId,
    this.actorUserId = const Value.absent(),
    required String eventType,
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       businessId = Value(businessId),
       deviceId = Value(deviceId),
       eventType = Value(eventType),
       createdAtMs = Value(createdAtMs);
  static Insertable<AuditEventRow> custom({
    Expression<String>? eventId,
    Expression<String>? businessId,
    Expression<String>? deviceId,
    Expression<String>? actorUserId,
    Expression<String>? eventType,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? metadataJson,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (businessId != null) 'business_id': businessId,
      if (deviceId != null) 'device_id': deviceId,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (eventType != null) 'event_type': eventType,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? businessId,
    Value<String>? deviceId,
    Value<String?>? actorUserId,
    Value<String>? eventType,
    Value<String?>? entityType,
    Value<String?>? entityId,
    Value<String>? metadataJson,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return AuditEventsCompanion(
      eventId: eventId ?? this.eventId,
      businessId: businessId ?? this.businessId,
      deviceId: deviceId ?? this.deviceId,
      actorUserId: actorUserId ?? this.actorUserId,
      eventType: eventType ?? this.eventType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (actorUserId.present) {
      map['actor_user_id'] = Variable<String>(actorUserId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('businessId: $businessId, ')
          ..write('deviceId: $deviceId, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LegacyV1AppDatabase extends GeneratedDatabase {
  _$LegacyV1AppDatabase(QueryExecutor e) : super(e);
  $LegacyV1AppDatabaseManager get managers => $LegacyV1AppDatabaseManager(this);
  late final $LocalBusinessTable localBusiness = $LocalBusinessTable(this);
  late final $LocalDeviceTable localDevice = $LocalDeviceTable(this);
  late final $UsersCacheTable usersCache = $UsersCacheTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $AuditEventsTable auditEvents = $AuditEventsTable(this);
  late final Index syncOpsStatusCreated = Index(
    'sync_ops_status_created',
    'CREATE INDEX sync_ops_status_created ON sync_operations (status, created_at_ms)',
  );
  late final Index syncOpsEntity = Index(
    'sync_ops_entity',
    'CREATE INDEX sync_ops_entity ON sync_operations (business_id, entity_type, entity_id)',
  );
  late final Index syncOpsDependsOn = Index(
    'sync_ops_depends_on',
    'CREATE INDEX sync_ops_depends_on ON sync_operations (depends_on_operation_id)',
  );
  late final Index syncConflictsStatus = Index(
    'sync_conflicts_status',
    'CREATE INDEX sync_conflicts_status ON sync_conflicts (status, created_at_ms)',
  );
  late final Index syncConflictsEntity = Index(
    'sync_conflicts_entity',
    'CREATE INDEX sync_conflicts_entity ON sync_conflicts (entity_type, entity_id)',
  );
  late final Index auditEventsCreated = Index(
    'audit_events_created',
    'CREATE INDEX audit_events_created ON audit_events (created_at_ms)',
  );
  late final Index auditEventsType = Index(
    'audit_events_type',
    'CREATE INDEX audit_events_type ON audit_events (business_id, event_type, created_at_ms)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localBusiness,
    localDevice,
    usersCache,
    appSettings,
    syncOperations,
    syncCursors,
    syncConflicts,
    auditEvents,
    syncOpsStatusCreated,
    syncOpsEntity,
    syncOpsDependsOn,
    syncConflictsStatus,
    syncConflictsEntity,
    auditEventsCreated,
    auditEventsType,
  ];
}

typedef $$LocalBusinessTableCreateCompanionBuilder =
    LocalBusinessCompanion Function({
      Value<int> singletonId,
      required String businessId,
      required String name,
      Value<String?> legalName,
      Value<String?> phone,
      Value<String?> address,
      Value<String> timezoneId,
      Value<String> currencyCode,
      Value<String> settingsJson,
      required int createdAtMs,
      required int updatedAtMs,
    });
typedef $$LocalBusinessTableUpdateCompanionBuilder =
    LocalBusinessCompanion Function({
      Value<int> singletonId,
      Value<String> businessId,
      Value<String> name,
      Value<String?> legalName,
      Value<String?> phone,
      Value<String?> address,
      Value<String> timezoneId,
      Value<String> currencyCode,
      Value<String> settingsJson,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
    });

final class $$LocalBusinessTableReferences
    extends
        BaseReferences<
          _$LegacyV1AppDatabase,
          $LocalBusinessTable,
          LocalBusinessRow
        > {
  $$LocalBusinessTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$LocalDeviceTable, List<LocalDeviceRow>>
  _localDeviceRefsTable(_$LegacyV1AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.localDevice,
        aliasName: 'local_business__business_id__local_device__business_id',
      );

  $$LocalDeviceTableProcessedTableManager get localDeviceRefs {
    final manager = $$LocalDeviceTableTableManager($_db, $_db.localDevice)
        .filter(
          (f) => f.businessId.businessId.sqlEquals(
            $_itemColumn<String>('business_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_localDeviceRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UsersCacheTable, List<UsersCacheRow>>
  _usersCacheRefsTable(_$LegacyV1AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.usersCache,
        aliasName: 'local_business__business_id__users_cache__business_id',
      );

  $$UsersCacheTableProcessedTableManager get usersCacheRefs {
    final manager = $$UsersCacheTableTableManager($_db, $_db.usersCache).filter(
      (f) => f.businessId.businessId.sqlEquals(
        $_itemColumn<String>('business_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_usersCacheRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppSettingsTable, List<AppSettingRow>>
  _appSettingsRefsTable(_$LegacyV1AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.appSettings,
        aliasName: 'local_business__business_id__app_settings__business_id',
      );

  $$AppSettingsTableProcessedTableManager get appSettingsRefs {
    final manager = $$AppSettingsTableTableManager($_db, $_db.appSettings)
        .filter(
          (f) => f.businessId.businessId.sqlEquals(
            $_itemColumn<String>('business_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_appSettingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncOperationsTable, List<SyncOperationRow>>
  _syncOperationsRefsTable(_$LegacyV1AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.syncOperations,
        aliasName: 'local_business__business_id__sync_operations__business_id',
      );

  $$SyncOperationsTableProcessedTableManager get syncOperationsRefs {
    final manager = $$SyncOperationsTableTableManager($_db, $_db.syncOperations)
        .filter(
          (f) => f.businessId.businessId.sqlEquals(
            $_itemColumn<String>('business_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_syncOperationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncCursorsTable, List<SyncCursorRow>>
  _syncCursorsRefsTable(_$LegacyV1AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.syncCursors,
        aliasName: 'local_business__business_id__sync_cursors__business_id',
      );

  $$SyncCursorsTableProcessedTableManager get syncCursorsRefs {
    final manager = $$SyncCursorsTableTableManager($_db, $_db.syncCursors)
        .filter(
          (f) => f.businessId.businessId.sqlEquals(
            $_itemColumn<String>('business_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_syncCursorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncConflictsTable, List<SyncConflictRow>>
  _syncConflictsRefsTable(_$LegacyV1AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.syncConflicts,
        aliasName: 'local_business__business_id__sync_conflicts__business_id',
      );

  $$SyncConflictsTableProcessedTableManager get syncConflictsRefs {
    final manager = $$SyncConflictsTableTableManager($_db, $_db.syncConflicts)
        .filter(
          (f) => f.businessId.businessId.sqlEquals(
            $_itemColumn<String>('business_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_syncConflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditEventsTable, List<AuditEventRow>>
  _auditEventsRefsTable(_$LegacyV1AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.auditEvents,
        aliasName: 'local_business__business_id__audit_events__business_id',
      );

  $$AuditEventsTableProcessedTableManager get auditEventsRefs {
    final manager = $$AuditEventsTableTableManager($_db, $_db.auditEvents)
        .filter(
          (f) => f.businessId.businessId.sqlEquals(
            $_itemColumn<String>('business_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_auditEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocalBusinessTableFilterComposer
    extends Composer<_$LegacyV1AppDatabase, $LocalBusinessTable> {
  $$LocalBusinessTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezoneId => $composableBuilder(
    column: $table.timezoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localDeviceRefs(
    Expression<bool> Function($$LocalDeviceTableFilterComposer f) f,
  ) {
    final $$LocalDeviceTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localDevice,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalDeviceTableFilterComposer(
            $db: $db,
            $table: $db.localDevice,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> usersCacheRefs(
    Expression<bool> Function($$UsersCacheTableFilterComposer f) f,
  ) {
    final $$UsersCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.usersCache,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersCacheTableFilterComposer(
            $db: $db,
            $table: $db.usersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appSettingsRefs(
    Expression<bool> Function($$AppSettingsTableFilterComposer f) f,
  ) {
    final $$AppSettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.appSettings,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppSettingsTableFilterComposer(
            $db: $db,
            $table: $db.appSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncOperationsRefs(
    Expression<bool> Function($$SyncOperationsTableFilterComposer f) f,
  ) {
    final $$SyncOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.syncOperations,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncOperationsTableFilterComposer(
            $db: $db,
            $table: $db.syncOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncCursorsRefs(
    Expression<bool> Function($$SyncCursorsTableFilterComposer f) f,
  ) {
    final $$SyncCursorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.syncCursors,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncCursorsTableFilterComposer(
            $db: $db,
            $table: $db.syncCursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncConflictsRefs(
    Expression<bool> Function($$SyncConflictsTableFilterComposer f) f,
  ) {
    final $$SyncConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.syncConflicts,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncConflictsTableFilterComposer(
            $db: $db,
            $table: $db.syncConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditEventsRefs(
    Expression<bool> Function($$AuditEventsTableFilterComposer f) f,
  ) {
    final $$AuditEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.auditEvents,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditEventsTableFilterComposer(
            $db: $db,
            $table: $db.auditEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalBusinessTableOrderingComposer
    extends Composer<_$LegacyV1AppDatabase, $LocalBusinessTable> {
  $$LocalBusinessTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalName => $composableBuilder(
    column: $table.legalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezoneId => $composableBuilder(
    column: $table.timezoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalBusinessTableAnnotationComposer
    extends Composer<_$LegacyV1AppDatabase, $LocalBusinessTable> {
  $$LocalBusinessTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get businessId => $composableBuilder(
    column: $table.businessId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get legalName =>
      $composableBuilder(column: $table.legalName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get timezoneId => $composableBuilder(
    column: $table.timezoneId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  Expression<T> localDeviceRefs<T extends Object>(
    Expression<T> Function($$LocalDeviceTableAnnotationComposer a) f,
  ) {
    final $$LocalDeviceTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localDevice,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalDeviceTableAnnotationComposer(
            $db: $db,
            $table: $db.localDevice,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> usersCacheRefs<T extends Object>(
    Expression<T> Function($$UsersCacheTableAnnotationComposer a) f,
  ) {
    final $$UsersCacheTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.usersCache,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersCacheTableAnnotationComposer(
            $db: $db,
            $table: $db.usersCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> appSettingsRefs<T extends Object>(
    Expression<T> Function($$AppSettingsTableAnnotationComposer a) f,
  ) {
    final $$AppSettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.appSettings,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppSettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.appSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncOperationsRefs<T extends Object>(
    Expression<T> Function($$SyncOperationsTableAnnotationComposer a) f,
  ) {
    final $$SyncOperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.syncOperations,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncOperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncCursorsRefs<T extends Object>(
    Expression<T> Function($$SyncCursorsTableAnnotationComposer a) f,
  ) {
    final $$SyncCursorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.syncCursors,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncCursorsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncCursors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncConflictsRefs<T extends Object>(
    Expression<T> Function($$SyncConflictsTableAnnotationComposer a) f,
  ) {
    final $$SyncConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.syncConflicts,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncConflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auditEventsRefs<T extends Object>(
    Expression<T> Function($$AuditEventsTableAnnotationComposer a) f,
  ) {
    final $$AuditEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.auditEvents,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocalBusinessTableTableManager
    extends
        RootTableManager<
          _$LegacyV1AppDatabase,
          $LocalBusinessTable,
          LocalBusinessRow,
          $$LocalBusinessTableFilterComposer,
          $$LocalBusinessTableOrderingComposer,
          $$LocalBusinessTableAnnotationComposer,
          $$LocalBusinessTableCreateCompanionBuilder,
          $$LocalBusinessTableUpdateCompanionBuilder,
          (LocalBusinessRow, $$LocalBusinessTableReferences),
          LocalBusinessRow,
          PrefetchHooks Function({
            bool localDeviceRefs,
            bool usersCacheRefs,
            bool appSettingsRefs,
            bool syncOperationsRefs,
            bool syncCursorsRefs,
            bool syncConflictsRefs,
            bool auditEventsRefs,
          })
        > {
  $$LocalBusinessTableTableManager(
    _$LegacyV1AppDatabase db,
    $LocalBusinessTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBusinessTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBusinessTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBusinessTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> legalName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> timezoneId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => LocalBusinessCompanion(
                singletonId: singletonId,
                businessId: businessId,
                name: name,
                legalName: legalName,
                phone: phone,
                address: address,
                timezoneId: timezoneId,
                currencyCode: currencyCode,
                settingsJson: settingsJson,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                required String businessId,
                required String name,
                Value<String?> legalName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> timezoneId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
              }) => LocalBusinessCompanion.insert(
                singletonId: singletonId,
                businessId: businessId,
                name: name,
                legalName: legalName,
                phone: phone,
                address: address,
                timezoneId: timezoneId,
                currencyCode: currencyCode,
                settingsJson: settingsJson,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalBusinessTable, LocalBusinessRow>(table),
                  $$LocalBusinessTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                localDeviceRefs = false,
                usersCacheRefs = false,
                appSettingsRefs = false,
                syncOperationsRefs = false,
                syncCursorsRefs = false,
                syncConflictsRefs = false,
                auditEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (localDeviceRefs) db.localDevice,
                    if (usersCacheRefs) db.usersCache,
                    if (appSettingsRefs) db.appSettings,
                    if (syncOperationsRefs) db.syncOperations,
                    if (syncCursorsRefs) db.syncCursors,
                    if (syncConflictsRefs) db.syncConflicts,
                    if (auditEventsRefs) db.auditEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (localDeviceRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalBusinessRow,
                          $LocalBusinessTable,
                          LocalDeviceRow,
                          $LocalDeviceTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalBusinessTableReferences
                              ._localDeviceRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalBusinessTableReferences(
                                db,
                                table,
                                p0,
                              ).localDeviceRefs,
                          currentColumn: 'business_id',
                          referencedColumn: 'business_id',
                          typedResults: items,
                        ),
                      if (usersCacheRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalBusinessRow,
                          $LocalBusinessTable,
                          UsersCacheRow,
                          $UsersCacheTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalBusinessTableReferences
                              ._usersCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalBusinessTableReferences(
                                db,
                                table,
                                p0,
                              ).usersCacheRefs,
                          currentColumn: 'business_id',
                          referencedColumn: 'business_id',
                          typedResults: items,
                        ),
                      if (appSettingsRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalBusinessRow,
                          $LocalBusinessTable,
                          AppSettingRow,
                          $AppSettingsTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalBusinessTableReferences
                              ._appSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalBusinessTableReferences(
                                db,
                                table,
                                p0,
                              ).appSettingsRefs,
                          currentColumn: 'business_id',
                          referencedColumn: 'business_id',
                          typedResults: items,
                        ),
                      if (syncOperationsRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalBusinessRow,
                          $LocalBusinessTable,
                          SyncOperationRow,
                          $SyncOperationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalBusinessTableReferences
                              ._syncOperationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalBusinessTableReferences(
                                db,
                                table,
                                p0,
                              ).syncOperationsRefs,
                          currentColumn: 'business_id',
                          referencedColumn: 'business_id',
                          typedResults: items,
                        ),
                      if (syncCursorsRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalBusinessRow,
                          $LocalBusinessTable,
                          SyncCursorRow,
                          $SyncCursorsTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalBusinessTableReferences
                              ._syncCursorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalBusinessTableReferences(
                                db,
                                table,
                                p0,
                              ).syncCursorsRefs,
                          currentColumn: 'business_id',
                          referencedColumn: 'business_id',
                          typedResults: items,
                        ),
                      if (syncConflictsRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalBusinessRow,
                          $LocalBusinessTable,
                          SyncConflictRow,
                          $SyncConflictsTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalBusinessTableReferences
                              ._syncConflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalBusinessTableReferences(
                                db,
                                table,
                                p0,
                              ).syncConflictsRefs,
                          currentColumn: 'business_id',
                          referencedColumn: 'business_id',
                          typedResults: items,
                        ),
                      if (auditEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          LocalBusinessRow,
                          $LocalBusinessTable,
                          AuditEventRow,
                          $AuditEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocalBusinessTableReferences
                              ._auditEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocalBusinessTableReferences(
                                db,
                                table,
                                p0,
                              ).auditEventsRefs,
                          currentColumn: 'business_id',
                          referencedColumn: 'business_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocalBusinessTableProcessedTableManager =
    ProcessedTableManager<
      _$LegacyV1AppDatabase,
      $LocalBusinessTable,
      LocalBusinessRow,
      $$LocalBusinessTableFilterComposer,
      $$LocalBusinessTableOrderingComposer,
      $$LocalBusinessTableAnnotationComposer,
      $$LocalBusinessTableCreateCompanionBuilder,
      $$LocalBusinessTableUpdateCompanionBuilder,
      (LocalBusinessRow, $$LocalBusinessTableReferences),
      LocalBusinessRow,
      PrefetchHooks Function({
        bool localDeviceRefs,
        bool usersCacheRefs,
        bool appSettingsRefs,
        bool syncOperationsRefs,
        bool syncCursorsRefs,
        bool syncConflictsRefs,
        bool auditEventsRefs,
      })
    >;
typedef $$LocalDeviceTableCreateCompanionBuilder =
    LocalDeviceCompanion Function({
      Value<int> singletonId,
      required String deviceId,
      required String businessId,
      required String platform,
      Value<String?> label,
      required String activationStatus,
      Value<int?> activatedAtMs,
      Value<int?> lastOnlineValidatedAtMs,
      Value<int?> offlineValidUntilMs,
      required int createdAtMs,
      required int updatedAtMs,
    });
typedef $$LocalDeviceTableUpdateCompanionBuilder =
    LocalDeviceCompanion Function({
      Value<int> singletonId,
      Value<String> deviceId,
      Value<String> businessId,
      Value<String> platform,
      Value<String?> label,
      Value<String> activationStatus,
      Value<int?> activatedAtMs,
      Value<int?> lastOnlineValidatedAtMs,
      Value<int?> offlineValidUntilMs,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
    });

final class $$LocalDeviceTableReferences
    extends
        BaseReferences<
          _$LegacyV1AppDatabase,
          $LocalDeviceTable,
          LocalDeviceRow
        > {
  $$LocalDeviceTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalBusinessTable _businessIdTable(_$LegacyV1AppDatabase db) => db
      .localBusiness
      .createAlias('local_device__business_id__local_business__business_id');

  $$LocalBusinessTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<String>('business_id')!;

    final manager = $$LocalBusinessTableTableManager(
      $_db,
      $_db.localBusiness,
    ).filter((f) => f.businessId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalDeviceTableFilterComposer
    extends Composer<_$LegacyV1AppDatabase, $LocalDeviceTable> {
  $$LocalDeviceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activatedAtMs => $composableBuilder(
    column: $table.activatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastOnlineValidatedAtMs => $composableBuilder(
    column: $table.lastOnlineValidatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offlineValidUntilMs => $composableBuilder(
    column: $table.offlineValidUntilMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalBusinessTableFilterComposer get businessId {
    final $$LocalBusinessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableFilterComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalDeviceTableOrderingComposer
    extends Composer<_$LegacyV1AppDatabase, $LocalDeviceTable> {
  $$LocalDeviceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activatedAtMs => $composableBuilder(
    column: $table.activatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastOnlineValidatedAtMs => $composableBuilder(
    column: $table.lastOnlineValidatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offlineValidUntilMs => $composableBuilder(
    column: $table.offlineValidUntilMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalBusinessTableOrderingComposer get businessId {
    final $$LocalBusinessTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableOrderingComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalDeviceTableAnnotationComposer
    extends Composer<_$LegacyV1AppDatabase, $LocalDeviceTable> {
  $$LocalDeviceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get activationStatus => $composableBuilder(
    column: $table.activationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activatedAtMs => $composableBuilder(
    column: $table.activatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastOnlineValidatedAtMs => $composableBuilder(
    column: $table.lastOnlineValidatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get offlineValidUntilMs => $composableBuilder(
    column: $table.offlineValidUntilMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  $$LocalBusinessTableAnnotationComposer get businessId {
    final $$LocalBusinessTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableAnnotationComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalDeviceTableTableManager
    extends
        RootTableManager<
          _$LegacyV1AppDatabase,
          $LocalDeviceTable,
          LocalDeviceRow,
          $$LocalDeviceTableFilterComposer,
          $$LocalDeviceTableOrderingComposer,
          $$LocalDeviceTableAnnotationComposer,
          $$LocalDeviceTableCreateCompanionBuilder,
          $$LocalDeviceTableUpdateCompanionBuilder,
          (LocalDeviceRow, $$LocalDeviceTableReferences),
          LocalDeviceRow,
          PrefetchHooks Function({bool businessId})
        > {
  $$LocalDeviceTableTableManager(
    _$LegacyV1AppDatabase db,
    $LocalDeviceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDeviceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDeviceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDeviceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String> activationStatus = const Value.absent(),
                Value<int?> activatedAtMs = const Value.absent(),
                Value<int?> lastOnlineValidatedAtMs = const Value.absent(),
                Value<int?> offlineValidUntilMs = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => LocalDeviceCompanion(
                singletonId: singletonId,
                deviceId: deviceId,
                businessId: businessId,
                platform: platform,
                label: label,
                activationStatus: activationStatus,
                activatedAtMs: activatedAtMs,
                lastOnlineValidatedAtMs: lastOnlineValidatedAtMs,
                offlineValidUntilMs: offlineValidUntilMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                required String deviceId,
                required String businessId,
                required String platform,
                Value<String?> label = const Value.absent(),
                required String activationStatus,
                Value<int?> activatedAtMs = const Value.absent(),
                Value<int?> lastOnlineValidatedAtMs = const Value.absent(),
                Value<int?> offlineValidUntilMs = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
              }) => LocalDeviceCompanion.insert(
                singletonId: singletonId,
                deviceId: deviceId,
                businessId: businessId,
                platform: platform,
                label: label,
                activationStatus: activationStatus,
                activatedAtMs: activatedAtMs,
                lastOnlineValidatedAtMs: lastOnlineValidatedAtMs,
                offlineValidUntilMs: offlineValidUntilMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalDeviceTable, LocalDeviceRow>(table),
                  $$LocalDeviceTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
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
                    if (businessId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.businessId,
                        referencedTable: $$LocalDeviceTableReferences
                            ._businessIdTable(db),
                        referencedColumn: $$LocalDeviceTableReferences
                            ._businessIdTable(db)
                            .businessId,
                      ) as T;
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

typedef $$LocalDeviceTableProcessedTableManager =
    ProcessedTableManager<
      _$LegacyV1AppDatabase,
      $LocalDeviceTable,
      LocalDeviceRow,
      $$LocalDeviceTableFilterComposer,
      $$LocalDeviceTableOrderingComposer,
      $$LocalDeviceTableAnnotationComposer,
      $$LocalDeviceTableCreateCompanionBuilder,
      $$LocalDeviceTableUpdateCompanionBuilder,
      (LocalDeviceRow, $$LocalDeviceTableReferences),
      LocalDeviceRow,
      PrefetchHooks Function({bool businessId})
    >;
typedef $$UsersCacheTableCreateCompanionBuilder = UsersCacheCompanion Function({
  required String userId,
  required String businessId,
  required String displayName,
  required String role,
  Value<bool> isActive,
  Value<int?> lastSyncedAtMs,
  required int createdAtMs,
  required int updatedAtMs,
  Value<int> rowid,
});
typedef $$UsersCacheTableUpdateCompanionBuilder = UsersCacheCompanion Function({
  Value<String> userId,
  Value<String> businessId,
  Value<String> displayName,
  Value<String> role,
  Value<bool> isActive,
  Value<int?> lastSyncedAtMs,
  Value<int> createdAtMs,
  Value<int> updatedAtMs,
  Value<int> rowid,
});

final class $$UsersCacheTableReferences
    extends
        BaseReferences<_$LegacyV1AppDatabase, $UsersCacheTable, UsersCacheRow> {
  $$UsersCacheTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalBusinessTable _businessIdTable(_$LegacyV1AppDatabase db) => db
      .localBusiness
      .createAlias('users_cache__business_id__local_business__business_id');

  $$LocalBusinessTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<String>('business_id')!;

    final manager = $$LocalBusinessTableTableManager(
      $_db,
      $_db.localBusiness,
    ).filter((f) => f.businessId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UsersCacheTableFilterComposer
    extends Composer<_$LegacyV1AppDatabase, $UsersCacheTable> {
  $$UsersCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAtMs => $composableBuilder(
    column: $table.lastSyncedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalBusinessTableFilterComposer get businessId {
    final $$LocalBusinessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableFilterComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsersCacheTableOrderingComposer
    extends Composer<_$LegacyV1AppDatabase, $UsersCacheTable> {
  $$UsersCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAtMs => $composableBuilder(
    column: $table.lastSyncedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalBusinessTableOrderingComposer get businessId {
    final $$LocalBusinessTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableOrderingComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsersCacheTableAnnotationComposer
    extends Composer<_$LegacyV1AppDatabase, $UsersCacheTable> {
  $$UsersCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAtMs => $composableBuilder(
    column: $table.lastSyncedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  $$LocalBusinessTableAnnotationComposer get businessId {
    final $$LocalBusinessTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableAnnotationComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsersCacheTableTableManager
    extends
        RootTableManager<
          _$LegacyV1AppDatabase,
          $UsersCacheTable,
          UsersCacheRow,
          $$UsersCacheTableFilterComposer,
          $$UsersCacheTableOrderingComposer,
          $$UsersCacheTableAnnotationComposer,
          $$UsersCacheTableCreateCompanionBuilder,
          $$UsersCacheTableUpdateCompanionBuilder,
          (UsersCacheRow, $$UsersCacheTableReferences),
          UsersCacheRow,
          PrefetchHooks Function({bool businessId})
        > {
  $$UsersCacheTableTableManager(
    _$LegacyV1AppDatabase db,
    $UsersCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> lastSyncedAtMs = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCacheCompanion(
                userId: userId,
                businessId: businessId,
                displayName: displayName,
                role: role,
                isActive: isActive,
                lastSyncedAtMs: lastSyncedAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String businessId,
                required String displayName,
                required String role,
                Value<bool> isActive = const Value.absent(),
                Value<int?> lastSyncedAtMs = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => UsersCacheCompanion.insert(
                userId: userId,
                businessId: businessId,
                displayName: displayName,
                role: role,
                isActive: isActive,
                lastSyncedAtMs: lastSyncedAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersCacheTable, UsersCacheRow>(table),
                  $$UsersCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
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
                    if (businessId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.businessId,
                        referencedTable: $$UsersCacheTableReferences
                            ._businessIdTable(db),
                        referencedColumn: $$UsersCacheTableReferences
                            ._businessIdTable(db)
                            .businessId,
                      ) as T;
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

typedef $$UsersCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$LegacyV1AppDatabase,
      $UsersCacheTable,
      UsersCacheRow,
      $$UsersCacheTableFilterComposer,
      $$UsersCacheTableOrderingComposer,
      $$UsersCacheTableAnnotationComposer,
      $$UsersCacheTableCreateCompanionBuilder,
      $$UsersCacheTableUpdateCompanionBuilder,
      (UsersCacheRow, $$UsersCacheTableReferences),
      UsersCacheRow,
      PrefetchHooks Function({bool businessId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String settingKey,
      required String businessId,
      required String valueJson,
      required int updatedAtMs,
      Value<String?> updatedByUserId,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> settingKey,
      Value<String> businessId,
      Value<String> valueJson,
      Value<int> updatedAtMs,
      Value<String?> updatedByUserId,
      Value<int> rowid,
    });

final class $$AppSettingsTableReferences
    extends
        BaseReferences<
          _$LegacyV1AppDatabase,
          $AppSettingsTable,
          AppSettingRow
        > {
  $$AppSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalBusinessTable _businessIdTable(_$LegacyV1AppDatabase db) => db
      .localBusiness
      .createAlias('app_settings__business_id__local_business__business_id');

  $$LocalBusinessTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<String>('business_id')!;

    final manager = $$LocalBusinessTableTableManager(
      $_db,
      $_db.localBusiness,
    ).filter((f) => f.businessId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppSettingsTableFilterComposer
    extends Composer<_$LegacyV1AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedByUserId => $composableBuilder(
    column: $table.updatedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalBusinessTableFilterComposer get businessId {
    final $$LocalBusinessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableFilterComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$LegacyV1AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedByUserId => $composableBuilder(
    column: $table.updatedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalBusinessTableOrderingComposer get businessId {
    final $$LocalBusinessTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableOrderingComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$LegacyV1AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedByUserId => $composableBuilder(
    column: $table.updatedByUserId,
    builder: (column) => column,
  );

  $$LocalBusinessTableAnnotationComposer get businessId {
    final $$LocalBusinessTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableAnnotationComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$LegacyV1AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (AppSettingRow, $$AppSettingsTableReferences),
          AppSettingRow,
          PrefetchHooks Function({bool businessId})
        > {
  $$AppSettingsTableTableManager(
    _$LegacyV1AppDatabase db,
    $AppSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<String?> updatedByUserId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                settingKey: settingKey,
                businessId: businessId,
                valueJson: valueJson,
                updatedAtMs: updatedAtMs,
                updatedByUserId: updatedByUserId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String businessId,
                required String valueJson,
                required int updatedAtMs,
                Value<String?> updatedByUserId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                settingKey: settingKey,
                businessId: businessId,
                valueJson: valueJson,
                updatedAtMs: updatedAtMs,
                updatedByUserId: updatedByUserId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  $$AppSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
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
                    if (businessId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.businessId,
                        referencedTable: $$AppSettingsTableReferences
                            ._businessIdTable(db),
                        referencedColumn: $$AppSettingsTableReferences
                            ._businessIdTable(db)
                            .businessId,
                      ) as T;
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

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$LegacyV1AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (AppSettingRow, $$AppSettingsTableReferences),
      AppSettingRow,
      PrefetchHooks Function({bool businessId})
    >;
typedef $$SyncOperationsTableCreateCompanionBuilder =
    SyncOperationsCompanion Function({
      required String operationId,
      required String businessId,
      required String deviceId,
      required String entityType,
      required String entityId,
      required String operationType,
      required String payloadJson,
      Value<String?> dependsOnOperationId,
      required String status,
      Value<int> retryCount,
      Value<String?> lastErrorCode,
      Value<String?> lastErrorMessage,
      Value<int?> lastAttemptAtMs,
      Value<int?> acknowledgedAtMs,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$SyncOperationsTableUpdateCompanionBuilder =
    SyncOperationsCompanion Function({
      Value<String> operationId,
      Value<String> businessId,
      Value<String> deviceId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operationType,
      Value<String> payloadJson,
      Value<String?> dependsOnOperationId,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastErrorCode,
      Value<String?> lastErrorMessage,
      Value<int?> lastAttemptAtMs,
      Value<int?> acknowledgedAtMs,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

final class $$SyncOperationsTableReferences
    extends
        BaseReferences<
          _$LegacyV1AppDatabase,
          $SyncOperationsTable,
          SyncOperationRow
        > {
  $$SyncOperationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalBusinessTable _businessIdTable(_$LegacyV1AppDatabase db) => db
      .localBusiness
      .createAlias('sync_operations__business_id__local_business__business_id');

  $$LocalBusinessTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<String>('business_id')!;

    final manager = $$LocalBusinessTableTableManager(
      $_db,
      $_db.localBusiness,
    ).filter((f) => f.businessId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SyncOperationsTable _dependsOnOperationIdTable(
    _$LegacyV1AppDatabase db,
  ) => db.syncOperations.createAlias(
    'sync_operations__depends_on_operation_id__sync_operations__operation_id',
  );

  $$SyncOperationsTableProcessedTableManager? get dependsOnOperationId {
    final $_column = $_itemColumn<String>('depends_on_operation_id');
    if ($_column == null) return null;
    final manager = $$SyncOperationsTableTableManager(
      $_db,
      $_db.syncOperations,
    ).filter((f) => f.operationId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _dependsOnOperationIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncOperationsTableFilterComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAttemptAtMs => $composableBuilder(
    column: $table.lastAttemptAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get acknowledgedAtMs => $composableBuilder(
    column: $table.acknowledgedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalBusinessTableFilterComposer get businessId {
    final $$LocalBusinessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableFilterComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SyncOperationsTableFilterComposer get dependsOnOperationId {
    final $$SyncOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dependsOnOperationId,
      referencedTable: $db.syncOperations,
      getReferencedColumn: (t) => t.operationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncOperationsTableFilterComposer(
            $db: $db,
            $table: $db.syncOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncOperationsTableOrderingComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAttemptAtMs => $composableBuilder(
    column: $table.lastAttemptAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get acknowledgedAtMs => $composableBuilder(
    column: $table.acknowledgedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalBusinessTableOrderingComposer get businessId {
    final $$LocalBusinessTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableOrderingComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SyncOperationsTableOrderingComposer get dependsOnOperationId {
    final $$SyncOperationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dependsOnOperationId,
      referencedTable: $db.syncOperations,
      getReferencedColumn: (t) => t.operationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncOperationsTableOrderingComposer(
            $db: $db,
            $table: $db.syncOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncOperationsTableAnnotationComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAttemptAtMs => $composableBuilder(
    column: $table.lastAttemptAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get acknowledgedAtMs => $composableBuilder(
    column: $table.acknowledgedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  $$LocalBusinessTableAnnotationComposer get businessId {
    final $$LocalBusinessTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableAnnotationComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SyncOperationsTableAnnotationComposer get dependsOnOperationId {
    final $$SyncOperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dependsOnOperationId,
      referencedTable: $db.syncOperations,
      getReferencedColumn: (t) => t.operationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncOperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.syncOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncOperationsTableTableManager
    extends
        RootTableManager<
          _$LegacyV1AppDatabase,
          $SyncOperationsTable,
          SyncOperationRow,
          $$SyncOperationsTableFilterComposer,
          $$SyncOperationsTableOrderingComposer,
          $$SyncOperationsTableAnnotationComposer,
          $$SyncOperationsTableCreateCompanionBuilder,
          $$SyncOperationsTableUpdateCompanionBuilder,
          (SyncOperationRow, $$SyncOperationsTableReferences),
          SyncOperationRow,
          PrefetchHooks Function({bool businessId, bool dependsOnOperationId})
        > {
  $$SyncOperationsTableTableManager(
    _$LegacyV1AppDatabase db,
    $SyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> dependsOnOperationId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastErrorMessage = const Value.absent(),
                Value<int?> lastAttemptAtMs = const Value.absent(),
                Value<int?> acknowledgedAtMs = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion(
                operationId: operationId,
                businessId: businessId,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadJson: payloadJson,
                dependsOnOperationId: dependsOnOperationId,
                status: status,
                retryCount: retryCount,
                lastErrorCode: lastErrorCode,
                lastErrorMessage: lastErrorMessage,
                lastAttemptAtMs: lastAttemptAtMs,
                acknowledgedAtMs: acknowledgedAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String businessId,
                required String deviceId,
                required String entityType,
                required String entityId,
                required String operationType,
                required String payloadJson,
                Value<String?> dependsOnOperationId = const Value.absent(),
                required String status,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<String?> lastErrorMessage = const Value.absent(),
                Value<int?> lastAttemptAtMs = const Value.absent(),
                Value<int?> acknowledgedAtMs = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion.insert(
                operationId: operationId,
                businessId: businessId,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadJson: payloadJson,
                dependsOnOperationId: dependsOnOperationId,
                status: status,
                retryCount: retryCount,
                lastErrorCode: lastErrorCode,
                lastErrorMessage: lastErrorMessage,
                lastAttemptAtMs: lastAttemptAtMs,
                acknowledgedAtMs: acknowledgedAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOperationsTable, SyncOperationRow>(table),
                  $$SyncOperationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({businessId = false, dependsOnOperationId = false}) {
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
                        if (businessId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.businessId,
                            referencedTable: $$SyncOperationsTableReferences
                                ._businessIdTable(db),
                            referencedColumn: $$SyncOperationsTableReferences
                                ._businessIdTable(db)
                                .businessId,
                          ) as T;
                        }
                        if (dependsOnOperationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.dependsOnOperationId,
                            referencedTable: $$SyncOperationsTableReferences
                                ._dependsOnOperationIdTable(db),
                            referencedColumn: $$SyncOperationsTableReferences
                                ._dependsOnOperationIdTable(db)
                                .operationId,
                          ) as T;
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

typedef $$SyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$LegacyV1AppDatabase,
      $SyncOperationsTable,
      SyncOperationRow,
      $$SyncOperationsTableFilterComposer,
      $$SyncOperationsTableOrderingComposer,
      $$SyncOperationsTableAnnotationComposer,
      $$SyncOperationsTableCreateCompanionBuilder,
      $$SyncOperationsTableUpdateCompanionBuilder,
      (SyncOperationRow, $$SyncOperationsTableReferences),
      SyncOperationRow,
      PrefetchHooks Function({bool businessId, bool dependsOnOperationId})
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String streamName,
      required String businessId,
      required String cursorValue,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> streamName,
      Value<String> businessId,
      Value<String> cursorValue,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

final class $$SyncCursorsTableReferences
    extends
        BaseReferences<
          _$LegacyV1AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow
        > {
  $$SyncCursorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalBusinessTable _businessIdTable(_$LegacyV1AppDatabase db) => db
      .localBusiness
      .createAlias('sync_cursors__business_id__local_business__business_id');

  $$LocalBusinessTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<String>('business_id')!;

    final manager = $$LocalBusinessTableTableManager(
      $_db,
      $_db.localBusiness,
    ).filter((f) => f.businessId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncCursorsTableFilterComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get streamName => $composableBuilder(
    column: $table.streamName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursorValue => $composableBuilder(
    column: $table.cursorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalBusinessTableFilterComposer get businessId {
    final $$LocalBusinessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableFilterComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get streamName => $composableBuilder(
    column: $table.streamName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursorValue => $composableBuilder(
    column: $table.cursorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalBusinessTableOrderingComposer get businessId {
    final $$LocalBusinessTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableOrderingComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get streamName => $composableBuilder(
    column: $table.streamName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursorValue => $composableBuilder(
    column: $table.cursorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  $$LocalBusinessTableAnnotationComposer get businessId {
    final $$LocalBusinessTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableAnnotationComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$LegacyV1AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (SyncCursorRow, $$SyncCursorsTableReferences),
          SyncCursorRow,
          PrefetchHooks Function({bool businessId})
        > {
  $$SyncCursorsTableTableManager(
    _$LegacyV1AppDatabase db,
    $SyncCursorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> streamName = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> cursorValue = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                streamName: streamName,
                businessId: businessId,
                cursorValue: cursorValue,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String streamName,
                required String businessId,
                required String cursorValue,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                streamName: streamName,
                businessId: businessId,
                cursorValue: cursorValue,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursorRow>(table),
                  $$SyncCursorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
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
                    if (businessId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.businessId,
                        referencedTable: $$SyncCursorsTableReferences
                            ._businessIdTable(db),
                        referencedColumn: $$SyncCursorsTableReferences
                            ._businessIdTable(db)
                            .businessId,
                      ) as T;
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

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$LegacyV1AppDatabase,
      $SyncCursorsTable,
      SyncCursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (SyncCursorRow, $$SyncCursorsTableReferences),
      SyncCursorRow,
      PrefetchHooks Function({bool businessId})
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String conflictId,
      required String businessId,
      required String entityType,
      required String entityId,
      required String localSnapshotJson,
      Value<String?> remoteSnapshotJson,
      required String status,
      required int createdAtMs,
      Value<int?> resolvedAtMs,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> conflictId,
      Value<String> businessId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> localSnapshotJson,
      Value<String?> remoteSnapshotJson,
      Value<String> status,
      Value<int> createdAtMs,
      Value<int?> resolvedAtMs,
      Value<int> rowid,
    });

final class $$SyncConflictsTableReferences
    extends
        BaseReferences<
          _$LegacyV1AppDatabase,
          $SyncConflictsTable,
          SyncConflictRow
        > {
  $$SyncConflictsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LocalBusinessTable _businessIdTable(_$LegacyV1AppDatabase db) => db
      .localBusiness
      .createAlias('sync_conflicts__business_id__local_business__business_id');

  $$LocalBusinessTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<String>('business_id')!;

    final manager = $$LocalBusinessTableTableManager(
      $_db,
      $_db.localBusiness,
    ).filter((f) => f.businessId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncConflictsTableFilterComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localSnapshotJson => $composableBuilder(
    column: $table.localSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteSnapshotJson => $composableBuilder(
    column: $table.remoteSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAtMs => $composableBuilder(
    column: $table.resolvedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalBusinessTableFilterComposer get businessId {
    final $$LocalBusinessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableFilterComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localSnapshotJson => $composableBuilder(
    column: $table.localSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteSnapshotJson => $composableBuilder(
    column: $table.remoteSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAtMs => $composableBuilder(
    column: $table.resolvedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalBusinessTableOrderingComposer get businessId {
    final $$LocalBusinessTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableOrderingComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$LegacyV1AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get localSnapshotJson => $composableBuilder(
    column: $table.localSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteSnapshotJson => $composableBuilder(
    column: $table.remoteSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolvedAtMs => $composableBuilder(
    column: $table.resolvedAtMs,
    builder: (column) => column,
  );

  $$LocalBusinessTableAnnotationComposer get businessId {
    final $$LocalBusinessTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableAnnotationComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$LegacyV1AppDatabase,
          $SyncConflictsTable,
          SyncConflictRow,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (SyncConflictRow, $$SyncConflictsTableReferences),
          SyncConflictRow,
          PrefetchHooks Function({bool businessId})
        > {
  $$SyncConflictsTableTableManager(
    _$LegacyV1AppDatabase db,
    $SyncConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> conflictId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> localSnapshotJson = const Value.absent(),
                Value<String?> remoteSnapshotJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int?> resolvedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                conflictId: conflictId,
                businessId: businessId,
                entityType: entityType,
                entityId: entityId,
                localSnapshotJson: localSnapshotJson,
                remoteSnapshotJson: remoteSnapshotJson,
                status: status,
                createdAtMs: createdAtMs,
                resolvedAtMs: resolvedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conflictId,
                required String businessId,
                required String entityType,
                required String entityId,
                required String localSnapshotJson,
                Value<String?> remoteSnapshotJson = const Value.absent(),
                required String status,
                required int createdAtMs,
                Value<int?> resolvedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                conflictId: conflictId,
                businessId: businessId,
                entityType: entityType,
                entityId: entityId,
                localSnapshotJson: localSnapshotJson,
                remoteSnapshotJson: remoteSnapshotJson,
                status: status,
                createdAtMs: createdAtMs,
                resolvedAtMs: resolvedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncConflictsTable, SyncConflictRow>(table),
                  $$SyncConflictsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
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
                    if (businessId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.businessId,
                        referencedTable: $$SyncConflictsTableReferences
                            ._businessIdTable(db),
                        referencedColumn: $$SyncConflictsTableReferences
                            ._businessIdTable(db)
                            .businessId,
                      ) as T;
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

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$LegacyV1AppDatabase,
      $SyncConflictsTable,
      SyncConflictRow,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (SyncConflictRow, $$SyncConflictsTableReferences),
      SyncConflictRow,
      PrefetchHooks Function({bool businessId})
    >;
typedef $$AuditEventsTableCreateCompanionBuilder =
    AuditEventsCompanion Function({
      required String eventId,
      required String businessId,
      required String deviceId,
      Value<String?> actorUserId,
      required String eventType,
      Value<String?> entityType,
      Value<String?> entityId,
      Value<String> metadataJson,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$AuditEventsTableUpdateCompanionBuilder =
    AuditEventsCompanion Function({
      Value<String> eventId,
      Value<String> businessId,
      Value<String> deviceId,
      Value<String?> actorUserId,
      Value<String> eventType,
      Value<String?> entityType,
      Value<String?> entityId,
      Value<String> metadataJson,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

final class $$AuditEventsTableReferences
    extends
        BaseReferences<
          _$LegacyV1AppDatabase,
          $AuditEventsTable,
          AuditEventRow
        > {
  $$AuditEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocalBusinessTable _businessIdTable(_$LegacyV1AppDatabase db) => db
      .localBusiness
      .createAlias('audit_events__business_id__local_business__business_id');

  $$LocalBusinessTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<String>('business_id')!;

    final manager = $$LocalBusinessTableTableManager(
      $_db,
      $_db.localBusiness,
    ).filter((f) => f.businessId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuditEventsTableFilterComposer
    extends Composer<_$LegacyV1AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$LocalBusinessTableFilterComposer get businessId {
    final $$LocalBusinessTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableFilterComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditEventsTableOrderingComposer
    extends Composer<_$LegacyV1AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocalBusinessTableOrderingComposer get businessId {
    final $$LocalBusinessTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableOrderingComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditEventsTableAnnotationComposer
    extends Composer<_$LegacyV1AppDatabase, $AuditEventsTable> {
  $$AuditEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  $$LocalBusinessTableAnnotationComposer get businessId {
    final $$LocalBusinessTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.localBusiness,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalBusinessTableAnnotationComposer(
            $db: $db,
            $table: $db.localBusiness,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditEventsTableTableManager
    extends
        RootTableManager<
          _$LegacyV1AppDatabase,
          $AuditEventsTable,
          AuditEventRow,
          $$AuditEventsTableFilterComposer,
          $$AuditEventsTableOrderingComposer,
          $$AuditEventsTableAnnotationComposer,
          $$AuditEventsTableCreateCompanionBuilder,
          $$AuditEventsTableUpdateCompanionBuilder,
          (AuditEventRow, $$AuditEventsTableReferences),
          AuditEventRow,
          PrefetchHooks Function({bool businessId})
        > {
  $$AuditEventsTableTableManager(
    _$LegacyV1AppDatabase db,
    $AuditEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> businessId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> actorUserId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> entityType = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditEventsCompanion(
                eventId: eventId,
                businessId: businessId,
                deviceId: deviceId,
                actorUserId: actorUserId,
                eventType: eventType,
                entityType: entityType,
                entityId: entityId,
                metadataJson: metadataJson,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String businessId,
                required String deviceId,
                Value<String?> actorUserId = const Value.absent(),
                required String eventType,
                Value<String?> entityType = const Value.absent(),
                Value<String?> entityId = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => AuditEventsCompanion.insert(
                eventId: eventId,
                businessId: businessId,
                deviceId: deviceId,
                actorUserId: actorUserId,
                eventType: eventType,
                entityType: entityType,
                entityId: entityId,
                metadataJson: metadataJson,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditEventsTable, AuditEventRow>(table),
                  $$AuditEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
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
                    if (businessId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.businessId,
                        referencedTable: $$AuditEventsTableReferences
                            ._businessIdTable(db),
                        referencedColumn: $$AuditEventsTableReferences
                            ._businessIdTable(db)
                            .businessId,
                      ) as T;
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

typedef $$AuditEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$LegacyV1AppDatabase,
      $AuditEventsTable,
      AuditEventRow,
      $$AuditEventsTableFilterComposer,
      $$AuditEventsTableOrderingComposer,
      $$AuditEventsTableAnnotationComposer,
      $$AuditEventsTableCreateCompanionBuilder,
      $$AuditEventsTableUpdateCompanionBuilder,
      (AuditEventRow, $$AuditEventsTableReferences),
      AuditEventRow,
      PrefetchHooks Function({bool businessId})
    >;

class $LegacyV1AppDatabaseManager {
  final _$LegacyV1AppDatabase _db;
  $LegacyV1AppDatabaseManager(this._db);
  $$LocalBusinessTableTableManager get localBusiness =>
      $$LocalBusinessTableTableManager(_db, _db.localBusiness);
  $$LocalDeviceTableTableManager get localDevice =>
      $$LocalDeviceTableTableManager(_db, _db.localDevice);
  $$UsersCacheTableTableManager get usersCache =>
      $$UsersCacheTableTableManager(_db, _db.usersCache);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$AuditEventsTableTableManager get auditEvents =>
      $$AuditEventsTableTableManager(_db, _db.auditEvents);
}

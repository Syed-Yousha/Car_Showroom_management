// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CarsTable extends Cars with TableInfo<$CarsTable, Car> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
    'year',
    aliasedName,
    false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registrationNumberMeta =
      const VerificationMeta('registrationNumber');
  @override
  late final GeneratedColumn<String> registrationNumber =
      GeneratedColumn<String>(
        'registration_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _chassisNumberMeta = const VerificationMeta(
    'chassisNumber',
  );
  @override
  late final GeneratedColumn<String> chassisNumber = GeneratedColumn<String>(
    'chassis_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _engineNumberMeta = const VerificationMeta(
    'engineNumber',
  );
  @override
  late final GeneratedColumn<String> engineNumber = GeneratedColumn<String>(
    'engine_number',
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
    defaultValue: const Constant('Available'),
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repairCostMeta = const VerificationMeta(
    'repairCost',
  );
  @override
  late final GeneratedColumn<double> repairCost = GeneratedColumn<double>(
    'repair_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isFileInHandMeta = const VerificationMeta(
    'isFileInHand',
  );
  @override
  late final GeneratedColumn<bool> isFileInHand = GeneratedColumn<bool>(
    'is_file_in_hand',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_file_in_hand" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isNumberPlateInHandMeta =
      const VerificationMeta('isNumberPlateInHand');
  @override
  late final GeneratedColumn<bool> isNumberPlateInHand = GeneratedColumn<bool>(
    'is_number_plate_in_hand',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_number_plate_in_hand" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDate,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    make,
    model,
    year,
    color,
    registrationNumber,
    chassisNumber,
    engineNumber,
    status,
    purchasePrice,
    repairCost,
    isFileInHand,
    isNumberPlateInHand,
    dateAdded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cars';
  @override
  VerificationContext validateIntegrity(
    Insertable<Car> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('registration_number')) {
      context.handle(
        _registrationNumberMeta,
        registrationNumber.isAcceptableOrUnknown(
          data['registration_number']!,
          _registrationNumberMeta,
        ),
      );
    }
    if (data.containsKey('chassis_number')) {
      context.handle(
        _chassisNumberMeta,
        chassisNumber.isAcceptableOrUnknown(
          data['chassis_number']!,
          _chassisNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chassisNumberMeta);
    }
    if (data.containsKey('engine_number')) {
      context.handle(
        _engineNumberMeta,
        engineNumber.isAcceptableOrUnknown(
          data['engine_number']!,
          _engineNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineNumberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('repair_cost')) {
      context.handle(
        _repairCostMeta,
        repairCost.isAcceptableOrUnknown(data['repair_cost']!, _repairCostMeta),
      );
    }
    if (data.containsKey('is_file_in_hand')) {
      context.handle(
        _isFileInHandMeta,
        isFileInHand.isAcceptableOrUnknown(
          data['is_file_in_hand']!,
          _isFileInHandMeta,
        ),
      );
    }
    if (data.containsKey('is_number_plate_in_hand')) {
      context.handle(
        _isNumberPlateInHandMeta,
        isNumberPlateInHand.isAcceptableOrUnknown(
          data['is_number_plate_in_hand']!,
          _isNumberPlateInHandMeta,
        ),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Car map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Car(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}year'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      registrationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration_number'],
      ),
      chassisNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chassis_number'],
      )!,
      engineNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      repairCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}repair_cost'],
      )!,
      isFileInHand: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_file_in_hand'],
      )!,
      isNumberPlateInHand: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_number_plate_in_hand'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
    );
  }

  @override
  $CarsTable createAlias(String alias) {
    return $CarsTable(attachedDatabase, alias);
  }
}

class Car extends DataClass implements Insertable<Car> {
  final int id;
  final String make;
  final String model;
  final String year;
  final String color;
  final String? registrationNumber;
  final String chassisNumber;
  final String engineNumber;
  final String status;
  final double purchasePrice;
  final double repairCost;
  final bool isFileInHand;
  final bool isNumberPlateInHand;
  final DateTime dateAdded;
  const Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    this.registrationNumber,
    required this.chassisNumber,
    required this.engineNumber,
    required this.status,
    required this.purchasePrice,
    required this.repairCost,
    required this.isFileInHand,
    required this.isNumberPlateInHand,
    required this.dateAdded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    map['year'] = Variable<String>(year);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || registrationNumber != null) {
      map['registration_number'] = Variable<String>(registrationNumber);
    }
    map['chassis_number'] = Variable<String>(chassisNumber);
    map['engine_number'] = Variable<String>(engineNumber);
    map['status'] = Variable<String>(status);
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['repair_cost'] = Variable<double>(repairCost);
    map['is_file_in_hand'] = Variable<bool>(isFileInHand);
    map['is_number_plate_in_hand'] = Variable<bool>(isNumberPlateInHand);
    map['date_added'] = Variable<DateTime>(dateAdded);
    return map;
  }

  CarsCompanion toCompanion(bool nullToAbsent) {
    return CarsCompanion(
      id: Value(id),
      make: Value(make),
      model: Value(model),
      year: Value(year),
      color: Value(color),
      registrationNumber: registrationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNumber),
      chassisNumber: Value(chassisNumber),
      engineNumber: Value(engineNumber),
      status: Value(status),
      purchasePrice: Value(purchasePrice),
      repairCost: Value(repairCost),
      isFileInHand: Value(isFileInHand),
      isNumberPlateInHand: Value(isNumberPlateInHand),
      dateAdded: Value(dateAdded),
    );
  }

  factory Car.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Car(
      id: serializer.fromJson<int>(json['id']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<String>(json['year']),
      color: serializer.fromJson<String>(json['color']),
      registrationNumber: serializer.fromJson<String?>(
        json['registrationNumber'],
      ),
      chassisNumber: serializer.fromJson<String>(json['chassisNumber']),
      engineNumber: serializer.fromJson<String>(json['engineNumber']),
      status: serializer.fromJson<String>(json['status']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      repairCost: serializer.fromJson<double>(json['repairCost']),
      isFileInHand: serializer.fromJson<bool>(json['isFileInHand']),
      isNumberPlateInHand: serializer.fromJson<bool>(
        json['isNumberPlateInHand'],
      ),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<String>(year),
      'color': serializer.toJson<String>(color),
      'registrationNumber': serializer.toJson<String?>(registrationNumber),
      'chassisNumber': serializer.toJson<String>(chassisNumber),
      'engineNumber': serializer.toJson<String>(engineNumber),
      'status': serializer.toJson<String>(status),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'repairCost': serializer.toJson<double>(repairCost),
      'isFileInHand': serializer.toJson<bool>(isFileInHand),
      'isNumberPlateInHand': serializer.toJson<bool>(isNumberPlateInHand),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
    };
  }

  Car copyWith({
    int? id,
    String? make,
    String? model,
    String? year,
    String? color,
    Value<String?> registrationNumber = const Value.absent(),
    String? chassisNumber,
    String? engineNumber,
    String? status,
    double? purchasePrice,
    double? repairCost,
    bool? isFileInHand,
    bool? isNumberPlateInHand,
    DateTime? dateAdded,
  }) => Car(
    id: id ?? this.id,
    make: make ?? this.make,
    model: model ?? this.model,
    year: year ?? this.year,
    color: color ?? this.color,
    registrationNumber: registrationNumber.present
        ? registrationNumber.value
        : this.registrationNumber,
    chassisNumber: chassisNumber ?? this.chassisNumber,
    engineNumber: engineNumber ?? this.engineNumber,
    status: status ?? this.status,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    repairCost: repairCost ?? this.repairCost,
    isFileInHand: isFileInHand ?? this.isFileInHand,
    isNumberPlateInHand: isNumberPlateInHand ?? this.isNumberPlateInHand,
    dateAdded: dateAdded ?? this.dateAdded,
  );
  Car copyWithCompanion(CarsCompanion data) {
    return Car(
      id: data.id.present ? data.id.value : this.id,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      color: data.color.present ? data.color.value : this.color,
      registrationNumber: data.registrationNumber.present
          ? data.registrationNumber.value
          : this.registrationNumber,
      chassisNumber: data.chassisNumber.present
          ? data.chassisNumber.value
          : this.chassisNumber,
      engineNumber: data.engineNumber.present
          ? data.engineNumber.value
          : this.engineNumber,
      status: data.status.present ? data.status.value : this.status,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      repairCost: data.repairCost.present
          ? data.repairCost.value
          : this.repairCost,
      isFileInHand: data.isFileInHand.present
          ? data.isFileInHand.value
          : this.isFileInHand,
      isNumberPlateInHand: data.isNumberPlateInHand.present
          ? data.isNumberPlateInHand.value
          : this.isNumberPlateInHand,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Car(')
          ..write('id: $id, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('color: $color, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('chassisNumber: $chassisNumber, ')
          ..write('engineNumber: $engineNumber, ')
          ..write('status: $status, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('repairCost: $repairCost, ')
          ..write('isFileInHand: $isFileInHand, ')
          ..write('isNumberPlateInHand: $isNumberPlateInHand, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    make,
    model,
    year,
    color,
    registrationNumber,
    chassisNumber,
    engineNumber,
    status,
    purchasePrice,
    repairCost,
    isFileInHand,
    isNumberPlateInHand,
    dateAdded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Car &&
          other.id == this.id &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.color == this.color &&
          other.registrationNumber == this.registrationNumber &&
          other.chassisNumber == this.chassisNumber &&
          other.engineNumber == this.engineNumber &&
          other.status == this.status &&
          other.purchasePrice == this.purchasePrice &&
          other.repairCost == this.repairCost &&
          other.isFileInHand == this.isFileInHand &&
          other.isNumberPlateInHand == this.isNumberPlateInHand &&
          other.dateAdded == this.dateAdded);
}

class CarsCompanion extends UpdateCompanion<Car> {
  final Value<int> id;
  final Value<String> make;
  final Value<String> model;
  final Value<String> year;
  final Value<String> color;
  final Value<String?> registrationNumber;
  final Value<String> chassisNumber;
  final Value<String> engineNumber;
  final Value<String> status;
  final Value<double> purchasePrice;
  final Value<double> repairCost;
  final Value<bool> isFileInHand;
  final Value<bool> isNumberPlateInHand;
  final Value<DateTime> dateAdded;
  const CarsCompanion({
    this.id = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.color = const Value.absent(),
    this.registrationNumber = const Value.absent(),
    this.chassisNumber = const Value.absent(),
    this.engineNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.repairCost = const Value.absent(),
    this.isFileInHand = const Value.absent(),
    this.isNumberPlateInHand = const Value.absent(),
    this.dateAdded = const Value.absent(),
  });
  CarsCompanion.insert({
    this.id = const Value.absent(),
    required String make,
    required String model,
    required String year,
    required String color,
    this.registrationNumber = const Value.absent(),
    required String chassisNumber,
    required String engineNumber,
    this.status = const Value.absent(),
    required double purchasePrice,
    this.repairCost = const Value.absent(),
    this.isFileInHand = const Value.absent(),
    this.isNumberPlateInHand = const Value.absent(),
    this.dateAdded = const Value.absent(),
  }) : make = Value(make),
       model = Value(model),
       year = Value(year),
       color = Value(color),
       chassisNumber = Value(chassisNumber),
       engineNumber = Value(engineNumber),
       purchasePrice = Value(purchasePrice);
  static Insertable<Car> custom({
    Expression<int>? id,
    Expression<String>? make,
    Expression<String>? model,
    Expression<String>? year,
    Expression<String>? color,
    Expression<String>? registrationNumber,
    Expression<String>? chassisNumber,
    Expression<String>? engineNumber,
    Expression<String>? status,
    Expression<double>? purchasePrice,
    Expression<double>? repairCost,
    Expression<bool>? isFileInHand,
    Expression<bool>? isNumberPlateInHand,
    Expression<DateTime>? dateAdded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (color != null) 'color': color,
      if (registrationNumber != null) 'registration_number': registrationNumber,
      if (chassisNumber != null) 'chassis_number': chassisNumber,
      if (engineNumber != null) 'engine_number': engineNumber,
      if (status != null) 'status': status,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (repairCost != null) 'repair_cost': repairCost,
      if (isFileInHand != null) 'is_file_in_hand': isFileInHand,
      if (isNumberPlateInHand != null)
        'is_number_plate_in_hand': isNumberPlateInHand,
      if (dateAdded != null) 'date_added': dateAdded,
    });
  }

  CarsCompanion copyWith({
    Value<int>? id,
    Value<String>? make,
    Value<String>? model,
    Value<String>? year,
    Value<String>? color,
    Value<String?>? registrationNumber,
    Value<String>? chassisNumber,
    Value<String>? engineNumber,
    Value<String>? status,
    Value<double>? purchasePrice,
    Value<double>? repairCost,
    Value<bool>? isFileInHand,
    Value<bool>? isNumberPlateInHand,
    Value<DateTime>? dateAdded,
  }) {
    return CarsCompanion(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      status: status ?? this.status,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      repairCost: repairCost ?? this.repairCost,
      isFileInHand: isFileInHand ?? this.isFileInHand,
      isNumberPlateInHand: isNumberPlateInHand ?? this.isNumberPlateInHand,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (registrationNumber.present) {
      map['registration_number'] = Variable<String>(registrationNumber.value);
    }
    if (chassisNumber.present) {
      map['chassis_number'] = Variable<String>(chassisNumber.value);
    }
    if (engineNumber.present) {
      map['engine_number'] = Variable<String>(engineNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (repairCost.present) {
      map['repair_cost'] = Variable<double>(repairCost.value);
    }
    if (isFileInHand.present) {
      map['is_file_in_hand'] = Variable<bool>(isFileInHand.value);
    }
    if (isNumberPlateInHand.present) {
      map['is_number_plate_in_hand'] = Variable<bool>(
        isNumberPlateInHand.value,
      );
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarsCompanion(')
          ..write('id: $id, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('color: $color, ')
          ..write('registrationNumber: $registrationNumber, ')
          ..write('chassisNumber: $chassisNumber, ')
          ..write('engineNumber: $engineNumber, ')
          ..write('status: $status, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('repairCost: $repairCost, ')
          ..write('isFileInHand: $isFileInHand, ')
          ..write('isNumberPlateInHand: $isNumberPlateInHand, ')
          ..write('dateAdded: $dateAdded')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cnicMeta = const VerificationMeta('cnic');
  @override
  late final GeneratedColumn<String> cnic = GeneratedColumn<String>(
    'cnic',
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
  @override
  List<GeneratedColumn> get $columns => [id, fullName, phone, cnic, address];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('cnic')) {
      context.handle(
        _cnicMeta,
        cnic.isAcceptableOrUnknown(data['cnic']!, _cnicMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      cnic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnic'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String fullName;
  final String phone;
  final String? cnic;
  final String? address;
  const Customer({
    required this.id,
    required this.fullName,
    required this.phone,
    this.cnic,
    this.address,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['full_name'] = Variable<String>(fullName);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || cnic != null) {
      map['cnic'] = Variable<String>(cnic);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      fullName: Value(fullName),
      phone: Value(phone),
      cnic: cnic == null && nullToAbsent ? const Value.absent() : Value(cnic),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String>(json['phone']),
      cnic: serializer.fromJson<String?>(json['cnic']),
      address: serializer.fromJson<String?>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String>(phone),
      'cnic': serializer.toJson<String?>(cnic),
      'address': serializer.toJson<String?>(address),
    };
  }

  Customer copyWith({
    int? id,
    String? fullName,
    String? phone,
    Value<String?> cnic = const Value.absent(),
    Value<String?> address = const Value.absent(),
  }) => Customer(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    cnic: cnic.present ? cnic.value : this.cnic,
    address: address.present ? address.value : this.address,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      cnic: data.cnic.present ? data.cnic.value : this.cnic,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('cnic: $cnic, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fullName, phone, cnic, address);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.cnic == this.cnic &&
          other.address == this.address);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> fullName;
  final Value<String> phone;
  final Value<String?> cnic;
  final Value<String?> address;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.cnic = const Value.absent(),
    this.address = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String fullName,
    required String phone,
    this.cnic = const Value.absent(),
    this.address = const Value.absent(),
  }) : fullName = Value(fullName),
       phone = Value(phone);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? cnic,
    Expression<String>? address,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (cnic != null) 'cnic': cnic,
      if (address != null) 'address': address,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String>? fullName,
    Value<String>? phone,
    Value<String?>? cnic,
    Value<String?>? address,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      address: address ?? this.address,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (cnic.present) {
      map['cnic'] = Variable<String>(cnic.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('cnic: $cnic, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<int> carId = GeneratedColumn<int>(
    'car_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cars (id)',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
    'sale_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountGivenMeta = const VerificationMeta(
    'discountGiven',
  );
  @override
  late final GeneratedColumn<double> discountGiven = GeneratedColumn<double>(
    'discount_given',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _saleDateMeta = const VerificationMeta(
    'saleDate',
  );
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
    'sale_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDate,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    carId,
    customerId,
    salePrice,
    discountGiven,
    saleDate,
    remarks,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    } else if (isInserting) {
      context.missing(_carIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    } else if (isInserting) {
      context.missing(_salePriceMeta);
    }
    if (data.containsKey('discount_given')) {
      context.handle(
        _discountGivenMeta,
        discountGiven.isAcceptableOrUnknown(
          data['discount_given']!,
          _discountGivenMeta,
        ),
      );
    }
    if (data.containsKey('sale_date')) {
      context.handle(
        _saleDateMeta,
        saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}car_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sale_price'],
      )!,
      discountGiven: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_given'],
      )!,
      saleDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sale_date'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final int id;
  final int carId;
  final int customerId;
  final double salePrice;
  final double discountGiven;
  final DateTime saleDate;
  final String? remarks;
  const Sale({
    required this.id,
    required this.carId,
    required this.customerId,
    required this.salePrice,
    required this.discountGiven,
    required this.saleDate,
    this.remarks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['car_id'] = Variable<int>(carId);
    map['customer_id'] = Variable<int>(customerId);
    map['sale_price'] = Variable<double>(salePrice);
    map['discount_given'] = Variable<double>(discountGiven);
    map['sale_date'] = Variable<DateTime>(saleDate);
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      carId: Value(carId),
      customerId: Value(customerId),
      salePrice: Value(salePrice),
      discountGiven: Value(discountGiven),
      saleDate: Value(saleDate),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<int>(json['id']),
      carId: serializer.fromJson<int>(json['carId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      salePrice: serializer.fromJson<double>(json['salePrice']),
      discountGiven: serializer.fromJson<double>(json['discountGiven']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      remarks: serializer.fromJson<String?>(json['remarks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'carId': serializer.toJson<int>(carId),
      'customerId': serializer.toJson<int>(customerId),
      'salePrice': serializer.toJson<double>(salePrice),
      'discountGiven': serializer.toJson<double>(discountGiven),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'remarks': serializer.toJson<String?>(remarks),
    };
  }

  Sale copyWith({
    int? id,
    int? carId,
    int? customerId,
    double? salePrice,
    double? discountGiven,
    DateTime? saleDate,
    Value<String?> remarks = const Value.absent(),
  }) => Sale(
    id: id ?? this.id,
    carId: carId ?? this.carId,
    customerId: customerId ?? this.customerId,
    salePrice: salePrice ?? this.salePrice,
    discountGiven: discountGiven ?? this.discountGiven,
    saleDate: saleDate ?? this.saleDate,
    remarks: remarks.present ? remarks.value : this.remarks,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      carId: data.carId.present ? data.carId.value : this.carId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      discountGiven: data.discountGiven.present
          ? data.discountGiven.value
          : this.discountGiven,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('carId: $carId, ')
          ..write('customerId: $customerId, ')
          ..write('salePrice: $salePrice, ')
          ..write('discountGiven: $discountGiven, ')
          ..write('saleDate: $saleDate, ')
          ..write('remarks: $remarks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    carId,
    customerId,
    salePrice,
    discountGiven,
    saleDate,
    remarks,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.carId == this.carId &&
          other.customerId == this.customerId &&
          other.salePrice == this.salePrice &&
          other.discountGiven == this.discountGiven &&
          other.saleDate == this.saleDate &&
          other.remarks == this.remarks);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<int> id;
  final Value<int> carId;
  final Value<int> customerId;
  final Value<double> salePrice;
  final Value<double> discountGiven;
  final Value<DateTime> saleDate;
  final Value<String?> remarks;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.carId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.discountGiven = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.remarks = const Value.absent(),
  });
  SalesCompanion.insert({
    this.id = const Value.absent(),
    required int carId,
    required int customerId,
    required double salePrice,
    this.discountGiven = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.remarks = const Value.absent(),
  }) : carId = Value(carId),
       customerId = Value(customerId),
       salePrice = Value(salePrice);
  static Insertable<Sale> custom({
    Expression<int>? id,
    Expression<int>? carId,
    Expression<int>? customerId,
    Expression<double>? salePrice,
    Expression<double>? discountGiven,
    Expression<DateTime>? saleDate,
    Expression<String>? remarks,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (carId != null) 'car_id': carId,
      if (customerId != null) 'customer_id': customerId,
      if (salePrice != null) 'sale_price': salePrice,
      if (discountGiven != null) 'discount_given': discountGiven,
      if (saleDate != null) 'sale_date': saleDate,
      if (remarks != null) 'remarks': remarks,
    });
  }

  SalesCompanion copyWith({
    Value<int>? id,
    Value<int>? carId,
    Value<int>? customerId,
    Value<double>? salePrice,
    Value<double>? discountGiven,
    Value<DateTime>? saleDate,
    Value<String?>? remarks,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      customerId: customerId ?? this.customerId,
      salePrice: salePrice ?? this.salePrice,
      discountGiven: discountGiven ?? this.discountGiven,
      saleDate: saleDate ?? this.saleDate,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<int>(carId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (discountGiven.present) {
      map['discount_given'] = Variable<double>(discountGiven.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('carId: $carId, ')
          ..write('customerId: $customerId, ')
          ..write('salePrice: $salePrice, ')
          ..write('discountGiven: $discountGiven, ')
          ..write('saleDate: $saleDate, ')
          ..write('remarks: $remarks')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDate,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    amountPaid,
    paymentDate,
    paymentType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_amountPaidMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_id'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int saleId;
  final double amountPaid;
  final DateTime paymentDate;
  final String paymentType;
  const Payment({
    required this.id,
    required this.saleId,
    required this.amountPaid,
    required this.paymentDate,
    required this.paymentType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<int>(saleId);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['payment_type'] = Variable<String>(paymentType);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      amountPaid: Value(amountPaid),
      paymentDate: Value(paymentDate),
      paymentType: Value(paymentType),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<int>(json['saleId']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<int>(saleId),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'paymentType': serializer.toJson<String>(paymentType),
    };
  }

  Payment copyWith({
    int? id,
    int? saleId,
    double? amountPaid,
    DateTime? paymentDate,
    String? paymentType,
  }) => Payment(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    amountPaid: amountPaid ?? this.amountPaid,
    paymentDate: paymentDate ?? this.paymentDate,
    paymentType: paymentType ?? this.paymentType,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentType: $paymentType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, saleId, amountPaid, paymentDate, paymentType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.amountPaid == this.amountPaid &&
          other.paymentDate == this.paymentDate &&
          other.paymentType == this.paymentType);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> saleId;
  final Value<double> amountPaid;
  final Value<DateTime> paymentDate;
  final Value<String> paymentType;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentType = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int saleId,
    required double amountPaid,
    this.paymentDate = const Value.absent(),
    required String paymentType,
  }) : saleId = Value(saleId),
       amountPaid = Value(amountPaid),
       paymentType = Value(paymentType);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? saleId,
    Expression<double>? amountPaid,
    Expression<DateTime>? paymentDate,
    Expression<String>? paymentType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (paymentType != null) 'payment_type': paymentType,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? saleId,
    Value<double>? amountPaid,
    Value<DateTime>? paymentDate,
    Value<String>? paymentType,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentType: paymentType ?? this.paymentType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentType: $paymentType')
          ..write(')'))
        .toString();
  }
}

class $InvestorsTable extends Investors
    with TableInfo<$InvestorsTable, Investor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, currentBalance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
    );
  }

  @override
  $InvestorsTable createAlias(String alias) {
    return $InvestorsTable(attachedDatabase, alias);
  }
}

class Investor extends DataClass implements Insertable<Investor> {
  final int id;
  final String name;
  final String phone;
  final double currentBalance;
  const Investor({
    required this.id,
    required this.name,
    required this.phone,
    required this.currentBalance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['current_balance'] = Variable<double>(currentBalance);
    return map;
  }

  InvestorsCompanion toCompanion(bool nullToAbsent) {
    return InvestorsCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      currentBalance: Value(currentBalance),
    );
  }

  factory Investor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investor(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'currentBalance': serializer.toJson<double>(currentBalance),
    };
  }

  Investor copyWith({
    int? id,
    String? name,
    String? phone,
    double? currentBalance,
  }) => Investor(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    currentBalance: currentBalance ?? this.currentBalance,
  );
  Investor copyWithCompanion(InvestorsCompanion data) {
    return Investor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('currentBalance: $currentBalance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, currentBalance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investor &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.currentBalance == this.currentBalance);
}

class InvestorsCompanion extends UpdateCompanion<Investor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<double> currentBalance;
  const InvestorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.currentBalance = const Value.absent(),
  });
  InvestorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    this.currentBalance = const Value.absent(),
  }) : name = Value(name),
       phone = Value(phone);
  static Insertable<Investor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<double>? currentBalance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (currentBalance != null) 'current_balance': currentBalance,
    });
  }

  InvestorsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<double>? currentBalance,
  }) {
    return InvestorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('currentBalance: $currentBalance')
          ..write(')'))
        .toString();
  }
}

class $CarInvestmentsTable extends CarInvestments
    with TableInfo<$CarInvestmentsTable, CarInvestment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CarInvestmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _carIdMeta = const VerificationMeta('carId');
  @override
  late final GeneratedColumn<int> carId = GeneratedColumn<int>(
    'car_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cars (id)',
    ),
  );
  static const VerificationMeta _investorIdMeta = const VerificationMeta(
    'investorId',
  );
  @override
  late final GeneratedColumn<int> investorId = GeneratedColumn<int>(
    'investor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investors (id)',
    ),
  );
  static const VerificationMeta _investmentAmountMeta = const VerificationMeta(
    'investmentAmount',
  );
  @override
  late final GeneratedColumn<double> investmentAmount = GeneratedColumn<double>(
    'investment_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profitShareMeta = const VerificationMeta(
    'profitShare',
  );
  @override
  late final GeneratedColumn<double> profitShare = GeneratedColumn<double>(
    'profit_share',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    carId,
    investorId,
    investmentAmount,
    profitShare,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'car_investments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CarInvestment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('car_id')) {
      context.handle(
        _carIdMeta,
        carId.isAcceptableOrUnknown(data['car_id']!, _carIdMeta),
      );
    } else if (isInserting) {
      context.missing(_carIdMeta);
    }
    if (data.containsKey('investor_id')) {
      context.handle(
        _investorIdMeta,
        investorId.isAcceptableOrUnknown(data['investor_id']!, _investorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_investorIdMeta);
    }
    if (data.containsKey('investment_amount')) {
      context.handle(
        _investmentAmountMeta,
        investmentAmount.isAcceptableOrUnknown(
          data['investment_amount']!,
          _investmentAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investmentAmountMeta);
    }
    if (data.containsKey('profit_share')) {
      context.handle(
        _profitShareMeta,
        profitShare.isAcceptableOrUnknown(
          data['profit_share']!,
          _profitShareMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CarInvestment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CarInvestment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      carId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}car_id'],
      )!,
      investorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}investor_id'],
      )!,
      investmentAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}investment_amount'],
      )!,
      profitShare: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}profit_share'],
      ),
    );
  }

  @override
  $CarInvestmentsTable createAlias(String alias) {
    return $CarInvestmentsTable(attachedDatabase, alias);
  }
}

class CarInvestment extends DataClass implements Insertable<CarInvestment> {
  final int id;
  final int carId;
  final int investorId;
  final double investmentAmount;
  final double? profitShare;
  const CarInvestment({
    required this.id,
    required this.carId,
    required this.investorId,
    required this.investmentAmount,
    this.profitShare,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['car_id'] = Variable<int>(carId);
    map['investor_id'] = Variable<int>(investorId);
    map['investment_amount'] = Variable<double>(investmentAmount);
    if (!nullToAbsent || profitShare != null) {
      map['profit_share'] = Variable<double>(profitShare);
    }
    return map;
  }

  CarInvestmentsCompanion toCompanion(bool nullToAbsent) {
    return CarInvestmentsCompanion(
      id: Value(id),
      carId: Value(carId),
      investorId: Value(investorId),
      investmentAmount: Value(investmentAmount),
      profitShare: profitShare == null && nullToAbsent
          ? const Value.absent()
          : Value(profitShare),
    );
  }

  factory CarInvestment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CarInvestment(
      id: serializer.fromJson<int>(json['id']),
      carId: serializer.fromJson<int>(json['carId']),
      investorId: serializer.fromJson<int>(json['investorId']),
      investmentAmount: serializer.fromJson<double>(json['investmentAmount']),
      profitShare: serializer.fromJson<double?>(json['profitShare']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'carId': serializer.toJson<int>(carId),
      'investorId': serializer.toJson<int>(investorId),
      'investmentAmount': serializer.toJson<double>(investmentAmount),
      'profitShare': serializer.toJson<double?>(profitShare),
    };
  }

  CarInvestment copyWith({
    int? id,
    int? carId,
    int? investorId,
    double? investmentAmount,
    Value<double?> profitShare = const Value.absent(),
  }) => CarInvestment(
    id: id ?? this.id,
    carId: carId ?? this.carId,
    investorId: investorId ?? this.investorId,
    investmentAmount: investmentAmount ?? this.investmentAmount,
    profitShare: profitShare.present ? profitShare.value : this.profitShare,
  );
  CarInvestment copyWithCompanion(CarInvestmentsCompanion data) {
    return CarInvestment(
      id: data.id.present ? data.id.value : this.id,
      carId: data.carId.present ? data.carId.value : this.carId,
      investorId: data.investorId.present
          ? data.investorId.value
          : this.investorId,
      investmentAmount: data.investmentAmount.present
          ? data.investmentAmount.value
          : this.investmentAmount,
      profitShare: data.profitShare.present
          ? data.profitShare.value
          : this.profitShare,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CarInvestment(')
          ..write('id: $id, ')
          ..write('carId: $carId, ')
          ..write('investorId: $investorId, ')
          ..write('investmentAmount: $investmentAmount, ')
          ..write('profitShare: $profitShare')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, carId, investorId, investmentAmount, profitShare);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CarInvestment &&
          other.id == this.id &&
          other.carId == this.carId &&
          other.investorId == this.investorId &&
          other.investmentAmount == this.investmentAmount &&
          other.profitShare == this.profitShare);
}

class CarInvestmentsCompanion extends UpdateCompanion<CarInvestment> {
  final Value<int> id;
  final Value<int> carId;
  final Value<int> investorId;
  final Value<double> investmentAmount;
  final Value<double?> profitShare;
  const CarInvestmentsCompanion({
    this.id = const Value.absent(),
    this.carId = const Value.absent(),
    this.investorId = const Value.absent(),
    this.investmentAmount = const Value.absent(),
    this.profitShare = const Value.absent(),
  });
  CarInvestmentsCompanion.insert({
    this.id = const Value.absent(),
    required int carId,
    required int investorId,
    required double investmentAmount,
    this.profitShare = const Value.absent(),
  }) : carId = Value(carId),
       investorId = Value(investorId),
       investmentAmount = Value(investmentAmount);
  static Insertable<CarInvestment> custom({
    Expression<int>? id,
    Expression<int>? carId,
    Expression<int>? investorId,
    Expression<double>? investmentAmount,
    Expression<double>? profitShare,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (carId != null) 'car_id': carId,
      if (investorId != null) 'investor_id': investorId,
      if (investmentAmount != null) 'investment_amount': investmentAmount,
      if (profitShare != null) 'profit_share': profitShare,
    });
  }

  CarInvestmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? carId,
    Value<int>? investorId,
    Value<double>? investmentAmount,
    Value<double?>? profitShare,
  }) {
    return CarInvestmentsCompanion(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      investorId: investorId ?? this.investorId,
      investmentAmount: investmentAmount ?? this.investmentAmount,
      profitShare: profitShare ?? this.profitShare,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (carId.present) {
      map['car_id'] = Variable<int>(carId.value);
    }
    if (investorId.present) {
      map['investor_id'] = Variable<int>(investorId.value);
    }
    if (investmentAmount.present) {
      map['investment_amount'] = Variable<double>(investmentAmount.value);
    }
    if (profitShare.present) {
      map['profit_share'] = Variable<double>(profitShare.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CarInvestmentsCompanion(')
          ..write('id: $id, ')
          ..write('carId: $carId, ')
          ..write('investorId: $investorId, ')
          ..write('investmentAmount: $investmentAmount, ')
          ..write('profitShare: $profitShare')
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
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDate,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, amount, date, category];
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
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
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
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['category'] = Variable<String>(category);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      date: Value(date),
      category: Value(category),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      category: serializer.fromJson<String>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'category': serializer.toJson<String>(category),
    };
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
  }) => Expense(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    category: category ?? this.category,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, amount, date, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.category == this.category);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<String> title;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> category;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.category = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required double amount,
    this.date = const Value.absent(),
    required String category,
  }) : title = Value(title),
       amount = Value(amount),
       category = Value(category);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? category,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (category != null) 'category': category,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String>? category,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CarsTable cars = $CarsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $InvestorsTable investors = $InvestorsTable(this);
  late final $CarInvestmentsTable carInvestments = $CarInvestmentsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cars,
    customers,
    sales,
    payments,
    investors,
    carInvestments,
    expenses,
  ];
}

typedef $$CarsTableCreateCompanionBuilder =
    CarsCompanion Function({
      Value<int> id,
      required String make,
      required String model,
      required String year,
      required String color,
      Value<String?> registrationNumber,
      required String chassisNumber,
      required String engineNumber,
      Value<String> status,
      required double purchasePrice,
      Value<double> repairCost,
      Value<bool> isFileInHand,
      Value<bool> isNumberPlateInHand,
      Value<DateTime> dateAdded,
    });
typedef $$CarsTableUpdateCompanionBuilder =
    CarsCompanion Function({
      Value<int> id,
      Value<String> make,
      Value<String> model,
      Value<String> year,
      Value<String> color,
      Value<String?> registrationNumber,
      Value<String> chassisNumber,
      Value<String> engineNumber,
      Value<String> status,
      Value<double> purchasePrice,
      Value<double> repairCost,
      Value<bool> isFileInHand,
      Value<bool> isNumberPlateInHand,
      Value<DateTime> dateAdded,
    });

final class $$CarsTableReferences
    extends BaseReferences<_$AppDatabase, $CarsTable, Car> {
  $$CarsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTable, List<Sale>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: $_aliasNameGenerator(db.cars.id, db.sales.carId),
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.carId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CarInvestmentsTable, List<CarInvestment>>
  _carInvestmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.carInvestments,
    aliasName: $_aliasNameGenerator(db.cars.id, db.carInvestments.carId),
  );

  $$CarInvestmentsTableProcessedTableManager get carInvestmentsRefs {
    final manager = $$CarInvestmentsTableTableManager(
      $_db,
      $_db.carInvestments,
    ).filter((f) => f.carId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_carInvestmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CarsTableFilterComposer extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chassisNumber => $composableBuilder(
    column: $table.chassisNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get engineNumber => $composableBuilder(
    column: $table.engineNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get repairCost => $composableBuilder(
    column: $table.repairCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFileInHand => $composableBuilder(
    column: $table.isFileInHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNumberPlateInHand => $composableBuilder(
    column: $table.isNumberPlateInHand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.carId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> carInvestmentsRefs(
    Expression<bool> Function($$CarInvestmentsTableFilterComposer f) f,
  ) {
    final $$CarInvestmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carInvestments,
      getReferencedColumn: (t) => t.carId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarInvestmentsTableFilterComposer(
            $db: $db,
            $table: $db.carInvestments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarsTableOrderingComposer extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chassisNumber => $composableBuilder(
    column: $table.chassisNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineNumber => $composableBuilder(
    column: $table.engineNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get repairCost => $composableBuilder(
    column: $table.repairCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFileInHand => $composableBuilder(
    column: $table.isFileInHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNumberPlateInHand => $composableBuilder(
    column: $table.isNumberPlateInHand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarsTable> {
  $$CarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get registrationNumber => $composableBuilder(
    column: $table.registrationNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chassisNumber => $composableBuilder(
    column: $table.chassisNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get engineNumber => $composableBuilder(
    column: $table.engineNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get repairCost => $composableBuilder(
    column: $table.repairCost,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFileInHand => $composableBuilder(
    column: $table.isFileInHand,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isNumberPlateInHand => $composableBuilder(
    column: $table.isNumberPlateInHand,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.carId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> carInvestmentsRefs<T extends Object>(
    Expression<T> Function($$CarInvestmentsTableAnnotationComposer a) f,
  ) {
    final $$CarInvestmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carInvestments,
      getReferencedColumn: (t) => t.carId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarInvestmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.carInvestments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CarsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarsTable,
          Car,
          $$CarsTableFilterComposer,
          $$CarsTableOrderingComposer,
          $$CarsTableAnnotationComposer,
          $$CarsTableCreateCompanionBuilder,
          $$CarsTableUpdateCompanionBuilder,
          (Car, $$CarsTableReferences),
          Car,
          PrefetchHooks Function({bool salesRefs, bool carInvestmentsRefs})
        > {
  $$CarsTableTableManager(_$AppDatabase db, $CarsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> make = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> year = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String?> registrationNumber = const Value.absent(),
                Value<String> chassisNumber = const Value.absent(),
                Value<String> engineNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> repairCost = const Value.absent(),
                Value<bool> isFileInHand = const Value.absent(),
                Value<bool> isNumberPlateInHand = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
              }) => CarsCompanion(
                id: id,
                make: make,
                model: model,
                year: year,
                color: color,
                registrationNumber: registrationNumber,
                chassisNumber: chassisNumber,
                engineNumber: engineNumber,
                status: status,
                purchasePrice: purchasePrice,
                repairCost: repairCost,
                isFileInHand: isFileInHand,
                isNumberPlateInHand: isNumberPlateInHand,
                dateAdded: dateAdded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String make,
                required String model,
                required String year,
                required String color,
                Value<String?> registrationNumber = const Value.absent(),
                required String chassisNumber,
                required String engineNumber,
                Value<String> status = const Value.absent(),
                required double purchasePrice,
                Value<double> repairCost = const Value.absent(),
                Value<bool> isFileInHand = const Value.absent(),
                Value<bool> isNumberPlateInHand = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
              }) => CarsCompanion.insert(
                id: id,
                make: make,
                model: model,
                year: year,
                color: color,
                registrationNumber: registrationNumber,
                chassisNumber: chassisNumber,
                engineNumber: engineNumber,
                status: status,
                purchasePrice: purchasePrice,
                repairCost: repairCost,
                isFileInHand: isFileInHand,
                isNumberPlateInHand: isNumberPlateInHand,
                dateAdded: dateAdded,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CarsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({salesRefs = false, carInvestmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (salesRefs) db.sales,
                    if (carInvestmentsRefs) db.carInvestments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (salesRefs)
                        await $_getPrefetchedData<Car, $CarsTable, Sale>(
                          currentTable: table,
                          referencedTable: $$CarsTableReferences
                              ._salesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CarsTableReferences(db, table, p0).salesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.carId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (carInvestmentsRefs)
                        await $_getPrefetchedData<
                          Car,
                          $CarsTable,
                          CarInvestment
                        >(
                          currentTable: table,
                          referencedTable: $$CarsTableReferences
                              ._carInvestmentsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CarsTableReferences(
                            db,
                            table,
                            p0,
                          ).carInvestmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.carId == item.id,
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

typedef $$CarsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarsTable,
      Car,
      $$CarsTableFilterComposer,
      $$CarsTableOrderingComposer,
      $$CarsTableAnnotationComposer,
      $$CarsTableCreateCompanionBuilder,
      $$CarsTableUpdateCompanionBuilder,
      (Car, $$CarsTableReferences),
      Car,
      PrefetchHooks Function({bool salesRefs, bool carInvestmentsRefs})
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required String fullName,
      required String phone,
      Value<String?> cnic,
      Value<String?> address,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<String> fullName,
      Value<String> phone,
      Value<String?> cnic,
      Value<String?> address,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTable, List<Sale>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: $_aliasNameGenerator(db.customers.id, db.sales.customerId),
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnic => $composableBuilder(
    column: $table.cnic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnic => $composableBuilder(
    column: $table.cnic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get cnic =>
      $composableBuilder(column: $table.cnic, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({bool salesRefs})
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> cnic = const Value.absent(),
                Value<String?> address = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                fullName: fullName,
                phone: phone,
                cnic: cnic,
                address: address,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fullName,
                required String phone,
                Value<String?> cnic = const Value.absent(),
                Value<String?> address = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                fullName: fullName,
                phone: phone,
                cnic: cnic,
                address: address,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({salesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (salesRefs) db.sales],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesRefs)
                    await $_getPrefetchedData<Customer, $CustomersTable, Sale>(
                      currentTable: table,
                      referencedTable: $$CustomersTableReferences
                          ._salesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomersTableReferences(db, table, p0).salesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.customerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({bool salesRefs})
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      Value<int> id,
      required int carId,
      required int customerId,
      required double salePrice,
      Value<double> discountGiven,
      Value<DateTime> saleDate,
      Value<String?> remarks,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<int> id,
      Value<int> carId,
      Value<int> customerId,
      Value<double> salePrice,
      Value<double> discountGiven,
      Value<DateTime> saleDate,
      Value<String?> remarks,
    });

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, Sale> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CarsTable _carIdTable(_$AppDatabase db) =>
      db.cars.createAlias($_aliasNameGenerator(db.sales.carId, db.cars.id));

  $$CarsTableProcessedTableManager get carId {
    final $_column = $_itemColumn<int>('car_id')!;

    final manager = $$CarsTableTableManager(
      $_db,
      $_db.cars,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) => db.customers
      .createAlias($_aliasNameGenerator(db.sales.customerId, db.customers.id));

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(db.sales.id, db.payments.saleId),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountGiven => $composableBuilder(
    column: $table.discountGiven,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  $$CarsTableFilterComposer get carId {
    final $$CarsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableFilterComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountGiven => $composableBuilder(
    column: $table.discountGiven,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  $$CarsTableOrderingComposer get carId {
    final $$CarsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableOrderingComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<double> get discountGiven => $composableBuilder(
    column: $table.discountGiven,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  $$CarsTableAnnotationComposer get carId {
    final $$CarsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableAnnotationComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, $$SalesTableReferences),
          Sale,
          PrefetchHooks Function({
            bool carId,
            bool customerId,
            bool paymentsRefs,
          })
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> carId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<double> salePrice = const Value.absent(),
                Value<double> discountGiven = const Value.absent(),
                Value<DateTime> saleDate = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                carId: carId,
                customerId: customerId,
                salePrice: salePrice,
                discountGiven: discountGiven,
                saleDate: saleDate,
                remarks: remarks,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int carId,
                required int customerId,
                required double salePrice,
                Value<double> discountGiven = const Value.absent(),
                Value<DateTime> saleDate = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                carId: carId,
                customerId: customerId,
                salePrice: salePrice,
                discountGiven: discountGiven,
                saleDate: saleDate,
                remarks: remarks,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SalesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({carId = false, customerId = false, paymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (paymentsRefs) db.payments],
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
                        if (carId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.carId,
                                    referencedTable: $$SalesTableReferences
                                        ._carIdTable(db),
                                    referencedColumn: $$SalesTableReferences
                                        ._carIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$SalesTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$SalesTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsRefs)
                        await $_getPrefetchedData<Sale, $SalesTable, Payment>(
                          currentTable: table,
                          referencedTable: $$SalesTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
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

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, $$SalesTableReferences),
      Sale,
      PrefetchHooks Function({bool carId, bool customerId, bool paymentsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      required int saleId,
      required double amountPaid,
      Value<DateTime> paymentDate,
      required String paymentType,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      Value<int> saleId,
      Value<double> amountPaid,
      Value<DateTime> paymentDate,
      Value<String> paymentType,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) => db.sales.createAlias(
    $_aliasNameGenerator(db.payments.saleId, db.sales.id),
  );

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<int>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool saleId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> saleId = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                saleId: saleId,
                amountPaid: amountPaid,
                paymentDate: paymentDate,
                paymentType: paymentType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int saleId,
                required double amountPaid,
                Value<DateTime> paymentDate = const Value.absent(),
                required String paymentType,
              }) => PaymentsCompanion.insert(
                id: id,
                saleId: saleId,
                amountPaid: amountPaid,
                paymentDate: paymentDate,
                paymentType: paymentType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false}) {
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
                    if (saleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.saleId,
                                referencedTable: $$PaymentsTableReferences
                                    ._saleIdTable(db),
                                referencedColumn: $$PaymentsTableReferences
                                    ._saleIdTable(db)
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

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool saleId})
    >;
typedef $$InvestorsTableCreateCompanionBuilder =
    InvestorsCompanion Function({
      Value<int> id,
      required String name,
      required String phone,
      Value<double> currentBalance,
    });
typedef $$InvestorsTableUpdateCompanionBuilder =
    InvestorsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> phone,
      Value<double> currentBalance,
    });

final class $$InvestorsTableReferences
    extends BaseReferences<_$AppDatabase, $InvestorsTable, Investor> {
  $$InvestorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CarInvestmentsTable, List<CarInvestment>>
  _carInvestmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.carInvestments,
    aliasName: $_aliasNameGenerator(
      db.investors.id,
      db.carInvestments.investorId,
    ),
  );

  $$CarInvestmentsTableProcessedTableManager get carInvestmentsRefs {
    final manager = $$CarInvestmentsTableTableManager(
      $_db,
      $_db.carInvestments,
    ).filter((f) => f.investorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_carInvestmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvestorsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestorsTable> {
  $$InvestorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> carInvestmentsRefs(
    Expression<bool> Function($$CarInvestmentsTableFilterComposer f) f,
  ) {
    final $$CarInvestmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carInvestments,
      getReferencedColumn: (t) => t.investorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarInvestmentsTableFilterComposer(
            $db: $db,
            $table: $db.carInvestments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestorsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestorsTable> {
  $$InvestorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestorsTable> {
  $$InvestorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  Expression<T> carInvestmentsRefs<T extends Object>(
    Expression<T> Function($$CarInvestmentsTableAnnotationComposer a) f,
  ) {
    final $$CarInvestmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.carInvestments,
      getReferencedColumn: (t) => t.investorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarInvestmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.carInvestments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestorsTable,
          Investor,
          $$InvestorsTableFilterComposer,
          $$InvestorsTableOrderingComposer,
          $$InvestorsTableAnnotationComposer,
          $$InvestorsTableCreateCompanionBuilder,
          $$InvestorsTableUpdateCompanionBuilder,
          (Investor, $$InvestorsTableReferences),
          Investor,
          PrefetchHooks Function({bool carInvestmentsRefs})
        > {
  $$InvestorsTableTableManager(_$AppDatabase db, $InvestorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
              }) => InvestorsCompanion(
                id: id,
                name: name,
                phone: phone,
                currentBalance: currentBalance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String phone,
                Value<double> currentBalance = const Value.absent(),
              }) => InvestorsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                currentBalance: currentBalance,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({carInvestmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (carInvestmentsRefs) db.carInvestments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (carInvestmentsRefs)
                    await $_getPrefetchedData<
                      Investor,
                      $InvestorsTable,
                      CarInvestment
                    >(
                      currentTable: table,
                      referencedTable: $$InvestorsTableReferences
                          ._carInvestmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$InvestorsTableReferences(
                            db,
                            table,
                            p0,
                          ).carInvestmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.investorId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$InvestorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestorsTable,
      Investor,
      $$InvestorsTableFilterComposer,
      $$InvestorsTableOrderingComposer,
      $$InvestorsTableAnnotationComposer,
      $$InvestorsTableCreateCompanionBuilder,
      $$InvestorsTableUpdateCompanionBuilder,
      (Investor, $$InvestorsTableReferences),
      Investor,
      PrefetchHooks Function({bool carInvestmentsRefs})
    >;
typedef $$CarInvestmentsTableCreateCompanionBuilder =
    CarInvestmentsCompanion Function({
      Value<int> id,
      required int carId,
      required int investorId,
      required double investmentAmount,
      Value<double?> profitShare,
    });
typedef $$CarInvestmentsTableUpdateCompanionBuilder =
    CarInvestmentsCompanion Function({
      Value<int> id,
      Value<int> carId,
      Value<int> investorId,
      Value<double> investmentAmount,
      Value<double?> profitShare,
    });

final class $$CarInvestmentsTableReferences
    extends BaseReferences<_$AppDatabase, $CarInvestmentsTable, CarInvestment> {
  $$CarInvestmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CarsTable _carIdTable(_$AppDatabase db) => db.cars.createAlias(
    $_aliasNameGenerator(db.carInvestments.carId, db.cars.id),
  );

  $$CarsTableProcessedTableManager get carId {
    final $_column = $_itemColumn<int>('car_id')!;

    final manager = $$CarsTableTableManager(
      $_db,
      $_db.cars,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_carIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InvestorsTable _investorIdTable(_$AppDatabase db) =>
      db.investors.createAlias(
        $_aliasNameGenerator(db.carInvestments.investorId, db.investors.id),
      );

  $$InvestorsTableProcessedTableManager get investorId {
    final $_column = $_itemColumn<int>('investor_id')!;

    final manager = $$InvestorsTableTableManager(
      $_db,
      $_db.investors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CarInvestmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CarInvestmentsTable> {
  $$CarInvestmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get investmentAmount => $composableBuilder(
    column: $table.investmentAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get profitShare => $composableBuilder(
    column: $table.profitShare,
    builder: (column) => ColumnFilters(column),
  );

  $$CarsTableFilterComposer get carId {
    final $$CarsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableFilterComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableFilterComposer get investorId {
    final $$InvestorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableFilterComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarInvestmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CarInvestmentsTable> {
  $$CarInvestmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get investmentAmount => $composableBuilder(
    column: $table.investmentAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get profitShare => $composableBuilder(
    column: $table.profitShare,
    builder: (column) => ColumnOrderings(column),
  );

  $$CarsTableOrderingComposer get carId {
    final $$CarsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableOrderingComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableOrderingComposer get investorId {
    final $$InvestorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableOrderingComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarInvestmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CarInvestmentsTable> {
  $$CarInvestmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get investmentAmount => $composableBuilder(
    column: $table.investmentAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get profitShare => $composableBuilder(
    column: $table.profitShare,
    builder: (column) => column,
  );

  $$CarsTableAnnotationComposer get carId {
    final $$CarsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.carId,
      referencedTable: $db.cars,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CarsTableAnnotationComposer(
            $db: $db,
            $table: $db.cars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableAnnotationComposer get investorId {
    final $$InvestorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableAnnotationComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CarInvestmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CarInvestmentsTable,
          CarInvestment,
          $$CarInvestmentsTableFilterComposer,
          $$CarInvestmentsTableOrderingComposer,
          $$CarInvestmentsTableAnnotationComposer,
          $$CarInvestmentsTableCreateCompanionBuilder,
          $$CarInvestmentsTableUpdateCompanionBuilder,
          (CarInvestment, $$CarInvestmentsTableReferences),
          CarInvestment,
          PrefetchHooks Function({bool carId, bool investorId})
        > {
  $$CarInvestmentsTableTableManager(
    _$AppDatabase db,
    $CarInvestmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CarInvestmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CarInvestmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CarInvestmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> carId = const Value.absent(),
                Value<int> investorId = const Value.absent(),
                Value<double> investmentAmount = const Value.absent(),
                Value<double?> profitShare = const Value.absent(),
              }) => CarInvestmentsCompanion(
                id: id,
                carId: carId,
                investorId: investorId,
                investmentAmount: investmentAmount,
                profitShare: profitShare,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int carId,
                required int investorId,
                required double investmentAmount,
                Value<double?> profitShare = const Value.absent(),
              }) => CarInvestmentsCompanion.insert(
                id: id,
                carId: carId,
                investorId: investorId,
                investmentAmount: investmentAmount,
                profitShare: profitShare,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CarInvestmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({carId = false, investorId = false}) {
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
                    if (carId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.carId,
                                referencedTable: $$CarInvestmentsTableReferences
                                    ._carIdTable(db),
                                referencedColumn:
                                    $$CarInvestmentsTableReferences
                                        ._carIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (investorId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.investorId,
                                referencedTable: $$CarInvestmentsTableReferences
                                    ._investorIdTable(db),
                                referencedColumn:
                                    $$CarInvestmentsTableReferences
                                        ._investorIdTable(db)
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

typedef $$CarInvestmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CarInvestmentsTable,
      CarInvestment,
      $$CarInvestmentsTableFilterComposer,
      $$CarInvestmentsTableOrderingComposer,
      $$CarInvestmentsTableAnnotationComposer,
      $$CarInvestmentsTableCreateCompanionBuilder,
      $$CarInvestmentsTableUpdateCompanionBuilder,
      (CarInvestment, $$CarInvestmentsTableReferences),
      CarInvestment,
      PrefetchHooks Function({bool carId, bool investorId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      required String title,
      required double amount,
      Value<DateTime> date,
      required String category,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<double> amount,
      Value<DateTime> date,
      Value<String> category,
    });

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
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
          (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
          Expense,
          PrefetchHooks Function()
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
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> category = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                title: title,
                amount: amount,
                date: date,
                category: category,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required double amount,
                Value<DateTime> date = const Value.absent(),
                required String category,
              }) => ExpensesCompanion.insert(
                id: id,
                title: title,
                amount: amount,
                date: date,
                category: category,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
      Expense,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CarsTableTableManager get cars => $$CarsTableTableManager(_db, _db.cars);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$InvestorsTableTableManager get investors =>
      $$InvestorsTableTableManager(_db, _db.investors);
  $$CarInvestmentsTableTableManager get carInvestments =>
      $$CarInvestmentsTableTableManager(_db, _db.carInvestments);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class CarExpense {
  final String title;
  final int amount;
  final DateTime? date;

  const CarExpense({required this.title, required this.amount, this.date});

  factory CarExpense.fromMap(Map<String, dynamic> m) => CarExpense(
        title: asString(m['title']),
        amount: asInt(m['amount']),
        date: tsToDate(m['date']),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'date': dateToTs(date),
      };
}

/// Car / Inventory item.
///
/// Status values: 'Available' | 'Booked' | 'Sold'
class Car {
  final String id;
  final String name;
  final String make;
  final String model;
  final int year;
  final String color;
  final int price;
  final int? demandPrice;
  final String regNo;
  final String status;
  final String? buyerId; // Customer doc id
  final String? buyerName; // Denormalized for display
  final String mileage;
  final String fuel;
  final String transmission;
  final String chassisNo;
  final String engineNo;
  final String? investorId; // Investor doc id
  final String? investorName; // Denormalized
  final bool fileHandedOver;
  final bool smartCardHandedOver;
  final bool numberPlateHandedOver;
  final bool remoteKeyHandedOver;
  final List<String> photos;
  final List<CarExpense> carExpenses;
  final String? sellerName;
  final String? sellerPhone;
  final String? sellerCnic;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Car({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.price,
    this.demandPrice,
    required this.regNo,
    required this.status,
    this.buyerId,
    this.buyerName,
    required this.mileage,
    required this.fuel,
    required this.transmission,
    required this.chassisNo,
    required this.engineNo,
    this.investorId,
    this.investorName,
    this.fileHandedOver = false,
    this.smartCardHandedOver = false,
    this.numberPlateHandedOver = false,
    this.remoteKeyHandedOver = false,
    this.photos = const [],
    this.carExpenses = const [],
    this.sellerName,
    this.sellerPhone,
    this.sellerCnic,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Car.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) =>
      Car.fromMap(s.id, s.data() ?? const {});

  /// Build a [Car] from a plain map — works for both `cloud_firestore`
  /// snapshots and the Firestore REST API (whose values arrive already
  /// unwrapped via `FirestoreRest`).
  factory Car.fromMap(String id, Map<String, dynamic> m) => Car(
        id: id,
        name: asString(m['name']),
        make: asString(m['make']),
        model: asString(m['model']),
        year: asInt(m['year']),
        color: asString(m['color']),
        price: asInt(m['price']),
        demandPrice: m['demandPrice'] == null ? null : asInt(m['demandPrice']),
        regNo: asString(m['regNo']),
        status: asString(m['status'], 'Available'),
        buyerId: m['buyerId'] as String?,
        buyerName: m['buyerName'] as String?,
        mileage: asString(m['mileage']),
        fuel: asString(m['fuel']),
        transmission: asString(m['transmission']),
        chassisNo: asString(m['chassisNo']),
        engineNo: asString(m['engineNo']),
        investorId: m['investorId'] as String?,
        investorName: m['investorName'] as String?,
        fileHandedOver: asBool(m['fileHandedOver']),
        smartCardHandedOver: asBool(m['smartCardHandedOver']),
        numberPlateHandedOver: asBool(m['numberPlateHandedOver']),
        remoteKeyHandedOver: asBool(m['remoteKeyHandedOver']),
        photos: asStringList(m['photos']),
        carExpenses: ((m['carExpenses'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CarExpense.fromMap)
            .toList(),
        sellerName: m['sellerName'] as String?,
        sellerPhone: m['sellerPhone'] as String?,
        sellerCnic: m['sellerCnic'] as String?,
        notes: m['notes'] as String?,
        createdAt: tsToDate(m['createdAt']),
        updatedAt: tsToDate(m['updatedAt']),
      );

  /// Alias of [fromMap] with the standard JSON-style name.
  factory Car.fromJson(String id, Map<String, dynamic> json) =>
      Car.fromMap(id, json);

  Map<String, dynamic> toMap() => {
        'name': name,
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        'price': price,
        if (demandPrice != null) 'demandPrice': demandPrice,
        'regNo': regNo,
        'status': status,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'mileage': mileage,
        'fuel': fuel,
        'transmission': transmission,
        'chassisNo': chassisNo,
        'engineNo': engineNo,
        'investorId': investorId,
        'investorName': investorName,
        'fileHandedOver': fileHandedOver,
        'smartCardHandedOver': smartCardHandedOver,
        'numberPlateHandedOver': numberPlateHandedOver,
        'remoteKeyHandedOver': remoteKeyHandedOver,
        'photos': photos,
        'carExpenses': carExpenses.map((e) => e.toMap()).toList(),
        'sellerName': sellerName,
        'sellerPhone': sellerPhone,
        'sellerCnic': sellerCnic,
        'notes': notes,
        'createdAt': dateToTs(createdAt) ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Alias of [toMap] with the standard JSON-style name.
  Map<String, dynamic> toJson() => toMap();

  Car copyWith({
    String? name,
    String? make,
    String? model,
    int? year,
    String? color,
    int? price,
    int? demandPrice,
    String? regNo,
    String? status,
    String? buyerId,
    String? buyerName,
    String? mileage,
    String? fuel,
    String? transmission,
    String? chassisNo,
    String? engineNo,
    String? investorId,
    String? investorName,
    bool? fileHandedOver,
    bool? smartCardHandedOver,
    bool? numberPlateHandedOver,
    bool? remoteKeyHandedOver,
    List<String>? photos,
    List<CarExpense>? carExpenses,
    String? sellerName,
    String? sellerPhone,
    String? sellerCnic,
    String? notes,
  }) =>
      Car(
        id: id,
        name: name ?? this.name,
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        color: color ?? this.color,
        price: price ?? this.price,
        demandPrice: demandPrice ?? this.demandPrice,
        regNo: regNo ?? this.regNo,
        status: status ?? this.status,
        buyerId: buyerId ?? this.buyerId,
        buyerName: buyerName ?? this.buyerName,
        mileage: mileage ?? this.mileage,
        fuel: fuel ?? this.fuel,
        transmission: transmission ?? this.transmission,
        chassisNo: chassisNo ?? this.chassisNo,
        engineNo: engineNo ?? this.engineNo,
        investorId: investorId ?? this.investorId,
        investorName: investorName ?? this.investorName,
        fileHandedOver: fileHandedOver ?? this.fileHandedOver,
        smartCardHandedOver: smartCardHandedOver ?? this.smartCardHandedOver,
        numberPlateHandedOver:
            numberPlateHandedOver ?? this.numberPlateHandedOver,
        remoteKeyHandedOver: remoteKeyHandedOver ?? this.remoteKeyHandedOver,
        photos: photos ?? this.photos,
        carExpenses: carExpenses ?? this.carExpenses,
        sellerName: sellerName ?? this.sellerName,
        sellerPhone: sellerPhone ?? this.sellerPhone,
        sellerCnic: sellerCnic ?? this.sellerCnic,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

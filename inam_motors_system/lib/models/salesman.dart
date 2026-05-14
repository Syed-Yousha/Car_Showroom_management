import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

/// Sale record under a salesman: salesmen/{salesmanId}/sales/{saleId}
class SalesmanSale {
  final String id;
  final String carId;
  final String carName;
  final String buyerId;
  final String buyerName;
  final int salePrice;
  final int profit;
  final DateTime date;
  final String type; // Cash | Installment

  const SalesmanSale({
    required this.id,
    required this.carId,
    required this.carName,
    required this.buyerId,
    required this.buyerName,
    required this.salePrice,
    required this.profit,
    required this.date,
    required this.type,
  });

  factory SalesmanSale.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final m = s.data() ?? {};
    return SalesmanSale(
      id: s.id,
      carId: asString(m['carId']),
      carName: asString(m['carName']),
      buyerId: asString(m['buyerId']),
      buyerName: asString(m['buyerName']),
      salePrice: asInt(m['salePrice']),
      profit: asInt(m['profit']),
      date: tsToDate(m['date']) ?? DateTime.now(),
      type: asString(m['type'], 'Cash'),
    );
  }

  Map<String, dynamic> toMap() => {
        'carId': carId,
        'carName': carName,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'salePrice': salePrice,
        'profit': profit,
        'date': dateToTs(date),
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class Salesman {
  final String id;
  final String name;
  final String phone;
  final String role;
  final int share; // %
  final DateTime? joinDate;
  final String status;
  // Cached aggregates updated by transactions
  final int totalSales;
  final int totalRevenue;
  final int totalProfit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Salesman({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.share,
    this.joinDate,
    this.status = 'Active',
    this.totalSales = 0,
    this.totalRevenue = 0,
    this.totalProfit = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Salesman.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) =>
      Salesman.fromRestMap(s.id, s.data() ?? const {});

  /// Hydrates a [Salesman] from a plain map — works for both Firestore
  /// snapshots and REST API responses (whose values arrive already unwrapped).
  factory Salesman.fromRestMap(String id, Map<String, dynamic> m) => Salesman(
        id: id,
        name: asString(m['name']),
        phone: asString(m['phone']),
        role: asString(m['role']),
        share: asInt(m['share']),
        joinDate: tsToDate(m['joinDate']),
        status: asString(m['status'], 'Active'),
        totalSales: asInt(m['totalSales']),
        totalRevenue: asInt(m['totalRevenue']),
        totalProfit: asInt(m['totalProfit']),
        createdAt: tsToDate(m['createdAt']),
        updatedAt: tsToDate(m['updatedAt']),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'role': role,
        'share': share,
        'joinDate': dateToTs(joinDate),
        'status': status,
        'totalSales': totalSales,
        'totalRevenue': totalRevenue,
        'totalProfit': totalProfit,
        'createdAt': dateToTs(createdAt) ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Salesman copyWith({
    String? name,
    String? phone,
    String? role,
    int? share,
    DateTime? joinDate,
    String? status,
    int? totalSales,
    int? totalRevenue,
    int? totalProfit,
  }) =>
      Salesman(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        share: share ?? this.share,
        joinDate: joinDate ?? this.joinDate,
        status: status ?? this.status,
        totalSales: totalSales ?? this.totalSales,
        totalRevenue: totalRevenue ?? this.totalRevenue,
        totalProfit: totalProfit ?? this.totalProfit,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

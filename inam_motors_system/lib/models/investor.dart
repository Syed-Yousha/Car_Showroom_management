import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class Investor {
  final String id;
  final String name;
  final String role;
  final int invested;
  final int share; // %
  final int profit;
  final String phone;
  final DateTime? joinDate;
  final String status;
  /// Capital currently tied up in unsold cars assigned to this investor.
  /// Maintained by `InventoryService.addCar` (and friends) via WriteBatch.
  final int heldAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Investor({
    required this.id,
    required this.name,
    required this.role,
    required this.invested,
    required this.share,
    required this.profit,
    required this.phone,
    this.joinDate,
    this.status = 'Active',
    this.heldAmount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Investor.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) =>
      Investor.fromMap(s.id, s.data() ?? const {});

  /// Build an [Investor] from a plain map — works for both `cloud_firestore`
  /// snapshots and the Firestore REST API (whose values arrive already
  /// unwrapped via `FirestoreRest`).
  factory Investor.fromMap(String id, Map<String, dynamic> m) => Investor(
        id: id,
        name: asString(m['name']),
        role: asString(m['role']),
        invested: asInt(m['invested']),
        share: asInt(m['share']),
        profit: asInt(m['profit']),
        phone: asString(m['phone']),
        joinDate: tsToDate(m['joinDate']),
        status: asString(m['status'], 'Active'),
        heldAmount: asInt(m['heldAmount']),
        createdAt: tsToDate(m['createdAt']),
        updatedAt: tsToDate(m['updatedAt']),
      );

  /// Alias of [fromMap] with the standard JSON-style name.
  factory Investor.fromJson(String id, Map<String, dynamic> json) =>
      Investor.fromMap(id, json);

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        'invested': invested,
        'share': share,
        'profit': profit,
        'phone': phone,
        'joinDate': dateToTs(joinDate),
        'status': status,
        'heldAmount': heldAmount,
        'createdAt': dateToTs(createdAt) ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Alias of [toMap] with the standard JSON-style name.
  Map<String, dynamic> toJson() => toMap();

  Investor copyWith({
    String? name,
    String? role,
    int? invested,
    int? share,
    int? profit,
    String? phone,
    DateTime? joinDate,
    String? status,
    int? heldAmount,
  }) =>
      Investor(
        id: id,
        name: name ?? this.name,
        role: role ?? this.role,
        invested: invested ?? this.invested,
        share: share ?? this.share,
        profit: profit ?? this.profit,
        phone: phone ?? this.phone,
        joinDate: joinDate ?? this.joinDate,
        status: status ?? this.status,
        heldAmount: heldAmount ?? this.heldAmount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

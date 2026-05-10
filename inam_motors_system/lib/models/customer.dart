import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

/// Customer master record. Ledger entries are stored as a sub-collection
/// (`customers/{customerId}/ledger/{entryId}`) — see LedgerEntry.
class Customer {
  final String id;
  final String name;
  final String phone;
  final String cnic;
  final String city;
  final String address;
  final String type; // VIP | Regular | New | Lead
  final int balance; // Cached: positive = owed to us, negative = credit
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.cnic,
    required this.city,
    required this.address,
    required this.type,
    this.balance = 0,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) =>
      Customer.fromMap(s.id, s.data() ?? const {});

  /// Build a [Customer] from a plain map — works for both `cloud_firestore`
  /// snapshots and the Firestore REST API (whose values arrive already
  /// unwrapped via `FirestoreRest`).
  factory Customer.fromMap(String id, Map<String, dynamic> m) => Customer(
        id: id,
        name: asString(m['name']),
        phone: asString(m['phone']),
        cnic: asString(m['cnic']),
        city: asString(m['city']),
        address: asString(m['address']),
        type: asString(m['type'], 'Regular'),
        balance: asInt(m['balance']),
        notes: m['notes'] as String?,
        createdAt: tsToDate(m['createdAt']),
        updatedAt: tsToDate(m['updatedAt']),
      );

  /// Alias of [fromMap] with the standard JSON-style name.
  factory Customer.fromJson(String id, Map<String, dynamic> json) =>
      Customer.fromMap(id, json);

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'cnic': cnic,
        'city': city,
        'address': address,
        'type': type,
        'balance': balance,
        'notes': notes,
        'createdAt': dateToTs(createdAt) ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Alias of [toMap] with the standard JSON-style name.
  Map<String, dynamic> toJson() => toMap();

  Customer copyWith({
    String? name,
    String? phone,
    String? cnic,
    String? city,
    String? address,
    String? type,
    int? balance,
    String? notes,
  }) =>
      Customer(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        cnic: cnic ?? this.cnic,
        city: city ?? this.city,
        address: address ?? this.address,
        type: type ?? this.type,
        balance: balance ?? this.balance,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

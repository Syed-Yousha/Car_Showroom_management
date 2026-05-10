import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

/// Ledger / Transaction entry under a customer.
/// Path: customers/{customerId}/ledger/{entryId}
///
/// type: 'Car Sale' | 'Trade-In' | 'Payment' | 'Credit Refund'
class LedgerEntry {
  final String id;
  final String customerId;
  final DateTime date;
  final String type;
  final String details;
  final int debit;
  final int credit;
  final String salesman; // For 'Car Sale': sold by; 'Payment': received by; 'Credit Refund': given by; 'Trade-In': bought by
  final String? carId; // Only for Car Sale / Trade-In
  final String? carName;
  // Sell Car specifics
  final bool fullPayment;
  final DateTime? dueDate;
  // Payment specifics
  final bool paymentFullPayment;
  final DateTime? remainingDueDate;
  final DateTime? createdAt;

  const LedgerEntry({
    required this.id,
    required this.customerId,
    required this.date,
    required this.type,
    required this.details,
    this.debit = 0,
    this.credit = 0,
    this.salesman = '',
    this.carId,
    this.carName,
    this.fullPayment = false,
    this.dueDate,
    this.paymentFullPayment = false,
    this.remainingDueDate,
    this.createdAt,
  });

  factory LedgerEntry.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> s,
    String customerId,
  ) {
    final m = s.data() ?? {};
    return LedgerEntry(
      id: s.id,
      customerId: customerId,
      date: tsToDate(m['date']) ?? DateTime.now(),
      type: asString(m['type']),
      details: asString(m['details']),
      debit: asInt(m['debit']),
      credit: asInt(m['credit']),
      salesman: asString(m['salesman']),
      carId: m['carId'] as String?,
      carName: m['carName'] as String?,
      fullPayment: asBool(m['fullPayment']),
      dueDate: tsToDate(m['dueDate']),
      paymentFullPayment: asBool(m['paymentFullPayment']),
      remainingDueDate: tsToDate(m['remainingDueDate']),
      createdAt: tsToDate(m['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'date': dateToTs(date),
        'type': type,
        'details': details,
        'debit': debit,
        'credit': credit,
        'salesman': salesman,
        'carId': carId,
        'carName': carName,
        'fullPayment': fullPayment,
        'dueDate': dateToTs(dueDate),
        'paymentFullPayment': paymentFullPayment,
        'remainingDueDate': dateToTs(remainingDueDate),
        'createdAt': dateToTs(createdAt) ?? FieldValue.serverTimestamp(),
      };

  /// Net balance impact: positive means customer owes more.
  int get balanceDelta => debit - credit;

  LedgerEntry copyWith({
    DateTime? date,
    String? type,
    String? details,
    int? debit,
    int? credit,
    String? salesman,
    String? carId,
    String? carName,
    bool? fullPayment,
    DateTime? dueDate,
    bool? paymentFullPayment,
    DateTime? remainingDueDate,
  }) =>
      LedgerEntry(
        id: id,
        customerId: customerId,
        date: date ?? this.date,
        type: type ?? this.type,
        details: details ?? this.details,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
        salesman: salesman ?? this.salesman,
        carId: carId ?? this.carId,
        carName: carName ?? this.carName,
        fullPayment: fullPayment ?? this.fullPayment,
        dueDate: dueDate ?? this.dueDate,
        paymentFullPayment: paymentFullPayment ?? this.paymentFullPayment,
        remainingDueDate: remainingDueDate ?? this.remainingDueDate,
        createdAt: createdAt,
      );
}

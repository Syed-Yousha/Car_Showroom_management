import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class Expense {
  final String id;
  final String title;
  final String category;
  final int amount;
  final DateTime date;
  final String paidTo;
  final String method;
  final bool recurring;
  final String? carId; // Optional: link maintenance expenses to a car
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.paidTo,
    required this.method,
    this.recurring = false,
    this.carId,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final m = s.data() ?? {};
    return Expense(
      id: s.id,
      title: asString(m['title']),
      category: asString(m['category']),
      amount: asInt(m['amount']),
      date: tsToDate(m['date']) ?? DateTime.now(),
      paidTo: asString(m['paidTo']),
      method: asString(m['method']),
      recurring: asBool(m['recurring']),
      carId: m['carId'] as String?,
      createdAt: tsToDate(m['createdAt']),
      updatedAt: tsToDate(m['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'amount': amount,
        'date': dateToTs(date),
        'paidTo': paidTo,
        'method': method,
        'recurring': recurring,
        'carId': carId,
        'createdAt': dateToTs(createdAt) ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Expense copyWith({
    String? title,
    String? category,
    int? amount,
    DateTime? date,
    String? paidTo,
    String? method,
    bool? recurring,
    String? carId,
  }) =>
      Expense(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        paidTo: paidTo ?? this.paidTo,
        method: method ?? this.method,
        recurring: recurring ?? this.recurring,
        carId: carId ?? this.carId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

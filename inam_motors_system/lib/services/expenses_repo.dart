import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

/// Path: expenses/{expenseId}
class ExpensesRepo {
  ExpensesRepo({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Expense> get _col =>
      _db.collection('expenses').withConverter<Expense>(
            fromFirestore: (snap, _) => Expense.fromSnapshot(snap),
            toFirestore: (e, _) => e.toMap(),
          );

  Stream<List<Expense>> watchAll() => _col
      .orderBy('date', descending: true)
      .snapshots()
      .map((q) => q.docs.map((d) => d.data()).toList());

  Stream<Expense?> watchOne(String id) =>
      _col.doc(id).snapshots().map((s) => s.exists ? s.data() : null);

  Future<Expense?> getOne(String id) async {
    final s = await _col.doc(id).get();
    return s.exists ? s.data() : null;
  }

  Future<String> add(Expense e) async {
    final ref = await _col.add(e);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) =>
      _db.collection('expenses').doc(id).update({
        ...partial,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) => _col.doc(id).delete();
}

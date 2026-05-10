import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';

/// Path: customers/{customerId}
class CustomersRepo {
  CustomersRepo({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Customer> get _col =>
      _db.collection('customers').withConverter<Customer>(
            fromFirestore: (snap, _) => Customer.fromSnapshot(snap),
            toFirestore: (c, _) => c.toMap(),
          );

  Stream<List<Customer>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map((d) => d.data()).toList());

  Stream<Customer?> watchOne(String id) =>
      _col.doc(id).snapshots().map((s) => s.exists ? s.data() : null);

  Future<Customer?> getOne(String id) async {
    final s = await _col.doc(id).get();
    return s.exists ? s.data() : null;
  }

  Future<String> add(Customer c) async {
    final ref = await _col.add(c);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) =>
      _db.collection('customers').doc(id).update({
        ...partial,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// Deletes the customer and **all** their ledger entries.
  /// Uses a batch (capped at 500 ops; the customer has far fewer entries
  /// in any realistic scenario for this app).
  Future<void> deleteWithLedger(String id) async {
    final ledger = await _db
        .collection('customers')
        .doc(id)
        .collection('ledger')
        .get();
    final batch = _db.batch();
    for (final d in ledger.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_db.collection('customers').doc(id));
    await batch.commit();
  }
}

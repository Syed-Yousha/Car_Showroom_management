import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import 'firestore_rest.dart';

/// Path: customers/{customerId}
///
/// CRUD-only — read paths live in [CustomerService] (REST). This repo
/// invalidates the `customers` REST cache after every write so the next read
/// returns fresh data.
class CustomersRepo {
  CustomersRepo({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  set rest(FirestoreRest r) => _rest = r;
  FirestoreRest? get _restClient => _rest;

  static const _collection = 'customers';

  void _invalidate() => _restClient?.clearCache(_collection);

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
    _invalidate();
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) async {
    await _db.collection(_collection).doc(id).update({
      ...partial,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _invalidate();
  }

  /// Deletes the customer and **all** their ledger entries.
  /// Uses a batch (capped at 500 ops; the customer has far fewer entries
  /// in any realistic scenario for this app).
  Future<void> deleteWithLedger(String id) async {
    final ledger = await _db
        .collection(_collection)
        .doc(id)
        .collection('ledger')
        .get();
    final batch = _db.batch();
    for (final d in ledger.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_db.collection(_collection).doc(id));
    await batch.commit();
    _invalidate();
    // The ledger sub-collection path also lives in the REST cache (keyed by
    // 'customers/{id}/ledger'); drop those too.
    _restClient?.clearCache('$_collection/$id/ledger');
  }
}

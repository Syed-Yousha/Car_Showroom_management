import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/salesman.dart';
import 'firestore_rest.dart';

/// Path: salesmen/{salesmanId}
/// Path: salesmen/{salesmanId}/sales/{saleId}
///
/// `listAllSafe` reads via REST (Windows C++ SDK crashes on `.get()`); writes
/// continue to use the SDK directly.
class SalesmenRepo {
  SalesmenRepo({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;
  set rest(FirestoreRest r) => _rest = r;
  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  Future<List<Salesman>> listAllSafe() async {
    final docs = await _restClient.listDocs('salesmen');
    // Salesman.fromSnapshot wraps a DocumentSnapshot — we need a from-map path.
    // The Salesman model doesn't have one yet; build the entity by faking the
    // structure REST returns. Simpler: hand back raw maps for backup, but
    // existing repos return typed models, so synthesise via toMap fields.
    return docs.map((d) => Salesman.fromRestMap(d.id, d.data)).toList();
  }

  CollectionReference<Salesman> get _col =>
      _db.collection('salesmen').withConverter<Salesman>(
            fromFirestore: (snap, _) => Salesman.fromSnapshot(snap),
            toFirestore: (s, _) => s.toMap(),
          );

  Stream<List<Salesman>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map((d) => d.data()).toList());

  Stream<Salesman?> watchOne(String id) =>
      _col.doc(id).snapshots().map((s) => s.exists ? s.data() : null);

  Future<Salesman?> getOne(String id) async {
    final s = await _col.doc(id).get();
    return s.exists ? s.data() : null;
  }

  Future<String> add(Salesman s) async {
    final ref = await _col.add(s);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) =>
      _db.collection('salesmen').doc(id).update({
        ...partial,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Stream<List<SalesmanSale>> watchSales(String salesmanId) => _db
      .collection('salesmen')
      .doc(salesmanId)
      .collection('sales')
      .orderBy('date', descending: true)
      .snapshots()
      .map((q) => q.docs.map(SalesmanSale.fromSnapshot).toList());

  Future<void> delete(String id) => _col.doc(id).delete();
}

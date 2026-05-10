import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/salesman.dart';

/// Path: salesmen/{salesmanId}
/// Path: salesmen/{salesmanId}/sales/{saleId}
class SalesmenRepo {
  SalesmenRepo({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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

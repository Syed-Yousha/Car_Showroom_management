import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

/// Path: cars/{carId}
class CarsRepo {
  CarsRepo({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Car> get _col =>
      _db.collection('cars').withConverter<Car>(
            fromFirestore: (snap, _) => Car.fromSnapshot(snap),
            toFirestore: (car, _) => car.toMap(),
          );

  Stream<List<Car>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map((d) => d.data()).toList());

  Stream<List<Car>> watchAvailable() => _col
      .where('status', isEqualTo: 'Available')
      .snapshots()
      .map((q) => q.docs.map((d) => d.data()).toList());

  Stream<Car?> watchOne(String id) =>
      _col.doc(id).snapshots().map((s) => s.exists ? s.data() : null);

  Future<Car?> getOne(String id) async {
    final s = await _col.doc(id).get();
    return s.exists ? s.data() : null;
  }

  Future<String> add(Car car) async {
    final ref = await _col.add(car);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) =>
      _db.collection('cars').doc(id).update({
        ...partial,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) => _col.doc(id).delete();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import '../models/investor.dart';
import 'firestore_rest.dart';

/// Inventory service — strictly independent CRUD.
///
/// No side effects on Investors or Documents. Sister modules read the
/// same `cars/` collection if they need to derive state; they must not
/// rely on this service writing into their collections.
class InventoryService {
  InventoryService({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  set rest(FirestoreRest r) => _rest = r;

  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  Future<List<Car>> fetchCarsSafe({bool forceRefresh = false}) async {
    final docs = await _restClient.listDocs('cars', forceRefresh: forceRefresh);
    final cars = docs.map((d) => Car.fromMap(d.id, d.data)).toList();
    cars.sort((a, b) {
      final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });
    return cars;
  }

  /// Adds a car. No writes to other collections.
  Future<String> addCar(Car car, {Investor? investor}) async {
    final carRef = _db.collection('cars').doc();
    final carData = {
      ...car.toMap(),
      'status': 'Available',
      'investorId': investor?.id,
      'investorName': investor?.name,
    };
    await carRef.set(carData);
    _restClient.clearCache('cars');
    return carRef.id;
  }

  /// Overwrites a car doc. No writes to other collections.
  Future<void> updateCar(
    Car newCar, {
    Investor? oldInvestor,
    int oldPrice = 0,
    Investor? newInvestor,
  }) async {
    if (newCar.id.isEmpty) {
      throw ArgumentError('updateCar: Car.id is required.');
    }
    await _db.collection('cars').doc(newCar.id).set({
      ...newCar.toMap(),
      'investorId': newInvestor?.id,
      'investorName': newInvestor?.name,
    });
    _restClient.clearCache('cars');
  }

  /// Marks a car Sold. No writes to other collections.
  Future<void> markCarSold(
    String carId, {
    required String buyerId,
    required String buyerName,
    String buyerPhone = '',
  }) async {
    if (carId.isEmpty) throw ArgumentError('markCarSold: carId is required.');
    await _db.collection('cars').doc(carId).set({
      'status': 'Sold',
      'buyerId': buyerId,
      'buyerName': buyerName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _restClient.clearCache('cars');
  }

  /// Deletes a car. No writes to other collections.
  Future<void> deleteCar({
    required String carId,
    Investor? previousInvestor,
    int carPrice = 0,
  }) async {
    if (carId.isEmpty) throw ArgumentError('deleteCar: carId is required.');
    await _db.collection('cars').doc(carId).delete();
    _restClient.clearCache('cars');
  }
}

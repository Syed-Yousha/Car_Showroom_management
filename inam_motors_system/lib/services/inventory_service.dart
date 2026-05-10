import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import '../models/investor.dart';
import 'document_service.dart';
import 'firestore_rest.dart';

/// Concise service for inventory: writes go through the SDK, reads go
/// through the Firestore REST API (the Windows C++ Firestore SDK crashes
/// on every `.get()` / `.snapshots()` — REST is the safe transport).
class InventoryService {
  InventoryService({
    FirebaseFirestore? db,
    FirestoreRest? rest,
    DocumentService? documents,
  })  : _db = db ?? FirebaseFirestore.instance,
        _rest = rest,
        _docs = documents;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;
  DocumentService? _docs;

  /// Allow main.dart to inject the global REST client after Firebase has
  /// been initialised (the REST singleton can't be built before then).
  set rest(FirestoreRest r) => _rest = r;

  set documents(DocumentService d) => _docs = d;

  FirestoreRest get _restClient => _rest ??= FirestoreRest();
  DocumentService get _docService => _docs ??= DocumentService(rest: _restClient);

  // ── READS (REST — safe on Windows) ─────────────────────────────────────

  /// Fetches every car from `cars/` via the Firestore REST API.
  /// CRITICAL: this is the ONLY way to read cars on Windows. Do not call
  /// `FirebaseFirestore.instance.collection('cars').get()` or `.snapshots()`
  /// — those crash the C++ SDK with no catchable exception.
  Future<List<Car>> fetchCarsSafe() async {
    print('[Inventory] fetchCarsSafe: GET /cars via REST...');
    final docs = await _restClient.listDocs('cars');
    print('[Inventory] fetchCarsSafe: got ${docs.length} car(s)');
    final cars = docs.map((d) => Car.fromMap(d.id, d.data)).toList();
    // Newest first. Cars without a createdAt (legacy seed data) sort to the
    // bottom so freshly-added entries always appear at the top of the grid.
    cars.sort((a, b) {
      final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });
    return cars;
  }

  // ── WRITES (SDK — works fine on Windows, with caveats) ─────────────────

  /// Adds a new car (status: Available) and, if [investor] is provided,
  /// rewrites that investor's `heldAmount` to include the new car's price.
  /// Also creates a paired `documents/{carId}` record so the new car shows
  /// up in the Docs & Files screen immediately.
  ///
  /// IMPORTANT — Windows-specific implementation:
  /// We do NOT use `WriteBatch` here, and we do NOT use `FieldValue.increment`.
  /// Both crash the Windows C++ Firestore plugin with
  /// `Unknown type in StandardCodecSerializer::ReadValueOfType: 142`
  /// (the platform channel can't serialize FieldValue.increment to native).
  /// Each write is a plain `set()` — not atomic, but stable on Windows.
  ///
  /// Returns the new car's document id.
  Future<String> addCar(Car car, {Investor? investor}) async {
    final carRef = _db.collection('cars').doc();
    final carData = {
      ...car.toMap(),
      'status': 'Available',
      'investorId': investor?.id,
      'investorName': investor?.name,
    };
    print('[Inventory] addCar: writing cars/${carRef.id} (price=${car.price})...');
    await carRef.set(carData);
    print('[Inventory] addCar: car write OK');

    if (investor != null && investor.id.isNotEmpty) {
      final newHeld = investor.heldAmount + car.price;
      print('[Inventory] addCar: updating investors/${investor.id} '
          'heldAmount ${investor.heldAmount} → $newHeld');
      final updated = investor.copyWith(heldAmount: newHeld);
      await _db
          .collection('investors')
          .doc(investor.id)
          .set(updated.toMap());
      print('[Inventory] addCar: investor heldAmount updated OK');
    }

    // Mirror into Docs & Files. Best-effort — if it fails, inventory write
    // already succeeded so we don't roll anything back.
    try {
      await _docService.upsertFromCar(
        car,
        carIdOverride: carRef.id,
        isNewRecord: true,
      );
    } catch (e, s) {
      print('[Inventory] addCar: docs mirror failed: $e\n$s');
    }

    return carRef.id;
  }

  /// Overwrites an existing car doc (full replacement via plain `set()`)
  /// and adjusts investor `heldAmount` on the affected parties:
  ///   - Same investor, price changed → delta on that investor
  ///   - Investor changed → subtract old price from old, add new price to new
  ///   - Investor added/removed → only one side adjusts
  /// Also refreshes the matching `documents/{carId}` surface metadata
  /// (handover state is preserved).
  /// All writes are plain `set()` — no `WriteBatch`, no `FieldValue.increment`.
  Future<void> updateCar(
    Car newCar, {
    Investor? oldInvestor,
    int oldPrice = 0,
    Investor? newInvestor,
  }) async {
    if (newCar.id.isEmpty) {
      throw ArgumentError('updateCar: Car.id is required.');
    }

    print('[Inventory] updateCar: writing cars/${newCar.id}...');
    await _db.collection('cars').doc(newCar.id).set({
      ...newCar.toMap(),
      'investorId': newInvestor?.id,
      'investorName': newInvestor?.name,
    });
    print('[Inventory] updateCar: car write OK');

    final oldId = oldInvestor?.id ?? '';
    final newId = newInvestor?.id ?? '';

    if (oldId.isNotEmpty && oldId == newId) {
      if (oldPrice != newCar.price && oldInvestor != null) {
        final delta = newCar.price - oldPrice;
        final newHeld = (oldInvestor.heldAmount + delta).clamp(0, 1 << 62);
        print('[Inventory] updateCar: $oldId heldAmount '
            '${oldInvestor.heldAmount} → $newHeld (delta $delta)');
        final updated = oldInvestor.copyWith(heldAmount: newHeld);
        await _db.collection('investors').doc(oldId).set(updated.toMap());
      }
    } else {
      if (oldInvestor != null && oldId.isNotEmpty && oldPrice > 0) {
        final newHeld =
            (oldInvestor.heldAmount - oldPrice).clamp(0, 1 << 62);
        print('[Inventory] updateCar: old $oldId heldAmount '
            '${oldInvestor.heldAmount} → $newHeld');
        final updated = oldInvestor.copyWith(heldAmount: newHeld);
        await _db.collection('investors').doc(oldId).set(updated.toMap());
      }
      if (newInvestor != null && newId.isNotEmpty && newCar.price > 0) {
        final newHeld = newInvestor.heldAmount + newCar.price;
        print('[Inventory] updateCar: new $newId heldAmount '
            '${newInvestor.heldAmount} → $newHeld');
        final updated = newInvestor.copyWith(heldAmount: newHeld);
        await _db.collection('investors').doc(newId).set(updated.toMap());
      }
    }

    // Mirror inventory checkboxes into Docs & Files. Inventory edits are
    // authoritative for receipt state — un/checking here flips the doc
    // record between 'inOffice' and 'notReceived'.
    try {
      await _docService.upsertFromCar(newCar);
    } catch (e, s) {
      print('[Inventory] updateCar: docs mirror failed: $e\n$s');
    }
  }

  /// Marks an existing car as Sold and records buyer info on the doc.
  /// Uses `set()` with `merge: true` so we only touch the relevant fields
  /// without re-writing the whole car record (which we don't have client-side
  /// when this is called from the customer-side Add Transaction flow).
  ///
  /// Also propagates the buyer onto the matching `documents/{carId}` record
  /// so the Docs & Files screen shows the buyer + sold status without the
  /// user having to re-enter it.
  ///
  /// Heldamount accounting on the linked investor is intentionally NOT
  /// adjusted here — selling doesn't make the investor's capital disappear,
  /// it converts to profit which we'll reconcile in a future settlement step.
  Future<void> markCarSold(
    String carId, {
    required String buyerId,
    required String buyerName,
    String buyerPhone = '',
  }) async {
    if (carId.isEmpty) throw ArgumentError('markCarSold: carId is required.');
    print('[Inventory] markCarSold: cars/$carId buyer=$buyerName');
    await _db.collection('cars').doc(carId).set({
      'status': 'Sold',
      'buyerId': buyerId,
      'buyerName': buyerName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    print('[Inventory] markCarSold: OK');

    try {
      await _docService.markBuyerOnSell(
        carId: carId,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
      );
    } catch (e, s) {
      print('[Inventory] markCarSold: docs mirror failed: $e\n$s');
    }
  }

  /// Deletes a car. If [previousInvestor] is provided, subtracts [carPrice]
  /// from their `heldAmount` so capital accounting stays consistent. Also
  /// removes the matching `documents/{carId}` record so deleted cars don't
  /// linger in the Docs & Files screen.
  Future<void> deleteCar({
    required String carId,
    Investor? previousInvestor,
    int carPrice = 0,
  }) async {
    if (carId.isEmpty) throw ArgumentError('deleteCar: carId is required.');

    print('[Inventory] deleteCar: deleting cars/$carId...');
    await _db.collection('cars').doc(carId).delete();
    print('[Inventory] deleteCar: car deleted OK');

    if (previousInvestor != null &&
        previousInvestor.id.isNotEmpty &&
        carPrice > 0) {
      final newHeld =
          (previousInvestor.heldAmount - carPrice).clamp(0, 1 << 62);
      print('[Inventory] deleteCar: investors/${previousInvestor.id} '
          'heldAmount ${previousInvestor.heldAmount} → $newHeld');
      final updated = previousInvestor.copyWith(heldAmount: newHeld);
      await _db
          .collection('investors')
          .doc(previousInvestor.id)
          .set(updated.toMap());
      print('[Inventory] deleteCar: investor heldAmount updated OK');
    }

    try {
      await _docService.delete(carId);
    } catch (e, s) {
      print('[Inventory] deleteCar: docs mirror failed: $e\n$s');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import 'firestore_rest.dart';

/// Document tracking service. Mirrors `InventoryService`'s shape:
///   • Reads via REST (Windows C++ SDK crashes on `.get()` / `.snapshots()`).
///   • Writes via plain `set()` / `delete()` (no batches, no FieldValue.increment).
///
/// Each car in inventory gets a matching `documents/{carId}` record so the
/// Docs & Files screen can render handover state per item (file, smart card,
/// plate, remote/key). Manual entries written through the "Add Document Entry"
/// form get an auto-generated id and have `carId == null`, so they only show
/// in Docs & Files — they never bleed into the Inventory screen.
class DocumentService {
  DocumentService({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  set rest(FirestoreRest r) => _rest = r;
  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  // ── READS (REST) ────────────────────────────────────────────────────────

  /// Returns every doc record (car-linked + manual) as raw maps with `id`
  /// injected. The Docs screen consumes maps directly so we keep the same
  /// shape it already expects.
  Future<List<Map<String, dynamic>>> fetchAllSafe({
    bool forceRefresh = false,
  }) async {
    print('[Docs] fetchAllSafe: GET /documents via REST '
        '(forceRefresh=$forceRefresh)...');
    final docs = await _restClient.listDocs(
      'documents',
      forceRefresh: forceRefresh,
    );
    print('[Docs] fetchAllSafe: got ${docs.length} record(s)');
    return docs.map((d) => {'id': d.id, ...d.data}).toList();
  }

  // ── WRITES (SDK plain set/delete) ───────────────────────────────────────

  /// Creates or refreshes the documents/{carId} record from a Car. The
  /// inventory's per-doc booleans (`fileHandedOver`, `smartCardHandedOver`,
  /// `numberPlateHandedOver`, `remoteKeyHandedOver`) carry the office's
  /// receipt state — checked = the doc is in office, unchecked = not yet
  /// received from the previous owner. This method maps that to the docs
  /// collection as:
  ///   - true  → status: 'inOffice'
  ///   - false → status: 'notReceived'
  ///
  /// Once a car is sold, the customer-side handover flow flips items to
  /// `'handedOver'` via [savePartial], which does NOT come through here —
  /// so subsequent inventory edits will, intentionally, overwrite the
  /// handover state. Inventory is the source of truth for receipt; the
  /// Docs & Files screen's edit dialog is the source of truth for outgoing
  /// handover.
  Future<void> upsertFromCar(
    Car car, {
    String? carIdOverride,
    bool isNewRecord = false,
  }) async {
    final id = carIdOverride ?? car.id;
    if (id.isEmpty) return;
    final ref = _db.collection('documents').doc(id);

    Map<String, dynamic> docState(bool inOffice) => {
          'status': inOffice ? 'inOffice' : 'notReceived',
          'to': null,
          'phone': null,
          'date': null,
        };

    final base = <String, dynamic>{
      'carId': id,
      'carName': car.name,
      'year': car.year,
      'regNo': car.regNo,
      'chassisNo': car.chassisNo,
      'engineNo': car.engineNo,
      'carStatus': car.status,
      'carColor': car.color,
      'file': docState(car.fileHandedOver),
      'smartCard': docState(car.smartCardHandedOver),
      'plate': docState(car.numberPlateHandedOver),
      'remoteKey': docState(car.remoteKeyHandedOver),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isNewRecord) {
      base['extraNotes'] = '';
      base['createdAt'] = FieldValue.serverTimestamp();
    }

    print('[Docs] upsertFromCar: writing documents/$id (new=$isNewRecord)');
    await ref.set(base, SetOptions(merge: true));
    _restClient.clearCache('documents');
    print('[Docs] upsertFromCar: OK');
  }

  /// Records buyer info on the doc record when a car is sold. Does not
  /// touch per-item handover state — that's the sales clerk's manual step
  /// later, in the Docs & Files edit dialog.
  Future<void> markBuyerOnSell({
    required String carId,
    required String buyerName,
    required String buyerPhone,
  }) async {
    if (carId.isEmpty) return;
    final ref = _db.collection('documents').doc(carId);
    print('[Docs] markBuyerOnSell: documents/$carId buyer=$buyerName');
    await ref.set({
      'buyer': buyerName,
      'buyerPhone': buyerPhone,
      'carStatus': 'Sold',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _restClient.clearCache('documents');
    print('[Docs] markBuyerOnSell: OK');
  }

  /// Saves an arbitrary partial update to a doc record (e.g. from the
  /// Docs & Files edit dialog). Always merges so we never blow away unset
  /// fields.
  Future<void> savePartial(String docId, Map<String, dynamic> partial) async {
    if (docId.isEmpty) {
      throw ArgumentError('savePartial: docId is required.');
    }
    final ref = _db.collection('documents').doc(docId);
    print('[Docs] savePartial: documents/$docId keys=${partial.keys.toList()}');
    await ref.set({
      ...partial,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _restClient.clearCache('documents');
    print('[Docs] savePartial: OK');
  }

  /// Adds a manual document record (no carId — so it won't appear in
  /// Inventory). Used by the "Add Document Entry" form for legacy/old
  /// records that the user wants to track but don't correspond to current
  /// inventory cars.
  Future<String> addManual(Map<String, dynamic> data) async {
    final ref = _db.collection('documents').doc();
    print('[Docs] addManual: writing documents/${ref.id}');
    await ref.set({
      ...data,
      'carId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _restClient.clearCache('documents');
    print('[Docs] addManual: OK');
    return ref.id;
  }

  /// Deletes a doc record. Called when a car is removed from inventory
  /// (cascading delete) or when the user removes a manual entry from the
  /// Docs & Files screen.
  Future<void> delete(String docId) async {
    if (docId.isEmpty) {
      throw ArgumentError('delete: docId is required.');
    }
    print('[Docs] delete: documents/$docId');
    await _db.collection('documents').doc(docId).delete();
    _restClient.clearCache('documents');
    print('[Docs] delete: OK');
  }
}

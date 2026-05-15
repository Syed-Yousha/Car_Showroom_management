import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import 'firestore_rest.dart';

/// Path: expenses/{expenseId}
///
/// Reads go through the REST API (`listAll`/`getOne`) because the Windows
/// `cloud_firestore` plugin crashes on `.get()` and `.snapshots()`. Writes
/// stay on the SDK — those work fine.
class ExpensesRepo {
  ExpensesRepo({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  /// Allow main.dart to inject the REST client after Firebase has been
  /// initialised (the global REST singleton can't be built before then).
  set rest(FirestoreRest r) => _rest = r;

  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  static const _collection = 'expenses';

  // ── Reads (REST + cache) ────────────────────────────────────────────────

  Future<List<Expense>> listAll({bool forceRefresh = false}) async {
    final docs = await _restClient.listDocs(
      _collection,
      forceRefresh: forceRefresh,
    );
    final list = docs.map((d) => Expense.fromMap(d.id, d.data)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<Expense?> getOne(String id, {bool forceRefresh = false}) async {
    final doc = await _restClient.getDoc(
      _collection,
      id,
      forceRefresh: forceRefresh,
    );
    return doc == null ? null : Expense.fromMap(doc.id, doc.data);
  }

  // ── Writes (SDK; invalidate cache afterwards) ───────────────────────────

  Future<String> add(Expense e) async {
    final ref = _db.collection(_collection).doc();
    await ref.set(e.toMap());
    _restClient.clearCache(_collection);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) async {
    await _db.collection(_collection).doc(id).set({
      ...partial,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _restClient.clearCache(_collection);
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
    _restClient.clearCache(_collection);
  }
}

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

  // ── Reads (REST) ─────────────────────────────────────────────────────────

  Future<List<Expense>> listAll() async {
    final docs = await _restClient.listDocs('expenses');
    final list = docs.map((d) => Expense.fromMap(d.id, d.data)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<Expense?> getOne(String id) async {
    final doc = await _restClient.getDoc('expenses', id);
    return doc == null ? null : Expense.fromMap(doc.id, doc.data);
  }

  // ── Writes (SDK — plain set/delete, Windows-safe) ───────────────────────

  Future<String> add(Expense e) async {
    final ref = _db.collection('expenses').doc();
    await ref.set(e.toMap());
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) =>
      _db.collection('expenses').doc(id).set({
        ...partial,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  Future<void> delete(String id) => _db.collection('expenses').doc(id).delete();
}

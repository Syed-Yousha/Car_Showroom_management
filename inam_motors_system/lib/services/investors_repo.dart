import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/investor.dart';
import 'firestore_rest.dart';

/// Path: investors/{investorId}
///
/// Reads go through the REST API (`listAll`/`getOne`) because the Windows
/// `cloud_firestore` plugin crashes on `.get()` and `.snapshots()`. Writes
/// stay on the SDK — those work fine.
class InvestorsRepo {
  InvestorsRepo({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  /// Allow main.dart to inject the REST client after Firebase has been
  /// initialised (the global REST singleton can't be built before then).
  set rest(FirestoreRest r) => _rest = r;

  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  static const _collection = 'investors';

  // ── Reads (REST + cache) ────────────────────────────────────────────────

  /// Hits the in-memory REST cache first. Pass `forceRefresh: true` to
  /// bypass the cache (e.g. from a manual refresh button).
  Future<List<Investor>> listAll({bool forceRefresh = false}) async {
    final docs = await _restClient.listDocs(
      _collection,
      forceRefresh: forceRefresh,
    );
    return docs.map((d) => Investor.fromMap(d.id, d.data)).toList();
  }

  Future<Investor?> getOne(String id, {bool forceRefresh = false}) async {
    final doc = await _restClient.getDoc(
      _collection,
      id,
      forceRefresh: forceRefresh,
    );
    return doc == null ? null : Investor.fromMap(doc.id, doc.data);
  }

  // ── Writes (SDK; invalidate cache afterwards) ───────────────────────────

  Future<String> add(Investor i) async {
    final ref = await _db.collection(_collection).add(i.toMap());
    _restClient.clearCache(_collection);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) async {
    await _db.collection(_collection).doc(id).update({
      ...partial,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _restClient.clearCache(_collection);
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
    _restClient.clearCache(_collection);
  }
}

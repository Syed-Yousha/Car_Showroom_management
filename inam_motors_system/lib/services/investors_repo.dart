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

  // ── Reads (REST) ─────────────────────────────────────────────────────────

  Future<List<Investor>> listAll() async {
    final docs = await _restClient.listDocs('investors');
    return docs.map((d) => Investor.fromMap(d.id, d.data)).toList();
  }

  Future<Investor?> getOne(String id) async {
    final doc = await _restClient.getDoc('investors', id);
    return doc == null ? null : Investor.fromMap(doc.id, doc.data);
  }

  // ── Writes (SDK) ─────────────────────────────────────────────────────────

  Future<String> add(Investor i) async {
    final ref = await _db.collection('investors').add(i.toMap());
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) =>
      _db.collection('investors').doc(id).update({
        ...partial,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) => _db.collection('investors').doc(id).delete();
}

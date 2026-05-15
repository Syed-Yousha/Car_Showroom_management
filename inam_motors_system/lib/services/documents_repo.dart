import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_record.dart';
import 'firestore_rest.dart';

/// Path: documents/{recordId}
///
/// Reads via REST (Windows C++ Firestore SDK crashes on every `.get()` /
/// `.snapshots()`). Writes via plain `set()` / `set(merge:true)` / `delete()`
/// — never `WriteBatch` and never `FieldValue.increment` (both crash the
/// Windows codec).
class DocumentsRepo {
  DocumentsRepo({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  set rest(FirestoreRest r) => _rest = r;
  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  static const _collection = 'documents';

  CollectionReference<Map<String, dynamic>> get _rawCol =>
      _db.collection(_collection);

  Future<List<DocumentRecord>> listAll({bool forceRefresh = false}) async {
    final docs = await _restClient.listDocs(
      _collection,
      forceRefresh: forceRefresh,
    );
    return docs.map((d) => DocumentRecord.fromMap(d.id, d.data)).toList();
  }

  Future<String> add(DocumentRecord r) async {
    final ref = _rawCol.doc();
    await ref.set(r.toMap());
    _restClient.clearCache(_collection);
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> partial) async {
    await _rawCol.doc(id).set({
      ...partial,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _restClient.clearCache(_collection);
  }

  Future<void> delete(String id) async {
    await _rawCol.doc(id).delete();
    _restClient.clearCache(_collection);
  }
}

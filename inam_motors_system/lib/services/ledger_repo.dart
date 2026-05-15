import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ledger_entry.dart';
import 'firestore_rest.dart';

/// Path: customers/{customerId}/ledger/{entryId}
///
/// Writes invalidate the REST cache so [LedgerService.fetchLedgerSafe] returns
/// fresh data on next read.
class LedgerRepo {
  LedgerRepo({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  set rest(FirestoreRest r) => _rest = r;
  FirestoreRest? get _restClient => _rest;

  String _path(String customerId) => 'customers/$customerId/ledger';

  CollectionReference<Map<String, dynamic>> _rawCol(String customerId) =>
      _db.collection('customers').doc(customerId).collection('ledger');

  Stream<List<LedgerEntry>> watchFor(String customerId) => _rawCol(customerId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((q) => q.docs
          .map((d) => LedgerEntry.fromSnapshot(d, customerId))
          .toList());

  Future<List<LedgerEntry>> getFor(String customerId) async {
    final q = await _rawCol(customerId).orderBy('date', descending: true).get();
    return q.docs.map((d) => LedgerEntry.fromSnapshot(d, customerId)).toList();
  }

  Future<void> update(
    String customerId,
    String entryId,
    Map<String, dynamic> partial,
  ) async {
    await _rawCol(customerId).doc(entryId).update(partial);
    _restClient?.clearCache(_path(customerId));
  }

  Future<void> delete(String customerId, String entryId) async {
    await _rawCol(customerId).doc(entryId).delete();
    _restClient?.clearCache(_path(customerId));
  }
}

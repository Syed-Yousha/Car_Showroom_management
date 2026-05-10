import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ledger_entry.dart';

/// Path: customers/{customerId}/ledger/{entryId}
class LedgerRepo {
  LedgerRepo({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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
  ) =>
      _rawCol(customerId).doc(entryId).update(partial);

  Future<void> delete(String customerId, String entryId) =>
      _rawCol(customerId).doc(entryId).delete();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';
import 'firestore_rest.dart';

/// CRUD for a customer's ledger sub-collection
/// (`customers/{customerId}/ledger/{entryId}`) plus the matching adjustment
/// of the parent customer's denormalized `balance` field.
///
/// Reads via REST, writes via SDK using only plain `set()` / `delete()` —
/// no `WriteBatch` and no `FieldValue.increment` (both crash the Windows
/// platform-channel codec).
class LedgerService {
  LedgerService({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  set rest(FirestoreRest r) => _rest = r;

  /// Self-bootstraps a `FirestoreRest` if main.dart's injection hasn't
  /// happened yet (e.g. across hot-reloads which don't re-run main()).
  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  // ── READS (REST — safe on Windows) ─────────────────────────────────────

  /// Fetches every ledger entry for [customerId] via REST. Returns
  /// `List<Map<String, dynamic>>` (raw doc data + injected `id` field) so
  /// the existing rendering code, which already consumes maps, keeps working
  /// without translation.
  Future<List<Map<String, dynamic>>> fetchLedgerSafe(String customerId) async {
    if (customerId.isEmpty) return const [];
    final path = 'customers/$customerId/ledger';
    print('[Ledger] fetchLedgerSafe: GET /$path via REST...');
    final docs = await _restClient.listDocs(path);
    print('[Ledger] fetchLedgerSafe: got ${docs.length} entry/entries');
    return docs.map((d) => {'id': d.id, ...d.data}).toList();
  }

  // ── WRITES (SDK — plain set/delete, no batch, no increment) ────────────

  /// Adds a new ledger entry under the customer + adjusts customer.balance
  /// by (debit - credit). Two separate writes; not atomic, but safe on
  /// Windows. Returns the new entry's doc id.
  Future<String> addEntry({
    required Customer customer,
    required Map<String, dynamic> entryData,
    required int debit,
    required int credit,
  }) async {
    final entryRef =
        _db.collection('customers').doc(customer.id).collection('ledger').doc();
    print('[Ledger] addEntry: writing ${entryRef.path}...');
    await entryRef.set({
      ...entryData,
      'debit': debit,
      'credit': credit,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('[Ledger] addEntry: entry write OK');

    final delta = debit - credit;
    if (delta != 0) {
      final newBalance = customer.balance + delta;
      print('[Ledger] addEntry: customer.balance ${customer.balance} → $newBalance');
      final updated = customer.copyWith(balance: newBalance);
      await _db.collection('customers').doc(customer.id).set(updated.toMap());
      print('[Ledger] addEntry: customer balance updated OK');
    }

    return entryRef.id;
  }

  /// Replaces an existing entry (full doc rewrite via plain `set()`) and
  /// adjusts customer.balance by ((newDebit - newCredit) - (oldDebit - oldCredit)).
  Future<void> updateEntry({
    required Customer customer,
    required String entryId,
    required Map<String, dynamic> entryData,
    required int oldDebit,
    required int oldCredit,
    required int newDebit,
    required int newCredit,
  }) async {
    if (entryId.isEmpty) {
      throw ArgumentError('updateEntry: entryId is required.');
    }
    final entryRef = _db
        .collection('customers')
        .doc(customer.id)
        .collection('ledger')
        .doc(entryId);
    print('[Ledger] updateEntry: writing ${entryRef.path}...');
    await entryRef.set({
      ...entryData,
      'debit': newDebit,
      'credit': newCredit,
    });
    print('[Ledger] updateEntry: entry write OK');

    final oldDelta = oldDebit - oldCredit;
    final newDelta = newDebit - newCredit;
    final adjust = newDelta - oldDelta;
    if (adjust != 0) {
      final newBalance = customer.balance + adjust;
      print('[Ledger] updateEntry: customer.balance ${customer.balance} → $newBalance');
      final updated = customer.copyWith(balance: newBalance);
      await _db.collection('customers').doc(customer.id).set(updated.toMap());
      print('[Ledger] updateEntry: customer balance updated OK');
    }
  }

  /// Deletes a ledger entry and reverses its impact on customer.balance.
  Future<void> deleteEntry({
    required Customer customer,
    required String entryId,
    required int oldDebit,
    required int oldCredit,
  }) async {
    if (entryId.isEmpty) {
      throw ArgumentError('deleteEntry: entryId is required.');
    }
    final entryRef = _db
        .collection('customers')
        .doc(customer.id)
        .collection('ledger')
        .doc(entryId);
    print('[Ledger] deleteEntry: deleting ${entryRef.path}...');
    await entryRef.delete();
    print('[Ledger] deleteEntry: entry delete OK');

    final oldDelta = oldDebit - oldCredit;
    if (oldDelta != 0) {
      final newBalance = customer.balance - oldDelta;
      print('[Ledger] deleteEntry: customer.balance ${customer.balance} → $newBalance');
      final updated = customer.copyWith(balance: newBalance);
      await _db.collection('customers').doc(customer.id).set(updated.toMap());
      print('[Ledger] deleteEntry: customer balance updated OK');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import 'firestore_rest.dart';

/// Customer master CRUD. Reads go through REST (Windows C++ Firestore SDK
/// crashes on `.get()` / `.snapshots()`); writes use the SDK with plain
/// `set()` / `delete()` only — never `WriteBatch` and never `FieldValue.increment`,
/// both of which crash the Windows platform channel codec.
class CustomerService {
  CustomerService({FirebaseFirestore? db, FirestoreRest? rest})
      : _db = db ?? FirebaseFirestore.instance,
        _rest = rest;

  final FirebaseFirestore _db;
  FirestoreRest? _rest;

  set rest(FirestoreRest r) => _rest = r;

  /// Self-bootstraps a `FirestoreRest` if main.dart's injection hasn't
  /// happened yet. Keeps the screen working across hot-reloads (which don't
  /// re-run main()) so newly-added globals don't dead-lock the UI.
  FirestoreRest get _restClient => _rest ??= FirestoreRest();

  // ── READS (REST — safe on Windows) ─────────────────────────────────────

  /// Fetches every customer doc via REST. CRITICAL: this is the ONLY way
  /// to read customers on Windows. Hits the in-memory REST cache by default;
  /// pass `forceRefresh: true` to bypass it (e.g. manual refresh button).
  Future<List<Customer>> fetchCustomersSafe({bool forceRefresh = false}) async {
    debugPrint('[Customer] fetchCustomersSafe: GET /customers via REST '
        '(forceRefresh=$forceRefresh)...');
    final docs = await _restClient.listDocs(
      'customers',
      forceRefresh: forceRefresh,
    );
    debugPrint('[Customer] fetchCustomersSafe: got ${docs.length} customer(s)');
    return docs.map((d) => Customer.fromMap(d.id, d.data)).toList();
  }

  // ── WRITES (SDK — plain set/delete, no batch, no increment) ────────────

  /// Adds a new customer. Auto-id, plain `set()`. Returns the new doc id.
  Future<String> addCustomer(Customer customer) async {
    final ref = _db.collection('customers').doc();
    debugPrint('[Customer] addCustomer: writing customers/${ref.id}...');
    await ref.set(customer.toMap());
    debugPrint('[Customer] addCustomer: write OK');
    _restClient.clearCache('customers');
    return ref.id;
  }

  /// Overwrites an existing customer doc (full replacement via plain `set()`).
  Future<void> updateCustomer(Customer customer) async {
    if (customer.id.isEmpty) {
      throw ArgumentError('updateCustomer: Customer.id is required.');
    }
    debugPrint('[Customer] updateCustomer: writing customers/${customer.id}...');
    await _db.collection('customers').doc(customer.id).set(customer.toMap());
    debugPrint('[Customer] updateCustomer: write OK');
    _restClient.clearCache('customers');
  }

  /// Deletes a customer doc. NOTE: ledger sub-collection docs are NOT
  /// auto-deleted — that's a Layer 2 concern (we'll handle it with the
  /// statement view).
  Future<void> deleteCustomer(String customerId) async {
    if (customerId.isEmpty) {
      throw ArgumentError('deleteCustomer: customerId is required.');
    }
    debugPrint('[Customer] deleteCustomer: deleting customers/$customerId...');
    await _db.collection('customers').doc(customerId).delete();
    debugPrint('[Customer] deleteCustomer: delete OK');
    _restClient.clearCache('customers');
    _restClient.clearCache('customers/$customerId/ledger');
  }

  // ── LAYER 2: LEDGER (Transactions) ─────────────────────────────────────

  /// Fetches ledger entries for a customer via REST to avoid Windows crash.
  Future<List<Map<String, dynamic>>> fetchLedgerSafe(
    String customerId, {
    bool forceRefresh = false,
  }) async {
    debugPrint('[Customer] fetchLedgerSafe: GET /customers/$customerId/ledger '
        '(forceRefresh=$forceRefresh)...');
    final docs = await _restClient.listDocs(
      'customers/$customerId/ledger',
      forceRefresh: forceRefresh,
    );
    // Sort by date manually as we aren't using a query here.
    docs.sort((a, b) {
      final da = DateTime.tryParse(a.data['date']?.toString() ?? '') ?? DateTime(2000);
      final db = DateTime.tryParse(b.data['date']?.toString() ?? '') ?? DateTime(2000);
      return db.compareTo(da); // descending
    });
    return docs.map((d) {
      final data = d.data;
      data['id'] = d.id;
      return data;
    }).toList();
  }

  /// Adds a transaction safely. Updates balance manually.
  Future<void> addLedgerEntrySafe(String customerId, Map<String, dynamic> entry, Customer currentCustomer) async {
    final entryRef = _db.collection('customers').doc(customerId).collection('ledger').doc();
    final data = Map<String, dynamic>.from(entry);
    data['id'] = entryRef.id;

    // Direct write to sub-collection
    await entryRef.set(data);
    _restClient.clearCache('customers/$customerId/ledger');

    // Calculate effect on balance.
    final debit = (data['debit'] as int?) ?? 0;
    final credit = (data['credit'] as int?) ?? 0;
    final int newBalance = currentCustomer.balance + debit - credit;

    // Apply back using updateCustomer (which itself invalidates the
    // customers cache).
    await updateCustomer(currentCustomer.copyWith(balance: newBalance));
  }

  /// Edits an existing transaction safely.
  Future<void> updateLedgerEntrySafe(String customerId, Map<String, dynamic> oldEntry, Map<String, dynamic> newEntry, Customer currentCustomer) async {
    final entryId = newEntry['id'] as String;
    final entryRef = _db.collection('customers').doc(customerId).collection('ledger').doc(entryId);

    await entryRef.set(newEntry);
    _restClient.clearCache('customers/$customerId/ledger');

    // Old impact vs new impact
    final oldDebit = (oldEntry['debit'] as int?) ?? 0;
    final oldCredit = (oldEntry['credit'] as int?) ?? 0;
    final oldDelta = oldDebit - oldCredit;

    final newDebit = (newEntry['debit'] as int?) ?? 0;
    final newCredit = (newEntry['credit'] as int?) ?? 0;
    final newDelta = newDebit - newCredit;

    // Remove old effect, add new effect
    final int newBalance = currentCustomer.balance - oldDelta + newDelta;
    await updateCustomer(currentCustomer.copyWith(balance: newBalance));
  }

  /// Deletes a transaction safely.
  Future<void> deleteLedgerEntrySafe(String customerId, Map<String, dynamic> entry, Customer currentCustomer) async {
    final entryId = entry['id'] as String;
    final entryRef = _db.collection('customers').doc(customerId).collection('ledger').doc(entryId);

    await entryRef.delete();
    _restClient.clearCache('customers/$customerId/ledger');

    // Reverse effect on balance.
    final debit = (entry['debit'] as int?) ?? 0;
    final credit = (entry['credit'] as int?) ?? 0;
    final int newBalance = currentCustomer.balance - debit + credit;

    await updateCustomer(currentCustomer.copyWith(balance: newBalance));
  }
}

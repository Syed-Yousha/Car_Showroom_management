import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/car.dart';
import '../models/customer.dart';
import '../models/document_record.dart';
import '../models/expense.dart';
import '../models/investor.dart';
import 'customer_service.dart';
import 'customers_repo.dart';
import 'documents_repo.dart';
import 'expenses_repo.dart';
import 'inventory_service.dart';
import 'investors_repo.dart';
import 'ledger_service.dart';

/// Sections offered in the CSV export dialog and used as keys in the JSON
/// backup blob.
enum BackupSection {
  inventory('Inventory'),
  customers('Customers'),
  expenses('Expenses'),
  ledger('Ledger'),
  investors('Investors'),
  documents('Documents');

  final String label;
  const BackupSection(this.label);
  String get filenameStem => name;
}

class BackupResult {
  final bool ok;
  final String message;
  final String? path;
  const BackupResult({required this.ok, required this.message, this.path});
}

/// Coordinates whole-system backup (JSON), per-section CSV export, and
/// factory reset. Every read routes through the REST-safe services/repos to
/// avoid the Windows C++ SDK read crashes; deletes go through the SDK
/// directly as plain single-doc operations (the Windows codec handles those
/// fine — only `.get()` / `.snapshots()` / `WriteBatch` crash it).
class BackupService {
  BackupService({
    required this.inventory,
    required this.customers,
    required this.customersRepo,
    required this.ledger,
    required this.expenses,
    required this.investors,
    required this.documents,
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  final InventoryService inventory;
  final CustomerService customers;
  final CustomersRepo customersRepo;
  final LedgerService ledger;
  final ExpensesRepo expenses;
  final InvestorsRepo investors;
  final DocumentsRepo documents;
  final FirebaseFirestore _db;

  // ── BACKUP (JSON) ──────────────────────────────────────────────────────

  Future<BackupResult> backupAllToJson({
    void Function(String step)? onProgress,
  }) async {
    try {
      onProgress?.call('Fetching cars…');
      final cars = await inventory.fetchCarsSafe();
      onProgress?.call('Fetching customers…');
      final clients = await customers.fetchCustomersSafe();
      onProgress?.call('Fetching ledger entries…');
      final ledgerByCustomer = <String, List<Map<String, dynamic>>>{};
      for (final c in clients) {
        ledgerByCustomer[c.id] = await ledger.fetchLedgerSafe(c.id);
      }
      onProgress?.call('Fetching expenses…');
      final expensesList = await expenses.listAll();
      onProgress?.call('Fetching investors…');
      final investorsList = await investors.listAll();
      onProgress?.call('Fetching documents…');
      final documentsList = await documents.listAll();

      onProgress?.call('Serialising…');
      final payload = <String, dynamic>{
        'meta': {
          'generatedAt': DateTime.now().toIso8601String(),
          'app': 'inam_motors_system',
          'version': 2,
        },
        'cars': cars.map(_carToBackupJson).toList(),
        'customers': clients.map(_customerToBackupJson).toList(),
        'ledger': ledgerByCustomer,
        'expenses': expensesList.map(_expenseToBackupJson).toList(),
        'investors': investorsList.map(_investorToBackupJson).toList(),
        'documents': documentsList.map(_documentToBackupJson).toList(),
      };

      final encoder = const JsonEncoder.withIndent('  ');
      final jsonStr = encoder.convert(payload);

      onProgress?.call('Writing file…');
      final dir = await getApplicationDocumentsDirectory();
      final stamp = _stamp();
      final file = File('${dir.path}${Platform.pathSeparator}'
          'inam_motors_backup_$stamp.json');
      await file.writeAsString(jsonStr, flush: true);

      return BackupResult(
        ok: true,
        message: 'Backup saved to ${file.path}',
        path: file.path,
      );
    } catch (e, s) {
      debugPrint('[Backup] failure: $e\n$s');
      return BackupResult(ok: false, message: 'Backup failed: $e');
    }
  }

  // ── EXPORT CSV ─────────────────────────────────────────────────────────

  Future<BackupResult> exportSectionToCsv(BackupSection section) async {
    try {
      final (headers, rows) = await _csvRows(section);
      final csv = _toCsv(headers, rows);
      final dir = await getApplicationDocumentsDirectory();
      final stamp = _stamp();
      final file = File('${dir.path}${Platform.pathSeparator}'
          'inam_motors_${section.filenameStem}_$stamp.csv');
      await file.writeAsString(csv, flush: true);
      return BackupResult(
        ok: true,
        message: '${section.label} exported to ${file.path}',
        path: file.path,
      );
    } catch (e, s) {
      debugPrint('[Export] ${section.name} failure: $e\n$s');
      return BackupResult(
          ok: false, message: 'Export ${section.label} failed: $e');
    }
  }

  Future<(List<String>, List<List<dynamic>>)> _csvRows(
      BackupSection section) async {
    switch (section) {
      case BackupSection.inventory:
        final cars = await inventory.fetchCarsSafe();
        return (
          ['id', 'name', 'make', 'model', 'year', 'color', 'price',
              'regNo', 'status', 'buyerId', 'buyerName', 'mileage',
              'fuel', 'transmission', 'chassisNo', 'engineNo',
              'investorId', 'investorName', 'createdAt', 'updatedAt'],
          cars
              .map((c) => <dynamic>[
                    c.id, c.name, c.make, c.model, c.year, c.color, c.price,
                    c.regNo, c.status, c.buyerId ?? '', c.buyerName ?? '',
                    c.mileage, c.fuel, c.transmission, c.chassisNo, c.engineNo,
                    c.investorId ?? '', c.investorName ?? '',
                    _iso(c.createdAt), _iso(c.updatedAt),
                  ])
              .toList(),
        );
      case BackupSection.customers:
        final clients = await customers.fetchCustomersSafe();
        return (
          ['id', 'name', 'phone', 'cnic', 'city', 'address', 'type',
              'balance', 'notes', 'createdAt', 'updatedAt'],
          clients
              .map((c) => <dynamic>[
                    c.id, c.name, c.phone, c.cnic, c.city, c.address, c.type,
                    c.balance, c.notes ?? '', _iso(c.createdAt),
                    _iso(c.updatedAt),
                  ])
              .toList(),
        );
      case BackupSection.expenses:
        final list = await expenses.listAll();
        return (
          ['id', 'title', 'category', 'amount', 'date', 'paidTo',
              'method', 'recurring', 'carId', 'createdAt', 'updatedAt'],
          list
              .map((e) => <dynamic>[
                    e.id, e.title, e.category, e.amount, _iso(e.date),
                    e.paidTo, e.method, e.recurring, e.carId ?? '',
                    _iso(e.createdAt), _iso(e.updatedAt),
                  ])
              .toList(),
        );
      case BackupSection.ledger:
        final clients = await customers.fetchCustomersSafe();
        final rows = <List<dynamic>>[];
        for (final c in clients) {
          final entries = await ledger.fetchLedgerSafe(c.id);
          for (final e in entries) {
            rows.add(<dynamic>[
              e['id'] ?? '',
              c.id,
              c.name,
              e['date'] ?? '',
              e['type'] ?? '',
              e['details'] ?? '',
              e['debit'] ?? 0,
              e['credit'] ?? 0,
              e['salesman'] ?? '',
              e['carId'] ?? '',
              e['carName'] ?? '',
              e['fullPayment'] ?? false,
              e['dueDate'] ?? '',
            ]);
          }
        }
        return (
          ['id', 'customerId', 'customerName', 'date', 'type', 'details',
              'debit', 'credit', 'salesman', 'carId', 'carName',
              'fullPayment', 'dueDate'],
          rows,
        );
      case BackupSection.investors:
        final list = await investors.listAll();
        return (
          ['id', 'name', 'role', 'invested', 'share', 'profit', 'phone',
              'joinDate', 'status', 'heldAmount', 'createdAt', 'updatedAt'],
          list
              .map((i) => <dynamic>[
                    i.id, i.name, i.role, i.invested, i.share, i.profit,
                    i.phone, _iso(i.joinDate), i.status, i.heldAmount,
                    _iso(i.createdAt), _iso(i.updatedAt),
                  ])
              .toList(),
        );
      case BackupSection.documents:
        final list = await documents.listAll();
        return (
          ['id', 'carId', 'carName', 'year', 'regNo', 'chassisNo', 'engineNo',
              'carStatus', 'buyer', 'buyerPhone', 'regName', 'carColor',
              'fileStatus', 'smartCardStatus', 'plateStatus', 'remoteKeyStatus'],
          list
              .map((d) => <dynamic>[
                    d.id, d.carId ?? '', d.carName, d.year, d.regNo,
                    d.chassisNo, d.engineNo, d.carStatus, d.buyer ?? '',
                    d.buyerPhone ?? '', d.regName ?? '', d.carColor ?? '',
                    d.file.status, d.smartCard.status, d.plate.status,
                    d.remoteKey.status,
                  ])
              .toList(),
        );
    }
  }

  // ── FACTORY RESET ─────────────────────────────────────────────────────

  /// Deletes every doc in every app collection. Each individual delete is
  /// wrapped so one stuck record can't abort the wipe. Reports progress so
  /// the UI can show live status.
  ///
  /// Notably this does NOT use `WriteBatch` (Windows codec crashes) and does
  /// not use `customersRepo.deleteWithLedger` (which `.get()`s the ledger
  /// sub-collection — also crashes on Windows). Instead it enumerates each
  /// customer's ledger via REST (`ledgerService.fetchLedgerSafe`) and deletes
  /// entries one-by-one with `_db.collection(...).doc(...).delete()`.
  Future<BackupResult> resetAllData({
    void Function(String step, int done, int total)? onProgress,
  }) async {
    try {
      // Phase 1: pre-fetch everything via REST so we have stable ID lists and
      // can drive an accurate progress total.
      onProgress?.call('Counting records…', 0, 0);
      final cars = await _safeFetch(() => inventory.fetchCarsSafe());
      final clients =
          await _safeFetch(() => customers.fetchCustomersSafe());
      final expensesList = await _safeFetch(() => expenses.listAll());
      final investorsList = await _safeFetch(() => investors.listAll());
      final documentsList = await _safeFetch(() => documents.listAll());

      // Also enumerate per-customer ledger ids so each entry can be deleted
      // individually (no batch, no .get() on the SDK).
      final ledgerByCustomer = <String, List<String>>{};
      for (final c in clients) {
        try {
          final entries = await ledger.fetchLedgerSafe(c.id);
          ledgerByCustomer[c.id] =
              entries.map((e) => (e['id'] ?? '').toString()).toList();
        } catch (e) {
          debugPrint('[Reset] ledger fetch failed for ${c.id}: $e');
          ledgerByCustomer[c.id] = const [];
        }
      }

      final total = cars.length +
          clients.length +
          expensesList.length +
          investorsList.length +
          documentsList.length +
          ledgerByCustomer.values.fold<int>(0, (s, l) => s + l.length);
      var done = 0;
      void tick(String label) {
        done++;
        onProgress?.call(label, done, total);
      }

      // Phase 2: per-collection deletes. Every per-doc delete is independently
      // try/catched so one failure can't break the wipe.

      // Ledger entries — must happen before customers so we don't orphan them.
      for (final entry in ledgerByCustomer.entries) {
        for (final entryId in entry.value) {
          if (entryId.isEmpty) {
            tick('Deleting ledger ($done/$total)');
            continue;
          }
          try {
            await _db
                .collection('customers')
                .doc(entry.key)
                .collection('ledger')
                .doc(entryId)
                .delete();
          } catch (e) {
            debugPrint('[Reset] ledger ${entry.key}/$entryId: $e');
          }
          tick('Deleting ledger ($done/$total)');
        }
      }

      // Customers
      for (final c in clients) {
        try {
          await _db.collection('customers').doc(c.id).delete();
        } catch (e) {
          debugPrint('[Reset] customer ${c.id}: $e');
        }
        tick('Deleting customers ($done/$total)');
      }

      // Cars
      for (final c in cars) {
        try {
          await _db.collection('cars').doc(c.id).delete();
        } catch (e) {
          debugPrint('[Reset] car ${c.id}: $e');
        }
        tick('Deleting cars ($done/$total)');
      }

      // Documents
      for (final d in documentsList) {
        try {
          await documents.delete(d.id);
        } catch (e) {
          debugPrint('[Reset] document ${d.id}: $e');
        }
        tick('Deleting documents ($done/$total)');
      }

      // Expenses
      for (final e in expensesList) {
        try {
          await expenses.delete(e.id);
        } catch (err) {
          debugPrint('[Reset] expense ${e.id}: $err');
        }
        tick('Deleting expenses ($done/$total)');
      }

      // Investors
      for (final i in investorsList) {
        try {
          await investors.delete(i.id);
        } catch (e) {
          debugPrint('[Reset] investor ${i.id}: $e');
        }
        tick('Deleting investors ($done/$total)');
      }

      return const BackupResult(
        ok: true,
        message: 'All data has been wiped.',
      );
    } catch (e, s) {
      debugPrint('[Reset] failure: $e\n$s');
      return BackupResult(ok: false, message: 'Reset failed: $e');
    }
  }

  /// Wrap a list fetch so a single failed collection doesn't take down the
  /// whole reset run. Returns an empty list on failure.
  static Future<List<T>> _safeFetch<T>(Future<List<T>> Function() f) async {
    try {
      return await f();
    } catch (e) {
      debugPrint('[Reset] pre-fetch failed: $e');
      return <T>[];
    }
  }

  // ── helpers ───────────────────────────────────────────────────────────

  static String _stamp() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}_'
        '${two(n.hour)}${two(n.minute)}${two(n.second)}';
  }

  static String _iso(DateTime? d) => d == null ? '' : d.toIso8601String();

  static String _toCsv(List<String> headers, List<List<dynamic>> rows) {
    final buf = StringBuffer();
    buf.writeln(headers.map(_csvField).join(','));
    for (final r in rows) {
      buf.writeln(r.map((v) => _csvField(v?.toString() ?? '')).join(','));
    }
    return buf.toString();
  }

  static String _csvField(String s) {
    final needsQuote =
        s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r');
    if (!needsQuote) return s;
    final escaped = s.replaceAll('"', '""');
    return '"$escaped"';
  }

  static Map<String, dynamic> _carToBackupJson(Car c) => {
        'id': c.id,
        'name': c.name,
        'make': c.make,
        'model': c.model,
        'year': c.year,
        'color': c.color,
        'price': c.price,
        if (c.demandPrice != null) 'demandPrice': c.demandPrice,
        'regNo': c.regNo,
        'status': c.status,
        'buyerId': c.buyerId,
        'buyerName': c.buyerName,
        'mileage': c.mileage,
        'fuel': c.fuel,
        'transmission': c.transmission,
        'chassisNo': c.chassisNo,
        'engineNo': c.engineNo,
        'investorId': c.investorId,
        'investorName': c.investorName,
        'fileHandedOver': c.fileHandedOver,
        'smartCardHandedOver': c.smartCardHandedOver,
        'numberPlateHandedOver': c.numberPlateHandedOver,
        'remoteKeyHandedOver': c.remoteKeyHandedOver,
        'photos': c.photos,
        'sellerName': c.sellerName,
        'sellerPhone': c.sellerPhone,
        'sellerCnic': c.sellerCnic,
        'notes': c.notes,
        'createdAt': _iso(c.createdAt),
        'updatedAt': _iso(c.updatedAt),
      };

  static Map<String, dynamic> _customerToBackupJson(Customer c) => {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'cnic': c.cnic,
        'city': c.city,
        'address': c.address,
        'type': c.type,
        'balance': c.balance,
        'notes': c.notes,
        'createdAt': _iso(c.createdAt),
        'updatedAt': _iso(c.updatedAt),
      };

  static Map<String, dynamic> _expenseToBackupJson(Expense e) => {
        'id': e.id,
        'title': e.title,
        'category': e.category,
        'amount': e.amount,
        'date': _iso(e.date),
        'paidTo': e.paidTo,
        'method': e.method,
        'recurring': e.recurring,
        'carId': e.carId,
        'createdAt': _iso(e.createdAt),
        'updatedAt': _iso(e.updatedAt),
      };

  static Map<String, dynamic> _investorToBackupJson(Investor i) => {
        'id': i.id,
        'name': i.name,
        'role': i.role,
        'invested': i.invested,
        'share': i.share,
        'profit': i.profit,
        'phone': i.phone,
        'joinDate': _iso(i.joinDate),
        'status': i.status,
        'heldAmount': i.heldAmount,
        'createdAt': _iso(i.createdAt),
        'updatedAt': _iso(i.updatedAt),
      };

  static Map<String, dynamic> _documentToBackupJson(DocumentRecord d) => {
        'id': d.id,
        'carId': d.carId,
        'carName': d.carName,
        'year': d.year,
        'regNo': d.regNo,
        'chassisNo': d.chassisNo,
        'engineNo': d.engineNo,
        'carStatus': d.carStatus,
        'buyer': d.buyer,
        'buyerPhone': d.buyerPhone,
        'regName': d.regName,
        'carColor': d.carColor,
        'extraNotes': d.extraNotes,
        'file': {'status': d.file.status},
        'smartCard': {'status': d.smartCard.status},
        'plate': {'status': d.plate.status},
        'remoteKey': {'status': d.remoteKey.status},
      };
}

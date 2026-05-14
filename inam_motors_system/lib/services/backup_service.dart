import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/car.dart';
import '../models/customer.dart';
import '../models/expense.dart';
import '../models/investor.dart';
import '../models/salesman.dart';
import 'customer_service.dart';
import 'customers_repo.dart';
import 'expenses_repo.dart';
import 'inventory_service.dart';
import 'investors_repo.dart';
import 'ledger_service.dart';
import 'salesmen_repo.dart';

/// Sections offered in the CSV export dialog and used as keys in the JSON
/// backup blob. The string is the user-facing label and the export filename
/// stem (lower-cased).
enum BackupSection {
  inventory('Inventory'),
  customers('Customers'),
  expenses('Expenses'),
  ledger('Ledger'),
  investors('Investors'),
  salesmen('Salesmen');

  final String label;
  const BackupSection(this.label);
  String get filenameStem => name; // lowercase enum name
}

/// Result returned by long-running operations so the UI can show a final
/// summary message without owning all the counting itself.
class BackupResult {
  final bool ok;
  final String message;
  final String? path;
  const BackupResult({required this.ok, required this.message, this.path});
}

/// Coordinates whole-system backup (JSON), per-section CSV export, and
/// factory reset. Every read routes through the REST-safe services/repos to
/// avoid the Windows C++ SDK read crashes; deletes use the SDK directly
/// (single-doc `set`/`delete` which the Windows codec handles fine).
class BackupService {
  BackupService({
    required this.inventory,
    required this.customers,
    required this.customersRepo,
    required this.ledger,
    required this.expenses,
    required this.investors,
    required this.salesmen,
  });

  final InventoryService inventory;
  final CustomerService customers;
  final CustomersRepo customersRepo;
  final LedgerService ledger;
  final ExpensesRepo expenses;
  final InvestorsRepo investors;
  final SalesmenRepo salesmen;

  // ── BACKUP (JSON) ──────────────────────────────────────────────────────

  /// Fetches every collection used by the app and serialises into a single
  /// pretty-printed JSON file under the user's Documents folder.
  ///
  /// Returns the absolute path of the file written.
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
      onProgress?.call('Fetching salesmen…');
      final salesmenList = await salesmen.listAllSafe();

      onProgress?.call('Serialising…');
      final payload = <String, dynamic>{
        'meta': {
          'generatedAt': DateTime.now().toIso8601String(),
          'app': 'inam_motors_system',
          'version': 1,
        },
        'cars': cars.map(_carToBackupJson).toList(),
        'customers': clients.map(_customerToBackupJson).toList(),
        'ledger': ledgerByCustomer.map(
          (cid, entries) => MapEntry(cid, entries),
        ),
        'expenses': expensesList.map(_expenseToBackupJson).toList(),
        'investors': investorsList.map(_investorToBackupJson).toList(),
        'salesmen': salesmenList.map(_salesmanToBackupJson).toList(),
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
      case BackupSection.salesmen:
        final list = await salesmen.listAllSafe();
        return (
          ['id', 'name', 'phone', 'role', 'share', 'joinDate', 'status',
              'totalSales', 'totalRevenue', 'totalProfit',
              'createdAt', 'updatedAt'],
          list
              .map((s) => <dynamic>[
                    s.id, s.name, s.phone, s.role, s.share,
                    _iso(s.joinDate), s.status, s.totalSales, s.totalRevenue,
                    s.totalProfit, _iso(s.createdAt), _iso(s.updatedAt),
                  ])
              .toList(),
        );
    }
  }

  // ── FACTORY RESET ─────────────────────────────────────────────────────

  /// Deletes every doc in every app collection via per-doc SDK deletes (the
  /// Windows codec doesn't tolerate WriteBatch). Reports progress so the UI
  /// can show a live status string.
  Future<BackupResult> resetAllData({
    void Function(String step, int done, int total)? onProgress,
  }) async {
    try {
      // Phase 1: count what we're about to delete (purely to drive a sensible
      // progress bar; the deletes themselves stream).
      final cars = await inventory.fetchCarsSafe();
      final clients = await customers.fetchCustomersSafe();
      final expensesList = await expenses.listAll();
      final investorsList = await investors.listAll();
      final salesmenList = await salesmen.listAllSafe();

      final total = cars.length +
          clients.length +
          expensesList.length +
          investorsList.length +
          salesmenList.length;
      var done = 0;

      void tick(String label) {
        done++;
        onProgress?.call(label, done, total);
      }

      // Phase 2: per-collection deletes. Each per-doc delete is wrapped in
      // its own try so one stuck record can't block the rest of the wipe.
      for (final c in cars) {
        try {
          await inventory.deleteCar(carId: c.id);
        } catch (_) {}
        tick('Deleting cars ($done/$total)');
      }
      for (final c in clients) {
        try {
          await customersRepo.deleteWithLedger(c.id);
        } catch (_) {
          try {
            await customers.deleteCustomer(c.id);
          } catch (_) {}
        }
        tick('Deleting customers ($done/$total)');
      }
      for (final e in expensesList) {
        try {
          await expenses.delete(e.id);
        } catch (_) {}
        tick('Deleting expenses ($done/$total)');
      }
      for (final i in investorsList) {
        try {
          await investors.delete(i.id);
        } catch (_) {}
        tick('Deleting investors ($done/$total)');
      }
      for (final s in salesmenList) {
        try {
          await salesmen.delete(s.id);
        } catch (_) {}
        tick('Deleting salesmen ($done/$total)');
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

  // ── helpers ───────────────────────────────────────────────────────────

  static String _stamp() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}_'
        '${two(n.hour)}${two(n.minute)}${two(n.second)}';
  }

  static String _iso(DateTime? d) => d == null ? '' : d.toIso8601String();

  /// RFC-4180-ish CSV builder: doubles up quotes inside fields, wraps any
  /// field containing comma/quote/newline in quotes, joins with `\r\n`.
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

  // Per-entity JSON shapers for the full backup. We strip serverTimestamp
  // sentinels (only meaningful inside `toMap` for writes) and emit ISO strings
  // for DateTimes.
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

  static Map<String, dynamic> _salesmanToBackupJson(Salesman s) => {
        'id': s.id,
        'name': s.name,
        'phone': s.phone,
        'role': s.role,
        'share': s.share,
        'joinDate': _iso(s.joinDate),
        'status': s.status,
        'totalSales': s.totalSales,
        'totalRevenue': s.totalRevenue,
        'totalProfit': s.totalProfit,
        'createdAt': _iso(s.createdAt),
        'updatedAt': _iso(s.updatedAt),
      };
}

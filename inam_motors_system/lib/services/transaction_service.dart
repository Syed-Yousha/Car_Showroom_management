import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import '../models/customer.dart';
import '../models/document_record.dart';
import '../models/ledger_entry.dart';
import '../models/salesman.dart';

class TransactionFailure implements Exception {
  TransactionFailure(this.message);
  final String message;
  @override
  String toString() => 'TransactionFailure: $message';
}

/// Coordinates multi-collection writes that must succeed or fail together.
///
/// All public methods are idempotent at the call-site (caller awaits a
/// single Future). `recordCarSale` uses `runTransaction` because it must
/// verify state (the car must not already be sold). The other operations
/// only do increments + creates and use a `WriteBatch`.
class TransactionService {
  TransactionService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ────────────────────────────────────────────────────────────────────────
  // CAR SALE
  // ────────────────────────────────────────────────────────────────────────
  /// Atomically:
  ///   1. Marks `cars/{carId}` as Sold (assigns buyerId / buyerName)
  ///   2. Creates a ledger entry under `customers/{customerId}/ledger/{auto}`
  ///   3. Increments customer balance by [salePrice]
  ///   4. Creates a document tracking record (status: all inOffice)
  ///   5. (Optional) Increments salesman aggregates + appends sale record
  ///
  /// Throws [TransactionFailure] if the car is already Sold or doesn't exist.
  /// Returns the new ledger entry ID.
  Future<String> recordCarSale({
    required String carId,
    required String customerId,
    required int salePrice,
    required DateTime date,
    required String details,
    String salesmanName = '',
    String? salesmanId,
    int? salesmanProfit,
    bool fullPayment = false,
    DateTime? dueDate,
  }) async {
    final carRef = _db.collection('cars').doc(carId);
    final customerRef = _db.collection('customers').doc(customerId);
    final ledgerRef = customerRef.collection('ledger').doc();
      
    // documents/{carId} is the canonical mapping — InventoryService creates
    // this record on addCar, so we always target it by carId here.
    final docRecordRef = _db.collection('documents').doc(carId);

    final salesmanRef =
        salesmanId == null ? null : _db.collection('salesmen').doc(salesmanId);
    final saleRef = salesmanRef?.collection('sales').doc();

    return _db.runTransaction<String>((tx) async {
      final carSnap = await tx.get(carRef);
      if (!carSnap.exists) {
        throw TransactionFailure('Car not found.');
      }
      final car = Car.fromSnapshot(carSnap);
      if (car.status == 'Sold') {
        throw TransactionFailure('This car is already sold.');
      }

      final customerSnap = await tx.get(customerRef);
      if (!customerSnap.exists) {
        throw TransactionFailure('Customer not found.');
      }
      final customer = Customer.fromSnapshot(customerSnap);

      // 1. Mark car as Sold + assign buyer
      tx.update(carRef, {
        'status': 'Sold',
        'buyerId': customerId,
        'buyerName': customer.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Create ledger entry
      final entry = LedgerEntry(
        id: ledgerRef.id,
        customerId: customerId,
        date: date,
        type: 'Car Sale',
        details: details,
        debit: salePrice,
        credit: 0,
        salesman: salesmanName,
        carId: carId,
        carName: car.name,
        fullPayment: fullPayment,
        dueDate: dueDate,
      );
      tx.set(ledgerRef, entry.toMap());

      // 3. Increment customer balance
      tx.update(customerRef, {
        'balance': FieldValue.increment(salePrice),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Create or merge the matching documents/{carId} record. Using
      // set+merge keeps any per-item handover state already on the doc
      // (file/smartCard/plate/remoteKey) intact while updating buyer info.
      final docRecord = DocumentRecord(
        id: carId,
        carId: carId,
        carName: car.name,
        year: car.year,
        regNo: car.regNo,
        chassisNo: car.chassisNo,
        engineNo: car.engineNo,
        carStatus: 'Sold',
        buyer: customer.name,
        buyerPhone: customer.phone,
        regName: car.name,
        carColor: car.color,
        file: const DocItemState(status: 'inOffice'),
        smartCard: const DocItemState(status: 'inOffice'),
        plate: const DocItemState(status: 'inOffice'),
        remoteKey: const DocItemState(status: 'inOffice'),
      );
      tx.set(docRecordRef, docRecord.toMap(), SetOptions(merge: true));

      // 5. Salesman aggregates + sale record (optional)
      if (salesmanRef != null && saleRef != null) {
        final profit = salesmanProfit ?? 0;
        tx.update(salesmanRef, {
          'totalSales': FieldValue.increment(1),
          'totalRevenue': FieldValue.increment(salePrice),
          'totalProfit': FieldValue.increment(profit),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        final sale = SalesmanSale(
          id: saleRef.id,
          carId: carId,
          carName: car.name,
          buyerId: customerId,
          buyerName: customer.name,
          salePrice: salePrice,
          profit: profit,
          date: date,
          type: fullPayment ? 'Cash' : 'Installment',
        );
        tx.set(saleRef, sale.toMap());
      }

      return ledgerRef.id;
    });
  }

  // ────────────────────────────────────────────────────────────────────────
  // PAYMENT (customer pays us — credit on their ledger, balance goes down)
  // ────────────────────────────────────────────────────────────────────────
  Future<String> recordPayment({
    required String customerId,
    required int amount,
    required DateTime date,
    String details = 'Payment received',
    String receivedBy = '',
    bool fullPayment = false,
    DateTime? remainingDueDate,
  }) async {
    final customerRef = _db.collection('customers').doc(customerId);
    final ledgerRef = customerRef.collection('ledger').doc();

    final entry = LedgerEntry(
      id: ledgerRef.id,
      customerId: customerId,
      date: date,
      type: 'Payment',
      details: details,
      debit: 0,
      credit: amount,
      salesman: receivedBy,
      paymentFullPayment: fullPayment,
      remainingDueDate: remainingDueDate,
    );

    final batch = _db.batch();
    batch.set(ledgerRef, entry.toMap());
    batch.update(customerRef, {
      'balance': FieldValue.increment(-amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return ledgerRef.id;
  }

  // ────────────────────────────────────────────────────────────────────────
  // CREDIT REFUND (we give back money — customer balance goes up to cancel
  // the credit they had, or further into debit if applicable)
  // ────────────────────────────────────────────────────────────────────────
  Future<String> recordCreditRefund({
    required String customerId,
    required int amount,
    required DateTime date,
    String details = 'Credit refunded',
    String givenBy = '',
  }) async {
    final customerRef = _db.collection('customers').doc(customerId);
    final ledgerRef = customerRef.collection('ledger').doc();

    final entry = LedgerEntry(
      id: ledgerRef.id,
      customerId: customerId,
      date: date,
      type: 'Credit Refund',
      details: details,
      debit: amount,
      credit: 0,
      salesman: givenBy,
    );

    final batch = _db.batch();
    batch.set(ledgerRef, entry.toMap());
    batch.update(customerRef, {
      'balance': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return ledgerRef.id;
  }

  // ────────────────────────────────────────────────────────────────────────
  // TRADE-IN (we accept a vehicle in exchange — adds car to inventory,
  // credits the customer's ledger by the trade-in value)
  // ────────────────────────────────────────────────────────────────────────
  Future<({String carId, String ledgerId})> recordTradeIn({
    required String customerId,
    required Car newCar, // id will be assigned by Firestore
    required int tradeInValue,
    required DateTime date,
    String details = 'Trade-In accepted',
    String boughtBy = '',
  }) async {
    final customerRef = _db.collection('customers').doc(customerId);
    final carRef = _db.collection('cars').doc();
    final ledgerRef = customerRef.collection('ledger').doc();

    // Force-set the car id and Available status on insert.
    final carData = newCar
        .copyWith(status: 'Available')
        .toMap();

    final entry = LedgerEntry(
      id: ledgerRef.id,
      customerId: customerId,
      date: date,
      type: 'Trade-In',
      details: details,
      debit: 0,
      credit: tradeInValue,
      salesman: boughtBy,
      carId: carRef.id,
      carName: newCar.name,
    );

    final batch = _db.batch();
    batch.set(carRef, carData);
    batch.set(ledgerRef, entry.toMap());
    batch.update(customerRef, {
      'balance': FieldValue.increment(-tradeInValue),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return (carId: carRef.id, ledgerId: ledgerRef.id);
  }
}

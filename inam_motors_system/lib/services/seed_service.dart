import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/car.dart';
import '../models/customer.dart';
import '../models/expense.dart';
import '../models/investor.dart';

/// One-shot helper that populates Firestore with realistic sample data.
///
/// Every write is sequential (one await per document) so the Windows C++ SDK
/// is never overwhelmed. Each step is print-traced so the debug console shows
/// exactly which call precedes a crash.
class SeedService {
  SeedService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Throttle delay between writes — prevents the Windows C++ Firebase SDK
  /// from being overwhelmed by rapid back-to-back gRPC calls.
  static const Duration _throttle = Duration(milliseconds: 80);

  /// Optional callback so the UI can show live progress.
  Future<SeedResult> seedAll({void Function(String step)? onProgress}) async {
    final result = SeedResult();

    void report(String msg) {
      debugPrint('[Seed] $msg');
      onProgress?.call(msg);
    }

    report('=== seedAll() started ===');

    // ── Pre-flight: ensure a fresh ID token is attached to the gRPC channel.
    // On Windows the Firebase C++ SDK can fire the first Firestore call
    // before the auth token has propagated, causing a hard native crash on
    // permission-denied. Forcing a refresh here makes that race impossible.
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('Not signed in — cannot seed Firestore.');
      }
      report('Pre-flight: refreshing auth token for ${user.email}...');
      final token = await user.getIdToken(true);
      report('Pre-flight: token refreshed (len=${token?.length ?? 0})');
      // Tiny pause to let the C++ Firestore client attach the new token to
      // its gRPC channel before any RPC fires.
      await Future.delayed(const Duration(milliseconds: 250));
    } catch (e, s) {
      report('Pre-flight FAILED: $e');
      debugPrint('[Seed] Pre-flight stack: $s');
      rethrow;
    }

    // ── Diagnostic: prove writes work before doing the bulk seed.
    // The first read on Windows kills the C++ SDK; first writes might too.
    // If this single test write crashes the app, we know writes are also
    // broken on this setup and need a different transport.
    report('Diagnostic: writing single test doc to "_seed_diag"...');
    try {
      await _db
          .collection('_seed_diag')
          .doc('init')
          .set({'at': DateTime.now().toIso8601String()});
      report('Diagnostic: write OK ✓');
    } catch (e, s) {
      report('Diagnostic: write FAILED: $e');
      debugPrint('[Seed] Diagnostic stack: $s');
      rethrow;
    }
    await Future.delayed(_throttle);

    // ── Bulk seed.
    // We deliberately do NOT read first to check if collections are empty —
    // reads currently crash the Windows C++ SDK on this build. Instead we
    // use fixed document IDs (e.g. `seed_inv_1`) and `set()`, so re-running
    // simply overwrites the same demo docs. This is idempotent and safe.
    report('Step 1/4: Seeding investors...');
    await _seedInvestors(result, report);
    report('Step 1/4: Investors done (${result.investors})');
    await Future.delayed(_throttle);

    report('Step 2/4: Seeding cars...');
    await _seedCars(result, report);
    report('Step 2/4: Cars done (${result.cars})');
    await Future.delayed(_throttle);

    report('Step 3/4: Seeding customers...');
    await _seedCustomers(result, report);
    report('Step 3/4: Customers done (${result.customers})');
    await Future.delayed(_throttle);

    report('Step 4/4: Seeding expenses...');
    await _seedExpenses(result, report);
    report('Step 4/4: Expenses done (${result.expenses})');

    report('=== seedAll() complete: ${result.describe()} ===');
    return result;
  }

  /// Wipes all known collections — destructive. Use with care.
  Future<void> clearAll() async {
    for (final path in const [
      'cars',
      'customers',
      'investors',
      'expenses',
      'documents',
    ]) {
      final q = await _db.collection(path).get();
      if (path == 'customers') {
        for (final d in q.docs) {
          final ledger = await d.reference.collection('ledger').get();
          for (final l in ledger.docs) {
            await l.reference.delete();
          }
        }
      }
      for (final d in q.docs) {
        await d.reference.delete();
      }
    }
  }

  // ── Private seeders (sequential, one await per doc) ──────────────────────

  Future<void> _seedInvestors(
      SeedResult result, void Function(String) report) async {
    final items = [
      Investor(
        id: '',
        name: 'Faheem Khan',
        role: 'Senior Partner',
        invested: 25000000,
        share: 40,
        profit: 1850000,
        phone: '0300-1112233',
        joinDate: DateTime(2023, 3, 12),
        status: 'Active',
      ),
      Investor(
        id: '',
        name: 'Tariq Aslam',
        role: 'Partner',
        invested: 15000000,
        share: 30,
        profit: 1100000,
        phone: '0301-4445566',
        joinDate: DateTime(2023, 6, 1),
        status: 'Active',
      ),
      Investor(
        id: '',
        name: 'Asif Mehmood',
        role: 'Partner',
        invested: 10000000,
        share: 20,
        profit: 720000,
        phone: '0302-7778899',
        joinDate: DateTime(2024, 1, 18),
        status: 'Active',
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final docId = 'seed_inv_${i + 1}';
      report('  Writing investor ${i + 1}/${items.length}: ${items[i].name} ($docId)');
      await _db.collection('investors').doc(docId).set(items[i].toMap());
      report('  Investor ${i + 1} written OK');
      await Future.delayed(_throttle);
    }
    result.investors = items.length;
  }

  Future<void> _seedCars(
      SeedResult result, void Function(String) report) async {
    final items = [
      Car(
        id: '',
        name: 'Toyota Grande 2024',
        make: 'Toyota',
        model: 'Grande',
        year: 2024,
        color: 'Pearl White',
        price: 8500000,
        regNo: 'LEA-7421',
        status: 'Available',
        mileage: '12,000 km',
        fuel: 'Petrol',
        transmission: 'Automatic',
        chassisNo: 'JTDBR32E-860045123',
        engineNo: '2ZR-FE-8924561',
      ),
      Car(
        id: '',
        name: 'Honda Civic 2023',
        make: 'Honda',
        model: 'Civic',
        year: 2023,
        color: 'Crystal Black',
        price: 7800000,
        regNo: 'LHR-5532',
        status: 'Available',
        mileage: '24,500 km',
        fuel: 'Petrol',
        transmission: 'Automatic',
        chassisNo: 'MRHGM66-560089745',
        engineNo: 'R18Z1-7756231',
      ),
      Car(
        id: '',
        name: 'Suzuki Cultus VXL 2024',
        make: 'Suzuki',
        model: 'Cultus',
        year: 2024,
        color: 'Solid White',
        price: 3800000,
        regNo: 'LEA-1105',
        status: 'Available',
        mileage: '8,200 km',
        fuel: 'Petrol',
        transmission: 'Manual',
        chassisNo: 'MBJHA36-240012345',
        engineNo: 'K10B-2401234',
      ),
      Car(
        id: '',
        name: 'Hyundai Tucson 2022',
        make: 'Hyundai',
        model: 'Tucson',
        year: 2022,
        color: 'Phantom Black',
        price: 11000000,
        regNo: 'LHR-8890',
        status: 'Available',
        mileage: '38,000 km',
        fuel: 'Petrol',
        transmission: 'Automatic',
        chassisNo: 'KMHJN81-220098765',
        engineNo: 'G4FP-2209871',
      ),
      Car(
        id: '',
        name: 'Changan Alsvin 2024',
        make: 'Changan',
        model: 'Alsvin',
        year: 2024,
        color: 'Star Blue',
        price: 6800000,
        regNo: 'MUL-2243',
        status: 'Available',
        mileage: '5,400 km',
        fuel: 'Petrol',
        transmission: 'Automatic',
        chassisNo: 'LSCGB54-240034567',
        engineNo: 'JL473Q5-2403456',
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final docId = 'seed_car_${i + 1}';
      report('  Writing car ${i + 1}/${items.length}: ${items[i].name} ($docId)');
      await _db.collection('cars').doc(docId).set(items[i].toMap());
      report('  Car ${i + 1} written OK');
      await Future.delayed(_throttle);
    }
    result.cars = items.length;
  }

  Future<void> _seedCustomers(
      SeedResult result, void Function(String) report) async {
    final items = [
      Customer(
        id: '',
        name: 'Ali Hassan',
        phone: '0312-1234567',
        cnic: '35202-1234567-1',
        city: 'Lahore',
        address: '123 Model Town, Lahore',
        type: 'VIP',
      ),
      Customer(
        id: '',
        name: 'Sarah Ahmed',
        phone: '0333-9876543',
        cnic: '35202-9876543-2',
        city: 'Karachi',
        address: 'Block 4, Clifton, Karachi',
        type: 'Regular',
      ),
      Customer(
        id: '',
        name: 'Ahmed Khan',
        phone: '0345-5566778',
        cnic: '35202-5566778-3',
        city: 'Lahore',
        address: 'DHA Phase 5, Lahore',
        type: 'VIP',
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final docId = 'seed_cust_${i + 1}';
      report('  Writing customer ${i + 1}/${items.length}: ${items[i].name} ($docId)');
      await _db.collection('customers').doc(docId).set(items[i].toMap());
      report('  Customer ${i + 1} written OK');
      await Future.delayed(_throttle);
    }
    result.customers = items.length;
  }

  Future<void> _seedExpenses(
      SeedResult result, void Function(String) report) async {
    final items = [
      Expense(
        id: '',
        title: 'Showroom Rent — Feb 2026',
        category: 'Rent',
        amount: 250000,
        date: DateTime(2026, 2, 1),
        paidTo: 'Landlord',
        method: 'Bank Transfer',
        recurring: true,
      ),
      Expense(
        id: '',
        title: 'Staff Salaries — Feb 2026',
        category: 'Salaries',
        amount: 380000,
        date: DateTime(2026, 2, 1),
        paidTo: 'Staff',
        method: 'Bank Transfer',
        recurring: true,
      ),
      Expense(
        id: '',
        title: 'Electricity Bill',
        category: 'Bills',
        amount: 22500,
        date: DateTime(2026, 2, 7),
        paidTo: 'LESCO',
        method: 'Online',
      ),
      Expense(
        id: '',
        title: 'Marketing — Facebook Ads',
        category: 'Marketing',
        amount: 35000,
        date: DateTime(2026, 2, 12),
        paidTo: 'Meta Pakistan',
        method: 'Online',
      ),
    ];

    for (var i = 0; i < items.length; i++) {
      final docId = 'seed_exp_${i + 1}';
      report('  Writing expense ${i + 1}/${items.length}: ${items[i].title} ($docId)');
      await _db.collection('expenses').doc(docId).set(items[i].toMap());
      report('  Expense ${i + 1} written OK');
      await Future.delayed(_throttle);
    }
    result.expenses = items.length;
  }
}

class SeedResult {
  int cars = 0;
  int customers = 0;
  int investors = 0;
  int expenses = 0;

  bool get any => cars + customers + investors + expenses > 0;

  String describe() {
    if (!any) return 'Database already populated — nothing seeded.';
    final parts = <String>[];
    if (cars > 0) parts.add('$cars cars');
    if (customers > 0) parts.add('$customers customers');
    if (investors > 0) parts.add('$investors investors');
    if (expenses > 0) parts.add('$expenses expenses');
    return 'Seeded ${parts.join(', ')}.';
  }
}

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

// Run this command in terminal to generate the missing .g.dart file:
// flutter pub run build_runner build
part 'database.g.dart'; 

// ==========================================
// 1. INVENTORY MODULE (Car Details)
// ==========================================
class Cars extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Car Details
  TextColumn get make => text()(); // e.g., Toyota
  TextColumn get model => text()(); // e.g., Corolla
  TextColumn get year => text()(); // e.g., 2024
  TextColumn get color => text()();
  TextColumn get registrationNumber => text().nullable()(); // ABC-123
  
  // Unique IDs (Critical for Showrooms)
  TextColumn get chassisNumber => text().unique()(); // VIN
  TextColumn get engineNumber => text()();
  
  // Status: 'Available', 'Sold', 'Booked'
  TextColumn get status => text().withDefault(const Constant('Available'))();
  
  // Purchasing Costs (How much the showroom spent)
  RealColumn get purchasePrice => real()();
  RealColumn get repairCost => real().withDefault(const Constant(0.0))();
  
  // Documentation Tracking (From client requirement: "File/Plate receipt")
  BoolColumn get isFileInHand => boolean().withDefault(const Constant(true))();
  BoolColumn get isNumberPlateInHand => boolean().withDefault(const Constant(true))();
  
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDate)();
}

// ==========================================
// 2. CRM MODULE (Customer Details)
// ==========================================
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();
  TextColumn get phone => text()();
  TextColumn get cnic => text().nullable()();
  TextColumn get address => text().nullable()();
}

// ==========================================
// 3. SALES MODULE (Invoices & Transactions)
// ==========================================
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Relational Links
  IntColumn get carId => integer().references(Cars, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  
  // Financials
  RealColumn get salePrice => real()(); // Amount sold for
  RealColumn get discountGiven => real().withDefault(const Constant(0.0))();
  
  // Date of Sale
  DateTimeColumn get saleDate => dateTime().withDefault(currentDate)();
  
  // Notes (e.g., "Sold on open transfer")
  TextColumn get remarks => text().nullable()();
}

// "Customer cash details" - Tracks installments/payments
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  IntColumn get saleId => integer().references(Sales, #id)();
  
  RealColumn get amountPaid => real()(); // e.g. 50,000 Token
  DateTimeColumn get paymentDate => dateTime().withDefault(currentDate)();
  
  // Type: 'Token', 'Down Payment', 'Final Settlement'
  TextColumn get paymentType => text()(); 
}

// ==========================================
// 4. INVESTOR MODULE (The Complex Logic)
// ==========================================
class Investors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  
  // Total balance currently with the showroom
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
}

// Which investor owns which car?
class CarInvestments extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  IntColumn get carId => integer().references(Cars, #id)();
  IntColumn get investorId => integer().references(Investors, #id)();
  
  // How much this investor put into THIS car
  RealColumn get investmentAmount => real()(); 
  
  // Their share of the profit (Calculated after sale)
  RealColumn get profitShare => real().nullable()(); 
}

// ==========================================
// 5. EXPENSE MODULE (Showroom Running Costs)
// ==========================================
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get title => text()(); // "Tea", "Electricity Bill"
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime().withDefault(currentDate)();
  
  // Category: 'Operational', 'Salary', 'Maintenance'
  TextColumn get category => text()(); 
}

// ==========================================
// DATABASE INITIALIZATION
// ==========================================
@DriftDatabase(tables: [Cars, Customers, Sales, Payments, Investors, CarInvestments, Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Put the database file in the Documents folder so it persists
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'inam_motors_v1.sqlite'));
    return NativeDatabase(file);
  });
}
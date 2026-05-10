import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../main.dart';
import '../../models/car.dart';
import '../../models/customer.dart';
import '../shared/widgets.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => CustomersScreenState();
}

class CustomersScreenState extends State<CustomersScreen> {
  void showAddDialog() => _showAddCustomerDialog();

  Future<List<String>> _pickAndSaveImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null) {
        final docsDir = await getApplicationDocumentsDirectory();
        final savedPaths = <String>[];
        for (final file in result.files) {
          if (file.path != null) {
            final newFile = await File(file.path!).copy(
              '${docsDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
            );
            savedPaths.add(newFile.path);
          }
        }
        return savedPaths;
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
    return [];
  }

  String _searchQuery = '';
  String _selectedFilter = 'All';
  Map<String, dynamic>? _selectedCustomer;

  // ───── Available cars for selling — populated live from Firestore via REST
  // every time the Add Transaction dialog opens (so newly-added inventory
  // and just-sold cars reflect immediately on the next open).
  List<Map<String, dynamic>> _availableCars = const [];

  /// Re-fetch all cars via REST and keep only the ones that are still
  /// Available (i.e. excluded Sold / Booked). Returns the list so callers
  /// can also chain off it.
  Future<List<Map<String, dynamic>>> _loadAvailableCars() async {
    // ignore: avoid_print
    print('[AddTxn] Loading available cars via REST...');
    final cars = await inventoryService.fetchCarsSafe();
    final available = cars
        .where((c) => c.status == 'Available')
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'price': c.price,
              'regNo': c.regNo,
            })
        .toList();
    // ignore: avoid_print
    print('[AddTxn] Available cars after filter: ${available.length}');
    _availableCars = available;
    return available;
  }

  // â”€â”€â”€â”€â”€ Customer data â”€â”€â”€â”€â”€
  /// Live list of customers — loaded from Firestore via REST
  /// (`CustomerService.fetchCustomersSafe`). Existing rendering code
  /// reads `Map<String, dynamic>`, so we adapt typed `Customer` objects
  /// into that shape via `_customerToDisplayMap`.
  List<Map<String, dynamic>> _customers = [];
  bool _loadingCustomers = true;
  String? _customersLoadError;

  /// Ledger state for the currently-selected customer (Layer 2). Loaded
  /// via REST when the user opens a customer; reflected in a banner at
  /// the top of the detail view.
  bool _loadingLedger = false;
  String? _ledgerLoadError;

  @override
  void initState() {
    super.initState();
    _refreshCustomers();
  }

  /// Open a customer's detail view and kick off a fresh ledger fetch.
  /// All Layer-1 tap handlers route through this single entry point so
  /// we never end up showing stale or empty ledger data.
  void _selectCustomer(Map<String, dynamic> c) {
    setState(() => _selectedCustomer = c);
    final id = (c['id'] ?? '').toString();
    if (id.isNotEmpty) _refreshLedgerFor(id);
  }

  /// Load the ledger sub-collection for [customerId] via REST and inject
  /// it into the matching customer's display map so the existing detail
  /// view renders without further changes.
  Future<void> _refreshLedgerFor(String customerId) async {
    if (customerId.isEmpty) return;
    if (mounted) {
      setState(() {
        _loadingLedger = true;
        _ledgerLoadError = null;
      });
    }
    try {
      final ledger = await ledgerService.fetchLedgerSafe(customerId);
      if (!mounted) return;
      // Sort by server-side `createdAt` ASCENDING — i.e. real insertion
      // order, oldest first. This matches how a bank-style statement reads
      // top-to-bottom and lets the running balance accumulate correctly.
      // Falls back to `date` string if createdAt is missing.
      ledger.sort((a, b) {
        final ca = (a['createdAt'] ?? '').toString();
        final cb = (b['createdAt'] ?? '').toString();
        if (ca.isNotEmpty && cb.isNotEmpty) return ca.compareTo(cb);
        if (ca.isNotEmpty) return -1; // a has timestamp, b doesn't → a first
        if (cb.isNotEmpty) return 1;  // b has timestamp, a doesn't → b first
        // Both missing — fall back to date string ascending.
        final da = (a['date'] ?? '').toString();
        final db = (b['date'] ?? '').toString();
        return da.compareTo(db);
      });
      // Mutate the customer Map in place so existing `customer['ledger']`
      // reads (scattered through detail-view code) get the live data.
      for (final c in _customers) {
        if ((c['id'] ?? '') == customerId) {
          c['ledger'] = ledger;
        }
      }
      if (_selectedCustomer != null &&
          (_selectedCustomer!['id'] ?? '') == customerId) {
        _selectedCustomer!['ledger'] = ledger;
      }
      setState(() => _loadingLedger = false);
    } catch (e, s) {
      // ignore: avoid_print
      print('[Ledger] fetchLedgerSafe failed: $e');
      // ignore: avoid_print
      print('[Ledger] Stack: $s');
      if (!mounted) return;
      setState(() {
        _ledgerLoadError = e.toString();
        _loadingLedger = false;
      });
    }
  }

  /// Fetch customers via REST and rebuild. Call on initState, on the
  /// Refresh button, and after every successful Add/Edit/Delete.
  Future<void> _refreshCustomers() async {
    if (mounted) {
      setState(() {
        _loadingCustomers = true;
        _customersLoadError = null;
      });
    }
    try {
      final customers = await customerService.fetchCustomersSafe();
      if (!mounted) return;
      setState(() {
        _customers = customers.map(_customerToDisplayMap).toList();
        _loadingCustomers = false;
      });
    } catch (e, s) {
      debugPrint('[Customers] fetchCustomersSafe failed: $e');
      debugPrint('[Customers] Stack: $s');
      if (!mounted) return;
      setState(() {
        _customersLoadError = e.toString();
        _loadingCustomers = false;
      });
    }
  }

  /// Adapt a typed `Customer` into the `Map<String, dynamic>` shape
  /// the existing rendering code consumes. The `ledger` sub-collection
  /// is left empty here — Layer 2 will populate it lazily when the user
  /// opens a customer's statement.
  Map<String, dynamic> _customerToDisplayMap(Customer c) => {
        'id': c.id,
        'name': c.name,
        'phone': c.phone,
        'cnic': c.cnic,
        'city': c.city,
        'address': c.address,
        'type': c.type,
        'balance': c.balance,
        'notes': c.notes ?? '',
        'ledger': <Map<String, dynamic>>[],
      };

  // ───── Computed helpers ─────
  int _getBalance(Map<String, dynamic> c) {
    return c['balance'] as int? ?? 0;
  }

  int _getTotalDebit(Map<String, dynamic> c) {
    final ledger = (c['ledger'] as List<dynamic>?) ?? [];
    return ledger.fold(0, (s, e) => s + ((e as Map)['debit'] as int? ?? 0));
  }

  int _getTotalCredit(Map<String, dynamic> c) {
    final ledger = (c['ledger'] as List<dynamic>?) ?? [];
    return ledger.fold(0, (s, e) => s + ((e as Map)['credit'] as int? ?? 0));
  }

  int _getCarCount(Map<String, dynamic> c) {
    final ledger = (c['ledger'] as List<dynamic>?) ?? [];
    return ledger.where((e) => (e as Map)['type'] == 'Car Sale').length;
  }

  List<Map<String, dynamic>> get _filtered {
    return _customers.where((c) {
      if (_selectedFilter != 'All' && c['type'] != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return c['name'].toString().toLowerCase().contains(q) ||
            c['phone'].toString().contains(q) ||
            c['cnic'].toString().contains(q) ||
            c['address'].toString().toLowerCase().contains(q) ||
            c['city'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  int get _vipCount => _customers.where((c) => c['type'] == 'VIP').length;
  int get _regularCount =>
      _customers.where((c) => c['type'] == 'Regular').length;
  int get _newCount => _customers.where((c) => c['type'] == 'New').length;
  int get _leadCount => _customers.where((c) => c['type'] == 'Lead').length;
  int get _withBalanceCount =>
      _customers.where((c) => _getBalance(c) > 0).length;

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  DIALOGS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  void _showAddTransactionDialog(Map<String, dynamic> customer) {
    String txnType = 'Sell Car';
    bool isManualEntry = false;
    Map<String, dynamic>? selectedCar;
    int selectedCarPrice = 0;

    // Shared amount + payment method fields (used by Payment & Credit Refund)
    final amountCtrl = TextEditingController();
    String paymentType = 'Cash';
    final bankNameCtrl = TextEditingController();
    final accNoCtrl = TextEditingController();

    // Sell Car
    final manualCarNameCtrl = TextEditingController();

    // Payment â€” full payment + clearance due date
    bool paymentFullPayment = false;
    DateTime? paymentDueDate;

    // Trade-In â€” full car detail controllers
    final tradeCarNameCtrl = TextEditingController();
    final tradeMakeCtrl = TextEditingController();
    final tradeModelCtrl = TextEditingController();
    final tradeRegNoCtrl = TextEditingController();
    final tradeColorCtrl = TextEditingController();
    final tradeMileageCtrl = TextEditingController();
    final tradeChassisCtrl = TextEditingController();
    final tradeEngineCtrl = TextEditingController();
    final tradeAmountCtrl = TextEditingController();
    String tradeFuelType = 'Petrol';
    String tradeTransmission = 'Automatic';
    List<String> tradeImagePaths = [];

    // Additional notes (shared â€” one type active at a time)
    final notesCtrl = TextEditingController();

    // Salesman â€” manual text entry (global to dialog)
    final salesmanCtrl = TextEditingController();

    DateTime txnDate = DateTime.now();
    bool fileHandedOver = false;
    bool smartCardHandedOver = false;
    bool plateHandedOver = false;
    bool remoteKeyHandedOver = false;

    // Available-cars loader state — fetched fresh from inventory on dialog
    // open via REST so we never show stale or already-sold cars.
    bool inventoryLoading = true;
    String? inventoryLoadError;
    bool inventoryLoadKicked = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (!inventoryLoadKicked) {
            inventoryLoadKicked = true;
            Future(() async {
              try {
                await _loadAvailableCars();
              } catch (e, s) {
                // ignore: avoid_print
                print('[AddTxn] Failed to load inventory: $e');
                // ignore: avoid_print
                print('[AddTxn] Stack: $s');
                inventoryLoadError = e.toString();
              } finally {
                inventoryLoading = false;
                if (ctx.mounted) setDialogState(() {});
              }
            });
          }
          // â”€â”€ Chip builders â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Widget txnTypeChip(String label) {
            final sel = txnType == label;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setDialogState(() => txnType = label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textPrimary)),
                ),
              ),
            );
          }

          Widget paymentChip(String label) {
            final sel = paymentType == label;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setDialogState(() => paymentType = label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textPrimary)),
                ),
              ),
            );
          }

          // Generic option chip for fuel/transmission selectors
          Widget optionChip(String label, String current, void Function(String) onSelect) {
            final sel = current == label;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setDialogState(() => onSelect(label)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textPrimary)),
                ),
              ),
            );
          }

          Widget sectionLabel(String text) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(text, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          );

          // Shared bank detail fields (Payment & Credit Refund)
          List<Widget> bankFields() => [
            const SizedBox(height: 14),
            _editField("Bank Name", bankNameCtrl),
            _editField("Account / Cheque No.", accNoCtrl),
          ];

          return ContentDialog(
            title: const Text(
              'Add Transaction',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
            ),
            constraints: const BoxConstraints(maxWidth: 620),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // â”€â”€ Transaction type selector â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Text('Transaction Type', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    txnTypeChip('Sell Car'),
                    txnTypeChip('Payment'),
                    txnTypeChip('Trade-In'),
                    txnTypeChip('Credit Refund'),
                  ]),
                  const SizedBox(height: 20),

                  // â”€â”€ SELL CAR â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  if (txnType == 'Sell Car') ...[
                    Row(children: [
                      Expanded(
                        child: FilledButton(
                          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(!isManualEntry ? AppTheme.primary : AppTheme.cardColor)),
                          onPressed: () => setDialogState(() => isManualEntry = false),
                          child: Text('Select from Inventory', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: !isManualEntry ? Colors.white : AppTheme.textPrimary)),
                        ).withClickCursor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(isManualEntry ? AppTheme.primary : AppTheme.cardColor)),
                          onPressed: () => setDialogState(() => isManualEntry = true),
                          child: Text('Manual Entry', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: isManualEntry ? Colors.white : AppTheme.textPrimary)),
                        ).withClickCursor,
                      ),
                    ]),
                    const SizedBox(height: 12),
                    if (!isManualEntry)
                      InfoLabel(
                        label: 'Select Car',
                        labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        child: inventoryLoading
                            ? Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.centerLeft,
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  const SizedBox(width: 12, height: 12, child: ProgressRing(strokeWidth: 2)),
                                  const SizedBox(width: 8),
                                  Text("Loading inventory…", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                                ]),
                              )
                            : inventoryLoadError != null
                                ? Text("Failed to load inventory: $inventoryLoadError",
                                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error))
                                : _availableCars.isEmpty
                                    ? Text("No available cars in inventory. Switch to Manual Entry.",
                                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted))
                                    : AutoSuggestBox<Map<String, dynamic>>(
                                        items: _availableCars.map((c) => AutoSuggestBoxItem<Map<String, dynamic>>(
                                          value: c,
                                          label: '${c['name']} - ${formatFullPrice(c['price'])}',
                                        )).toList(),
                                        onSelected: (item) => setDialogState(() {
                                          selectedCar = item.value;
                                          selectedCarPrice = item.value?['price'] ?? 0;
                                          amountCtrl.text = selectedCarPrice.toString();
                                        }),
                                      ),
                      )
                    else
                      _editField("Manual Car Name / Details", manualCarNameCtrl),
                    const SizedBox(height: 12),
                    _editField("Final Sale Price (Rs)", amountCtrl),
                    const SizedBox(height: 14),
                    sectionLabel("Documentation Handover"),
                    _buildDocStatusGrid(
                      fileHandedOver, smartCardHandedOver, plateHandedOver, remoteKeyHandedOver,
                      (f, s, p, r) => setDialogState(() { fileHandedOver = f; smartCardHandedOver = s; plateHandedOver = p; remoteKeyHandedOver = r; }),
                    ),
                    _editFieldMultiline("Additional Notes (optional)", notesCtrl),
                  ],

                  // â”€â”€ PAYMENT â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  if (txnType == 'Payment') ...[
                    _editField("Payment Amount (Rs)", amountCtrl),
                    const SizedBox(height: 4),
                    Checkbox(
                      checked: paymentFullPayment,
                      onChanged: (v) => setDialogState(() {
                        paymentFullPayment = v ?? false;
                        if (paymentFullPayment) paymentDueDate = null;
                      }),
                      content: Text(
                        "Full Payment",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!paymentFullPayment) ...[
                      Text(
                        "Remaining Payment Due Date",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DatePicker(
                        selected: paymentDueDate ?? DateTime.now(),
                        onChanged: (d) =>
                            setDialogState(() => paymentDueDate = d),
                      ),
                      const SizedBox(height: 14),
                    ],
                    sectionLabel("Payment Method"),
                    Row(children: [
                      paymentChip('Cash'),
                      const SizedBox(width: 8),
                      paymentChip('Bank Transfer'),
                      const SizedBox(width: 8),
                      paymentChip('Cheque'),
                    ]),
                    if (paymentType != 'Cash') ...bankFields(),
                    const SizedBox(height: 14),
                    _editFieldMultiline("Additional Notes (optional)", notesCtrl),
                  ],

                  // â”€â”€ TRADE-IN â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  if (txnType == 'Trade-In') ...[
                    _editField("Car Name", tradeCarNameCtrl),
                    Row(children: [
                      Expanded(child: _editField("Make", tradeMakeCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _editField("Model", tradeModelCtrl)),
                    ]),
                    Row(children: [
                      Expanded(child: _editField("Reg. No.", tradeRegNoCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _editField("Color", tradeColorCtrl)),
                    ]),
                    Row(children: [
                      Expanded(child: _editField("Mileage (e.g., 45,000 km)", tradeMileageCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _editField("Trade-In Value (Rs)", tradeAmountCtrl)),
                    ]),
                    Row(children: [
                      Expanded(child: _editField("Chassis No.", tradeChassisCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _editField("Engine No.", tradeEngineCtrl)),
                    ]),
                    sectionLabel("Fuel Type"),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      optionChip('Petrol',  tradeFuelType, (v) => tradeFuelType = v),
                      optionChip('Diesel',  tradeFuelType, (v) => tradeFuelType = v),
                      optionChip('Hybrid',  tradeFuelType, (v) => tradeFuelType = v),
                      optionChip('EV',      tradeFuelType, (v) => tradeFuelType = v),
                    ]),
                    const SizedBox(height: 14),
                    sectionLabel("Transmission"),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      optionChip('Automatic', tradeTransmission, (v) => tradeTransmission = v),
                      optionChip('Manual',    tradeTransmission, (v) => tradeTransmission = v),
                    ]),
                    const SizedBox(height: 14),
                    // â”€â”€ Car Photos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Car Photos",
                                  style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary)),
                              FilledButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(AppTheme.primary)),
                                onPressed: () async {
                                  final newPaths = await _pickAndSaveImages();
                                  if (newPaths.isNotEmpty) {
                                    setDialogState(
                                        () => tradeImagePaths.addAll(newPaths));
                                  }
                                },
                                child: const Text("Upload Photos",
                                    style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 12,
                                        color: Colors.white)),
                              ).withClickCursor,
                            ],
                          ),
                          if (tradeImagePaths.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: tradeImagePaths.asMap().entries.map((entry) {
                                final path = entry.value;
                                final fileName =
                                    path.split(RegExp(r'[\\/]')).last;
                                return Container(
                                  width: 100,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.divider),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.file(
                                              File(path),
                                              width: 90,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) =>
                                                  Container(
                                                width: 90,
                                                height: 70,
                                                color: AppTheme.background,
                                                child: const Center(
                                                    child: Icon(
                                                        FluentIcons.error,
                                                        size: 16,
                                                        color: AppTheme.error)),
                                              ),
                                            ),
                                          ),
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => setDialogState(() =>
                                                  tradeImagePaths
                                                      .removeAt(entry.key)),
                                              child: Container(
                                                margin: const EdgeInsets.all(4),
                                                padding:
                                                    const EdgeInsets.all(3),
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle),
                                                child: Icon(FluentIcons.cancel,
                                                    size: 10,
                                                    color: AppTheme.error),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(fileName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: AppTheme.fontFamily,
                                              fontSize: 10,
                                              color: AppTheme.textPrimary)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.divider),
                              ),
                              child: Column(
                                children: [
                                  Icon(FluentIcons.photo_collection,
                                      size: 28, color: AppTheme.textMuted),
                                  const SizedBox(height: 8),
                                  Text("No photos uploaded yet",
                                      style: TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 12,
                                          color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    sectionLabel("Documentation Received"),
                    _buildDocStatusGrid(
                      fileHandedOver, smartCardHandedOver, plateHandedOver, remoteKeyHandedOver,
                      (f, s, p, r) => setDialogState(() { fileHandedOver = f; smartCardHandedOver = s; plateHandedOver = p; remoteKeyHandedOver = r; }),
                    ),
                    _editFieldMultiline("Additional Notes (optional)", notesCtrl),
                  ],

                  // â”€â”€ CREDIT REFUND â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  if (txnType == 'Credit Refund') ...[
                    _editField("Refund Amount (Rs)", amountCtrl),
                    sectionLabel("Refund Method"),
                    Row(children: [
                      paymentChip('Cash'),
                      const SizedBox(width: 8),
                      paymentChip('Bank Transfer'),
                      const SizedBox(width: 8),
                      paymentChip('Cheque'),
                    ]),
                    if (paymentType != 'Cash') ...bankFields(),
                    const SizedBox(height: 14),
                    _editFieldMultiline("Additional Notes (optional)", notesCtrl),
                  ],

                  // â”€â”€ SALESMAN + DATE (global footer) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: _editField(
                      txnType == 'Payment'
                          ? "Received by"
                          : txnType == 'Credit Refund'
                              ? "Given by"
                              : "Salesman Name",
                      salesmanCtrl,
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Transaction Date", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                        const SizedBox(height: 6),
                        DatePicker(selected: txnDate, onChanged: (d) => setDialogState(() => txnDate = d)),
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(fontFamily: AppTheme.fontFamily)),
              ).withClickCursor,
              FilledButton(
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
                onPressed: () async {
                  final dateStr = '${txnDate.year}-${txnDate.month.toString().padLeft(2, '0')}-${txnDate.day.toString().padLeft(2, '0')}';
                  final salesman = salesmanCtrl.text.trim();
                  final customerId = (customer['id'] ?? '').toString();
                  if (customerId.isEmpty) return;

                  // Build the entry data + debit/credit amounts.
                  Map<String, dynamic>? entryData;
                  int debit = 0;
                  int credit = 0;

                  if (txnType == 'Sell Car') {
                    final amt = int.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                    String detail = '';
                    if (isManualEntry) {
                      detail = manualCarNameCtrl.text.trim();
                      if (detail.isEmpty || amt <= 0) return;
                    } else {
                      if (selectedCar == null) return;
                      detail = selectedCar!['name'] as String;
                      if (amt <= 0) return;
                    }
                    debit = amt;
                    entryData = {
                      'date': dateStr,
                      'type': 'Car Sale',
                      'details': detail,
                      'salesman': salesman,
                      'file': fileHandedOver,
                      'smartCard': smartCardHandedOver,
                      'plate': plateHandedOver,
                      'notes': notesCtrl.text.trim(),
                      'remoteKey': remoteKeyHandedOver,
                    };
                  } else if (txnType == 'Payment') {
                    final amt = int.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                    if (amt <= 0) return;
                    final remainingDueStr = (paymentFullPayment || paymentDueDate == null)
                        ? ''
                        : '${paymentDueDate!.year}-${paymentDueDate!.month.toString().padLeft(2, '0')}-${paymentDueDate!.day.toString().padLeft(2, '0')}';
                    String detail = paymentType;
                    if (paymentType != 'Cash') {
                      final parts = <String>[];
                      if (bankNameCtrl.text.trim().isNotEmpty) parts.add(bankNameCtrl.text.trim());
                      if (accNoCtrl.text.trim().isNotEmpty) parts.add(accNoCtrl.text.trim());
                      detail = parts.isNotEmpty ? '$paymentType - ${parts.join(' / ')}' : paymentType;
                    }
                    credit = amt;
                    entryData = {
                      'date': dateStr,
                      'type': 'Payment',
                      'details': detail,
                      'salesman': salesman,
                      'fullPayment': paymentFullPayment,
                      'remainingDueDate': remainingDueStr,
                      'notes': notesCtrl.text.trim(),
                    };
                  } else if (txnType == 'Trade-In') {
                    final amt = int.tryParse(tradeAmountCtrl.text.replaceAll(',', '')) ?? 0;
                    final carName = tradeCarNameCtrl.text.trim();
                    final make = tradeMakeCtrl.text.trim();
                    final model = tradeModelCtrl.text.trim();
                    if (amt <= 0 || make.isEmpty) return;
                    final detail = carName.isNotEmpty ? carName : (model.isNotEmpty ? '$make $model' : make);
                    credit = amt;
                    entryData = {
                      'date': dateStr,
                      'type': 'Trade-In',
                      'details': detail,
                      'salesman': salesman,
                      'tradeCarName': carName,
                      'tradeCarMake': make,
                      'tradeCarModel': model,
                      'tradeCarRegNo': tradeRegNoCtrl.text.trim(),
                      'tradeCarColor': tradeColorCtrl.text.trim(),
                      'tradeCarMileage': tradeMileageCtrl.text.trim(),
                      'tradeCarChassis': tradeChassisCtrl.text.trim(),
                      'tradeCarEngine': tradeEngineCtrl.text.trim(),
                      'tradeCarFuel': tradeFuelType,
                      'tradeCarTransmission': tradeTransmission,
                      'tradeCarPhotos': List<String>.from(tradeImagePaths),
                      'file': fileHandedOver,
                      'smartCard': smartCardHandedOver,
                      'plate': plateHandedOver,
                      'remoteKey': remoteKeyHandedOver,
                      'notes': notesCtrl.text.trim(),
                    };
                  } else if (txnType == 'Credit Refund') {
                    final amt = int.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                    if (amt <= 0) return;
                    String detail = 'Credit Refund - $paymentType';
                    if (paymentType != 'Cash') {
                      final parts = <String>[];
                      if (bankNameCtrl.text.trim().isNotEmpty) parts.add(bankNameCtrl.text.trim());
                      if (accNoCtrl.text.trim().isNotEmpty) parts.add(accNoCtrl.text.trim());
                      if (parts.isNotEmpty) detail = 'Credit Refund - $paymentType / ${parts.join(' / ')}';
                    }
                    debit = amt;
                    entryData = {
                      'date': dateStr,
                      'type': 'Credit Refund',
                      'details': detail,
                      'salesman': salesman,
                      'notes': notesCtrl.text.trim(),
                    };
                  }

                  if (entryData == null) return;

                  // Persist via LedgerService. We rebuild the Customer
                  // object from the live display map so the service can
                  // adjust customer.balance with the correct starting value.
                  final customerObj = Customer(
                    id: customerId,
                    name: (customer['name'] ?? '').toString(),
                    phone: (customer['phone'] ?? '').toString(),
                    cnic: (customer['cnic'] ?? '').toString(),
                    city: (customer['city'] ?? '').toString(),
                    address: (customer['address'] ?? '').toString(),
                    type: (customer['type'] ?? 'Regular').toString(),
                    balance: (customer['balance'] as int?) ?? 0,
                    notes: customer['notes'] as String?,
                  );
                  try {
                    // ignore: avoid_print
                    print('[AddTxn] type=$txnType debit=$debit credit=$credit customerId=$customerId');
                    final id = await ledgerService.addEntry(
                      customer: customerObj,
                      entryData: entryData,
                      debit: debit,
                      credit: credit,
                    );
                    // ignore: avoid_print
                    print('[AddTxn] entry written id=$id');
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    // Update local customer.balance + reload ledger.
                    customer['balance'] = customerObj.balance + (debit - credit);
                    // ── Inventory side-effects ─────────────────────────
                    // Sell Car (with a real inventory pick) → mark Sold.
                    if (txnType == 'Sell Car' &&
                        !isManualEntry &&
                        selectedCar != null) {
                      final soldCarId = (selectedCar!['id'] ?? '').toString();
                      if (soldCarId.isNotEmpty) {
                        try {
                          await inventoryService.markCarSold(
                            soldCarId,
                            buyerId: customerId,
                            buyerName: customerObj.name,
                            buyerPhone: customerObj.phone,
                          );
                        } catch (e, s) {
                          // ignore: avoid_print
                          print('[AddTxn] markCarSold failed (ledger entry already saved): $e');
                          // ignore: avoid_print
                          print('[AddTxn] Stack: $s');
                        }
                        // Mirror this dialog's handover checkboxes onto the
                        // matching documents/{carId} record so the Docs &
                        // Files screen reflects what was handed to the buyer.
                        final today = DateTime.now();
                        final todayStr = '${today.year}-'
                            '${today.month.toString().padLeft(2, '0')}-'
                            '${today.day.toString().padLeft(2, '0')}';
                        Map<String, dynamic> docState(bool given) => given
                            ? {
                                'status': 'handedOver',
                                'to': customerObj.name,
                                'phone': customerObj.phone,
                                'date': todayStr,
                              }
                            : {
                                'status': 'inOffice',
                                'to': null,
                                'phone': null,
                                'date': null,
                              };
                        try {
                          await documentService.savePartial(soldCarId, {
                            'carStatus': 'Sold',
                            'buyer': customerObj.name,
                            'buyerPhone': customerObj.phone,
                            if (fileHandedOver)
                              'file': docState(true),
                            if (smartCardHandedOver)
                              'smartCard': docState(true),
                            if (plateHandedOver)
                              'plate': docState(true),
                            if (remoteKeyHandedOver)
                              'remoteKey': docState(true),
                          });
                        } catch (e, s) {
                          // ignore: avoid_print
                          print('[AddTxn] docs handover sync failed: $e\n$s');
                        }
                      }
                    }
                    // Trade-In → add the customer's car as new Available
                    // inventory so it shows up on the Inventory screen.
                    if (txnType == 'Trade-In') {
                      try {
                        final tradeCar = Car(
                          id: '', // auto-id
                          name: tradeCarNameCtrl.text.trim().isNotEmpty
                              ? tradeCarNameCtrl.text.trim()
                              : '${tradeMakeCtrl.text.trim()} ${tradeModelCtrl.text.trim()}'.trim(),
                          make: tradeMakeCtrl.text.trim(),
                          model: tradeModelCtrl.text.trim(),
                          year: DateTime.now().year,
                          color: tradeColorCtrl.text.trim(),
                          price: int.tryParse(tradeAmountCtrl.text.replaceAll(',', '')) ?? 0,
                          regNo: tradeRegNoCtrl.text.trim(),
                          status: 'Available',
                          mileage: tradeMileageCtrl.text.trim(),
                          fuel: tradeFuelType,
                          transmission: tradeTransmission,
                          chassisNo: tradeChassisCtrl.text.trim(),
                          engineNo: tradeEngineCtrl.text.trim(),
                          photos: List<String>.from(tradeImagePaths),
                          sellerName: customerObj.name,
                          sellerPhone: customerObj.phone,
                          sellerCnic: customerObj.cnic,
                          notes: 'Acquired via Trade-In from ${customerObj.name}',
                        );
                        await inventoryService.addCar(tradeCar);
                      } catch (e, s) {
                        // ignore: avoid_print
                        print('[AddTxn] addCar (trade-in) failed (ledger entry already saved): $e');
                        // ignore: avoid_print
                        print('[AddTxn] Stack: $s');
                      }
                    }
                    displayInfoBar(context, builder: (c, close) => InfoBar(
                      title: Text('$txnType added.', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                      severity: InfoBarSeverity.success,
                      onClose: close,
                    ));
                    _refreshLedgerFor(customerId);
                  } catch (e, s) {
                    // ignore: avoid_print
                    print('[AddTxn] FAILED: $e');
                    // ignore: avoid_print
                    print('[AddTxn] Stack: $s');
                    if (!mounted) return;
                    displayInfoBar(context, builder: (c, close) => InfoBar(
                      title: Text('Failed to add transaction: $e', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                      severity: InfoBarSeverity.error,
                      onClose: close,
                    ));
                  }
                },
                child: const Text('Add Transaction', style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
              ).withClickCursor,
            ],
          );
        },
      ),
    );
  }

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cnicCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedType = 'New';
    bool savingAdd = false;
    String? addError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ContentDialog(
          title: const Text(
            "Add Customer",
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          constraints: const BoxConstraints(maxWidth: 480),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField("Full Name", nameCtrl),
                Row(
                  children: [
                    Expanded(child: _editField("Phone", phoneCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _editField("CNIC", cnicCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _editField("City", cityCtrl)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: InfoLabel(
                          label: "Type",
                          labelStyle: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                          child: ComboBox<String>(
                            value: selectedType,
                            isExpanded: true,
                            items: ['VIP', 'Regular', 'New', 'Lead']
                                .map(
                                  (s) => ComboBoxItem<String>(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => selectedType = v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _editField("Address", addressCtrl),
                _editFieldMultiline("Additional Notes (optional)", notesCtrl),
              ],
            ),
          ),
          actions: [
            if (addError != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  addError!,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error),
                ),
              ),
            Button(
              onPressed: savingAdd ? null : () => Navigator.pop(ctx),
              child: const Text(
                "Cancel",
                style: TextStyle(fontFamily: AppTheme.fontFamily),
              ),
            ).withClickCursor,
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.primary),
              ),
              onPressed: savingAdd
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        setDialogState(() => addError = 'Customer name is required.');
                        return;
                      }
                      setDialogState(() {
                        savingAdd = true;
                        addError = null;
                      });
                      final newCustomer = Customer(
                        id: '', // Firestore generates
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        cnic: cnicCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        type: selectedType,
                        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                      );
                      try {
                        debugPrint('[AddCustomer] Calling customerService.addCustomer() — name=${newCustomer.name}');
                        final id = await customerService.addCustomer(newCustomer);
                        debugPrint('[AddCustomer] Customer saved with id=$id');
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        displayInfoBar(context, builder: (c, close) => InfoBar(
                          title: Text('Customer "${newCustomer.name}" added.', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                          severity: InfoBarSeverity.success,
                          onClose: close,
                        ));
                        _refreshCustomers();
                      } catch (e, s) {
                        debugPrint('[AddCustomer] FAILED: $e');
                        debugPrint('[AddCustomer] Stack: $s');
                        if (!ctx.mounted) return;
                        setDialogState(() {
                          savingAdd = false;
                          addError = 'Save failed: $e';
                        });
                      }
                    },
              child: savingAdd
                  ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
                  : const Text(
                      "Add Customer",
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white,
                      ),
                    ),
            ).withClickCursor,
          ],
        ),
      ),
    );
  }

  void _showEditCustomerDialog(Map<String, dynamic> c) {
    final customerId = (c['id'] ?? '').toString();
    if (customerId.isEmpty) return;

    final nameCtrl = TextEditingController(text: c['name']);
    final phoneCtrl = TextEditingController(text: c['phone']);
    final cnicCtrl = TextEditingController(text: c['cnic']);
    final cityCtrl = TextEditingController(text: c['city']);
    final addressCtrl = TextEditingController(text: c['address'] ?? '');
    final customerNotesCtrl = TextEditingController(text: c['notes'] as String? ?? '');
    String selectedType = c['type'];
    bool savingEdit = false;
    String? editError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ContentDialog(
          title: const Text(
            "Edit Customer",
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
          constraints: const BoxConstraints(maxWidth: 480),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _editField("Full Name", nameCtrl),
                Row(
                  children: [
                    Expanded(child: _editField("Phone", phoneCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _editField("CNIC", cnicCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _editField("City", cityCtrl)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: InfoLabel(
                          label: "Type",
                          labelStyle: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                          child: ComboBox<String>(
                            value: selectedType,
                            isExpanded: true,
                            items: ['VIP', 'Regular', 'New', 'Lead']
                                .map(
                                  (s) => ComboBoxItem<String>(
                                    value: s,
                                    child: Text(
                                      s,
                                      style: const TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => selectedType = v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _editField("Address", addressCtrl),
                _editFieldMultiline("Additional Notes (optional)", customerNotesCtrl),
              ],
            ),
          ),
          actions: [
            if (editError != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  editError!,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error),
                ),
              ),
            Button(
              onPressed: savingEdit ? null : () => Navigator.pop(ctx),
              child: const Text(
                "Cancel",
                style: TextStyle(fontFamily: AppTheme.fontFamily),
              ),
            ).withClickCursor,
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.primary),
              ),
              onPressed: savingEdit
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        setDialogState(() => editError = 'Customer name is required.');
                        return;
                      }
                      setDialogState(() {
                        savingEdit = true;
                        editError = null;
                      });
                      final updated = Customer(
                        id: customerId,
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        cnic: cnicCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        type: selectedType,
                        balance: (c['balance'] as int?) ?? 0,
                        notes: customerNotesCtrl.text.trim().isEmpty ? null : customerNotesCtrl.text.trim(),
                      );
                      try {
                        debugPrint('[EditCustomer] Calling customerService.updateCustomer() — id=$customerId');
                        await customerService.updateCustomer(updated);
                        debugPrint('[EditCustomer] updateCustomer OK');
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        displayInfoBar(context, builder: (c, close) => InfoBar(
                          title: Text('Customer "${updated.name}" updated.', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                          severity: InfoBarSeverity.success,
                          onClose: close,
                        ));
                        _refreshCustomers();
                      } catch (e, s) {
                        debugPrint('[EditCustomer] FAILED: $e');
                        debugPrint('[EditCustomer] Stack: $s');
                        if (!ctx.mounted) return;
                        setDialogState(() {
                          savingEdit = false;
                          editError = 'Update failed: $e';
                        });
                      }
                    },
              child: savingEdit
                  ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
                  : const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white,
                      ),
                    ),
            ).withClickCursor,
          ],
        ),
      ),
    );
  }

  void _showRemoveCustomerDialog(Map<String, dynamic> c) {
    final customerId = (c['id'] ?? '').toString();
    if (customerId.isEmpty) return;
    bool deleting = false;
    String? deleteError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: const Text(
          "Remove Customer",
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Are you sure you want to remove ${c['name']}? All ledger data will be lost. This action cannot be undone.",
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (deleteError != null) ...[
            const SizedBox(height: 8),
            Text(deleteError!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.error)),
          ],
        ]),
        actions: [
          Button(
            onPressed: deleting ? null : () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(fontFamily: AppTheme.fontFamily),
            ),
          ).withClickCursor,
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(AppTheme.error),
            ),
            onPressed: deleting
                ? null
                : () async {
                    setDialogState(() {
                      deleting = true;
                      deleteError = null;
                    });
                    try {
                      debugPrint('[RemoveCustomer] Calling customerService.deleteCustomer() — id=$customerId');
                      await customerService.deleteCustomer(customerId);
                      debugPrint('[RemoveCustomer] Delete OK');
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      // Clear detail view if the removed customer was selected.
                      if (_selectedCustomer != null &&
                          (_selectedCustomer!['id'] ?? '') == customerId) {
                        setState(() => _selectedCustomer = null);
                      }
                      displayInfoBar(context, builder: (c2, close) => InfoBar(
                        title: Text('Customer "${c['name']}" removed.', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                        severity: InfoBarSeverity.success,
                        onClose: close,
                      ));
                      _refreshCustomers();
                    } catch (e, s) {
                      debugPrint('[RemoveCustomer] FAILED: $e');
                      debugPrint('[RemoveCustomer] Stack: $s');
                      if (!ctx.mounted) return;
                      setDialogState(() {
                        deleting = false;
                        deleteError = 'Remove failed: $e';
                      });
                    }
                  },
            child: deleting
                ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                : const Text(
                    "Remove",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.white,
                    ),
                  ),
          ).withClickCursor,
        ],
      )),
    );
  }

  // â”€â”€â”€â”€â”€ Add Transaction Dialog â”€â”€â”€â”€â”€

  // â”€â”€â”€â”€â”€ Edit Transaction Dialog â”€â”€â”€â”€â”€
  void _showCustomerNoteDialog(Map<String, dynamic> customer) {
    final note = (customer['notes'] as String? ?? '').trim();
    if (note.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.quick_note, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              "Customer Note",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 460),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: SelectableText(
            note,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        actions: [
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(AppTheme.primary),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Close",
              style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white),
            ),
          ).withClickCursor,
        ],
      ),
    );
  }

  void _showNoteDialog(Map<String, dynamic> entry) {
    final note = (entry['notes'] as String? ?? '').trim();
    if (note.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.quick_note, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              "Transaction Note",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 460),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: SelectableText(
            note,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        actions: [
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(AppTheme.primary),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Close",
              style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white),
            ),
          ).withClickCursor,
        ],
      ),
    );
  }

  void _showEditTransactionDialog(
    Map<String, dynamic> customer,
    int entryIndex,
  ) {
    final ledger = customer['ledger'] as List<Map<String, dynamic>>;
    final entry = ledger[entryIndex];
    final originalType = entry['type'] as String;

    final amountCtrl = TextEditingController(
      text: originalType == 'Payment' || originalType == 'Trade-In'
          ? (entry['credit'] as int).toString()
          : (entry['debit'] as int).toString(),
    );
    final detailsCtrl = TextEditingController(text: entry['details'] ?? '');
    final notesCtrl = TextEditingController(text: entry['notes'] as String? ?? '');
    DateTime txnDate = DateTime.tryParse(entry['date'] ?? '') ?? DateTime.now();
    final salesmanCtrl =
        TextEditingController(text: (entry['salesman'] as String? ?? ''));
    bool fileHandedOver = entry['file'] == true;
    bool smartCardHandedOver = entry['smartCard'] == true;
    bool plateHandedOver = entry['plate'] == true;
    bool remoteKeyHandedOver = entry['remoteKey'] == true;

    // Payment â€” Full Payment + Due Date
    bool editPaymentFullPayment = entry['fullPayment'] == true;
    DateTime? editPaymentDueDate =
        DateTime.tryParse(entry['remainingDueDate'] as String? ?? '');

    // Payment-specific
    String paymentType = 'Cash';
    final accNoCtrl = TextEditingController();
    final bankNameCtrl = TextEditingController();
    if (originalType == 'Payment') {
      final d = entry['details'] as String? ?? '';
      if (d.startsWith('Bank Transfer')) {
        paymentType = 'Bank Transfer';
        final parts = d.split(' - ');
        if (parts.length > 1) accNoCtrl.text = parts.sublist(1).join(' - ');
      } else if (d.startsWith('Cheque')) {
        paymentType = 'Cheque';
        final parts = d.split(' - ');
        if (parts.length > 1) accNoCtrl.text = parts.sublist(1).join(' - ');
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return ContentDialog(
            title: const Text(
              "Edit Transaction",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            constraints: const BoxConstraints(maxWidth: 560),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show type as read-only badge
                  Row(
                    children: [
                      Text(
                        "Type: ",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _txnColor(originalType).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _txnIcon(originalType),
                              size: 14,
                              color: _txnColor(originalType),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              originalType,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _txnColor(originalType),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (originalType == 'Car Sale') ...[
                    _editField("Car Details", detailsCtrl),
                    _editField("Sale Price (Rs)", amountCtrl),
                    const SizedBox(height: 14),
                    Text(
                      "Documentation & Handover",
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDocStatusGrid(
                      fileHandedOver,
                      smartCardHandedOver,
                      plateHandedOver,
                      remoteKeyHandedOver,
                      (f, s, p, r) {
                        setDialogState(() {
                          fileHandedOver = f;
                          smartCardHandedOver = s;
                          plateHandedOver = p;
                          remoteKeyHandedOver = r;
                        });
                      },
                    ),
                  ],

                  if (originalType == 'Payment') ...[
                    _editField("Amount (Rs)", amountCtrl),
                    const SizedBox(height: 4),
                    Checkbox(
                      checked: editPaymentFullPayment,
                      onChanged: (v) => setDialogState(() {
                        editPaymentFullPayment = v ?? false;
                        if (editPaymentFullPayment) editPaymentDueDate = null;
                      }),
                      content: Text(
                        "Full Payment",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (!editPaymentFullPayment) ...[
                      Text(
                        "Remaining Payment Due Date",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DatePicker(
                        selected: editPaymentDueDate ?? DateTime.now(),
                        onChanged: (d) =>
                            setDialogState(() => editPaymentDueDate = d),
                      ),
                      const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      "Payment Method",
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _paymentChip(
                          'Cash',
                          paymentType,
                          (v) => setDialogState(() => paymentType = v),
                        ),
                        const SizedBox(width: 8),
                        _paymentChip(
                          'Bank Transfer',
                          paymentType,
                          (v) => setDialogState(() => paymentType = v),
                        ),
                        const SizedBox(width: 8),
                        _paymentChip(
                          'Cheque',
                          paymentType,
                          (v) => setDialogState(() => paymentType = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (paymentType != 'Cash') ...[
                      _editField("Bank Name", bankNameCtrl),
                      _editField("Account / Cheque No.", accNoCtrl),
                    ],
                  ],

                  if (originalType == 'Credit Refund') ...[
                    _editField("Refund Amount (Rs)", amountCtrl),
                  ],

                  if (originalType == 'Trade-In') ...[
                    _editField("Car Name", detailsCtrl),
                    _editField("Trade-In Value (Rs)", amountCtrl),
                    const SizedBox(height: 4),
                    Text(
                      "Documentation Received",
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDocStatusGrid(
                      fileHandedOver,
                      smartCardHandedOver,
                      plateHandedOver,
                      remoteKeyHandedOver,
                      (f, s, p, r) {
                        setDialogState(() {
                          fileHandedOver = f;
                          smartCardHandedOver = s;
                          plateHandedOver = p;
                          remoteKeyHandedOver = r;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 14),
                  Text(
                    originalType == 'Payment'
                        ? "Received by"
                        : originalType == 'Credit Refund'
                            ? "Given by"
                            : "Salesman",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextBox(
                    controller: salesmanCtrl,
                    placeholder: originalType == 'Payment'
                        ? "Enter receiver name"
                        : originalType == 'Credit Refund'
                            ? "Enter giver name"
                            : "Enter salesman name",
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Transaction Date",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DatePicker(
                    selected: txnDate,
                    onChanged: (d) => setDialogState(() => txnDate = d),
                  ),
                  const SizedBox(height: 14),
                  _editFieldMultiline("Additional Notes (optional)", notesCtrl),
                ],
              ),
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontFamily: AppTheme.fontFamily),
                ),
              ).withClickCursor,
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                ),
                onPressed: () async {
                  final dateStr =
                      '${txnDate.year}-${txnDate.month.toString().padLeft(2, '0')}-${txnDate.day.toString().padLeft(2, '0')}';
                  final amt = int.tryParse(amountCtrl.text) ?? 0;
                  if (amt <= 0) return;
                  final notes = notesCtrl.text.trim();
                  final salesman = salesmanCtrl.text.trim();
                  final entryId = (entry['id'] ?? '').toString();
                  final customerId = (customer['id'] ?? '').toString();
                  if (entryId.isEmpty || customerId.isEmpty) return;

                  // Old debit/credit for the customer.balance delta math.
                  final oldDebit = (entry['debit'] as int?) ?? 0;
                  final oldCredit = (entry['credit'] as int?) ?? 0;

                  // Build the new entry data + new debit/credit per type.
                  Map<String, dynamic> newEntryData;
                  int newDebit = 0;
                  int newCredit = 0;

                  if (originalType == 'Car Sale') {
                    newDebit = amt;
                    newEntryData = {
                      'date': dateStr,
                      'type': 'Car Sale',
                      'details': detailsCtrl.text.trim(),
                      'salesman': salesman,
                      'file': fileHandedOver,
                      'smartCard': smartCardHandedOver,
                      'plate': plateHandedOver,
                      'notes': notes,
                      if (entry['remoteKey'] != null) 'remoteKey': entry['remoteKey'],
                    };
                  } else if (originalType == 'Payment') {
                    String detail = paymentType;
                    if (paymentType != 'Cash') {
                      final parts = <String>[];
                      if (bankNameCtrl.text.trim().isNotEmpty) parts.add(bankNameCtrl.text.trim());
                      if (accNoCtrl.text.trim().isNotEmpty) parts.add(accNoCtrl.text.trim());
                      detail = parts.isNotEmpty ? '$paymentType - ${parts.join(' / ')}' : paymentType;
                    }
                    final remDueStr = (editPaymentFullPayment || editPaymentDueDate == null)
                        ? ''
                        : '${editPaymentDueDate!.year}-${editPaymentDueDate!.month.toString().padLeft(2, '0')}-${editPaymentDueDate!.day.toString().padLeft(2, '0')}';
                    newCredit = amt;
                    newEntryData = {
                      'date': dateStr,
                      'type': 'Payment',
                      'details': detail,
                      'salesman': salesman,
                      'fullPayment': editPaymentFullPayment,
                      'remainingDueDate': remDueStr,
                      'notes': notes,
                    };
                  } else if (originalType == 'Trade-In') {
                    newCredit = amt;
                    newEntryData = {
                      'date': dateStr,
                      'type': 'Trade-In',
                      'details': detailsCtrl.text.trim(),
                      'salesman': salesman,
                      'file': fileHandedOver,
                      'smartCard': smartCardHandedOver,
                      'plate': plateHandedOver,
                      'notes': notes,
                      if (entry['tradeCarName'] != null) 'tradeCarName': entry['tradeCarName'],
                      if (entry['tradeCarPhotos'] != null) 'tradeCarPhotos': entry['tradeCarPhotos'],
                    };
                  } else if (originalType == 'Credit Refund') {
                    newDebit = amt;
                    newEntryData = {
                      'date': dateStr,
                      'type': 'Credit Refund',
                      'details': 'Credit Refund - Paid back to customer',
                      'salesman': salesman,
                      'notes': notes,
                    };
                  } else {
                    return;
                  }

                  final customerObj = Customer(
                    id: customerId,
                    name: (customer['name'] ?? '').toString(),
                    phone: (customer['phone'] ?? '').toString(),
                    cnic: (customer['cnic'] ?? '').toString(),
                    city: (customer['city'] ?? '').toString(),
                    address: (customer['address'] ?? '').toString(),
                    type: (customer['type'] ?? 'Regular').toString(),
                    balance: (customer['balance'] as int?) ?? 0,
                    notes: customer['notes'] as String?,
                  );
                  try {
                    // ignore: avoid_print
                    print('[EditTxn] entryId=$entryId oldDebit=$oldDebit oldCredit=$oldCredit newDebit=$newDebit newCredit=$newCredit');
                    await ledgerService.updateEntry(
                      customer: customerObj,
                      entryId: entryId,
                      entryData: newEntryData,
                      oldDebit: oldDebit,
                      oldCredit: oldCredit,
                      newDebit: newDebit,
                      newCredit: newCredit,
                    );
                    // ignore: avoid_print
                    print('[EditTxn] updateEntry OK');
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    customer['balance'] = customerObj.balance + ((newDebit - newCredit) - (oldDebit - oldCredit));
                    displayInfoBar(context, builder: (c, close) => InfoBar(
                      title: Text('Transaction updated.', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                      severity: InfoBarSeverity.success,
                      onClose: close,
                    ));
                    _refreshLedgerFor(customerId);
                  } catch (e, s) {
                    // ignore: avoid_print
                    print('[EditTxn] FAILED: $e');
                    // ignore: avoid_print
                    print('[EditTxn] Stack: $s');
                    if (!mounted) return;
                    displayInfoBar(context, builder: (c, close) => InfoBar(
                      title: Text('Failed to update transaction: $e', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                      severity: InfoBarSeverity.error,
                      onClose: close,
                    ));
                  }
                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                  ),
                ),
              ).withClickCursor,
            ],
          );
        },
      ),
    );
  }

  void _showDeleteLedgerEntryDialog(
    Map<String, dynamic> customer,
    int entryIndex,
  ) {
    final entry =
        (customer['ledger'] as List<Map<String, dynamic>>)[entryIndex];
    final entryId = (entry['id'] ?? '').toString();
    final customerId = (customer['id'] ?? '').toString();
    bool deleting = false;
    String? deleteError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: const Text(
          "Delete Entry",
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            "Remove ${entry['type']} entry \"${entry['details']}\" on ${entry['date']}?",
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (deleteError != null) ...[
            const SizedBox(height: 8),
            Text(deleteError!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.error)),
          ],
        ]),
        actions: [
          Button(
            onPressed: deleting ? null : () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(fontFamily: AppTheme.fontFamily),
            ),
          ).withClickCursor,
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(AppTheme.error),
            ),
            onPressed: deleting
                ? null
                : () async {
                    if (entryId.isEmpty || customerId.isEmpty) {
                      setDialogState(() => deleteError = 'Missing entry/customer id — refresh and try again.');
                      return;
                    }
                    setDialogState(() {
                      deleting = true;
                      deleteError = null;
                    });
                    final oldDebit = (entry['debit'] as int?) ?? 0;
                    final oldCredit = (entry['credit'] as int?) ?? 0;
                    final customerObj = Customer(
                      id: customerId,
                      name: (customer['name'] ?? '').toString(),
                      phone: (customer['phone'] ?? '').toString(),
                      cnic: (customer['cnic'] ?? '').toString(),
                      city: (customer['city'] ?? '').toString(),
                      address: (customer['address'] ?? '').toString(),
                      type: (customer['type'] ?? 'Regular').toString(),
                      balance: (customer['balance'] as int?) ?? 0,
                      notes: customer['notes'] as String?,
                    );
                    try {
                      // ignore: avoid_print
                      print('[DeleteTxn] entryId=$entryId customerId=$customerId oldDebit=$oldDebit oldCredit=$oldCredit');
                      await ledgerService.deleteEntry(
                        customer: customerObj,
                        entryId: entryId,
                        oldDebit: oldDebit,
                        oldCredit: oldCredit,
                      );
                      // ignore: avoid_print
                      print('[DeleteTxn] deleteEntry OK');
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      customer['balance'] = customerObj.balance - (oldDebit - oldCredit);
                      displayInfoBar(context, builder: (c2, close) => InfoBar(
                        title: const Text('Transaction deleted.', style: TextStyle(fontFamily: AppTheme.fontFamily)),
                        severity: InfoBarSeverity.success,
                        onClose: close,
                      ));
                      _refreshLedgerFor(customerId);
                    } catch (e, s) {
                      // ignore: avoid_print
                      print('[DeleteTxn] FAILED: $e');
                      // ignore: avoid_print
                      print('[DeleteTxn] Stack: $s');
                      if (!ctx.mounted) return;
                      setDialogState(() {
                        deleting = false;
                        deleteError = 'Delete failed: $e';
                      });
                    }
                  },
            child: deleting
                ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                : const Text(
                    "Delete",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.white,
                    ),
                  ),
          ).withClickCursor,
        ],
      )),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  RECEIPT PDF (per-transaction)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Future<void> _showTransactionReceipt(
    Map<String, dynamic> customer,
    int entryIndex,
  ) async {
    final ledger = customer['ledger'] as List<Map<String, dynamic>>;
    final entry = ledger[entryIndex];
    final type = entry['type'] as String;
    final debit = entry['debit'] as int;
    final credit = entry['credit'] as int;
    final amount = debit > 0 ? debit : credit;

    // Calculate running balance up to this entry
    int prevBalance = 0;
    for (int i = 0; i < entryIndex; i++) {
      prevBalance += (ledger[i]['debit'] as int) - (ledger[i]['credit'] as int);
    }
    int newBalance = prevBalance + debit - credit;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "INAM MOTORS",
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#6C5DD3'),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "Car Showroom & Dealership",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      height: 2,
                      width: 160,
                      color: PdfColor.fromHex('#6C5DD3'),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F0EEFF'),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    "TRANSACTION RECEIPT",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#6C5DD3'),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Date: ${entry['date']}",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    "Receipt #: RCP-${(customer['name'] as String).split(' ').first.toUpperCase()}-${entryIndex + 1}",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Customer Info
              pw.Text(
                "CUSTOMER INFORMATION",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 6),
              _pdfRow("Name", customer['name']),
              _pdfRow("Phone", customer['phone']),
              _pdfRow("CNIC", customer['cnic']),
              _pdfRow("Address", customer['address'] ?? customer['city']),
              pw.SizedBox(height: 12),

              // Transaction Info
              pw.Text(
                "TRANSACTION DETAILS",
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 6),
              _pdfRow("Type", type),
              _pdfRow("Description", entry['details']),
              _pdfRow(
                "Amount",
                '${formatFullPrice(amount)} (${debit > 0 ? "Debit" : "Credit"})',
              ),
              if (entry['salesman'] != null &&
                  (entry['salesman'] as String).isNotEmpty)
                _pdfRow(
                  type == 'Payment'
                      ? "Received by"
                      : type == 'Credit Refund'
                          ? "Given by"
                          : "Salesman",
                  entry['salesman'],
                ),
              // Car Sale: Full Payment / Payment Clearance Due Date
              if (type == 'Car Sale')
                _pdfRow(
                  "Payment Status",
                  entry['fullPayment'] == true
                      ? "Full Payment"
                      : ((entry['dueDate'] as String? ?? '').trim().isNotEmpty
                          ? "Due by ${entry['dueDate']}"
                          : "Pending"),
                ),
              // Payment: Full Payment / Remaining Due Date
              if (type == 'Payment')
                _pdfRow(
                  "Remaining Status",
                  entry['fullPayment'] == true
                      ? "Full Payment"
                      : ((entry['remainingDueDate'] as String? ?? '')
                              .trim()
                              .isNotEmpty
                          ? "Due by ${entry['remainingDueDate']}"
                          : "Pending"),
                ),
              pw.SizedBox(height: 12),

              // Documentation Status (for Car Sale & Trade-In)
              if (type == 'Car Sale' || type == 'Trade-In') ...[
                pw.Text(
                  "DOCUMENTATION STATUS",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _pdfDocItem("File", entry['file'] == true),
                    ),
                    pw.Expanded(
                      child: _pdfDocItem(
                        "Smart Card",
                        entry['smartCard'] == true,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _pdfDocItem(
                        "Number Plate",
                        entry['plate'] == true,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
              ],

              // Notes (only shown when present)
              if ((entry['notes'] as String? ?? '').isNotEmpty) ...[
                pw.Text(
                  "NOTES",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFFBEB'),
                    border: pw.Border.all(color: PdfColor.fromHex('#FDE68A')),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Text(
                    entry['notes'] as String,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 12),
              ],

              // Balance Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      "BALANCE SUMMARY",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "Previous Balance:",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          prevBalance == 0
                              ? 'Settled'
                              : '${formatFullPrice(prevBalance.abs())} ${prevBalance > 0 ? 'DR' : 'CR'}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: prevBalance > 0
                                ? PdfColors.red
                                : prevBalance < 0
                                ? PdfColors.green
                                : PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "This Transaction:",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          '${debit > 0 ? '+' : '-'} ${formatFullPrice(amount)}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: debit > 0 ? PdfColors.red : PdfColors.green,
                          ),
                        ),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "New Balance:",
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          newBalance == 0
                              ? 'Settled'
                              : '${formatFullPrice(newBalance.abs())} ${newBalance > 0 ? 'DR (Outstanding)' : 'CR (Credit)'}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: newBalance > 0
                                ? PdfColors.red
                                : newBalance < 0
                                ? PdfColors.green
                                : PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Signatures
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 100,
                        height: 0.5,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Customer Signature",
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 100,
                        height: 0.5,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Authorized Signature",
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  "Generated by Inam Motors System",
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey400,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'Receipt_${customer['name'].toString().replaceAll(' ', '_')}_${entryIndex + 1}.pdf',
    );
  }

  // â”€â”€â”€â”€â”€ Full Ledger PDF â”€â”€â”€â”€â”€
  Future<void> _showLedgerPdf(Map<String, dynamic> c) async {
    final ledger = c['ledger'] as List<Map<String, dynamic>>;
    final balance = _getBalance(c);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          int runBal = 0;
          return [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    "INAM MOTORS",
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#6C5DD3'),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "Car Showroom & Dealership",
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    height: 2,
                    width: 200,
                    color: PdfColor.fromHex('#6C5DD3'),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              "Statement of Account",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.SizedBox(height: 8),

            _pdfRow("Customer Name", c['name']),
            _pdfRow("Phone", c['phone']),
            _pdfRow("CNIC", c['cnic']),
            _pdfRow("Address", c['address'] ?? c['city']),
            pw.SizedBox(height: 16),

            // Summary
            pw.Row(
              children: [
                _pdfStatBox(
                  balance > 0
                      ? "Outstanding Balance"
                      : balance < 0
                      ? "Credit Balance"
                      : "Balance",
                  formatFullPrice(balance.abs()),
                  balance > 0 ? PdfColor.fromHex('#EF4444') : PdfColors.green,
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Ledger Table
            pw.Text(
              "Ledger Details",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (ledger.isNotEmpty)
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F0EEFF'),
                ),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                columnWidths: {
                  0: const pw.FixedColumnWidth(56),
                  1: const pw.FixedColumnWidth(46),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FixedColumnWidth(56),
                  4: const pw.FixedColumnWidth(56),
                  5: const pw.FixedColumnWidth(58),
                  6: const pw.FixedColumnWidth(54),
                  7: const pw.FixedColumnWidth(58),
                },
                headers: [
                  'Date',
                  'Type',
                  'Details',
                  'Debit',
                  'Credit',
                  'Balance',
                  'Action',
                  'Person',
                ],
                data: ledger.map((e) {
                  runBal += (e['debit'] as int) - (e['credit'] as int);
                  String details = e['details'] as String;
                  // Append payment-clearance / remaining-due info
                  final type = e['type'] as String;
                  if (type == 'Car Sale') {
                    if (e['fullPayment'] == true) {
                      details += '\nFull Payment';
                    } else {
                      final due = (e['dueDate'] as String? ?? '').trim();
                      if (due.isNotEmpty) details += '\nDue: $due';
                    }
                  } else if (type == 'Payment') {
                    if (e['fullPayment'] == true) {
                      details += '\nFull Payment';
                    } else {
                      final due =
                          (e['remainingDueDate'] as String? ?? '').trim();
                      if (due.isNotEmpty) details += '\nDue: $due';
                    }
                  }
                  // Append doc status for car-related entries
                  if (type == 'Car Sale' || type == 'Trade-In') {
                    final docs = <String>[];
                    if (e['file'] == true) docs.add('F');
                    if (e['smartCard'] == true) docs.add('SC');
                    if (e['plate'] == true) docs.add('P');
                    if (docs.isNotEmpty) details += '\n[${docs.join(', ')}]';
                  }
                  final action = type == 'Payment'
                      ? 'Received by'
                      : type == 'Credit Refund'
                          ? 'Given by'
                          : type == 'Trade-In'
                              ? 'Bought by'
                              : type == 'Car Sale'
                                  ? 'Sold by'
                                  : '';
                  return [
                    e['date'],
                    type,
                    details,
                    (e['debit'] as int) > 0
                        ? formatFullPrice(e['debit'] as int)
                        : '-',
                    (e['credit'] as int) > 0
                        ? formatFullPrice(e['credit'] as int)
                        : '-',
                    '${formatFullPrice(runBal.abs())}${runBal > 0
                        ? ' DR'
                        : runBal < 0
                        ? ' CR'
                        : ''}',
                    action,
                    e['salesman'] ?? '',
                  ];
                }).toList(),
              ),

            pw.SizedBox(height: 12),
            // Legend for doc abbreviations
            if (ledger.any(
              (e) => e['type'] == 'Car Sale' || e['type'] == 'Trade-In',
            ))
              pw.Text(
                "F = File, SC = Smart Card, P = Number Plate",
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey500,
                ),
              ),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Container(
                      width: 120,
                      height: 0.5,
                      color: PdfColors.grey400,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Customer Signature",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(
                      width: 120,
                      height: 0.5,
                      color: PdfColors.grey400,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Authorized Signature",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Center(
              child: pw.Text(
                "Generated by Inam Motors System",
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey400,
                ),
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Ledger_${c['name'].toString().replaceAll(' ', '_')}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfStatBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfDocItem(String label, bool checked) {
    return pw.Row(
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            color: checked ? PdfColors.green : PdfColors.red,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(
          '$label: ${checked ? "Yes" : "No"}',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: checked ? PdfColors.green : PdfColors.red,
          ),
        ),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  FIELD HELPERS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _editField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoLabel(
        label: label,
        labelStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
        child: TextBox(
          controller: ctrl,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
          decoration: WidgetStateProperty.all(
            BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.divider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _editFieldMultiline(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoLabel(
        label: label,
        labelStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
        child: TextBox(
          controller: ctrl,
          maxLines: 3,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
          decoration: WidgetStateProperty.all(
            BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.divider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocStatusGrid(
    bool file,
    bool smartCard,
    bool plate,
    bool remoteKey,
    void Function(bool, bool, bool, bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _docToggle(
                  "File",
                  FluentIcons.document,
                  file,
                  (v) => onChanged(v, smartCard, plate, remoteKey),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _docToggle(
                  "Smart Card",
                  FluentIcons.contact_card,
                  smartCard,
                  (v) => onChanged(file, v, plate, remoteKey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _docToggle(
                  "Number Plate",
                  FluentIcons.number_field,
                  plate,
                  (v) => onChanged(file, smartCard, v, remoteKey),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _docToggle(
                  "Remote / Key",
                  FluentIcons.lock,
                  remoteKey,
                  (v) => onChanged(file, smartCard, plate, v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _docToggle(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: value
                ? AppTheme.success.withValues(alpha: 0.1)
                : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: value
                  ? AppTheme.success.withValues(alpha: 0.5)
                  : AppTheme.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(
                value ? FluentIcons.checkbox_composite : FluentIcons.checkbox,
                size: 16,
                color: value ? AppTheme.success : AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 13,
                color: value ? AppTheme.success : AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: value ? AppTheme.success : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentChip(
    String label,
    String current,
    ValueChanged<String> onTap,
  ) {
    final sel = current == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? AppTheme.primary : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel ? AppTheme.primary : AppTheme.divider,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: sel ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'VIP':
        return AppTheme.warning;
      case 'Regular':
        return AppTheme.info;
      case 'New':
        return AppTheme.success;
      case 'Lead':
        return AppTheme.textMuted;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _balanceColor(int balance) {
    if (balance > 0) return AppTheme.error;
    if (balance < 0) return AppTheme.success;
    return AppTheme.textMuted;
  }

  String _balanceText(int balance) {
    if (balance == 0) return 'Settled';
    return '${formatFullPrice(balance.abs())} ${balance > 0 ? 'DR' : 'CR'}';
  }

  IconData _txnIcon(String type) {
    switch (type) {
      case 'Car Sale':
        return FluentIcons.car;
      case 'Payment':
        return FluentIcons.money;
      case 'Trade-In':
        return FluentIcons.switch_widget;
      case 'Credit Refund':
        return FluentIcons.undo;
      default:
        return FluentIcons.document;
    }
  }

  Color _txnColor(String type) {
    switch (type) {
      case 'Car Sale':
        return AppTheme.error;
      case 'Payment':
        return AppTheme.success;
      case 'Trade-In':
        return AppTheme.info;
      case 'Credit Refund':
        return AppTheme.warning;
      default:
        return AppTheme.textMuted;
    }
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  BUILD
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  @override
  Widget build(BuildContext context) {
    // Initial fetch in flight, no data yet → full-screen spinner.
    if (_loadingCustomers && _customers.isEmpty && _selectedCustomer == null) {
      return const ScaffoldPage(content: Center(child: ProgressRing()));
    }
    // First fetch failed and we have nothing to show → error + retry.
    if (_customersLoadError != null &&
        _customers.isEmpty &&
        _selectedCustomer == null) {
      return ScaffoldPage(
        content: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.error, size: 36, color: AppTheme.error),
                const SizedBox(height: 12),
                Text(
                  'Failed to load customers',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _customersLoadError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: AppTheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _refreshCustomers,
                  child: const Text('Retry',
                      style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_selectedCustomer != null) {
      return _buildCustomerDetail(_selectedCustomer!);
    }
    return _buildCustomerList();
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //  CUSTOMER LIST VIEW
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildCustomerList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;

        return ScaffoldPage.scrollable(
          padding: EdgeInsets.all(isNarrow ? 16 : 28),
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customers",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: isNarrow ? 22 : 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Customer ledger system \u2014 track sales, payments & trade-ins",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: isNarrow ? 12 : 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: _loadingCustomers
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: ProgressRing(strokeWidth: 2),
                        )
                      : Icon(FluentIcons.refresh,
                          size: 16, color: AppTheme.textSecondary),
                  onPressed: _loadingCustomers ? null : _refreshCustomers,
                ).withClickCursor,
                const SizedBox(width: 8),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  onPressed: () => _showAddCustomerDialog(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.add, size: 14, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Add Customer",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ).withClickCursor,
              ],
            ),

            const SizedBox(height: 24),

            // STATS
            if (isNarrow)
              Column(
                children: [
                  Row(
                    children: [
                      StatCard(
                        label: "Total",
                        value: "${_customers.length}",
                        icon: FluentIcons.people,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: "VIP",
                        value: "$_vipCount",
                        icon: FluentIcons.diamond_user,
                        color: AppTheme.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatCard(
                        label: "With Balance",
                        value: "$_withBalanceCount",
                        icon: FluentIcons.alert_solid,
                        color: AppTheme.error,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: "Leads",
                        value: "$_leadCount",
                        icon: FluentIcons.people_add,
                        color: AppTheme.success,
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                children: [
                  StatCard(
                    label: "Total Customers",
                    value: "${_customers.length}",
                    icon: FluentIcons.people,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    label: "VIP Customers",
                    value: "$_vipCount",
                    icon: FluentIcons.diamond_user,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    label: "With Balance Due",
                    value: "$_withBalanceCount",
                    icon: FluentIcons.alert_solid,
                    color: AppTheme.error,
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    label: "Leads",
                    value: "$_leadCount",
                    icon: FluentIcons.people_add,
                    color: AppTheme.success,
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // SEARCH + FILTERS
            if (isNarrow)
              Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip("All", _customers.length),
                        const SizedBox(width: 8),
                        _buildChip("VIP", _vipCount),
                        const SizedBox(width: 8),
                        _buildChip("Regular", _regularCount),
                        const SizedBox(width: 8),
                        _buildChip("New", _newCount),
                        const SizedBox(width: 8),
                        _buildChip("Lead", _leadCount),
                      ],
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(flex: 3, child: _buildSearchBar()),
                  const SizedBox(width: 16),
                  _buildChip("All", _customers.length),
                  const SizedBox(width: 8),
                  _buildChip("VIP", _vipCount),
                  const SizedBox(width: 8),
                  _buildChip("Regular", _regularCount),
                  const SizedBox(width: 8),
                  _buildChip("New", _newCount),
                  const SizedBox(width: 8),
                  _buildChip("Lead", _leadCount),
                ],
              ),

            const SizedBox(height: 16),

            Text(
              "Showing ${_filtered.length} of ${_customers.length} customers",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),

            const SizedBox(height: 12),

            // CUSTOMER TABLE
            if (!isNarrow) _buildTableHeader(),
            ..._filtered.map(
              (c) => isNarrow ? _buildCustomerCard(c) : _buildCustomerRow(c),
            ),
            if (_filtered.isEmpty)
              const EmptyState(message: 'No customers found'),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TextBox(
        placeholder: "Search by name, phone, CNIC, address...",
        placeholderStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 13,
          color: AppTheme.textMuted,
        ),
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 13,
          color: AppTheme.textPrimary,
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(FluentIcons.search, size: 14, color: AppTheme.textMuted),
        ),
        decoration: WidgetStateProperty.all(
          BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildChip(String label, int count) {
    final sel = _selectedFilter == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: sel ? AppTheme.primary : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel ? AppTheme.primary : AppTheme.divider,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sel
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$count",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "Name",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: Text(
              "CNIC",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              "Phone",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              "Type",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              "Cars",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              "Balance",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 140),
        ],
      ),
    );
  }

  Widget _buildCustomerRow(Map<String, dynamic> c) {
    final typeColor = _typeColor(c['type']);
    final balance = _getBalance(c);
    final carCount = _getCarCount(c);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _selectCustomer(c),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          c['name'].toString().substring(0, 1),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['name'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            c['city'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 130,
                child: Text(
                  c['cnic'],
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                child: Text(
                  c['phone'],
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    c['type'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  "$carCount",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balance == 0 ? 'Settled' : formatFullPrice(balance.abs()),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _balanceColor(balance),
                      ),
                    ),
                    if (balance > 0)
                      Text(
                        "Owes",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 9,
                          color: AppTheme.error.withValues(alpha: 0.7),
                        ),
                      ),
                    if (balance < 0)
                      Text(
                        "Credit",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 9,
                          color: AppTheme.success.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              // Actions column: small icons on top, prominent View Statement button below
              SizedBox(
                width: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if ((c['notes'] as String? ?? '').trim().isNotEmpty)
                          Tooltip(
                            message: "Note Entered",
                            child: IconButton(
                              icon: Icon(
                                FluentIcons.quick_note,
                                size: 14,
                                color: const Color(0xFFF59E0B),
                              ),
                              onPressed: () => _showCustomerNoteDialog(c),
                            ).withClickCursor,
                          ),
                        Tooltip(
                          message: "Print Ledger",
                          child: IconButton(
                            icon: Icon(
                              FluentIcons.pdf,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                            onPressed: () => _showLedgerPdf(c),
                          ).withClickCursor,
                        ),
                        Tooltip(
                          message: "Edit",
                          child: IconButton(
                            icon: Icon(
                              FluentIcons.edit,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                            onPressed: () => _showEditCustomerDialog(c),
                          ).withClickCursor,
                        ),
                        Tooltip(
                          message: "Remove",
                          child: IconButton(
                            icon: Icon(
                              FluentIcons.delete,
                              size: 14,
                              color: AppTheme.error.withValues(alpha: 0.7),
                            ),
                            onPressed: () => _showRemoveCustomerDialog(c),
                          ).withClickCursor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _selectCustomer(c),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "View Statement",
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                FluentIcons.chevron_right_med,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> c) {
    final typeColor = _typeColor(c['type']);
    final balance = _getBalance(c);
    final carCount = _getCarCount(c);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _selectCustomer(c),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        c['name'].toString().substring(0, 1),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['name'],
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          c['phone'],
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((c['notes'] as String? ?? '').trim().isNotEmpty) ...[
                    Tooltip(
                      message: "Note Entered",
                      child: IconButton(
                        icon: Icon(
                          FluentIcons.quick_note,
                          size: 14,
                          color: const Color(0xFFF59E0B),
                        ),
                        onPressed: () => _showCustomerNoteDialog(c),
                      ).withClickCursor,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      c['type'],
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: typeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FluentIcons.contact_card,
                          size: 11,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "CNIC: ",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        Text(
                          c['cnic'],
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          FluentIcons.home,
                          size: 11,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            c['address'] ?? c['city'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(FluentIcons.car, size: 12, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    "$carCount cars",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _balanceColor(balance).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      balance == 0
                          ? 'Settled'
                          : '${balance > 0 ? "Owes " : "Credit "}${formatFullPrice(balance.abs())}',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _balanceColor(balance),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Prominent View Statement button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _selectCustomer(c),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "View Statement of Account",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          FluentIcons.chevron_right_med,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //  CUSTOMER DETAIL / LEDGER VIEW
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildCustomerDetail(Map<String, dynamic> c) {
    final ledger = c['ledger'] as List<Map<String, dynamic>>;
    final balance = _getBalance(c);
    final totalDebit = _getTotalDebit(c);
    final totalCredit = _getTotalCredit(c);
    final carCount = _getCarCount(c);
    final typeColor = _typeColor(c['type']);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;

        return ScaffoldPage.scrollable(
          padding: EdgeInsets.all(isNarrow ? 16 : 28),
          children: [
            // ── Layer-2 ledger load status ───────────────────────────────
            if (_loadingLedger)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Text('Loading ledger via REST…',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                ]),
              ),
            if (_ledgerLoadError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  Icon(FluentIcons.error, size: 14, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Failed to load ledger: $_ledgerLoadError',
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error)),
                  ),
                  const SizedBox(width: 8),
                  Button(
                    onPressed: () => _refreshLedgerFor((c['id'] ?? '').toString()),
                    child: const Text('Retry', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
                  ).withClickCursor,
                ]),
              ),
            // BACK + TITLE
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    FluentIcons.chrome_back,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => setState(() => _selectedCustomer = null),
                ).withClickCursor,
                const SizedBox(width: 8),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      c['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              c['name'],
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: isNarrow ? 18 : 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              c['type'],
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${c['phone']}  \u2022  ${c['cnic']}  \u2022  ${c['city']}",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                if (!isNarrow) ...[
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        AppTheme.primary,
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                    onPressed: () => _showAddTransactionDialog(c),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.add, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          "Add Transaction",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ).withClickCursor,
                  const SizedBox(width: 8),
                  Tooltip(
                    message: "Print Ledger PDF",
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          FluentIcons.pdf,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                      onPressed: () => _showLedgerPdf(c),
                    ).withClickCursor,
                  ),
                  const SizedBox(width: 4),
                  if ((c['notes'] as String? ?? '').trim().isNotEmpty) ...[
                    Tooltip(
                      message: "Note Entered",
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Icon(
                            FluentIcons.quick_note,
                            size: 16,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        onPressed: () => _showCustomerNoteDialog(c),
                      ).withClickCursor,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Tooltip(
                    message: "Edit Customer",
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: const Icon(
                          FluentIcons.edit,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                      onPressed: () => _showEditCustomerDialog(c),
                    ).withClickCursor,
                  ),
                ],
              ],
            ),

            if (isNarrow) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          AppTheme.primary,
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                      onPressed: () => _showAddTransactionDialog(c),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.add, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "Add Transaction",
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ).withClickCursor,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      FluentIcons.pdf,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    onPressed: () => _showLedgerPdf(c),
                  ).withClickCursor,
                  if ((c['notes'] as String? ?? '').trim().isNotEmpty)
                    Tooltip(
                      message: "Note Entered",
                      child: IconButton(
                        icon: Icon(
                          FluentIcons.quick_note,
                          size: 16,
                          color: const Color(0xFFF59E0B),
                        ),
                        onPressed: () => _showCustomerNoteDialog(c),
                      ).withClickCursor,
                    ),
                  IconButton(
                    icon: Icon(
                      FluentIcons.edit,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    onPressed: () => _showEditCustomerDialog(c),
                  ).withClickCursor,
                ],
              ),
            ],

            const SizedBox(height: 24),

            // â”€â”€ SUMMARY STATS â”€â”€
            if (isNarrow)
              Column(
                children: [
                  Row(
                    children: [
                      StatCard(
                        label: "Total Charged",
                        value: formatFullPrice(totalDebit),
                        icon: FluentIcons.receipt_processing,
                        color: AppTheme.error,
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: "Total Paid",
                        value: formatFullPrice(totalCredit),
                        icon: FluentIcons.money,
                        color: AppTheme.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatCard(
                        label: "Balance",
                        value: _balanceText(balance),
                        icon: FluentIcons.calculator,
                        color: _balanceColor(balance),
                      ),
                      const SizedBox(width: 12),
                      StatCard(
                        label: "Cars Bought",
                        value: "$carCount",
                        icon: FluentIcons.car,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                children: [
                  StatCard(
                    label: "Total Charged",
                    value: formatFullPrice(totalDebit),
                    icon: FluentIcons.receipt_processing,
                    color: AppTheme.error,
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    label: "Total Paid / Credited",
                    value: formatFullPrice(totalCredit),
                    icon: FluentIcons.money,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    label: "Current Balance",
                    value: _balanceText(balance),
                    icon: FluentIcons.calculator,
                    color: _balanceColor(balance),
                  ),
                  const SizedBox(width: 16),
                  StatCard(
                    label: "Cars Bought",
                    value: "$carCount",
                    icon: FluentIcons.car,
                    color: AppTheme.primary,
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // â”€â”€ BALANCE BANNER â”€â”€
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _balanceColor(balance).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _balanceColor(balance).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    balance > 0
                        ? FluentIcons.warning
                        : balance < 0
                        ? FluentIcons.completed
                        : FluentIcons.accept_medium,
                    size: 20,
                    color: _balanceColor(balance),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          balance > 0
                              ? "Outstanding Balance"
                              : balance < 0
                              ? "Credit Balance (We Owe Customer)"
                              : "Account Settled",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _balanceColor(balance),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          balance > 0
                              ? "${c['name']} owes ${formatFullPrice(balance)} to Inam Motors"
                              : balance < 0
                              ? "Inam Motors owes ${formatFullPrice(balance.abs())} to ${c['name']}"
                              : "All payments are settled. No balance due.",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    balance == 0
                        ? '\u2713 Cleared'
                        : '${formatFullPrice(balance.abs())} ${balance > 0 ? 'DR' : 'CR'}',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _balanceColor(balance),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // â”€â”€ LEDGER TABLE â”€â”€
            Row(
              children: [
                Text(
                  "Statement of Account",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  "${ledger.length} transactions",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (ledger.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        FluentIcons.document_set,
                        size: 28,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No transactions yet",
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Click 'Add Transaction' to sell a car, receive payment, or record a trade-in",
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Table Header
              if (!isNarrow)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          "Date",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          "Type",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Details",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          "Debit",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          "Credit",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Text(
                          "Balance",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 140),
                    ],
                  ),
                ),

              // Table Rows
              ..._buildLedgerRows(c, ledger, isNarrow),
            ],

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  List<Widget> _buildLedgerRows(
    Map<String, dynamic> customer,
    List<Map<String, dynamic>> ledger,
    bool isNarrow,
  ) {
    int runningBalance = 0;
    final rows = <Widget>[];

    for (int i = 0; i < ledger.length; i++) {
      final e = ledger[i];
      final debit = e['debit'] as int;
      final credit = e['credit'] as int;
      runningBalance += debit - credit;
      final isLast = i == ledger.length - 1;

      if (isNarrow) {
        rows.add(
          _buildLedgerCard(customer, i, e, debit, credit, runningBalance),
        );
      } else {
        // Build detail sub-text showing salesman + doc status
        final hasDocs = e['type'] == 'Car Sale' || e['type'] == 'Trade-In';
        final salesman = e['salesman'] as String? ?? '';

        rows.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(
                left: BorderSide(color: AppTheme.divider),
                right: BorderSide(color: AppTheme.divider),
                bottom: BorderSide(color: AppTheme.divider),
              ),
              borderRadius: isLast
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    )
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    e['date'],
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _txnColor(e['type']).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Icon(
                          _txnIcon(e['type']),
                          size: 12,
                          color: _txnColor(e['type']),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          e['type'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _txnColor(e['type']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['details'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (e['type'] == 'Car Sale' &&
                          (e['fullPayment'] == true ||
                              (e['dueDate'] as String? ?? '')
                                  .trim()
                                  .isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(
                                FluentIcons.clock,
                                size: 10,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  e['fullPayment'] == true
                                      ? "Full Payment"
                                      : "Due by ${e['dueDate']}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (e['type'] == 'Payment' &&
                          (e['fullPayment'] == true ||
                              (e['remainingDueDate'] as String? ?? '')
                                  .trim()
                                  .isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(
                                FluentIcons.clock,
                                size: 10,
                                color: AppTheme.warning,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  e['fullPayment'] == true
                                      ? "Full Payment"
                                      : "Due by ${e['remainingDueDate']}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          if (salesman.isNotEmpty) ...[
                            Icon(
                              FluentIcons.people,
                              size: 10,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              salesman,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 10,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                          if (salesman.isNotEmpty && hasDocs)
                            const SizedBox(width: 8),
                          if (hasDocs) ...[
                            _miniDocBadge("F", e['file'] == true),
                            const SizedBox(width: 3),
                            _miniDocBadge("SC", e['smartCard'] == true),
                            const SizedBox(width: 3),
                            _miniDocBadge("P", e['plate'] == true),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    debit > 0 ? formatFullPrice(debit) : '-',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: debit > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: debit > 0 ? AppTheme.error : AppTheme.textMuted,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    credit > 0 ? formatFullPrice(credit) : '-',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: credit > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: credit > 0 ? AppTheme.success : AppTheme.textMuted,
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Text(
                    '${formatFullPrice(runningBalance.abs())}${runningBalance > 0
                        ? ' DR'
                        : runningBalance < 0
                        ? ' CR'
                        : ''}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: runningBalance > 0
                          ? AppTheme.error
                          : runningBalance < 0
                          ? AppTheme.success
                          : AppTheme.textMuted,
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if ((e['notes'] as String? ?? '').trim().isNotEmpty)
                        Tooltip(
                          message: "Note Entered",
                          child: IconButton(
                            icon: Icon(
                              FluentIcons.quick_note,
                              size: 12,
                              color: const Color(0xFFF59E0B),
                            ),
                            onPressed: () => _showNoteDialog(e),
                          ).withClickCursor,
                        ),
                      Tooltip(
                        message: "Edit",
                        child: IconButton(
                          icon: Icon(
                            FluentIcons.edit,
                            size: 12,
                            color: AppTheme.primary.withValues(alpha: 0.7),
                          ),
                          onPressed: () =>
                              _showEditTransactionDialog(customer, i),
                        ).withClickCursor,
                      ),
                      Tooltip(
                        message: "Receipt",
                        child: IconButton(
                          icon: Icon(
                            FluentIcons.print,
                            size: 12,
                            color: AppTheme.primary.withValues(alpha: 0.7),
                          ),
                          onPressed: () => _showTransactionReceipt(customer, i),
                        ).withClickCursor,
                      ),
                      Tooltip(
                        message: "Delete",
                        child: IconButton(
                          icon: Icon(
                            FluentIcons.delete,
                            size: 12,
                            color: AppTheme.error.withValues(alpha: 0.5),
                          ),
                          onPressed: () =>
                              _showDeleteLedgerEntryDialog(customer, i),
                        ).withClickCursor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return rows;
  }

  Widget _miniDocBadge(String label, bool ok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: ok
            ? AppTheme.success.withValues(alpha: 0.12)
            : AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: ok ? AppTheme.success : AppTheme.error.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildLedgerCard(
    Map<String, dynamic> customer,
    int index,
    Map<String, dynamic> e,
    int debit,
    int credit,
    int runningBalance,
  ) {
    final hasDocs = e['type'] == 'Car Sale' || e['type'] == 'Trade-In';
    final salesman = e['salesman'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _txnColor(e['type']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _txnIcon(e['type']),
                  size: 14,
                  color: _txnColor(e['type']),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e['type'],
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _txnColor(e['type']),
                      ),
                    ),
                    Text(
                      e['details'],
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((e['notes'] as String? ?? '').trim().isNotEmpty)
                    Tooltip(
                      message: "Note Entered",
                      child: IconButton(
                        icon: Icon(
                          FluentIcons.quick_note,
                          size: 12,
                          color: const Color(0xFFF59E0B),
                        ),
                        onPressed: () => _showNoteDialog(e),
                      ).withClickCursor,
                    ),
                  IconButton(
                    icon: Icon(
                      FluentIcons.edit,
                      size: 12,
                      color: AppTheme.primary.withValues(alpha: 0.7),
                    ),
                    onPressed: () =>
                        _showEditTransactionDialog(customer, index),
                  ).withClickCursor,
                  IconButton(
                    icon: Icon(
                      FluentIcons.print,
                      size: 12,
                      color: AppTheme.primary.withValues(alpha: 0.7),
                    ),
                    onPressed: () => _showTransactionReceipt(customer, index),
                  ).withClickCursor,
                  IconButton(
                    icon: Icon(
                      FluentIcons.delete,
                      size: 12,
                      color: AppTheme.error.withValues(alpha: 0.5),
                    ),
                    onPressed: () =>
                        _showDeleteLedgerEntryDialog(customer, index),
                  ).withClickCursor,
                ],
              ),
            ],
          ),
          if (salesman.isNotEmpty ||
              hasDocs ||
              (e['type'] == 'Car Sale' &&
                  (e['fullPayment'] == true ||
                      (e['dueDate'] as String? ?? '').trim().isNotEmpty)) ||
              (e['type'] == 'Payment' &&
                  (e['fullPayment'] == true ||
                      (e['remainingDueDate'] as String? ?? '')
                          .trim()
                          .isNotEmpty))) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (e['type'] == 'Car Sale' &&
                    (e['fullPayment'] == true ||
                        (e['dueDate'] as String? ?? '').trim().isNotEmpty))
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentIcons.clock,
                        size: 10,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        e['fullPayment'] == true
                            ? "Full Payment"
                            : "Due ${e['dueDate']}",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                if (e['type'] == 'Payment' &&
                    (e['fullPayment'] == true ||
                        (e['remainingDueDate'] as String? ?? '')
                            .trim()
                            .isNotEmpty))
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentIcons.clock,
                        size: 10,
                        color: AppTheme.warning,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        e['fullPayment'] == true
                            ? "Full Payment"
                            : "Due ${e['remainingDueDate']}",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                if (salesman.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentIcons.people,
                        size: 10,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        salesman,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                if (hasDocs)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _miniDocBadge("F", e['file'] == true),
                      const SizedBox(width: 3),
                      _miniDocBadge("SC", e['smartCard'] == true),
                      const SizedBox(width: 3),
                      _miniDocBadge("P", e['plate'] == true),
                    ],
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Text(
                  e['date'],
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
                const Spacer(),
                if (debit > 0)
                  Text(
                    "DR: ${formatFullPrice(debit)}",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error,
                    ),
                  ),
                if (credit > 0)
                  Text(
                    "CR: ${formatFullPrice(credit)}",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                const SizedBox(width: 12),
                Text(
                  'Bal: ${formatFullPrice(runningBalance.abs())}${runningBalance > 0
                      ? ' DR'
                      : runningBalance < 0
                      ? ' CR'
                      : ''}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: runningBalance > 0
                        ? AppTheme.error
                        : runningBalance < 0
                        ? AppTheme.success
                        : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

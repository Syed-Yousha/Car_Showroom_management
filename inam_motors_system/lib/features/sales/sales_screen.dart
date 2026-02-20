import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _searchQuery = '';
  String _selectedTab = 'All';
  int? _expandedSaleIndex;

  // Car inventory (shared reference)
  final List<Map<String, dynamic>> _availableCars = [
    {'name': 'Toyota Grande', 'make': 'Toyota', 'model': 'Grande', 'year': 2024, 'color': 'White', 'regNo': 'LEA-7421', 'chassisNo': 'JTDBR32E-860045123', 'engineNo': '2ZR-FE-8924561'},
    {'name': 'Kia Sportage', 'make': 'Kia', 'model': 'Sportage Alpha', 'year': 2022, 'color': 'Red', 'regNo': 'ISB-3918', 'chassisNo': 'KNAPH81-220056789', 'engineNo': 'G4FJ-2204587'},
    {'name': 'Suzuki Cultus', 'make': 'Suzuki', 'model': 'Cultus VXL', 'year': 2024, 'color': 'Silver', 'regNo': 'LEA-1105', 'chassisNo': 'MBJHA36-240012345', 'engineNo': 'K10B-2401234'},
    {'name': 'Hyundai Tucson', 'make': 'Hyundai', 'model': 'Tucson GLS', 'year': 2022, 'color': 'Grey', 'regNo': 'LHR-8890', 'chassisNo': 'KMHJN81-220098765', 'engineNo': 'G4FP-2209871'},
    {'name': 'Changan Alsvin', 'make': 'Changan', 'model': 'Alsvin Lumiere', 'year': 2024, 'color': 'Blue', 'regNo': 'MUL-2243', 'chassisNo': 'LSCGB54-240034567', 'engineNo': 'JL473Q5-2403456'},
    {'name': 'Toyota Corolla', 'make': 'Toyota', 'model': 'Corolla Altis X', 'year': 2024, 'color': 'Silver', 'regNo': 'LEA-9034', 'chassisNo': 'JTDKR32E-240067890', 'engineNo': '1NZ-FE-2406789'},
  ];

  // Buyers reference
  final List<Map<String, dynamic>> _buyers = [
    {'name': 'Ali Hassan', 'phone': '0312-1234567', 'cnic': '35202-1234567-1', 'address': '123 Model Town, Lahore'},
    {'name': 'Ahmed Khan', 'phone': '0300-9876543', 'cnic': '35201-9876543-2', 'address': '45 F-8, Islamabad'},
    {'name': 'Usman Ali', 'phone': '0321-5551234', 'cnic': '35203-5551234-3', 'address': '78 Clifton Block 5, Karachi'},
    {'name': 'Bilal Malik', 'phone': '0333-6667890', 'cnic': '35204-6667890-4', 'address': '12 Johar Town Phase 2, Lahore'},
    {'name': 'Farhan Raza', 'phone': '0345-1112233', 'cnic': '35205-1112233-5', 'address': '56 D Ground, Faisalabad'},
    {'name': 'Zain ul Abideen', 'phone': '0311-7778899', 'cnic': '35207-7778899-7', 'address': '34 Saddar Bazaar, Rawalpindi'},
    {'name': 'Hamza Tariq', 'phone': '0322-2223344', 'cnic': '35208-2223344-8', 'address': '67 Canal Road, Lahore'},
    {'name': 'Waqar Ahmed', 'phone': '0346-8889900', 'cnic': '35210-8889900-0', 'address': '15 University Road, Peshawar'},
  ];

  // Sellers / Salesmen
  final List<Map<String, dynamic>> _sellers = [
    {'name': 'Faheem Khan', 'phone': '0300-1112233', 'cnic': '35201-1112233-1', 'address': 'Office, Inam Motors, Lahore'},
    {'name': 'Inam Khan', 'phone': '0321-4445566', 'cnic': '35201-4445566-2', 'address': 'Office, Inam Motors, Lahore'},
  ];

  // Sales Ledger (each sale is an account)
  final List<Map<String, dynamic>> _sales = [
    {
      'invoiceNo': 'INV-0001',
      'car': 'Honda Civic',
      'carDetails': {'make': 'Honda', 'model': 'Civic', 'year': 2023, 'color': 'Black', 'regNo': 'LHR-5532', 'chassisNo': 'MRHGM66-560089745', 'engineNo': 'R18Z1-7756231'},
      'buyer': 'Ahmed Khan',
      'buyerPhone': '0300-9876543',
      'buyerCnic': '35201-9876543-2',
      'buyerAddress': '45 F-8, Islamabad',
      'seller': 'Faheem Khan',
      'sellerPhone': '0300-1112233',
      'sellerCnic': '35201-1112233-1',
      'sellerAddress': 'Office, Inam Motors, Lahore',
      'totalPrice': 7200000,
      'saleDate': '2026-02-03',
      'payments': [
        {'amount': 4000000, 'type': 'Cash', 'date': '2026-02-03', 'accNo': ''},
        {'amount': 3200000, 'type': 'Bank Transfer', 'date': '2026-02-10', 'accNo': 'HBL-102938'},
      ],
    },
    {
      'invoiceNo': 'INV-0002',
      'car': 'Kia Sportage',
      'carDetails': {'make': 'Kia', 'model': 'Sportage Alpha', 'year': 2022, 'color': 'Red', 'regNo': 'ISB-3918', 'chassisNo': 'KNAPH81-220056789', 'engineNo': 'G4FJ-2204587'},
      'buyer': 'Usman Ali',
      'buyerPhone': '0321-5551234',
      'buyerCnic': '35203-5551234-3',
      'buyerAddress': '78 Clifton Block 5, Karachi',
      'seller': 'Inam Khan',
      'sellerPhone': '0321-4445566',
      'sellerCnic': '35201-4445566-2',
      'sellerAddress': 'Office, Inam Motors, Lahore',
      'totalPrice': 9500000,
      'saleDate': '2026-02-01',
      'payments': [
        {'amount': 4000000, 'type': 'Cash', 'date': '2026-02-01', 'accNo': ''},
        {'amount': 1500000, 'type': 'Cheque', 'date': '2026-02-15', 'accNo': 'CHQ-447821'},
      ],
    },
    {
      'invoiceNo': 'INV-0003',
      'car': 'MG HS',
      'carDetails': {'make': 'MG', 'model': 'HS Essence', 'year': 2024, 'color': 'White', 'regNo': 'LEA-6677', 'chassisNo': 'LSJWB48-240076543', 'engineNo': '15S4G-2406543'},
      'buyer': 'Zain ul Abideen',
      'buyerPhone': '0311-7778899',
      'buyerCnic': '35207-7778899-7',
      'buyerAddress': '34 Saddar Bazaar, Rawalpindi',
      'seller': 'Faheem Khan',
      'sellerPhone': '0300-1112233',
      'sellerCnic': '35201-1112233-1',
      'sellerAddress': 'Office, Inam Motors, Lahore',
      'totalPrice': 9800000,
      'saleDate': '2026-01-15',
      'payments': [
        {'amount': 9800000, 'type': 'Bank Transfer', 'date': '2026-01-15', 'accNo': 'MCB-998877'},
      ],
    },
    {
      'invoiceNo': 'INV-0004',
      'car': 'Suzuki Cultus',
      'carDetails': {'make': 'Suzuki', 'model': 'Cultus VXL', 'year': 2024, 'color': 'Silver', 'regNo': 'LEA-1105', 'chassisNo': 'MBJHA36-240012345', 'engineNo': 'K10B-2401234'},
      'buyer': 'Bilal Malik',
      'buyerPhone': '0333-6667890',
      'buyerCnic': '35204-6667890-4',
      'buyerAddress': '12 Johar Town Phase 2, Lahore',
      'seller': 'Inam Khan',
      'sellerPhone': '0321-4445566',
      'sellerCnic': '35201-4445566-2',
      'sellerAddress': 'Office, Inam Motors, Lahore',
      'totalPrice': 3800000,
      'saleDate': '2026-01-28',
      'payments': [
        {'amount': 1500000, 'type': 'Cash', 'date': '2026-01-28', 'accNo': ''},
        {'amount': 800000, 'type': 'Online', 'date': '2026-02-12', 'accNo': 'JZ-0033221'},
      ],
    },
    {
      'invoiceNo': 'INV-0005',
      'car': 'Hyundai Tucson',
      'carDetails': {'make': 'Hyundai', 'model': 'Tucson GLS', 'year': 2022, 'color': 'Grey', 'regNo': 'LHR-8890', 'chassisNo': 'KMHJN81-220098765', 'engineNo': 'G4FP-2209871'},
      'buyer': 'Farhan Raza',
      'buyerPhone': '0345-1112233',
      'buyerCnic': '35205-1112233-5',
      'buyerAddress': '56 D Ground, Faisalabad',
      'seller': 'Faheem Khan',
      'sellerPhone': '0300-1112233',
      'sellerCnic': '35201-1112233-1',
      'sellerAddress': 'Office, Inam Motors, Lahore',
      'totalPrice': 11000000,
      'saleDate': '2026-01-25',
      'payments': [
        {'amount': 5000000, 'type': 'Cash', 'date': '2026-01-25', 'accNo': ''},
        {'amount': 2000000, 'type': 'Cheque', 'date': '2026-02-05', 'accNo': 'CHQ-119988'},
      ],
    },
    {
      'invoiceNo': 'INV-0006',
      'car': 'Changan Alsvin',
      'carDetails': {'make': 'Changan', 'model': 'Alsvin Lumiere', 'year': 2024, 'color': 'Blue', 'regNo': 'MUL-2243', 'chassisNo': 'LSCGB54-240034567', 'engineNo': 'JL473Q5-2403456'},
      'buyer': 'Hamza Tariq',
      'buyerPhone': '0322-2223344',
      'buyerCnic': '35208-2223344-8',
      'buyerAddress': '67 Canal Road, Lahore',
      'seller': 'Inam Khan',
      'sellerPhone': '0321-4445566',
      'sellerCnic': '35201-4445566-2',
      'sellerAddress': 'Office, Inam Motors, Lahore',
      'totalPrice': 4600000,
      'saleDate': '2026-01-10',
      'payments': [
        {'amount': 2000000, 'type': 'Cash', 'date': '2026-01-10', 'accNo': ''},
        {'amount': 1200000, 'type': 'Online', 'date': '2026-02-01', 'accNo': 'EP-445566'},
      ],
    },
  ];

  // Computed helpers
  int _totalPaid(Map<String, dynamic> sale) =>
      (sale['payments'] as List).fold(0, (s, p) => s + ((p as Map)['amount'] as int));
  int _remaining(Map<String, dynamic> sale) =>
      (sale['totalPrice'] as int) - _totalPaid(sale);
  String _saleStatus(Map<String, dynamic> sale) =>
      _remaining(sale) <= 0 ? 'Completed' : 'Active';

  int get _totalSalesValue => _sales.fold(0, (s, e) => s + (e['totalPrice'] as int));
  int get _totalReceived => _sales.fold(0, (s, e) => s + _totalPaid(e));
  int get _totalPending => _totalSalesValue - _totalReceived;
  int get _activeCount => _sales.where((s) => _saleStatus(s) == 'Active').length;
  int get _completedCount => _sales.where((s) => _saleStatus(s) == 'Completed').length;

  List<Map<String, dynamic>> get _filtered {
    return _sales.where((s) {
      if (_selectedTab == 'Active' && _saleStatus(s) != 'Active') return false;
      if (_selectedTab == 'Completed' && _saleStatus(s) != 'Completed') return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return s['buyer'].toString().toLowerCase().contains(q) ||
            s['car'].toString().toLowerCase().contains(q) ||
            s['invoiceNo'].toString().toLowerCase().contains(q) ||
            s['seller'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  String _formatPrice(int price) {
    if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return 'Rs ${(price / 1000).toStringAsFixed(0)}K';
    return 'Rs $price';
  }

  String _formatFullPrice(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buf.write(str[i]);
      count++;
      if (count == 3 && i > 0) { buf.write(','); count = 0; }
      else if (count > 3 && (count - 3) % 2 == 0 && i > 0) buf.write(',');
    }
    return 'Rs ${buf.toString().split('').reversed.join()}';
  }

  // ═══════════════════════════════════════════════
  //  ADD SALE DIALOG
  // ═══════════════════════════════════════════════
  void _showAddSaleDialog() {
    String? selectedCarName;
    String? selectedBuyerName;
    String? selectedSellerName;
    final priceCtrl = TextEditingController();
    final firstPaymentAmountCtrl = TextEditingController();
    String firstPaymentType = 'Cash';
    final firstPaymentAccCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        final selectedCar = selectedCarName != null
            ? _availableCars.firstWhere((c) => c['name'] == selectedCarName, orElse: () => <String, dynamic>{})
            : null;
        final selectedBuyer = selectedBuyerName != null
            ? _buyers.firstWhere((b) => b['name'] == selectedBuyerName, orElse: () => <String, dynamic>{})
            : null;
        final selectedSeller = selectedSellerName != null
            ? _sellers.firstWhere((s) => s['name'] == selectedSellerName, orElse: () => <String, dynamic>{})
            : null;

        return ContentDialog(
          title: const Text("New Sale", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
          constraints: const BoxConstraints(maxWidth: 580),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Select Car",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    placeholder: const Text("Choose a car", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                    value: selectedCarName,
                    isExpanded: true,
                    items: _availableCars.map((c) => ComboBoxItem<String>(
                      value: c['name'] as String,
                      child: Text("${c['name']} ${c['year']} (${c['regNo']})", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                    )).toList(),
                    onChanged: (v) => setDialogState(() => selectedCarName = v),
                  ),
                ),
              ),
              if (selectedCar != null && selectedCar.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.04), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primary.withOpacity(0.12))),
                  child: Row(children: [
                    Icon(FluentIcons.car, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text("${selectedCar['make']} ${selectedCar['model']} | ${selectedCar['color']} | ${selectedCar['regNo']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary))),
                  ]),
                ),
              Row(children: [
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InfoLabel(
                    label: "Select Buyer",
                    labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    child: ComboBox<String>(
                      placeholder: const Text("Choose buyer", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                      value: selectedBuyerName,
                      isExpanded: true,
                      items: _buyers.map((b) => ComboBoxItem<String>(
                        value: b['name'] as String,
                        child: Text("${b['name']} (${b['phone']})", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                      )).toList(),
                      onChanged: (v) => setDialogState(() => selectedBuyerName = v),
                    ),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InfoLabel(
                    label: "Select Seller",
                    labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    child: ComboBox<String>(
                      placeholder: const Text("Choose seller", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                      value: selectedSellerName,
                      isExpanded: true,
                      items: _sellers.map((s) => ComboBoxItem<String>(
                        value: s['name'] as String,
                        child: Text(s['name'] as String, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                      )).toList(),
                      onChanged: (v) => setDialogState(() => selectedSellerName = v),
                    ),
                  ),
                )),
              ]),
              if (selectedBuyer != null && selectedBuyer.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: AppTheme.info.withOpacity(0.04), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.info.withOpacity(0.12))),
                  child: Row(children: [
                    Icon(FluentIcons.contact, size: 14, color: AppTheme.info),
                    const SizedBox(width: 8),
                    Expanded(child: Text("${selectedBuyer['cnic']} | ${selectedBuyer['address']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary))),
                  ]),
                ),
              _saleEditField("Total Price (Rs)", priceCtrl),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Initial Payment / Advance", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _saleEditField("Amount", firstPaymentAmountCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InfoLabel(
                        label: "Type",
                        labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        child: ComboBox<String>(
                          value: firstPaymentType,
                          isExpanded: true,
                          items: ['Cash', 'Online', 'Cheque', 'Bank Transfer'].map((t) => ComboBoxItem<String>(value: t, child: Text(t, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                          onChanged: (v) { if (v != null) setDialogState(() => firstPaymentType = v); },
                        ),
                      ),
                    )),
                  ]),
                  if (firstPaymentType != 'Cash')
                    _saleEditField("Account / Cheque Number", firstPaymentAccCtrl),
                ]),
              ),
            ]),
          ),
          actions: [
            Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
            FilledButton(
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
              onPressed: () {
                if (selectedCarName == null || selectedBuyerName == null || selectedSellerName == null || priceCtrl.text.isEmpty) return;
                final car = selectedCar!;
                final buyer = selectedBuyer!;
                final seller = selectedSeller!;
                final totalPrice = int.tryParse(priceCtrl.text) ?? 0;
                final firstAmount = int.tryParse(firstPaymentAmountCtrl.text) ?? 0;
                final now = DateTime.now();
                final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                final invoiceNo = "INV-${(_sales.length + 1).toString().padLeft(4, '0')}";

                final newSale = <String, dynamic>{
                  'invoiceNo': invoiceNo,
                  'car': car['name'],
                  'carDetails': {'make': car['make'], 'model': car['model'], 'year': car['year'], 'color': car['color'], 'regNo': car['regNo'], 'chassisNo': car['chassisNo'], 'engineNo': car['engineNo']},
                  'buyer': buyer['name'],
                  'buyerPhone': buyer['phone'],
                  'buyerCnic': buyer['cnic'],
                  'buyerAddress': buyer['address'],
                  'seller': seller['name'],
                  'sellerPhone': seller['phone'],
                  'sellerCnic': seller['cnic'],
                  'sellerAddress': seller['address'],
                  'totalPrice': totalPrice,
                  'saleDate': dateStr,
                  'payments': <Map<String, dynamic>>[],
                };
                if (firstAmount > 0) {
                  (newSale['payments'] as List).add({'amount': firstAmount, 'type': firstPaymentType, 'date': dateStr, 'accNo': firstPaymentAccCtrl.text});
                }
                setState(() => _sales.insert(0, newSale));
                Navigator.pop(ctx);
              },
              child: const Text("Create Sale", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════
  //  ADD PAYMENT DIALOG
  // ═══════════════════════════════════════════════
  void _showAddPaymentDialog(Map<String, dynamic> sale) {
    final idx = _sales.indexOf(sale);
    if (idx == -1) return;
    final amountCtrl = TextEditingController();
    final accCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}");
    String payType = 'Cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: Text("Add Payment \u2014 ${sale['invoiceNo']}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 440),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Total: ${_formatPrice(sale['totalPrice'])}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                Text("Paid: ${_formatPrice(_totalPaid(sale))}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("Remaining", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                Text(_formatPrice(_remaining(sale)), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: _remaining(sale) > 0 ? AppTheme.warning : AppTheme.success)),
              ]),
            ]),
          ),
          _saleEditField("Amount (Rs)", amountCtrl),
          Row(children: [
            Expanded(child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InfoLabel(
                label: "Payment Type",
                labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                child: ComboBox<String>(
                  value: payType,
                  isExpanded: true,
                  items: ['Cash', 'Online', 'Cheque', 'Bank Transfer'].map((t) => ComboBoxItem<String>(value: t, child: Text(t, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                  onChanged: (v) { if (v != null) setDialogState(() => payType = v); },
                ),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: _saleEditField("Date (YYYY-MM-DD)", dateCtrl)),
          ]),
          if (payType != 'Cash')
            _saleEditField("Account / Cheque Number", accCtrl),
        ]),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.success)),
            onPressed: () {
              final amount = int.tryParse(amountCtrl.text) ?? 0;
              if (amount <= 0) return;
              setState(() {
                (_sales[idx]['payments'] as List).add({'amount': amount, 'type': payType, 'date': dateCtrl.text, 'accNo': accCtrl.text});
              });
              Navigator.pop(ctx);
            },
            child: const Text("Add Payment", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
        ],
      )),
    );
  }

  // ═══════════════════════════════════════════════
  //  REMOVE SALE DIALOG
  // ═══════════════════════════════════════════════
  void _showRemoveSaleDialog(Map<String, dynamic> sale) {
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Remove Sale", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Are you sure you want to remove this sale record?", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.error.withOpacity(0.2))),
            child: Row(children: [
              Icon(FluentIcons.warning, size: 16, color: AppTheme.error),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("${sale['invoiceNo']} \u2014 ${sale['car']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text("Buyer: ${sale['buyer']} | ${_formatPrice(sale['totalPrice'])}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              ])),
            ]),
          ),
        ]),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: () { setState(() => _sales.remove(sale)); Navigator.pop(ctx); },
            child: const Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  INVOICE DIALOG
  // ═══════════════════════════════════════════════
  void _showInvoiceDialog(Map<String, dynamic> sale) {
    final paid = _totalPaid(sale);
    final rem = _remaining(sale);
    final carD = sale['carDetails'] as Map<String, dynamic>;
    final payments = sale['payments'] as List;
    final latestPayment = payments.isNotEmpty ? payments.last as Map : null;

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(children: [
          Icon(FluentIcons.print, size: 18, color: AppTheme.primary),
          const SizedBox(width: 8),
          const Text("Invoice", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(sale['invoiceNo'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ),
        ]),
        constraints: const BoxConstraints(maxWidth: 620),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Column(children: [
              const Text("INAM MOTORS", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
              const SizedBox(height: 2),
              Text("Car Showroom & Dealership", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              Container(height: 2, width: 200, color: AppTheme.primary),
            ])),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Invoice #: ${sale['invoiceNo']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text("Date: ${sale['saleDate']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
            ]),
            const SizedBox(height: 16),
            _invoiceSectionHeader("Car Details"),
            _invoiceBlock([
              _invoiceRow("Car Name", "${carD['model']} (${carD['year']})"),
              _invoiceRow("Brand / Make", carD['make'] ?? ''),
              _invoiceRow("Reg Number", carD['regNo'] ?? ''),
              _invoiceRow("Color", carD['color'] ?? ''),
              _invoiceRow("Engine No", carD['engineNo'] ?? ''),
              _invoiceRow("Chassis No", carD['chassisNo'] ?? ''),
            ]),
            _invoiceSectionHeader("Buyer Details"),
            _invoiceBlock([
              _invoiceRow("Name", sale['buyer']),
              _invoiceRow("Phone", sale['buyerPhone']),
              _invoiceRow("NIC", sale['buyerCnic']),
              _invoiceRow("Address", sale['buyerAddress']),
            ]),
            _invoiceSectionHeader("Seller Details"),
            _invoiceBlock([
              _invoiceRow("Name", sale['seller']),
              _invoiceRow("Phone", sale['sellerPhone']),
              _invoiceRow("NIC", sale['sellerCnic']),
              _invoiceRow("Address", sale['sellerAddress']),
            ]),
            _invoiceSectionHeader("Payment Details"),
            _invoiceBlock([
              _invoiceRow("Total Price", _formatFullPrice(sale['totalPrice'])),
              _invoiceRow("Advance / Paid", _formatFullPrice(paid)),
              _invoiceRow("Remaining Amount", _formatFullPrice(rem)),
              if (latestPayment != null) ...[
                _invoiceRow("Payment Type", latestPayment['type'] ?? ''),
                if ((latestPayment['accNo'] ?? '').toString().isNotEmpty)
                  _invoiceRow("Acc / Cheque No", latestPayment['accNo']),
              ],
            ]),
            Container(height: 1, color: AppTheme.divider, margin: const EdgeInsets.symmetric(vertical: 8)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(children: [
                Container(width: 150, height: 1, color: AppTheme.textMuted),
                const SizedBox(height: 4),
                Text("Buyer's Signature", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
              ]),
              Column(children: [
                Container(width: 150, height: 1, color: AppTheme.textMuted),
                const SizedBox(height: 4),
                Text("Seller's Signature", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
              ]),
            ]),
            const SizedBox(height: 10),
            Center(child: Text("Showroom Copy / Customer Copy", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1))),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Close", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () => Navigator.pop(ctx),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(FluentIcons.print, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text("Print / Save PDF", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  WHATSAPP REMINDER
  // ═══════════════════════════════════════════════
  void _showWhatsAppDialog(Map<String, dynamic> sale) {
    final msg = "Assalam o Alaikum ${sale['buyer']},\n\nThis is a gentle reminder from Inam Motors regarding your account for ${sale['car']}.\n\nTotal: ${_formatPrice(sale['totalPrice'])}\nPaid: ${_formatPrice(_totalPaid(sale))}\nRemaining: ${_formatPrice(_remaining(sale))}\n\nKindly make the payment at your earliest convenience.\n\nThank you,\nInam Motors";

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(children: [
          Icon(FluentIcons.chat, size: 18, color: AppTheme.success),
          const SizedBox(width: 8),
          const Text("WhatsApp Reminder", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        ]),
        constraints: const BoxConstraints(maxWidth: 500),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text("To: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
            Text("${sale['buyer']} (${sale['buyerPhone']})", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
            child: Text(msg, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary, height: 1.5)),
          ),
        ]),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.success)),
            onPressed: () => Navigator.pop(ctx),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(FluentIcons.chat, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text("Copy & Send", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  UI HELPERS
  // ═══════════════════════════════════════════════
  Widget _saleEditField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoLabel(
        label: label,
        labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        child: TextBox(
          controller: ctrl,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
          decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider))),
        ),
      ),
    );
  }

  Widget _invoiceSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
    );
  }

  Widget _invoiceBlock(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Column(children: children),
    );
  }

  Widget _invoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
      ]),
    );
  }

  Color _payTypeColor(String type) {
    switch (type) {
      case 'Cash': return AppTheme.success;
      case 'Online': return AppTheme.info;
      case 'Cheque': return AppTheme.warning;
      case 'Bank Transfer': return AppTheme.primary;
      default: return AppTheme.textSecondary;
    }
  }

  // ═══════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;
      final isMedium = constraints.maxWidth < 1000;

      return ScaffoldPage.scrollable(
        padding: EdgeInsets.all(isNarrow ? 16 : 28),
        children: [
          // Header
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Sales & Payments", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Ledger of all sales, payment history & invoices", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
            ])),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
              onPressed: _showAddSaleDialog,
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(FluentIcons.add, size: 14, color: Colors.white),
                SizedBox(width: 8),
                Text("New Sale", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ]),
          const SizedBox(height: 24),

          // Stats
          if (isNarrow)
            Column(children: [
              Row(children: [
                _buildStat("Total Sales", _formatPrice(_totalSalesValue), FluentIcons.money, AppTheme.primary),
                const SizedBox(width: 12),
                _buildStat("Received", _formatPrice(_totalReceived), FluentIcons.check_mark, AppTheme.success),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStat("Pending", _formatPrice(_totalPending), FluentIcons.clock, AppTheme.warning),
                const SizedBox(width: 12),
                _buildStat("Active", "$_activeCount", FluentIcons.sync_folder, AppTheme.error),
              ]),
            ])
          else
            Row(children: [
              _buildStat("Total Sales", _formatPrice(_totalSalesValue), FluentIcons.money, AppTheme.primary),
              const SizedBox(width: 16),
              _buildStat("Received", _formatPrice(_totalReceived), FluentIcons.check_mark, AppTheme.success),
              const SizedBox(width: 16),
              _buildStat("Pending", _formatPrice(_totalPending), FluentIcons.clock, AppTheme.warning),
              const SizedBox(width: 16),
              _buildStat("Active Accounts", "$_activeCount", FluentIcons.sync_folder, AppTheme.info),
            ]),
          const SizedBox(height: 24),

          // Toolbar
          if (isNarrow)
            Column(children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                _buildTabChip("All", _sales.length),
                const SizedBox(width: 8),
                _buildTabChip("Active", _activeCount),
                const SizedBox(width: 8),
                _buildTabChip("Completed", _completedCount),
              ])),
            ])
          else
            Row(children: [
              Expanded(flex: 3, child: _buildSearchBar()),
              const SizedBox(width: 16),
              _buildTabChip("All", _sales.length),
              const SizedBox(width: 8),
              _buildTabChip("Active", _activeCount),
              const SizedBox(width: 8),
              _buildTabChip("Completed", _completedCount),
            ]),
          const SizedBox(height: 12),
          Text("${_filtered.length} of ${_sales.length} sales", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 12),

          // Sale cards
          ..._filtered.asMap().entries.map((entry) => _buildSaleCard(entry.value, entry.key, isNarrow, isMedium)),
          if (_filtered.isEmpty) _buildEmpty(),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  // ═══════════════════════════════════════════════
  //  SALE CARD
  // ═══════════════════════════════════════════════
  Widget _buildSaleCard(Map<String, dynamic> sale, int index, bool isNarrow, bool isMedium) {
    final paid = _totalPaid(sale);
    final rem = _remaining(sale);
    final status = _saleStatus(sale);
    final progress = sale['totalPrice'] > 0 ? paid / (sale['totalPrice'] as int) : 0.0;
    final statusColor = status == 'Completed' ? AppTheme.success : AppTheme.warning;
    final isExpanded = _expandedSaleIndex == index;
    final payments = sale['payments'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isExpanded ? AppTheme.primary.withOpacity(0.3) : AppTheme.divider),
      ),
      child: Column(children: [
        // Card header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Top row
            Row(children: [
              Text(sale['invoiceNo'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                child: Text(status, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
              ),
              const SizedBox(width: 8),
              Text(sale['saleDate'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              const Spacer(),
              if (status == 'Active')
                Tooltip(message: "WhatsApp Reminder", child: IconButton(icon: Icon(FluentIcons.chat, size: 14, color: AppTheme.success), onPressed: () => _showWhatsAppDialog(sale))),
              Tooltip(message: "Generate Invoice", child: IconButton(icon: const Icon(FluentIcons.print, size: 14, color: AppTheme.primary), onPressed: () => _showInvoiceDialog(sale))),
              Tooltip(message: "Remove Sale", child: IconButton(icon: Icon(FluentIcons.delete, size: 14, color: AppTheme.error.withOpacity(0.7)), onPressed: () => _showRemoveSaleDialog(sale))),
              IconButton(
                icon: Icon(isExpanded ? FluentIcons.chevron_up : FluentIcons.chevron_down, size: 12, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _expandedSaleIndex = isExpanded ? null : index),
              ),
            ]),
            const SizedBox(height: 12),

            // Car & buyer info
            if (isNarrow)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)), child: const Icon(FluentIcons.car, size: 18, color: AppTheme.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sale['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text("${(sale['carDetails'] as Map)['regNo']} \u2022 ${(sale['carDetails'] as Map)['color']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
                  ])),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(FluentIcons.contact, size: 12, color: AppTheme.info),
                  const SizedBox(width: 6),
                  Text("Buyer: ${sale['buyer']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.info)),
                  const Spacer(),
                  Text("Seller: ${sale['seller']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary)),
                ]),
              ])
            else
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)), child: const Icon(FluentIcons.car, size: 20, color: AppTheme.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sale['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text("${(sale['carDetails'] as Map)['make']} ${(sale['carDetails'] as Map)['model']} | ${(sale['carDetails'] as Map)['regNo']} | ${(sale['carDetails'] as Map)['color']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(children: [
                    Icon(FluentIcons.contact, size: 12, color: AppTheme.info),
                    const SizedBox(width: 4),
                    Text(sale['buyer'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.info)),
                  ]),
                  const SizedBox(height: 2),
                  Text("Seller: ${sale['seller']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary)),
                ]),
              ]),

            const SizedBox(height: 14),

            // Progress bar
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Payment Progress", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              Text("${(progress * 100).toInt()}%", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: progress >= 1.0 ? AppTheme.success : AppTheme.primary)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(height: 8, child: ProgressBar(value: progress * 100, backgroundColor: AppTheme.divider, activeColor: progress >= 1.0 ? AppTheme.success : AppTheme.primary)),
            ),
            const SizedBox(height: 12),

            // Amount summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
              child: isMedium
                  ? Column(children: [
                      Row(children: [_buildAmountItem("Total Price", _formatPrice(sale['totalPrice']), AppTheme.textPrimary), _buildAmountItem("Total Paid", _formatPrice(paid), AppTheme.success)]),
                      const SizedBox(height: 10),
                      Row(children: [_buildAmountItem("Remaining", _formatPrice(rem), rem > 0 ? AppTheme.warning : AppTheme.success), _buildAmountItem("Payments", "${payments.length}", AppTheme.info)]),
                    ])
                  : Row(children: [
                      _buildAmountItem("Total Price", _formatPrice(sale['totalPrice']), AppTheme.textPrimary),
                      _buildAmountItem("Total Paid", _formatPrice(paid), AppTheme.success),
                      _buildAmountItem("Remaining", _formatPrice(rem), rem > 0 ? AppTheme.warning : AppTheme.success),
                      _buildAmountItem("Payments", "${payments.length}", AppTheme.info),
                    ]),
            ),

            // Add payment button
            if (status == 'Active') ...[
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: FilledButton(
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.success), shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8))),
                onPressed: () => _showAddPaymentDialog(sale),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(FluentIcons.add, size: 12, color: Colors.white), SizedBox(width: 6), Text("Add Payment", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))]),
              )),
            ],
          ]),
        ),

        // Expanded payment ledger
        if (isExpanded) Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.background, border: Border(top: BorderSide(color: AppTheme.divider))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(FluentIcons.money, size: 14, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text("Payment History", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const Spacer(),
              Text("${payments.length} payment(s)", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
            ]),
            const SizedBox(height: 12),

            // Table header
            if (!isNarrow)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(6)),
                child: Row(children: [
                  SizedBox(width: 30, child: Text("#", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                  Expanded(flex: 2, child: Text("Date", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                  Expanded(flex: 2, child: Text("Type", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                  Expanded(flex: 3, child: Text("Acc / Cheque No", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                  Expanded(flex: 2, child: Text("Amount", textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                ]),
              ),

            if (payments.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text("No payments recorded yet", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)))),

            ...payments.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value as Map;
              if (isNarrow) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(6)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("#${i + 1}  ${p['date']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: _payTypeColor(p['type']).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(p['type'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: _payTypeColor(p['type']))),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      if ((p['accNo'] ?? '').toString().isNotEmpty) Text(p['accNo'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)) else const SizedBox(),
                      Text(_formatPrice(p['amount']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.success)),
                    ]),
                  ]),
                );
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.5)))),
                child: Row(children: [
                  SizedBox(width: 30, child: Text("${i + 1}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary))),
                  Expanded(flex: 2, child: Text(p['date'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary))),
                  Expanded(flex: 2, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _payTypeColor(p['type']).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(p['type'], textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: _payTypeColor(p['type']))),
                  )),
                  Expanded(flex: 3, child: Text((p['accNo'] ?? '').toString().isNotEmpty ? p['accNo'] : '\u2014', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary))),
                  Expanded(flex: 2, child: Text(_formatPrice(p['amount']), textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.success))),
                ]),
              );
            }),

            // Running totals
            if (payments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Total Paid", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  Text(_formatPrice(paid), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.success)),
                ]),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: (rem > 0 ? AppTheme.warning : AppTheme.success).withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Remaining", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  Text(_formatPrice(rem), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w800, color: rem > 0 ? AppTheme.warning : AppTheme.success)),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════
  Widget _buildAmountItem(String label, String value, Color valueColor) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
    ]));
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
      child: TextBox(
        placeholder: "Search by buyer, car, invoice or seller...",
        placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted),
        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
        prefix: Padding(padding: const EdgeInsets.only(left: 10), child: Icon(FluentIcons.search, size: 14, color: AppTheme.textMuted)),
        decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.transparent))),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildTabChip(String label, int count) {
    final sel = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: sel ? AppTheme.primary : AppTheme.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textPrimary)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: sel ? Colors.white.withOpacity(0.2) : AppTheme.background, borderRadius: BorderRadius.circular(10)),
            child: Text("$count", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.textSecondary)),
          ),
        ]),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 12),
        Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        ])),
      ]),
    ));
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(FluentIcons.search, size: 32, color: AppTheme.primary)),
        const SizedBox(height: 16),
        Text("No sales found", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text("Try adjusting your search or filters", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
      ])),
    );
  }
}

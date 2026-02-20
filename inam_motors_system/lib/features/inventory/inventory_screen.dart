import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isGridView = true;
  String _sortBy = 'Newest';
  int? _expandedIndex;

  final List<Map<String, dynamic>> _cars = [
    {
      'name': 'Toyota Grande',
      'make': 'Toyota',
      'model': 'Grande',
      'year': 2024,
      'color': 'White',
      'price': 8500000,
      'regNo': 'LEA-7421',
      'status': 'Available',
      'buyer': '',
      'mileage': '12,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'JTDBR32E-860045123',
      'engineNo': '2ZR-FE-8924561',
      'investor': 'Muhammad Inam',
      'fileHandedOver': true,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front', 'Back', 'Interior'],
      'carExpenses': [
        {'title': 'Paint Job', 'amount': 35000, 'date': '2026-01-20'},
        {'title': 'Interior Clean', 'amount': 8000, 'date': '2026-01-22'},
      ],
    },
    {
      'name': 'Honda Civic',
      'make': 'Honda',
      'model': 'Civic',
      'year': 2023,
      'color': 'Black',
      'price': 7200000,
      'regNo': 'LHR-5532',
      'status': 'Sold',
      'buyer': 'Ahmed Khan',
      'mileage': '25,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'MRHGM66-560089745',
      'engineNo': 'R18Z1-7756231',
      'investor': 'Tariq Mehmood',
      'fileHandedOver': true,
      'smartCardHandedOver': true,
      'numberPlateHandedOver': true,
      'photos': ['Front', 'Back'],
      'carExpenses': [
        {'title': 'Engine Repair', 'amount': 85000, 'date': '2026-01-15'},
      ],
    },
    {
      'name': 'Kia Sportage',
      'make': 'Kia',
      'model': 'Sportage Alpha',
      'year': 2022,
      'color': 'Red',
      'price': 9500000,
      'regNo': 'ISB-3918',
      'status': 'Booked',
      'buyer': 'Usman Ali',
      'mileage': '18,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'KNAPH81-220056789',
      'engineNo': 'G4FJ-2204587',
      'investor': 'Muhammad Inam',
      'fileHandedOver': false,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front', 'Interior'],
      'carExpenses': [],
    },
    {
      'name': 'Suzuki Cultus',
      'make': 'Suzuki',
      'model': 'Cultus VXL',
      'year': 2024,
      'color': 'Silver',
      'price': 3800000,
      'regNo': 'LEA-1105',
      'status': 'Available',
      'buyer': '',
      'mileage': '5,000 km',
      'fuel': 'Petrol',
      'transmission': 'Manual',
      'chassisNo': 'MBJHA36-240012345',
      'engineNo': 'K10B-2401234',
      'investor': 'Kashif Ali',
      'fileHandedOver': true,
      'smartCardHandedOver': true,
      'numberPlateHandedOver': true,
      'photos': ['Front', 'Back', 'Interior'],
      'carExpenses': [
        {'title': 'AC Service', 'amount': 5000, 'date': '2026-02-01'},
      ],
    },
    {
      'name': 'Hyundai Tucson',
      'make': 'Hyundai',
      'model': 'Tucson GLS',
      'year': 2022,
      'color': 'Grey',
      'price': 11000000,
      'regNo': 'LHR-8890',
      'status': 'Available',
      'buyer': '',
      'mileage': '30,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'KMHJN81-220098765',
      'engineNo': 'G4FP-2209871',
      'investor': 'Tariq Mehmood',
      'fileHandedOver': false,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front'],
      'carExpenses': [
        {'title': 'Tyre Change', 'amount': 48000, 'date': '2026-01-10'},
        {'title': 'Bumper Repair', 'amount': 25000, 'date': '2026-01-18'},
      ],
    },
    {
      'name': 'MG HS',
      'make': 'MG',
      'model': 'HS Essence',
      'year': 2024,
      'color': 'White',
      'price': 9800000,
      'regNo': 'LEA-6677',
      'status': 'Sold',
      'buyer': 'Zain ul Abideen',
      'mileage': '8,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'LSJWB48-240076543',
      'engineNo': '15S4G-2406543',
      'investor': 'Muhammad Inam',
      'fileHandedOver': true,
      'smartCardHandedOver': true,
      'numberPlateHandedOver': true,
      'photos': ['Front', 'Back', 'Interior'],
      'carExpenses': [],
    },
    {
      'name': 'Changan Alsvin',
      'make': 'Changan',
      'model': 'Alsvin Lumiere',
      'year': 2024,
      'color': 'Blue',
      'price': 4600000,
      'regNo': 'MUL-2243',
      'status': 'Available',
      'buyer': '',
      'mileage': '2,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'LSCGB54-240034567',
      'engineNo': 'JL473Q5-2403456',
      'investor': 'Kashif Ali',
      'fileHandedOver': true,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front', 'Back'],
      'carExpenses': [
        {'title': 'Detailing', 'amount': 12000, 'date': '2026-02-03'},
      ],
    },
    {
      'name': 'Toyota Corolla',
      'make': 'Toyota',
      'model': 'Corolla Altis X',
      'year': 2024,
      'color': 'Silver',
      'price': 6800000,
      'regNo': 'LEA-9034',
      'status': 'Available',
      'buyer': '',
      'mileage': '15,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'JTDKR32E-240067890',
      'engineNo': '1NZ-FE-2406789',
      'investor': 'Muhammad Inam',
      'fileHandedOver': false,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front', 'Interior'],
      'carExpenses': [],
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    var list = _cars.where((c) {
      if (_selectedFilter != 'All' && c['status'] != _selectedFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return c['name'].toString().toLowerCase().contains(q) ||
            c['make'].toString().toLowerCase().contains(q) ||
            c['chassisNo'].toString().toLowerCase().contains(q) ||
            c['engineNo'].toString().toLowerCase().contains(q) ||
            c['investor'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();

    if (_sortBy == 'Price: High') list.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    if (_sortBy == 'Price: Low') list.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    if (_sortBy == 'Newest') list.sort((a, b) => (b['year'] as int).compareTo(a['year'] as int));

    return list;
  }

  String _formatPrice(int price) {
    if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return 'Rs ${(price / 1000).toStringAsFixed(0)}K';
    return 'Rs $price';
  }

  int get _availableCount => _cars.where((c) => c['status'] == 'Available').length;
  int get _soldCount => _cars.where((c) => c['status'] == 'Sold').length;
  int get _bookedCount => _cars.where((c) => c['status'] == 'Booked').length;
  int get _totalCarExpenses => _cars.fold(0, (s, c) => s + ((c['carExpenses'] as List).fold(0, (ss, e) => (ss) + ((e as Map)['amount'] as int))));

  void _showAddCarDialog() {
    final nameCtrl = TextEditingController();
    final makeCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: '2024');
    final colorCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final regNoCtrl = TextEditingController();
    final mileageCtrl = TextEditingController();
    final chassisCtrl = TextEditingController();
    final engineCtrl = TextEditingController();
    final investorCtrl = TextEditingController();
    String selectedFuel = 'Petrol';
    String selectedTransmission = 'Automatic';
    bool fileHanded = false;
    bool smartCardHanded = false;
    bool plateHanded = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: const Text("Add New Car", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 560),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: _editField("Car Name", nameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Make", makeCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Model", modelCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Year", yearCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Reg No", regNoCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Color", colorCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Price (Rs)", priceCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Mileage", mileageCtrl)),
            ]),
            Row(children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Fuel Type",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedFuel,
                    isExpanded: true,
                    items: ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedFuel = v); },
                  ),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Transmission",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedTransmission,
                    isExpanded: true,
                    items: ['Automatic', 'Manual'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedTransmission = v); },
                  ),
                ),
              )),
            ]),
            _editField("Chassis No", chassisCtrl),
            _editField("Engine No", engineCtrl),
            _editField("Investor", investorCtrl),
            const SizedBox(height: 8),
            Row(children: [
              Checkbox(
                checked: fileHanded,
                onChanged: (v) => setDialogState(() => fileHanded = v ?? false),
                content: Text("File", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              const SizedBox(width: 16),
              Checkbox(
                checked: smartCardHanded,
                onChanged: (v) => setDialogState(() => smartCardHanded = v ?? false),
                content: Text("Smart Card", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              const SizedBox(width: 16),
              Checkbox(
                checked: plateHanded,
                onChanged: (v) => setDialogState(() => plateHanded = v ?? false),
                content: Text("Number Plate", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
            ]),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              setState(() {
                _cars.add({
                  'name': nameCtrl.text,
                  'make': makeCtrl.text,
                  'model': modelCtrl.text,
                  'year': int.tryParse(yearCtrl.text) ?? 2024,
                  'color': colorCtrl.text,
                  'price': int.tryParse(priceCtrl.text) ?? 0,
                  'regNo': regNoCtrl.text,
                  'status': 'Available',
                  'buyer': '',
                  'mileage': mileageCtrl.text,
                  'fuel': selectedFuel,
                  'transmission': selectedTransmission,
                  'chassisNo': chassisCtrl.text,
                  'engineNo': engineCtrl.text,
                  'investor': investorCtrl.text,
                  'fileHandedOver': fileHanded,
                  'smartCardHandedOver': smartCardHanded,
                  'numberPlateHandedOver': plateHanded,
                  'photos': <String>[],
                  'carExpenses': <Map<String, dynamic>>[],
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text("Add Car", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _showRemoveCarDialog(Map<String, dynamic> car) {
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Remove Car", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Are you sure you want to remove this car from inventory?", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.error.withOpacity(0.2))),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(FluentIcons.car, size: 18, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("${car['name']} (${car['year']})", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text("${car['color']} \u2022 ${car['transmission']} \u2022 ${_formatPrice(car['price'])}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              ])),
            ]),
          ),
          const SizedBox(height: 8),
          Text("This action cannot be undone.", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.error)),
        ]),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: () {
              setState(() => _cars.remove(car));
              Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditCarDialog(Map<String, dynamic> car) {
    final index = _cars.indexOf(car);
    if (index == -1) return;

    final nameCtrl = TextEditingController(text: car['name']);
    final makeCtrl = TextEditingController(text: car['make']);
    final modelCtrl = TextEditingController(text: car['model']);
    final yearCtrl = TextEditingController(text: car['year'].toString());
    final colorCtrl = TextEditingController(text: car['color']);
    final priceCtrl = TextEditingController(text: car['price'].toString());
    final mileageCtrl = TextEditingController(text: car['mileage']);
    final chassisCtrl = TextEditingController(text: car['chassisNo']);
    final engineCtrl = TextEditingController(text: car['engineNo']);
    final investorCtrl = TextEditingController(text: car['investor']);
    final regNoCtrl = TextEditingController(text: car['regNo'] ?? '');
    final buyerCtrl = TextEditingController(text: car['buyer'] ?? '');
    String selectedStatus = car['status'];
    String selectedFuel = car['fuel'];
    String selectedTransmission = car['transmission'];
    bool fileHanded = car['fileHandedOver'];
    bool smartCardHanded = car['smartCardHandedOver'] ?? false;
    bool plateHanded = car['numberPlateHandedOver'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: const Text("Edit Car Details", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 560),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: _editField("Car Name", nameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Make", makeCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Model", modelCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Year", yearCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Color", colorCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Price (Rs)", priceCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Mileage", mileageCtrl)),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Status",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: ['Available', 'Sold', 'Booked'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedStatus = v); },
                  ),
                ),
              )),
            ]),
            Row(children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Fuel Type",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedFuel,
                    isExpanded: true,
                    items: ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedFuel = v); },
                  ),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Transmission",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedTransmission,
                    isExpanded: true,
                    items: ['Automatic', 'Manual'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedTransmission = v); },
                  ),
                ),
              )),
            ]),
            Row(children: [
              Expanded(child: _editField("Reg No", regNoCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Investor", investorCtrl)),
            ]),
            _editField("Chassis No", chassisCtrl),
            _editField("Engine No", engineCtrl),
            if (selectedStatus == 'Sold' || selectedStatus == 'Booked')
              _editField("Buyer Name", buyerCtrl),
            const SizedBox(height: 8),
            Text("Document Tracking", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(children: [
              Checkbox(
                checked: fileHanded,
                onChanged: (v) => setDialogState(() => fileHanded = v ?? false),
                content: Text("File", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              const SizedBox(width: 16),
              Checkbox(
                checked: smartCardHanded,
                onChanged: (v) => setDialogState(() => smartCardHanded = v ?? false),
                content: Text("Smart Card", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              const SizedBox(width: 16),
              Checkbox(
                checked: plateHanded,
                onChanged: (v) => setDialogState(() => plateHanded = v ?? false),
                content: Text("Number Plate", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
            ]),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              setState(() {
                _cars[index] = {
                  ...car,
                  'name': nameCtrl.text,
                  'make': makeCtrl.text,
                  'model': modelCtrl.text,
                  'year': int.tryParse(yearCtrl.text) ?? car['year'],
                  'color': colorCtrl.text,
                  'price': int.tryParse(priceCtrl.text) ?? car['price'],
                  'mileage': mileageCtrl.text,
                  'status': selectedStatus,
                  'fuel': selectedFuel,
                  'transmission': selectedTransmission,
                  'chassisNo': chassisCtrl.text,
                  'engineNo': engineCtrl.text,
                  'investor': investorCtrl.text,
                  'regNo': regNoCtrl.text,
                  'buyer': buyerCtrl.text,
                  'fileHandedOver': fileHanded,
                  'smartCardHandedOver': smartCardHanded,
                  'numberPlateHandedOver': plateHanded,
                };
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save Changes", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
        ],
      )),
    );
  }

  Widget _editField(String label, TextEditingController ctrl) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;
      final isMedium = constraints.maxWidth < 1000;

      return ScaffoldPage.scrollable(
        padding: EdgeInsets.all(isNarrow ? 16 : 28),
        children: [
          // HEADER
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Inventory", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Complete car profiles with documents, expenses & tracking", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
            ])),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
              onPressed: () => _showAddCarDialog(),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(FluentIcons.add, size: 14, color: Colors.white),
                SizedBox(width: 8),
                Text("Add New Car", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ]),

          const SizedBox(height: 24),

          // STAT CARDS
          if (isNarrow)
            Column(children: [
              Row(children: [
                _buildStat("Total Cars", "${_cars.length}", FluentIcons.car, AppTheme.primary),
                const SizedBox(width: 12),
                _buildStat("Available", "$_availableCount", FluentIcons.check_mark, AppTheme.success),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStat("Sold", "$_soldCount", FluentIcons.completed, AppTheme.textMuted),
                const SizedBox(width: 12),
                _buildStat("Car Expenses", _formatPrice(_totalCarExpenses), FluentIcons.repair, AppTheme.warning),
              ]),
            ])
          else
            Row(children: [
              _buildStat("Total Cars", "${_cars.length}", FluentIcons.car, AppTheme.primary),
              const SizedBox(width: 16),
              _buildStat("Available", "$_availableCount", FluentIcons.check_mark, AppTheme.success),
              const SizedBox(width: 16),
              _buildStat("Sold", "$_soldCount", FluentIcons.completed, AppTheme.textMuted),
              const SizedBox(width: 16),
              _buildStat("Car Expenses", _formatPrice(_totalCarExpenses), FluentIcons.repair, AppTheme.warning),
            ]),

          const SizedBox(height: 24),

          // TOOLBAR
          if (isNarrow)
            Column(children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _buildFilterChip("All", _cars.length),
                  const SizedBox(width: 8),
                  _buildFilterChip("Available", _availableCount),
                  const SizedBox(width: 8),
                  _buildFilterChip("Sold", _soldCount),
                  const SizedBox(width: 8),
                  _buildFilterChip("Booked", _bookedCount),
                ]),
              ),
            ])
          else
            Row(children: [
              Expanded(flex: 3, child: _buildSearchBar()),
              const SizedBox(width: 16),
              _buildFilterChip("All", _cars.length),
              const SizedBox(width: 8),
              _buildFilterChip("Available", _availableCount),
              const SizedBox(width: 8),
              _buildFilterChip("Sold", _soldCount),
              const SizedBox(width: 8),
              _buildFilterChip("Booked", _bookedCount),
              const SizedBox(width: 12),
              ComboBox<String>(
                value: _sortBy,
                items: ['Newest', 'Price: High', 'Price: Low'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _sortBy = v); },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(_isGridView ? FluentIcons.grid_view_medium : FluentIcons.list, size: 16, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ),
            ]),

          const SizedBox(height: 12),
          Text("${_filtered.length} of ${_cars.length} cars", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 12),

          // CAR LIST
          if (_isGridView)
            _buildGridView(isNarrow, isMedium)
          else
            ..._filtered.asMap().entries.map((e) => _buildCarListItem(e.value, e.key, isNarrow)),

          if (_filtered.isEmpty) _buildEmpty(),

          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildGridView(bool isNarrow, bool isMedium) {
    final cols = isNarrow ? 1 : (isMedium ? 2 : 3);
    final items = _filtered;

    return Column(children: [
      for (int i = 0; i < items.length; i += cols)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (int j = 0; j < cols; j++)
              if (i + j < items.length)
                Expanded(child: Padding(
                  padding: EdgeInsets.only(right: j < cols - 1 ? 14 : 0),
                  child: _buildCarCard(items[i + j]),
                ))
              else
                const Expanded(child: SizedBox()),
          ]),
        ),
    ]);
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    final statusColor = _statusColor(car['status']);
    final carExpenses = car['carExpenses'] as List;
    final totalExpense = carExpenses.fold(0, (s, e) => (s) + ((e as Map)['amount'] as int));

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image placeholder with overlays
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppTheme.divider.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Stack(children: [
            Center(child: Icon(FluentIcons.car, size: 40, color: AppTheme.textMuted.withOpacity(0.3))),
            Positioned(top: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(5)),
              child: Text("${car['year']}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
            )),
            Positioned(top: 10, right: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.9), borderRadius: BorderRadius.circular(5)),
              child: Text(car['status'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            )),
            Positioned(bottom: 10, right: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(5)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(FluentIcons.camera, size: 10, color: Colors.white),
                const SizedBox(width: 4),
                Text("${(car['photos'] as List).length}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: Colors.white)),
              ]),
            )),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(car['name'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text("${car['model']} \u2022 ${car['color']} \u2022 ${car['transmission']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 8),

            // Chassis & Engine
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
              child: Column(children: [
                Row(children: [
                  Icon(FluentIcons.number_field, size: 10, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text("Chassis: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                  Flexible(child: Text(car['chassisNo'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(FluentIcons.settings, size: 10, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text("Engine: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                  Flexible(child: Text(car['engineNo'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                ]),
              ]),
            ),

            const SizedBox(height: 10),

            // Investor link
            Row(children: [
              Icon(FluentIcons.people, size: 11, color: AppTheme.info),
              const SizedBox(width: 6),
              Flexible(child: Text("Investor: ${car['investor']}", overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.info))),
            ]),

            const SizedBox(height: 8),

            // Document Tracking
            Row(children: [
              _buildDocCheckbox("File", car['fileHandedOver']),
              const SizedBox(width: 10),
              _buildDocCheckbox("Smart Card", car['smartCardHandedOver'] ?? false),
              const SizedBox(width: 10),
              _buildDocCheckbox("Plate", car['numberPlateHandedOver']),
            ]),

            // Buyer name for Sold cars
            if (car['status'] == 'Sold' && (car['buyer'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.info.withOpacity(0.06), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.info.withOpacity(0.15))),
                child: Row(children: [
                  Icon(FluentIcons.contact, size: 12, color: AppTheme.info),
                  const SizedBox(width: 6),
                  Text("Buyer: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
                  Flexible(child: Text(car['buyer'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.info))),
                ]),
              ),
            ],

            const SizedBox(height: 10),

            // Price + Expense
            Row(children: [
              Expanded(child: Text(_formatPrice(car['price']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary))),
              if (totalExpense > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text("Exp: ${_formatPrice(totalExpense)}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.warning)),
                ),
            ]),

            const SizedBox(height: 12),

            // Action buttons
            Row(children: [
              Expanded(child: Button(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
                ),
                onPressed: () => _showEditCarDialog(car),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(FluentIcons.edit, size: 12),
                  SizedBox(width: 6),
                  Text("Edit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
                ]),
              )),
              const SizedBox(width: 6),
              Expanded(child: Button(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
                ),
                onPressed: () => _showRemoveCarDialog(car),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(FluentIcons.delete, size: 12, color: AppTheme.error),
                  const SizedBox(width: 6),
                  Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error)),
                ]),
              )),
              const SizedBox(width: 6),
              Expanded(child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppTheme.error.withOpacity(0.9)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
                ),
                onPressed: () {},
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(FluentIcons.pdf, size: 12, color: Colors.white),
                  SizedBox(width: 6),
                  Text("PDF", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: Colors.white)),
                ]),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCarListItem(Map<String, dynamic> car, int index, bool isNarrow) {
    final statusColor = _statusColor(car['status']);
    final carExpenses = car['carExpenses'] as List;
    final totalExpense = carExpenses.fold(0, (s, e) => (s) + ((e as Map)['amount'] as int));
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isExpanded ? AppTheme.primary.withOpacity(0.3) : AppTheme.divider),
      ),
      child: Column(children: [
        // Main row
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: AppTheme.divider.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              child: Icon(FluentIcons.car, size: 22, color: AppTheme.textMuted.withOpacity(0.5)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(car['name'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                  child: Text(car['status'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ]),
              const SizedBox(height: 4),
              Text("${car['year']} \u2022 ${car['color']} \u2022 ${car['transmission']} \u2022 ${car['mileage']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Row(children: [
                Text("Chassis: ${car['chassisNo']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textSecondary)),
                if (car['regNo'] != null && car['regNo'].toString().isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text("Reg: ${car['regNo']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ],
              ]),
              if (car['status'] == 'Sold' && (car['buyer'] ?? '').toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(children: [
                    Icon(FluentIcons.contact, size: 10, color: AppTheme.info),
                    const SizedBox(width: 4),
                    Text("Buyer: ${car['buyer']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.info)),
                  ]),
                ),
            ])),
            if (!isNarrow) ...[
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_formatPrice(car['price']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                const SizedBox(height: 4),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _buildDocCheckbox("File", car['fileHandedOver']),
                  const SizedBox(width: 6),
                  _buildDocCheckbox("Card", car['smartCardHandedOver'] ?? false),
                  const SizedBox(width: 6),
                  _buildDocCheckbox("Plate", car['numberPlateHandedOver']),
                ]),
              ]),
              const SizedBox(width: 8),
            ],
            Column(children: [
              IconButton(
                icon: Icon(isExpanded ? FluentIcons.chevron_up : FluentIcons.chevron_down, size: 12, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _expandedIndex = isExpanded ? null : index),
              ),
              IconButton(
                icon: const Icon(FluentIcons.edit, size: 12, color: AppTheme.primary),
                onPressed: () => _showEditCarDialog(car),
              ),
              IconButton(
                icon: Icon(FluentIcons.delete, size: 12, color: AppTheme.error.withOpacity(0.7)),
                onPressed: () => _showRemoveCarDialog(car),
              ),
              IconButton(
                icon: const Icon(FluentIcons.pdf, size: 12, color: AppTheme.error),
                onPressed: () {},
              ),
            ]),
          ]),
        ),

        // Expanded details
        if (isExpanded) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border(top: BorderSide(color: AppTheme.divider)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isNarrow)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildDetailRow("Engine No", car['engineNo']),
                  _buildDetailRow("Chassis No", car['chassisNo']),
                  _buildDetailRow("Investor", car['investor']),
                  _buildDetailRow("Fuel", car['fuel']),
                ])
              else
                Row(children: [
                  Expanded(child: _buildDetailRow("Engine No", car['engineNo'])),
                  Expanded(child: _buildDetailRow("Chassis No", car['chassisNo'])),
                  Expanded(child: _buildDetailRow("Investor", car['investor'])),
                  Expanded(child: _buildDetailRow("Fuel", car['fuel'])),
                ]),
              const SizedBox(height: 16),

              // Photo Gallery section
              Text("Photo Gallery", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(children: [
                ...(car['photos'] as List).map((photo) => Container(
                  width: 80, height: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(FluentIcons.camera, size: 16, color: AppTheme.textMuted.withOpacity(0.5)),
                    const SizedBox(height: 4),
                    Text(photo, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, color: AppTheme.textMuted)),
                  ]),
                )),
                Container(
                  width: 80, height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(FluentIcons.add, size: 14, color: AppTheme.primary.withOpacity(0.6)),
                    Text("Upload", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, color: AppTheme.primary.withOpacity(0.6))),
                  ]),
                ),
              ]),

              if (carExpenses.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(children: [
                  Text("Car-Specific Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const Spacer(),
                  Text("Total: ${_formatPrice(totalExpense)}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.warning)),
                ]),
                const SizedBox(height: 8),
                ...carExpenses.map((exp) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Icon(FluentIcons.repair, size: 12, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(child: Text((exp as Map)['title'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary))),
                    Text(_formatPrice(exp['amount']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.warning)),
                    const SizedBox(width: 12),
                    Text(exp['date'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                  ]),
                )),
              ],

              const SizedBox(height: 16),
              Text("Document Tracking", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(children: [
                _buildDocCheck("File", car['fileHandedOver']),
                const SizedBox(width: 20),
                _buildDocCheck("Smart Card", car['smartCardHandedOver'] ?? false),
                const SizedBox(width: 20),
                _buildDocCheck("Number Plate", car['numberPlateHandedOver']),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildDocCheck(String label, bool value) {
    return Row(children: [
      Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: value ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: value ? AppTheme.success : AppTheme.error.withOpacity(0.5)),
        ),
        child: Icon(value ? FluentIcons.check_mark : FluentIcons.cancel, size: 12, color: value ? AppTheme.success : AppTheme.error),
      ),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
      const SizedBox(width: 4),
      Text(value ? "Yes" : "No", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: value ? AppTheme.success : AppTheme.error)),
    ]);
  }

  Widget _buildDocCheckbox(String label, bool value) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: value ? AppTheme.success.withOpacity(0.15) : AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: value ? AppTheme.success : AppTheme.error.withOpacity(0.5), width: 1),
        ),
        child: Icon(value ? FluentIcons.check_mark : FluentIcons.cancel, size: 8, color: value ? AppTheme.success : AppTheme.error),
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
    ]);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
      child: TextBox(
        placeholder: "Search by name, chassis, engine, investor...",
        placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted),
        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
        prefix: Padding(padding: const EdgeInsets.only(left: 10), child: Icon(FluentIcons.search, size: 14, color: AppTheme.textMuted)),
        decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.transparent))),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final sel = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primary : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
        ),
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
    return Expanded(
      child: Container(
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
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(FluentIcons.search, size: 32, color: AppTheme.primary)),
        const SizedBox(height: 16),
        Text("No cars found", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text("Try adjusting your search or filters", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
      ])),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Available': return AppTheme.success;
      case 'Sold': return AppTheme.textMuted;
      case 'Booked': return AppTheme.warning;
      default: return AppTheme.textSecondary;
    }
  }
}

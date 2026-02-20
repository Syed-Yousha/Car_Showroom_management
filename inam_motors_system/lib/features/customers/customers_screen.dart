import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _customers = [
    {'name': 'Ali Hassan', 'phone': '0312-1234567', 'cnic': '35202-1234567-1', 'city': 'Lahore', 'address': '123 Model Town, Lahore', 'totalPurchases': 2, 'totalSpent': 15700000, 'lastPurchase': '2026-02-05', 'type': 'Regular'},
    {'name': 'Ahmed Khan', 'phone': '0300-9876543', 'cnic': '35201-9876543-2', 'city': 'Islamabad', 'address': '45 F-8, Islamabad', 'totalPurchases': 1, 'totalSpent': 7200000, 'lastPurchase': '2026-02-03', 'type': 'New'},
    {'name': 'Usman Ali', 'phone': '0321-5551234', 'cnic': '35203-5551234-3', 'city': 'Karachi', 'address': '78 Clifton Block 5, Karachi', 'totalPurchases': 3, 'totalSpent': 22500000, 'lastPurchase': '2026-02-01', 'type': 'VIP'},
    {'name': 'Bilal Malik', 'phone': '0333-6667890', 'cnic': '35204-6667890-4', 'city': 'Lahore', 'address': '12 Johar Town Phase 2, Lahore', 'totalPurchases': 1, 'totalSpent': 3800000, 'lastPurchase': '2026-01-28', 'type': 'New'},
    {'name': 'Farhan Raza', 'phone': '0345-1112233', 'cnic': '35205-1112233-5', 'city': 'Faisalabad', 'address': '56 D Ground, Faisalabad', 'totalPurchases': 2, 'totalSpent': 17800000, 'lastPurchase': '2026-01-25', 'type': 'Regular'},
    {'name': 'Imran Shah', 'phone': '0301-4445566', 'cnic': '35206-4445566-6', 'city': 'Multan', 'address': '90 Gulberg Colony, Multan', 'totalPurchases': 0, 'totalSpent': 0, 'lastPurchase': '-', 'type': 'Lead'},
    {'name': 'Zain ul Abideen', 'phone': '0311-7778899', 'cnic': '35207-7778899-7', 'city': 'Rawalpindi', 'address': '34 Saddar Bazaar, Rawalpindi', 'totalPurchases': 4, 'totalSpent': 35000000, 'lastPurchase': '2026-01-15', 'type': 'VIP'},
    {'name': 'Hamza Tariq', 'phone': '0322-2223344', 'cnic': '35208-2223344-8', 'city': 'Lahore', 'address': '67 Canal Road, Lahore', 'totalPurchases': 1, 'totalSpent': 4600000, 'lastPurchase': '2026-01-10', 'type': 'New'},
    {'name': 'Saad Qureshi', 'phone': '0334-5556677', 'cnic': '35209-5556677-9', 'city': 'Islamabad', 'address': '22 G-9 Markaz, Islamabad', 'totalPurchases': 0, 'totalSpent': 0, 'lastPurchase': '-', 'type': 'Lead'},
    {'name': 'Waqar Ahmed', 'phone': '0346-8889900', 'cnic': '35210-8889900-0', 'city': 'Peshawar', 'address': '15 University Road, Peshawar', 'totalPurchases': 1, 'totalSpent': 9500000, 'lastPurchase': '2026-01-05', 'type': 'Regular'},
  ];

  List<Map<String, dynamic>> get _filtered {
    return _customers.where((c) {
      if (_selectedFilter != 'All' && c['type'] != _selectedFilter) return false;
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
  int get _regularCount => _customers.where((c) => c['type'] == 'Regular').length;
  int get _newCount => _customers.where((c) => c['type'] == 'New').length;
  int get _leadCount => _customers.where((c) => c['type'] == 'Lead').length;

  String _formatPrice(int price) {
    if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    if (price == 0) return '-';
    return 'Rs $price';
  }

  // Dummy sales data linked to customers for the detail card
  final List<Map<String, dynamic>> _salesData = [
    {'buyer': 'Ali Hassan', 'car': 'Toyota Grande 2024', 'salePrice': 8500000, 'purchasePrice': 7500000, 'discount': 0, 'date': '2026-02-05'},
    {'buyer': 'Ali Hassan', 'car': 'Hyundai Tucson 2022', 'salePrice': 7200000, 'purchasePrice': 6200000, 'discount': 0, 'date': '2025-08-10'},
    {'buyer': 'Ahmed Khan', 'car': 'Honda Civic 2023', 'salePrice': 7200000, 'purchasePrice': 6200000, 'discount': 0, 'date': '2026-02-03'},
    {'buyer': 'Usman Ali', 'car': 'Kia Sportage 2022', 'salePrice': 9500000, 'purchasePrice': 8200000, 'discount': 0, 'date': '2026-02-01'},
    {'buyer': 'Usman Ali', 'car': 'MG HS 2024', 'salePrice': 9800000, 'purchasePrice': 8800000, 'discount': 0, 'date': '2025-10-20'},
    {'buyer': 'Usman Ali', 'car': 'Suzuki Alto 2025', 'salePrice': 3200000, 'purchasePrice': 2800000, 'discount': 0, 'date': '2025-06-15'},
    {'buyer': 'Bilal Malik', 'car': 'Suzuki Cultus 2024', 'salePrice': 3800000, 'purchasePrice': 3200000, 'discount': 100000, 'date': '2026-01-28'},
    {'buyer': 'Farhan Raza', 'car': 'Hyundai Tucson 2022', 'salePrice': 11000000, 'purchasePrice': 9500000, 'discount': 0, 'date': '2026-01-25'},
    {'buyer': 'Farhan Raza', 'car': 'Changan Alsvin 2024', 'salePrice': 6800000, 'purchasePrice': 5800000, 'discount': 0, 'date': '2025-09-10'},
    {'buyer': 'Zain ul Abideen', 'car': 'MG HS 2024', 'salePrice': 9800000, 'purchasePrice': 8800000, 'discount': 0, 'date': '2026-01-15'},
    {'buyer': 'Zain ul Abideen', 'car': 'Toyota Grande 2024', 'salePrice': 8500000, 'purchasePrice': 7500000, 'discount': 0, 'date': '2025-11-01'},
    {'buyer': 'Zain ul Abideen', 'car': 'Honda Civic 2023', 'salePrice': 7200000, 'purchasePrice': 6200000, 'discount': 0, 'date': '2025-07-12'},
    {'buyer': 'Zain ul Abideen', 'car': 'Suzuki Cultus 2024', 'salePrice': 9500000, 'purchasePrice': 8200000, 'discount': 0, 'date': '2025-04-03'},
    {'buyer': 'Hamza Tariq', 'car': 'Changan Alsvin 2024', 'salePrice': 4600000, 'purchasePrice': 3800000, 'discount': 0, 'date': '2026-01-10'},
    {'buyer': 'Waqar Ahmed', 'car': 'Kia Sportage 2022', 'salePrice': 9500000, 'purchasePrice': 8200000, 'discount': 0, 'date': '2026-01-05'},
  ];

  void _showEditCustomerDialog(Map<String, dynamic> c) {
    final idx = _customers.indexOf(c);
    if (idx == -1) return;

    final nameCtrl = TextEditingController(text: c['name']);
    final phoneCtrl = TextEditingController(text: c['phone']);
    final cnicCtrl = TextEditingController(text: c['cnic']);
    final cityCtrl = TextEditingController(text: c['city']);
    final addressCtrl = TextEditingController(text: c['address'] ?? '');
    String selectedType = c['type'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: const Text("Edit Customer", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 480),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _custEditField("Full Name", nameCtrl),
            Row(children: [
              Expanded(child: _custEditField("Phone", phoneCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _custEditField("CNIC", cnicCtrl)),
            ]),
            Row(children: [
              Expanded(child: _custEditField("City", cityCtrl)),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Type",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedType,
                    isExpanded: true,
                    items: ['VIP', 'Regular', 'New', 'Lead'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedType = v); },
                  ),
                ),
              )),
            ]),
            _custEditField("Address", addressCtrl),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              setState(() {
                _customers[idx] = {
                  ...c,
                  'name': nameCtrl.text,
                  'phone': phoneCtrl.text,
                  'cnic': cnicCtrl.text,
                  'city': cityCtrl.text,
                  'address': addressCtrl.text,
                  'type': selectedType,
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

  Widget _custEditField(String label, TextEditingController ctrl) {
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

  void _showRemoveCustomerDialog(Map<String, dynamic> c) {
    final index = _customers.indexOf(c);
    if (index == -1) return;
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Remove Customer", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Text(
          "Are you sure you want to remove ${c['name']}? This action cannot be undone.",
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: () {
              setState(() => _customers.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetailDialog(Map<String, dynamic> c) {
    final customerSales = _salesData.where((s) => s['buyer'] == c['name']).toList();
    int totalSaleValue = 0;
    int totalProfit = 0;
    for (final s in customerSales) {
      totalSaleValue += (s['salePrice'] as int);
      totalProfit += ((s['salePrice'] as int) - (s['purchasePrice'] as int) - (s['discount'] as int));
    }

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(c['name'].toString().substring(0, 1), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primary))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['name'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 16)),
            Text("${c['phone']} \u2022 ${c['city']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
          ])),
        ]),
        constraints: const BoxConstraints(maxWidth: 560),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Summary Stats
            Row(children: [
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Column(children: [
                  Text("${customerSales.length}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  Text("Cars Bought", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                ]),
              )),
              const SizedBox(width: 10),
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.info.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Column(children: [
                  Text(_formatPrice(totalSaleValue), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.info)),
                  Text("Total Sales", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                ]),
              )),
              const SizedBox(width: 10),
              Expanded(child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Column(children: [
                  Text(_formatPrice(totalProfit), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.success)),
                  Text("Profit Earned", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                ]),
              )),
            ]),
            const SizedBox(height: 16),

            // Customer Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
              child: Column(children: [
                _detailRow("CNIC", c['cnic']),
                _detailRow("Address", c['address'] ?? c['city']),
                _detailRow("Type", c['type']),
                _detailRow("Last Purchase", c['lastPurchase']),
              ]),
            ),
            const SizedBox(height: 16),

            // Cars Purchased
            Text("Cars Purchased", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            if (customerSales.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text("No purchase history found", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted))),
              )
            else
              ...customerSales.map((s) {
                final profit = (s['salePrice'] as int) - (s['purchasePrice'] as int) - (s['discount'] as int);
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(FluentIcons.car, size: 16, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      Text("Date: ${s['date']} \u2022 Price: ${_formatPrice(s['salePrice'])}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(_formatPrice(profit), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: profit >= 0 ? AppTheme.success : AppTheme.error)),
                      Text("Profit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, color: AppTheme.textMuted)),
                    ]),
                  ]),
                );
              }),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Close", style: TextStyle(fontFamily: AppTheme.fontFamily))),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;

      return ScaffoldPage.scrollable(
        padding: EdgeInsets.all(isNarrow ? 16 : 28),
        children: [
          // HEADER
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Customers", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Customer database with CNIC, address & purchase history", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
            ])),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
              onPressed: () {},
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(FluentIcons.add, size: 14, color: Colors.white),
                SizedBox(width: 8),
                Text("Add Customer", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ]),

          const SizedBox(height: 24),

          // STATS
          if (isNarrow)
            Column(children: [
              Row(children: [
                _buildStat("Total", "${_customers.length}", FluentIcons.people, AppTheme.primary),
                const SizedBox(width: 12),
                _buildStat("VIP", "$_vipCount", FluentIcons.diamond_user, AppTheme.warning),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStat("Regular", "$_regularCount", FluentIcons.contact, AppTheme.info),
                const SizedBox(width: 12),
                _buildStat("Leads", "$_leadCount", FluentIcons.people_add, AppTheme.success),
              ]),
            ])
          else
            Row(children: [
              _buildStat("Total", "${_customers.length}", FluentIcons.people, AppTheme.primary),
              const SizedBox(width: 16),
              _buildStat("VIP", "$_vipCount", FluentIcons.diamond_user, AppTheme.warning),
              const SizedBox(width: 16),
              _buildStat("Regular", "$_regularCount", FluentIcons.contact, AppTheme.info),
              const SizedBox(width: 16),
              _buildStat("Leads", "$_leadCount", FluentIcons.people_add, AppTheme.success),
            ]),

          const SizedBox(height: 24),

          // SEARCH + FILTERS
          if (isNarrow)
            Column(children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _buildChip("All", _customers.length),
                  const SizedBox(width: 8),
                  _buildChip("VIP", _vipCount),
                  const SizedBox(width: 8),
                  _buildChip("Regular", _regularCount),
                  const SizedBox(width: 8),
                  _buildChip("New", _newCount),
                  const SizedBox(width: 8),
                  _buildChip("Lead", _leadCount),
                ]),
              ),
            ])
          else
            Row(children: [
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
            ]),

          const SizedBox(height: 16),

          Text("Showing ${_filtered.length} of ${_customers.length} customers",
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),

          const SizedBox(height: 12),

          // CUSTOMER LIST
          if (!isNarrow) _buildTableHeader(),
          ..._filtered.map((c) => isNarrow ? _buildCustomerCard(c) : _buildCustomerRow(c)),
          if (_filtered.isEmpty) _buildEmpty(),

          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
      child: TextBox(
        placeholder: "Search by name, phone, CNIC, address...",
        placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted),
        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
        prefix: Padding(padding: const EdgeInsets.only(left: 10), child: Icon(FluentIcons.search, size: 14, color: AppTheme.textMuted)),
        decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.transparent))),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildChip(String label, int count) {
    final sel = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
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

  Color _typeColor(String type) {
    switch (type) {
      case 'VIP': return AppTheme.warning;
      case 'Regular': return AppTheme.info;
      case 'New': return AppTheme.success;
      case 'Lead': return AppTheme.textMuted;
      default: return AppTheme.textSecondary;
    }
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(flex: 2, child: Text("Name", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 130, child: Text("CNIC", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 110, child: Text("Phone", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 70, child: Text("Type", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 80, child: Text("Purchases", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 100, child: Text("Total Spent", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 60),
      ]),
    );
  }

  Widget _buildCustomerRow(Map<String, dynamic> c) {
    final typeColor = _typeColor(c['type']);
    return GestureDetector(
      onTap: () => _showCustomerDetailDialog(c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
        child: Row(children: [
        Expanded(flex: 2, child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(c['name'].toString().substring(0, 1), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primary))),
          ),
          const SizedBox(width: 10),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['name'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Text(c['address'] ?? c['city'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
          ])),
        ])),
        SizedBox(width: 130, child: Text(c['cnic'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
        SizedBox(width: 110, child: Text(c['phone'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary))),
        SizedBox(width: 70, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
          child: Text(c['type'], textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: typeColor)),
        )),
        SizedBox(width: 80, child: Text("${c['totalPurchases']}", textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary))),
        SizedBox(width: 100, child: Text(_formatPrice(c['totalSpent']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
        SizedBox(width: 90, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(icon: Icon(FluentIcons.view, size: 14, color: AppTheme.textSecondary), onPressed: () => _showCustomerDetailDialog(c)),
          IconButton(icon: Icon(FluentIcons.edit, size: 14, color: AppTheme.primary), onPressed: () => _showEditCustomerDialog(c)),
          IconButton(icon: Icon(FluentIcons.delete, size: 14, color: AppTheme.error.withOpacity(0.7)), onPressed: () => _showRemoveCustomerDialog(c)),
        ])),
      ]),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> c) {
    final typeColor = _typeColor(c['type']);
    return GestureDetector(
      onTap: () => _showCustomerDetailDialog(c),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text(c['name'].toString().substring(0, 1), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primary))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c['name'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Text(c['phone'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
              child: Text(c['type'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: typeColor)),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(FluentIcons.edit, size: 14, color: AppTheme.primary),
              onPressed: () => _showEditCustomerDialog(c),
            ),
            IconButton(
              icon: Icon(FluentIcons.delete, size: 14, color: AppTheme.error.withOpacity(0.7)),
              onPressed: () => _showRemoveCustomerDialog(c),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(FluentIcons.contact_card, size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Text("CNIC: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
                Text(c['cnic'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(FluentIcons.home, size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Flexible(child: Text(c['address'] ?? c['city'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary))),
              ]),
            ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            _buildCardDetail(FluentIcons.city_next, c['city']),
            const SizedBox(width: 16),
            _buildCardDetail(FluentIcons.shopping_cart, "${c['totalPurchases']} purchases"),
            const Spacer(),
            Text(_formatPrice(c['totalSpent']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildCardDetail(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 12, color: AppTheme.textMuted),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
    ]);
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(FluentIcons.search, size: 32, color: AppTheme.primary)),
        const SizedBox(height: 16),
        Text("No customers found", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text("Try adjusting your search or filters", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
      ])),
    );
  }
}

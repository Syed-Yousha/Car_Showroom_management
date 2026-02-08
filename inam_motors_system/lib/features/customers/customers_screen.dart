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
    {'name': 'Ali Hassan', 'phone': '0312-1234567', 'cnic': '35202-1234567-1', 'city': 'Lahore', 'totalPurchases': 2, 'totalSpent': 15700000, 'lastPurchase': '2026-02-05', 'type': 'Regular'},
    {'name': 'Ahmed Khan', 'phone': '0300-9876543', 'cnic': '35201-9876543-2', 'city': 'Islamabad', 'totalPurchases': 1, 'totalSpent': 7200000, 'lastPurchase': '2026-02-03', 'type': 'New'},
    {'name': 'Usman Ali', 'phone': '0321-5551234', 'cnic': '35203-5551234-3', 'city': 'Karachi', 'totalPurchases': 3, 'totalSpent': 22500000, 'lastPurchase': '2026-02-01', 'type': 'VIP'},
    {'name': 'Bilal Malik', 'phone': '0333-6667890', 'cnic': '35204-6667890-4', 'city': 'Lahore', 'totalPurchases': 1, 'totalSpent': 3800000, 'lastPurchase': '2026-01-28', 'type': 'New'},
    {'name': 'Farhan Raza', 'phone': '0345-1112233', 'cnic': '35205-1112233-5', 'city': 'Faisalabad', 'totalPurchases': 2, 'totalSpent': 17800000, 'lastPurchase': '2026-01-25', 'type': 'Regular'},
    {'name': 'Imran Shah', 'phone': '0301-4445566', 'cnic': '35206-4445566-6', 'city': 'Multan', 'totalPurchases': 0, 'totalSpent': 0, 'lastPurchase': '-', 'type': 'Lead'},
    {'name': 'Zain ul Abideen', 'phone': '0311-7778899', 'cnic': '35207-7778899-7', 'city': 'Rawalpindi', 'totalPurchases': 4, 'totalSpent': 35000000, 'lastPurchase': '2026-01-15', 'type': 'VIP'},
    {'name': 'Hamza Tariq', 'phone': '0322-2223344', 'cnic': '35208-2223344-8', 'city': 'Lahore', 'totalPurchases': 1, 'totalSpent': 4600000, 'lastPurchase': '2026-01-10', 'type': 'New'},
    {'name': 'Saad Qureshi', 'phone': '0334-5556677', 'cnic': '35209-5556677-9', 'city': 'Islamabad', 'totalPurchases': 0, 'totalSpent': 0, 'lastPurchase': '-', 'type': 'Lead'},
    {'name': 'Waqar Ahmed', 'phone': '0346-8889900', 'cnic': '35210-8889900-0', 'city': 'Peshawar', 'totalPurchases': 1, 'totalSpent': 9500000, 'lastPurchase': '2026-01-05', 'type': 'Regular'},
  ];

  List<Map<String, dynamic>> get _filtered {
    return _customers.where((c) {
      if (_selectedFilter != 'All' && c['type'] != _selectedFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return c['name'].toString().toLowerCase().contains(q) ||
            c['phone'].toString().contains(q) ||
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
              Text("Manage your customer relationships", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
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
        placeholder: "Search by name, phone, city...",
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
        SizedBox(width: 120, child: Text("Phone", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 90, child: Text("City", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 70, child: Text("Type", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 80, child: Text("Purchases", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 100, child: Text("Total Spent", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 60),
      ]),
    );
  }

  Widget _buildCustomerRow(Map<String, dynamic> c) {
    final typeColor = _typeColor(c['type']);
    return Container(
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
          Flexible(child: Text(c['name'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
        ])),
        SizedBox(width: 120, child: Text(c['phone'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary))),
        SizedBox(width: 90, child: Text(c['city'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary))),
        SizedBox(width: 70, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
          child: Text(c['type'], textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: typeColor)),
        )),
        SizedBox(width: 80, child: Text("${c['totalPurchases']}", textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary))),
        SizedBox(width: 100, child: Text(_formatPrice(c['totalSpent']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
        SizedBox(width: 60, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          IconButton(icon: Icon(FluentIcons.view, size: 14, color: AppTheme.textSecondary), onPressed: () {}),
          IconButton(icon: Icon(FluentIcons.edit, size: 14, color: AppTheme.textSecondary), onPressed: () {}),
        ])),
      ]),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> c) {
    final typeColor = _typeColor(c['type']);
    return Container(
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
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _buildCardDetail(FluentIcons.city_next, c['city']),
          const SizedBox(width: 16),
          _buildCardDetail(FluentIcons.shopping_cart, "${c['totalPurchases']} purchases"),
          const Spacer(),
          Text(_formatPrice(c['totalSpent']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        ]),
      ]),
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

import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _selectedTab = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _sales = [
    {'id': 'INV-001', 'car': 'Toyota Grande 2024', 'buyer': 'Ali Hassan', 'date': '2026-02-05', 'amount': 8500000, 'status': 'Completed', 'payment': 'Full Payment', 'docs': ['Invoice', 'Transfer Letter']},
    {'id': 'INV-002', 'car': 'Honda Civic 2023', 'buyer': 'Ahmed Khan', 'date': '2026-02-03', 'amount': 7200000, 'status': 'Completed', 'payment': 'Full Payment', 'docs': ['Invoice', 'Transfer Letter', 'Insurance']},
    {'id': 'INV-003', 'car': 'Kia Sportage 2022', 'buyer': 'Usman Ali', 'date': '2026-02-01', 'amount': 9500000, 'status': 'Pending', 'payment': 'Installment', 'docs': ['Invoice']},
    {'id': 'INV-004', 'car': 'Suzuki Cultus 2024', 'buyer': 'Bilal Malik', 'date': '2026-01-28', 'amount': 3800000, 'status': 'Completed', 'payment': 'Full Payment', 'docs': ['Invoice', 'Transfer Letter']},
    {'id': 'INV-005', 'car': 'Hyundai Tucson 2022', 'buyer': 'Farhan Raza', 'date': '2026-01-25', 'amount': 11000000, 'status': 'Pending', 'payment': 'Partial', 'docs': ['Invoice']},
    {'id': 'INV-006', 'car': 'Toyota Corolla 2024', 'buyer': 'Imran Shah', 'date': '2026-01-20', 'amount': 6800000, 'status': 'Cancelled', 'payment': 'Refunded', 'docs': []},
    {'id': 'INV-007', 'car': 'MG HS 2024', 'buyer': 'Zain ul Abideen', 'date': '2026-01-15', 'amount': 9800000, 'status': 'Completed', 'payment': 'Full Payment', 'docs': ['Invoice', 'Transfer Letter', 'Insurance']},
    {'id': 'INV-008', 'car': 'Changan Alsvin 2024', 'buyer': 'Hamza Tariq', 'date': '2026-01-10', 'amount': 4600000, 'status': 'Completed', 'payment': 'Full Payment', 'docs': ['Invoice', 'Transfer Letter']},
  ];

  List<Map<String, dynamic>> get _filteredSales {
    return _sales.where((s) {
      if (_selectedTab != 'All' && s['status'] != _selectedTab) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return s['id'].toString().toLowerCase().contains(q) ||
            s['car'].toString().toLowerCase().contains(q) ||
            s['buyer'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  String _formatPrice(int price) {
    if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    return 'Rs $price';
  }

  int get _completedCount => _sales.where((s) => s['status'] == 'Completed').length;
  int get _pendingCount => _sales.where((s) => s['status'] == 'Pending').length;
  int get _cancelledCount => _sales.where((s) => s['status'] == 'Cancelled').length;
  int get _totalRevenue => _sales.where((s) => s['status'] == 'Completed').fold(0, (sum, s) => sum + (s['amount'] as int));

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
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Sales & Documents",
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text("Track all sales, invoices and documents",
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
              ]),
            ),
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
                Text("New Sale", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ]),

          const SizedBox(height: 24),

          // STATS
          if (isNarrow)
            Column(children: [
              Row(children: [
                _buildStat("Total Sales", "${_sales.length}", FluentIcons.shopping_cart, AppTheme.primary),
                const SizedBox(width: 12),
                _buildStat("Completed", "$_completedCount", FluentIcons.completed, AppTheme.success),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStat("Pending", "$_pendingCount", FluentIcons.clock, AppTheme.warning),
                const SizedBox(width: 12),
                _buildStat("Revenue", _formatPrice(_totalRevenue), FluentIcons.money, AppTheme.info),
              ]),
            ])
          else
            Row(children: [
              _buildStat("Total Sales", "${_sales.length}", FluentIcons.shopping_cart, AppTheme.primary),
              const SizedBox(width: 16),
              _buildStat("Completed", "$_completedCount", FluentIcons.completed, AppTheme.success),
              const SizedBox(width: 16),
              _buildStat("Pending", "$_pendingCount", FluentIcons.clock, AppTheme.warning),
              const SizedBox(width: 16),
              _buildStat("Revenue", _formatPrice(_totalRevenue), FluentIcons.money, AppTheme.info),
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
                  _buildTabChip("All", _sales.length),
                  const SizedBox(width: 8),
                  _buildTabChip("Completed", _completedCount),
                  const SizedBox(width: 8),
                  _buildTabChip("Pending", _pendingCount),
                  const SizedBox(width: 8),
                  _buildTabChip("Cancelled", _cancelledCount),
                ]),
              ),
            ])
          else
            Row(children: [
              Expanded(flex: 3, child: _buildSearchBar()),
              const SizedBox(width: 16),
              _buildTabChip("All", _sales.length),
              const SizedBox(width: 8),
              _buildTabChip("Completed", _completedCount),
              const SizedBox(width: 8),
              _buildTabChip("Pending", _pendingCount),
              const SizedBox(width: 8),
              _buildTabChip("Cancelled", _cancelledCount),
            ]),

          const SizedBox(height: 20),

          // TABLE HEADER (wide) or CARD LIST (narrow)
          if (!isNarrow) _buildTableHeader(),

          // SALES LIST
          ..._filteredSales.map((s) => isNarrow ? _buildSaleCard(s) : _buildSaleRow(s)),

          if (_filteredSales.isEmpty) _buildEmpty(),

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
        placeholder: "Search by invoice, car or buyer...",
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        SizedBox(width: 90, child: Text("Invoice", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        Expanded(flex: 2, child: Text("Car", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        Expanded(flex: 2, child: Text("Buyer", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 90, child: Text("Date", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 100, child: Text("Amount", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 90, child: Text("Status", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 80, child: Text("Docs", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
        SizedBox(width: 60),
      ]),
    );
  }

  Widget _buildSaleRow(Map<String, dynamic> s) {
    final statusColor = _statusColor(s['status']);
    final docs = s['docs'] as List;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
      child: Row(children: [
        SizedBox(width: 90, child: Text(s['id'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary))),
        Expanded(flex: 2, child: Text(s['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary))),
        Expanded(flex: 2, child: Text(s['buyer'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary))),
        SizedBox(width: 90, child: Text(s['date'].toString().substring(5), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted))),
        SizedBox(width: 100, child: Text(_formatPrice(s['amount']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
        SizedBox(
          width: 90,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(s['status'], textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ),
        SizedBox(width: 80, child: Text("${docs.length} files", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted))),
        SizedBox(
          width: 60,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(icon: Icon(FluentIcons.view, size: 14, color: AppTheme.textSecondary), onPressed: () {}),
            IconButton(icon: Icon(FluentIcons.print, size: 14, color: AppTheme.textSecondary), onPressed: () {}),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> s) {
    final statusColor = _statusColor(s['status']);
    final docs = s['docs'] as List;
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(s['id'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(s['status'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(s['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text("Buyer: ${s['buyer']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 10),
        Row(children: [
          Text(_formatPrice(s['amount']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primary)),
          const Spacer(),
          Icon(FluentIcons.calendar, size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(s['date'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(width: 12),
          Icon(FluentIcons.attach, size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text("${docs.length}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
          child: const Icon(FluentIcons.search, size: 32, color: AppTheme.primary),
        ),
        const SizedBox(height: 16),
        Text("No sales found", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text("Try adjusting your search or filters", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
      ])),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed': return AppTheme.success;
      case 'Pending': return AppTheme.warning;
      case 'Cancelled': return AppTheme.error;
      default: return AppTheme.textSecondary;
    }
  }
}

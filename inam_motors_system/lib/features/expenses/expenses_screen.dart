import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _expenses = [
    {'id': 'EXP-001', 'title': 'Workshop Rent', 'category': 'Rent', 'amount': 150000, 'date': '2026-02-01', 'paidTo': 'Landlord', 'method': 'Bank Transfer', 'recurring': true},
    {'id': 'EXP-002', 'title': 'Staff Salaries - Feb', 'category': 'Salary', 'amount': 320000, 'date': '2026-02-01', 'paidTo': 'Staff (5)', 'method': 'Cash', 'recurring': true},
    {'id': 'EXP-003', 'title': 'Car Detailing Supplies', 'category': 'Maintenance', 'amount': 25000, 'date': '2026-02-03', 'paidTo': 'Auto Supplies Co.', 'method': 'Cash', 'recurring': false},
    {'id': 'EXP-004', 'title': 'Electricity Bill', 'category': 'Utility', 'amount': 45000, 'date': '2026-02-05', 'paidTo': 'LESCO', 'method': 'Online', 'recurring': true},
    {'id': 'EXP-005', 'title': 'Facebook/Instagram Ads', 'category': 'Marketing', 'amount': 50000, 'date': '2026-02-04', 'paidTo': 'Meta Ads', 'method': 'Online', 'recurring': true},
    {'id': 'EXP-006', 'title': 'Toyota Grande - Paint Job', 'category': 'Maintenance', 'amount': 35000, 'date': '2026-02-02', 'paidTo': 'Al-Noor Paint Shop', 'method': 'Cash', 'recurring': false},
    {'id': 'EXP-007', 'title': 'Gas Bill', 'category': 'Utility', 'amount': 18000, 'date': '2026-01-30', 'paidTo': 'SNGPL', 'method': 'Online', 'recurring': true},
    {'id': 'EXP-008', 'title': 'Security Guard - Feb', 'category': 'Salary', 'amount': 35000, 'date': '2026-02-01', 'paidTo': 'Guard Service', 'method': 'Cash', 'recurring': true},
    {'id': 'EXP-009', 'title': 'OLX Premium Listing', 'category': 'Marketing', 'amount': 15000, 'date': '2026-01-28', 'paidTo': 'OLX', 'method': 'Online', 'recurring': true},
    {'id': 'EXP-010', 'title': 'Honda Civic - Engine Repair', 'category': 'Maintenance', 'amount': 85000, 'date': '2026-01-25', 'paidTo': 'Honda Service Center', 'method': 'Cash', 'recurring': false},
    {'id': 'EXP-011', 'title': 'Insurance Premiums', 'category': 'Insurance', 'amount': 60000, 'date': '2026-01-20', 'paidTo': 'State Life Insurance', 'method': 'Bank Transfer', 'recurring': true},
    {'id': 'EXP-012', 'title': 'Office Supplies', 'category': 'Miscellaneous', 'amount': 8000, 'date': '2026-02-06', 'paidTo': 'Stationery Shop', 'method': 'Cash', 'recurring': false},
  ];

  List<Map<String, dynamic>> get _filtered {
    return _expenses.where((e) {
      if (_selectedCategory != 'All' && e['category'] != _selectedCategory) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return e['title'].toString().toLowerCase().contains(q) ||
            e['paidTo'].toString().toLowerCase().contains(q) ||
            e['category'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  List<String> get _categories {
    final cats = _expenses.map((e) => e['category'] as String).toSet().toList();
    cats.sort();
    return cats;
  }

  int get _totalExpenses => _expenses.fold(0, (s, e) => s + (e['amount'] as int));
  int get _monthlyRecurring => _expenses.where((e) => e['recurring'] == true).fold(0, (s, e) => s + (e['amount'] as int));
  int get _oneTimeExpenses => _expenses.where((e) => e['recurring'] == false).fold(0, (s, e) => s + (e['amount'] as int));

  String _formatPrice(int price) {
    if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return 'Rs ${(price / 1000).toStringAsFixed(0)}K';
    return 'Rs $price';
  }

  int _categoryTotal(String cat) => _expenses.where((e) => e['category'] == cat).fold(0, (s, e) => s + (e['amount'] as int));
  int _categoryCount(String cat) => _expenses.where((e) => e['category'] == cat).length;

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Rent': return AppTheme.primary;
      case 'Salary': return AppTheme.info;
      case 'Maintenance': return AppTheme.warning;
      case 'Utility': return const Color(0xFF8B5CF6);
      case 'Marketing': return AppTheme.success;
      case 'Insurance': return const Color(0xFFEC4899);
      case 'Miscellaneous': return AppTheme.textMuted;
      default: return AppTheme.textSecondary;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Rent': return FluentIcons.home;
      case 'Salary': return FluentIcons.people;
      case 'Maintenance': return FluentIcons.repair;
      case 'Utility': return FluentIcons.lightning_bolt;
      case 'Marketing': return FluentIcons.megaphone;
      case 'Insurance': return FluentIcons.shield;
      case 'Miscellaneous': return FluentIcons.more;
      default: return FluentIcons.money;
    }
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
              Text("Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Track and manage all business expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
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
                Text("Add Expense", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ]),

          const SizedBox(height: 24),

          // STATS
          if (isNarrow)
            Column(children: [
              Row(children: [
                _buildStat("Total Expenses", _formatPrice(_totalExpenses), FluentIcons.calculator_addition, AppTheme.error),
                const SizedBox(width: 12),
                _buildStat("Recurring", _formatPrice(_monthlyRecurring), FluentIcons.sync_folder, AppTheme.warning),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStat("One-Time", _formatPrice(_oneTimeExpenses), FluentIcons.page, AppTheme.info),
                const SizedBox(width: 12),
                _buildStat("Categories", "${_categories.length}", FluentIcons.tag, AppTheme.primary),
              ]),
            ])
          else
            Row(children: [
              _buildStat("Total Expenses", _formatPrice(_totalExpenses), FluentIcons.calculator_addition, AppTheme.error),
              const SizedBox(width: 16),
              _buildStat("Recurring", _formatPrice(_monthlyRecurring), FluentIcons.sync_folder, AppTheme.warning),
              const SizedBox(width: 16),
              _buildStat("One-Time", _formatPrice(_oneTimeExpenses), FluentIcons.page, AppTheme.info),
              const SizedBox(width: 16),
              _buildStat("Categories", "${_categories.length}", FluentIcons.tag, AppTheme.primary),
            ]),

          const SizedBox(height: 24),

          // CATEGORY BREAKDOWN + EXPENSE LIST
          if (isMedium)
            Column(children: [
              _buildCategoryBreakdown(),
              const SizedBox(height: 20),
              _buildExpenseListSection(),
            ])
          else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 300, child: _buildCategoryBreakdown()),
              const SizedBox(width: 20),
              Expanded(child: _buildExpenseListSection()),
            ]),

          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("By Category", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text("Expense breakdown", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
        const SizedBox(height: 18),
        ..._categories.map((cat) {
          final total = _categoryTotal(cat);
          final pct = _totalExpenses > 0 ? total / _totalExpenses : 0.0;
          final color = _categoryColor(cat);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                  child: Icon(_categoryIcon(cat), color: color, size: 12),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(cat, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
                Text(_formatPrice(total), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 5,
                  child: ProgressBar(value: pct * 100, backgroundColor: AppTheme.divider, activeColor: color),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildExpenseListSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("All Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 14),

          // Search bar
          _buildSearchBar(),
          const SizedBox(height: 12),

          // Filter chips - scrollable
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChip("All", _expenses.length),
                ..._categories.map((c) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildChip(c, _categoryCount(c)),
                )),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Text("${_filtered.length} expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 10),

          // Expense rows
          ..._filtered.map((e) => _buildExpenseRow(e)),

          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(child: Text("No expenses found", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textMuted))),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(Map<String, dynamic> e) {
    final catColor = _categoryColor(e['category']);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.5)))),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(_categoryIcon(e['category']), size: 14, color: catColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(e['title'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
            if (e['recurring'] == true)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: AppTheme.info.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
                  child: const Text("Recurring", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 8, fontWeight: FontWeight.w700, color: AppTheme.info)),
                ),
              ),
          ]),
          const SizedBox(height: 2),
          Text("${e['paidTo']} \u2022 ${e['method']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_formatPrice(e['amount']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.error)),
          Text(e['date'].toString().substring(5), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 36,
      child: TextBox(
        placeholder: "Search expenses...",
        placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary),
        prefix: Padding(padding: const EdgeInsets.only(left: 10), child: Icon(FluentIcons.search, size: 13, color: AppTheme.textMuted)),
        decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.transparent))),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildChip(String label, int count) {
    final sel = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary),
        ),
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
            Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
          ])),
        ]),
      ),
    );
  }
}

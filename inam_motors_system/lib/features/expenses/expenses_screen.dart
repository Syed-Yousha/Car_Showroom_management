import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../shared/widgets.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => ExpensesScreenState();
}

class ExpensesScreenState extends State<ExpensesScreen> {
  void showAddDialog() => _showAddExpenseDialog();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _expenses = [
    {'id': 'EXP-001', 'title': 'Workshop Rent', 'category': 'Rent', 'amount': 150000, 'date': '2026-02-01', 'paidTo': 'Landlord', 'method': 'Bank Transfer', 'recurring': true},
    {'id': 'EXP-002', 'title': 'Staff Salaries - Feb', 'category': 'Salaries', 'amount': 320000, 'date': '2026-02-01', 'paidTo': 'Staff (5)', 'method': 'Cash', 'recurring': true},
    {'id': 'EXP-003', 'title': 'Car Detailing Supplies', 'category': 'Maintenance', 'amount': 25000, 'date': '2026-02-03', 'paidTo': 'Auto Supplies Co.', 'method': 'Cash', 'recurring': false},
    {'id': 'EXP-004', 'title': 'Electricity Bill', 'category': 'Bills', 'amount': 45000, 'date': '2026-02-05', 'paidTo': 'LESCO', 'method': 'Online', 'recurring': true},
    {'id': 'EXP-005', 'title': 'Facebook/Instagram Ads', 'category': 'Marketing', 'amount': 50000, 'date': '2026-02-04', 'paidTo': 'Meta Ads', 'method': 'Online', 'recurring': true},
    {'id': 'EXP-006', 'title': 'Toyota Grande - Paint Job', 'category': 'Maintenance', 'amount': 35000, 'date': '2026-02-02', 'paidTo': 'Al-Noor Paint Shop', 'method': 'Cash', 'recurring': false},
    {'id': 'EXP-007', 'title': 'Gas Bill', 'category': 'Bills', 'amount': 18000, 'date': '2026-01-30', 'paidTo': 'SNGPL', 'method': 'Online', 'recurring': true},
    {'id': 'EXP-008', 'title': 'Security Guard - Feb', 'category': 'Salaries', 'amount': 35000, 'date': '2026-02-01', 'paidTo': 'Guard Service', 'method': 'Cash', 'recurring': true},
    {'id': 'EXP-009', 'title': 'OLX Premium Listing', 'category': 'Marketing', 'amount': 15000, 'date': '2026-01-28', 'paidTo': 'OLX', 'method': 'Online', 'recurring': true},
    {'id': 'EXP-010', 'title': 'Honda Civic - Engine Repair', 'category': 'Maintenance', 'amount': 85000, 'date': '2026-01-25', 'paidTo': 'Honda Service Center', 'method': 'Cash', 'recurring': false},
    {'id': 'EXP-011', 'title': 'Insurance Premiums', 'category': 'Bills', 'amount': 60000, 'date': '2026-01-20', 'paidTo': 'State Life Insurance', 'method': 'Bank Transfer', 'recurring': true},
    {'id': 'EXP-012', 'title': 'Office Supplies', 'category': 'Miscellaneous', 'amount': 8000, 'date': '2026-02-06', 'paidTo': 'Stationery Shop', 'method': 'Cash', 'recurring': false},
    {'id': 'EXP-013', 'title': 'Daily Tea & Refreshments', 'category': 'Tea', 'amount': 12000, 'date': '2026-02-06', 'paidTo': 'Canteen', 'method': 'Cash', 'recurring': true},
    {'id': 'EXP-014', 'title': 'Water Supply - Feb', 'category': 'Bills', 'amount': 5000, 'date': '2026-02-01', 'paidTo': 'WASA', 'method': 'Cash', 'recurring': true},
    {'id': 'EXP-015', 'title': 'Internet & Phone Bill', 'category': 'Bills', 'amount': 8000, 'date': '2026-02-03', 'paidTo': 'PTCL', 'method': 'Online', 'recurring': true},
  ];

  // Monthly report data
  final List<Map<String, dynamic>> _monthlyReport = [
    {'month': 'Feb 2026', 'income': 6250000, 'expenses': 871000, 'net': 5379000},
    {'month': 'Jan 2026', 'income': 9800000, 'expenses': 745000, 'net': 9055000},
    {'month': 'Dec 2025', 'income': 4600000, 'expenses': 680000, 'net': 3920000},
    {'month': 'Nov 2025', 'income': 7200000, 'expenses': 710000, 'net': 6490000},
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

  // Daily costs: Tea + Rent + Bills + Salaries
  int get _dailyCosts {
    const dailyCategories = ['Tea', 'Rent', 'Bills', 'Salaries'];
    return _expenses.where((e) => dailyCategories.contains(e['category'])).fold(0, (s, e) => s + (e['amount'] as int));
  }



  int _categoryTotal(String cat) => _expenses.where((e) => e['category'] == cat).fold(0, (s, e) => s + (e['amount'] as int));
  int _categoryCount(String cat) => _expenses.where((e) => e['category'] == cat).length;

  void _showAddExpenseDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final paidToCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}");
    String selectedCategory = 'Miscellaneous';
    String selectedMethod = 'Cash';
    bool isRecurring = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: const Text("Add Expense", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 480),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _expEditField("Title", titleCtrl),
            Row(children: [
              Expanded(child: _expEditField("Amount", amountCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _expEditField("Paid To", paidToCtrl)),
            ]),
            _expEditField("Date (YYYY-MM-DD)", dateCtrl),
            Row(children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Category",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: ['Rent', 'Salaries', 'Maintenance', 'Bills', 'Marketing', 'Tea', 'Miscellaneous'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedCategory = v); },
                  ),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Method",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedMethod,
                    isExpanded: true,
                    items: ['Cash', 'Online', 'Bank Transfer', 'Cheque'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedMethod = v); },
                  ),
                ),
              )),
            ]),
            Row(children: [
              Checkbox(
                checked: isRecurring,
                onChanged: (v) => setDialogState(() => isRecurring = v ?? false),
              ),
              const SizedBox(width: 8),
              Text("Recurring Expense", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary)),
            ]),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final id = "EXP-${(_expenses.length + 1).toString().padLeft(3, '0')}";
              setState(() {
                _expenses.insert(0, {
                  'id': id,
                  'title': titleCtrl.text.trim(),
                  'category': selectedCategory,
                  'amount': int.tryParse(amountCtrl.text) ?? 0,
                  'date': dateCtrl.text,
                  'paidTo': paidToCtrl.text.trim(),
                  'method': selectedMethod,
                  'recurring': isRecurring,
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text("Add Expense", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
        ],
      )),
    );
  }

  void _showEditExpenseDialog(Map<String, dynamic> e) {
    final idx = _expenses.indexOf(e);
    if (idx == -1) return;

    final titleCtrl = TextEditingController(text: e['title']);
    final amountCtrl = TextEditingController(text: e['amount'].toString());
    final paidToCtrl = TextEditingController(text: e['paidTo']);
    final dateCtrl = TextEditingController(text: e['date']);
    String selectedCategory = e['category'];
    String selectedMethod = e['method'];
    bool isRecurring = e['recurring'] == true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: Text("Edit Expense ${e['id']}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 480),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _expEditField("Title", titleCtrl),
            Row(children: [
              Expanded(child: _expEditField("Amount", amountCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _expEditField("Paid To", paidToCtrl)),
            ]),
            _expEditField("Date (YYYY-MM-DD)", dateCtrl),
            Row(children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Category",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: ['Rent', 'Salaries', 'Maintenance', 'Bills', 'Marketing', 'Tea', 'Miscellaneous'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedCategory = v); },
                  ),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Method",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedMethod,
                    isExpanded: true,
                    items: ['Cash', 'Online', 'Bank Transfer', 'Cheque'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedMethod = v); },
                  ),
                ),
              )),
            ]),
            Row(children: [
              Checkbox(
                checked: isRecurring,
                onChanged: (v) => setDialogState(() => isRecurring = v ?? false),
              ),
              const SizedBox(width: 8),
              Text("Recurring Expense", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary)),
            ]),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              setState(() {
                _expenses[idx] = {
                  ...e,
                  'title': titleCtrl.text,
                  'amount': int.tryParse(amountCtrl.text) ?? e['amount'],
                  'paidTo': paidToCtrl.text,
                  'date': dateCtrl.text,
                  'category': selectedCategory,
                  'method': selectedMethod,
                  'recurring': isRecurring,
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

  Widget _expEditField(String label, TextEditingController ctrl) {
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

  void _showRemoveExpenseDialog(Map<String, dynamic> e) {
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Remove Expense", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Are you sure you want to remove this expense?", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.error.withValues(alpha: 0.2))),
            child: Row(children: [
              Icon(FluentIcons.warning, size: 16, color: AppTheme.error),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e['title'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text("${formatPrice(e['amount'])} \u2022 ${e['category']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              ])),
            ]),
          ),
        ]),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: () {
              setState(() => _expenses.remove(e));
              Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Rent': return AppTheme.primary;
      case 'Salaries': return AppTheme.info;
      case 'Tea': return const Color(0xFF8B5CF6);
      case 'Bills': return AppTheme.error;
      case 'Maintenance': return AppTheme.warning;
      case 'Marketing': return AppTheme.success;
      case 'Miscellaneous': return AppTheme.textMuted;
      default: return AppTheme.textSecondary;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Rent': return FluentIcons.home;
      case 'Salaries': return FluentIcons.people;
      case 'Tea': return FluentIcons.cafe;
      case 'Bills': return FluentIcons.lightning_bolt;
      case 'Maintenance': return FluentIcons.repair;
      case 'Marketing': return FluentIcons.megaphone;
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
              Text("Track daily costs, bills, salaries & monthly reports", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
            ])),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
              onPressed: () => _showAddExpenseDialog(),
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
                StatCard(valueFontSize: 18, label: "Total Expenses", value: formatPrice(_totalExpenses), icon: FluentIcons.calculator_addition, color: AppTheme.error),
                const SizedBox(width: 12),
                StatCard(valueFontSize: 18, label: "Daily Costs", value: formatPrice(_dailyCosts), icon: FluentIcons.cafe, color: const Color(0xFF8B5CF6)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                StatCard(valueFontSize: 18, label: "Recurring", value: formatPrice(_monthlyRecurring), icon: FluentIcons.sync_folder, color: AppTheme.warning),
                const SizedBox(width: 12),
                StatCard(valueFontSize: 18, label: "One-Time", value: formatPrice(_oneTimeExpenses), icon: FluentIcons.page, color: AppTheme.info),
              ]),
            ])
          else
            Row(children: [
              StatCard(valueFontSize: 18, label: "Total Expenses", value: formatPrice(_totalExpenses), icon: FluentIcons.calculator_addition, color: AppTheme.error),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "Daily Costs", value: formatPrice(_dailyCosts), icon: FluentIcons.cafe, color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "Recurring", value: formatPrice(_monthlyRecurring), icon: FluentIcons.sync_folder, color: AppTheme.warning),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "One-Time", value: formatPrice(_oneTimeExpenses), icon: FluentIcons.page, color: AppTheme.info),
            ]),

          const SizedBox(height: 24),

          // DAILY COSTS HIGHLIGHT
          _buildDailyCostsSection(isNarrow),

          const SizedBox(height: 24),

          // MONTHLY REPORT
          _buildMonthlyReportSection(isNarrow),

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

  Widget _buildDailyCostsSection(bool isNarrow) {
    final dailyCategories = ['Tea', 'Rent', 'Bills', 'Salaries'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(FluentIcons.cafe, size: 14, color: Color(0xFF8B5CF6))),
          const SizedBox(width: 10),
          Text("Daily & Running Costs", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          Text(formatPrice(_dailyCosts), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.error)),
        ]),
        const SizedBox(height: 16),
        if (isNarrow)
          Column(children: [
            Row(children: dailyCategories.take(2).map((cat) => Expanded(child: Padding(
              padding: EdgeInsets.only(right: cat != dailyCategories[1] ? 10 : 0),
              child: _buildDailyCostCard(cat),
            ))).toList()),
            const SizedBox(height: 10),
            Row(children: dailyCategories.skip(2).map((cat) => Expanded(child: Padding(
              padding: EdgeInsets.only(right: cat != dailyCategories.last ? 10 : 0),
              child: _buildDailyCostCard(cat),
            ))).toList()),
          ])
        else
          Row(children: dailyCategories.map((cat) => Expanded(child: Padding(
            padding: EdgeInsets.only(right: cat != dailyCategories.last ? 12 : 0),
            child: _buildDailyCostCard(cat),
          ))).toList()),
      ]),
    );
  }

  Widget _buildDailyCostCard(String category) {
    final total = _categoryTotal(category);
    final color = _categoryColor(category);
    final icon = _categoryIcon(category);
    final count = _categoryCount(category);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(category, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ]),
        const SizedBox(height: 10),
        Text(formatPrice(total), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        Text("$count entries", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
      ]),
    );
  }

  Widget _buildMonthlyReportSection(bool isNarrow) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(FluentIcons.report_document, size: 14, color: AppTheme.primary)),
          const SizedBox(width: 10),
          Text("Monthly Reports", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          Text("Expenses vs Income", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        ]),
        const SizedBox(height: 16),

        // Table header
        if (!isNarrow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              Expanded(flex: 2, child: Text("Month", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              Expanded(child: Text("Income", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              Expanded(child: Text("Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              Expanded(child: Text("Net Profit", textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              SizedBox(width: 100, child: Text("Ratio", textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
            ]),
          ),

        ..._monthlyReport.map((m) => isNarrow ? _buildMonthCardMobile(m) : _buildMonthRow(m)),
      ]),
    );
  }

  Widget _buildMonthRow(Map<String, dynamic> m) {
    final expenseRatio = (m['expenses'] as int) / (m['income'] as int);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(m['month'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
        Expanded(child: Text(formatPrice(m['income']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success))),
        Expanded(child: Text(formatPrice(m['expenses']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.error))),
        Expanded(child: Text(formatPrice(m['net']), textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: (m['net'] as int) >= 0 ? AppTheme.success : AppTheme.error))),
        SizedBox(
          width: 100,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            SizedBox(
              width: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(height: 6, child: ProgressBar(value: expenseRatio * 100, backgroundColor: AppTheme.success.withValues(alpha: 0.2), activeColor: AppTheme.error)),
              ),
            ),
            const SizedBox(width: 6),
            Text("${(expenseRatio * 100).toStringAsFixed(0)}%", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildMonthCardMobile(Map<String, dynamic> m) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(m['month'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Income", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
            Text(formatPrice(m['income']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.success)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
            Text(formatPrice(m['expenses']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.error)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("Net Profit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
            Text(formatPrice(m['net']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: (m['net'] as int) >= 0 ? AppTheme.success : AppTheme.error)),
          ])),
        ]),
      ]),
    );
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
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                  child: Icon(_categoryIcon(cat), color: color, size: 12),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(cat, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
                Text(formatPrice(total), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(height: 5, child: ProgressBar(value: pct * 100, backgroundColor: AppTheme.divider, activeColor: color)),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text("All Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 14),
        _buildSearchBar(),
        const SizedBox(height: 12),
        SizedBox(
          height: 32,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            _buildChip("All", _expenses.length),
            ..._categories.map((c) => Padding(padding: const EdgeInsets.only(left: 8), child: _buildChip(c, _categoryCount(c)))),
          ]),
        ),
        const SizedBox(height: 14),
        Text("${_filtered.length} expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        const SizedBox(height: 10),
        ..._filtered.map((e) => _buildExpenseRow(e)),
        if (_filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Text("No expenses found", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textMuted))),
          ),
      ]),
    );
  }

  Widget _buildExpenseRow(Map<String, dynamic> e) {
    final catColor = _categoryColor(e['category']);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)))),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
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
                  decoration: BoxDecoration(color: AppTheme.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                  child: const Text("Recurring", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 8, fontWeight: FontWeight.w700, color: AppTheme.info)),
                ),
              ),
          ]),
          const SizedBox(height: 2),
          Text("${e['paidTo']} \u2022 ${e['method']} \u2022 ${e['category']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(formatPrice(e['amount']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.error)),
          Text(e['date'].toString().substring(5), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        ]),
        const SizedBox(width: 4),
        IconButton(icon: const Icon(FluentIcons.edit, size: 13, color: AppTheme.primary), onPressed: () => _showEditExpenseDialog(e)),
        IconButton(icon: Icon(FluentIcons.delete, size: 13, color: AppTheme.error.withValues(alpha: 0.7)), onPressed: () => _showRemoveExpenseDialog(e)),
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
        decoration: BoxDecoration(color: sel ? AppTheme.primary : AppTheme.background, borderRadius: BorderRadius.circular(14)),
        child: Text("$label ($count)", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary)),
      ),
    );
  }

}

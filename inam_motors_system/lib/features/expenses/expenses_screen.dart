import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../main.dart' show expensesRepo;
import '../../models/base.dart' show dateToTs;
import '../../models/expense.dart';
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

  List<Expense> _expenses = const [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh({bool force = false}) async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final list = await expensesRepo.listAll(forceRefresh: force);
      if (!mounted) return;
      setState(() {
        _expenses = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  List<Expense> get _filtered {
    return _expenses.where((e) {
      if (_selectedCategory != 'All' && e.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return e.title.toLowerCase().contains(q) ||
            e.paidTo.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  List<String> get _categories {
    final cats = _expenses.map((e) => e.category).toSet().toList();
    cats.sort();
    return cats;
  }

  // Period helpers — the dashboard pivots around "current month" for headline
  // stats, "today" for the daily-cost callout, and rolling-4-months for the
  // monthly report. Computed once per build (cheap; small N).
  bool _inMonth(DateTime d, int year, int month) =>
      d.year == year && d.month == month;
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Iterable<Expense> get _thisMonth {
    final now = DateTime.now();
    return _expenses.where((e) => _inMonth(e.date, now.year, now.month));
  }

  Iterable<Expense> get _today {
    final now = DateTime.now();
    return _expenses.where((e) => _sameDay(e.date, now));
  }

  // Headline cards — current month
  int get _totalExpenses => _thisMonth.fold(0, (s, e) => s + e.amount);
  int get _monthlyRecurring =>
      _thisMonth.where((e) => e.recurring).fold(0, (s, e) => s + e.amount);
  int get _oneTimeExpenses =>
      _thisMonth.where((e) => !e.recurring).fold(0, (s, e) => s + e.amount);

  // Today's spend — used by the "Daily Cost" headline card.
  int get _dailyCosts => _today.fold(0, (s, e) => s + e.amount);

  // All-time per-category — used by the "By Category" breakdown card and the
  // filter-chip counts on the expense list (those should reflect everything,
  // not just one month).
  int _categoryTotal(String cat) =>
      _expenses.where((e) => e.category == cat).fold(0, (s, e) => s + e.amount);

  int _categoryCount(String cat) =>
      _expenses.where((e) => e.category == cat).length;

  // Current-month per-category — used by the "Daily & Running Costs" detail
  // cards so the four buckets (Tea/Rent/Bills/Salaries) show this month's
  // running spend rather than all-time totals.
  int _monthCategoryTotal(String cat) =>
      _thisMonth.where((e) => e.category == cat).fold(0, (s, e) => s + e.amount);

  int _monthCategoryCount(String cat) =>
      _thisMonth.where((e) => e.category == cat).length;

  /// Trailing-4-months breakdown. For each of the most recent 4 calendar
  /// months (oldest → newest), aggregates total / recurring / one-time spend
  /// and entry count from the loaded expenses.
  List<_MonthlyBreakdown> get _monthlyBreakdown {
    final now = DateTime.now();
    final rows = <_MonthlyBreakdown>[];
    for (int i = 3; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final inBucket = _expenses.where((e) => _inMonth(e.date, m.year, m.month));
      final total = inBucket.fold<int>(0, (s, e) => s + e.amount);
      final rec = inBucket
          .where((e) => e.recurring)
          .fold<int>(0, (s, e) => s + e.amount);
      final one = inBucket
          .where((e) => !e.recurring)
          .fold<int>(0, (s, e) => s + e.amount);
      rows.add(_MonthlyBreakdown(
        month: m,
        total: total,
        recurring: rec,
        oneTime: one,
        count: inBucket.length,
      ));
    }
    // Newest first for display.
    return rows.reversed.toList();
  }

  static const _monthAbbrev = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _monthLabel(DateTime d) => '${_monthAbbrev[d.month - 1]} ${d.year}';

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _parseDateOrNow(String s) {
    final parsed = DateTime.tryParse(s);
    return parsed ?? DateTime.now();
  }

  Future<void> _showFlash(String message, {bool isError = false}) async {
    if (!mounted) return;
    await displayInfoBar(
      context,
      builder: (ctx, close) => InfoBar(
        title: Text(message,
            style: const TextStyle(fontFamily: AppTheme.fontFamily)),
        severity: isError ? InfoBarSeverity.error : InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  void _showAddExpenseDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final paidToCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: _formatDate(DateTime.now()));
    String selectedCategory = 'Miscellaneous';
    String selectedMethod = 'Cash';
    bool isRecurring = false;
    bool busy = false;

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
          Button(onPressed: busy ? null : () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: busy ? null : () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              setDialogState(() => busy = true);
              final expense = Expense(
                id: '',
                title: title,
                category: selectedCategory,
                amount: int.tryParse(amountCtrl.text.trim()) ?? 0,
                date: _parseDateOrNow(dateCtrl.text.trim()),
                paidTo: paidToCtrl.text.trim(),
                method: selectedMethod,
                recurring: isRecurring,
              );
              try {
                await expensesRepo.add(expense);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                await _refresh();
                await _showFlash("Expense added.");
              } catch (e) {
                setDialogState(() => busy = false);
                await _showFlash("Failed to add: $e", isError: true);
              }
            },
            child: busy
                ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                : const Text("Add Expense", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      )),
    );
  }

  void _showEditExpenseDialog(Expense e) {
    final titleCtrl = TextEditingController(text: e.title);
    final amountCtrl = TextEditingController(text: e.amount.toString());
    final paidToCtrl = TextEditingController(text: e.paidTo);
    final dateCtrl = TextEditingController(text: _formatDate(e.date));
    String selectedCategory = e.category;
    String selectedMethod = e.method;
    bool isRecurring = e.recurring;
    bool busy = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: Text("Edit Expense", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
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
          Button(onPressed: busy ? null : () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: busy ? null : () async {
              setDialogState(() => busy = true);
              try {
                await expensesRepo.update(e.id, {
                  'title': titleCtrl.text.trim(),
                  'amount': int.tryParse(amountCtrl.text.trim()) ?? e.amount,
                  'paidTo': paidToCtrl.text.trim(),
                  'date': dateToTs(_parseDateOrNow(dateCtrl.text.trim())),
                  'category': selectedCategory,
                  'method': selectedMethod,
                  'recurring': isRecurring,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                await _refresh();
                await _showFlash("Expense updated.");
              } catch (err) {
                setDialogState(() => busy = false);
                await _showFlash("Failed to update: $err", isError: true);
              }
            },
            child: busy
                ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                : const Text("Save Changes", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
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

  void _showRemoveExpenseDialog(Expense e) {
    bool busy = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
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
                Text(e.title, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text("${formatFullPrice(e.amount)} • ${e.category}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              ])),
            ]),
          ),
        ]),
        actions: [
          Button(onPressed: busy ? null : () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: busy ? null : () async {
              setDialogState(() => busy = true);
              try {
                await expensesRepo.delete(e.id);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                await _refresh();
                await _showFlash("Expense removed.");
              } catch (err) {
                setDialogState(() => busy = false);
                await _showFlash("Failed to delete: $err", isError: true);
              }
            },
            child: busy
                ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                : const Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      )),
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
            IconButton(
              icon: Icon(FluentIcons.refresh, size: 16, color: AppTheme.textSecondary),
              onPressed: _loading ? null : () => _refresh(force: true),
            ).withClickCursor,
            const SizedBox(width: 8),
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
            ).withClickCursor,
          ]),

          const SizedBox(height: 24),

          if (_loading)
            const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: ProgressRing()))
          else if (_loadError != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.error.withValues(alpha: 0.2))),
              child: Row(children: [
                Icon(FluentIcons.error, size: 16, color: AppTheme.error),
                const SizedBox(width: 10),
                Expanded(child: Text("Failed to load expenses: $_loadError", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.error))),
                Button(onPressed: _refresh, child: const Text("Retry", style: TextStyle(fontFamily: AppTheme.fontFamily))),
              ]),
            )
          else ...[
            // STATS
            if (isNarrow)
              Column(children: [
                Row(children: [
                  StatCard(valueFontSize: 18, label: "This Month", value: formatFullPrice(_totalExpenses), icon: FluentIcons.calculator_addition, color: AppTheme.error),
                  const SizedBox(width: 12),
                  StatCard(valueFontSize: 18, label: "Today", value: formatFullPrice(_dailyCosts), icon: FluentIcons.cafe, color: const Color(0xFF8B5CF6)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  StatCard(valueFontSize: 18, label: "Recurring", value: formatFullPrice(_monthlyRecurring), icon: FluentIcons.sync_folder, color: AppTheme.warning),
                  const SizedBox(width: 12),
                  StatCard(valueFontSize: 18, label: "One-Time", value: formatFullPrice(_oneTimeExpenses), icon: FluentIcons.page, color: AppTheme.info),
                ]),
              ])
            else
              Row(children: [
                StatCard(valueFontSize: 18, label: "This Month", value: formatFullPrice(_totalExpenses), icon: FluentIcons.calculator_addition, color: AppTheme.error),
                const SizedBox(width: 16),
                StatCard(valueFontSize: 18, label: "Today", value: formatFullPrice(_dailyCosts), icon: FluentIcons.cafe, color: const Color(0xFF8B5CF6)),
                const SizedBox(width: 16),
                StatCard(valueFontSize: 18, label: "Recurring", value: formatFullPrice(_monthlyRecurring), icon: FluentIcons.sync_folder, color: AppTheme.warning),
                const SizedBox(width: 16),
                StatCard(valueFontSize: 18, label: "One-Time", value: formatFullPrice(_oneTimeExpenses), icon: FluentIcons.page, color: AppTheme.info),
              ]),

            const SizedBox(height: 24),
            _buildDailyCostsSection(isNarrow),
            const SizedBox(height: 24),
            _buildMonthlyReportSection(isNarrow),
            const SizedBox(height: 24),

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
        ],
      );
    });
  }

  Widget _buildDailyCostsSection(bool isNarrow) {
    final dailyCategories = ['Tea', 'Rent', 'Bills', 'Salaries'];
    final runningTotal = dailyCategories.fold<int>(
        0, (s, cat) => s + _monthCategoryTotal(cat));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(FluentIcons.cafe, size: 14, color: Color(0xFF8B5CF6))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Daily & Running Costs", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text("Tea, Rent, Bills, Salaries — this month", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
          ]),
          const Spacer(),
          Text(formatFullPrice(runningTotal), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.error)),
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
    final total = _monthCategoryTotal(category);
    final color = _categoryColor(category);
    final icon = _categoryIcon(category);
    final count = _monthCategoryCount(category);

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
        Text(formatFullPrice(total), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        Text("$count entries", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
      ]),
    );
  }

  Widget _buildMonthlyReportSection(bool isNarrow) {
    final rows = _monthlyBreakdown;
    final maxTotal = rows.fold<int>(0, (m, r) => r.total > m ? r.total : m);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(FluentIcons.report_document, size: 14, color: AppTheme.primary)),
          const SizedBox(width: 10),
          Text("Monthly Reports", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          Text("Last 4 months", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        ]),
        const SizedBox(height: 16),
        if (!isNarrow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              Expanded(flex: 2, child: Text("Month", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              Expanded(child: Text("Recurring", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              Expanded(child: Text("One-Time", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              Expanded(child: Text("Total", textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              SizedBox(width: 110, child: Text("Share", textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
            ]),
          ),
        ...rows.map((m) => isNarrow ? _buildMonthCardMobile(m) : _buildMonthRow(m, maxTotal)),
      ]),
    );
  }

  Widget _buildMonthRow(_MonthlyBreakdown m, int maxTotal) {
    final share = maxTotal == 0 ? 0.0 : m.total / maxTotal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)))),
      child: Row(children: [
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_monthLabel(m.month), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text("${m.count} ${m.count == 1 ? 'entry' : 'entries'}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        ])),
        Expanded(child: Text(formatFullPrice(m.recurring), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.warning))),
        Expanded(child: Text(formatFullPrice(m.oneTime), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.info))),
        Expanded(child: Text(formatFullPrice(m.total), textAlign: TextAlign.right, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.error))),
        SizedBox(
          width: 110,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            SizedBox(
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(height: 6, child: ProgressBar(value: share * 100, backgroundColor: AppTheme.divider, activeColor: AppTheme.error)),
              ),
            ),
            const SizedBox(width: 6),
            Text("${(share * 100).toStringAsFixed(0)}%", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildMonthCardMobile(_MonthlyBreakdown m) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_monthLabel(m.month), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const Spacer(),
          Text("${m.count} ${m.count == 1 ? 'entry' : 'entries'}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Recurring", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
            Text(formatFullPrice(m.recurring), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.warning)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("One-Time", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
            Text(formatFullPrice(m.oneTime), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.info)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("Total", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
            Text(formatFullPrice(m.total), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.error)),
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
        if (_categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text("No data", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
          )
        else
          ..._categories.map((cat) {
            final total = _categoryTotal(cat);
            final allTimeTotal =
                _expenses.fold<int>(0, (s, e) => s + e.amount);
            final pct = allTimeTotal > 0 ? total / allTimeTotal : 0.0;
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
                  Text(formatFullPrice(total), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
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

  Widget _buildExpenseRow(Expense e) {
    final catColor = _categoryColor(e.category);
    final dateLabel = _formatDate(e.date);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)))),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(_categoryIcon(e.category), size: 14, color: catColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(e.title, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
            if (e.recurring)
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
          Text("${e.paidTo} • ${e.method} • ${e.category}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(formatFullPrice(e.amount), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.error)),
          Text(dateLabel.substring(5), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        ]),
        const SizedBox(width: 4),
        IconButton(icon: const Icon(FluentIcons.edit, size: 13, color: AppTheme.primary), onPressed: () => _showEditExpenseDialog(e)).withClickCursor,
        IconButton(icon: Icon(FluentIcons.delete, size: 13, color: AppTheme.error.withValues(alpha: 0.7)), onPressed: () => _showRemoveExpenseDialog(e)).withClickCursor,
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: sel ? AppTheme.primary : AppTheme.background, borderRadius: BorderRadius.circular(14)),
          child: Text("$label ($count)", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary)),
        ),
      ),
    );
  }
}

class _MonthlyBreakdown {
  final DateTime month;
  final int total;
  final int recurring;
  final int oneTime;
  final int count;
  const _MonthlyBreakdown({
    required this.month,
    required this.total,
    required this.recurring,
    required this.oneTime,
    required this.count,
  });
}


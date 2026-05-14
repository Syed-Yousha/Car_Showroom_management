import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../main.dart'
    show inventoryService, customerService, ledgerService, investorsRepo;
import '../../models/car.dart';
import '../../models/customer.dart';
import '../../models/investor.dart';
import '../shared/widgets.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onAddCar;
  final VoidCallback? onAddCustomer;
  final VoidCallback? onAddExpense;
  const DashboardScreen(
      {super.key, this.onAddCar, this.onAddCustomer, this.onAddExpense});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _loadError;
  List<Car> _cars = const [];
  List<Investor> _investors = const [];
  // (customer, entry) pairs for customers with positive balance — used to
  // surface payment-due rows on the dashboard. We pull each owing customer's
  // ledger so we can find the most recent open "Car Sale" entry's dueDate.
  List<_DueRow> _dueRows = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        inventoryService.fetchCarsSafe(),
        customerService.fetchCustomersSafe(),
        investorsRepo.listAll(),
      ]);
      final cars = results[0] as List<Car>;
      final customers = results[1] as List<Customer>;
      final investors = results[2] as List<Investor>;

      // Resolve payment-due rows. We need each owing customer's most recent
      // unpaid Car Sale entry (if any) for the due date + car label. Limit
      // to top 10 owing customers to keep N reasonable on REST.
      final owing = customers.where((c) => c.balance > 0).toList()
        ..sort((a, b) => b.balance.compareTo(a.balance));
      final top = owing.take(10).toList();
      final dueRows = await _resolveDueRows(top);

      if (!mounted) return;
      setState(() {
        _cars = cars;
        _investors = investors;
        _dueRows = dueRows;
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

  Future<List<_DueRow>> _resolveDueRows(List<Customer> owing) async {
    final futures = owing.map((c) async {
      try {
        final entries = await ledgerService.fetchLedgerSafe(c.id);
        // Pick the most recent open Car Sale entry (not full payment) — that's
        // the one whose dueDate we want to show.
        Map<String, dynamic>? best;
        for (final e in entries) {
          if (e['type'] != 'Car Sale') continue;
          if (e['fullPayment'] == true) continue;
          if (best == null) {
            best = e;
            continue;
          }
          final bestDate = DateTime.tryParse(best['date']?.toString() ?? '') ??
              DateTime(2000);
          final eDate = DateTime.tryParse(e['date']?.toString() ?? '') ??
              DateTime(2000);
          if (eDate.isAfter(bestDate)) best = e;
        }
        final dueDate = best == null
            ? null
            : DateTime.tryParse(best['dueDate']?.toString() ?? '');
        final carName =
            (best?['carName'] as String?) ?? (best?['details'] as String?) ?? '';
        return _DueRow(
          customer: c,
          carName: carName,
          dueDate: dueDate,
        );
      } catch (_) {
        // A single customer's ledger fetch failing shouldn't break the whole
        // dashboard — fall back to a row with no car/dueDate context.
        return _DueRow(customer: c, carName: '', dueDate: null);
      }
    });
    return Future.wait(futures);
  }

  // ── Derived metrics ────────────────────────────────────────────────────

  int get _availableCount =>
      _cars.where((c) => c.status == 'Available').length;
  int get _bookedCount => _cars.where((c) => c.status == 'Booked').length;
  int get _soldCount => _cars.where((c) => c.status == 'Sold').length;

  int get _totalRevenue =>
      _cars.where((c) => c.status == 'Sold').fold(0, (s, c) => s + c.price);

  int get _activeInvestorCount =>
      _investors.where((i) => i.status == 'Active').length;

  List<Car> get _recentArrivals {
    final copy = List<Car>.from(_cars);
    copy.sort((a, b) {
      final ad = a.createdAt ?? DateTime(2000);
      final bd = b.createdAt ?? DateTime(2000);
      return bd.compareTo(ad);
    });
    return copy.take(4).toList();
  }

  /// Sold-car counts grouped by `make`, sorted descending. Top entries only.
  List<_BrandStat> get _topBrands {
    final byMake = <String, int>{};
    for (final c in _cars.where((c) => c.status == 'Sold')) {
      final key = c.make.trim().isEmpty ? 'Unknown' : c.make.trim();
      byMake[key] = (byMake[key] ?? 0) + 1;
    }
    final list = byMake.entries
        .map((e) => _BrandStat(name: e.key, count: e.value))
        .toList();
    list.sort((a, b) => b.count.compareTo(a.count));
    return list.take(4).toList();
  }

  /// Revenue grouped by the last 6 calendar months (oldest → newest), using
  /// the sold car's `updatedAt` (set when status flipped to 'Sold') as the
  /// sale date proxy. We don't have a dedicated saleDate field on Car.
  List<_MonthRevenue> get _monthlyRevenue {
    final now = DateTime.now();
    final buckets = <_MonthRevenue>[];
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      buckets.add(_MonthRevenue(month: m, revenue: 0));
    }
    for (final c in _cars.where((c) => c.status == 'Sold')) {
      final d = c.updatedAt ?? c.createdAt;
      if (d == null) continue;
      for (int i = 0; i < buckets.length; i++) {
        final b = buckets[i];
        if (d.year == b.month.year && d.month == b.month.month) {
          buckets[i] = _MonthRevenue(month: b.month, revenue: b.revenue + c.price);
          break;
        }
      }
    }
    return buckets;
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final isMedium = constraints.maxWidth < 1000;

        return ScaffoldPage.scrollable(
          padding: EdgeInsets.all(isNarrow ? 16 : 28),
          children: [
            _buildHeader(isNarrow),
            const SizedBox(height: 24),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: ProgressRing()),
              )
            else if (_loadError != null)
              _buildErrorBanner()
            else ...[
              _buildQuickActions(isNarrow),
              const SizedBox(height: 24),
              _buildStatCards(isNarrow),
              const SizedBox(height: 24),
              _buildPaymentAlerts(isNarrow),
              const SizedBox(height: 24),
              _buildMiddleSection(isMedium),
              const SizedBox(height: 24),
              _buildTopBrandsCard(isNarrow),
              const SizedBox(height: 24),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isNarrow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back, Admin",
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: isNarrow ? 22 : 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Here's what's happening with your showroom today.",
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
          icon: Icon(FluentIcons.refresh,
              size: 16, color: AppTheme.textSecondary),
          onPressed: _loading ? null : _refresh,
        ).withClickCursor,
        const SizedBox(width: 8),
        FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppTheme.primary),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          onPressed: () => widget.onAddCar?.call(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.add, size: 14, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Add New Car",
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
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(FluentIcons.error, size: 16, color: AppTheme.error),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Failed to load dashboard: $_loadError",
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppTheme.error,
            ),
          ),
        ),
        Button(
          onPressed: _refresh,
          child: const Text("Retry",
              style: TextStyle(fontFamily: AppTheme.fontFamily)),
        ),
      ]),
    );
  }

  Widget _buildQuickActions(bool isNarrow) {
    if (isNarrow) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildQuickActionFixed(FluentIcons.add_to, "Add Car",
              AppTheme.primary, () => widget.onAddCar?.call()),
          _buildQuickActionFixed(FluentIcons.people_add, "Add Customer",
              AppTheme.warning, () => widget.onAddCustomer?.call()),
          _buildQuickActionFixed(FluentIcons.calculator, "Add Expense",
              AppTheme.error, () => widget.onAddExpense?.call()),
        ],
      );
    }
    return Row(
      children: [
        _buildQuickAction(
            icon: FluentIcons.add_to,
            label: "Add Car",
            color: AppTheme.primary,
            onTap: () => widget.onAddCar?.call()),
        const SizedBox(width: 12),
        _buildQuickAction(
            icon: FluentIcons.people_add,
            label: "Add Customer",
            color: AppTheme.warning,
            onTap: () => widget.onAddCustomer?.call()),
        const SizedBox(width: 12),
        _buildQuickAction(
            icon: FluentIcons.calculator,
            label: "Add Expense",
            color: AppTheme.error,
            onTap: () => widget.onAddExpense?.call()),
      ],
    );
  }

  Widget _buildStatCards(bool isNarrow) {
    final cards = [
      _StatCardData(
        title: "Total Cars",
        value: "$_availableCount",
        change: _bookedCount > 0
            ? "$_bookedCount booked"
            : "Currently available",
        isPositive: true,
        graphColor: AppTheme.primary,
      ),
      _StatCardData(
        title: "Cars Sold",
        value: "$_soldCount",
        change: _soldCount == 0 ? "No sales yet" : "Across all time",
        isPositive: _soldCount > 0,
        graphColor: AppTheme.success,
      ),
      _StatCardData(
        title: "Total Revenue",
        value: formatFullPrice(_totalRevenue),
        change: "From $_soldCount sold ${_soldCount == 1 ? 'car' : 'cars'}",
        isPositive: _totalRevenue > 0,
        graphColor: AppTheme.warning,
      ),
      _StatCardData(
        title: "Investors",
        value: "$_activeInvestorCount",
        change: _activeInvestorCount == 0
            ? "No active investors"
            : "Active partners",
        isPositive: _activeInvestorCount > 0,
        graphColor: AppTheme.info,
      ),
    ];

    if (isNarrow) {
      return Column(children: [
        Row(children: [
          _buildStatCard(cards[0]),
          const SizedBox(width: 12),
          _buildStatCard(cards[1]),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _buildStatCard(cards[2]),
          const SizedBox(width: 12),
          _buildStatCard(cards[3]),
        ]),
      ]);
    }
    return Row(children: [
      _buildStatCard(cards[0]),
      const SizedBox(width: 16),
      _buildStatCard(cards[1]),
      const SizedBox(width: 16),
      _buildStatCard(cards[2]),
      const SizedBox(width: 16),
      _buildStatCard(cards[3]),
    ]);
  }

  Widget _buildMiddleSection(bool isMedium) {
    final revenueCard = _buildRevenueCard();
    final arrivalsCard = _buildArrivalsCard();
    if (isMedium) {
      return Column(children: [
        revenueCard,
        const SizedBox(height: 20),
        arrivalsCard,
      ]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: revenueCard),
        const SizedBox(width: 20),
        Expanded(flex: 1, child: arrivalsCard),
      ],
    );
  }

  Widget _buildRevenueCard() {
    final data = _monthlyRevenue;
    final maxRev =
        data.fold<int>(0, (m, e) => e.revenue > m ? e.revenue : m);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Revenue Statistics",
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Row(children: [
                _buildLegendDot("Revenue", AppTheme.primary),
              ]),
            ],
          ),
          const SizedBox(height: 4),
          Text("Sold-car revenue over the last 6 months",
              style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: AppTheme.textMuted)),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: maxRev == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.chart,
                            size: 40,
                            color: AppTheme.primary.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text("No sales recorded yet",
                            style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13,
                                color: AppTheme.textMuted)),
                      ],
                    ),
                  )
                : _RevenueBarChart(data: data, maxRevenue: maxRev),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalsCard() {
    final arrivals = _recentArrivals;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Arrivals",
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text("${arrivals.length} shown",
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          if (arrivals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text("No cars in inventory yet",
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: AppTheme.textMuted)),
              ),
            )
          else
            ...arrivals.map((c) => _buildCarRow(
                  name: c.name.isEmpty ? "${c.make} ${c.model}".trim() : c.name,
                  details:
                      "${c.year}${c.color.isNotEmpty ? ' • ${c.color}' : ''}",
                  status: c.status,
                  price: formatFullPrice(c.price),
                )),
        ],
      ),
    );
  }

  Widget _buildTopBrandsCard(bool isNarrow) {
    final brands = _topBrands;
    final colors = [
      AppTheme.primary,
      AppTheme.success,
      AppTheme.warning,
      AppTheme.info,
    ];
    final maxCount =
        brands.fold<int>(0, (m, e) => e.count > m ? e.count : m);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Top Selling Brands",
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text("All time",
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 20),
          if (brands.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text("No sales yet — sell a car to see brand stats here.",
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      color: AppTheme.textMuted)),
            )
          else if (isNarrow)
            Column(
              children: [
                for (int i = 0; i < brands.length; i++) ...[
                  _buildBrandProgress(
                    brands[i].name,
                    maxCount == 0 ? 0 : brands[i].count / maxCount,
                    colors[i % colors.length],
                    brands[i].count,
                  ),
                  if (i < brands.length - 1) const SizedBox(height: 14),
                ]
              ],
            )
          else
            Row(
              children: [
                for (int i = 0; i < brands.length; i++) ...[
                  Expanded(
                    child: _buildBrandProgress(
                      brands[i].name,
                      maxCount == 0 ? 0 : brands[i].count / maxCount,
                      colors[i % colors.length],
                      brands[i].count,
                    ),
                  ),
                  if (i < brands.length - 1) const SizedBox(width: 32),
                ]
              ],
            ),
        ],
      ),
    );
  }

  // ── WhatsApp Reminder Dialog ──
  void _showWhatsAppDialog(_DueRow row) {
    final amount = formatFullPrice(row.customer.balance);
    final dueLabel = row.dueDate == null
        ? 'not set'
        : _formatDate(row.dueDate!);
    final msg =
        "Assalam o Alaikum ${row.customer.name},\n\nThis is a gentle reminder from Inam Motors regarding your outstanding balance${row.carName.isEmpty ? '' : ' for ${row.carName}'}.\n\nDue Amount: $amount\nDue Date: $dueLabel\n\nKindly make the payment at your earliest convenience.\n\nThank you,\nInam Motors";

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(children: [
          Icon(FluentIcons.chat, size: 18, color: AppTheme.success),
          const SizedBox(width: 8),
          const Text("WhatsApp Reminder",
              style: TextStyle(
                  fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        ]),
        constraints: const BoxConstraints(maxWidth: 500),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text("To: ",
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: AppTheme.textMuted)),
                Text(row.customer.name,
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                if (row.customer.phone.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text("(${row.customer.phone})",
                      style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: AppTheme.textMuted)),
                ],
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.divider)),
                child: Text(msg,
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        height: 1.5)),
              ),
            ]),
        actions: [
          Button(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel",
                  style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.success)),
            onPressed: () => Navigator.pop(ctx),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(FluentIcons.chat, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text("Copy & Send",
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ]),
          ).withClickCursor,
        ],
      ),
    );
  }

  // ── Payment Due Alerts ──
  Widget _buildPaymentAlerts(bool isNarrow) {
    final rows = _dueRows;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: const Icon(FluentIcons.warning,
                  size: 14, color: AppTheme.error),
            ),
            const SizedBox(width: 10),
            Text("Payment Due Alerts",
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Text("${rows.length}",
                  style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.error)),
            ),
          ]),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [
                Icon(FluentIcons.check_mark, size: 14, color: AppTheme.success),
                const SizedBox(width: 8),
                Text("No outstanding balances. You're all caught up.",
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: AppTheme.textSecondary)),
              ]),
            )
          else
            ...rows.map((row) => _buildAlertRow(row, isNarrow)),
        ],
      ),
    );
  }

  Widget _buildAlertRow(_DueRow row, bool isNarrow) {
    final urgency = _urgencyFor(row.dueDate);
    final urgencyColor = urgency.color;
    final amount = formatFullPrice(row.customer.balance);
    final dueLabel =
        row.dueDate == null ? 'No due date' : _formatDate(row.dueDate!);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: urgencyColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: urgencyColor.withValues(alpha: 0.12)),
      ),
      child: Row(children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
              color: urgencyColor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(row.customer.name,
                      style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: urgencyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(urgency.label,
                      style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: urgencyColor)),
                ),
              ]),
              const SizedBox(height: 3),
              Text(
                "${row.carName.isEmpty ? 'Outstanding balance' : row.carName} • $amount",
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
        if (!isNarrow) ...[
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(amount,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: urgencyColor)),
            Text(dueLabel,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    color: AppTheme.textMuted)),
          ]),
          const SizedBox(width: 12),
          Tooltip(
            message: "Send WhatsApp Reminder",
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showWhatsAppDialog(row),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(FluentIcons.chat,
                      size: 14, color: AppTheme.success),
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  _Urgency _urgencyFor(DateTime? due) {
    if (due == null) return _Urgency(label: "Open", color: AppTheme.info);
    final today = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day);
    final dueDay = DateTime(due.year, due.month, due.day);
    final days = dueDay.difference(today).inDays;
    if (days < 0) {
      return _Urgency(label: "Overdue", color: AppTheme.error);
    } else if (days == 0) {
      return _Urgency(label: "Due Today", color: AppTheme.error);
    } else if (days <= 3) {
      return _Urgency(label: "Due in ${days}d", color: AppTheme.warning);
    } else {
      return _Urgency(label: "Upcoming", color: AppTheme.info);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Reusable building blocks (unchanged styling) ────────────────────────

  Widget _buildQuickAction(
      {required IconData icon,
      required String label,
      required Color color,
      VoidCallback? onTap}) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionFixed(
      IconData icon, String label, Color color, VoidCallback? onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatCard(_StatCardData d) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.title,
              style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(d.value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(d.isPositive ? FluentIcons.up : FluentIcons.down,
                size: 10,
                color: d.isPositive ? AppTheme.success : AppTheme.textMuted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(d.change,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: d.isPositive
                          ? AppTheme.success
                          : AppTheme.textMuted)),
            ),
          ]),
        ]),
      ),
    );
  }

  static Widget _buildLegendDot(String label, Color color) {
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              color: AppTheme.textMuted)),
    ]);
  }

  Widget _buildCarRow(
      {required String name,
      required String details,
      required String status,
      required String price}) {
    Color statusColor = AppTheme.success;
    if (status == 'Sold') statusColor = AppTheme.textMuted;
    if (status == 'Booked') statusColor = AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(8)),
          child:
              Icon(FluentIcons.car, color: AppTheme.textSecondary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(details,
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.textMuted,
                      fontSize: 11)),
            ],
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price,
              style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppTheme.primary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4)),
            child: Text(status,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }

  Widget _buildBrandProgress(
      String brand, double progress, Color color, int count) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(brand,
            style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: AppTheme.textPrimary)),
        Text("$count sold",
            style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
      ]),
      const SizedBox(height: 8),
      Container(
        height: 6,
        decoration: BoxDecoration(
            color: AppTheme.divider, borderRadius: BorderRadius.circular(3)),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3))),
        ),
      ),
    ]);
  }
}

// ── Data classes ─────────────────────────────────────────────────────────

class _StatCardData {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final Color graphColor;
  const _StatCardData({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.graphColor,
  });
}

class _BrandStat {
  final String name;
  final int count;
  const _BrandStat({required this.name, required this.count});
}

class _MonthRevenue {
  final DateTime month;
  final int revenue;
  const _MonthRevenue({required this.month, required this.revenue});
}

class _DueRow {
  final Customer customer;
  final String carName;
  final DateTime? dueDate;
  const _DueRow(
      {required this.customer, required this.carName, this.dueDate});
}

class _Urgency {
  final String label;
  final Color color;
  const _Urgency({required this.label, required this.color});
}

// ── Custom monthly-revenue bar chart ─────────────────────────────────────

class _RevenueBarChart extends StatelessWidget {
  final List<_MonthRevenue> data;
  final int maxRevenue;
  const _RevenueBarChart({required this.data, required this.maxRevenue});

  static const _monthAbbrev = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < data.length; i++) ...[
            Expanded(
              child: _buildBar(data[i]),
            ),
            if (i < data.length - 1) const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildBar(_MonthRevenue m) {
    final pct = maxRevenue == 0 ? 0.0 : m.revenue / maxRevenue;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          m.revenue == 0 ? '' : _shortPrice(m.revenue),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: LayoutBuilder(builder: (ctx, c) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.divider.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: pct.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.primary,
                          AppTheme.primary.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          _monthAbbrev[m.month.month - 1],
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  String _shortPrice(int amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(amount % 10000000 == 0 ? 0 : 1)}Cr';
    }
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(amount % 100000 == 0 ? 0 : 1)}L';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '$amount';
  }
}

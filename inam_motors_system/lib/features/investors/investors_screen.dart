import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../main.dart';
import '../../models/investor.dart';
import '../shared/widgets.dart';

class InvestorsScreen extends StatefulWidget {
  const InvestorsScreen({super.key});

  @override
  State<InvestorsScreen> createState() => _InvestorsScreenState();
}

class _InvestorsScreenState extends State<InvestorsScreen> {
  /// Filled from a REST `listAll` call inside the FutureBuilder.
  /// Existing rendering helpers consume `Map<String, dynamic>`, so we
  /// adapt the typed `Investor` into that shape.
  List<Map<String, dynamic>> _investors = const [];

  Future<List<Investor>> _futureInvestors = investorsRepo.listAll();

  void _refresh({bool force = false}) {
    setState(() {
      _futureInvestors = investorsRepo.listAll(forceRefresh: force);
    });
  }

  Map<String, dynamic> _toDisplayMap(Investor inv) => {
        'id': inv.id,
        'name': inv.name,
        'role': inv.role,
        'invested': inv.invested,
        'share': inv.share,
        'profit': inv.profit,
        'phone': inv.phone,
        'joinDate':
            (inv.joinDate ?? DateTime.now()).toIso8601String().substring(0, 10),
        'status': inv.status,
        // Per-car P&L breakdown isn't in Firestore yet; keep empty so the
        // existing card layout renders cleanly.
        'cars': const <Map<String, dynamic>>[],
      };

  int get _totalInvested => _investors.fold(0, (s, i) => s + (i['invested'] as int));
  int get _totalProfit => _investors.fold(0, (s, i) => s + (i['profit'] as int));
  int get _totalCars => _investors.fold(0, (s, i) => s + ((i['cars'] as List).length));

  int _investorNetProfit(Map<String, dynamic> inv) {
    int total = 0;
    for (final car in (inv['cars'] as List)) {
      if (car['status'] == 'Sold') {
        total += ((car['salePrice'] as int) - (car['purchasePrice'] as int) - (car['repairs'] as int));
      }
    }
    return total;
  }

  int _carNetProfit(Map<String, dynamic> car) {
    if (car['status'] != 'Sold') return 0;
    return (car['salePrice'] as int) - (car['purchasePrice'] as int) - (car['repairs'] as int);
  }

  void _showEditDialog(int index) {
    final inv = Map<String, dynamic>.from(_investors[index]);
    final nameCtrl = TextEditingController(text: inv['name']);
    final roleCtrl = TextEditingController(text: inv['role']);
    final phoneCtrl = TextEditingController(text: inv['phone']);
    final investedCtrl = TextEditingController(text: inv['invested'].toString());
    final shareCtrl = TextEditingController(text: inv['share'].toString());

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Edit Investor", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 480),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _dialogField("Name", nameCtrl),
            _dialogField("Role", roleCtrl),
            _dialogField("Phone", phoneCtrl),
            _dialogField("Total Invested (Rs)", investedCtrl, isNumber: true),
            _dialogField("Share (%)", shareCtrl, isNumber: true),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              setState(() {
                _investors[index] = {
                  ...inv,
                  'name': nameCtrl.text,
                  'role': roleCtrl.text,
                  'phone': phoneCtrl.text,
                  'invested': int.tryParse(investedCtrl.text) ?? inv['invested'],
                  'share': int.tryParse(shareCtrl.text) ?? inv['share'],
                };
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl, {bool isNumber = false}) {
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

  void _showRemoveDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Remove Investor", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Text(
          "Are you sure you want to remove ${_investors[index]['name']}? This action cannot be undone.",
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: () {
              setState(() => _investors.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Investor>>(
      future: _futureInvestors,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const ScaffoldPage(
            content: Center(child: ProgressRing()),
          );
        }
        if (snap.hasError) {
          return ScaffoldPage(
            content: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load investors:\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _refresh(force: true),
                      child: const Text('Retry',
                          style: TextStyle(fontFamily: AppTheme.fontFamily)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        _investors =
            (snap.data ?? const []).map(_toDisplayMap).toList();
        return _buildMainContent();
      },
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;
      final isMedium = constraints.maxWidth < 1000;

      return ScaffoldPage.scrollable(
        padding: EdgeInsets.all(isNarrow ? 16 : 28),
        children: [
          // HEADER
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("Investors", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text("${_investors.length} Partners", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.primary)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text("Car-to-investor mapping, profit splits & P&L per vehicle", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
              ]),
              Wrap(spacing: 10, runSpacing: 8, children: [
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
                    Text("Add Investor", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ).withClickCursor,
              ]),
            ],
          ),

          const SizedBox(height: 24),

          // OVERVIEW STATS
          if (isNarrow)
            Column(children: [
              Row(children: [
                StatCard(valueFontSize: 18, label: "Total Invested", value: formatFullPrice(_totalInvested), icon: FluentIcons.money, color: AppTheme.primary),
                const SizedBox(width: 12),
                StatCard(valueFontSize: 18, label: "Net Profit", value: formatFullPrice(_totalProfit), icon: FluentIcons.up, color: AppTheme.success),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                StatCard(valueFontSize: 18, label: "Partners", value: "${_investors.length}", icon: FluentIcons.people, color: AppTheme.info),
                const SizedBox(width: 12),
                StatCard(valueFontSize: 18, label: "Cars Mapped", value: "$_totalCars", icon: FluentIcons.car, color: AppTheme.warning),
              ]),
            ])
          else
            Row(children: [
              StatCard(valueFontSize: 18, label: "Total Invested", value: formatFullPrice(_totalInvested), icon: FluentIcons.money, color: AppTheme.primary),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "Net Profit", value: formatFullPrice(_totalProfit), icon: FluentIcons.up, color: AppTheme.success),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "Partners", value: "${_investors.length}", icon: FluentIcons.people, color: AppTheme.info),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "Cars Mapped", value: "$_totalCars", icon: FluentIcons.car, color: AppTheme.warning),
            ]),

          const SizedBox(height: 28),

          // P&L FORMULA REFERENCE
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: const Icon(FluentIcons.calculator, size: 14, color: AppTheme.info)),
                const SizedBox(width: 10),
                Text("P&L Formula", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _buildFormulaItem("Sale Price", AppTheme.success),
                  _buildFormulaOp("-"),
                  _buildFormulaItem("Purchase\nPrice", AppTheme.primary),
                  _buildFormulaOp("-"),
                  _buildFormulaItem("Vehicle\nRepairs", AppTheme.warning),
                  _buildFormulaOp("="),
                  _buildFormulaItem("Net\nProfit", const Color(0xFF10B981)),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // SHARE DISTRIBUTION
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Share Distribution", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Current profit sharing ratio", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 28,
                  child: Row(
                    children: _investors.asMap().entries.map((e) {
                      final colors = [AppTheme.primary, AppTheme.info, AppTheme.warning];
                      return Expanded(
                        flex: e.value['share'] as int,
                        child: Container(
                          color: colors[e.key % colors.length],
                          child: Center(child: Text("${e.value['share']}%", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 20, runSpacing: 8,
                children: _investors.asMap().entries.map((e) {
                  final colors = [AppTheme.primary, AppTheme.info, AppTheme.warning];
                  return Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[e.key % colors.length], borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 6),
                    Text("${e.value['name']} (${e.value['share']}%)", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                  ]);
                }).toList(),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // INVESTOR CARDS WITH CAR MAPPING
          Text("Partners & Car Mapping", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 14),

          ..._investors.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildInvestorCardFull(e.value, e.key, isNarrow, isMedium),
          )),

          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildFormulaItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildFormulaOp(String op) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(op, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
    );
  }

  Widget _buildInvestorCardFull(Map<String, dynamic> inv, int index, bool isNarrow, bool isMedium) {
    final cars = inv['cars'] as List;
    final netProfit = _investorNetProfit(inv);
    final soldCars = cars.where((c) => c['status'] == 'Sold').length;
    final inStockCars = cars.where((c) => c['status'] == 'In Stock').length;

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(inv['name'].toString().substring(0, 1), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primary))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(inv['name'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text("${inv['role']} \u2022 ${inv['share']}% Share", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(inv['status'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
          ),
          const SizedBox(width: 8),
          IconButton(icon: Icon(FluentIcons.edit, size: 14, color: AppTheme.textMuted), onPressed: () => _showEditDialog(index)).withClickCursor,
          const SizedBox(width: 4),
          IconButton(icon: Icon(FluentIcons.delete, size: 14, color: AppTheme.error), onPressed: () => _showRemoveDialog(index)).withClickCursor,
        ]),

        const SizedBox(height: 16),

        // Summary stats
        if (isNarrow)
          Column(children: [
            Row(children: [
              Expanded(child: _buildInvDetail("Invested", formatFullPrice(inv['invested']))),
              Expanded(child: _buildInvDetail("Net P&L", formatFullPrice(netProfit), color: netProfit >= 0 ? AppTheme.success : AppTheme.error)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildInvDetail("Cars Sold", "$soldCars")),
              Expanded(child: _buildInvDetail("In Stock", "$inStockCars")),
            ]),
          ])
        else
          Row(children: [
            Expanded(child: _buildInvDetail("Invested", formatFullPrice(inv['invested']))),
            Expanded(child: _buildInvDetail("Net P&L", formatFullPrice(netProfit), color: netProfit >= 0 ? AppTheme.success : AppTheme.error)),
            Expanded(child: _buildInvDetail("Cars Sold", "$soldCars")),
            Expanded(child: _buildInvDetail("In Stock", "$inStockCars")),
          ]),

        const SizedBox(height: 16),

        // Contact row
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(FluentIcons.phone, size: 12, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Text(inv['phone'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
            const Spacer(),
            Icon(FluentIcons.calendar, size: 12, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Text("Since ${inv['joinDate'].toString().substring(0, 7)}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
          ]),
        ),

        const SizedBox(height: 16),

        // Car-to-Investor Mapping Table
        Row(children: [
          Icon(FluentIcons.car, size: 14, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text("Car P&L Breakdown", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 10),

        // Table header
        if (!isNarrow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              Expanded(flex: 3, child: Text("Vehicle", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              SizedBox(width: 110, child: Text("Purchase", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              SizedBox(width: 110, child: Text("Sale", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              SizedBox(width: 100, child: Text("Repairs", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              SizedBox(width: 110, child: Text("Net Profit", textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
            ]),
          ),

        // Car rows
        ...cars.map((car) => isNarrow ? _buildCarCardMobile(car) : _buildCarRow(car)),
      ]),
    );
  }

  Widget _buildCarRow(Map<String, dynamic> car) {
    final profit = _carNetProfit(car);
    final isSold = car['status'] == 'Sold';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)))),
      child: Row(children: [
        Expanded(flex: 3, child: Row(children: [
          Text(car['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isSold ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(car['status'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 8, fontWeight: FontWeight.w700, color: isSold ? AppTheme.success : AppTheme.warning)),
          ),
        ])),
        SizedBox(width: 110, child: Text(formatFullPrice(car['purchasePrice']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary))),
        SizedBox(width: 110, child: Text(isSold ? formatFullPrice(car['salePrice']) : '-', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: isSold ? AppTheme.success : AppTheme.textMuted))),
        SizedBox(width: 100, child: Text(formatFullPrice(car['repairs']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.warning))),
        SizedBox(width: 110, child: Text(
          isSold ? formatFullPrice(profit) : 'Pending',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: isSold ? (profit >= 0 ? AppTheme.success : AppTheme.error) : AppTheme.textMuted),
        )),
      ]),
    );
  }

  Widget _buildCarCardMobile(Map<String, dynamic> car) {
    final profit = _carNetProfit(car);
    final isSold = car['status'] == 'Sold';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(car['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: (isSold ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(car['status'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: isSold ? AppTheme.success : AppTheme.warning)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _buildMiniStat("Purchase", formatFullPrice(car['purchasePrice']), AppTheme.primary)),
          Expanded(child: _buildMiniStat("Sale", isSold ? formatFullPrice(car['salePrice']) : '-', AppTheme.success)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: _buildMiniStat("Repairs", formatFullPrice(car['repairs']), AppTheme.warning)),
          Expanded(child: const SizedBox()), // Empty space to maintain alignment
        ]),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            isSold ? "Net: ${formatFullPrice(profit)}" : "Pending",
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: isSold ? (profit >= 0 ? AppTheme.success : AppTheme.error) : AppTheme.textMuted),
          ),
        ),
      ]),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Row(children: [
      Text("$label: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
      Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    ]);
  }

  Widget _buildInvDetail(String label, String value, {Color? color}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: color ?? AppTheme.textPrimary)),
    ]);
  }
}

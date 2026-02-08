import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class InvestorsScreen extends StatefulWidget {
  const InvestorsScreen({super.key});

  @override
  State<InvestorsScreen> createState() => _InvestorsScreenState();
}

class _InvestorsScreenState extends State<InvestorsScreen> {
  final List<Map<String, dynamic>> _investors = [
    {
      'name': 'Muhammad Inam',
      'role': 'Managing Partner',
      'invested': 25000000,
      'share': 50,
      'profit': 3200000,
      'phone': '0300-1234567',
      'joinDate': '2024-01-15',
      'status': 'Active',
      'cars': 42,
    },
    {
      'name': 'Tariq Mehmood',
      'role': 'Silent Partner',
      'invested': 15000000,
      'share': 30,
      'profit': 1920000,
      'phone': '0321-9876543',
      'joinDate': '2024-06-10',
      'status': 'Active',
      'cars': 25,
    },
    {
      'name': 'Kashif Ali',
      'role': 'Investor',
      'invested': 10000000,
      'share': 20,
      'profit': 1280000,
      'phone': '0333-5556677',
      'joinDate': '2025-03-01',
      'status': 'Active',
      'cars': 17,
    },
  ];

  int get _totalInvested => _investors.fold(0, (s, i) => s + (i['invested'] as int));
  int get _totalProfit => _investors.fold(0, (s, i) => s + (i['profit'] as int));
  int get _totalCars => _investors.fold(0, (s, i) => s + (i['cars'] as int));

  String _formatPrice(int price) {
    if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    return 'Rs $price';
  }

  void _showEditDialog(int index) {
    final inv = Map<String, dynamic>.from(_investors[index]);
    final nameCtrl = TextEditingController(text: inv['name']);
    final roleCtrl = TextEditingController(text: inv['role']);
    final phoneCtrl = TextEditingController(text: inv['phone']);
    final investedCtrl = TextEditingController(text: inv['invested'].toString());
    final shareCtrl = TextEditingController(text: inv['share'].toString());
    final profitCtrl = TextEditingController(text: inv['profit'].toString());
    final carsCtrl = TextEditingController(text: inv['cars'].toString());

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Edit Investor", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 480),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField("Name", nameCtrl),
              _dialogField("Role", roleCtrl),
              _dialogField("Phone", phoneCtrl),
              _dialogField("Total Invested (Rs)", investedCtrl, isNumber: true),
              _dialogField("Share (%)", shareCtrl, isNumber: true),
              _dialogField("Profit Earned (Rs)", profitCtrl, isNumber: true),
              _dialogField("Cars Funded", carsCtrl, isNumber: true),
            ],
          ),
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily)),
          ),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              setState(() {
                _investors[index] = {
                  'name': nameCtrl.text,
                  'role': roleCtrl.text,
                  'phone': phoneCtrl.text,
                  'invested': int.tryParse(investedCtrl.text) ?? inv['invested'],
                  'share': int.tryParse(shareCtrl.text) ?? inv['share'],
                  'profit': int.tryParse(profitCtrl.text) ?? inv['profit'],
                  'cars': int.tryParse(carsCtrl.text) ?? inv['cars'],
                  'joinDate': inv['joinDate'],
                  'status': inv['status'],
                };
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ),
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
          decoration: WidgetStateProperty.all(BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.divider),
          )),
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
              Text("Investors", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Partner investments, shares and profit distribution", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
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
                Text("Add Investor", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ]),

          const SizedBox(height: 24),

          // OVERVIEW STATS
          if (isNarrow)
            Column(children: [
              Row(children: [
                _buildStat("Total Invested", _formatPrice(_totalInvested), FluentIcons.money, AppTheme.primary),
                const SizedBox(width: 12),
                _buildStat("Total Profit", _formatPrice(_totalProfit), FluentIcons.up, AppTheme.success),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStat("Partners", "${_investors.length}", FluentIcons.people, AppTheme.info),
                const SizedBox(width: 12),
                _buildStat("Cars Funded", "$_totalCars", FluentIcons.car, AppTheme.warning),
              ]),
            ])
          else
            Row(children: [
              _buildStat("Total Invested", _formatPrice(_totalInvested), FluentIcons.money, AppTheme.primary),
              const SizedBox(width: 16),
              _buildStat("Total Profit", _formatPrice(_totalProfit), FluentIcons.up, AppTheme.success),
              const SizedBox(width: 16),
              _buildStat("Partners", "${_investors.length}", FluentIcons.people, AppTheme.info),
              const SizedBox(width: 16),
              _buildStat("Cars Funded", "$_totalCars", FluentIcons.car, AppTheme.warning),
            ]),

          const SizedBox(height: 28),

          // SHARE DISTRIBUTION
          _buildCard(
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
                      final colors = [AppTheme.primary, AppTheme.info, AppTheme.warning, AppTheme.success, AppTheme.error];
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
                spacing: 20,
                runSpacing: 8,
                children: _investors.asMap().entries.map((e) {
                  final colors = [AppTheme.primary, AppTheme.info, AppTheme.warning, AppTheme.success, AppTheme.error];
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

          // INVESTOR CARDS
          Text("Partners", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 14),

          if (isNarrow)
            Column(children: _investors.asMap().entries.map((e) => 
              Padding(padding: const EdgeInsets.only(bottom: 14), child: _buildInvestorCard(e.value, e.key))
            ).toList())
          else if (isMedium)
            Column(children: [
              for (int idx = 0; idx < _investors.length; idx += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _buildInvestorCard(_investors[idx], idx)),
                    const SizedBox(width: 16),
                    if (idx + 1 < _investors.length)
                      Expanded(child: _buildInvestorCard(_investors[idx + 1], idx + 1))
                    else
                      const Expanded(child: SizedBox()),
                  ]),
                ),
            ])
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _investors.asMap().entries.map((e) => 
                Expanded(child: Padding(padding: const EdgeInsets.only(right: 16), child: _buildInvestorCard(e.value, e.key)))
              ).toList(),
            ),

          const SizedBox(height: 24),

          // RECENT TRANSACTIONS
          _buildCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Recent Transactions", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                HyperlinkButton(
                  style: ButtonStyle(foregroundColor: WidgetStateProperty.all(AppTheme.primary)),
                  onPressed: () {},
                  child: const Text("View All", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
                ),
              ]),
              const SizedBox(height: 14),
              _buildTx("Muhammad Inam", "Investment - Toyota Grande", 4250000, true, "Feb 05"),
              _buildTx("Tariq Mehmood", "Profit Distribution", 640000, false, "Feb 01"),
              _buildTx("Kashif Ali", "Investment - Honda City", 2600000, true, "Jan 28"),
              _buildTx("Muhammad Inam", "Profit Distribution", 1060000, false, "Jan 25"),
              _buildTx("Tariq Mehmood", "Investment - MG HS", 2940000, true, "Jan 20"),
            ]),
          ),

          const SizedBox(height: 24),
        ],
      );
    });
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

  static Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: child,
    );
  }

  Widget _buildInvestorCard(Map<String, dynamic> inv, int index) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(inv['name'].toString().substring(0, 1), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primary))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(inv['name'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text(inv['role'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
          ])),
          IconButton(
            icon: Icon(FluentIcons.edit, size: 14, color: AppTheme.textMuted),
            onPressed: () => _showEditDialog(index),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _buildInvDetail("Invested", _formatPrice(inv['invested']))),
          Expanded(child: _buildInvDetail("Share", "${inv['share']}%")),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildInvDetail("Profit Earned", _formatPrice(inv['profit']))),
          Expanded(child: _buildInvDetail("Cars", "${inv['cars']}")),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(FluentIcons.phone, size: 12, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Flexible(child: Text(inv['phone'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary))),
            const Spacer(),
            Icon(FluentIcons.calendar, size: 12, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Text("Since ${inv['joinDate'].toString().substring(0, 7)}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Button(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
              ),
              onPressed: () => _showEditDialog(index),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(FluentIcons.edit, size: 12),
                SizedBox(width: 6),
                Text("Edit Details", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildInvDetail(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
    ]);
  }

  Widget _buildTx(String name, String desc, int amount, bool isInvestment, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.5)))),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: (isInvestment ? AppTheme.primary : AppTheme.success).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(isInvestment ? FluentIcons.add : FluentIcons.money, size: 14, color: isInvestment ? AppTheme.primary : AppTheme.success),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          Text(desc, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text("${isInvestment ? '+' : '-'}${_formatPrice(amount)}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: isInvestment ? AppTheme.primary : AppTheme.success)),
          Text(date, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }
}

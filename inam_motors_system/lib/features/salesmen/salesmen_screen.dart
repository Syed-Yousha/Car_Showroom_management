import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../shared/widgets.dart';

class SalesmenScreen extends StatefulWidget {
  const SalesmenScreen({super.key});

  @override
  State<SalesmenScreen> createState() => _SalesmenScreenState();
}

class _SalesmenScreenState extends State<SalesmenScreen> {
  bool _isUnlocked = false;
  String _pinInput = '';
  String _pinError = '';
  static const String _correctPin = '1234';

  String _selectedYear = '2026';
  final List<String> _years = ['2024', '2025', '2026'];

  final List<Map<String, dynamic>> _partners = [
    {
      'name': 'Faheem Khan',
      'phone': '0300-1234567',
      'role': 'Partner & Salesman',
      'share': 50,
      'joinDate': '2024-01-15',
      'status': 'Active',
      'yearlySales': {
        '2024': {
          'totalSales': 12,
          'totalRevenue': 85000000,
          'totalProfit': 3200000,
          'cars': [
            {'car': 'Toyota Corolla 2023', 'buyer': 'Ali Hassan', 'salePrice': 7200000, 'profit': 320000, 'date': '2024-03-10', 'type': 'Cash'},
            {'car': 'Honda City 2023', 'buyer': 'Usman Ali', 'salePrice': 5800000, 'profit': 280000, 'date': '2024-05-22', 'type': 'Cash'},
            {'car': 'Suzuki Cultus 2024', 'buyer': 'Bilal Malik', 'salePrice': 3800000, 'profit': 220000, 'date': '2024-07-15', 'type': 'Installment'},
            {'car': 'Toyota Yaris 2024', 'buyer': 'Hamza Tariq', 'salePrice': 5200000, 'profit': 250000, 'date': '2024-09-01', 'type': 'Cash'},
            {'car': 'Kia Sportage 2022', 'buyer': 'Farhan Raza', 'salePrice': 9500000, 'profit': 350000, 'date': '2024-11-18', 'type': 'Cash'},
          ],
        },
        '2025': {
          'totalSales': 15,
          'totalRevenue': 112000000,
          'totalProfit': 4500000,
          'cars': [
            {'car': 'MG HS 2024', 'buyer': 'Zain ul Abideen', 'salePrice': 9800000, 'profit': 380000, 'date': '2025-01-15', 'type': 'Cash'},
            {'car': 'Toyota Grande 2024', 'buyer': 'Ahmed Khan', 'salePrice': 8500000, 'profit': 350000, 'date': '2025-04-20', 'type': 'Cash'},
            {'car': 'Honda Civic 2023', 'buyer': 'Imran Shah', 'salePrice': 7200000, 'profit': 280000, 'date': '2025-07-12', 'type': 'Installment'},
            {'car': 'Hyundai Tucson 2022', 'buyer': 'Kashif Ali', 'salePrice': 11000000, 'profit': 420000, 'date': '2025-10-05', 'type': 'Cash'},
          ],
        },
        '2026': {
          'totalSales': 3,
          'totalRevenue': 25500000,
          'totalProfit': 950000,
          'cars': [
            {'car': 'Toyota Grande 2024', 'buyer': 'Ali Hassan', 'salePrice': 8500000, 'profit': 350000, 'date': '2026-02-05', 'type': 'Cash'},
            {'car': 'MG HS 2024', 'buyer': 'Zain ul Abideen', 'salePrice': 9800000, 'profit': 380000, 'date': '2026-01-15', 'type': 'Cash'},
            {'car': 'Honda Civic 2023', 'buyer': 'Ahmed Khan', 'salePrice': 7200000, 'profit': 220000, 'date': '2026-01-08', 'type': 'Cash'},
          ],
        },
      },
    },
    {
      'name': 'Inam Khan',
      'phone': '0321-9876543',
      'role': 'Partner & Salesman',
      'share': 50,
      'joinDate': '2024-01-15',
      'status': 'Active',
      'yearlySales': {
        '2024': {
          'totalSales': 10,
          'totalRevenue': 72000000,
          'totalProfit': 2800000,
          'cars': [
            {'car': 'Changan Alsvin 2024', 'buyer': 'Tariq Hussain', 'salePrice': 4600000, 'profit': 180000, 'date': '2024-02-20', 'type': 'Cash'},
            {'car': 'Suzuki Alto 2024', 'buyer': 'Kamran Akbar', 'salePrice': 3200000, 'profit': 150000, 'date': '2024-06-10', 'type': 'Cash'},
            {'car': 'Toyota Corolla 2024', 'buyer': 'Faisal Nawaz', 'salePrice': 6800000, 'profit': 300000, 'date': '2024-08-25', 'type': 'Installment'},
            {'car': 'Honda Civic 2022', 'buyer': 'Rashid Mehmood', 'salePrice': 6500000, 'profit': 280000, 'date': '2024-10-14', 'type': 'Cash'},
          ],
        },
        '2025': {
          'totalSales': 13,
          'totalRevenue': 95000000,
          'totalProfit': 3800000,
          'cars': [
            {'car': 'Kia Sportage 2023', 'buyer': 'Bilal Malik', 'salePrice': 10200000, 'profit': 400000, 'date': '2025-02-08', 'type': 'Cash'},
            {'car': 'Suzuki Swift 2024', 'buyer': 'Hamza Tariq', 'salePrice': 4500000, 'profit': 200000, 'date': '2025-05-15', 'type': 'Cash'},
            {'car': 'Toyota Yaris 2024', 'buyer': 'Usman Ali', 'salePrice': 5200000, 'profit': 250000, 'date': '2025-08-22', 'type': 'Installment'},
          ],
        },
        '2026': {
          'totalSales': 2,
          'totalRevenue': 14600000,
          'totalProfit': 520000,
          'cars': [
            {'car': 'Kia Sportage 2022', 'buyer': 'Usman Ali', 'salePrice': 9500000, 'profit': 300000, 'date': '2026-02-01', 'type': 'Cash'},
            {'car': 'Suzuki Cultus 2024', 'buyer': 'Bilal Malik', 'salePrice': 3800000, 'profit': 220000, 'date': '2026-01-28', 'type': 'Installment'},
          ],
        },
      },
    },
  ];

  Map<String, dynamic> _getYearData(Map<String, dynamic> partner) {
    final yearlySales = partner['yearlySales'] as Map<String, dynamic>;
    return yearlySales[_selectedYear] ?? {'totalSales': 0, 'totalRevenue': 0, 'totalProfit': 0, 'cars': []};
  }

  int get _yearTotalSales => _partners.fold(0, (s, p) => s + (_getYearData(p)['totalSales'] as int));
  int get _yearTotalRevenue => _partners.fold(0, (s, p) => s + (_getYearData(p)['totalRevenue'] as int));
  int get _yearTotalProfit => _partners.fold(0, (s, p) => s + (_getYearData(p)['totalProfit'] as int));

  void _showEditPartnerDialog(int index) {
    final partner = Map<String, dynamic>.from(_partners[index]);
    final nameCtrl = TextEditingController(text: partner['name']);
    final phoneCtrl = TextEditingController(text: partner['phone']);
    final roleCtrl = TextEditingController(text: partner['role']);
    final shareCtrl = TextEditingController(text: partner['share'].toString());

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Edit Partner Details", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 460),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _dialogField("Name", nameCtrl),
            _dialogField("Phone", phoneCtrl),
            _dialogField("Role", roleCtrl),
            _dialogField("Share (%)", shareCtrl, isNumber: true),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              setState(() {
                _partners[index] = {
                  ...partner,
                  'name': nameCtrl.text,
                  'phone': phoneCtrl.text,
                  'role': roleCtrl.text,
                  'share': int.tryParse(shareCtrl.text) ?? partner['share'],
                };
              });
              Navigator.pop(ctx);
            },
            child: const Text("Save Changes", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      ),
    );
  }

  void _showRemovePartnerDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Remove Partner", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Text(
          "Are you sure you want to remove ${_partners[index]['name']}? This action cannot be undone.",
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: () {
              setState(() => _partners.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      ),
    );
  }

  void _showAddPartnerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final shareCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text("Add New Partner", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 460),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _dialogField("Name", nameCtrl),
            _dialogField("Phone", phoneCtrl),
            _dialogField("Share (%)", shareCtrl, isNumber: true),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _partners.add({
                    'name': nameCtrl.text,
                    'phone': phoneCtrl.text,
                    'role': 'Partner & Salesman',
                    'share': int.tryParse(shareCtrl.text) ?? 0,
                    'joinDate': '2026-02-18',
                    'status': 'Active',
                    'yearlySales': {
                      '2024': {'totalSales': 0, 'totalRevenue': 0, 'totalProfit': 0, 'cars': []},
                      '2025': {'totalSales': 0, 'totalRevenue': 0, 'totalProfit': 0, 'cars': []},
                      '2026': {'totalSales': 0, 'totalRevenue': 0, 'totalProfit': 0, 'cars': []},
                    },
                  });
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text("Add Partner", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) return _buildLockScreen();
    return _buildMainContent();
  }

  Widget _buildLockScreen() {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: const Icon(FluentIcons.lock, size: 36, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            Text("Secured Module", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text("Salesmen & Profit Tracking is protected.\nEnter your PIN to access.", textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 0; i < 4; i++)
                Container(
                  width: 48, height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _pinError.isNotEmpty ? AppTheme.error : (i < _pinInput.length ? AppTheme.primary : AppTheme.divider),
                      width: i < _pinInput.length ? 2 : 1,
                    ),
                  ),
                  child: Center(child: Text(i < _pinInput.length ? "\u2022" : "", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
                ),
            ]),
            if (_pinError.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_pinError, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              child: Column(children: [
                for (int row = 0; row < 4; row++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (int col = 0; col < 3; col++)
                        () {
                          final nums = [['1','2','3'],['4','5','6'],['7','8','9'],['C','0','\u2713']];
                          final val = nums[row][col];
                          final isAction = val == 'C' || val == '\u2713';
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: 64, height: 48,
                              child: Button(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(val == '\u2713' ? AppTheme.primary : AppTheme.cardColor),
                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _pinError = '';
                                    if (val == 'C') {
                                      if (_pinInput.isNotEmpty) _pinInput = _pinInput.substring(0, _pinInput.length - 1);
                                    } else if (val == '\u2713') {
                                      if (_pinInput == _correctPin) {
                                        _isUnlocked = true;
                                      } else {
                                        _pinError = 'Incorrect PIN. Try again.';
                                        _pinInput = '';
                                      }
                                    } else if (_pinInput.length < 4) {
                                      _pinInput += val;
                                    }
                                  });
                                },
                                child: Text(val, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isAction ? 16 : 18, fontWeight: FontWeight.w600, color: val == '\u2713' ? Colors.white : AppTheme.textPrimary)),
                              ).withClickCursor,
                            ),
                          );
                        }(),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            Text("Default PIN: 1234", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
          ]),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;

      return ScaffoldPage.scrollable(
        padding: EdgeInsets.all(isNarrow ? 16 : 28),
        children: [
          // HEADER - Wrap prevents overflow on resize
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("Salesmen & Profit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(FluentIcons.lock, size: 10, color: AppTheme.success),
                      const SizedBox(width: 4),
                      Text("Secured", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 4),
                Text("Partners & profit tracking for Inam Motors", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
              ]),
              Wrap(spacing: 10, runSpacing: 8, children: [
                Button(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  ),
                  onPressed: () => setState(() { _isUnlocked = false; _pinInput = ''; _pinError = ''; }),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(FluentIcons.lock, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text("Lock", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  ]),
                ).withClickCursor,
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  ),
                  onPressed: _showAddPartnerDialog,
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(FluentIcons.add, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Add Partner", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ).withClickCursor,
              ]),
            ],
          ),

          const SizedBox(height: 24),

          // YEAR SELECTOR + SUMMARY
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(FluentIcons.calendar, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text("Year:", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(width: 10),
                ComboBox<String>(
                  value: _selectedYear,
                  items: _years.map((y) => ComboBoxItem<String>(value: y, child: Text(y, style: TextStyle(fontFamily: AppTheme.fontFamily)))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _selectedYear = v); },
                ),
              ]),
              Wrap(spacing: 12, runSpacing: 8, children: [
                _buildMiniStat("Sales", "$_yearTotalSales", AppTheme.primary),
                _buildMiniStat("Revenue", formatFullPrice(_yearTotalRevenue), AppTheme.info),
                _buildMiniStat("Profit", formatFullPrice(_yearTotalProfit), AppTheme.success),
              ]),
            ],
          ),

          const SizedBox(height: 24),

          // STAT CARDS
          if (isNarrow)
            Column(children: [
              Row(children: [
                StatCard(valueFontSize: 18, label: "Total Sales", value: "$_yearTotalSales", icon: FluentIcons.shopping_cart, color: AppTheme.primary),
                const SizedBox(width: 12),
                StatCard(valueFontSize: 18, label: "Revenue", value: formatFullPrice(_yearTotalRevenue), icon: FluentIcons.money, color: AppTheme.info),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                StatCard(valueFontSize: 18, label: "Net Profit", value: formatFullPrice(_yearTotalProfit), icon: FluentIcons.up, color: AppTheme.success),
                const SizedBox(width: 12),
                StatCard(valueFontSize: 18, label: "Partners", value: "${_partners.length}", icon: FluentIcons.people, color: AppTheme.warning),
              ]),
            ])
          else
            Row(children: [
              StatCard(valueFontSize: 18, label: "Total Sales", value: "$_yearTotalSales", icon: FluentIcons.shopping_cart, color: AppTheme.primary),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "Revenue", value: formatFullPrice(_yearTotalRevenue), icon: FluentIcons.money, color: AppTheme.info),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "Net Profit", value: formatFullPrice(_yearTotalProfit), icon: FluentIcons.up, color: AppTheme.success),
              const SizedBox(width: 16),
              StatCard(valueFontSize: 18, label: "Partners", value: "${_partners.length}", icon: FluentIcons.people, color: AppTheme.warning),
            ]),

          const SizedBox(height: 24),

          // PARTNERSHIP SHARE BAR
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Partnership Share", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Profit distribution ratio", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 28,
                  child: Row(
                    children: _partners.asMap().entries.map((e) {
                      final colors = [AppTheme.primary, AppTheme.info, AppTheme.warning, AppTheme.success];
                      return Expanded(
                        flex: e.value['share'] as int,
                        child: Container(
                          color: colors[e.key % colors.length],
                          child: Center(child: Text("${e.value['name']} - ${e.value['share']}%", overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // PARTNER CARDS
          Text("Partners - $_selectedYear Sales", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 14),

          ..._partners.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPartnerCard(e.value, e.key, isNarrow),
          )),

          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner, int index, bool isNarrow) {
    final yearData = _getYearData(partner);
    final cars = yearData['cars'] as List;

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(partner['name'].toString().substring(0, 1), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primary))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(partner['name'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text("${partner['role']} \u2022 ${partner['share']}% Share", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(partner['status'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
          ),
          const SizedBox(width: 6),
          IconButton(icon: Icon(FluentIcons.edit, size: 14, color: AppTheme.textMuted), onPressed: () => _showEditPartnerDialog(index)).withClickCursor,
          IconButton(icon: Icon(FluentIcons.delete, size: 14, color: AppTheme.error), onPressed: () => _showRemovePartnerDialog(index)).withClickCursor,
        ]),

        const SizedBox(height: 16),

        // Year stats
        if (isNarrow)
          Column(children: [
            Row(children: [
              Expanded(child: _buildDetail("Sales ($_selectedYear)", "${yearData['totalSales']}")),
              Expanded(child: _buildDetail("Revenue", formatFullPrice(yearData['totalRevenue']))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildDetail("Net Profit", formatFullPrice(yearData['totalProfit']), color: AppTheme.success)),
              Expanded(child: _buildDetail("Share", "${partner['share']}%")),
            ]),
          ])
        else
          Row(children: [
            Expanded(child: _buildDetail("Sales ($_selectedYear)", "${yearData['totalSales']}")),
            Expanded(child: _buildDetail("Revenue", formatFullPrice(yearData['totalRevenue']))),
            Expanded(child: _buildDetail("Net Profit", formatFullPrice(yearData['totalProfit']), color: AppTheme.success)),
            Expanded(child: _buildDetail("Share", "${partner['share']}%")),
          ]),

        const SizedBox(height: 16),

        // Contact row
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(FluentIcons.phone, size: 12, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Text(partner['phone'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
            const Spacer(),
            Icon(FluentIcons.calendar, size: 12, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Text("Since ${partner['joinDate']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
          ]),
        ),

        if (cars.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(children: [
            Icon(FluentIcons.car, size: 14, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text("Sales in $_selectedYear", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const Spacer(),
            Text("${cars.length} vehicles", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
          ]),
          const SizedBox(height: 10),

          if (!isNarrow)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                Expanded(flex: 3, child: Text("Vehicle", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                SizedBox(width: 100, child: Text("Buyer", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                SizedBox(width: 120, child: Text("Sale Price", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                SizedBox(width: 110, child: Text("Profit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                SizedBox(width: 80, child: Text("Date", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
                SizedBox(width: 70, child: Text("Type", textAlign: TextAlign.right, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted))),
              ]),
            ),

          ...cars.map((car) => isNarrow ? _buildCarCardMobile(car) : _buildCarRow(car)),
        ],

        if (cars.isEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text("No sales recorded for $_selectedYear", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted))),
          ),
        ],
      ]),
    );
  }

  Widget _buildCarRow(Map<String, dynamic> car) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)))),
      child: Row(children: [
        Expanded(flex: 3, child: Text(car['car'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
        SizedBox(width: 100, child: Text(car['buyer'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary))),
        SizedBox(width: 120, child: Text(formatFullPrice(car['salePrice']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary))),
        SizedBox(width: 110, child: Text(formatFullPrice(car['profit']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.success))),
        SizedBox(width: 80, child: Text(car['date'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted))),
        SizedBox(width: 70, child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (car['type'] == 'Cash' ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(car['type'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: car['type'] == 'Cash' ? AppTheme.success : AppTheme.warning)),
          ),
        )),
      ]),
    );
  }

  Widget _buildCarCardMobile(Map<String, dynamic> car) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(car['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: (car['type'] == 'Cash' ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(car['type'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: car['type'] == 'Cash' ? AppTheme.success : AppTheme.warning)),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Icon(FluentIcons.contact, size: 10, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(car['buyer'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(car['date'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Text("Sale: ${formatFullPrice(car['salePrice'])}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary)),
          const Spacer(),
          Text("Profit: ${formatFullPrice(car['profit'])}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success)),
        ]),
      ]),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text("$label: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
        Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  Widget _buildDetail(String label, String value, {Color? color}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: color ?? AppTheme.textPrimary)),
    ]);
  }

}

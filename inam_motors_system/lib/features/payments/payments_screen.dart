import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _selectedTab = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _payments = [
    {
      'id': 'PAY-001',
      'car': 'Kia Sportage 2022',
      'buyer': 'Usman Ali',
      'phone': '0321-5551234',
      'totalAmount': 9500000,
      'downPayment': 4000000,
      'paid': 5500000,
      'remaining': 4000000,
      'installments': 6,
      'paidInstallments': 2,
      'nextDue': '2026-03-01',
      'mode': 'Bank Transfer',
      'status': 'Active',
      'saleType': 'Installment',
    },
    {
      'id': 'PAY-002',
      'car': 'Hyundai Tucson 2022',
      'buyer': 'Farhan Raza',
      'phone': '0345-1112233',
      'totalAmount': 11000000,
      'downPayment': 5000000,
      'paid': 7000000,
      'remaining': 4000000,
      'installments': 8,
      'paidInstallments': 3,
      'nextDue': '2026-02-28',
      'mode': 'Cheque',
      'status': 'Active',
      'saleType': 'Installment',
    },
    {
      'id': 'PAY-003',
      'car': 'Toyota Grande 2024',
      'buyer': 'Ali Hassan',
      'phone': '0312-1234567',
      'totalAmount': 8500000,
      'downPayment': 8500000,
      'paid': 8500000,
      'remaining': 0,
      'installments': 0,
      'paidInstallments': 0,
      'nextDue': '-',
      'mode': 'Cash',
      'status': 'Completed',
      'saleType': 'Cash',
    },
    {
      'id': 'PAY-004',
      'car': 'MG HS 2024',
      'buyer': 'Zain ul Abideen',
      'phone': '0311-7778899',
      'totalAmount': 9800000,
      'downPayment': 9800000,
      'paid': 9800000,
      'remaining': 0,
      'installments': 0,
      'paidInstallments': 0,
      'nextDue': '-',
      'mode': 'Bank Transfer',
      'status': 'Completed',
      'saleType': 'Cash',
    },
    {
      'id': 'PAY-005',
      'car': 'Suzuki Cultus 2024',
      'buyer': 'Bilal Malik',
      'phone': '0333-6667890',
      'totalAmount': 3800000,
      'downPayment': 1500000,
      'paid': 2300000,
      'remaining': 1500000,
      'installments': 4,
      'paidInstallments': 1,
      'nextDue': '2026-02-15',
      'mode': 'Cash',
      'status': 'Overdue',
      'saleType': 'Installment',
    },
    {
      'id': 'PAY-006',
      'car': 'Changan Alsvin 2024',
      'buyer': 'Hamza Tariq',
      'phone': '0322-2223344',
      'totalAmount': 4600000,
      'downPayment': 2000000,
      'paid': 3200000,
      'remaining': 1400000,
      'installments': 5,
      'paidInstallments': 2,
      'nextDue': '2026-03-10',
      'mode': 'Cash',
      'status': 'Active',
      'saleType': 'Installment',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _payments.where((p) {
      if (_selectedTab == 'Active' && p['status'] != 'Active') return false;
      if (_selectedTab == 'Overdue' && p['status'] != 'Overdue') return false;
      if (_selectedTab == 'Completed' && p['status'] != 'Completed') return false;
      if (_selectedTab == 'Installment' && p['saleType'] != 'Installment') return false;
      if (_selectedTab == 'Cash' && p['saleType'] != 'Cash') return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p['buyer'].toString().toLowerCase().contains(q) ||
            p['car'].toString().toLowerCase().contains(q) ||
            p['id'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  String _formatPrice(int price) {
    if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return 'Rs ${(price / 1000).toStringAsFixed(0)}K';
    return 'Rs $price';
  }

  int get _activeCount => _payments.where((p) => p['status'] == 'Active').length;
  int get _overdueCount => _payments.where((p) => p['status'] == 'Overdue').length;
  int get _completedCount => _payments.where((p) => p['status'] == 'Completed').length;
  int get _totalReceived => _payments.fold(0, (s, p) => s + (p['paid'] as int));
  int get _totalRemaining => _payments.fold(0, (s, p) => s + (p['remaining'] as int));

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
              Text("Payments & Installments", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Track all payments, installments and due amounts", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
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
                Text("Record Payment", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ]),

          const SizedBox(height: 24),

          // STAT CARDS
          if (isNarrow)
            Column(children: [
              Row(children: [
                _buildStat("Total Received", _formatPrice(_totalReceived), FluentIcons.money, AppTheme.success),
                const SizedBox(width: 12),
                _buildStat("Remaining", _formatPrice(_totalRemaining), FluentIcons.clock, AppTheme.warning),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStat("Active Plans", "$_activeCount", FluentIcons.sync_folder, AppTheme.primary),
                const SizedBox(width: 12),
                _buildStat("Overdue", "$_overdueCount", FluentIcons.warning, AppTheme.error),
              ]),
            ])
          else
            Row(children: [
              _buildStat("Total Received", _formatPrice(_totalReceived), FluentIcons.money, AppTheme.success),
              const SizedBox(width: 16),
              _buildStat("Remaining", _formatPrice(_totalRemaining), FluentIcons.clock, AppTheme.warning),
              const SizedBox(width: 16),
              _buildStat("Active Plans", "$_activeCount", FluentIcons.sync_folder, AppTheme.primary),
              const SizedBox(width: 16),
              _buildStat("Overdue", "$_overdueCount", FluentIcons.warning, AppTheme.error),
            ]),

          const SizedBox(height: 24),

          // UPCOMING DUE DATES
          _buildUpcomingDues(isNarrow),

          const SizedBox(height: 24),

          // TOOLBAR
          if (isNarrow)
            Column(children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _buildTabChip("All", _payments.length),
                  const SizedBox(width: 8),
                  _buildTabChip("Active", _activeCount),
                  const SizedBox(width: 8),
                  _buildTabChip("Overdue", _overdueCount),
                  const SizedBox(width: 8),
                  _buildTabChip("Completed", _completedCount),
                  const SizedBox(width: 8),
                  _buildTabChip("Installment", _payments.where((p) => p['saleType'] == 'Installment').length),
                  const SizedBox(width: 8),
                  _buildTabChip("Cash", _payments.where((p) => p['saleType'] == 'Cash').length),
                ]),
              ),
            ])
          else
            Row(children: [
              Expanded(flex: 3, child: _buildSearchBar()),
              const SizedBox(width: 16),
              _buildTabChip("All", _payments.length),
              const SizedBox(width: 8),
              _buildTabChip("Active", _activeCount),
              const SizedBox(width: 8),
              _buildTabChip("Overdue", _overdueCount),
              const SizedBox(width: 8),
              _buildTabChip("Completed", _completedCount),
            ]),

          const SizedBox(height: 20),

          // PAYMENT CARDS
          ..._filtered.map((p) => _buildPaymentCard(p, isMedium)),

          if (_filtered.isEmpty) _buildEmpty(),

          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildUpcomingDues(bool isNarrow) {
    final dueSoon = _payments.where((p) => p['status'] == 'Active' || p['status'] == 'Overdue').toList()
      ..sort((a, b) => a['nextDue'].toString().compareTo(b['nextDue'].toString()));

    if (dueSoon.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(FluentIcons.event_date, size: 16, color: AppTheme.warning),
          const SizedBox(width: 8),
          Text("Upcoming Due Dates", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text("${dueSoon.length} pending", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.warning)),
          ),
        ]),
        const SizedBox(height: 16),
        ...dueSoon.take(3).map((p) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.5)))),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: (p['status'] == 'Overdue' ? AppTheme.error : AppTheme.warning).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                p['status'] == 'Overdue' ? FluentIcons.warning : FluentIcons.calendar,
                size: 16,
                color: p['status'] == 'Overdue' ? AppTheme.error : AppTheme.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['buyer'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text("${p['car']} \u2022 Due: ${p['nextDue']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_formatPrice(p['remaining']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: p['status'] == 'Overdue' ? AppTheme.error : AppTheme.textPrimary)),
              if (p['status'] == 'Overdue')
                Text("OVERDUE", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.error)),
            ]),
            const SizedBox(width: 8),
            // WhatsApp reminder button
            Tooltip(
              message: "Send WhatsApp Reminder",
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Icon(FluentIcons.chat, size: 14, color: AppTheme.success),
                ),
                onPressed: () => _showWhatsAppDialog(p),
              ),
            ),
          ]),
        )),
      ]),
    );
  }

  void _showEditPaymentDialog(Map<String, dynamic> p) {
    final paymentIndex = _payments.indexOf(p);
    if (paymentIndex == -1) return;

    final carCtrl = TextEditingController(text: p['car']);
    final buyerCtrl = TextEditingController(text: p['buyer']);
    final phoneCtrl = TextEditingController(text: p['phone']);
    final totalAmountCtrl = TextEditingController(text: p['totalAmount'].toString());
    final downPaymentCtrl = TextEditingController(text: p['downPayment'].toString());
    final paidCtrl = TextEditingController(text: p['paid'].toString());
    final remainingCtrl = TextEditingController(text: p['remaining'].toString());
    final installmentsCtrl = TextEditingController(text: p['installments'].toString());
    final paidInstallmentsCtrl = TextEditingController(text: p['paidInstallments'].toString());
    final nextDueCtrl = TextEditingController(text: p['nextDue']);
    String selectedMode = p['mode'];
    String selectedStatus = p['status'];
    String selectedSaleType = p['saleType'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: Text("Edit Payment ${p['id']}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 560),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _payEditField("Car", carCtrl),
            Row(children: [
              Expanded(child: _payEditField("Buyer Name", buyerCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _payEditField("Phone", phoneCtrl)),
            ]),
            Row(children: [
              Expanded(child: _payEditField("Total Amount", totalAmountCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _payEditField("Down Payment", downPaymentCtrl)),
            ]),
            Row(children: [
              Expanded(child: _payEditField("Paid Amount", paidCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _payEditField("Remaining", remainingCtrl)),
            ]),
            Row(children: [
              Expanded(child: _payEditField("Installments", installmentsCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _payEditField("Paid Installments", paidInstallmentsCtrl)),
            ]),
            _payEditField("Next Due Date (YYYY-MM-DD)", nextDueCtrl),
            Row(children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Payment Mode",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedMode,
                    isExpanded: true,
                    items: ['Cash', 'Bank Transfer', 'Cheque'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedMode = v); },
                  ),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Status",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: ['Active', 'Overdue', 'Completed'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedStatus = v); },
                  ),
                ),
              )),
            ]),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InfoLabel(
                label: "Sale Type",
                labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                child: ComboBox<String>(
                  value: selectedSaleType,
                  isExpanded: true,
                  items: ['Cash', 'Installment'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                  onChanged: (v) { if (v != null) setDialogState(() => selectedSaleType = v); },
                ),
              ),
            ),
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () {
              setState(() {
                _payments[paymentIndex] = {
                  ...p,
                  'car': carCtrl.text,
                  'buyer': buyerCtrl.text,
                  'phone': phoneCtrl.text,
                  'totalAmount': int.tryParse(totalAmountCtrl.text) ?? p['totalAmount'],
                  'downPayment': int.tryParse(downPaymentCtrl.text) ?? p['downPayment'],
                  'paid': int.tryParse(paidCtrl.text) ?? p['paid'],
                  'remaining': int.tryParse(remainingCtrl.text) ?? p['remaining'],
                  'installments': int.tryParse(installmentsCtrl.text) ?? p['installments'],
                  'paidInstallments': int.tryParse(paidInstallmentsCtrl.text) ?? p['paidInstallments'],
                  'nextDue': nextDueCtrl.text,
                  'mode': selectedMode,
                  'status': selectedStatus,
                  'saleType': selectedSaleType,
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

  Widget _payEditField(String label, TextEditingController ctrl) {
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

  void _showWhatsAppDialog(Map<String, dynamic> p) {
    final msg = "Assalam o Alaikum ${p['buyer']},\n\nThis is a gentle reminder from Inam Motors regarding your installment for ${p['car']}.\n\nRemaining Amount: ${_formatPrice(p['remaining'])}\nNext Due Date: ${p['nextDue']}\n\nKindly make the payment at your earliest convenience.\n\nThank you,\nInam Motors";

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(children: [
          Icon(FluentIcons.chat, size: 18, color: AppTheme.success),
          const SizedBox(width: 8),
          const Text("WhatsApp Reminder", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        ]),
        constraints: const BoxConstraints(maxWidth: 500),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text("To: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
            Text("${p['buyer']} (${p['phone']})", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
            child: Text(msg, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary, height: 1.5)),
          ),
        ]),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.success)),
            onPressed: () => Navigator.pop(ctx),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(FluentIcons.chat, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text("Copy & Send", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> p, bool isMedium) {
    final statusColor = _paymentStatusColor(p['status']);
    final progress = p['totalAmount'] > 0 ? (p['paid'] as int) / (p['totalAmount'] as int) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p['status'] == 'Overdue' ? AppTheme.error.withOpacity(0.3) : AppTheme.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top: ID + Status + Sale Type
        Row(children: [
          Text(p['id'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(p['status'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (p['saleType'] == 'Cash' ? AppTheme.success : AppTheme.info).withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              p['saleType'] == 'Cash' ? 'Cash Sale' : 'Installment Sale',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: p['saleType'] == 'Cash' ? AppTheme.success : AppTheme.info),
            ),
          ),
          const Spacer(),
          if (p['saleType'] == 'Installment') ...[
            // WhatsApp Reminder
            Tooltip(
              message: "Send WhatsApp Reminder",
              child: IconButton(
                icon: Icon(FluentIcons.chat, size: 14, color: AppTheme.success),
                onPressed: () => _showWhatsAppDialog(p),
              ),
            ),
          ],
          IconButton(icon: Icon(FluentIcons.edit, size: 14, color: AppTheme.primary), onPressed: () => _showEditPaymentDialog(p)),
          IconButton(icon: Icon(FluentIcons.view, size: 14, color: AppTheme.textSecondary), onPressed: () {}),
        ]),
        const SizedBox(height: 14),

        // Car & Buyer info
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: const Icon(FluentIcons.car, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Text("Buyer: ${p['buyer']} \u2022 ${p['phone']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
          ])),
        ]),
        const SizedBox(height: 16),

        // Payment Progress Bar
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Payment Progress", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              Text("${(progress * 100).toInt()}%", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: progress >= 1.0 ? AppTheme.success : AppTheme.primary)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: ProgressBar(
                  value: progress * 100,
                  backgroundColor: AppTheme.divider,
                  activeColor: progress >= 1.0 ? AppTheme.success : (p['status'] == 'Overdue' ? AppTheme.error : AppTheme.primary),
                ),
              ),
            ),
          ])),
        ]),
        const SizedBox(height: 14),

        // Amount breakdown
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
          child: isMedium
              ? Column(children: [
                  Row(children: [
                    _buildAmountItem("Total Amount", _formatPrice(p['totalAmount']), AppTheme.textPrimary),
                    _buildAmountItem("Down Payment", _formatPrice(p['downPayment']), AppTheme.info),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _buildAmountItem("Total Paid", _formatPrice(p['paid']), AppTheme.success),
                    _buildAmountItem("Remaining", _formatPrice(p['remaining']), p['remaining'] > 0 ? AppTheme.warning : AppTheme.success),
                  ]),
                ])
              : Row(children: [
                  _buildAmountItem("Total Amount", _formatPrice(p['totalAmount']), AppTheme.textPrimary),
                  _buildAmountItem("Down Payment", _formatPrice(p['downPayment']), AppTheme.info),
                  _buildAmountItem("Total Paid", _formatPrice(p['paid']), AppTheme.success),
                  _buildAmountItem("Remaining", _formatPrice(p['remaining']), p['remaining'] > 0 ? AppTheme.warning : AppTheme.success),
                ]),
        ),

        if (p['saleType'] == 'Installment') ...[
          const SizedBox(height: 12),
          // Installment details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              _buildDetailItem(FluentIcons.calendar, "Next Due", p['nextDue'], p['status'] == 'Overdue' ? AppTheme.error : AppTheme.textPrimary),
              _buildDetailItem(FluentIcons.number_field, "Installments", "${p['paidInstallments']}/${p['installments']}", AppTheme.textPrimary),
              _buildDetailItem(FluentIcons.payment_card, "Mode", p['mode'], AppTheme.textPrimary),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildAmountItem(String label, String value, Color valueColor) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
    ]));
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color valueColor) {
    return Expanded(child: Row(children: [
      Icon(icon, size: 12, color: AppTheme.textMuted),
      const SizedBox(width: 6),
      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: valueColor)),
      ])),
    ]));
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
      child: TextBox(
        placeholder: "Search by buyer, car or payment ID...",
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

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)), child: const Icon(FluentIcons.search, size: 32, color: AppTheme.primary)),
        const SizedBox(height: 16),
        Text("No payments found", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text("Try adjusting your search or filters", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
      ])),
    );
  }

  Color _paymentStatusColor(String status) {
    switch (status) {
      case 'Active': return AppTheme.primary;
      case 'Overdue': return AppTheme.error;
      case 'Completed': return AppTheme.success;
      default: return AppTheme.textSecondary;
    }
  }
}

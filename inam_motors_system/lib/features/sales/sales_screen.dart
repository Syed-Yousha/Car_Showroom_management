import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  final List<String> _statusFilters = ['All', 'Completed', 'Installment', 'Pending'];

  final List<Map<String, dynamic>> _sales = [
    {
      'id': 'INV-001',
      'car': 'Toyota Grande 2024',
      'buyer': 'Ali Hassan',
      'buyerPhone': '0300-1112233',
      'buyerCNIC': '35201-1234567-1',
      'salesman': 'Faheem Khan',
      'salePrice': 8500000,
      'purchasePrice': 7500000,
      'discount': 0,
      'saleDate': '2026-02-05',
      'paymentType': 'Cash',
      'status': 'Completed',
      'remarks': 'Full cash payment received',
    },
    {
      'id': 'INV-002',
      'car': 'MG HS 2024',
      'buyer': 'Zain ul Abideen',
      'buyerPhone': '0321-4455667',
      'buyerCNIC': '35202-7654321-9',
      'salesman': 'Faheem Khan',
      'salePrice': 9800000,
      'purchasePrice': 8800000,
      'discount': 0,
      'saleDate': '2026-01-15',
      'paymentType': 'Cash',
      'status': 'Completed',
      'remarks': '',
    },
    {
      'id': 'INV-003',
      'car': 'Honda Civic 2023',
      'buyer': 'Ahmed Khan',
      'buyerPhone': '0333-9988776',
      'buyerCNIC': '35203-1122334-5',
      'salesman': 'Faheem Khan',
      'salePrice': 7200000,
      'purchasePrice': 6200000,
      'discount': 0,
      'saleDate': '2026-01-08',
      'paymentType': 'Cash',
      'status': 'Completed',
      'remarks': 'Sold on open transfer',
    },
    {
      'id': 'INV-004',
      'car': 'Kia Sportage 2022',
      'buyer': 'Usman Ali',
      'buyerPhone': '0312-5566778',
      'buyerCNIC': '35204-9988776-3',
      'salesman': 'Inam Khan',
      'salePrice': 9500000,
      'purchasePrice': 8200000,
      'discount': 0,
      'saleDate': '2026-02-01',
      'paymentType': 'Cash',
      'status': 'Completed',
      'remarks': '',
    },
    {
      'id': 'INV-005',
      'car': 'Suzuki Cultus 2024',
      'buyer': 'Bilal Malik',
      'buyerPhone': '0345-1122334',
      'buyerCNIC': '35205-5566778-7',
      'salesman': 'Inam Khan',
      'salePrice': 3800000,
      'purchasePrice': 3200000,
      'discount': 100000,
      'saleDate': '2026-01-28',
      'paymentType': 'Installment',
      'status': 'Installment',
      'remarks': 'Rs 2,000,000 received. Remaining in 3 installments.',
    },
    {
      'id': 'INV-006',
      'car': 'Changan Alsvin 2024',
      'buyer': 'Tariq Hussain',
      'buyerPhone': '0300-6677889',
      'buyerCNIC': '35206-3344556-1',
      'salesman': 'Inam Khan',
      'salePrice': 4600000,
      'purchasePrice': 3800000,
      'discount': 0,
      'saleDate': '2025-12-20',
      'paymentType': 'Cash',
      'status': 'Completed',
      'remarks': '',
    },
  ];

  List<Map<String, dynamic>> get _filteredSales {
    return _sales.where((sale) {
      final matchesSearch = _searchQuery.isEmpty ||
          sale['car'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sale['buyer'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sale['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          sale['salesman'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || sale['status'] == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  String _formatPrice(int price) {
    if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return 'Rs ${(price / 1000).toStringAsFixed(0)}K';
    if (price == 0) return 'Rs 0';
    return 'Rs $price';
  }

  String _formatPriceFull(int price) {
    final str = price.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        result.write(',');
      }
      result.write(str[i]);
      count++;
    }
    return 'Rs ${result.toString().split('').reversed.join()}';
  }

  int get _totalRevenue => _sales.fold(0, (s, sale) => s + (sale['salePrice'] as int));
  int get _totalProfit => _sales.fold(0, (s, sale) => s + ((sale['salePrice'] as int) - (sale['purchasePrice'] as int) - (sale['discount'] as int)));
  int get _completedSales => _sales.where((s) => s['status'] == 'Completed').length;

  void _showEditSaleDialog(int index) {
    final sale = Map<String, dynamic>.from(_sales[index]);
    final carCtrl = TextEditingController(text: sale['car']);
    final buyerCtrl = TextEditingController(text: sale['buyer']);
    final buyerPhoneCtrl = TextEditingController(text: sale['buyerPhone']);
    final buyerCnicCtrl = TextEditingController(text: sale['buyerCNIC']);
    final salePriceCtrl = TextEditingController(text: sale['salePrice'].toString());
    final purchasePriceCtrl = TextEditingController(text: sale['purchasePrice'].toString());
    final discountCtrl = TextEditingController(text: sale['discount'].toString());
    final dateCtrl = TextEditingController(text: sale['saleDate']);
    final remarksCtrl = TextEditingController(text: sale['remarks']);
    String selectedSalesman = sale['salesman'];
    String selectedStatus = sale['status'];
    String selectedPaymentType = sale['paymentType'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ContentDialog(
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: const Icon(FluentIcons.edit, size: 14, color: AppTheme.primary),
            ),
            const SizedBox(width: 10),
            Text("Edit Sale - ${sale['id']}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
          ]),
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Car & Sale Info
              Row(children: [
                Expanded(child: _dialogField("Car / Vehicle", carCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _dialogField("Sale Date", dateCtrl)),
              ]),
              // Buyer Info
              Row(children: [
                Expanded(child: _dialogField("Buyer Name", buyerCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _dialogField("Buyer Phone", buyerPhoneCtrl)),
              ]),
              _dialogField("Buyer CNIC", buyerCnicCtrl),
              // Financials
              Row(children: [
                Expanded(child: _dialogField("Purchase Price (Rs)", purchasePriceCtrl, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _dialogField("Sale Price (Rs)", salePriceCtrl, isNumber: true)),
              ]),
              _dialogField("Discount (Rs)", discountCtrl, isNumber: true),
              // Dropdowns
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Salesman",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedSalesman,
                    isExpanded: true,
                    items: ['Faheem Khan', 'Inam Khan'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedSalesman = v); },
                  ),
                ),
              ),
              Row(children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: InfoLabel(
                      label: "Payment Type",
                      labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      child: ComboBox<String>(
                        value: selectedPaymentType,
                        isExpanded: true,
                        items: ['Cash', 'Installment'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                        onChanged: (v) { if (v != null) setDialogState(() => selectedPaymentType = v); },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: InfoLabel(
                      label: "Status",
                      labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      child: ComboBox<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        items: ['Completed', 'Installment', 'Pending'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                        onChanged: (v) { if (v != null) setDialogState(() => selectedStatus = v); },
                      ),
                    ),
                  ),
                ),
              ]),
              _dialogField("Remarks / Notes", remarksCtrl),
            ]),
          ),
          actions: [
            Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
            FilledButton(
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
              onPressed: () {
                setState(() {
                  _sales[index] = {
                    ...sale,
                    'car': carCtrl.text,
                    'buyer': buyerCtrl.text,
                    'buyerPhone': buyerPhoneCtrl.text,
                    'buyerCNIC': buyerCnicCtrl.text,
                    'salePrice': int.tryParse(salePriceCtrl.text) ?? sale['salePrice'],
                    'purchasePrice': int.tryParse(purchasePriceCtrl.text) ?? sale['purchasePrice'],
                    'discount': int.tryParse(discountCtrl.text) ?? sale['discount'],
                    'saleDate': dateCtrl.text,
                    'salesman': selectedSalesman,
                    'paymentType': selectedPaymentType,
                    'status': selectedStatus,
                    'remarks': remarksCtrl.text,
                  };
                });
                Navigator.pop(ctx);
              },
              child: const Text("Save Changes", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaleDetailsDialog(Map<String, dynamic> sale) {
    final profit = (sale['salePrice'] as int) - (sale['purchasePrice'] as int) - (sale['discount'] as int);

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: const Icon(FluentIcons.document_set, size: 14, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Text("Invoice ${sale['id']}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        ]),
        constraints: const BoxConstraints(maxWidth: 520),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Invoice Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text("INAM MOTORS", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(sale['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(sale['status'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: _getStatusColor(sale['status']))),
                  ),
                ]),
                const SizedBox(height: 4),
                Text("Tax Invoice / Sale Receipt", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              ]),
            ),
            const SizedBox(height: 16),

            // Vehicle Details
            _invoiceSection("Vehicle Details", [
              _invoiceRow("Vehicle", sale['car']),
              _invoiceRow("Invoice #", sale['id']),
              _invoiceRow("Sale Date", sale['saleDate']),
              _invoiceRow("Salesman", sale['salesman']),
            ]),
            const SizedBox(height: 12),

            // Buyer Details
            _invoiceSection("Buyer Details", [
              _invoiceRow("Name", sale['buyer']),
              _invoiceRow("Phone", sale['buyerPhone']),
              _invoiceRow("CNIC", sale['buyerCNIC']),
            ]),
            const SizedBox(height: 12),

            // Financial Breakdown
            _invoiceSection("Financial Summary", [
              _invoiceRow("Purchase Price", _formatPriceFull(sale['purchasePrice'])),
              _invoiceRow("Sale Price", _formatPriceFull(sale['salePrice'])),
              if ((sale['discount'] as int) > 0)
                _invoiceRow("Discount", "- ${_formatPriceFull(sale['discount'])}"),
              _invoiceRow("Payment Type", sale['paymentType']),
            ]),

            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (profit >= 0 ? AppTheme.success : AppTheme.error).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Net Profit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: profit >= 0 ? AppTheme.success : AppTheme.error)),
                Text(_formatPriceFull(profit), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: profit >= 0 ? AppTheme.success : AppTheme.error)),
              ]),
            ),

            if (sale['remarks'] != null && sale['remarks'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Remarks", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                  const SizedBox(height: 4),
                  Text(sale['remarks'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
                ]),
              ),
            ],
          ]),
        ),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Close", style: TextStyle(fontFamily: AppTheme.fontFamily))),
        ],
      ),
    );
  }

  Widget _invoiceSection(String title, List<Widget> rows) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
        child: Column(children: rows),
      ),
    ]);
  }

  Widget _invoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
        Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ]),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return AppTheme.success;
      case 'Installment': return AppTheme.warning;
      case 'Pending': return AppTheme.error;
      default: return AppTheme.textMuted;
    }
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
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;

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
                Text("Sales & Invoicing", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text("Manage all car sales, invoices & transaction details", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
              ]),
            ],
          ),

          const SizedBox(height: 24),

          // STATS
          if (isNarrow)
            Column(children: [
              Row(children: [
                _buildStat("Total Sales", "${_sales.length}", FluentIcons.shopping_cart, AppTheme.primary),
                const SizedBox(width: 12),
                _buildStat("Revenue", _formatPrice(_totalRevenue), FluentIcons.money, AppTheme.info),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStat("Net Profit", _formatPrice(_totalProfit), FluentIcons.up, AppTheme.success),
                const SizedBox(width: 12),
                _buildStat("Completed", "$_completedSales", FluentIcons.completed_solid, AppTheme.warning),
              ]),
            ])
          else
            Row(children: [
              _buildStat("Total Sales", "${_sales.length}", FluentIcons.shopping_cart, AppTheme.primary),
              const SizedBox(width: 16),
              _buildStat("Revenue", _formatPrice(_totalRevenue), FluentIcons.money, AppTheme.info),
              const SizedBox(width: 16),
              _buildStat("Net Profit", _formatPrice(_totalProfit), FluentIcons.up, AppTheme.success),
              const SizedBox(width: 16),
              _buildStat("Completed", "$_completedSales", FluentIcons.completed_solid, AppTheme.warning),
            ]),

          const SizedBox(height: 24),

          // SEARCH & FILTER
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : 300,
                child: TextBox(
                  placeholder: 'Search by car, buyer, invoice #, salesman...',
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(FluentIcons.search, size: 14, color: AppTheme.textMuted),
                  ),
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
                  decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider))),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              ComboBox<String>(
                value: _statusFilter,
                items: _statusFilters.map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _statusFilter = v); },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SALES LIST
          if (_filteredSales.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
              child: Center(child: Text("No sales found matching your criteria", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textMuted))),
            )
          else
            ..._filteredSales.asMap().entries.map((entry) {
              final idx = _sales.indexOf(entry.value);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSaleCard(entry.value, idx, isNarrow),
              );
            }),

          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildSaleCard(Map<String, dynamic> sale, int index, bool isNarrow) {
    final profit = (sale['salePrice'] as int) - (sale['purchasePrice'] as int) - (sale['discount'] as int);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(sale['id'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(sale['car'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _getStatusColor(sale['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
            child: Text(sale['status'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: _getStatusColor(sale['status']))),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(FluentIcons.view, size: 14, color: AppTheme.textMuted),
            onPressed: () => _showSaleDetailsDialog(sale),
          ),
          IconButton(
            icon: const Icon(FluentIcons.edit, size: 14, color: AppTheme.primary),
            onPressed: () => _showEditSaleDialog(index),
          ),
        ]),

        const SizedBox(height: 12),

        // Details
        if (isNarrow)
          Column(children: [
            Row(children: [
              Expanded(child: _buildDetailItem("Buyer", sale['buyer'], FluentIcons.contact)),
              Expanded(child: _buildDetailItem("Salesman", sale['salesman'], FluentIcons.people)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildDetailItem("Sale Price", _formatPrice(sale['salePrice']), FluentIcons.money)),
              Expanded(child: _buildDetailItem("Profit", _formatPrice(profit), FluentIcons.up, color: profit >= 0 ? AppTheme.success : AppTheme.error)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildDetailItem("Date", sale['saleDate'], FluentIcons.calendar)),
              Expanded(child: _buildDetailItem("Payment", sale['paymentType'], FluentIcons.payment_card)),
            ]),
          ])
        else
          Row(children: [
            Expanded(child: _buildDetailItem("Buyer", sale['buyer'], FluentIcons.contact)),
            Expanded(child: _buildDetailItem("Salesman", sale['salesman'], FluentIcons.people)),
            Expanded(child: _buildDetailItem("Sale Price", _formatPrice(sale['salePrice']), FluentIcons.money)),
            Expanded(child: _buildDetailItem("Profit", _formatPrice(profit), FluentIcons.up, color: profit >= 0 ? AppTheme.success : AppTheme.error)),
            Expanded(child: _buildDetailItem("Date", sale['saleDate'], FluentIcons.calendar)),
            Expanded(child: _buildDetailItem("Payment", sale['paymentType'], FluentIcons.payment_card)),
          ]),

        if (sale['remarks'] != null && sale['remarks'].toString().isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
            child: Row(children: [
              Icon(FluentIcons.info, size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Expanded(child: Text(sale['remarks'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textSecondary))),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, {Color? color}) {
    return Row(children: [
      Icon(icon, size: 12, color: AppTheme.textMuted),
      const SizedBox(width: 6),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, color: AppTheme.textMuted)),
        Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: color ?? AppTheme.textPrimary)),
      ])),
    ]);
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

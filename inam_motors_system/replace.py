import re

with open('lib/features/customers/customers_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

with open('old_block.txt', 'r', encoding='utf-8') as f:
    old_func = f.read()

new_func = r'''  void _showAddTransactionDialog(Map<String, dynamic> customer) {
    String txnType = 'Sell Car';
    bool isManualEntry = false;
    Map<String, dynamic>? selectedCar;
    int selectedCarPrice = 0;
    
    final amountCtrl = TextEditingController();
    
    String paymentType = 'Cash';
    final accNoCtrl = TextEditingController();
    final bankNameCtrl = TextEditingController();
    
    final tradeCarNameCtrl = TextEditingController();
    final tradeAmountCtrl = TextEditingController();
    
    final manualCarNameCtrl = TextEditingController();
    
    DateTime txnDate = DateTime.now();
    String? selectedSalesman;
    if (_salesmen.isNotEmpty) selectedSalesman = _salesmen.first;
    
    bool fileHandedOver = false;
    bool smartCardHandedOver = false;
    bool plateHandedOver = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Widget txnTypeChip(String label) {
            final sel = txnType == label;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setDialogState(() => txnType = label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }

          Widget paymentChip(String label) {
            final sel = paymentType == label;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setDialogState(() => paymentType = label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }

          return ContentDialog(
            title: const Text(
              'Add Transaction',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
            ),
            constraints: const BoxConstraints(maxWidth: 600),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Type',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      txnTypeChip('Sell Car'),
                      txnTypeChip('Payment'),
                      txnTypeChip('Trade-In'),
                      txnTypeChip('Credit Refund'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (txnType == 'Sell Car') ...[
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(!isManualEntry ? AppTheme.primary : AppTheme.cardColor),
                            ),
                            onPressed: () => setDialogState(() {
                              isManualEntry = false;
                            }),
                            child: Text('Select from Inventory', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: !isManualEntry ? Colors.white : AppTheme.textPrimary)),
                          ).withClickCursor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(isManualEntry ? AppTheme.primary : AppTheme.cardColor),
                            ),
                            onPressed: () => setDialogState(() => isManualEntry = true),
                            child: Text('Manual Entry', style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: isManualEntry ? Colors.white : AppTheme.textPrimary)),
                          ).withClickCursor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (!isManualEntry)
                      InfoLabel(
                        label: 'Select Car',
                        labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        child: AutoSuggestBox<Map<String, dynamic>>(
                          items: _availableCars.map((c) => AutoSuggestBoxItem<Map<String, dynamic>>(
                            value: c,
                            label: '${c['name']} - ${formatFullPrice(c['price'])}',
                          )).toList(),
                          onSelected: (item) {
                            setDialogState(() {
                              selectedCar = item.value;
                              selectedCarPrice = item.value?['price'] ?? 0;
                              amountCtrl.text = selectedCarPrice.toString();
                            });
                          },
                        ),
                      )
                    else
                      _editField("Manual Car Name/Details", manualCarNameCtrl),

                    const SizedBox(height: 12),
                    _editField("Final Sale Price (Rs)", amountCtrl),
                    
                    const SizedBox(height: 12),
                    Text(
                      "Documentation & Handover",
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    _buildDocStatusGrid(
                      fileHandedOver,
                      smartCardHandedOver,
                      plateHandedOver,
                      (f, s, p) => setDialogState(() {
                        fileHandedOver = f;
                        smartCardHandedOver = s;
                        plateHandedOver = p;
                      }),
                    ),
                  ],

                  if (txnType == 'Payment') ...[
                    _editField("Payment Amount (Rs)", amountCtrl),
                    const SizedBox(height: 2),
                    Text(
                      "Payment Method",
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        paymentChip('Cash'),
                        const SizedBox(width: 8),
                        paymentChip('Bank Transfer'),
                        const SizedBox(width: 8),
                        paymentChip('Cheque'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (paymentType != 'Cash') ...[
                      _editField("Bank Name", bankNameCtrl),
                      const SizedBox(height: 12),
                      _editField("Account / Cheque No.", accNoCtrl),
                    ],
                  ],

                  if (txnType == 'Trade-In') ...[
                    _editField("Car Name", tradeCarNameCtrl),
                    const SizedBox(height: 12),
                    _editField("Trade-In Value (Rs)", tradeAmountCtrl),
                    const SizedBox(height: 12),
                    Text(
                      "Documentation Received",
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    _buildDocStatusGrid(
                      fileHandedOver,
                      smartCardHandedOver,
                      plateHandedOver,
                      (f, s, p) => setDialogState(() {
                        fileHandedOver = f;
                        smartCardHandedOver = s;
                        plateHandedOver = p;
                      }),
                    ),
                  ],

                  if (txnType == 'Credit Refund') ...[
                    _editField("Refund Amount (Rs)", amountCtrl),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: InfoLabel(
                          label: 'Salesman',
                          labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                          child: ComboBox<String>(
                            value: selectedSalesman,
                            isExpanded: true,
                            items: _salesmen.map((s) => ComboBoxItem<String>(
                              value: s,
                              child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                            )).toList(),
                            onChanged: (v) {
                              if (v != null) setDialogState(() => selectedSalesman = v);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transaction Date",
                              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            DatePicker(
                              selected: txnDate,
                              onChanged: (d) => setDialogState(() => txnDate = d),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(fontFamily: AppTheme.fontFamily)),
              ).withClickCursor,
              FilledButton(
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
                onPressed: () {
                  final dateStr = '${txnDate.year}-${txnDate.month.toString().padLeft(2, '0')}-${txnDate.day.toString().padLeft(2, '0')}';
                  final ledger = customer['ledger'] as List<Map<String, dynamic>>;

                  if (txnType == 'Sell Car') {
                    final amt = int.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                    String detail = '';
                    if (isManualEntry) {
                      detail = manualCarNameCtrl.text.trim();
                      if (detail.isEmpty || amt <= 0) return;
                    } else {
                      if (selectedCar == null) return;
                      detail = selectedCar!['name'] as String;
                      if (amt <= 0) return;
                    }

                    setState(() {
                      ledger.add({
                        'date': dateStr,
                        'type': 'Car Sale',
                        'details': detail,
                        'debit': amt,
                        'credit': 0,
                        'salesman': selectedSalesman ?? '',
                        'file': fileHandedOver,
                        'smartCard': smartCardHandedOver,
                        'plate': plateHandedOver,
                      });
                      if (!isManualEntry && selectedCar != null) {
                        _availableCars.remove(selectedCar);
                      }
                    });
                  } else if (txnType == 'Payment') {
                    final amt = int.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                    if (amt <= 0) return;
                    
                    String detail = paymentType;
                    if (paymentType != 'Cash') {
                      final parts = <String>[];
                      if (bankNameCtrl.text.trim().isNotEmpty) parts.add(bankNameCtrl.text.trim());
                      if (accNoCtrl.text.trim().isNotEmpty) parts.add(accNoCtrl.text.trim());
                      detail = parts.isNotEmpty ? '$paymentType - ${parts.join(' / ')}' : paymentType;
                    }

                    setState(() {
                      ledger.add({
                        'date': dateStr,
                        'type': 'Payment',
                        'details': detail,
                        'debit': 0,
                        'credit': amt,
                        'salesman': selectedSalesman ?? '',
                      });
                    });
                  } else if (txnType == 'Trade-In') {
                    final amt = int.tryParse(tradeAmountCtrl.text.replaceAll(',', '')) ?? 0;
                    final detail = tradeCarNameCtrl.text.trim();
                    if (amt <= 0 || detail.isEmpty) return;

                    setState(() {
                      ledger.add({
                        'date': dateStr,
                        'type': 'Trade-In',
                        'details': detail,
                        'debit': 0,
                        'credit': amt,
                        'salesman': selectedSalesman ?? '',
                        'file': fileHandedOver,
                        'smartCard': smartCardHandedOver,
                        'plate': plateHandedOver,
                      });
                    });
                  } else if (txnType == 'Credit Refund') {
                    final amt = int.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
                    if (amt <= 0) return;

                    setState(() {
                      ledger.add({
                        'date': dateStr,
                        'type': 'Credit Refund',
                        'details': 'Credit Refund - Paid back to customer',
                        'debit': amt,
                        'credit': 0,
                        'salesman': selectedSalesman ?? '',
                      });
                    });
                  }

                  Navigator.pop(ctx);
                },
                child: const Text('Add Transaction', style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
              ).withClickCursor,
            ],
          );
        },
      ),
    );
  }

  Widget _transactionField'''

if old_func in text:
    text = text.replace(old_func, new_func)
    with open('lib/features/customers/customers_screen.dart', 'w', encoding='utf-8') as f:
        f.write(text)
    print('SUCCESS! Pattern replaced.')
else:
    print('FAILED to match exact old_func.')

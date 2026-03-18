import sys

with open('temp_dialog.txt', 'r', encoding='utf-8') as f:
    old_content = f.read()

new_content = old_content.replace(
    '    bool isManualEntry = false;\n    Map<String, dynamic>? selectedCar;\n    final carNameCtrl = TextEditingController();\n    final chassisCtrl = TextEditingController();\n    final engineCtrl = TextEditingController();\n    final priceCtrl = TextEditingController();\n    final notesCtrl = TextEditingController();\n    String selectedSalesman = _salesmen.first;',
    '    bool isManualEntry = false;\n    Map<String, dynamic>? selectedCar;\n    final carNameCtrl = TextEditingController();\n    final chassisCtrl = TextEditingController();\n    final engineCtrl = TextEditingController();\n    final priceCtrl = TextEditingController();\n    final notesCtrl = TextEditingController();\n    String selectedSalesman = _salesmen.first;\n    bool fileHandedOver = false;\n    bool smartCardHandedOver = false;\n    bool plateHandedOver = false;'
)

old_ui = '''                  if (!isManualEntry)
                    InfoLabel(
                      label: \\'Select Car\\',
                      labelStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                      child: ComboBox<Map<String, dynamic>>(
                        value: selectedCar,
                        isExpanded: true,
                        items: _availableCars
                            .map(
                              (car) => ComboBoxItem<Map<String, dynamic>>(
                                value: car,
                                child: Text(
                                  \\'\\ - \\\\',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedCar = v);
                        },
                      ),
                    )
                  else
                    Column(
                      children: [
                        _transactionField(\\'Car Name\\', carNameCtrl),
                        _transactionField(\\'Chassis No\\', chassisCtrl),
                        _transactionField(\\'Engine No\\', engineCtrl),
                        _transactionField(\\'Purchase Price (Rs)\\', priceCtrl),
                      ],
                    ),'''

new_ui = '''                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: !isManualEntry
                        ? InfoLabel(
                            key: const ValueKey(\\'inventory\\'),
                            label: \\'Select Car\\',
                            labelStyle: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                            child: AutoSuggestBox<Map<String, dynamic>>(
                              items: _availableCars.map((car) {
                                return AutoSuggestBoxItem<Map<String, dynamic>>(
                                  value: car,
                                  label: \\'\\ - \\\\',
                                );
                              }).toList(),
                              onSelected: (item) {
                                setDialogState(() => selectedCar = item.value);
                              },
                            ),
                          )
                        : Column(
                            key: const ValueKey(\\'manual\\'),
                            children: [
                              _transactionField(\\'Car Name\\', carNameCtrl),
                              _transactionField(\\'Chassis No\\', chassisCtrl),
                              _transactionField(\\'Engine No\\', engineCtrl),
                              _transactionField(\\'Sale Price (Rs)\\', priceCtrl),
                            ],
                          ),
                  ),'''

new_content = new_content.replace(old_ui, new_ui)

doc_status_ui = '''                  const SizedBox(height: 12),
                  Text(
                    "Documentation & Handover",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDocStatusGrid(
                    fileHandedOver,
                    smartCardHandedOver,
                    plateHandedOver,
                    (f, s, p) {
                      setDialogState(() {
                        fileHandedOver = f;
                        smartCardHandedOver = s;
                        plateHandedOver = p;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  InfoLabel(
                    label: \\'Salesman\\','''

new_content = new_content.replace('''                  const SizedBox(height: 12),
                  InfoLabel(
                    label: \\'Salesman\\',''', doc_status_ui)

add_action_old = '''              onPressed: () {
                Navigator.pop(ctx);
              },'''

add_action_new = '''              onPressed: () {
                int amt = int.tryParse(priceCtrl.text) ?? 0;
                String detail = '';
                
                if (selectedType == \\'Car Sale\\') {
                  if (isManualEntry) {
                    detail = carNameCtrl.text.trim();
                  } else if (selectedCar != null) {
                    detail = selectedCar![\\'name\\'] as String;
                    amt = selectedCar![\\'price\\'] as int;
                    setState(() {
                      _availableCars.remove(selectedCar);
                    });
                  }
                  
                  if (detail.isEmpty || amt <= 0) return;
                } else {
                  detail = notesCtrl.text.trim();
                  if (amt <= 0) return;
                }

                setState(() {
                  final dateStr = \\'\\-\\-\\\\';
                  final ledger = customer[\\'ledger\\'] as List<Map<String, dynamic>>;
                  
                  if (selectedType == \\'Car Sale\\') {
                    ledger.add({
                      \\'date\\': dateStr,
                      \\'type\\': selectedType,
                      \\'details\\': detail,
                      \\'debit\\': amt,
                      \\'credit\\': 0,
                      \\'salesman\\': selectedSalesman,
                      \\'file\\': fileHandedOver,
                      \\'smartCard\\': smartCardHandedOver,
                      \\'plate\\': plateHandedOver,
                    });
                  } else if (selectedType == \\'Payment\\') {
                    ledger.add({
                      \\'date\\': dateStr,
                      \\'type\\': selectedType,
                      \\'details\\': detail.isEmpty ? \\'Cash Payment\\' : detail,
                      \\'debit\\': 0,
                      \\'credit\\': amt,
                      \\'salesman\\': selectedSalesman,
                    });
                  } else if (selectedType == \\'Trade-In\\') {
                    ledger.add({
                      \\'date\\': dateStr,
                      \\'type\\': selectedType,
                      \\'details\\': detail,
                      \\'debit\\': 0,
                      \\'credit\\': amt,
                      \\'salesman\\': selectedSalesman,
                      \\'file\\': fileHandedOver,
                      \\'smartCard\\': smartCardHandedOver,
                      \\'plate\\': plateHandedOver,
                    });
                  } else if (selectedType == \\'Credit Refund\\') {
                    ledger.add({
                      \\'date\\': dateStr,
                      \\'type\\': selectedType,
                      \\'details\\': detail.isEmpty ? \\'Debit Refund\\' : detail,
                      \\'debit\\': amt,
                      \\'credit\\': 0,
                      \\'salesman\\': selectedSalesman,
                    });
                  }
                });

                Navigator.pop(ctx);
              },'''

new_content = new_content.replace(add_action_old, add_action_new)

with open('temp_dialog.txt', 'w', encoding='utf-8') as f:
    f.write(new_content)


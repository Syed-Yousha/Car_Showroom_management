import 'package:fluent_ui/fluent_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme.dart';

class DocumentTrackingScreen extends StatefulWidget {
  const DocumentTrackingScreen({super.key});

  @override
  State<DocumentTrackingScreen> createState() => _DocumentTrackingScreenState();
}

class _DocumentTrackingScreenState extends State<DocumentTrackingScreen> {
  String _searchQuery = '';
  String _docFilter = 'All'; // All | Pending | Cleared

  // ─────────────────────────────────────────────────────────────────────────
  //  Mock data — synchronized with inventory_screen.dart and customers_screen
  //  Rule:
  //    status: 'inOffice'   → document physically at Inam Motors
  //    status: 'handedOver' → given to buyer, recorded with name + date
  // ─────────────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _records = [
    // ── Toyota Grande 2024 · Available ────────────────────────────────────
    {
      'carName': 'Toyota Grande',
      'year': 2024,
      'regNo': 'LEA-7421',
      'chassisNo': 'JTDBR32E-860045123',
      'engineNo': '2ZR-FE-8924561',
      'carStatus': 'Available',
      'buyer': null,
      'file':      {'status': 'inOffice',   'to': null,            'date': null},
      'smartCard': {'status': 'inOffice',   'to': null,            'date': null},
      'plate':     {'status': 'inOffice',   'to': null,            'date': null},
      'remoteKey': {'status': 'inOffice',   'to': null,            'date': null},
    },
    // ── Honda Civic 2023 · Sold → Ahmed Khan (2026-02-03, all docs given) ─
    {
      'carName': 'Honda Civic',
      'year': 2023,
      'regNo': 'LHR-5532',
      'chassisNo': 'MRHGM66-560089745',
      'engineNo': 'R18Z1-7756231',
      'carStatus': 'Sold',
      'buyer': 'Ahmed Khan',
      'file':      {'status': 'handedOver', 'to': 'Ahmed Khan', 'date': '2026-02-03'},
      'smartCard': {'status': 'handedOver', 'to': 'Ahmed Khan', 'date': '2026-02-03'},
      'plate':     {'status': 'handedOver', 'to': 'Ahmed Khan', 'date': '2026-02-03'},
      'remoteKey': {'status': 'handedOver', 'to': 'Ahmed Khan', 'date': '2026-02-03'},
    },
    // ── Kia Sportage 2022 · Booked → Usman Ali (docs still pending) ───────
    {
      'carName': 'Kia Sportage',
      'year': 2022,
      'regNo': 'ISB-3918',
      'chassisNo': 'KNAPH81-220056789',
      'engineNo': 'G4FJ-2204587',
      'carStatus': 'Booked',
      'buyer': 'Usman Ali',
      'file':      {'status': 'inOffice', 'to': null, 'date': null},
      'smartCard': {'status': 'inOffice', 'to': null, 'date': null},
      'plate':     {'status': 'inOffice', 'to': null, 'date': null},
      'remoteKey': {'status': 'inOffice', 'to': null, 'date': null},
    },
    // ── Suzuki Cultus 2024 · Available ────────────────────────────────────
    {
      'carName': 'Suzuki Cultus',
      'year': 2024,
      'regNo': 'LEA-1105',
      'chassisNo': 'MBJHA36-240012345',
      'engineNo': 'K10B-2401234',
      'carStatus': 'Available',
      'buyer': null,
      'file':      {'status': 'inOffice', 'to': null, 'date': null},
      'smartCard': {'status': 'inOffice', 'to': null, 'date': null},
      'plate':     {'status': 'inOffice', 'to': null, 'date': null},
      'remoteKey': {'status': 'inOffice', 'to': null, 'date': null},
    },
    // ── Hyundai Tucson 2022 · Available ───────────────────────────────────
    {
      'carName': 'Hyundai Tucson',
      'year': 2022,
      'regNo': 'LHR-8890',
      'chassisNo': 'KMHJN81-220098765',
      'engineNo': 'G4FP-2209871',
      'carStatus': 'Available',
      'buyer': null,
      'file':      {'status': 'inOffice', 'to': null, 'date': null},
      'smartCard': {'status': 'inOffice', 'to': null, 'date': null},
      'plate':     {'status': 'inOffice', 'to': null, 'date': null},
      'remoteKey': {'status': 'inOffice', 'to': null, 'date': null},
    },
    // ── MG HS 2024 · Sold → Zain ul Abideen (file + smartCard + plate given)
    {
      'carName': 'MG HS',
      'year': 2024,
      'regNo': 'LEA-6677',
      'chassisNo': 'LSJWB48-240076543',
      'engineNo': '15S4G-2406543',
      'carStatus': 'Sold',
      'buyer': 'Zain ul Abideen',
      'file':      {'status': 'handedOver', 'to': 'Zain ul Abideen', 'date': '2026-01-15'},
      'smartCard': {'status': 'handedOver', 'to': 'Zain ul Abideen', 'date': '2026-01-15'},
      'plate':     {'status': 'handedOver', 'to': 'Zain ul Abideen', 'date': '2026-01-15'},
      'remoteKey': {'status': 'handedOver', 'to': 'Zain ul Abideen', 'date': '2026-01-15'},
    },
    // ── Changan Alsvin 2024 · Available ───────────────────────────────────
    {
      'carName': 'Changan Alsvin',
      'year': 2024,
      'regNo': 'MUL-2243',
      'chassisNo': 'LSCGB54-240034567',
      'engineNo': 'JL473Q5-2403456',
      'carStatus': 'Available',
      'buyer': null,
      'file':      {'status': 'inOffice', 'to': null, 'date': null},
      'smartCard': {'status': 'inOffice', 'to': null, 'date': null},
      'plate':     {'status': 'inOffice', 'to': null, 'date': null},
      'remoteKey': {'status': 'inOffice', 'to': null, 'date': null},
    },
    // ── Toyota Corolla 2024 · Available ───────────────────────────────────
    {
      'carName': 'Toyota Corolla',
      'year': 2024,
      'regNo': 'LEA-9034',
      'chassisNo': 'JTDKR32E-240067890',
      'engineNo': '1NZ-FE-2406789',
      'carStatus': 'Available',
      'buyer': null,
      'file':      {'status': 'inOffice', 'to': null, 'date': null},
      'smartCard': {'status': 'inOffice', 'to': null, 'date': null},
      'plate':     {'status': 'inOffice', 'to': null, 'date': null},
      'remoteKey': {'status': 'inOffice', 'to': null, 'date': null},
    },
  ];

  bool _rowMatchesDoc(Map<String, dynamic> r) {
    if (_docFilter == 'All') return true;
    final allDocs = [
      r['file'] as Map<String, dynamic>,
      r['smartCard'] as Map<String, dynamic>,
      r['plate'] as Map<String, dynamic>,
      if (r['remoteKey'] != null) r['remoteKey'] as Map<String, dynamic>,
    ];
    if (_docFilter == 'Pending') {
      // At least one doc is In Office for a booked/sold car
      return r['carStatus'] != 'Available' &&
          allDocs.any((d) => d['status'] == 'inOffice');
    }
    if (_docFilter == 'Cleared') {
      return allDocs.every((d) => d['status'] == 'handedOver');
    }
    if (_docFilter == 'Not Received') {
      return allDocs.any((d) => d['status'] == 'notReceived');
    }
    return true;
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchQuery.toLowerCase();
    return _records.where((r) {
      final matchSearch = q.isEmpty ||
          r['carName'].toString().toLowerCase().contains(q) ||
          r['chassisNo'].toString().toLowerCase().contains(q) ||
          r['engineNo'].toString().toLowerCase().contains(q) ||
          r['regNo'].toString().toLowerCase().contains(q);
      return matchSearch && _rowMatchesDoc(r);
    }).toList();
  }

  int get _inOfficeCount => _records
      .where((r) =>
          (r['file'] as Map)['status'] == 'inOffice' ||
          (r['smartCard'] as Map)['status'] == 'inOffice' ||
          (r['plate'] as Map)['status'] == 'inOffice' ||
          (r['remoteKey'] as Map?)?['status'] == 'inOffice')
      .length;

  int get _clearedCount => _records
      .where((r) =>
          (r['file'] as Map)['status'] == 'handedOver' &&
          (r['smartCard'] as Map)['status'] == 'handedOver' &&
          (r['plate'] as Map)['status'] == 'handedOver' &&
          (r['remoteKey'] as Map?)?['status'] == 'handedOver')
      .length;

  int get _pendingCount => _records
      .where((r) =>
          r['carStatus'] != 'Available' &&
          ((r['file'] as Map)['status'] == 'inOffice' ||
              (r['smartCard'] as Map)['status'] == 'inOffice' ||
              (r['plate'] as Map)['status'] == 'inOffice' ||
              (r['remoteKey'] as Map?)?['status'] == 'inOffice'))
      .length;

  int get _notReceivedCount => _records
      .where((r) =>
          (r['file'] as Map)['status'] == 'notReceived' ||
          (r['smartCard'] as Map)['status'] == 'notReceived' ||
          (r['plate'] as Map)['status'] == 'notReceived' ||
          (r['remoteKey'] as Map?)?['status'] == 'notReceived')
      .length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(bottom: BorderSide(color: AppTheme.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(FluentIcons.document_set, size: 20, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Docs & File Tracking",
                              style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                          Text("Track File, Smart Card and Number Plate handover status for all vehicles",
                              style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 12,
                                  color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // ── Stat chips ──────────────────────────────────────────
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _statChip("Total Vehicles", "${_records.length}", AppTheme.primary, FluentIcons.car),
                    _statChip("Docs In Office", "$_inOfficeCount", AppTheme.success, FluentIcons.office_store_logo),
                    _statChip("Handed Over", "$_clearedCount", const Color(0xFFF59E0B), FluentIcons.check_mark),
                    _statChip("Pending (Sold)", "$_pendingCount", AppTheme.error, FluentIcons.clock),
                    _statChip("Not Received", "$_notReceivedCount", AppTheme.error, FluentIcons.error),
                  ],
                ),
              ],
            ),
          ),

          // ── Toolbar ─────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(bottom: BorderSide(color: AppTheme.divider)),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Add Document Entry
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  ),
                  onPressed: () => _showAddDocumentDialog(),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(FluentIcons.add, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Add Document Entry', style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                  ]),
                ).withClickCursor,
                // Search
                SizedBox(
                  width: 250,
                  child: TextBox(
                    placeholder: "Search by Car Name, Chassis No, Engine No...",
                    placeholderStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(FluentIcons.search, size: 14, color: AppTheme.textMuted),
                    ),
                    decoration: WidgetStateProperty.all(BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.divider),
                    )),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                // Filter chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _filterChip('All'),
                    _filterChip('Pending'),
                    _filterChip('Cleared'),
                    _filterChip('Not Received'),
                  ],
                ),
                Text(
                  "${filtered.length} vehicle${filtered.length == 1 ? '' : 's'}",
                  style: TextStyle(
                      fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // ── Table ────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FluentIcons.document_search, size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text("No matching records",
                            style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14,
                                color: AppTheme.textMuted)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth < 1100 ? 1100 : constraints.maxWidth,
                              maxWidth: constraints.maxWidth < 1100 ? 1100 : constraints.maxWidth,
                            ),
                            child: Column(
                              children: [
                                // Table header
                                Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(children: [
                            _headerCell("Car Details", flex: 3),
                            _headerCell("Chassis / Engine", flex: 3),
                            _headerCell("File", flex: 2),
                            _headerCell("Smart Card", flex: 2),
                            _headerCell("Number Plate", flex: 2),
                            _headerCell("Remote / Key", flex: 2),
                            _headerCell("Actions", flex: 2),
                          ]),
                        ),
                        // Table rows
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius:
                                const BorderRadius.vertical(bottom: Radius.circular(10)),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Column(
                            children: filtered.asMap().entries.map((entry) {
                              final i = entry.key;
                              final r = entry.value;
                              return Container(
                                decoration: BoxDecoration(
                                  color: i.isEven
                                      ? AppTheme.cardColor
                                      : AppTheme.background.withValues(alpha: 0.5),
                                  border: i < filtered.length - 1
                                      ? Border(
                                          bottom: BorderSide(color: AppTheme.divider))
                                      : null,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(children: [
                                  // Car Details
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Text(
                                              "${r['carName']} ${r['year']}",
                                              style: TextStyle(
                                                  fontFamily: AppTheme.fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textPrimary),
                                            ),
                                            _statusBadge(r['carStatus'] as String),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          r['regNo'] as String,
                                          style: TextStyle(
                                              fontFamily: AppTheme.fontFamily,
                                              fontSize: 11,
                                              color: AppTheme.textMuted),
                                        ),
                                        if (r['buyer'] != null) ...[
                                          const SizedBox(height: 2),
                                          Row(children: [
                                            Icon(FluentIcons.contact,
                                                size: 10, color: AppTheme.primary),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                r['buyer'] as String,
                                                style: TextStyle(
                                                    fontFamily: AppTheme.fontFamily,
                                                    fontSize: 11,
                                                    color: AppTheme.primary,
                                                    fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Chassis / Engine
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r['chassisNo'] as String,
                                          style: TextStyle(
                                              fontFamily: AppTheme.fontFamily,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textPrimary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          r['engineNo'] as String,
                                          style: TextStyle(
                                              fontFamily: AppTheme.fontFamily,
                                              fontSize: 11,
                                              color: AppTheme.textMuted),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // File
                                  Expanded(flex: 2, child: _docStatusWidget(r['file'] as Map<String, dynamic>)),
                                  // Smart Card
                                  Expanded(flex: 2, child: _docStatusWidget(r['smartCard'] as Map<String, dynamic>)),
                                  // Plate
                                  Expanded(flex: 2, child: _docStatusWidget(r['plate'] as Map<String, dynamic>)),
                                  // Remote / Key
                                  Expanded(flex: 2, child: r['remoteKey'] != null ? _docStatusWidget(r['remoteKey'] as Map<String, dynamic>) : const SizedBox()),
                                  // Actions
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Tooltip(
                                          message: "Handover Slip",
                                          child: IconButton(
                                            icon: Icon(FluentIcons.print, size: 14, color: AppTheme.primary),
                                            onPressed: () => _showHandoverSlipPdf(r),
                                          ).withClickCursor,
                                        ),
                                        Tooltip(
                                          message: "Edit",
                                          child: IconButton(
                                            icon: Icon(FluentIcons.edit, size: 14, color: AppTheme.textMuted),
                                            onPressed: () => _showEditDocDialog(r),
                                          ).withClickCursor,
                                        ),
                                        Tooltip(
                                          message: "Remove",
                                          child: IconButton(
                                            icon: Icon(FluentIcons.delete, size: 14, color: AppTheme.error.withValues(alpha: 0.7)),
                                            onPressed: () => setState(() => _records.remove(r)),
                                          ).withClickCursor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                            ),
                          ),
                        );
                      }
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final active = _docFilter == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _docFilter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : AppTheme.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? AppTheme.primary : AppTheme.divider),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Sold':
        color = AppTheme.textMuted;
        break;
      case 'Booked':
        color = AppTheme.warning;
        break;
      default:
        color = AppTheme.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showEditDocDialog(Map<String, dynamic> record) {
    Map<String, dynamic> fileDoc = Map.from(record['file']);
    Map<String, dynamic> smartCardDoc = Map.from(record['smartCard']);
    Map<String, dynamic> plateDoc = Map.from(record['plate']);
    Map<String, dynamic> remoteKeyDoc = record['remoteKey'] != null
        ? Map.from(record['remoteKey'])
        : {'status': 'inOffice', 'to': null, 'date': null};

    String fileStatus = fileDoc['status'];
    String fileTo = fileDoc['to'] ?? record['buyer'] ?? '';
    String fileDate = fileDoc['date'] ?? DateTime.now().toString().split(' ')[0];

    String smartCardStatus = smartCardDoc['status'];
    String smartCardTo = smartCardDoc['to'] ?? record['buyer'] ?? '';
    String smartCardDate = smartCardDoc['date'] ?? DateTime.now().toString().split(' ')[0];

    String plateStatus = plateDoc['status'];
    String plateTo = plateDoc['to'] ?? record['buyer'] ?? '';
    String plateDate = plateDoc['date'] ?? DateTime.now().toString().split(' ')[0];

    String remoteKeyStatus = remoteKeyDoc['status'];
    String remoteKeyTo = remoteKeyDoc['to'] ?? record['buyer'] ?? '';
    String remoteKeyDate = remoteKeyDoc['date'] ?? DateTime.now().toString().split(' ')[0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Widget buildDocSection(
            String label,
            String status,
            String to,
            String date,
            ValueChanged<String?> onStatusChanged,
            ValueChanged<String> onToChanged,
            ValueChanged<String> onDateChanged,
          ) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _docStatusDropdown(label, status, onStatusChanged),
                if (status == 'handedOver') ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextBox(
                      placeholder: 'To (Customer/Buyer)',
                      controller: TextEditingController(text: to)..selection = TextSelection.collapsed(offset: to.length),
                      onChanged: onToChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextBox(
                      placeholder: 'Date (YYYY-MM-DD)',
                      controller: TextEditingController(text: date)..selection = TextSelection.collapsed(offset: date.length),
                      onChanged: onDateChanged,
                    ),
                  ),
                ],
              ],
            );
          }

          return ContentDialog(
            title: Text("Edit Documents for ${record['carName']}",
                style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
            constraints: const BoxConstraints(maxWidth: 520),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDocSection('File', fileStatus, fileTo, fileDate,
                    (v) => setDialogState(() => fileStatus = v!),
                    (v) => fileTo = v, (v) => fileDate = v),
                  buildDocSection('Smart Card', smartCardStatus, smartCardTo, smartCardDate,
                    (v) => setDialogState(() => smartCardStatus = v!),
                    (v) => smartCardTo = v, (v) => smartCardDate = v),
                  buildDocSection('Number Plate', plateStatus, plateTo, plateDate,
                    (v) => setDialogState(() => plateStatus = v!),
                    (v) => plateTo = v, (v) => plateDate = v),
                  buildDocSection('Remote / Key', remoteKeyStatus, remoteKeyTo, remoteKeyDate,
                    (v) => setDialogState(() => remoteKeyStatus = v!),
                    (v) => remoteKeyTo = v, (v) => remoteKeyDate = v),
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
                  setState(() {
                    record['file']['status'] = fileStatus;
                    if (fileStatus == 'handedOver') { record['file']['to'] = fileTo; record['file']['date'] = fileDate; }

                    record['smartCard']['status'] = smartCardStatus;
                    if (smartCardStatus == 'handedOver') { record['smartCard']['to'] = smartCardTo; record['smartCard']['date'] = smartCardDate; }

                    record['plate']['status'] = plateStatus;
                    if (plateStatus == 'handedOver') { record['plate']['to'] = plateTo; record['plate']['date'] = plateDate; }

                    record['remoteKey'] ??= {'status': 'inOffice', 'to': null, 'date': null};
                    record['remoteKey']['status'] = remoteKeyStatus;
                    if (remoteKeyStatus == 'handedOver') { record['remoteKey']['to'] = remoteKeyTo; record['remoteKey']['date'] = remoteKeyDate; }
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Save', style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
              ).withClickCursor,
            ],
          );
        },
      ),
    );
  }

  Widget _docStatusDropdown(String label, String value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InfoLabel(
        label: label,
        child: ComboBox<String>(
          value: value,
          isExpanded: true,
          items: const [
            ComboBoxItem(value: 'inOffice', child: Text('In Office')),
            ComboBoxItem(value: 'handedOver', child: Text('Handed Over')),
            ComboBoxItem(value: 'notReceived', child: Text('Not Received')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _docStatusWidget(Map<String, dynamic> doc) {
    final isHandedOver = doc['status'] == 'handedOver';
    final isNotReceived = doc['status'] == 'notReceived';
    
    Color color;
    IconData icon;
    String labelText;
    
    if (isHandedOver) {
      color = const Color(0xFFF59E0B);
      icon = FluentIcons.send;
      labelText = "Handed Over";
    } else if (isNotReceived) {
      color = AppTheme.error;
      icon = FluentIcons.error;
      labelText = "Not Received";
    } else {
      color = AppTheme.success;
      icon = FluentIcons.office_store_logo;
      labelText = "In Office";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 11, color: color),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                labelText,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (isHandedOver && doc['to'] != null) ...[
          const SizedBox(height: 3),
          Text(
            "To: ${doc['to']}",
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "on ${doc['date']}",
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  // ── Add Document Entry dialog ────────────────────────────────────────────
  void _showAddDocumentDialog() {
    final carModelCtrl    = TextEditingController();
    final yearCtrl        = TextEditingController();
    final regNoCtrl       = TextEditingController();
    final regNameCtrl     = TextEditingController();
    final carColorCtrl    = TextEditingController();
    final chassisNoCtrl   = TextEditingController();
    final engineNoCtrl    = TextEditingController();
    final buyerNameCtrl   = TextEditingController();
    final buyerPhoneCtrl  = TextEditingController();
    final extraNotesCtrl  = TextEditingController();

    String carStatus       = 'Available';
    String fileStatus      = 'inOffice';
    String smartCardStatus = 'inOffice';
    String plateStatus     = 'inOffice';
    String remoteKeyStatus = 'inOffice';
    DateTime? handoverDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return ContentDialog(
            title: const Text('Add Document Entry',
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Car Details ────────────────────────────────────────
                  Text('Car Details',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600,
                          fontSize: 13, color: AppTheme.primary)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: InfoLabel(label: 'Car Model *',
                        child: TextBox(controller: carModelCtrl, placeholder: 'e.g. Toyota Corolla',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))),
                    const SizedBox(width: 12),
                    SizedBox(width: 100, child: InfoLabel(label: 'Year',
                        child: TextBox(controller: yearCtrl, placeholder: '2024',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: InfoLabel(label: 'Reg No *',
                        child: TextBox(controller: regNoCtrl, placeholder: 'LEA-1234',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))),
                    const SizedBox(width: 12),
                    Expanded(child: InfoLabel(label: 'Car Color',
                        child: TextBox(controller: carColorCtrl, placeholder: 'White',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))),
                  ]),
                  const SizedBox(height: 10),
                  InfoLabel(label: 'Reg Name (Registered Owner)',
                      child: TextBox(controller: regNameCtrl, placeholder: 'Owner / registered name',
                          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13))),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: InfoLabel(label: 'Chassis No',
                        child: TextBox(controller: chassisNoCtrl, placeholder: 'Optional',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))),
                    const SizedBox(width: 12),
                    Expanded(child: InfoLabel(label: 'Engine No',
                        child: TextBox(controller: engineNoCtrl, placeholder: 'Optional',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))),
                  ]),
                  const SizedBox(height: 10),
                  InfoLabel(label: 'Car Status',
                      child: ComboBox<String>(
                        value: carStatus,
                        isExpanded: true,
                        items: const [
                          ComboBoxItem(value: 'Available', child: Text('Available')),
                          ComboBoxItem(value: 'Booked',    child: Text('Booked')),
                          ComboBoxItem(value: 'Sold',      child: Text('Sold')),
                        ],
                        onChanged: (v) => setDialogState(() => carStatus = v!),
                      )),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // ── Document Status ────────────────────────────────────
                  Text('Document Status',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600,
                          fontSize: 13, color: AppTheme.primary)),
                  const SizedBox(height: 10),
                  _docStatusDropdown('File', fileStatus,
                      (v) => setDialogState(() => fileStatus = v!)),
                  _docStatusDropdown('Smart Card', smartCardStatus,
                      (v) => setDialogState(() => smartCardStatus = v!)),
                  _docStatusDropdown('Number Plate', plateStatus,
                      (v) => setDialogState(() => plateStatus = v!)),
                  _docStatusDropdown('Remote / Key', remoteKeyStatus,
                      (v) => setDialogState(() => remoteKeyStatus = v!)),
                  const SizedBox(height: 4),
                  const Divider(),
                  const SizedBox(height: 12),

                  // ── Handover Details ───────────────────────────────────
                  Text('Handover Details',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600,
                          fontSize: 13, color: AppTheme.primary)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: InfoLabel(label: 'Customer Name',
                        child: TextBox(controller: buyerNameCtrl, placeholder: 'Buyer / customer name',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))),
                    const SizedBox(width: 12),
                    Expanded(child: InfoLabel(label: 'Customer Phone',
                        child: TextBox(controller: buyerPhoneCtrl, placeholder: '0300-1234567',
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))),
                  ]),
                  const SizedBox(height: 10),
                  InfoLabel(
                    label: 'Handover Date',
                    child: DatePicker(
                      selected: handoverDate,
                      onChanged: (d) => setDialogState(() => handoverDate = d),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InfoLabel(label: 'Extra Notes',
                      child: TextBox(
                        controller: extraNotesCtrl,
                        placeholder: 'Any additional notes...',
                        maxLines: 3,
                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
                      )),
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
                  if (carModelCtrl.text.trim().isEmpty || regNoCtrl.text.trim().isEmpty) return;
                  final hDate = handoverDate != null
                      ? '${handoverDate!.year}-${handoverDate!.month.toString().padLeft(2, '0')}-${handoverDate!.day.toString().padLeft(2, '0')}'
                      : null;
                  Map<String, dynamic> docEntry(String status) => {
                    'status': status,
                    'to': (status == 'handedOver' && buyerNameCtrl.text.trim().isNotEmpty)
                        ? buyerNameCtrl.text.trim()
                        : null,
                    'date': status == 'handedOver' ? hDate : null,
                  };
                  setState(() {
                    _records.add({
                      'carName':   carModelCtrl.text.trim(),
                      'year':      int.tryParse(yearCtrl.text.trim()) ?? DateTime.now().year,
                      'regNo':     regNoCtrl.text.trim(),
                      'chassisNo': chassisNoCtrl.text.trim().isEmpty ? '-' : chassisNoCtrl.text.trim(),
                      'engineNo':  engineNoCtrl.text.trim().isEmpty  ? '-' : engineNoCtrl.text.trim(),
                      'carStatus': carStatus,
                      'buyer':     buyerNameCtrl.text.trim().isEmpty ? null : buyerNameCtrl.text.trim(),
                      'regName':   regNameCtrl.text.trim(),
                      'carColor':  carColorCtrl.text.trim(),
                      'buyerPhone': buyerPhoneCtrl.text.trim(),
                      'extraNotes': extraNotesCtrl.text.trim(),
                      'file':      docEntry(fileStatus),
                      'smartCard': docEntry(smartCardStatus),
                      'plate':     docEntry(plateStatus),
                      'remoteKey': docEntry(remoteKeyStatus),
                    });
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Save', style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
              ).withClickCursor,
            ],
          );
        },
      ),
    );
  }

  // ── Handover Slip PDF ────────────────────────────────────────────────────
  Future<void> _showHandoverSlipPdf(Map<String, dynamic> record) async {
    final pdf = pw.Document();

    const primary     = PdfColor(0.486, 0.227, 0.929);   // #7C3AED purple
    const primaryLight = PdfColor(0.933, 0.918, 1.0);     // #EDE9FE
    const textDark    = PdfColor(0.118, 0.106, 0.294);    // #1E1B4B
    const textGray    = PdfColor(0.420, 0.447, 0.502);    // #6B7280
    const borderGray  = PdfColor(0.898, 0.906, 0.922);    // #E5E7EB
    const greenFill   = PdfColor(0.820, 0.980, 0.906);    // #D1FAE5
    const greenText   = PdfColor(0.063, 0.725, 0.506);    // #10B981
    const redFill     = PdfColor(0.996, 0.886, 0.886);    // #FEE2E2
    const redText     = PdfColor(0.937, 0.267, 0.267);    // #EF4444
    const noteFill    = PdfColor(1.0,   0.984, 0.922);    // #FFFBEB
    const noteBorder  = PdfColor(0.992, 0.906, 0.541);    // #FDE68A

    pw.Widget sectionTitle(String title) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primary, width: 1.5)),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primary)),
    );

    pw.Widget slipRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
              width: 140,
              child: pw.Text(label,
                  style: const pw.TextStyle(fontSize: 10, color: textGray))),
          pw.Text(':  ', style: const pw.TextStyle(fontSize: 10, color: textGray)),
          pw.Expanded(
              child: pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark))),
        ],
      ),
    );

    pw.Widget docItem(String label, String status) {
      final isHandedOver  = status == 'handedOver';
      final isNotReceived = status == 'notReceived';
      final statusLabel   = isHandedOver ? 'Handed Over' : isNotReceived ? 'Not Received' : 'In Office';
      final itemFill  = isHandedOver ? greenFill  : isNotReceived ? redFill  : primaryLight;
      final itemText  = isHandedOver ? greenText  : isNotReceived ? redText  : textGray;
      final itemBorder= isHandedOver ? greenText  : isNotReceived ? redText  : borderGray;

      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        child: pw.Row(
          children: [
            pw.Container(
              width: 18, height: 18,
              decoration: pw.BoxDecoration(
                color: itemFill,
                border: pw.Border.all(color: itemBorder),
                borderRadius: pw.BorderRadius.circular(3),
              ),
              alignment: pw.Alignment.center,
              child: isHandedOver
                  ? pw.Text('✓',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: greenText))
                  : pw.SizedBox(),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                child: pw.Text(label,
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark))),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: pw.BoxDecoration(
                color: itemFill,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(statusLabel,
                  style: pw.TextStyle(fontSize: 9, color: itemText)),
            ),
          ],
        ),
      );
    }

    final carName        = '${record['carName']} ${record['year']}';
    final regNo          = (record['regNo']  as String?) ?? '-';
    final chassis        = (record['chassisNo'] as String?) ?? '-';
    final engine         = (record['engineNo']  as String?) ?? '-';
    final carStatus      = (record['carStatus'] as String?) ?? '-';
    final buyer          = (record['buyer']     as String?) ?? '-';
    final regName        = (record['regName']   as String?) ?? '-';
    final buyerPhone     = (record['buyerPhone'] as String?) ?? '-';
    final extraNotes     = (record['extraNotes'] as String?) ?? '';

    final fileStatus       = (record['file']      as Map?)?['status'] as String? ?? 'inOffice';
    final smartCardStatus  = (record['smartCard']  as Map?)?['status'] as String? ?? 'inOffice';
    final plateStatus      = (record['plate']      as Map?)?['status'] as String? ?? 'inOffice';
    final remoteKeyStatus  = (record['remoteKey']  as Map?)?['status'] as String? ?? 'inOffice';

    final handoverDate =
        (record['file'] as Map?)?['date'] as String? ??
        (record['smartCard'] as Map?)?['date'] as String? ??
        DateTime.now().toString().split(' ')[0];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // ── Header ──────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: primary,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('DOCUMENT HANDOVER RECEIPT',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('Inam Motors — Official Document Transfer Record',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColor(0.867, 0.839, 0.996))),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Inam Motors',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('Date: $handoverDate',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColor(0.867, 0.839, 0.996))),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),

          // ── Vehicle Details ──────────────────────────────────────────
          sectionTitle('Vehicle Details'),
          slipRow('Car Name / Model', carName),
          slipRow('Registration No.', regNo),
          slipRow('Chassis No.', chassis),
          slipRow('Engine No.', engine),
          slipRow('Car Status', carStatus),

          // ── Receiver Details ─────────────────────────────────────────
          sectionTitle('Receiver Details'),
          slipRow('Customer / Buyer', buyer == '-' ? 'N/A' : buyer),
          slipRow('Phone', buyerPhone == '-' ? 'N/A' : buyerPhone),
          slipRow('Reg. Owner (Name)', regName == '-' ? 'N/A' : regName),
          slipRow('Handover Date', handoverDate),

          // ── Document Checklist ───────────────────────────────────────
          sectionTitle('Document Handover Checklist'),
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: pw.BoxDecoration(
              color: const PdfColor(0.976, 0.980, 0.984),
              border: pw.Border.all(color: borderGray),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                docItem('Vehicle File (Registration Book)', fileStatus),
                pw.Divider(color: borderGray, height: 1),
                docItem('Smart Card', smartCardStatus),
                pw.Divider(color: borderGray, height: 1),
                docItem('Number Plate', plateStatus),
                pw.Divider(color: borderGray, height: 1),
                docItem('Remote / Key', remoteKeyStatus),
              ],
            ),
          ),

          // ── Extra Notes ──────────────────────────────────────────────
          if (extraNotes.isNotEmpty) ...[
            sectionTitle('Extra Notes'),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: noteFill,
                border: pw.Border.all(color: noteBorder),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(extraNotes,
                  style: const pw.TextStyle(fontSize: 10, color: textDark)),
            ),
          ],

          pw.SizedBox(height: 50),

          // ── Signature lines ──────────────────────────────────────────
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(height: 1, color: textDark),
                    pw.SizedBox(height: 8),
                    pw.Text('Authorized Signature (Inam Motors)',
                        style: const pw.TextStyle(fontSize: 9, color: textGray)),
                  ],
                ),
              ),
              pw.SizedBox(width: 60),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(height: 1, color: textDark),
                    pw.SizedBox(height: 8),
                    pw.Text('Customer Signature',
                        style: const pw.TextStyle(fontSize: 9, color: textGray)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 24),
          pw.Center(
            child: pw.Text(
              'This document is generated by Inam Motors Management System',
              style: const pw.TextStyle(fontSize: 8, color: textGray),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Handover_Slip_${record['regNo']}_${record['carName']}.pdf',
    );
  }
}

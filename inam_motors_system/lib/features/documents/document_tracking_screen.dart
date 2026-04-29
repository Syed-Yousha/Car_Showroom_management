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
      return allDocs.every((d) => d['status'] == 'handedOver' || d['status'] == 'notAvailable');
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
      .where((r) {
        bool done(Map? d) =>
            d == null || d['status'] == 'handedOver' || d['status'] == 'notAvailable';
        return done(r['file'] as Map?) &&
            done(r['smartCard'] as Map?) &&
            done(r['plate'] as Map?) &&
            done(r['remoteKey'] as Map?);
      })
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
      padding:  EdgeInsets.zero,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 54, 28, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Docs & File Tracking",
                          style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text("Track File, Smart Card and Number Plate handover status for all vehicles",
                          style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                    shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  ),
                  onPressed: () => _showAddDocumentDialog(),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(FluentIcons.add, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Add Document Entry',
                        style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.white)),
                  ]),
                ).withClickCursor,
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Stat chips ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Wrap(
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
          ),

          const SizedBox(height: 16),

          // ── Toolbar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 700;
                return wide
                    ? Row(
                        children: [
                          // Search
                          Flexible(
                            flex: 3,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: _searchBox(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Filter chips
                          Flexible(
                            flex: 5,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _filterChip('All'),
                                _filterChip('Pending'),
                                _filterChip('Cleared'),
                                _filterChip('Not Received'),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${filtered.length} vehicle${filtered.length == 1 ? '' : 's'}",
                            style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                color: AppTheme.textMuted),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _searchBox(),
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 8),
                          Text(
                            "${filtered.length} vehicle${filtered.length == 1 ? '' : 's'}",
                            style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                color: AppTheme.textMuted),
                          ),
                        ],
                      );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Table / Cards ─────────────────────────────────────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (context, outerConstraints) {
                // ── Empty state ──────────────────────────────────────────────
                if (filtered.isEmpty) {
                  return Center(
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
                  );
                }

                // ── Narrow → Card layout (no horizontal overflow possible) ──
                if (outerConstraints.maxWidth < 850) {
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final r = filtered[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Top: car info + action buttons ───────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
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
                                      const SizedBox(height: 2),
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
                                          const SizedBox(width: 4),
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
                                // Actions
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if ((r['extraNotes'] as String? ?? '').trim().isNotEmpty)
                                      Tooltip(
                                        message: "Note Entered",
                                        child: IconButton(
                                          icon: Icon(FluentIcons.quick_note,
                                              size: 14, color: const Color(0xFFF59E0B)),
                                          onPressed: () => _showExtraNoteDialog(r),
                                        ).withClickCursor,
                                      ),
                                    Tooltip(
                                      message: "Handover Slip",
                                      child: IconButton(
                                        icon: Icon(FluentIcons.print,
                                            size: 14, color: AppTheme.primary),
                                        onPressed: () => _showHandoverSlipPdf(r),
                                      ).withClickCursor,
                                    ),
                                    Tooltip(
                                      message: "Edit",
                                      child: IconButton(
                                        icon: Icon(FluentIcons.edit,
                                            size: 14, color: AppTheme.textMuted),
                                        onPressed: () => _showEditDocDialog(r),
                                      ).withClickCursor,
                                    ),
                                    Tooltip(
                                      message: "Remove",
                                      child: IconButton(
                                        icon: Icon(FluentIcons.delete,
                                            size: 14,
                                            color: AppTheme.error.withValues(alpha: 0.7)),
                                        onPressed: () =>
                                            setState(() => _records.remove(r)),
                                      ).withClickCursor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // ── Middle: Chassis / Engine ─────────────────
                            const SizedBox(height: 6),
                            Text(
                              r['chassisNo'] as String,
                              style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              r['engineNo'] as String,
                              style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                  color: AppTheme.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                            // ── Bottom: Doc status chips ─────────────────
                            const SizedBox(height: 10),
                            Container(height: 1, color: AppTheme.divider),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _docMiniChip('File', r['file'] as Map<String, dynamic>),
                                _docMiniChip('Smart Card', r['smartCard'] as Map<String, dynamic>),
                                _docMiniChip('Number Plate', r['plate'] as Map<String, dynamic>),
                                if (r['remoteKey'] != null)
                                  _docMiniChip('Remote / Key', r['remoteKey'] as Map<String, dynamic>),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                // ── Wide → horizontal-scrollable table ───────────────────────
                // Content width = at least 1000 px; grows to fill larger screens.
                final double tableWidth = outerConstraints.maxWidth > 1056
                    ? outerConstraints.maxWidth - 56
                    : 1000.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20, bottom: 28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Column(
                          children: [
                            // Header
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(children: [
                                _headerCell("Car Details", flex: 3),
                                _headerCell("Chassis / Engine", flex: 3),
                                _headerCell("File", flex: 2),
                                _headerCell("Smart Card", flex: 2),
                                _headerCell("Number Plate", flex: 2),
                                _headerCell("Remote / Key", flex: 2),
                                _headerCell("Actions", flex: 2, textAlign: TextAlign.end),
                              ]),
                            ),
                            // Rows
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(10)),
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
                                          ? Border(bottom: BorderSide(color: AppTheme.divider))
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
                                            Text(r['regNo'] as String,
                                                style: TextStyle(
                                                    fontFamily: AppTheme.fontFamily,
                                                    fontSize: 11,
                                                    color: AppTheme.textMuted)),
                                            if (r['buyer'] != null) ...[
                                              const SizedBox(height: 2),
                                              Row(children: [
                                                Icon(FluentIcons.contact,
                                                    size: 10, color: AppTheme.primary),
                                                const SizedBox(width: 3),
                                                Expanded(
                                                  child: Text(r['buyer'] as String,
                                                      style: TextStyle(
                                                          fontFamily: AppTheme.fontFamily,
                                                          fontSize: 11,
                                                          color: AppTheme.primary,
                                                          fontWeight: FontWeight.w500),
                                                      overflow: TextOverflow.ellipsis),
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
                                            Text(r['chassisNo'] as String,
                                                style: TextStyle(
                                                    fontFamily: AppTheme.fontFamily,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.textPrimary),
                                                overflow: TextOverflow.ellipsis),
                                            const SizedBox(height: 3),
                                            Text(r['engineNo'] as String,
                                                style: TextStyle(
                                                    fontFamily: AppTheme.fontFamily,
                                                    fontSize: 11,
                                                    color: AppTheme.textMuted),
                                                overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                      // File
                                      Expanded(flex: 2, child: _docStatusWidget(r['file'] as Map<String, dynamic>)),
                                      // Smart Card
                                      Expanded(flex: 2, child: _docStatusWidget(r['smartCard'] as Map<String, dynamic>)),
                                      // Number Plate
                                      Expanded(flex: 2, child: _docStatusWidget(r['plate'] as Map<String, dynamic>, isPlate: true)),
                                      // Remote / Key
                                      Expanded(flex: 2, child: r['remoteKey'] != null ? _docStatusWidget(r['remoteKey'] as Map<String, dynamic>) : const SizedBox()),
                                      // Actions
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            if ((r['extraNotes'] as String? ?? '').trim().isNotEmpty)
                                              Tooltip(
                                                message: "Note Entered",
                                                child: IconButton(
                                                  icon: Icon(FluentIcons.quick_note,
                                                      size: 14, color: const Color(0xFFF59E0B)),
                                                  onPressed: () => _showExtraNoteDialog(r),
                                                ).withClickCursor,
                                              ),
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return TextBox(
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

  Widget _headerCell(String label, {int flex = 1, TextAlign textAlign = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textMuted,
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

  void _showExtraNoteDialog(Map<String, dynamic> record) {
    final note = (record['extraNotes'] as String? ?? '').trim();
    if (note.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.quick_note, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text(
              "Document Note",
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 460),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: SelectableText(
            note,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        actions: [
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close",
                style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      ),
    );
  }

  void _showEditDocDialog(Map<String, dynamic> record) {
    // Car Details
    final carModelCtrl  = TextEditingController(text: record['carName'] ?? '');
    final yearCtrl      = TextEditingController(text: record['year']?.toString() ?? '');
    final regNoCtrl     = TextEditingController(text: record['regNo'] ?? '');
    final regNameCtrl   = TextEditingController(text: record['regName'] ?? '');
    final carColorCtrl  = TextEditingController(text: record['carColor'] ?? '');
    final chassisNoCtrl = TextEditingController(
        text: (record['chassisNo'] == '-' ? '' : (record['chassisNo'] ?? '')));
    final engineNoCtrl  = TextEditingController(
        text: (record['engineNo'] == '-' ? '' : (record['engineNo'] ?? '')));
    String carStatus = record['carStatus'] ?? 'Available';

    // Document statuses + per-doc handover details
    Map<String, dynamic> fileDoc = Map.from(record['file']);
    Map<String, dynamic> smartCardDoc = Map.from(record['smartCard']);
    Map<String, dynamic> plateDoc = Map.from(record['plate']);
    Map<String, dynamic> remoteKeyDoc = record['remoteKey'] != null
        ? Map.from(record['remoteKey'])
        : {'status': 'inOffice', 'to': null, 'date': null};

    String fileStatus = fileDoc['status'];
    final fileToCtrl = TextEditingController(
        text: fileDoc['to'] ?? record['buyer'] ?? '');
    final filePhoneCtrl = TextEditingController(
        text: fileDoc['phone'] ?? record['buyerPhone'] ?? '');
    DateTime? fileDate = DateTime.tryParse(fileDoc['date'] ?? '');

    String smartCardStatus = smartCardDoc['status'];
    final smartCardToCtrl = TextEditingController(
        text: smartCardDoc['to'] ?? record['buyer'] ?? '');
    final smartCardPhoneCtrl = TextEditingController(
        text: smartCardDoc['phone'] ?? record['buyerPhone'] ?? '');
    DateTime? smartCardDate = DateTime.tryParse(smartCardDoc['date'] ?? '');

    String plateStatus = plateDoc['status'];
    final plateToCtrl = TextEditingController(
        text: plateDoc['to'] ?? record['buyer'] ?? '');
    final platePhoneCtrl = TextEditingController(
        text: plateDoc['phone'] ?? record['buyerPhone'] ?? '');
    DateTime? plateDate = DateTime.tryParse(plateDoc['date'] ?? '');

    String remoteKeyStatus = remoteKeyDoc['status'];
    final remoteKeyToCtrl = TextEditingController(
        text: remoteKeyDoc['to'] ?? record['buyer'] ?? '');
    final remoteKeyPhoneCtrl = TextEditingController(
        text: remoteKeyDoc['phone'] ?? record['buyerPhone'] ?? '');
    DateTime? remoteKeyDate = DateTime.tryParse(remoteKeyDoc['date'] ?? '');

    final extraNotesCtrl = TextEditingController(
        text: (record['extraNotes'] as String?) ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return ContentDialog(
            title: Text("Edit Document Entry — ${record['carName']}",
                style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 680),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Car Details ────────────────────────────────────────
                  Text('Car Details',
                      style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.primary)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: InfoLabel(
                            label: 'Car Model *',
                            child: TextBox(
                                controller: carModelCtrl,
                                placeholder: 'e.g. Toyota Corolla',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13)))),
                    const SizedBox(width: 12),
                    SizedBox(
                        width: 100,
                        child: InfoLabel(
                            label: 'Year',
                            child: TextBox(
                                controller: yearCtrl,
                                placeholder: '2024',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13)))),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: InfoLabel(
                            label: 'Reg No *',
                            child: TextBox(
                                controller: regNoCtrl,
                                placeholder: 'LEA-1234',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: InfoLabel(
                            label: 'Car Color',
                            child: TextBox(
                                controller: carColorCtrl,
                                placeholder: 'White',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13)))),
                  ]),
                  const SizedBox(height: 10),
                  InfoLabel(
                      label: 'Reg Name (Registered Owner)',
                      child: TextBox(
                          controller: regNameCtrl,
                          placeholder: 'Owner / registered name',
                          style: TextStyle(
                              fontFamily: AppTheme.fontFamily, fontSize: 13))),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: InfoLabel(
                            label: 'Chassis No',
                            child: TextBox(
                                controller: chassisNoCtrl,
                                placeholder: 'Optional',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: InfoLabel(
                            label: 'Engine No',
                            child: TextBox(
                                controller: engineNoCtrl,
                                placeholder: 'Optional',
                                style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13)))),
                  ]),
                  const SizedBox(height: 10),
                  InfoLabel(
                      label: 'Car Status',
                      child: ComboBox<String>(
                        value: carStatus,
                        isExpanded: true,
                        items: const [
                          ComboBoxItem(
                              value: 'Available', child: Text('Available')),
                          ComboBoxItem(value: 'Booked', child: Text('Booked')),
                          ComboBoxItem(value: 'Sold', child: Text('Sold')),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => carStatus = v!),
                      )),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // ── Document Status + per-document Handover ────────────
                  Text('Document Status & Handover',
                      style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.primary)),
                  const SizedBox(height: 10),
                  _docStatusBlock(
                    'File',
                    fileStatus,
                    fileToCtrl,
                    filePhoneCtrl,
                    fileDate,
                    (v) => setDialogState(() => fileStatus = v!),
                    (d) => setDialogState(() => fileDate = d),
                  ),
                  _docStatusBlock(
                    'Smart Card',
                    smartCardStatus,
                    smartCardToCtrl,
                    smartCardPhoneCtrl,
                    smartCardDate,
                    (v) => setDialogState(() => smartCardStatus = v!),
                    (d) => setDialogState(() => smartCardDate = d),
                  ),
                  _docStatusBlock(
                    'Number Plate',
                    plateStatus,
                    plateToCtrl,
                    platePhoneCtrl,
                    plateDate,
                    (v) => setDialogState(() => plateStatus = v!),
                    (d) => setDialogState(() => plateDate = d),
                  ),
                  _docStatusBlock(
                    'Remote / Key',
                    remoteKeyStatus,
                    remoteKeyToCtrl,
                    remoteKeyPhoneCtrl,
                    remoteKeyDate,
                    (v) => setDialogState(() => remoteKeyStatus = v!),
                    (d) => setDialogState(() => remoteKeyDate = d),
                  ),
                  const SizedBox(height: 4),
                  const Divider(),
                  const SizedBox(height: 12),
                  InfoLabel(
                    label: 'Additional Notes (optional)',
                    child: TextBox(
                      controller: extraNotesCtrl,
                      maxLines: 3,
                      placeholder:
                          'Anything else to remember about this vehicle’s documents...',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(fontFamily: AppTheme.fontFamily)),
              ).withClickCursor,
              FilledButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(AppTheme.primary)),
                onPressed: () {
                  if (carModelCtrl.text.trim().isEmpty ||
                      regNoCtrl.text.trim().isEmpty) {
                    return;
                  }
                  String? fmt(DateTime? d) => d == null
                      ? null
                      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                  void writeDoc(
                    String key,
                    String status,
                    TextEditingController toCtrl,
                    TextEditingController phoneCtrl,
                    DateTime? date,
                  ) {
                    record[key] ??= {
                      'status': 'inOffice',
                      'to': null,
                      'phone': null,
                      'date': null,
                    };
                    record[key]['status'] = status;
                    if (status == 'handedOver') {
                      record[key]['to'] = toCtrl.text.trim().isEmpty
                          ? null
                          : toCtrl.text.trim();
                      record[key]['phone'] = phoneCtrl.text.trim().isEmpty
                          ? null
                          : phoneCtrl.text.trim();
                      record[key]['date'] = fmt(date);
                    } else {
                      record[key]['to'] = null;
                      record[key]['phone'] = null;
                      record[key]['date'] = null;
                    }
                  }

                  String? firstNonEmpty(List<TextEditingController> cs) {
                    for (final c in cs) {
                      final t = c.text.trim();
                      if (t.isNotEmpty) return t;
                    }
                    return null;
                  }
                  final primaryBuyer = firstNonEmpty([
                    fileToCtrl,
                    smartCardToCtrl,
                    plateToCtrl,
                    remoteKeyToCtrl,
                  ]);
                  final primaryPhone = firstNonEmpty([
                    filePhoneCtrl,
                    smartCardPhoneCtrl,
                    platePhoneCtrl,
                    remoteKeyPhoneCtrl,
                  ]);

                  setState(() {
                    record['carName'] = carModelCtrl.text.trim();
                    record['year'] = int.tryParse(yearCtrl.text.trim()) ??
                        record['year'];
                    record['regNo'] = regNoCtrl.text.trim();
                    record['regName'] = regNameCtrl.text.trim();
                    record['carColor'] = carColorCtrl.text.trim();
                    record['chassisNo'] = chassisNoCtrl.text.trim().isEmpty
                        ? '-'
                        : chassisNoCtrl.text.trim();
                    record['engineNo'] = engineNoCtrl.text.trim().isEmpty
                        ? '-'
                        : engineNoCtrl.text.trim();
                    record['carStatus'] = carStatus;
                    record['buyer'] = primaryBuyer;
                    record['buyerPhone'] = primaryPhone ?? '';
                    record['extraNotes'] = extraNotesCtrl.text.trim();

                    writeDoc('file', fileStatus, fileToCtrl, filePhoneCtrl, fileDate);
                    writeDoc('smartCard', smartCardStatus, smartCardToCtrl, smartCardPhoneCtrl, smartCardDate);
                    writeDoc('plate', plateStatus, plateToCtrl, platePhoneCtrl, plateDate);
                    writeDoc('remoteKey', remoteKeyStatus, remoteKeyToCtrl, remoteKeyPhoneCtrl, remoteKeyDate);
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Save',
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white)),
              ).withClickCursor,
            ],
          );
        },
      ),
    );
  }

  Widget _docMiniChip(String label, Map<String, dynamic> doc) {
    final isHandedOver   = doc['status'] == 'handedOver';
    final isNotReceived  = doc['status'] == 'notReceived';
    final isNotAvailable = doc['status'] == 'notAvailable';
    final bool isPlate   = label.toLowerCase().contains('plate');
    final Color color    = isHandedOver
        ? const Color(0xFFF59E0B)
        : isNotReceived
            ? AppTheme.error
            : isNotAvailable
                ? AppTheme.textMuted
                : AppTheme.success;
    final String statusText = isHandedOver
        ? 'Handed Over'
        : isNotReceived
            ? 'Not Received'
            : isNotAvailable
                ? (isPlate ? 'Not Issued' : 'Not Available')
                : 'In Office';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10,
                  color: AppTheme.textMuted)),
          const SizedBox(height: 2),
          Text(statusText,
              style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _docStatusDropdown(String label, String value, ValueChanged<String?> onChanged) {
    final bool isPlate = label.toLowerCase().contains('plate');
    final String unavailableLabel = isPlate ? 'Not Issued' : 'Not Available';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InfoLabel(
        label: label,
        child: ComboBox<String>(
          value: value,
          isExpanded: true,
          items: [
            const ComboBoxItem(value: 'inOffice', child: Text('In Office')),
            const ComboBoxItem(value: 'handedOver', child: Text('Handed Over')),
            const ComboBoxItem(value: 'notReceived', child: Text('Not Received')),
            ComboBoxItem(value: 'notAvailable', child: Text(unavailableLabel)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _docStatusWidget(Map<String, dynamic> doc, {bool isPlate = false}) {
    final isHandedOver = doc['status'] == 'handedOver';
    final isNotReceived = doc['status'] == 'notReceived';
    final isNotAvailable = doc['status'] == 'notAvailable';

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
    } else if (isNotAvailable) {
      color = AppTheme.textMuted;
      icon = FluentIcons.blocked2;
      labelText = isPlate ? "Not Issued" : "Not Available";
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
    final extraNotesCtrl  = TextEditingController();

    String carStatus       = 'Available';

    String fileStatus      = 'inOffice';
    String smartCardStatus = 'inOffice';
    String plateStatus     = 'inOffice';
    String remoteKeyStatus = 'inOffice';

    // Per-document handover details (used only when status == 'handedOver')
    final fileToCtrl       = TextEditingController();
    final filePhoneCtrl    = TextEditingController();
    DateTime? fileDate;

    final smartCardToCtrl    = TextEditingController();
    final smartCardPhoneCtrl = TextEditingController();
    DateTime? smartCardDate;

    final plateToCtrl    = TextEditingController();
    final platePhoneCtrl = TextEditingController();
    DateTime? plateDate;

    final remoteKeyToCtrl    = TextEditingController();
    final remoteKeyPhoneCtrl = TextEditingController();
    DateTime? remoteKeyDate;

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

                  // ── Document Status + per-document Handover ────────────
                  Text('Document Status & Handover',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600,
                          fontSize: 13, color: AppTheme.primary)),
                  const SizedBox(height: 10),
                  _docStatusBlock(
                    'File',
                    fileStatus,
                    fileToCtrl,
                    filePhoneCtrl,
                    fileDate,
                    (v) => setDialogState(() => fileStatus = v!),
                    (d) => setDialogState(() => fileDate = d),
                  ),
                  _docStatusBlock(
                    'Smart Card',
                    smartCardStatus,
                    smartCardToCtrl,
                    smartCardPhoneCtrl,
                    smartCardDate,
                    (v) => setDialogState(() => smartCardStatus = v!),
                    (d) => setDialogState(() => smartCardDate = d),
                  ),
                  _docStatusBlock(
                    'Number Plate',
                    plateStatus,
                    plateToCtrl,
                    platePhoneCtrl,
                    plateDate,
                    (v) => setDialogState(() => plateStatus = v!),
                    (d) => setDialogState(() => plateDate = d),
                  ),
                  _docStatusBlock(
                    'Remote / Key',
                    remoteKeyStatus,
                    remoteKeyToCtrl,
                    remoteKeyPhoneCtrl,
                    remoteKeyDate,
                    (v) => setDialogState(() => remoteKeyStatus = v!),
                    (d) => setDialogState(() => remoteKeyDate = d),
                  ),
                  const SizedBox(height: 4),
                  const Divider(),
                  const SizedBox(height: 12),
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
                  String? fmt(DateTime? d) => d == null
                      ? null
                      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                  Map<String, dynamic> docEntry(
                    String status,
                    TextEditingController toCtrl,
                    TextEditingController phoneCtrl,
                    DateTime? date,
                  ) =>
                      {
                        'status': status,
                        'to': (status == 'handedOver' && toCtrl.text.trim().isNotEmpty)
                            ? toCtrl.text.trim()
                            : null,
                        'phone': (status == 'handedOver' && phoneCtrl.text.trim().isNotEmpty)
                            ? phoneCtrl.text.trim()
                            : null,
                        'date': status == 'handedOver' ? fmt(date) : null,
                      };

                  // Pick the first non-empty buyer/phone to keep the existing
                  // record-level fields in sync (used for table display).
                  String? firstNonEmpty(List<TextEditingController> cs) {
                    for (final c in cs) {
                      final t = c.text.trim();
                      if (t.isNotEmpty) return t;
                    }
                    return null;
                  }
                  final primaryBuyer = firstNonEmpty([
                    fileToCtrl,
                    smartCardToCtrl,
                    plateToCtrl,
                    remoteKeyToCtrl,
                  ]);
                  final primaryPhone = firstNonEmpty([
                    filePhoneCtrl,
                    smartCardPhoneCtrl,
                    platePhoneCtrl,
                    remoteKeyPhoneCtrl,
                  ]);

                  setState(() {
                    _records.insert(0, {
                      'carName':   carModelCtrl.text.trim(),
                      'year':      int.tryParse(yearCtrl.text.trim()) ?? DateTime.now().year,
                      'regNo':     regNoCtrl.text.trim(),
                      'chassisNo': chassisNoCtrl.text.trim().isEmpty ? '-' : chassisNoCtrl.text.trim(),
                      'engineNo':  engineNoCtrl.text.trim().isEmpty  ? '-' : engineNoCtrl.text.trim(),
                      'carStatus': carStatus,
                      'buyer':     primaryBuyer,
                      'regName':   regNameCtrl.text.trim(),
                      'carColor':  carColorCtrl.text.trim(),
                      'buyerPhone': primaryPhone ?? '',
                      'extraNotes': extraNotesCtrl.text.trim(),
                      'file':      docEntry(fileStatus, fileToCtrl, filePhoneCtrl, fileDate),
                      'smartCard': docEntry(smartCardStatus, smartCardToCtrl, smartCardPhoneCtrl, smartCardDate),
                      'plate':     docEntry(plateStatus, plateToCtrl, platePhoneCtrl, plateDate),
                      'remoteKey': docEntry(remoteKeyStatus, remoteKeyToCtrl, remoteKeyPhoneCtrl, remoteKeyDate),
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

  // Renders a status dropdown for a doc, plus inline Customer Name / Phone /
  // Handover Date fields that only appear when status == 'handedOver'.
  Widget _docStatusBlock(
    String label,
    String status,
    TextEditingController toCtrl,
    TextEditingController phoneCtrl,
    DateTime? date,
    ValueChanged<String?> onStatusChanged,
    ValueChanged<DateTime> onDateChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _docStatusDropdown(label, status, onStatusChanged),
          if (status == 'handedOver') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: InfoLabel(
                          label: 'Customer Name',
                          child: TextBox(
                            controller: toCtrl,
                            placeholder: 'Buyer / customer name',
                            style: TextStyle(
                                fontFamily: AppTheme.fontFamily, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoLabel(
                          label: 'Customer Phone',
                          child: TextBox(
                            controller: phoneCtrl,
                            placeholder: '0300-1234567',
                            style: TextStyle(
                                fontFamily: AppTheme.fontFamily, fontSize: 13),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    InfoLabel(
                      label: 'Handover Date',
                      child: DatePicker(
                        selected: date,
                        onChanged: onDateChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
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
      margin: const pw.EdgeInsets.only(top: 10, bottom: 6),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primary, width: 1.5)),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primary)),
    );

    pw.Widget slipRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
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

    // Draw a tick mark using two rotated rectangles (no font glyph needed).
    pw.Widget tickMark(PdfColor color) {
      return pw.SizedBox(
        width: 14,
        height: 14,
        child: pw.Stack(children: [
          pw.Positioned(
            left: 1,
            top: 7,
            child: pw.Transform.rotate(
              angle: -0.785, // -45°
              child: pw.Container(width: 6, height: 1.8, color: color),
            ),
          ),
          pw.Positioned(
            left: 4,
            top: 4,
            child: pw.Transform.rotate(
              angle: -0.95, // ~-54°
              child: pw.Container(width: 10, height: 1.8, color: color),
            ),
          ),
        ]),
      );
    }

    // Draw an X using two rotated rectangles.
    pw.Widget crossMark(PdfColor color) {
      return pw.SizedBox(
        width: 14,
        height: 14,
        child: pw.Stack(children: [
          pw.Positioned(
            left: 0,
            top: 6,
            child: pw.Transform.rotate(
              angle: -0.785,
              child: pw.Container(width: 14, height: 1.8, color: color),
            ),
          ),
          pw.Positioned(
            left: 0,
            top: 6,
            child: pw.Transform.rotate(
              angle: 0.785,
              child: pw.Container(width: 14, height: 1.8, color: color),
            ),
          ),
        ]),
      );
    }

    // A horizontal dash for "Not Available / Not Issued".
    pw.Widget dashMark(PdfColor color) {
      return pw.Container(
        width: 10,
        height: 1.8,
        color: color,
      );
    }

    pw.Widget docItem(String label, String status, String? toPerson, String? phone, String? date) {
      final isHandedOver   = status == 'handedOver';
      final isNotReceived  = status == 'notReceived';
      final isNotAvailable = status == 'notAvailable';
      final isPlate        = label.toLowerCase().contains('plate');
      final statusLabel    = isHandedOver
          ? 'Handed Over'
          : isNotReceived
              ? 'Not Received'
              : isNotAvailable
                  ? (isPlate ? 'Not Issued' : 'Not Available')
                  : 'In Office';

      final markColor = isHandedOver
          ? greenText
          : isNotReceived
              ? redText
              : isNotAvailable
                  ? textGray
                  : textGray;
      final boxBorder = isHandedOver
          ? greenText
          : isNotReceived
              ? redText
              : isNotAvailable
                  ? textGray
                  : borderGray;

      final pw.Widget mark = isHandedOver
          ? tickMark(markColor)
          : isNotReceived
              ? crossMark(markColor)
              : isNotAvailable
                  ? dashMark(markColor)
                  : pw.SizedBox();

      final pillFill   = isHandedOver ? greenFill : isNotReceived ? redFill : primaryLight;
      final pillText   = isHandedOver ? greenText : isNotReceived ? redText : textGray;

      final receiverParts = <String>[];
      if (isHandedOver) {
        if (toPerson != null && toPerson.trim().isNotEmpty) receiverParts.add(toPerson.trim());
        if (phone != null && phone.trim().isNotEmpty) receiverParts.add(phone.trim());
        if (date != null && date.trim().isNotEmpty) receiverParts.add(date.trim());
      }
      final receiverLine = receiverParts.join('  ·  ');

      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(
              width: 18,
              height: 18,
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: boxBorder, width: 1.4),
                borderRadius: pw.BorderRadius.circular(3),
              ),
              alignment: pw.Alignment.center,
              child: mark,
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(label,
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark)),
                  if (receiverLine.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(receiverLine,
                          style: const pw.TextStyle(
                              fontSize: 9, color: textGray)),
                    ),
                ],
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: pw.BoxDecoration(
                color: pillFill,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(statusLabel,
                  style: pw.TextStyle(fontSize: 9, color: pillText)),
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

    final fileTo       = (record['file']      as Map?)?['to'] as String?;
    final smartCardTo  = (record['smartCard']  as Map?)?['to'] as String?;
    final plateTo      = (record['plate']      as Map?)?['to'] as String?;
    final remoteKeyTo  = (record['remoteKey']  as Map?)?['to'] as String?;

    final filePhone       = (record['file']      as Map?)?['phone'] as String?;
    final smartCardPhone  = (record['smartCard']  as Map?)?['phone'] as String?;
    final platePhone      = (record['plate']      as Map?)?['phone'] as String?;
    final remoteKeyPhone  = (record['remoteKey']  as Map?)?['phone'] as String?;

    final fileDate       = (record['file']      as Map?)?['date'] as String?;
    final smartCardDate  = (record['smartCard']  as Map?)?['date'] as String?;
    final plateDate      = (record['plate']      as Map?)?['date'] as String?;
    final remoteKeyDate  = (record['remoteKey']  as Map?)?['date'] as String?;

    final handoverDate = fileDate ??
        smartCardDate ??
        plateDate ??
        remoteKeyDate ??
        DateTime.now().toString().split(' ')[0];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          // ── Header ──────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
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
                            fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 3),
                    pw.Text('Inam Motors  Official Document Transfer Record',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColor(0.867, 0.839, 0.996))),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Inam Motors',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.SizedBox(height: 3),
                    pw.Text('Date: $handoverDate',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColor(0.867, 0.839, 0.996))),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 3),

          // ── Vehicle Details ──────────────────────────────────────────
          sectionTitle('Vehicle Details'),
          slipRow('Car Name / Model', carName),
          slipRow('Registration No.', regNo),
          slipRow('Chassis No.', chassis),
          slipRow('Engine No.', engine),
          slipRow('Car Status', carStatus),

          // ── Owner Info ────────────────────────────────────────────────
          sectionTitle('Registered Owner'),
          slipRow('Reg. Owner (Name)', regName == '-' ? 'N/A' : regName),
          slipRow('Owner Phone', buyerPhone.isEmpty || buyerPhone == '-' ? 'N/A' : buyerPhone),
          slipRow('Owner Name', buyer == '-' ? 'N/A' : buyer),

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
                docItem('Vehicle File (Registration Book)', fileStatus, fileTo, filePhone, fileDate),
                pw.Divider(color: borderGray, height: 1),
                docItem('Smart Card', smartCardStatus, smartCardTo, smartCardPhone, smartCardDate),
                pw.Divider(color: borderGray, height: 1),
                docItem('Number Plate', plateStatus, plateTo, platePhone, plateDate),
                pw.Divider(color: borderGray, height: 1),
                docItem('Remote / Key', remoteKeyStatus, remoteKeyTo, remoteKeyPhone, remoteKeyDate),
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

          pw.SizedBox(height: 20),

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

          pw.SizedBox(height: 10),
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

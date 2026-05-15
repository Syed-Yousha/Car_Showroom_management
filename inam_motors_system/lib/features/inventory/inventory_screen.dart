import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../main.dart';
import '../../models/car.dart';
import '../../models/investor.dart';
import '../shared/widgets.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  void showAddDialog() => _showAddCarDialog();

  Future<List<String>> _pickAndSaveImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        final docsDir = await getApplicationDocumentsDirectory();
        final inamDir = Directory('${docsDir.path}\\InamMotors_Images');
        if (!await inamDir.exists()) {
          await inamDir.create(recursive: true);
        }

        List<String> savedPaths = [];
        for (var file in result.files) {
          if (file.path != null) {
            final fileName = file.name;
            final newPath = '${inamDir.path}\\${DateTime.now().millisecondsSinceEpoch}_$fileName';
            final newFile = await File(file.path!).copy(newPath);
            savedPaths.add(newFile.path);
          }
        }
        return savedPaths;
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
    return [];
  }

  Future<pw.ImageProvider?> _getMemoryImage(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.MemoryImage(bytes);
      }
    } catch (e) {
      debugPrint("Error loading image for PDF: $e");
    }
    return null;
  }

  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isGridView = true;
  String _sortBy = 'Newest';
  int? _expandedIndex;

  /// Live list of cars, loaded from Firestore via the REST helper
  /// (`InventoryService.fetchCarsSafe`). Replaces the previous hardcoded
  /// demo list so the UI reflects real data.
  List<Map<String, dynamic>> _cars = [];
  bool _loadingCars = true;
  String? _carsLoadError;

  @override
  void initState() {
    super.initState();
    _refreshCars();
  }

  /// Fetch cars via REST and rebuild. Call this on initState, when the
  /// user taps "Refresh", or after any write that changes inventory.
  Future<void> _refreshCars() async {
    if (mounted) {
      setState(() {
        _loadingCars = true;
        _carsLoadError = null;
      });
    }
    try {
      final cars = await inventoryService.fetchCarsSafe();
      if (!mounted) return;
      setState(() {
        _cars = cars.map(_carToDisplayMap).toList();
        _loadingCars = false;
      });
    } catch (e, s) {
      print('[Inventory] fetchCarsSafe failed: $e');
      print('[Inventory] Stack: $s');
      if (!mounted) return;
      setState(() {
        _carsLoadError = e.toString();
        _loadingCars = false;
      });
    }
  }

  /// Convert a typed `Car` into the `Map<String, dynamic>` shape the
  /// existing rendering code already consumes — keeps the (large) build
  /// methods unchanged.
  Map<String, dynamic> _carToDisplayMap(Car c) => {
        'id': c.id,
        'name': c.name,
        'make': c.make,
        'model': c.model,
        'year': c.year,
        'color': c.color,
        'price': c.price,
        'demandPrice': c.demandPrice ?? c.price,
        'regNo': c.regNo,
        'status': c.status,
        'buyer': c.buyerName ?? '',
        'mileage': c.mileage,
        'fuel': c.fuel,
        'transmission': c.transmission,
        'chassisNo': c.chassisNo,
        'engineNo': c.engineNo,
        'investorId': c.investorId,
        'investor': c.investorName ?? '',
        'fileHandedOver': c.fileHandedOver,
        'smartCardHandedOver': c.smartCardHandedOver,
        'numberPlateHandedOver': c.numberPlateHandedOver,
        'remoteKeyHandedOver': c.remoteKeyHandedOver,
        'photos': c.photos,
        'carExpenses': c.carExpenses
            .map((e) => {
                  'title': e.title,
                  'amount': e.amount,
                  'date': e.date?.toIso8601String().substring(0, 10) ?? '',
                })
            .toList(),
        'sellerName': c.sellerName ?? '',
        'sellerPhone': c.sellerPhone ?? '',
        'sellerCnic': c.sellerCnic ?? '',
        'notes': c.notes ?? '',
      };

  // ── Removed hardcoded demo cars below — kept the rest of the screen
  // unchanged. Old demo data lived inline as a `final List<Map<...>>` and
  // is now replaced by `_refreshCars()` above.
  // ignore: unused_field
  static const _legacyDemoCars = <Map<String, dynamic>>[
    {
      'name': 'Toyota Grande',
      'make': 'Toyota',
      'model': 'Grande',
      'year': 2024,
      'color': 'White',
      'price': 8500000,
      'regNo': 'LEA-7421',
      'status': 'Available',
      'buyer': '',
      'mileage': '12,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'JTDBR32E-860045123',
      'engineNo': '2ZR-FE-8924561',
      'investor': 'Faheem Khan',
      'fileHandedOver': true,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front', 'Back', 'Interior'],
      'carExpenses': [
        {'title': 'Paint Job', 'amount': 35000, 'date': '2026-01-20'},
        {'title': 'Interior Clean', 'amount': 8000, 'date': '2026-01-22'},
      ],
    },
    {
      'name': 'Honda Civic',
      'make': 'Honda',
      'model': 'Civic',
      'year': 2023,
      'color': 'Black',
      'price': 7200000,
      'regNo': 'LHR-5532',
      'status': 'Sold',
      'buyer': 'Ahmed Khan',
      'mileage': '25,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'MRHGM66-560089745',
      'engineNo': 'R18Z1-7756231',
      'investor': 'Inam Khan',
      'fileHandedOver': true,
      'smartCardHandedOver': true,
      'numberPlateHandedOver': true,
      'photos': ['Front', 'Back'],
      'carExpenses': [
        {'title': 'Engine Repair', 'amount': 85000, 'date': '2026-01-15'},
      ],
    },
    {
      'name': 'Kia Sportage',
      'make': 'Kia',
      'model': 'Sportage Alpha',
      'year': 2022,
      'color': 'Red',
      'price': 9500000,
      'regNo': 'ISB-3918',
      'status': 'Booked',
      'buyer': 'Usman Ali',
      'mileage': '18,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'KNAPH81-220056789',
      'engineNo': 'G4FJ-2204587',
      'investor': 'Inam Khan',
      'fileHandedOver': false,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front', 'Interior'],
      'carExpenses': [],
    },
    {
      'name': 'Suzuki Cultus',
      'make': 'Suzuki',
      'model': 'Cultus VXL',
      'year': 2024,
      'color': 'Silver',
      'price': 3800000,
      'regNo': 'LEA-1105',
      'status': 'Available',
      'buyer': '',
      'mileage': '5,000 km',
      'fuel': 'Petrol',
      'transmission': 'Manual',
      'chassisNo': 'MBJHA36-240012345',
      'engineNo': 'K10B-2401234',
      'investor': 'Inam Khan',
      'fileHandedOver': true,
      'smartCardHandedOver': true,
      'numberPlateHandedOver': true,
      'photos': ['Front', 'Back', 'Interior'],
      'carExpenses': [
        {'title': 'AC Service', 'amount': 5000, 'date': '2026-02-01'},
      ],
    },
    {
      'name': 'Hyundai Tucson',
      'make': 'Hyundai',
      'model': 'Tucson GLS',
      'year': 2022,
      'color': 'Grey',
      'price': 11000000,
      'regNo': 'LHR-8890',
      'status': 'Available',
      'buyer': '',
      'mileage': '30,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'KMHJN81-220098765',
      'engineNo': 'G4FP-2209871',
      'investor': 'Inam Khan',
      'fileHandedOver': false,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front'],
      'carExpenses': [
        {'title': 'Tyre Change', 'amount': 48000, 'date': '2026-01-10'},
        {'title': 'Bumper Repair', 'amount': 25000, 'date': '2026-01-18'},
      ],
    },
    {
      'name': 'MG HS',
      'make': 'MG',
      'model': 'HS Essence',
      'year': 2024,
      'color': 'White',
      'price': 9800000,
      'regNo': 'LEA-6677',
      'status': 'Sold',
      'buyer': 'Zain ul Abideen',
      'mileage': '8,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'LSJWB48-240076543',
      'engineNo': '15S4G-2406543',
      'investor': 'Inam Khan',
      'fileHandedOver': true,
      'smartCardHandedOver': true,
      'numberPlateHandedOver': true,
      'photos': ['Front', 'Back', 'Interior'],
      'carExpenses': [],
    },
    {
      'name': 'Changan Alsvin',
      'make': 'Changan',
      'model': 'Alsvin Lumiere',
      'year': 2024,
      'color': 'Blue',
      'price': 4600000,
      'regNo': 'MUL-2243',
      'status': 'Available',
      'buyer': '',
      'mileage': '2,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'LSCGB54-240034567',
      'engineNo': 'JL473Q5-2403456',
      'investor': 'Inam Khan',
      'fileHandedOver': true,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front', 'Back'],
      'carExpenses': [
        {'title': 'Detailing', 'amount': 12000, 'date': '2026-02-03'},
      ],
    },
    {
      'name': 'Toyota Corolla',
      'make': 'Toyota',
      'model': 'Corolla Altis X',
      'year': 2024,
      'color': 'Silver',
      'price': 6800000,
      'regNo': 'LEA-9034',
      'status': 'Available',
      'buyer': '',
      'mileage': '15,000 km',
      'fuel': 'Petrol',
      'transmission': 'Automatic',
      'chassisNo': 'JTDKR32E-240067890',
      'engineNo': '1NZ-FE-2406789',
      'investor': 'Faheem Khan',
      'fileHandedOver': false,
      'smartCardHandedOver': false,
      'numberPlateHandedOver': false,
      'photos': ['Front', 'Interior'],
      'carExpenses': [],
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    var list = _cars.where((c) {
      if (_selectedFilter != 'All' && c['status'] != _selectedFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return c['name'].toString().toLowerCase().contains(q) ||
            c['make'].toString().toLowerCase().contains(q) ||
            c['chassisNo'].toString().toLowerCase().contains(q) ||
            c['engineNo'].toString().toLowerCase().contains(q) ||
            c['investor'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();

    if (_sortBy == 'Price: High') list.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    if (_sortBy == 'Price: Low') list.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    if (_sortBy == 'Newest') list.sort((a, b) => (b['year'] as int).compareTo(a['year'] as int));

    return list;
  }

  int get _availableCount => _cars.where((c) => c['status'] == 'Available').length;
  int get _soldCount => _cars.where((c) => c['status'] == 'Sold').length;
  int get _bookedCount => _cars.where((c) => c['status'] == 'Booked').length;
  int get _totalCarExpenses => _cars.fold(0, (s, c) => s + ((c['carExpenses'] as List).fold(0, (ss, e) => (ss) + ((e as Map)['amount'] as int))));



  int? _parseAmount(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  Future<(int, String)?> _showDemandPriceDialog(Map<String, dynamic> car) async {
    final currentDemand = (car['demandPrice'] as int?) ?? (car['price'] as int? ?? 0);
    final demandCtrl = TextEditingController(text: currentDemand > 0 ? '$currentDemand' : '');
    final notesCtrl = TextEditingController();
    String? errorText;

    final result = await showDialog<(int, String)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => ContentDialog(
          title: const Text(
            'Generate Customer PDF',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
          ),
          constraints: const BoxConstraints(maxWidth: 480),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set the demand price for ${car['name']}. Purchase price stays hidden from the customer copy.',
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              InfoLabel(
                label: 'Demand Price (Rs)',
                labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                child: TextBox(
                  controller: demandCtrl,
                  placeholder: 'Enter demand price',
                  placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
                  decoration: WidgetStateProperty.all(
                    BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider)),
                  ),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 4),
                Text(errorText!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.error)),
              ],
              const SizedBox(height: 14),
              InfoLabel(
                label: 'Additional Notes (printed on PDF)',
                labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                child: TextBox(
                  controller: notesCtrl,
                  maxLines: 3,
                  placeholder: 'e.g. Payment terms, condition remarks, special instructions...',
                  placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
                  decoration: WidgetStateProperty.all(
                    BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(fontFamily: AppTheme.fontFamily)),
            ).withClickCursor,
            FilledButton(
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
              onPressed: () {
                final parsed = _parseAmount(demandCtrl.text);
                if (parsed == null || parsed <= 0) {
                  setDialogState(() => errorText = 'Enter a valid demand price');
                  return;
                }
                Navigator.pop(ctx, (parsed, notesCtrl.text.trim()));
              },
              child: const Text('Generate PDF', style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
            ).withClickCursor,
          ],
        ),
      ),
    );

    return result;
  }

  // ═══════════════════════════════════════════════
  //  CAR PDF EXPORT
  // ═══════════════════════════════════════════════
  Future<void> _showCarPdf(Map<String, dynamic> car) async {
    final result = await _showDemandPriceDialog(car);
    if (result == null) return;

    final (demandPrice, additionalNotes) = result;

    setState(() {
      car['demandPrice'] = demandPrice;
    });

    List<pw.ImageProvider> loadedImages = [];
    if (car['photos'] != null) {
      final photoPaths = car['photos'] as List;
      final imageFutures = photoPaths.map((path) => _getMemoryImage(path.toString()));
      final resolvedImages = await Future.wait(imageFutures);
      loadedImages = resolvedImages.where((img) => img != null).cast<pw.ImageProvider>().toList();
    }

    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          // ── Header ──────────────────────────────────────────────────
          pw.Center(child: pw.Column(children: [
            pw.Text("INAM MOTORS", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#6C5DD3'))),
            pw.SizedBox(height: 2),
            pw.Text("Car Showroom & Dealership", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.SizedBox(height: 6),
            pw.Container(height: 2, width: 200, color: PdfColor.fromHex('#6C5DD3')),
          ])),
          pw.SizedBox(height: 16),

          // ── Title ────────────────────────────────────────────────────
          pw.Text("Vehicle Profile", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.SizedBox(height: 8),

          // ── Car Information (customer-facing only) ───────────────────
          pw.Text("Car Information", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _pdfRow("Name",         car['name']?.toString() ?? ''),
          _pdfRow("Make",         car['make']?.toString() ?? ''),
          _pdfRow("Model",        car['model']?.toString() ?? ''),
          _pdfRow("Year",         "${car['year'] ?? ''}"),
          _pdfRow("Color",        car['color']?.toString() ?? ''),
          _pdfRow("Reg No",       car['regNo']?.toString() ?? ''),
          _pdfRow("Mileage",      car['mileage']?.toString() ?? ''),
          _pdfRow("Fuel Type",    car['fuel']?.toString() ?? ''),
          _pdfRow("Transmission", car['transmission']?.toString() ?? ''),
          _pdfRow("Engine No",    car['engineNo']?.toString() ?? ''),
          _pdfRow("Chassis No",   car['chassisNo']?.toString() ?? ''),
          pw.SizedBox(height: 14),

          // ── Demand Price highlight ───────────────────────────────────
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F5F3FF'),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColor.fromHex('#6C5DD3'), width: 0.8),
            ),
            child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text("Demand Price", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.Text(formatFullPrice(demandPrice), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#6C5DD3'))),
            ]),
          ),
          pw.SizedBox(height: 14),

          // ── Car Photos ───────────────────────────────────────────────
          if (loadedImages.isNotEmpty) ...[
            pw.Text("Car Photos", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              children: loadedImages.map<pw.Widget>((img) => pw.Container(
                width: 220,
                height: 165,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.ClipRRect(
                  horizontalRadius: 6,
                  verticalRadius: 6,
                  child: pw.Image(img, fit: pw.BoxFit.cover),
                ),
              )).toList(),
            ),
            pw.SizedBox(height: 14),
          ],

          // ── Additional Notes ─────────────────────────────────────────
          if (additionalNotes.isNotEmpty) ...[
            pw.Text("Notes", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              ),
              child: pw.Text(additionalNotes, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
            ),
            pw.SizedBox(height: 14),
          ],

          // ── Signature footer ─────────────────────────────────────────
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Column(children: [
              pw.Container(width: 120, height: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 4),
              pw.Text("Authorized Signature", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
            ]),
            pw.Text("Generated by Inam Motors System", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey400)),
          ]),
        ];
      },
    ));

    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: 'Car_${car['name'].toString().replaceAll(' ', '_')}_${car['regNo']}.pdf');
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(children: [
        pw.SizedBox(width: 130, child: pw.Text(label, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700))),
        pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 11))),
      ]),
    );
  }


  void _showAddCarDialog() {
    final nameCtrl = TextEditingController();
    final makeCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final regNoCtrl = TextEditingController();
    final mileageCtrl = TextEditingController();
    final chassisCtrl = TextEditingController();
    final engineCtrl = TextEditingController();
    final sellerNameCtrl = TextEditingController();
    final sellerPhoneCtrl = TextEditingController();
    final sellerCnicCtrl = TextEditingController();
    String selectedFuel = 'Petrol';
    String selectedTransmission = 'Automatic';
    bool fileHanded = false;
    bool smartCardHanded = false;
    bool plateHanded = false;
    bool remoteKeyHanded = false;
    final notesCtrl = TextEditingController();
    List<String> selectedImagePaths = [];

    // Investor dropdown state. Loaded async via the REST helper because
    // the Windows Firestore SDK crashes on reads.
    List<Investor> investorList = const [];
    Investor? selectedInvestor;
    bool investorsLoading = true;
    String? investorsLoadError;
    bool loadKicked = false;
    bool saving = false;
    String? saveError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        // First-build only: kick off the REST listAll for the investor
        // dropdown. Subsequent rebuilds skip via the `loadKicked` flag.
        if (!loadKicked) {
          loadKicked = true;
          Future(() async {
            try {
              print('[AddCar] Loading investors via REST...');
              final list = await investorsRepo.listAll();
              print('[AddCar] Loaded ${list.length} investor(s) OK');
              investorList = list;
            } catch (e, s) {
              print('[AddCar] Failed to load investors: $e');
              print('[AddCar] Stack: $s');
              investorsLoadError = e.toString();
            } finally {
              investorsLoading = false;
              if (ctx.mounted) setDialogState(() {});
            }
          });
        }

        return ContentDialog(
        title: const Text("Add New Car", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Car Photos", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      FilledButton(
                        style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
                        onPressed: () async {
                          final newPaths = await _pickAndSaveImages();
                          if (newPaths.isNotEmpty) {
                            setDialogState(() => selectedImagePaths.addAll(newPaths));
                          }
                        },
                        child: const Text("Upload Photos", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: Colors.white)),
                      ).withClickCursor,
                    ],
                  ),
                  if (selectedImagePaths.isNotEmpty) ...[  
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12, 
                      runSpacing: 12, 
                      children: selectedImagePaths.asMap().entries.map((entry) {
                        final path = entry.value;
                        final fileName = path.split(RegExp(r'[\\/]')).last;
                        return Container(
                          width: 100,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor, 
                            borderRadius: BorderRadius.circular(6), 
                            border: Border.all(color: AppTheme.divider)
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, 
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      File(path), 
                                      width: 90, 
                                      height: 70, 
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        width: 90, height: 70, color: AppTheme.background,
                                        child: const Center(child: Icon(FluentIcons.error, size: 16, color: AppTheme.error)),
                                      ),
                                    ),
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() => selectedImagePaths.removeAt(entry.key)),
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: Icon(FluentIcons.cancel, size: 10, color: AppTheme.error),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(fileName, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textPrimary)),
                            ]
                          ),
                        );
                      }).toList()
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.divider, style: BorderStyle.none),
                      ),
                      child: Column(
                        children: [
                          Icon(FluentIcons.photo_collection, size: 28, color: AppTheme.textMuted),
                          const SizedBox(height: 8),
                          Text("No photos uploaded yet", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _editField("Car Name", nameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Make", makeCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Model", modelCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Reg No", regNoCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Color", colorCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Purchase Price (Hidden from Customer)", priceCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Mileage", mileageCtrl)),
            ]),
            Row(children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Fuel Type",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedFuel,
                    isExpanded: true,
                    items: ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedFuel = v); },
                  ),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Transmission",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedTransmission,
                    isExpanded: true,
                    items: ['Automatic', 'Manual'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedTransmission = v); },
                  ),
                ),
              )),
            ]),
            _editField("Chassis No", chassisCtrl),
            _editField("Engine No", engineCtrl),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InfoLabel(
                label: "Investor (optional)",
                labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                child: investorsLoading
                    ? Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.centerLeft,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const SizedBox(width: 12, height: 12, child: ProgressRing(strokeWidth: 2)),
                          const SizedBox(width: 8),
                          Text("Loading investors…", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                        ]),
                      )
                    : investorsLoadError != null
                        ? Text("Failed to load: $investorsLoadError",
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error))
                        : ComboBox<Investor?>(
                            value: selectedInvestor,
                            isExpanded: true,
                            placeholder: Text(
                              investorList.isEmpty ? "No investors available" : "(none) — no investor for this car",
                              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted),
                            ),
                            items: [
                              const ComboBoxItem<Investor?>(
                                value: null,
                                child: Text("(none)", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                              ),
                              for (final inv in investorList)
                                ComboBoxItem<Investor?>(
                                  value: inv,
                                  child: Text(inv.name, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                                ),
                            ],
                            onChanged: (v) => setDialogState(() => selectedInvestor = v),
                          ),
              ),
            ),
            Row(children: [
              Expanded(child: _editField("Seller Name", sellerNameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Seller Phone", sellerPhoneCtrl)),
            ]),
            _editField("Seller CNIC", sellerCnicCtrl),
            const SizedBox(height: 8),
            Wrap(spacing: 16, runSpacing: 8, children: [
              Checkbox(
                checked: fileHanded,
                onChanged: (v) => setDialogState(() => fileHanded = v ?? false),
                content: Text("File", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              Checkbox(
                checked: smartCardHanded,
                onChanged: (v) => setDialogState(() => smartCardHanded = v ?? false),
                content: Text("Smart Card", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              Checkbox(
                checked: plateHanded,
                onChanged: (v) => setDialogState(() => plateHanded = v ?? false),
                content: Text("Number Plate", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              Checkbox(
                checked: remoteKeyHanded,
                onChanged: (v) => setDialogState(() => remoteKeyHanded = v ?? false),
                content: Text("Remote / Key", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
            ]),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InfoLabel(
                label: "File Date & Additional Notes",
                labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                child: TextBox(
                  controller: notesCtrl,
                  maxLines: 3,
                  placeholder: "Enter file date, remarks, or any extra details...",
                  placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
                  decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider))),
                ),
              ),
            ),
          ]),
          ),
        ),
        actions: [
          if (saveError != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                saveError!,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error),
              ),
            ),
          Button(
            onPressed: saving ? null : () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily)),
          ).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: saving
                ? null
                : () async {
                    if (nameCtrl.text.trim().isEmpty) {
                      setDialogState(() => saveError = 'Car name is required.');
                      return;
                    }
                    setDialogState(() {
                      saving = true;
                      saveError = null;
                    });

                    final priceInt = int.tryParse(priceCtrl.text.trim()) ?? 0;
                    final car = Car(
                      id: '', // auto-id assigned by InventoryService
                      name: nameCtrl.text.trim(),
                      make: makeCtrl.text.trim(),
                      model: modelCtrl.text.trim(),
                      year: DateTime.now().year,
                      color: colorCtrl.text.trim(),
                      price: priceInt,
                      demandPrice: priceInt,
                      regNo: regNoCtrl.text.trim(),
                      status: 'Available',
                      mileage: mileageCtrl.text.trim(),
                      fuel: selectedFuel,
                      transmission: selectedTransmission,
                      chassisNo: chassisCtrl.text.trim(),
                      engineNo: engineCtrl.text.trim(),
                      fileHandedOver: fileHanded,
                      smartCardHandedOver: smartCardHanded,
                      numberPlateHandedOver: plateHanded,
                      remoteKeyHandedOver: remoteKeyHanded,
                      photos: selectedImagePaths,
                      sellerName: sellerNameCtrl.text.trim().isEmpty ? null : sellerNameCtrl.text.trim(),
                      sellerPhone: sellerPhoneCtrl.text.trim().isEmpty ? null : sellerPhoneCtrl.text.trim(),
                      sellerCnic: sellerCnicCtrl.text.trim().isEmpty ? null : sellerCnicCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                    );

                    try {
                      print('[AddCar] Calling inventoryService.addCar() — investor=${selectedInvestor?.name ?? "(none)"}, price=$priceInt');
                      final id = await inventoryService.addCar(car, investor: selectedInvestor);
                      print('[AddCar] Car saved successfully with id=$id');
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      displayInfoBar(context, builder: (c, close) => InfoBar(
                        title: Text('Car "${car.name}" added.', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                        severity: InfoBarSeverity.success,
                        onClose: close,
                      ));
                      // Re-fetch the list so the new car appears immediately.
                      _refreshCars();
                    } catch (e, s) {
                      print('[AddCar] FAILED to save car: $e');
                      print('[AddCar] Stack: $s');
                      if (!ctx.mounted) return;
                      setDialogState(() {
                        saving = false;
                        saveError = 'Save failed: $e';
                      });
                    }
                  },
            child: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: ProgressRing(strokeWidth: 2),
                  )
                : const Text("Add Car", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      );
      }),
    );
  }

  void _showNoteDialog(Map<String, dynamic> car) {
    final note = (car['notes'] as String? ?? '').trim();
    if (note.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.quick_note, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text(
              "Car Note",
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

  void _showRemoveCarDialog(Map<String, dynamic> car) {
    final carId = (car['id'] ?? '').toString();
    final carPrice = (car['price'] as int?) ?? 0;
    final previousInvestorId = (car['investorId'] ?? '').toString();

    bool deleting = false;
    String? deleteError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => ContentDialog(
        title: const Text("Remove Car", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Are you sure you want to remove this car from inventory?", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.error.withValues(alpha: 0.2))),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(FluentIcons.car, size: 18, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("${car['name']} (${car['year']})", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text("${car['color']} \u2022 ${car['transmission']} \u2022 ${formatFullPrice(carPrice)}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              ])),
            ]),
          ),
          const SizedBox(height: 8),
          Text("This action cannot be undone.", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.error)),
          if (deleteError != null) ...[
            const SizedBox(height: 8),
            Text(deleteError!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.error)),
          ],
        ]),
        actions: [
          Button(
            onPressed: deleting ? null : () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily)),
          ).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: deleting
                ? null
                : () async {
                    if (carId.isEmpty) {
                      setDialogState(() => deleteError = 'Missing car id \u2014 refresh and try again.');
                      return;
                    }
                    setDialogState(() {
                      deleting = true;
                      deleteError = null;
                    });
                    try {
                      // Look up the investor (if any) so we can adjust heldAmount.
                      Investor? prevInvestor;
                      if (previousInvestorId.isNotEmpty) {
                        print('[RemoveCar] Fetching previous investor $previousInvestorId via REST...');
                        prevInvestor = await investorsRepo.getOne(previousInvestorId);
                      }
                      print('[RemoveCar] Calling inventoryService.deleteCar(carId=$carId)');
                      await inventoryService.deleteCar(
                        carId: carId,
                        previousInvestor: prevInvestor,
                        carPrice: carPrice,
                      );
                      print('[RemoveCar] Delete OK');
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      displayInfoBar(context, builder: (c, close) => InfoBar(
                        title: Text('Car "${car['name']}" removed.', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                        severity: InfoBarSeverity.success,
                        onClose: close,
                      ));
                      _refreshCars();
                    } catch (e, s) {
                      print('[RemoveCar] FAILED: $e');
                      print('[RemoveCar] Stack: $s');
                      if (!ctx.mounted) return;
                      setDialogState(() {
                        deleting = false;
                        deleteError = 'Remove failed: $e';
                      });
                    }
                  },
            child: deleting
                ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                : const Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      )),
    );
  }

  void _showEditCarDialog(Map<String, dynamic> car) {
    final index = _cars.indexOf(car);
    if (index == -1) return;

    final nameCtrl = TextEditingController(text: car['name']);
    final makeCtrl = TextEditingController(text: car['make']);
    final modelCtrl = TextEditingController(text: car['model']);
    final yearCtrl = TextEditingController(text: car['year'].toString());
    final colorCtrl = TextEditingController(text: car['color']);
    final priceCtrl = TextEditingController(text: car['price'].toString());
    final mileageCtrl = TextEditingController(text: car['mileage']);
    final chassisCtrl = TextEditingController(text: car['chassisNo']);
    final engineCtrl = TextEditingController(text: car['engineNo']);
    final sellerNameCtrl = TextEditingController(text: car['sellerName'] ?? '');
    final sellerPhoneCtrl = TextEditingController(text: car['sellerPhone'] ?? '');
    final sellerCnicCtrl = TextEditingController(text: car['sellerCnic'] ?? '');
    // Investor dropdown is loaded async via REST. We pre-populate
    // `selectedInvestor` once the list arrives, matching the car's saved
    // `investorId`. The ORIGINAL investor + price are kept separately so
    // updateCar() can adjust heldAmount accurately.
    final originalInvestorId = (car['investorId'] ?? '').toString();
    final originalPrice = (car['price'] as int?) ?? 0;
    final originalCarId = (car['id'] ?? '').toString();
    List<Investor> investorList = const [];
    Investor? selectedInvestor;
    Investor? originalInvestor;
    bool investorsLoading = true;
    String? investorsLoadError;
    bool editLoadKicked = false;
    bool savingEdit = false;
    String? editSaveError;

    final regNoCtrl = TextEditingController(text: car['regNo'] ?? '');
    final buyerCtrl = TextEditingController(text: car['buyer'] ?? '');
    String selectedStatus = car['status'];
    String selectedFuel = car['fuel'];
    String selectedTransmission = car['transmission'];
    bool fileHanded = car['fileHandedOver'];
    bool smartCardHanded = car['smartCardHandedOver'] ?? false;
    bool plateHanded = car['numberPlateHandedOver'];
    bool remoteKeyHanded = car['remoteKeyHandedOver'] ?? false;
    final notesCtrl = TextEditingController(text: car['notes'] ?? '');
    List<String> selectedImagePaths = List<String>.from(car['photos'] ?? []);
    List<Map<String, TextEditingController>> expenseRows = ((car['carExpenses'] ?? []) as List).map<Map<String, TextEditingController>>((e) => {
      'title': TextEditingController(text: e['title'] ?? ''),
      'amount': TextEditingController(text: (e['amount'] ?? 0).toString()),
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        // First-build only: kick off the REST listAll for the investor
        // dropdown. Pre-select the car's existing investor (if any) so
        // the dropdown shows the right entry on open.
        if (!editLoadKicked) {
          editLoadKicked = true;
          Future(() async {
            try {
              print('[EditCar] Loading investors via REST...');
              final list = await investorsRepo.listAll();
              print('[EditCar] Loaded ${list.length} investor(s) OK');
              investorList = list;
              if (originalInvestorId.isNotEmpty) {
                for (final inv in list) {
                  if (inv.id == originalInvestorId) {
                    originalInvestor = inv;
                    selectedInvestor = inv;
                    break;
                  }
                }
              }
            } catch (e, s) {
              print('[EditCar] Failed to load investors: $e');
              print('[EditCar] Stack: $s');
              investorsLoadError = e.toString();
            } finally {
              investorsLoading = false;
              if (ctx.mounted) setDialogState(() {});
            }
          });
        }

        return ContentDialog(
        title: const Text("Edit Car Details", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Car Photos", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      FilledButton(
                        style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
                        onPressed: () async {
                          final newPaths = await _pickAndSaveImages();
                          if (newPaths.isNotEmpty) {
                            setDialogState(() => selectedImagePaths.addAll(newPaths));
                          }
                        },
                        child: const Text("Upload Photos", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: Colors.white)),
                      ).withClickCursor,
                    ],
                  ),
                  if (selectedImagePaths.isNotEmpty) ...[  
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12, 
                      runSpacing: 12, 
                      children: selectedImagePaths.asMap().entries.map((entry) {
                        final path = entry.value;
                        final fileName = path.split(RegExp(r'[\\/]')).last;
                        return Container(
                          width: 100,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor, 
                            borderRadius: BorderRadius.circular(6), 
                            border: Border.all(color: AppTheme.divider)
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, 
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      File(path), 
                                      width: 90, 
                                      height: 70, 
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(
                                        width: 90, height: 70, color: AppTheme.background,
                                        child: const Center(child: Icon(FluentIcons.error, size: 16, color: AppTheme.error)),
                                      ),
                                    ),
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() => selectedImagePaths.removeAt(entry.key)),
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: Icon(FluentIcons.cancel, size: 10, color: AppTheme.error),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(fileName, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textPrimary)),
                            ]
                          ),
                        );
                      }).toList()
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.divider, style: BorderStyle.none),
                      ),
                      child: Column(
                        children: [
                          Icon(FluentIcons.photo_collection, size: 28, color: AppTheme.textMuted),
                          const SizedBox(height: 8),
                          Text("No photos uploaded yet", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(children: [
              Expanded(child: _editField("Car Name", nameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Make", makeCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Model", modelCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Year", yearCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Color", colorCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Purchase Price (Hidden from Customer)", priceCtrl)),
            ]),
            Row(children: [
              Expanded(child: _editField("Mileage", mileageCtrl)),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Status",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedStatus,
                    isExpanded: true,
                    items: ['Available', 'Sold', 'Booked'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedStatus = v); },
                  ),
                ),
              )),
            ]),
            Row(children: [
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Fuel Type",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedFuel,
                    isExpanded: true,
                    items: ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedFuel = v); },
                  ),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InfoLabel(
                  label: "Transmission",
                  labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  child: ComboBox<String>(
                    value: selectedTransmission,
                    isExpanded: true,
                    items: ['Automatic', 'Manual'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)))).toList(),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedTransmission = v); },
                  ),
                ),
              )),
            ]),
            Row(children: [
              Expanded(child: _editField("Reg No", regNoCtrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InfoLabel(
                    label: "Investor (optional)",
                    labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    child: investorsLoading
                        ? Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.centerLeft,
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const SizedBox(width: 12, height: 12, child: ProgressRing(strokeWidth: 2)),
                              const SizedBox(width: 8),
                              Text("Loading investors…", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                            ]),
                          )
                        : investorsLoadError != null
                            ? Text("Failed to load: $investorsLoadError",
                                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error))
                            : ComboBox<Investor?>(
                                value: selectedInvestor,
                                isExpanded: true,
                                placeholder: Text(
                                  "(none)",
                                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted),
                                ),
                                items: [
                                  const ComboBoxItem<Investor?>(
                                    value: null,
                                    child: Text("(none)", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                                  ),
                                  for (final inv in investorList)
                                    ComboBoxItem<Investor?>(
                                      value: inv,
                                      child: Text(inv.name, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13)),
                                    ),
                                ],
                                onChanged: (v) => setDialogState(() => selectedInvestor = v),
                              ),
                  ),
                ),
              ),
            ]),
            Row(children: [
              Expanded(child: _editField("Seller Name", sellerNameCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _editField("Seller Phone", sellerPhoneCtrl)),
            ]),
            _editField("Seller CNIC", sellerCnicCtrl),
            _editField("Chassis No", chassisCtrl),
            _editField("Engine No", engineCtrl),
            if (selectedStatus == 'Sold' || selectedStatus == 'Booked')
              _editField("Buyer Name", buyerCtrl),
            const SizedBox(height: 8),
            Text("Document Tracking", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Wrap(spacing: 16, runSpacing: 8, children: [
              Checkbox(
                checked: fileHanded,
                onChanged: (v) => setDialogState(() => fileHanded = v ?? false),
                content: Text("File", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              Checkbox(
                checked: smartCardHanded,
                onChanged: (v) => setDialogState(() => smartCardHanded = v ?? false),
                content: Text("Smart Card", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              Checkbox(
                checked: plateHanded,
                onChanged: (v) => setDialogState(() => plateHanded = v ?? false),
                content: Text("Number Plate", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
              Checkbox(
                checked: remoteKeyHanded,
                onChanged: (v) => setDialogState(() => remoteKeyHanded = v ?? false),
                content: Text("Remote / Key", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
              ),
            ]),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InfoLabel(
                label: "File Date & Additional Notes",
                labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                child: TextBox(
                  controller: notesCtrl,
                  maxLines: 3,
                  placeholder: "Enter file date, remarks, or any extra details...",
                  placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
                  decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider))),
                ),
              ),
            ),
            Row(children: [
              Text("Car Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setDialogState(() {
                    expenseRows.add({
                      'title': TextEditingController(),
                      'amount': TextEditingController(),
                    });
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(FluentIcons.add, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            ...expenseRows.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(child: TextBox(
                  controller: entry.value['title']!,
                  placeholder: "Expense title",
                  placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
                  decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider))),
                )),
                const SizedBox(width: 8),
                SizedBox(width: 120, child: TextBox(
                  controller: entry.value['amount']!,
                  placeholder: "Amount",
                  placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
                  decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.divider))),
                )),
                const SizedBox(width: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setDialogState(() => expenseRows.removeAt(entry.key)),
                    child: Icon(FluentIcons.delete, size: 14, color: AppTheme.error),
                  ),
                ),
              ]),
            )),
          ]),
          ),
        ),
        actions: [
          if (editSaveError != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                editSaveError!,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error),
              ),
            ),
          Button(
            onPressed: savingEdit ? null : () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily)),
          ).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.primary)),
            onPressed: savingEdit
                ? null
                : () async {
                    if (originalCarId.isEmpty) {
                      setDialogState(() => editSaveError = 'Missing car id — refresh and try again.');
                      return;
                    }
                    setDialogState(() {
                      savingEdit = true;
                      editSaveError = null;
                    });

                    final newPrice = int.tryParse(priceCtrl.text.trim()) ?? originalPrice;
                    final newCar = Car(
                      id: originalCarId,
                      name: nameCtrl.text.trim(),
                      make: makeCtrl.text.trim(),
                      model: modelCtrl.text.trim(),
                      year: int.tryParse(yearCtrl.text.trim()) ?? (car['year'] as int? ?? DateTime.now().year),
                      color: colorCtrl.text.trim(),
                      price: newPrice,
                      demandPrice: (car['demandPrice'] as int?) ?? newPrice,
                      regNo: regNoCtrl.text.trim(),
                      status: selectedStatus,
                      buyerId: car['buyerId'] as String?,
                      buyerName: buyerCtrl.text.trim().isEmpty ? null : buyerCtrl.text.trim(),
                      mileage: mileageCtrl.text.trim(),
                      fuel: selectedFuel,
                      transmission: selectedTransmission,
                      chassisNo: chassisCtrl.text.trim(),
                      engineNo: engineCtrl.text.trim(),
                      investorId: selectedInvestor?.id,
                      investorName: selectedInvestor?.name,
                      fileHandedOver: fileHanded,
                      smartCardHandedOver: smartCardHanded,
                      numberPlateHandedOver: plateHanded,
                      remoteKeyHandedOver: remoteKeyHanded,
                      photos: selectedImagePaths,
                      carExpenses: expenseRows
                          .where((row) => row['title']!.text.trim().isNotEmpty)
                          .map((row) => CarExpense(
                                title: row['title']!.text.trim(),
                                amount: int.tryParse(row['amount']!.text) ?? 0,
                                date: DateTime.now(),
                              ))
                          .toList(),
                      sellerName: sellerNameCtrl.text.trim().isEmpty ? null : sellerNameCtrl.text.trim(),
                      sellerPhone: sellerPhoneCtrl.text.trim().isEmpty ? null : sellerPhoneCtrl.text.trim(),
                      sellerCnic: sellerCnicCtrl.text.trim().isEmpty ? null : sellerCnicCtrl.text.trim(),
                      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                    );

                    try {
                      print('[EditCar] Calling inventoryService.updateCar() — '
                          'oldInvestor=${originalInvestor?.name ?? "(none)"}, '
                          'newInvestor=${selectedInvestor?.name ?? "(none)"}, '
                          'oldPrice=$originalPrice, newPrice=$newPrice');
                      await inventoryService.updateCar(
                        newCar,
                        oldInvestor: originalInvestor,
                        oldPrice: originalPrice,
                        newInvestor: selectedInvestor,
                      );
                      print('[EditCar] updateCar OK');
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      displayInfoBar(context, builder: (c, close) => InfoBar(
                        title: Text('Car "${newCar.name}" updated.', style: const TextStyle(fontFamily: AppTheme.fontFamily)),
                        severity: InfoBarSeverity.success,
                        onClose: close,
                      ));
                      _refreshCars();
                    } catch (e, s) {
                      print('[EditCar] FAILED to update car: $e');
                      print('[EditCar] Stack: $s');
                      if (!ctx.mounted) return;
                      setDialogState(() {
                        savingEdit = false;
                        editSaveError = 'Update failed: $e';
                      });
                    }
                  },
            child: savingEdit
                ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
                : const Text("Save Changes", style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      );
      }),
    );
  }

  Widget _editField(String label, TextEditingController ctrl) {
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
    // Initial fetch in flight, no data yet → full-screen spinner.
    if (_loadingCars && _cars.isEmpty) {
      return const ScaffoldPage(
        content: Center(child: ProgressRing()),
      );
    }
    // First fetch failed and we have nothing to show → error + retry.
    if (_carsLoadError != null && _cars.isEmpty) {
      return ScaffoldPage(
        content: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.error, size: 36, color: AppTheme.error),
                const SizedBox(height: 12),
                Text(
                  'Failed to load inventory',
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  _carsLoadError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _refreshCars,
                  child: const Text('Retry', style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;
      final isMedium = constraints.maxWidth < 1000;

      return ScaffoldPage.scrollable(
        padding: EdgeInsets.all(isNarrow ? 16 : 28),
        children: [
          // HEADER
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Inventory", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 22 : 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text("Complete car profiles with documents, expenses & tracking", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: isNarrow ? 12 : 14, color: AppTheme.textSecondary)),
            ])),
            // Refresh — re-fetches `cars/` via REST. Re-uses the same spinner
            // overlay shown on first load, but the existing list stays
            // visible so the screen doesn't flash blank.
            IconButton(
              icon: _loadingCars
                  ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                  : Icon(FluentIcons.refresh, size: 16, color: AppTheme.textSecondary),
              onPressed: _loadingCars ? null : _refreshCars,
            ).withClickCursor,
            const SizedBox(width: 8),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              ),
              onPressed: () => _showAddCarDialog(),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(FluentIcons.add, size: 14, color: Colors.white),
                SizedBox(width: 8),
                Text("Add New Car", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ).withClickCursor,
          ]),

          const SizedBox(height: 24),

          // STAT CARDS
          if (isNarrow)
            Column(children: [
              Row(children: [
                StatCard(label: "Total Cars", value: "${_cars.length}", icon: FluentIcons.car, color: AppTheme.primary),
                const SizedBox(width: 12),
                StatCard(label: "Available", value: "$_availableCount", icon: FluentIcons.check_mark, color: AppTheme.success),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                StatCard(label: "Sold", value: "$_soldCount", icon: FluentIcons.completed, color: AppTheme.textMuted),
                const SizedBox(width: 12),
                StatCard(label: "Car Expenses", value: formatFullPrice(_totalCarExpenses), icon: FluentIcons.repair, color: AppTheme.warning),
              ]),
            ])
          else
            Row(children: [
              StatCard(label: "Total Cars", value: "${_cars.length}", icon: FluentIcons.car, color: AppTheme.primary),
              const SizedBox(width: 16),
              StatCard(label: "Available", value: "$_availableCount", icon: FluentIcons.check_mark, color: AppTheme.success),
              const SizedBox(width: 16),
              StatCard(label: "Sold", value: "$_soldCount", icon: FluentIcons.completed, color: AppTheme.textMuted),
              const SizedBox(width: 16),
              StatCard(label: "Car Expenses", value: formatFullPrice(_totalCarExpenses), icon: FluentIcons.repair, color: AppTheme.warning),
            ]),

          const SizedBox(height: 24),

          // TOOLBAR
          if (isNarrow)
            Column(children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _buildFilterChip("All", _cars.length),
                  const SizedBox(width: 8),
                  _buildFilterChip("Available", _availableCount),
                  const SizedBox(width: 8),
                  _buildFilterChip("Sold", _soldCount),
                  const SizedBox(width: 8),
                  _buildFilterChip("Booked", _bookedCount),
                ]),
              ),
            ])
          else
            Row(children: [
              Expanded(flex: 3, child: _buildSearchBar()),
              const SizedBox(width: 16),
              _buildFilterChip("All", _cars.length),
              const SizedBox(width: 8),
              _buildFilterChip("Available", _availableCount),
              const SizedBox(width: 8),
              _buildFilterChip("Sold", _soldCount),
              const SizedBox(width: 8),
              _buildFilterChip("Booked", _bookedCount),
              const SizedBox(width: 12),
              ComboBox<String>(
                value: _sortBy,
                items: ['Newest', 'Price: High', 'Price: Low'].map((s) => ComboBoxItem<String>(value: s, child: Text(s, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)))).toList(),
                onChanged: (v) { if (v != null) setState(() => _sortBy = v); },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(_isGridView ? FluentIcons.grid_view_medium : FluentIcons.list, size: 16, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _isGridView = !_isGridView),
              ).withClickCursor,
            ]),

          const SizedBox(height: 12),
          Text("${_filtered.length} of ${_cars.length} cars", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 12),

          // CAR LIST
          if (_isGridView)
            _buildGridView(isNarrow, isMedium)
          else
            ..._filtered.asMap().entries.map((e) => _buildCarListItem(e.value, e.key, isNarrow)),

          if (_filtered.isEmpty) const EmptyState(message: 'No cars found'),

          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildGridView(bool isNarrow, bool isMedium) {
    final cols = isNarrow ? 1 : (isMedium ? 2 : 3);
    final items = _filtered;

    return Column(children: [
      for (int i = 0; i < items.length; i += cols)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (int j = 0; j < cols; j++)
              if (i + j < items.length)
                Expanded(child: Padding(
                  padding: EdgeInsets.only(right: j < cols - 1 ? 14 : 0),
                  child: _buildCarCard(items[i + j]),
                ))
              else
                const Expanded(child: SizedBox()),
          ]),
        ),
    ]);
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    final statusColor = _statusColor(car['status']);
    final carExpenses = car['carExpenses'] as List;
    final totalExpense = carExpenses.fold(0, (s, e) => (s) + ((e as Map)['amount'] as int));

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Photo carousel — shows real photos, with left/right arrows when 2+.
        _CarPhotoCarousel(
          photos: List<String>.from(car['photos'] as List),
          height: 140,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          overlays: [
            Positioned(top: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(5)),
              child: Text("${car['year']}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
            )),
            Positioned(top: 10, right: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(5)),
              child: Text(car['status'], style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            )),
            Positioned(bottom: 10, right: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(5)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(FluentIcons.camera, size: 10, color: Colors.white),
                const SizedBox(width: 4),
                Text("${(car['photos'] as List).length}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: Colors.white)),
              ]),
            )),
          ],
        ),

        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(car['name'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text("${car['model']} \u2022 ${car['color']} \u2022 ${car['transmission']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 8),

            // Chassis & Engine
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(6)),
              child: Column(children: [
                Row(children: [
                  Icon(FluentIcons.number_field, size: 10, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text("Chassis: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                  Flexible(child: Text(car['chassisNo'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(FluentIcons.settings, size: 10, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text("Engine: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                  Flexible(child: Text(car['engineNo'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary))),
                ]),
              ]),
            ),

            const SizedBox(height: 10),

            // Investor link
            Row(children: [
              Icon(FluentIcons.people, size: 11, color: AppTheme.info),
              const SizedBox(width: 6),
              Flexible(child: Text("Investor: ${car['investor']}", overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.info))),
            ]),

            const SizedBox(height: 8),

            // Document Tracking — shows the per-doc receipt state Inam Motors
            // recorded when the car was added/edited. Short labels keep the
            // row from wrapping on narrow grid widths.
            Row(children: [
              _buildDocCheckbox("F", car['fileHandedOver']),
              const SizedBox(width: 8),
              _buildDocCheckbox("SC", car['smartCardHandedOver'] ?? false),
              const SizedBox(width: 8),
              _buildDocCheckbox("P", car['numberPlateHandedOver']),
              const SizedBox(width: 8),
              _buildDocCheckbox("R/K", car['remoteKeyHandedOver'] ?? false),
            ]),

            // Buyer name for Sold cars
            if (car['status'] == 'Sold' && (car['buyer'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.info.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.info.withValues(alpha: 0.15))),
                child: Row(children: [
                  Icon(FluentIcons.contact, size: 12, color: AppTheme.info),
                  const SizedBox(width: 6),
                  Text("Buyer: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
                  Flexible(child: Text(car['buyer'], overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.info))),
                ]),
              ),
            ],

            const SizedBox(height: 10),

            // Price + Expense
            Row(children: [
              Expanded(child: Text(formatFullPrice(car['price']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary))),
              if (totalExpense > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text("Exp: ${formatFullPrice(totalExpense)}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.warning)),
                ),
            ]),

            const SizedBox(height: 12),

            // Action buttons
            Row(children: [
              if ((car['notes'] as String? ?? '').trim().isNotEmpty) ...[
                Tooltip(
                  message: "Note Entered",
                  child: IconButton(
                    icon: Icon(FluentIcons.quick_note, size: 14, color: const Color(0xFFF59E0B)),
                    onPressed: () => _showNoteDialog(car),
                  ).withClickCursor,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(child: Button(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
                ),
                onPressed: () => _showEditCarDialog(car),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(FluentIcons.edit, size: 12),
                  SizedBox(width: 6),
                  Text("Edit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
                ]),
              ).withClickCursor),
              const SizedBox(width: 6),
              Expanded(child: Button(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
                ),
                onPressed: () => _showRemoveCarDialog(car),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(FluentIcons.delete, size: 12, color: AppTheme.error),
                  const SizedBox(width: 6),
                  Text("Remove", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.error)),
                ]),
              ).withClickCursor),
              const SizedBox(width: 6),
              Expanded(child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppTheme.error.withValues(alpha: 0.9)),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
                ),
                onPressed: () => _showCarPdf(car),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(FluentIcons.pdf, size: 12, color: Colors.white),
                  SizedBox(width: 6),
                  Text("PDF", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: Colors.white)),
                ]),
              ).withClickCursor),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildCarListItem(Map<String, dynamic> car, int index, bool isNarrow) {
    final statusColor = _statusColor(car['status']);
    final carExpenses = car['carExpenses'] as List;
    final totalExpense = carExpenses.fold(0, (s, e) => (s) + ((e as Map)['amount'] as int));
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isExpanded ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.divider),
      ),
      child: Column(children: [
        // Main row
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(color: AppTheme.divider.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
              child: (car['photos'] as List).isNotEmpty
                  ? Image.file(File((car['photos'] as List).first.toString()), fit: BoxFit.cover)
                  : Icon(FluentIcons.car, size: 22, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(car['name'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                  child: Text(car['status'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ]),
              const SizedBox(height: 4),
              Text("${car['year']} \u2022 ${car['color']} \u2022 ${car['transmission']} \u2022 ${car['mileage']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 2),
              Row(children: [
                Text("Chassis: ${car['chassisNo']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textSecondary)),
                if (car['regNo'] != null && car['regNo'].toString().isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text("Reg: ${car['regNo']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ],
              ]),
              if (car['status'] == 'Sold' && (car['buyer'] ?? '').toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(children: [
                    Icon(FluentIcons.contact, size: 10, color: AppTheme.info),
                    const SizedBox(width: 4),
                    Text("Buyer: ${car['buyer']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.info)),
                  ]),
                ),
            ])),
            if (!isNarrow) ...[
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formatFullPrice(car['price']), style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                const SizedBox(height: 4),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _buildDocCheckbox("F", car['fileHandedOver']),
                  const SizedBox(width: 6),
                  _buildDocCheckbox("SC", car['smartCardHandedOver'] ?? false),
                  const SizedBox(width: 6),
                  _buildDocCheckbox("P", car['numberPlateHandedOver']),
                  const SizedBox(width: 6),
                  _buildDocCheckbox("R/K", car['remoteKeyHandedOver'] ?? false),
                ]),
              ]),
              const SizedBox(width: 8),
            ],
            Column(children: [
              IconButton(
                icon: Icon(isExpanded ? FluentIcons.chevron_up : FluentIcons.chevron_down, size: 12, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _expandedIndex = isExpanded ? null : index),
              ).withClickCursor,
              if ((car['notes'] as String? ?? '').trim().isNotEmpty)
                Tooltip(
                  message: "Note Entered",
                  child: IconButton(
                    icon: Icon(FluentIcons.quick_note, size: 12, color: const Color(0xFFF59E0B)),
                    onPressed: () => _showNoteDialog(car),
                  ).withClickCursor,
                ),
              IconButton(
                icon: const Icon(FluentIcons.edit, size: 12, color: AppTheme.primary),
                onPressed: () => _showEditCarDialog(car),
              ).withClickCursor,
              IconButton(
                icon: Icon(FluentIcons.delete, size: 12, color: AppTheme.error.withValues(alpha: 0.7)),
                onPressed: () => _showRemoveCarDialog(car),
              ).withClickCursor,
              IconButton(
                icon: const Icon(FluentIcons.pdf, size: 12, color: AppTheme.error),
                onPressed: () => _showCarPdf(car),
              ).withClickCursor,
            ]),
          ]),
        ),

        // Expanded details
        if (isExpanded) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border(top: BorderSide(color: AppTheme.divider)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isNarrow)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildDetailRow("Engine No", car['engineNo']),
                  _buildDetailRow("Chassis No", car['chassisNo']),
                  _buildDetailRow("Investor", car['investor']),
                  _buildDetailRow("Fuel", car['fuel']),
                ])
              else
                Row(children: [
                  Expanded(child: _buildDetailRow("Engine No", car['engineNo'])),
                  Expanded(child: _buildDetailRow("Chassis No", car['chassisNo'])),
                  Expanded(child: _buildDetailRow("Investor", car['investor'])),
                  Expanded(child: _buildDetailRow("Fuel", car['fuel'])),
                ]),
              const SizedBox(height: 16),

              // Photo Gallery section — render actual image files saved by
              // `_pickAndSaveImages`. Wraps with errorBuilder so legacy
              // labels like "Front" or missing files just show a camera
              // placeholder instead of crashing the card.
              Text("Photo Gallery", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Wrap(spacing: 10, runSpacing: 10, children: [
                ...() {
                  final allPaths = (car['photos'] as List)
                      .map((p) => p.toString())
                      .toList();
                  return allPaths.asMap().entries.map((entry) {
                    final i = entry.key;
                    final path = entry.value;
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => showFullscreenGallery(
                          context,
                          photos: allPaths,
                          initialIndex: i,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(children: [
                            Container(
                              width: 100, height: 75,
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                border: Border.all(color: AppTheme.divider),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FluentIcons.camera, size: 16, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                                    const SizedBox(height: 4),
                                    Text(path.split(RegExp(r'[\\/]')).last,
                                        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, color: AppTheme.textMuted),
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4, right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(FluentIcons.full_screen,
                                    size: 10, color: Colors.white),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    );
                  });
                }(),
                Container(
                  width: 100, height: 75,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(FluentIcons.add, size: 14, color: AppTheme.primary.withValues(alpha: 0.6)),
                    Text("Upload", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, color: AppTheme.primary.withValues(alpha: 0.6))),
                  ]),
                ),
              ]),

              if (carExpenses.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(children: [
                  Text("Car-Specific Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const Spacer(),
                  Text("Total: ${formatFullPrice(totalExpense)}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.warning)),
                ]),
                const SizedBox(height: 8),
                ...carExpenses.map((exp) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Icon(FluentIcons.repair, size: 12, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(child: Text((exp as Map)['title'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary))),
                    Text(formatFullPrice(exp['amount']), style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.warning)),
                    const SizedBox(width: 12),
                    Text(exp['date'], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                  ]),
                )),
              ],

              const SizedBox(height: 16),
              Text("Document Tracking", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(children: [
                _buildDocCheck("File", car['fileHandedOver']),
                const SizedBox(width: 20),
                _buildDocCheck("Smart Card", car['smartCardHandedOver'] ?? false),
                const SizedBox(width: 20),
                _buildDocCheck("Number Plate", car['numberPlateHandedOver']),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildDocCheck(String label, bool value) {
    return Row(children: [
      Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: value ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: value ? AppTheme.success : AppTheme.error.withValues(alpha: 0.5)),
        ),
        child: Icon(value ? FluentIcons.check_mark : FluentIcons.cancel, size: 12, color: value ? AppTheme.success : AppTheme.error),
      ),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary)),
      const SizedBox(width: 4),
      Text(value ? "Yes" : "No", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: value ? AppTheme.success : AppTheme.error)),
    ]);
  }

  Widget _buildDocCheckbox(String label, bool value) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: value ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: value ? AppTheme.success : AppTheme.error.withValues(alpha: 0.5), width: 1),
        ),
        child: Icon(value ? FluentIcons.check_mark : FluentIcons.cancel, size: 8, color: value ? AppTheme.success : AppTheme.error),
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
    ]);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
      child: TextBox(
        placeholder: "Search by name, chassis, engine, investor...",
        placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted),
        style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
        prefix: Padding(padding: const EdgeInsets.only(left: 10), child: Icon(FluentIcons.search, size: 14, color: AppTheme.textMuted)),
        decoration: WidgetStateProperty.all(BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.transparent))),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final sel = _selectedFilter == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
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
            decoration: BoxDecoration(color: sel ? Colors.white.withValues(alpha: 0.2) : AppTheme.background, borderRadius: BorderRadius.circular(10)),
            child: Text("$count", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppTheme.textSecondary)),
          ),
        ]),
      ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Available': return AppTheme.success;
      case 'Sold': return AppTheme.textMuted;
      case 'Booked': return AppTheme.warning;
      default: return AppTheme.textSecondary;
    }
  }
}

/// Inventory card photo carousel: shows the current photo with optional
/// left/right arrows when 2+ photos are available, plus a small dot indicator.
/// `overlays` are stacked above the image (year/status/count chips).
class _CarPhotoCarousel extends StatefulWidget {
  final List<String> photos;
  final double height;
  final BorderRadius borderRadius;
  final List<Widget> overlays;

  const _CarPhotoCarousel({
    required this.photos,
    required this.height,
    required this.borderRadius,
    this.overlays = const [],
  });

  @override
  State<_CarPhotoCarousel> createState() => _CarPhotoCarouselState();
}

class _CarPhotoCarouselState extends State<_CarPhotoCarousel> {
  int _index = 0;

  void _prev() => setState(() {
        _index = (_index - 1 + widget.photos.length) % widget.photos.length;
      });
  void _next() => setState(() {
        _index = (_index + 1) % widget.photos.length;
      });

  @override
  Widget build(BuildContext context) {
    final hasPhotos = widget.photos.isNotEmpty;
    final showArrows = widget.photos.length > 1;
    final safeIndex = hasPhotos ? _index.clamp(0, widget.photos.length - 1) : 0;

    return Container(
      height: widget.height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppTheme.divider.withValues(alpha: 0.3),
        borderRadius: widget.borderRadius,
      ),
      child: Stack(fit: StackFit.expand, children: [
        if (hasPhotos)
          Image.file(
            File(widget.photos[safeIndex]),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Icon(FluentIcons.camera,
                  size: 36, color: AppTheme.textMuted.withValues(alpha: 0.4)),
            ),
          )
        else
          Center(
            child: Icon(FluentIcons.car,
                size: 40, color: AppTheme.textMuted.withValues(alpha: 0.3)),
          ),
        ...widget.overlays,
        if (hasPhotos)
          Positioned(
            top: 8,
            right: 8,
            child: Tooltip(
              message: 'Open fullscreen',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => showFullscreenGallery(
                    context,
                    photos: widget.photos,
                    initialIndex: safeIndex,
                  ),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(FluentIcons.full_screen,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        if (showArrows) ...[
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _arrowButton(FluentIcons.chevron_left, _prev),
            ),
          ),
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _arrowButton(FluentIcons.chevron_right, _next),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.photos.length, (i) {
                  final active = i == safeIndex;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: active ? 8 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

/// Opens [photos] as a modal fullscreen viewer starting at [initialIndex].
/// Left/right arrow buttons (and keyboard arrows / Escape) navigate between
/// images. Use this from any car photo thumbnail or carousel.
void showFullscreenGallery(
  BuildContext context, {
  required List<String> photos,
  int initialIndex = 0,
}) {
  if (photos.isEmpty) return;
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (_) => _FullscreenGallery(
      photos: photos,
      initialIndex: initialIndex.clamp(0, photos.length - 1),
    ),
  );
}

class _FullscreenGallery extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  const _FullscreenGallery({required this.photos, required this.initialIndex});

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late int _index = widget.initialIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _prev() => setState(() {
        _index = (_index - 1 + widget.photos.length) % widget.photos.length;
      });
  void _next() => setState(() {
        _index = (_index + 1) % widget.photos.length;
      });

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _prev();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _next();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final multi = widget.photos.length > 1;
    final path = widget.photos[_index];
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Stack(
        children: [
          // Tap empty area to dismiss.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          // Image (clamped — ignores hits on the surrounding empty area).
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    FluentIcons.camera,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          // Top bar: counter + close.
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  multi ? '${_index + 1} / ${widget.photos.length}' : '1 / 1',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              _GalleryButton(
                icon: FluentIcons.cancel,
                tooltip: 'Close (Esc)',
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ]),
          ),
          if (multi) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GalleryButton(
                  icon: FluentIcons.chevron_left,
                  tooltip: 'Previous (←)',
                  onTap: _prev,
                  large: true,
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GalleryButton(
                  icon: FluentIcons.chevron_right,
                  tooltip: 'Next (→)',
                  onTap: _next,
                  large: true,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool large;
  const _GalleryButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final dim = large ? 44.0 : 36.0;
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: dim,
            height: dim,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15), width: 1),
            ),
            child: Icon(icon, size: large ? 18 : 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
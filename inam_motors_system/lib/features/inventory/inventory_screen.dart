import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isGridView = true;
  String _sortBy = 'Newest';

  final List<Map<String, dynamic>> _cars = [
    {'name': 'Toyota Grande', 'make': 'Toyota', 'model': 'Grande', 'year': 2024, 'color': 'White', 'price': 8500000, 'status': 'Available', 'mileage': 0, 'fuel': 'Petrol', 'transmission': 'Automatic'},
    {'name': 'Honda Civic', 'make': 'Honda', 'model': 'Civic', 'year': 2023, 'color': 'Black', 'price': 7200000, 'status': 'Sold', 'mileage': 12000, 'fuel': 'Petrol', 'transmission': 'Automatic'},
    {'name': 'Suzuki Alto', 'make': 'Suzuki', 'model': 'Alto', 'year': 2025, 'color': 'Silver', 'price': 3200000, 'status': 'Available', 'mileage': 0, 'fuel': 'Petrol', 'transmission': 'Manual'},
    {'name': 'Kia Sportage', 'make': 'Kia', 'model': 'Sportage', 'year': 2022, 'color': 'Red', 'price': 9500000, 'status': 'Booked', 'mileage': 25000, 'fuel': 'Petrol', 'transmission': 'Automatic'},
    {'name': 'Toyota Corolla', 'make': 'Toyota', 'model': 'Corolla', 'year': 2024, 'color': 'Grey', 'price': 6800000, 'status': 'Available', 'mileage': 5000, 'fuel': 'Petrol', 'transmission': 'Automatic'},
    {'name': 'Honda City', 'make': 'Honda', 'model': 'City', 'year': 2023, 'color': 'White', 'price': 5200000, 'status': 'Available', 'mileage': 8000, 'fuel': 'Petrol', 'transmission': 'Automatic'},
    {'name': 'Suzuki Cultus', 'make': 'Suzuki', 'model': 'Cultus', 'year': 2024, 'color': 'Blue', 'price': 3800000, 'status': 'Sold', 'mileage': 3000, 'fuel': 'Petrol', 'transmission': 'Manual'},
    {'name': 'Toyota Yaris', 'make': 'Toyota', 'model': 'Yaris', 'year': 2023, 'color': 'White', 'price': 5500000, 'status': 'Available', 'mileage': 15000, 'fuel': 'Petrol', 'transmission': 'Automatic'},
    {'name': 'Hyundai Tucson', 'make': 'Hyundai', 'model': 'Tucson', 'year': 2022, 'color': 'Black', 'price': 11000000, 'status': 'Booked', 'mileage': 20000, 'fuel': 'Diesel', 'transmission': 'Automatic'},
    {'name': 'MG HS', 'make': 'MG', 'model': 'HS', 'year': 2024, 'color': 'Burgundy', 'price': 9800000, 'status': 'Available', 'mileage': 0, 'fuel': 'Petrol', 'transmission': 'Automatic'},
    {'name': 'Changan Alsvin', 'make': 'Changan', 'model': 'Alsvin', 'year': 2024, 'color': 'Silver', 'price': 4600000, 'status': 'Sold', 'mileage': 2000, 'fuel': 'Petrol', 'transmission': 'Automatic'},
    {'name': 'Toyota Fortuner', 'make': 'Toyota', 'model': 'Fortuner', 'year': 2023, 'color': 'White', 'price': 18500000, 'status': 'Available', 'mileage': 10000, 'fuel': 'Diesel', 'transmission': 'Automatic'},
  ];

  List<Map<String, dynamic>> get _filteredCars {
    var cars = _cars.where((car) {
      if (_selectedFilter != 'All' && car['status'] != _selectedFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return car['name'].toString().toLowerCase().contains(q) ||
            car['make'].toString().toLowerCase().contains(q) ||
            car['model'].toString().toLowerCase().contains(q) ||
            car['color'].toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
    return cars;
  }

  int get _availableCount => _cars.where((c) => c['status'] == 'Available').length;
  int get _soldCount => _cars.where((c) => c['status'] == 'Sold').length;
  int get _bookedCount => _cars.where((c) => c['status'] == 'Booked').length;

  String _formatPrice(int price) {
    if (price >= 10000000) {
      return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
    } else if (price >= 100000) {
      return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
    }
    return 'Rs $price';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final isMedium = constraints.maxWidth < 1000;

        return ScaffoldPage.scrollable(
          padding: EdgeInsets.all(isNarrow ? 16 : 28),
          children: [
            // HEADER ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Inventory",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: isNarrow ? 22 : 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Manage your car stock and listings",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: isNarrow ? 12 : 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  onPressed: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.add, size: 14, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Add New Car",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SUMMARY STATS
            if (isNarrow)
              Column(children: [
                Row(children: [
                  _buildMiniStat("Total Cars", "${_cars.length}", FluentIcons.car, AppTheme.primary),
                  const SizedBox(width: 12),
                  _buildMiniStat("Available", "$_availableCount", FluentIcons.check_mark, AppTheme.success),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _buildMiniStat("Sold", "$_soldCount", FluentIcons.completed, AppTheme.textMuted),
                  const SizedBox(width: 12),
                  _buildMiniStat("Booked", "$_bookedCount", FluentIcons.clock, AppTheme.warning),
                ]),
              ])
            else
              Row(children: [
                _buildMiniStat("Total Cars", "${_cars.length}", FluentIcons.car, AppTheme.primary),
                const SizedBox(width: 16),
                _buildMiniStat("Available", "$_availableCount", FluentIcons.check_mark, AppTheme.success),
                const SizedBox(width: 16),
                _buildMiniStat("Sold", "$_soldCount", FluentIcons.completed, AppTheme.textMuted),
                const SizedBox(width: 16),
                _buildMiniStat("Booked", "$_bookedCount", FluentIcons.clock, AppTheme.warning),
              ]),

            const SizedBox(height: 24),

            // SEARCH + FILTERS + VIEW TOGGLE
            _buildToolbar(isNarrow),

            const SizedBox(height: 20),

            // FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("All", _cars.length),
                  const SizedBox(width: 8),
                  _buildFilterChip("Available", _availableCount),
                  const SizedBox(width: 8),
                  _buildFilterChip("Sold", _soldCount),
                  const SizedBox(width: 8),
                  _buildFilterChip("Booked", _bookedCount),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // RESULTS COUNT
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Showing ${_filteredCars.length} of ${_cars.length} cars",
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ),

            // CAR GRID / LIST
            if (_isGridView)
              _buildCarGrid(isNarrow, isMedium)
            else
              _buildCarList(),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // ── Toolbar: Search + Sort + View Toggle ──
  Widget _buildToolbar(bool isNarrow) {
    if (isNarrow) {
      return Column(
        children: [
          // Search bar full width
          _buildSearchBar(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSortDropdown()),
              const SizedBox(width: 12),
              _buildViewToggle(),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(flex: 3, child: _buildSearchBar()),
        const SizedBox(width: 16),
        SizedBox(width: 180, child: _buildSortDropdown()),
        const SizedBox(width: 12),
        _buildViewToggle(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TextBox(
        placeholder: "Search cars by name, make, model, color...",
        placeholderStyle: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 13,
          color: AppTheme.textMuted,
        ),
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 13,
          color: AppTheme.textPrimary,
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(FluentIcons.search, size: 14, color: AppTheme.textMuted),
        ),
        decoration: WidgetStateProperty.all(BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent),
        )),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: DropDownButton(
        title: Text(
          _sortBy,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            color: AppTheme.textPrimary,
          ),
        ),
        items: [
          MenuFlyoutItem(text: const Text("Newest", style: TextStyle(fontFamily: AppTheme.fontFamily)), onPressed: () => setState(() => _sortBy = 'Newest')),
          MenuFlyoutItem(text: const Text("Price: Low to High", style: TextStyle(fontFamily: AppTheme.fontFamily)), onPressed: () => setState(() => _sortBy = 'Price: Low to High')),
          MenuFlyoutItem(text: const Text("Price: High to Low", style: TextStyle(fontFamily: AppTheme.fontFamily)), onPressed: () => setState(() => _sortBy = 'Price: High to Low')),
          MenuFlyoutItem(text: const Text("Name A-Z", style: TextStyle(fontFamily: AppTheme.fontFamily)), onPressed: () => setState(() => _sortBy = 'Name A-Z')),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn(FluentIcons.grid_view_medium, true),
          Container(width: 1, height: 20, color: AppTheme.divider),
          _buildToggleBtn(FluentIcons.list, false),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(IconData icon, bool isGrid) {
    final selected = _isGridView == isGrid;
    return GestureDetector(
      onTap: () => setState(() => _isGridView = isGrid),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(isGrid ? 8 : 0).copyWith(
            topRight: Radius.circular(isGrid ? 0 : 8),
            bottomRight: Radius.circular(isGrid ? 0 : 8),
            topLeft: Radius.circular(isGrid ? 8 : 0),
            bottomLeft: Radius.circular(isGrid ? 8 : 0),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: selected ? AppTheme.primary : AppTheme.textMuted,
        ),
      ),
    );
  }

  // ── Filter Chip ──
  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : AppTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mini Stat Card ──
  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Car Grid ──
  Widget _buildCarGrid(bool isNarrow, bool isMedium) {
    final cars = _filteredCars;
    final crossAxisCount = isNarrow ? 1 : (isMedium ? 2 : 3);

    if (cars.isEmpty) return _buildEmptyState();

    final List<Widget> rows = [];
    for (int i = 0; i < cars.length; i += crossAxisCount) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < crossAxisCount; j++) {
        if (i + j < cars.length) {
          if (j > 0) rowChildren.add(const SizedBox(width: 16));
          rowChildren.add(Expanded(child: _buildCarCard(cars[i + j])));
        } else {
          if (j > 0) rowChildren.add(const SizedBox(width: 16));
          rowChildren.add(const Expanded(child: SizedBox()));
        }
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 16));
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowChildren,
      ));
    }

    return Column(children: rows);
  }

  // ── Car List ──
  Widget _buildCarList() {
    final cars = _filteredCars;
    if (cars.isEmpty) return _buildEmptyState();

    return Column(
      children: cars.map((car) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildCarListItem(car),
        );
      }).toList(),
    );
  }

  // ── Car Card (Grid View) ──
  Widget _buildCarCard(Map<String, dynamic> car) {
    final statusColor = _statusColor(car['status']);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(FluentIcons.car, size: 48, color: AppTheme.divider),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      car['status'],
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.textPrimary.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${car['year']}",
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car['name'],
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${car['color']} \u2022 ${car['transmission']} \u2022 ${car['fuel']}",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatPrice(car['price']),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(FluentIcons.speed_high, size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          "${car['mileage']} km",
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("View", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text("Edit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Car List Item ──
  Widget _buildCarListItem(Map<String, dynamic> car) {
    final statusColor = _statusColor(car['status']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.car, size: 24, color: AppTheme.divider),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        car['name'],
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        car['status'],
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${car['year']} \u2022 ${car['color']} \u2022 ${car['transmission']} \u2022 ${car['fuel']} \u2022 ${car['mileage']} km",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _formatPrice(car['price']),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Button(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("View", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Edit", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(FluentIcons.search, size: 32, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              "No cars found",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Try adjusting your search or filters",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Available':
        return AppTheme.success;
      case 'Sold':
        return AppTheme.textMuted;
      case 'Booked':
        return AppTheme.warning;
      default:
        return AppTheme.textSecondary;
    }
  }
}

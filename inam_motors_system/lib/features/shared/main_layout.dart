import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';
import '../../main.dart';
import '../../models/business_profile.dart';
import '../dashboard/dashboard_screen.dart';
import 'notifications_bell.dart';
import '../inventory/inventory_screen.dart';
import '../customers/customers_screen.dart';
import '../investors/investors_screen.dart';
import '../expenses/expenses_screen.dart';
import '../documents/document_tracking_screen.dart';
import '../settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  PaneDisplayMode _displayMode = PaneDisplayMode.open;

  final _inventoryKey = GlobalKey<InventoryScreenState>();
  final _customersKey = GlobalKey<CustomersScreenState>();
  final _expensesKey = GlobalKey<ExpensesScreenState>();
  final _adminFlyout = FlyoutController();

  @override
  void dispose() {
    _adminFlyout.dispose();
    super.dispose();
  }

  Future<void> _handleSignOut() async {
    try {
      AuthGate.isUnlocked = false;
      await authService.signOut();
    } catch (e) {
      debugPrint('[MainLayout] Sign-out failed: $e');
    }
  }

  void _openAdminMenu() {
    _adminFlyout.showFlyout(
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: FlyoutPlacementMode.bottomRight,
      ),
      builder: (ctx) => MenuFlyout(items: [
        MenuFlyoutItem(
          leading: ValueListenableBuilder<bool>(
            valueListenable: InamMotorsApp.isDarkMode,
            builder: (_, dark, _)=> Icon(
              dark ? FluentIcons.sunny : FluentIcons.clear_night,
              size: 14,
            ),
          ),
          text: ValueListenableBuilder<bool>(
            valueListenable: InamMotorsApp.isDarkMode,
            builder: (_, dark, _)=> Text(
              dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13),
            ),
          ),
          onPressed: () {
            Navigator.of(ctx).pop();
            InamMotorsApp.isDarkMode.value = !InamMotorsApp.isDarkMode.value;
          },
        ),
        const MenuFlyoutSeparator(),
        MenuFlyoutItem(
          leading: Icon(FluentIcons.sign_out, size: 14, color: AppTheme.error),
          text: Text(
            'Sign Out',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.error),
          ),
          onPressed: () {
            Navigator.of(ctx).pop();
            _handleSignOut();
          },
        ),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load the live business profile so the header brand label, dashboards,
    // and any future invoice/receipt rendering pick up the current values.
    businessProfileService.fetchSafe().catchError((e) {
      debugPrint('[MainLayout] BizProfile fetch failed: $e');
      return const BusinessProfile();
    });
    // One-time seed of demo data on app launch (if not already seeded).
    _ensureSeedDataLoaded();
    // Prime the notification list so the bell badge is correct on first paint.
    notificationsService.refresh().catchError((e) {
      debugPrint('[MainLayout] Notifications refresh failed: $e');
    });
  }

  /// Automatically populate Firestore with demo data on first run.
  /// Silently fails if seeding is not needed or if it's already been done.
  Future<void> _ensureSeedDataLoaded() async {
    try {
      debugPrint('[MainLayout] Checking if seed data is needed...');
      // Try to fetch one investor to see if any data exists.
      final investors = await investorsRepo.listAll();
      if (investors.isNotEmpty) {
        debugPrint('[MainLayout] Seed data already exists (${investors.length} investor(s) found)');
        return;
      }
      debugPrint('[MainLayout] No data found — auto-seeding Firestore...');
      await seedService.seedAll(onProgress: (step) {
        debugPrint('[MainLayout] Seed: $step');
      });
      debugPrint('[MainLayout] Auto-seed completed successfully');
    } catch (e, s) {
      debugPrint('[MainLayout] Auto-seed skipped or failed: $e');
      debugPrint('[MainLayout] Stack: $s');
      // Silently fail — user can manually seed if needed.
    }
  }

  void _openAddDialog(int index, GlobalKey key) {
    setState(() => _selectedIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = key.currentState;
      if (state is InventoryScreenState) state.showAddDialog();
      if (state is CustomersScreenState) state.showAddDialog();
      if (state is ExpensesScreenState) state.showAddDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _displayMode == PaneDisplayMode.open;
    final sidebarWidth = isOpen ? 240.0 : 50.0;

    return NavigationView(
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        leading: SizedBox(
          width: sidebarWidth,
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  isOpen ? FluentIcons.collapse_menu : FluentIcons.expand_menu,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _displayMode = isOpen
                        ? PaneDisplayMode.compact
                        : PaneDisplayMode.open;
                  });
                },
              ).withClickCursor,
              if (isOpen) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(FluentIcons.car, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<BusinessProfile>(
                  valueListenable: businessProfileService.profile,
                  builder: (_, profile, _) => Text(
                    profile.businessName.trim().isEmpty
                        ? 'Inam Motors'
                        : profile.businessName,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        height: 52,
        title: Row(
          children: [
            const Spacer(),
            const NotificationsBell(),
            const SizedBox(width: 4),
            FlyoutTarget(
              controller: _adminFlyout,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _openAdminMenu,
                  child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder<BusinessProfile>(
                    valueListenable: businessProfileService.profile,
                    builder: (_, profile, _) => Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          profile.initials,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(FluentIcons.chevron_down, size: 10, color: AppTheme.textSecondary),
                ],
              ),
            ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      pane: NavigationPane(
        selected: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
        displayMode: _displayMode,
        indicator: const StickyNavigationIndicator(),
        size: const NavigationPaneSize(openWidth: 240, compactWidth: 50),
        toggleable: false,
        header: _displayMode == PaneDisplayMode.open
            ? Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                child: Text(
                  "MAIN MENU",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              )
            : const SizedBox(height: 8),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.speed_high),
            title: Text("Dashboard", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
            body: DashboardScreen(
              onAddCar: () => _openAddDialog(1, _inventoryKey),
              onAddCustomer: () => _openAddDialog(2, _customersKey),
              onAddExpense: () => _openAddDialog(5, _expensesKey),
            ),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.car),
            title: Text("Inventory", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
            body: InventoryScreen(key: _inventoryKey),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: Text("Customers", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
            body: CustomersScreen(key: _customersKey),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.document_set),
            title: Text("Docs & Files", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
            body: const DocumentTrackingScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.money),
            title: Text("Investors", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
            body: const InvestorsScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.calculator_addition),
            title: Text("Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
            body: ExpensesScreen(key: _expensesKey),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: Text("Settings", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
            body: const SettingsScreen(),
          ),
        ],
      ),
    );
  }

}

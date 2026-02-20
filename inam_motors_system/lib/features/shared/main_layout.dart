import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../inventory/inventory_screen.dart';
import '../sales/sales_screen.dart';
import '../customers/customers_screen.dart';
import '../salesmen/salesmen_screen.dart';
import '../investors/investors_screen.dart';
import '../expenses/expenses_screen.dart';
import '../settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  PaneDisplayMode _displayMode = PaneDisplayMode.open;

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
              ),
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
                Text(
                  "Inam Motors",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppTheme.textPrimary,
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
            IconButton(
              icon: Icon(FluentIcons.ringer, size: 18, color: AppTheme.textSecondary),
              onPressed: () {},
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text(
                        "IM",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
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
            title: const Text("Dashboard", style: TextStyle(fontFamily: AppTheme.fontFamily)),
            body: const DashboardScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.car),
            title: const Text("Inventory", style: TextStyle(fontFamily: AppTheme.fontFamily)),
            body: const InventoryScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.document_set),
            title: const Text("Sales & Payments", style: TextStyle(fontFamily: AppTheme.fontFamily)),
            body: const SalesScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: const Text("Customers", style: TextStyle(fontFamily: AppTheme.fontFamily)),
            body: const CustomersScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people_repeat),
            title: const Text("Salesmen & Profit", style: TextStyle(fontFamily: AppTheme.fontFamily)),
            body: const SalesmenScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.money),
            title: const Text("Investors", style: TextStyle(fontFamily: AppTheme.fontFamily)),
            body: const InvestorsScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.calculator_addition),
            title: const Text("Expenses", style: TextStyle(fontFamily: AppTheme.fontFamily)),
            body: const ExpensesScreen(),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text("Settings", style: TextStyle(fontFamily: AppTheme.fontFamily)),
            body: const SettingsScreen(),
          ),
        ],
      ),
    );
  }

}

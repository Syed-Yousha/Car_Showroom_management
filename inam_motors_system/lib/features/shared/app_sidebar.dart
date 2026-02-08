import 'package:fluent_ui/fluent_ui.dart';
import '../dashboard/dashboard_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int topIndex = 0; // Tracks which tab is active

  // The screens for each tab
  final List<Widget> _pages = [
    const DashboardScreen(),
    const Center(child: Text("Inventory Screen (Coming Soon)")),
    const Center(child: Text("Sales Screen (Coming Soon)")),
    const Center(child: Text("Customers Screen (Coming Soon)")),
    const Center(child: Text("Investors Screen (Coming Soon)")),
    const Center(child: Text("Expenses Screen (Coming Soon)")),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text("Inam Motors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: PaneDisplayMode.open, // Keeps sidebar expanded
        
        // SIDEBAR ITEMS
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.speed_high),
            title: const Text("Dashboard"),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.car),
            title: const Text("Inventory"),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.invoice),
            title: const Text("Sales & Docs"),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.people),
            title: const Text("Customers"),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.money),
            title: const Text("Investors"),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.calculator_addition),
            title: const Text("Expenses"),
            body: const SizedBox.shrink(),
          ),
        ],
        
        // BOTTOM ITEMS
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text("Settings"),
            body: const SizedBox.shrink(),
          ),
        ],
      ),
      content: NavigationBody(
        index: topIndex,
        children: _pages,
      ),
    );
  }
}
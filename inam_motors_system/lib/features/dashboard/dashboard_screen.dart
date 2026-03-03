import 'package:fluent_ui/fluent_ui.dart';
import 'dart:math' as math;
import '../../core/theme.dart';
import '../shared/widgets.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onAddCar;
  final VoidCallback? onNewSale;
  final VoidCallback? onAddCustomer;
  final VoidCallback? onAddExpense;
  const DashboardScreen({super.key, this.onAddCar, this.onNewSale, this.onAddCustomer, this.onAddExpense});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final isMedium = constraints.maxWidth < 1000;

        return ScaffoldPage.scrollable(
          padding: EdgeInsets.all(isNarrow ? 16 : 28),
          children: [
            // TOP ROW: Welcome + Add New Car button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back, Admin",
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: isNarrow ? 22 : 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Here's what's happening with your showroom today.",
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
                  onPressed: () => widget.onAddCar?.call(),
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

            // QUICK ACTIONS ROW
            if (isNarrow)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildQuickActionFixed(FluentIcons.add_to, "Add Car", AppTheme.primary, () => widget.onAddCar?.call()),
                  _buildQuickActionFixed(FluentIcons.document, "New Sale", AppTheme.success, () => widget.onNewSale?.call()),
                  _buildQuickActionFixed(FluentIcons.people_add, "Add Customer", AppTheme.warning, () => widget.onAddCustomer?.call()),
                  _buildQuickActionFixed(FluentIcons.calculator, "Add Expense", AppTheme.error, () => widget.onAddExpense?.call()),
                ],
              )
            else
              Row(
                children: [
                  _buildQuickAction(icon: FluentIcons.add_to, label: "Add Car", color: AppTheme.primary, onTap: () => widget.onAddCar?.call()),
                  const SizedBox(width: 12),
                  _buildQuickAction(icon: FluentIcons.document, label: "New Sale", color: AppTheme.success, onTap: () => widget.onNewSale?.call()),
                  const SizedBox(width: 12),
                  _buildQuickAction(icon: FluentIcons.people_add, label: "Add Customer", color: AppTheme.warning, onTap: () => widget.onAddCustomer?.call()),
                  const SizedBox(width: 12),
                  _buildQuickAction(icon: FluentIcons.calculator, label: "Add Expense", color: AppTheme.error, onTap: () => widget.onAddExpense?.call()),
                ],
              ),

            const SizedBox(height: 24),

            // STAT CARDS
            if (isNarrow)
              Column(
                children: [
                  Row(children: [
                    _buildStatCard(title: "Total Cars", value: "84", change: "+5 this week", isPositive: true, graphColor: AppTheme.primary),
                    const SizedBox(width: 12),
                    _buildStatCard(title: "Cars Sold", value: "12", change: "+3 this month", isPositive: true, graphColor: AppTheme.success),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _buildStatCard(title: "Total Revenue", value: "Rs 6.5M", change: "+12% growth", isPositive: true, graphColor: AppTheme.warning),
                    const SizedBox(width: 12),
                    _buildStatCard(title: "Investors", value: "3", change: "Active partners", isPositive: true, graphColor: AppTheme.info),
                  ]),
                ],
              )
            else
              Row(
                children: [
                  _buildStatCard(title: "Total Cars", value: "84", change: "+5 this week", isPositive: true, graphColor: AppTheme.primary),
                  const SizedBox(width: 16),
                  _buildStatCard(title: "Cars Sold", value: "12", change: "+3 this month", isPositive: true, graphColor: AppTheme.success),
                  const SizedBox(width: 16),
                  _buildStatCard(title: "Total Revenue", value: "Rs 6.5M", change: "+12% growth", isPositive: true, graphColor: AppTheme.warning),
                  const SizedBox(width: 16),
                  _buildStatCard(title: "Investors", value: "3", change: "Active partners", isPositive: true, graphColor: AppTheme.info),
                ],
              ),

            const SizedBox(height: 24),

            // PAYMENT DUE ALERTS
            _buildPaymentAlerts(isNarrow),

            const SizedBox(height: 24),

            // MIDDLE SECTION
            if (isMedium)
              Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Revenue Statistics", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            Row(children: [
                              _buildLegendDot("Revenue", AppTheme.primary),
                              const SizedBox(width: 16),
                              _buildLegendDot("Expenses", AppTheme.warning),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Monthly revenue overview", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 220,
                          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(FluentIcons.chart, size: 40, color: AppTheme.primary.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text("Revenue Chart", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text("Add fl_chart package for visualization", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                          ])),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Recent Arrivals", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            HyperlinkButton(
                              style: ButtonStyle(foregroundColor: WidgetStateProperty.all(AppTheme.primary)),
                              onPressed: () {},
                              child: const Text("View All", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCarRow("Toyota Grande", "2024 \u2022 White", "Available", "Rs 85L"),
                        _buildCarRow("Honda Civic", "2023 \u2022 Black", "Sold", "Rs 72L"),
                        _buildCarRow("Suzuki Alto", "2025 \u2022 Silver", "Available", "Rs 32L"),
                        _buildCarRow("Kia Sportage", "2022 \u2022 Red", "Booked", "Rs 95L"),
                      ],
                    ),
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Revenue Statistics", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              Row(children: [
                                _buildLegendDot("Revenue", AppTheme.primary),
                                const SizedBox(width: 16),
                                _buildLegendDot("Expenses", AppTheme.warning),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Monthly revenue overview", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 260,
                            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(FluentIcons.chart, size: 40, color: AppTheme.primary.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text("Revenue Chart", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              const SizedBox(height: 4),
                              Text("Add fl_chart package for visualization", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                            ])),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Recent Arrivals", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              HyperlinkButton(
                                style: ButtonStyle(foregroundColor: WidgetStateProperty.all(AppTheme.primary)),
                                onPressed: () {},
                                child: const Text("View All", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCarRow("Toyota Grande", "2024 \u2022 White", "Available", "Rs 85L"),
                          _buildCarRow("Honda Civic", "2023 \u2022 Black", "Sold", "Rs 72L"),
                          _buildCarRow("Suzuki Alto", "2025 \u2022 Silver", "Available", "Rs 32L"),
                          _buildCarRow("Kia Sportage", "2022 \u2022 Red", "Booked", "Rs 95L"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // BOTTOM: Top Selling Brands
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Top Selling Brands", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      Text("This Month", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isNarrow)
                    Column(
                      children: [
                        _buildBrandProgress("Toyota", 0.75, AppTheme.primary),
                        const SizedBox(height: 14),
                        _buildBrandProgress("Honda", 0.60, AppTheme.success),
                        const SizedBox(height: 14),
                        _buildBrandProgress("Suzuki", 0.45, AppTheme.warning),
                        const SizedBox(height: 14),
                        _buildBrandProgress("Kia", 0.30, AppTheme.info),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(child: _buildBrandProgress("Toyota", 0.75, AppTheme.primary)),
                        const SizedBox(width: 32),
                        Expanded(child: _buildBrandProgress("Honda", 0.60, AppTheme.success)),
                        const SizedBox(width: 32),
                        Expanded(child: _buildBrandProgress("Suzuki", 0.45, AppTheme.warning)),
                        const SizedBox(width: 32),
                        Expanded(child: _buildBrandProgress("Kia", 0.30, AppTheme.info)),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // ── WhatsApp Reminder Dialog ──
  void _showWhatsAppDialog(Map<String, String> a) {
    final msg = "Assalam o Alaikum ${a['buyer']},\n\nThis is a gentle reminder from Inam Motors regarding your installment for ${a['car']}.\n\nDue Amount: ${a['amount']}\nDue Date: ${a['due']}\n\nKindly make the payment at your earliest convenience.\n\nThank you,\nInam Motors";

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Row(children: [
          Icon(FluentIcons.chat, size: 18, color: AppTheme.success),
          const SizedBox(width: 8),
          const Text("WhatsApp Reminder", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        ]),
        constraints: const BoxConstraints(maxWidth: 500),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text("To: ", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
            Text(a['buyer']!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.divider)),
            child: Text(msg, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textPrimary, height: 1.5)),
          ),
        ]),
        actions: [
          Button(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(fontFamily: AppTheme.fontFamily))),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.success)),
            onPressed: () => Navigator.pop(ctx),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(FluentIcons.chat, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text("Copy & Send", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Payment Due Alerts ──
  Widget _buildPaymentAlerts(bool isNarrow) {
    final alerts = [
      {'buyer': 'Usman Ali', 'car': 'Kia Sportage 2022', 'amount': 'Rs 5.0L', 'due': 'Feb 10, 2026', 'status': 'Due Today', 'urgency': 'high'},
      {'buyer': 'Bilal Malik', 'car': 'Suzuki Cultus 2024', 'amount': 'Rs 3.8L', 'due': 'Feb 12, 2026', 'status': 'Due in 2 days', 'urgency': 'medium'},
      {'buyer': 'Farhan Raza', 'car': 'Hyundai Tucson 2022', 'amount': 'Rs 4.0L', 'due': 'Feb 18, 2026', 'status': 'Upcoming', 'urgency': 'low'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: const Icon(FluentIcons.warning, size: 14, color: AppTheme.error),
            ),
            const SizedBox(width: 10),
            Text("Payment Due Alerts", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text("${alerts.length}", style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.error)),
            ),
            const Spacer(),
            HyperlinkButton(
              style: ButtonStyle(foregroundColor: WidgetStateProperty.all(AppTheme.primary)),
              onPressed: () {},
              child: const Text("View All", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 14),
          ...alerts.map((a) {
            final urgencyColor = a['urgency'] == 'high' ? AppTheme.error : (a['urgency'] == 'medium' ? AppTheme.warning : AppTheme.info);
            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: urgencyColor.withValues(alpha: 0.12)),
              ),
              child: Row(children: [
                Container(
                  width: 4, height: 40,
                  decoration: BoxDecoration(color: urgencyColor, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(a['buyer']!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: urgencyColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(a['status']!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 9, fontWeight: FontWeight.w700, color: urgencyColor)),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text("${a['car']} \u2022 ${a['amount']}", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted)),
                ])),
                if (!isNarrow) ...[
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(a['amount']!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700, color: urgencyColor)),
                    Text(a['due']!, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: AppTheme.textMuted)),
                  ]),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: "Send WhatsApp Reminder",
                    child: GestureDetector(
                      onTap: () => _showWhatsAppDialog(a),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(FluentIcons.chat, size: 14, color: AppTheme.success),
                      ),
                    ),
                  ),
                ],
              ]),
            );
          }),
        ],
      ),
    );
  }

  // ── Quick Action chip (expanded) ──
  Widget _buildQuickAction({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Quick Action chip (fixed width for wrap) ──
  Widget _buildQuickActionFixed(IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ]),
        ),
      ),
    );
  }

  // ── Stat Card with mini sparkline ──
  Widget _buildStatCard({required String title, required String value, required String change, required bool isPositive, required Color graphColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(child: Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
              SizedBox(width: 60, height: 28, child: CustomPaint(painter: _SparklinePainter(color: graphColor))),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [
            Icon(isPositive ? FluentIcons.up : FluentIcons.down, size: 10, color: isPositive ? AppTheme.success : AppTheme.error),
            const SizedBox(width: 4),
            Flexible(child: Text(change, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, fontWeight: FontWeight.w500, color: isPositive ? AppTheme.success : AppTheme.error))),
          ]),
        ]),
      ),
    );
  }

  // ── Legend dot ──
  static Widget _buildLegendDot(String label, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
    ]);
  }

  // ── Car Row ──
  Widget _buildCarRow(String name, String details, String status, String price) {
    Color statusColor = AppTheme.success;
    if (status == 'Sold') statusColor = AppTheme.textMuted;
    if (status == 'Booked') statusColor = AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(8)),
          child: Icon(FluentIcons.car, color: AppTheme.textSecondary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(details, style: TextStyle(fontFamily: AppTheme.fontFamily, color: AppTheme.textMuted, fontSize: 11)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.primary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(fontFamily: AppTheme.fontFamily, color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ]),
      ]),
    );
  }

  // ── Brand Progress ──
  Widget _buildBrandProgress(String brand, double progress, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(brand, style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w500, fontSize: 13, color: AppTheme.textPrimary)),
        Text("${(progress * 100).toInt()}%", style: TextStyle(fontFamily: AppTheme.fontFamily, color: color, fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
      const SizedBox(height: 8),
      Container(
        height: 6,
        decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(3)),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        ),
      ),
    ]);
  }
}

// ── Custom sparkline painter for stat cards ──
class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[];
    final random = math.Random(color.toARGB32());
    double y = size.height * 0.7;
    for (int i = 0; i <= 8; i++) {
      final x = (size.width / 8) * i;
      y = y + (random.nextDouble() - 0.6) * size.height * 0.25;
      y = y.clamp(size.height * 0.1, size.height * 0.9);
      points.add(Offset(x, y));
    }
    points[points.length - 1] = Offset(size.width, size.height * 0.2);
    points[points.length - 2] = Offset(size.width * 0.82, size.height * 0.35);

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }
    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

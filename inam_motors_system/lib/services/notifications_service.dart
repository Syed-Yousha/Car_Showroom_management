import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils.dart';
import '../models/car.dart';
import '../models/customer.dart';
import 'customer_service.dart';
import 'inventory_service.dart';

enum AlertSeverity { info, warning, critical }

class AppAlert {
  final String id;
  final String title;
  final String body;
  final AlertSeverity severity;
  final IconData icon;
  final DateTime timestamp;

  const AppAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.icon,
    required this.timestamp,
  });
}

/// Derives notifications from the same Firestore data the rest of the app
/// reads (cars + customers via the REST-safe services). Persists read state
/// in shared_preferences so dismissals survive restarts.
///
/// The service exposes a [alerts] ValueNotifier that the header bell + flyout
/// listen to. Call [refresh] after any data mutation that might surface a new
/// alert (or on a periodic timer — currently we just refresh on first build
/// and whenever the bell is opened).
class NotificationsService {
  NotificationsService({
    required this.inventory,
    required this.customers,
    this.lowStockThreshold = 5,
  });

  final InventoryService inventory;
  final CustomerService customers;
  final int lowStockThreshold;

  final ValueNotifier<List<AppAlert>> alerts =
      ValueNotifier<List<AppAlert>>(const []);

  Set<String> _readIds = {};
  bool _readLoaded = false;
  static const _prefsKey = 'notifications_read_ids_v1';

  Future<void> _ensureReadLoaded() async {
    if (_readLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _readIds = (prefs.getStringList(_prefsKey) ?? const []).toSet();
    _readLoaded = true;
  }

  Future<void> _persistRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _readIds.toList());
  }

  /// Returns the count of alerts the user hasn't dismissed yet.
  int get unreadCount =>
      alerts.value.where((a) => !_readIds.contains(a.id)).length;

  bool isRead(String id) => _readIds.contains(id);

  Future<void> markRead(String id) async {
    await _ensureReadLoaded();
    if (_readIds.add(id)) {
      await _persistRead();
      // Touch the notifier so listeners re-evaluate unreadCount.
      alerts.value = List.of(alerts.value);
    }
  }

  Future<void> markAllRead() async {
    await _ensureReadLoaded();
    _readIds = alerts.value.map((a) => a.id).toSet();
    await _persistRead();
    alerts.value = List.of(alerts.value);
  }

  /// Re-derives the alert list from current Firestore data. Safe to call
  /// concurrently — a later call simply replaces the value.
  Future<void> refresh() async {
    await _ensureReadLoaded();
    final results = await Future.wait([
      inventory.fetchCarsSafe(),
      customers.fetchCustomersSafe(),
    ]);
    final cars = results[0] as List<Car>;
    final clients = results[1] as List<Customer>;

    final out = <AppAlert>[];

    // 1. Low car stock — single aggregate alert when available stock drops
    // below the configured threshold.
    final availableCount = cars.where((c) => c.status == 'Available').length;
    if (availableCount < lowStockThreshold) {
      out.add(AppAlert(
        id: 'low_stock',
        title: 'Low Inventory',
        body: availableCount == 0
            ? 'No cars currently available for sale.'
            : 'Only $availableCount ${availableCount == 1 ? 'car' : 'cars'} available — restock soon.',
        severity: availableCount == 0 ? AlertSeverity.critical : AlertSeverity.warning,
        icon: FluentIcons.car,
        timestamp: DateTime.now(),
      ));
    }

    // 2. Payment due — one alert per customer with a positive balance. ID
    // includes the customer id so dismissals are per-customer.
    final owing = clients.where((c) => c.balance > 0).toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
    for (final c in owing.take(20)) {
      out.add(AppAlert(
        id: 'payment_due_${c.id}',
        title: 'Payment Due — ${c.name}',
        body: 'Outstanding balance: ${formatFullPrice(c.balance)}',
        severity: c.balance >= 500000
            ? AlertSeverity.critical
            : AlertSeverity.warning,
        icon: FluentIcons.warning,
        timestamp: DateTime.now(),
      ));
    }

    alerts.value = out;
  }
}

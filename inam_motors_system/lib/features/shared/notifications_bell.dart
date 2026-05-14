import 'package:fluent_ui/fluent_ui.dart';
import '../../core/theme.dart';
import '../../main.dart' show notificationsService;
import '../../services/notifications_service.dart';

/// Header bell. Listens to [notificationsService.alerts] and renders a badge
/// with the live unread count. Click opens a flyout listing the alerts; each
/// row can be dismissed (marks read; persisted via shared_preferences).
class NotificationsBell extends StatefulWidget {
  const NotificationsBell({super.key});

  @override
  State<NotificationsBell> createState() => _NotificationsBellState();
}

class _NotificationsBellState extends State<NotificationsBell> {
  final _controller = FlyoutController();
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      await notificationsService.refresh();
    } catch (_) {
      // Silently swallow — a fetch failure shouldn't break the header.
    }
    _refreshing = false;
  }

  Future<void> _openFlyout() async {
    // Re-derive on every open so the user always sees current alerts.
    await _refresh();
    if (!mounted) return;
    await _controller.showFlyout(
      autoModeConfiguration: FlyoutAutoConfiguration(
        preferredMode: FlyoutPlacementMode.bottomRight,
      ),
      barrierDismissible: true,
      dismissOnPointerMoveAway: false,
      dismissWithEsc: true,
      builder: (ctx) => _NotificationsFlyout(onDismissAll: () async {
        await notificationsService.markAllRead();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: _controller,
      child: ValueListenableBuilder<List<AppAlert>>(
        valueListenable: notificationsService.alerts,
        builder: (_, alerts, _) {
          final unread = notificationsService.unreadCount;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(FluentIcons.ringer,
                    size: 18, color: AppTheme.textSecondary),
                onPressed: _openFlyout,
              ),
              if (unread > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.cardColor, width: 1.5),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationsFlyout extends StatelessWidget {
  final Future<void> Function() onDismissAll;
  const _NotificationsFlyout({required this.onDismissAll});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AppAlert>>(
      valueListenable: notificationsService.alerts,
      builder: (ctx, alerts, _) {
        return FlyoutContent(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                child: Row(children: [
                  Text("Notifications",
                      style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const Spacer(),
                  if (alerts.isNotEmpty)
                    HyperlinkButton(
                      style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all(AppTheme.primary)),
                      onPressed: () async {
                        await onDismissAll();
                      },
                      child: const Text("Mark all read",
                          style: TextStyle(
                              fontFamily: AppTheme.fontFamily, fontSize: 11)),
                    ),
                ]),
              ),
              Container(height: 1, color: AppTheme.divider),
              if (alerts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
                  child: Row(children: [
                    Icon(FluentIcons.check_mark,
                        size: 14, color: AppTheme.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text("No alerts. You're all caught up.",
                          style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ),
                  ]),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: alerts.length,
                    itemBuilder: (_, i) => _AlertRow(alert: alerts[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AlertRow extends StatelessWidget {
  final AppAlert alert;
  const _AlertRow({required this.alert});

  Color _color() {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return AppTheme.error;
      case AlertSeverity.warning:
        return AppTheme.warning;
      case AlertSeverity.info:
        return AppTheme.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final read = notificationsService.isRead(alert.id);
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)),
        ),
        color: read ? null : color.withValues(alpha: 0.03),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6)),
          child: Icon(alert.icon, size: 12, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(alert.title,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(alert.body,
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: AppTheme.textMuted)),
          ]),
        ),
        if (!read)
          IconButton(
            icon: Icon(FluentIcons.clear, size: 10, color: AppTheme.textMuted),
            onPressed: () async {
              await notificationsService.markRead(alert.id);
            },
          ),
      ]),
    );
  }
}

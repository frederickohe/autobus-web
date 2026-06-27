import 'package:autobus/barrel.dart';
import 'models/app_notification.dart';

class NotificationsInboxPage extends StatelessWidget {
  const NotificationsInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: ManageScreenStyle.homeDashboardBodyDecoration,
        child: const SafeArea(
          child: NotificationsInboxPanel(showBackButton: true),
        ),
      ),
    );
  }
}

class NotificationsInboxPanel extends StatefulWidget {
  const NotificationsInboxPanel({
    super.key,
    this.showBackButton = false,
    this.compact = false,
    this.onClose,
  });

  final bool showBackButton;
  final bool compact;
  final VoidCallback? onClose;

  @override
  State<NotificationsInboxPanel> createState() =>
      _NotificationsInboxPanelState();
}

class _NotificationsInboxPanelState extends State<NotificationsInboxPanel> {
  late Future<List<AppNotification>> _future;
  final Set<String> _markingIds = {};

  bool get _light =>
      widget.compact || ManageScreenStyle.useLightTheme;

  @override
  void initState() {
    super.initState();
    _future = _loadUnread();
  }

  Future<List<AppNotification>> _loadUnread() {
    return context.read<ApiService>().getUnreadNotifications();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadUnread();
    });
    await _future;
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (_markingIds.contains(notification.id)) return;
    setState(() => _markingIds.add(notification.id));
    try {
      await context.read<ApiService>().markNotificationAsRead(notification.id);
      if (!mounted) return;
      await _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not mark notification as read',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w300),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _markingIds.remove(notification.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.compact ? 14.0 : 18.0;
    final topPadding = widget.compact ? 12.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          SizedBox(height: topPadding),
          Row(
            children: [
              if (widget.showBackButton)
                const ManageScreenBackButton()
              else
                SizedBox(width: widget.compact ? 0 : 48, height: 48),
              Expanded(
                child: Text(
                  'Notifications',
                  textAlign: widget.compact ? TextAlign.left : TextAlign.center,
                  style: ManageScreenStyle.headerTitleStyle(context).copyWith(
                    fontSize: widget.compact ? 15 : null,
                  ),
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.close,
                    color: _light
                        ? ManageScreenStyle.lightSecondaryText
                        : Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Close',
                )
              else
                SizedBox(width: widget.compact ? 0 : 48, height: 48),
            ],
          ),
          SizedBox(height: widget.compact ? 10 : 18),
          Expanded(
            child: FutureBuilder<List<AppNotification>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: AutobusLoadingIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load notifications',
                      style: GoogleFonts.montserrat(
                        color: _light
                            ? ManageScreenStyle.lightSecondaryText
                            : Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                final items = snap.data ?? const [];
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications yet',
                      style: GoogleFonts.montserrat(
                        color: _light
                            ? ManageScreenStyle.lightSecondaryText
                            : Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: widget.compact ? 8 : 10),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      final created = n.createdAt;
                      final subtitle = [
                        if (created != null)
                          '${created.toLocal()}'.split('.').first,
                      ].join('\n');
                      final marking = _markingIds.contains(n.id);

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.compact ? 12 : 14,
                          vertical: widget.compact ? 10 : 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: _light ? Colors.white : null,
                          border: Border.all(
                            color: _light
                                ? ManageScreenStyle.lightBorder
                                : const Color(0xFF3F1163),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 5),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.displayText.isNotEmpty
                                        ? n.displayText
                                        : n.title,
                                    style: GoogleFonts.montserrat(
                                      color: _light
                                          ? ManageScreenStyle.lightPrimaryText
                                          : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  if (subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      subtitle,
                                      style: GoogleFonts.montserrat(
                                        color: _light
                                            ? ManageScreenStyle
                                                .lightSecondaryText
                                            : Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextButton(
                              onPressed:
                                  marking ? null : () => _markAsRead(n),
                              style: TextButton.styleFrom(
                                foregroundColor: CustColors.mainCol,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: marking
                                  ? const AutobusLoadingIndicator(size: 14)
                                  : Text(
                                      'Mark read',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                            ),
                            Transform.rotate(
                              angle: -0.785398,
                              child: Icon(
                                Icons.arrow_outward,
                                color: _light
                                    ? ManageScreenStyle.lightSecondaryText
                                    : Colors.white54,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (widget.compact) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

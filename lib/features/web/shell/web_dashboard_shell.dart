import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/shell/web_app_controller.dart';
import 'package:autobus/features/web/shell/web_dashboard_nav.dart';
import 'package:autobus/features/web/shell/web_notifications_drawer.dart';

/// Authenticated web chrome: persistent sidebar navigation and full-width content.
class WebDashboardShell extends StatelessWidget {
  const WebDashboardShell({super.key});

  static const double sidebarBreakpoint = 960;
  static const double fullSidebarWidth = 248;
  static const Color shellBackground = Color(0xFF0A0512);
  static const Color contentBackground = Colors.white;
  static const Color topBarBackground = Colors.white;
  static const Color topBarBorder = Color(0xFFE2E8F0);
  static const Color sidebarBackground = Color(0xFF1A0F2E);
  static const Color sidebarBorder = Color(0xFF3F1163);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WebAppController.instance,
      builder: (context, _) {
        final activeNavId = WebAppController.instance.activeNavId;

        return LayoutBuilder(
          builder: (context, constraints) {
            final useDrawer = constraints.maxWidth < sidebarBreakpoint;

            if (useDrawer) {
              return _MobileWebDashboard(activeNavId: activeNavId);
            }

            return ColoredBox(
              color: contentBackground,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: fullSidebarWidth,
                    child: const _WebDashboardSidebar(compact: false),
                  ),
                  Expanded(
                    child: WebDashboardNotificationsOverlay(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _WebDashboardTopBar(),
                          Expanded(
                            child: _WebDashboardContentNavigator(
                              navId: activeNavId,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _WebDashboardContentNavigator extends StatelessWidget {
  const _WebDashboardContentNavigator({required this.navId});

  final String navId;

  static Widget _screenFor(String id) {
    final items = [
      ...webDashboardPrimaryNavItems(),
      webDashboardSettingsNavItem,
    ];
    return items.firstWhere((item) => item.id == id, orElse: () => items.first).screen;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: WebAppController.instance.contentNavigatorKey,
      onGenerateInitialRoutes: (_, __) {
        return [
          MaterialPageRoute<void>(
            builder: (_) => _screenFor(WebAppController.instance.activeNavId),
          ),
        ];
      },
    );
  }
}

class _MobileWebDashboard extends StatefulWidget {
  const _MobileWebDashboard({required this.activeNavId});

  final String activeNavId;

  @override
  State<_MobileWebDashboard> createState() => _MobileWebDashboardState();
}

class _MobileWebDashboardState extends State<_MobileWebDashboard> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: WebDashboardShell.contentBackground,
      drawer: Drawer(
        width: WebDashboardShell.fullSidebarWidth,
        backgroundColor: WebDashboardShell.sidebarBackground,
        child: const SafeArea(child: _WebDashboardSidebar(compact: false)),
      ),
      body: WebDashboardNotificationsOverlay(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WebDashboardTopBar(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: _WebDashboardContentNavigator(navId: widget.activeNavId),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebDashboardTopBar extends StatelessWidget {
  const _WebDashboardTopBar({this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: WebDashboardShell.topBarBackground,
      ),
      child: Row(
        children: [
          if (onMenuPressed != null)
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu, color: WebDashboardShell.sidebarBackground),
            ),
          const Spacer(),
          const _WebDashboardNotificationButton(),
          const SizedBox(width: 4),
          UserAvatar(
            size: 40,
            onLightBackground: true,
            onTap: () {
              WebAppController.instance.pushContent(const Profile());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _WebDashboardSidebar extends StatelessWidget {
  const _WebDashboardSidebar({required this.compact});

  final bool compact;

  void _navigate(WebDashboardNavItem item) {
    if (WebAppController.instance.activeNavId == item.id) return;
    WebAppController.instance.setActiveNav(item.id, screen: item.screen);
  }

  @override
  Widget build(BuildContext context) {
    final activeId = WebAppController.instance.activeNavId;
    final primaryItems = webDashboardPrimaryNavItems();

    return ColoredBox(
      color: WebDashboardShell.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              children: [
                for (final item in primaryItems)
                  _SidebarNavTile(
                    item: item,
                    compact: compact,
                    selected: activeId == item.id,
                    onTap: () => _navigate(item),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: WebDashboardShell.sidebarBorder),
          _SidebarNavTile(
            item: webDashboardSettingsNavItem,
            compact: compact,
            selected: activeId == webDashboardSettingsNavItem.id,
            onTap: () => _navigate(webDashboardSettingsNavItem),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.fromLTRB(compact ? 12 : 16, 0, compact ? 12 : 16, 20),
            child: compact
                ? const Center(child: AutobusMark(circleSize: 14))
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutobusMark(circleSize: 14),
                      SizedBox(width: 5),
                      Expanded(
                        child: AutobusWordmark(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          baseColor: Colors.white70,
                          accentColor: CustColors.logolight,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavTile extends StatelessWidget {
  const _SidebarNavTile({
    required this.item,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  final WebDashboardNavItem item;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.montserrat(
      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.72),
      fontSize: 12,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: selected
                  ? CustColors.mainCol.withValues(alpha: 0.18)
                  : Colors.transparent,
              border: selected
                  ? Border.all(color: CustColors.mainCol.withValues(alpha: 0.45))
                  : null,
            ),
            child: compact
                ? Center(child: _NavIcon(icon: item.icon, selected: selected))
                : Row(
                    children: [
                      _NavIcon(icon: item.icon, selected: selected),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item.label, style: labelStyle)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.selected});

  final dynamic icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white.withValues(alpha: 0.7);
    if (icon is IconData) {
      return Icon(icon as IconData, color: color, size: 20);
    }
    return Iconify(icon, color: color, size: 20);
  }
}

class _WebDashboardNotificationButton extends StatefulWidget {
  const _WebDashboardNotificationButton();

  @override
  State<_WebDashboardNotificationButton> createState() =>
      _WebDashboardNotificationButtonState();
}

class _WebDashboardNotificationButtonState
    extends State<_WebDashboardNotificationButton> {
  Future<int>? _unreadCountFuture;

  @override
  void initState() {
    super.initState();
    WebAppController.instance.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    WebAppController.instance.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!WebAppController.instance.notificationsDrawerOpen && mounted) {
      setState(() {
        _unreadCountFuture =
            context.read<ApiService>().getUnreadNotificationCount();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unreadCountFuture ??=
        context.read<ApiService>().getUnreadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _unreadCountFuture,
      builder: (context, snap) {
        final unread = snap.data ?? 0;
        return IconButton(
          onPressed: WebAppController.instance.toggleNotificationsDrawer,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none,
                color: WebDashboardShell.sidebarBackground,
              ),
              if (unread > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

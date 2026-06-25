import 'package:autobus/barrel.dart';
import 'package:autobus/features/reports/reports_overview.dart';
import 'package:autobus/features/web/shell/web_app_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Home extends StatefulWidget {
  const Home({super.key});

  /// Full-screen entrance when leaving the welcome screen (fade, lift, scale with ease-out back).
  static Route<void> routeFromWelcome() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: 'Home'),
      pageBuilder: (context, animation, secondaryAnimation) => const Home(),
      transitionDuration: const Duration(milliseconds: 1600),
      reverseTransitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final scaleCurved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInBack,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.78, end: 1).animate(scaleCurved),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<int>? _unreadCountFuture;
  Future<List<AppNotification>>? _alertsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final api = context.read<ApiService>();
    _unreadCountFuture ??= api.getUnreadNotificationCount();
    _alertsFuture ??= api.getUnreadNotifications();
  }

  Future<void> _refreshNotifications() async {
    final api = context.read<ApiService>();
    setState(() {
      _unreadCountFuture = api.getUnreadNotificationCount();
      _alertsFuture = api.getUnreadNotifications();
    });
  }

  void _openNotificationTarget(AppNotification notification) {
    switch (notification.flutterPage?.toLowerCase()) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Profile()),
        );
        break;
      case 'subscription':
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: kManageSubscriptionRouteName),
            builder: (_) => const ManageSubscriptionPage(),
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<HomeMenuItem> menuItems = [
      HomeMenuItem("Intelligence", Fluent.brain_circuit_20_regular, () {
        _openHub(context, navId: 'intelligence', screen: const ManageIntelligence());
      }),
      HomeMenuItem("Inbox", MaterialSymbols.phone_callback_outline_sharp, () {
        _openHub(context, navId: 'inbox', screen: const ManageChats());
      }),
      HomeMenuItem("Messaging", Ph.chats_circle, () {
        _openHub(context, navId: 'messaging', screen: const ManageEmails());
      }),
      HomeMenuItem("Customers", Fluent.people_call_16_regular, () {
        _openHub(context, navId: 'customers', screen: const ManageCustomers());
      }),
      HomeMenuItem("Marketing", Fluent.people_community_add_20_regular, () {
        _openHub(context, navId: 'marketing', screen: const ManageMarketing());
      }),
      HomeMenuItem("Orders", Carbon.ibm_watson_orders, () {
        _openHub(context, navId: 'orders', screen: const ManageOrders());
      }),
      HomeMenuItem("Products", Ep.sell, () {
        _openHub(context, navId: 'products', screen: const ManageProducts());
      }),
      HomeMenuItem("Analytics", Uim.analytics, () {
        _openHub(context, navId: 'analytics', screen: const ManageReports());
      }),
    ];

    final inWebShell = kIsWeb && WebAppController.instance.useDashboardShell;

    return Scaffold(
      backgroundColor: inWebShell ? Colors.white : Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: inWebShell
                ? ManageScreenStyle.webDashboardBodyDecoration
                : const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF130522), Color(0xFF000000)],
                    ),
                  ),
          ),
          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1100
                    ? 4
                    : constraints.maxWidth >= 760
                        ? 3
                        : 2;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    32 + MediaQuery.viewPaddingOf(context).bottom + 56,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                  if (!(kIsWeb && WebAppController.instance.useDashboardShell)) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<int>(
                          future: _unreadCountFuture,
                          builder: (context, snap) {
                            final unread = snap.data ?? 0;
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationsInboxPage(),
                                  ),
                                );
                                await _refreshNotifications();
                              },
                              child: _notificationBell(unreadCount: unread),
                            );
                          },
                        ),
                        const UserAvatar(),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String displayName = 'Guest';
                      if (state is Authenticated) {
                        displayName =
                            (state.user['fullname'] ??
                                    state.user['email'] ??
                                    'User')
                                .toString();
                      }

                      final firstName = displayName.trim().split(' ').first;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Hello $firstName',
                            style: GoogleFonts.montserrat(
                              color: inWebShell
                                  ? ManageScreenStyle.lightSecondaryText
                                  : Colors.white.withValues(alpha: 0.8),
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Iconify(
                              Ion.sparkles_sharp,
                              color: const Color(0xFFA855F7),
                              size: 20,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  FutureBuilder<List<AppNotification>>(
                    future: _alertsFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const SizedBox(height: 36);
                      }
                      final alerts = snap.data ?? const [];
                      if (alerts.isEmpty) {
                        return const SizedBox(height: 36);
                      }
                      return Column(
                        children: [
                          for (var i = 0; i < alerts.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _AlertBox(
                              text: alerts[i].displayText.isNotEmpty
                                  ? alerts[i].displayText
                                  : alerts[i].title,
                              onTap: () => _openNotificationTarget(alerts[i]),
                            ),
                          ],
                          const SizedBox(height: 36),
                        ],
                      );
                    },
                  ),
                  if (inWebShell) ...[
                    ReportsOverviewPanel(
                      horizontalPadding: 0,
                      showViewDetailedReportsLink: true,
                      onViewDetailedReports: () => _openHub(
                        context,
                        navId: 'analytics',
                        screen: const ManageReports(),
                      ),
                    ),
                  ],
                          if (!(kIsWeb &&
                              WebAppController.instance.useDashboardShell))
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: menuItems.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 149 / 115,
                              ),
                              itemBuilder: (context, index) {
                                return _DashboardCard(item: menuItems[index]);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarCircle() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? avatarUrl;
        String initials = 'U';

        if (state is Authenticated) {
          final u = state.user;
          final name = (u['fullname'] ?? u['email'] ?? 'User').toString();
          initials = name.trim().isNotEmpty
              ? name.trim()[0].toUpperCase()
              : 'U';

          avatarUrl =
              (u['avatar'] ?? u['avatar_url'] ?? u['photo'] ?? u['photo_url'])
                  ?.toString();
          if (avatarUrl != null && avatarUrl.trim().isEmpty) avatarUrl = null;
        }

        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFFF43F5E)],
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A051D),
              border: Border.all(color: const Color(0xFF0A051D), width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF0A051D),
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      initials,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  void _openHub(
    BuildContext context, {
    required String navId,
    required Widget screen,
  }) {
    if (kIsWeb && WebAppController.instance.useDashboardShell) {
      WebAppController.instance.setActiveNav(navId, screen: screen);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _notificationBell({required int unreadCount}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: CustColors.mainCol, width: 1),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 12,
              top: 12,
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
  }
}

class _DashboardCard extends StatelessWidget {
  final HomeMenuItem item;

  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final light = kIsWeb && WebAppController.instance.useDashboardShell;

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: light ? ManageScreenStyle.lightBorder : const Color(0xFF3F1163),
          ),
          color: light ? Colors.white : null,
          boxShadow: light
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(item.icon, light: light),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: GoogleFonts.montserrat(
                color: light ? ManageScreenStyle.lightPrimaryText : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(dynamic icon, {required bool light}) {
    final color = light ? CustColors.mainCol : Colors.white70;
    if (icon is IconData) {
      return Icon(icon, color: color, size: 30);
    } else {
      return Iconify(icon, color: color, size: 30);
    }
  }
}

class HomeMenuItem {
  final String title;
  final dynamic icon; // Changed from IconData to dynamic for Iconify icons
  final VoidCallback onTap;

  HomeMenuItem(this.title, this.icon, this.onTap);
}

class _AlertBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _AlertBox({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final light = kIsWeb && WebAppController.instance.useDashboardShell;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: light ? ManageScreenStyle.lightBorder : const Color(0xFF3F1163),
            width: light ? 1 : 1.5,
          ),
          color: light ? const Color(0xFFFEF2F2) : null,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_outlined,
              color: Color(0xFFEF4444),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: light
                      ? ManageScreenStyle.lightPrimaryText
                      : Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Transform.rotate(
              angle: -0.785,
              child: const Icon(
                Icons.arrow_outward,
                color: Color(0xFFEF4444),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

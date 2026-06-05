import 'package:autobus/barrel.dart';

class WebDashboardNavItem {
  const WebDashboardNavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.screen,
    this.routeName,
  });

  final String id;
  final String label;
  final dynamic icon;
  final Widget screen;
  final String? routeName;
}

List<WebDashboardNavItem> webDashboardPrimaryNavItems() {
  return [
    WebDashboardNavItem(
      id: 'home',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      routeName: 'Home',
      screen: const Home(),
    ),
    WebDashboardNavItem(
      id: 'intelligence',
      label: 'Intelligence',
      icon: Fluent.brain_circuit_20_regular,
      screen: const ManageIntelligence(),
    ),
    WebDashboardNavItem(
      id: 'inbox',
      label: 'Inbox',
      icon: MaterialSymbols.phone_callback_outline_sharp,
      screen: const ManageChats(),
    ),
    WebDashboardNavItem(
      id: 'messaging',
      label: 'Messaging',
      icon: Ph.chats_circle,
      screen: const ManageEmails(),
    ),
    WebDashboardNavItem(
      id: 'customers',
      label: 'Customers',
      icon: Fluent.people_call_16_regular,
      screen: const ManageCustomers(),
    ),
    WebDashboardNavItem(
      id: 'marketing',
      label: 'Marketing',
      icon: Fluent.people_community_add_20_regular,
      screen: const ManageMarketing(),
    ),
    WebDashboardNavItem(
      id: 'orders',
      label: 'Orders',
      icon: Carbon.ibm_watson_orders,
      screen: const ManageOrders(),
    ),
    WebDashboardNavItem(
      id: 'products',
      label: 'Products',
      icon: Ep.sell,
      screen: const ManageProducts(),
    ),
    WebDashboardNavItem(
      id: 'analytics',
      label: 'Analytics',
      icon: Uim.analytics,
      screen: const ManageReports(),
    ),
  ];
}

const WebDashboardNavItem webDashboardSettingsNavItem = WebDashboardNavItem(
  id: 'settings',
  label: 'Settings',
  icon: Icons.settings_outlined,
  screen: SettingsPage(),
);

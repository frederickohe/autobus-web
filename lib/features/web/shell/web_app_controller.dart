import 'package:flutter/foundation.dart' show kIsWeb, ChangeNotifier;
import 'package:flutter/material.dart';

/// Toggles the authenticated web dashboard shell (sidebar + full-width content).
class WebAppController extends ChangeNotifier {
  WebAppController._();

  static final WebAppController instance = WebAppController._();

  final GlobalKey<NavigatorState> contentNavigatorKey =
      GlobalKey<NavigatorState>();

  bool _useDashboardShell = false;
  String _activeNavId = 'home';
  bool _notificationsDrawerOpen = false;

  bool get useDashboardShell => _useDashboardShell;
  String get activeNavId => _activeNavId;
  bool get notificationsDrawerOpen => _notificationsDrawerOpen;

  void enterDashboardShell({String navId = 'home'}) {
    if (!kIsWeb) return;
    _activeNavId = navId;
    if (_useDashboardShell) {
      notifyListeners();
      return;
    }
    _useDashboardShell = true;
    notifyListeners();
  }

  void exitDashboardShell() {
    if (!_useDashboardShell) return;
    _useDashboardShell = false;
    _activeNavId = 'home';
    _notificationsDrawerOpen = false;
    notifyListeners();
  }

  void setActiveNav(String id, {Widget? screen}) {
    final changed = _activeNavId != id;
    _activeNavId = id;

    if (screen != null && _useDashboardShell) {
      contentNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => screen),
        (_) => false,
      );
    }

    if (changed || screen != null) {
      notifyListeners();
    }
  }

  Future<T?> pushContent<T>(Widget page) {
    return contentNavigatorKey.currentState?.push<T>(
          MaterialPageRoute(builder: (_) => page),
        ) ??
        Future.value(null);
  }

  void openNotificationsDrawer() {
    if (_notificationsDrawerOpen) return;
    _notificationsDrawerOpen = true;
    notifyListeners();
  }

  void closeNotificationsDrawer() {
    if (!_notificationsDrawerOpen) return;
    _notificationsDrawerOpen = false;
    notifyListeners();
  }

  void toggleNotificationsDrawer() {
    _notificationsDrawerOpen = !_notificationsDrawerOpen;
    notifyListeners();
  }
}

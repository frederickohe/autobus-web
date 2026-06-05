import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/shell/web_app_controller.dart';

/// Right-side notifications drawer overlay for the authenticated web dashboard.
class WebDashboardNotificationsOverlay extends StatelessWidget {
  const WebDashboardNotificationsOverlay({super.key, required this.child});

  final Widget child;

  static const double drawerWidth = 380;
  static const Color _drawerBackground = Color(0xFF1A0F2E);
  static const Color _drawerBorder = Color(0xFF3F1163);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WebAppController.instance,
      builder: (context, _) {
        final open = WebAppController.instance.notificationsDrawerOpen;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !open,
                child: AnimatedOpacity(
                  opacity: open ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: WebAppController.instance.closeNotificationsDrawer,
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              top: 0,
              bottom: 0,
              right: open ? 0 : -drawerWidth,
              width: drawerWidth,
              child: Material(
                color: _drawerBackground,
                elevation: 12,
                shadowColor: Colors.black.withValues(alpha: 0.5),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _drawerBorder),
                    ),
                  ),
                  child: SafeArea(
                    left: false,
                    child: NotificationsInboxPanel(
                      onClose:
                          WebAppController.instance.closeNotificationsDrawer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

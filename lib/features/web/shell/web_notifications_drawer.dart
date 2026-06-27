import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/shell/web_app_controller.dart';

/// Notifications dropdown anchored below the top-bar bell on the web dashboard.
class WebDashboardNotificationsOverlay extends StatelessWidget {
  const WebDashboardNotificationsOverlay({super.key, required this.child});

  final Widget child;

  static const double panelWidth = 360;
  static const double panelMaxHeight = 480;
  static const double topBarHeight = 64;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WebAppController.instance,
      builder: (context, _) {
        final open = WebAppController.instance.notificationsDrawerOpen;

        return Stack(
          clipBehavior: Clip.none,
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
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: open ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !open,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: topBarHeight - 6,
                      right: 68,
                      child: Transform.rotate(
                        angle: 0.785398,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: ManageScreenStyle.lightBorder,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: topBarHeight + 4,
                      right: 16,
                      child: Material(
                        color: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: panelWidth,
                          height: panelMaxHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ManageScreenStyle.lightBorder,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: NotificationsInboxPanel(
                              compact: true,
                              onClose:
                                  WebAppController.instance
                                      .closeNotificationsDrawer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

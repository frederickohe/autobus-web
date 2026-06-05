import 'package:autobus/features/web/shell/web_app_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header chrome rules for hub screens inside the authenticated web dashboard shell.
class ManageScreenChrome {
  ManageScreenChrome._();

  static bool get inWebDashboard =>
      kIsWeb && WebAppController.instance.useDashboardShell;

  static bool hideHeaderBack(BuildContext context) {
    if (!inWebDashboard) return false;
    return !Navigator.of(context).canPop();
  }
}

/// Visual baseline for hub screens opened from Home (matches inbox / messaging hubs).
class ManageScreenStyle {
  ManageScreenStyle._();

  static const Color backgroundStart = Color(0xFF160A2C);
  static const Color backgroundEnd = Color(0xFF0C0418);
  static const Color headerRingBorder = Color.fromRGBO(255, 255, 255, 0.15);

  /// Same vertical gradient as the [Home] dashboard background.
  static const BoxDecoration homeDashboardBodyDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF130522), Color(0xFF000000)],
    ),
  );

  static BoxDecoration bodyGradientDecoration() => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [backgroundStart, backgroundEnd],
    ),
  );

  static TextStyle headerTitleStyle() => GoogleFonts.inter(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.2,
  );
}

class ManageScreenHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry padding;

  const ManageScreenHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBackPressed,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 0),
  });

  @override
  Widget build(BuildContext context) {
    final hideBack = ManageScreenChrome.hideHeaderBack(context);

    return Padding(
      padding: padding,
      child: SizedBox(
        height: 54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!hideBack)
              Align(
                alignment: Alignment.centerLeft,
                child: ManageScreenBackButton(onPressed: onBackPressed),
              ),
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hideBack ? 0 : 72),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: ManageScreenStyle.headerTitleStyle(),
                  ),
                ),
              ),
            ),
            if (trailing != null)
              Align(
                alignment: Alignment.centerRight,
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}

class ManageScreenBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ManageScreenBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (ManageScreenChrome.hideHeaderBack(context)) {
      return const SizedBox(width: 48, height: 48);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ManageScreenStyle.headerRingBorder),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

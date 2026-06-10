import 'package:autobus/common_design/colors.dart';
import 'package:autobus/common_design/widgets/credit_avatar.dart';
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
  static const Color headerRingBorderDark = Color.fromRGBO(255, 255, 255, 0.15);
  static const Color headerRingBorderLight = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightPrimaryText = Color(0xFF1A0F2E);
  static const Color lightSecondaryText = Color(0xFF64748B);

  static bool get useLightTheme => ManageScreenChrome.inWebDashboard;

  static Color get scaffoldBackgroundColor =>
      useLightTheme ? Colors.white : Colors.black;

  static Color get headerRingBorder =>
      useLightTheme ? headerRingBorderLight : headerRingBorderDark;

  /// Same vertical gradient as the [Home] dashboard background (mobile / non-shell).
  static const BoxDecoration homeDashboardBodyDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF130522), Color(0xFF000000)],
    ),
  );

  static const BoxDecoration webDashboardBodyDecoration = BoxDecoration(
    color: Colors.white,
  );

  static BoxDecoration bodyDecoration() =>
      useLightTheme ? webDashboardBodyDecoration : homeDashboardBodyDecoration;

  static BoxDecoration bodyGradientDecoration() => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [backgroundStart, backgroundEnd],
    ),
  );

  static TextStyle headerTitleStyle() => GoogleFonts.inter(
    color: useLightTheme ? lightPrimaryText : Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.2,
  );

  static TextStyle hubWelcomeTitleStyle() => GoogleFonts.montserrat(
    color: useLightTheme ? lightPrimaryText : Colors.white,
    fontSize: 19,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
  );

  static TextStyle hubWelcomeSubtitleStyle() => GoogleFonts.montserrat(
    color: useLightTheme
        ? lightSecondaryText
        : Colors.white.withValues(alpha: 0.9),
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.6,
  );

  static TextStyle hubSectionTitleStyle() => GoogleFonts.montserrat(
    color: useLightTheme ? lightPrimaryText : Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static int hubCrossAxisCount(double maxWidth) {
    if (!useLightTheme) return 2;
    if (maxWidth >= 960) return 4;
    if (maxWidth >= 640) return 3;
    return 2;
  }

  static double hubChildAspectRatio(double maxWidth) {
    if (!useLightTheme) return 1.0;
    if (maxWidth >= 960) return 2.6;
    if (maxWidth >= 640) return 2.3;
    return 2.0;
  }
}

class ManageScreenHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  /// When set (and [trailing] is null), shows a credit chip for this category.
  final String? creditCategory;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry padding;

  const ManageScreenHeader({
    super.key,
    required this.title,
    this.trailing,
    this.creditCategory,
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
            Align(
              alignment: Alignment.centerRight,
              child:
                  trailing ??
                  (creditCategory != null
                      ? CreditAvatar(creditCategory: creditCategory!)
                      : const SizedBox(width: 48, height: 48)),
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

    final light = ManageScreenStyle.useLightTheme;

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
          child: Icon(
            Icons.arrow_back_ios_new,
            color: light ? ManageScreenStyle.lightPrimaryText : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Compact action tiles for hub sub-dashboards (Link Channel, Live Chats, etc.).
class ManageHubActionCard extends StatelessWidget {
  const ManageHubActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final light = ManageScreenStyle.useLightTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(light ? 16 : 32),
        child: Ink(
          decoration: BoxDecoration(
            color: light ? Colors.white : null,
            border: Border.all(
              color: light ? ManageScreenStyle.lightBorder : const Color(0xFF3F1163),
            ),
            borderRadius: BorderRadius.circular(light ? 16 : 32),
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
              Icon(
                icon,
                color: light ? CustColors.mainCol : Colors.white,
                size: light ? 22 : 28,
              ),
              SizedBox(height: light ? 8 : 14),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: light
                      ? ManageScreenStyle.lightPrimaryText
                      : Colors.white.withValues(alpha: 0.9),
                  fontSize: light ? 12 : 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: light
                        ? ManageScreenStyle.lightSecondaryText
                        : Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive grid for hub action cards — denser layout on the web dashboard.
class ManageHubGrid extends StatelessWidget {
  const ManageHubGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            ManageScreenStyle.hubCrossAxisCount(constraints.maxWidth);
        final aspectRatio =
            ManageScreenStyle.hubChildAspectRatio(constraints.maxWidth);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: ManageScreenStyle.useLightTheme ? 12 : 16,
          crossAxisSpacing: ManageScreenStyle.useLightTheme ? 12 : 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspectRatio,
          children: children,
        );
      },
    );
  }
}

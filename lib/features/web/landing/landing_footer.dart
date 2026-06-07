import 'package:autobus/barrel.dart';
import 'package:autobus/features/legal/account_deletion_page.dart';
import 'package:autobus/features/legal/privacy_policy_page.dart';
import 'package:autobus/features/web/legal_web_paths.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key, required this.isNarrow});

  final bool isNarrow;

  static const _bg = Color(0xFF2A1447);
  static const _muted = Color(0xFFC4B8D6);
  static const _divider = Color(0xFF3D2A5C);

  void _openPrivacyPolicy(BuildContext context) {
    if (kIsWeb) {
      openLegalWebPath('/privacy');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
    );
  }

  void _openAccountDeletion(BuildContext context) {
    if (kIsWeb) {
      openLegalWebPath('/delete-account');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountDeletionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    return Container(
      width: double.infinity,
      color: _bg,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 24 : 80,
        vertical: isNarrow ? 40 : 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isNarrow ? _NarrowContent(
            year: year,
            onPrivacyTap: () => _openPrivacyPolicy(context),
            onAccountDeletionTap: () => _openAccountDeletion(context),
          ) : _WideContent(
            year: year,
            onPrivacyTap: () => _openPrivacyPolicy(context),
            onAccountDeletionTap: () => _openAccountDeletion(context),
          ),
        ),
      ),
    );
  }
}

class _WideContent extends StatelessWidget {
  const _WideContent({
    required this.year,
    required this.onPrivacyTap,
    required this.onAccountDeletionTap,
  });

  final int year;
  final VoidCallback onPrivacyTap;
  final VoidCallback onAccountDeletionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      AutobusMark(circleSize: 32),
                      SizedBox(width: 9),
                      AutobusWordmark(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        baseColor: Colors.white,
                        accentColor: CustColors.logolight,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI-powered business management for teams of every size.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                      color: LandingFooter._muted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _FooterLinkGroup(
                title: 'Product',
                links: const [
                  _FooterLink(label: 'Features'),
                  _FooterLink(label: 'Get Started'),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _FooterLinkGroup(
                title: 'Legal',
                links: [
                  _FooterLink(
                    label: 'Privacy Policy',
                    onTap: onPrivacyTap,
                  ),
                  _FooterLink(
                    label: 'Account Deletion',
                    onTap: onAccountDeletionTap,
                  ),
                  const _FooterLink(label: 'Terms & Conditions'),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _FooterLinkGroup(
                title: 'Contact',
                links: const [
                  _FooterLink(
                    label: 'privacy@autobus.app',
                    isEmail: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Divider(color: LandingFooter._divider, height: 1),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                '© $year Autobus. All rights reserved.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: LandingFooter._muted,
                ),
              ),
            ),
            Text(
              'Built for modern businesses.',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: LandingFooter._muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NarrowContent extends StatelessWidget {
  const _NarrowContent({
    required this.year,
    required this.onPrivacyTap,
    required this.onAccountDeletionTap,
  });

  final int year;
  final VoidCallback onPrivacyTap;
  final VoidCallback onAccountDeletionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AutobusMark(circleSize: 32),
            SizedBox(width: 9),
            AutobusWordmark(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              baseColor: Colors.white,
              accentColor: CustColors.logolight,
              textAlign: TextAlign.left,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'AI-powered business management for teams of every size.',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: LandingFooter._muted,
          ),
        ),
        const SizedBox(height: 32),
        _FooterLinkGroup(
          title: 'Legal',
          links: [
            _FooterLink(label: 'Privacy Policy', onTap: onPrivacyTap),
            _FooterLink(
              label: 'Account Deletion',
              onTap: onAccountDeletionTap,
            ),
            const _FooterLink(label: 'Terms & Conditions'),
          ],
        ),
        const SizedBox(height: 24),
        _FooterLinkGroup(
          title: 'Contact',
          links: const [
            _FooterLink(label: 'privacy@autobus.app', isEmail: true),
          ],
        ),
        const SizedBox(height: 32),
        const Divider(color: LandingFooter._divider, height: 1),
        const SizedBox(height: 20),
        Text(
          '© $year Autobus. All rights reserved.',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: LandingFooter._muted,
          ),
        ),
      ],
    );
  }
}

class _FooterLinkGroup extends StatelessWidget {
  const _FooterLinkGroup({
    required this.title,
    required this.links,
  });

  final String title;
  final List<_FooterLink> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: link,
        )),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    this.onTap,
    this.isEmail = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: LandingFooter._muted,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: Text(label, style: style.copyWith(decoration: TextDecoration.underline)),
      );
    }

    return Text(label, style: style);
  }
}

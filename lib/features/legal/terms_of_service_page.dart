import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/landing/landing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static const _bg = Color(0xFFF6F8FF);
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _brand = Color(0xFF2A1447);

  static const _lastUpdated = 'August 9, 2026';
  static const _contactEmail = 'privacy@autobus.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  return;
                }
                if (kIsWeb) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LandingPage()),
                  );
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms of Service',
                          style: GoogleFonts.montserrat(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: $_lastUpdated',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const _PolicySection(
                          title: '1. Agreement to These Terms',
                          body:
                              'These Terms of Service ("Terms") govern your access to and use of '
                              'the Autobus mobile application, website, and related services '
                              '(collectively, the "Service") operated by Autobus ("we", "our", or "us").\n\n'
                              'By creating an account, accessing, or using the Service, you agree to be '
                              'bound by these Terms and our Privacy Policy. If you do not agree, do not '
                              'use the Service.',
                        ),
                        const _PolicySection(
                          title: '2. Eligibility',
                          body:
                              'You must be at least 18 years old (or the age of majority in your '
                              'jurisdiction) and able to form a binding contract to use Autobus. '
                              'The Service is intended for business and professional use. By using '
                              'Autobus, you represent that the information you provide is accurate '
                              'and that you have authority to bind the business or organization you '
                              'represent, if any.',
                        ),
                        const _PolicySection(
                          title: '3. Accounts and Security',
                          body: 'To use most features, you must create an account. You agree to:',
                          bullets: [
                            'Provide accurate registration information and keep it up to date.',
                            'Keep your login credentials, PIN, and verification codes confidential.',
                            'Notify us promptly of any unauthorized access to your account.',
                            'Accept responsibility for activity that occurs under your account.',
                          ],
                          footer:
                              'We may suspend or terminate accounts that appear compromised, abusive, '
                              'or in violation of these Terms.',
                        ),
                        const _PolicySection(
                          title: '4. The Service',
                          body:
                              'Autobus is an AI-powered business management platform that may include '
                              'customer management, orders, products, marketing, messaging, analytics, '
                              'and related operational tools. Features available to you depend on your '
                              'subscription plan and configuration.\n\n'
                              'We may modify, add, or remove features from time to time. We do not '
                              'guarantee that any particular feature will remain available indefinitely.',
                        ),
                        const _PolicySection(
                          title: '5. Subscriptions and Payments',
                          body:
                              'Paid plans are billed through our payment partner (currently Paystack) '
                              'or other processors we designate. By subscribing, you authorize recurring '
                              'charges according to your selected plan until you cancel.\n\n'
                              'Fees are generally non-refundable except where required by law or expressly '
                              'stated otherwise. Taxes may apply. Failure to pay may result in suspension '
                              'or loss of access to paid features.',
                        ),
                        const _PolicySection(
                          title: '6. Acceptable Use',
                          body: 'You agree not to misuse the Service. Prohibited conduct includes:',
                          bullets: [
                            'Violating applicable laws, regulations, or third-party rights.',
                            'Uploading unlawful, harmful, deceptive, or infringing content.',
                            'Attempting to gain unauthorized access to systems, accounts, or data.',
                            'Interfering with or disrupting the Service, including through malware or abuse of APIs.',
                            'Using Autobus to send spam or unsolicited communications in violation of law.',
                            'Reselling, scraping, or reverse engineering the Service except as permitted by law.',
                            'Misrepresenting your identity or affiliation when using the Service.',
                          ],
                        ),
                        const _PolicySection(
                          title: '7. Your Content and Business Data',
                          body:
                              'You retain ownership of the business data, media, messages, and other '
                              'content you submit to Autobus ("Customer Content"). You grant us a limited '
                              'license to host, process, transmit, and display Customer Content solely as '
                              'needed to operate and improve the Service for you.\n\n'
                              'You are responsible for Customer Content, including ensuring you have the '
                              'rights and consents needed to use it with Autobus and with any third-party '
                              'integrations you connect.',
                        ),
                        const _PolicySection(
                          title: '8. AI Features',
                          body:
                              'Autobus may use artificial intelligence to generate suggestions, drafts, '
                              'insights, or automated responses. AI outputs can be inaccurate or incomplete. '
                              'You are responsible for reviewing AI outputs before relying on them for '
                              'business, legal, financial, or operational decisions.\n\n'
                              'We do not use your private business data to train public AI models without '
                              'your consent.',
                        ),
                        const _PolicySection(
                          title: '9. Third-Party Services and Integrations',
                          body:
                              'The Service may integrate with third-party platforms (for example payment, '
                              'messaging, email, social media, or hosting providers). Your use of those '
                              'services is subject to their terms and privacy policies. Autobus is not '
                              'responsible for third-party services, outages, or changes to their APIs or policies.',
                        ),
                        const _PolicySection(
                          title: '10. Intellectual Property',
                          body:
                              'Autobus, including its software, branding, design, and documentation, is '
                              'owned by us or our licensors and is protected by intellectual property laws. '
                              'Except for the limited rights granted to use the Service under these Terms, '
                              'no rights are transferred to you.',
                        ),
                        const _PolicySection(
                          title: '11. Disclaimers',
                          body:
                              'THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE." TO THE MAXIMUM EXTENT '
                              'PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING '
                              'MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.\n\n'
                              'We do not warrant that the Service will be uninterrupted, error-free, or '
                              'completely secure, or that AI-generated content will meet your requirements.',
                        ),
                        const _PolicySection(
                          title: '12. Limitation of Liability',
                          body:
                              'TO THE MAXIMUM EXTENT PERMITTED BY LAW, AUTOBUS AND ITS AFFILIATES, '
                              'OFFICERS, EMPLOYEES, AND AGENTS WILL NOT BE LIABLE FOR INDIRECT, INCIDENTAL, '
                              'SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR FOR LOST PROFITS, REVENUE, '
                              'DATA, OR BUSINESS OPPORTUNITIES, ARISING FROM YOUR USE OF THE SERVICE.\n\n'
                              'OUR TOTAL LIABILITY FOR ANY CLAIM ARISING OUT OF THESE TERMS OR THE SERVICE '
                              'WILL NOT EXCEED THE AMOUNTS YOU PAID TO AUTOBUS FOR THE SERVICE IN THE '
                              'TWELVE (12) MONTHS BEFORE THE CLAIM AROSE.',
                        ),
                        const _PolicySection(
                          title: '13. Termination',
                          body:
                              'You may stop using Autobus at any time and may request account deletion '
                              'subject to our Privacy Policy and applicable law. We may suspend or terminate '
                              'access if you violate these Terms, fail to pay fees, or if we discontinue the '
                              'Service.\n\n'
                              'Sections that by their nature should survive (including intellectual property, '
                              'disclaimers, limitation of liability, and governing law) will survive termination.',
                        ),
                        const _PolicySection(
                          title: '14. Governing Law',
                          body:
                              'These Terms are governed by the laws of Ghana, without regard to conflict '
                              'of law principles. Courts located in Ghana will have exclusive jurisdiction '
                              'over disputes arising from these Terms or the Service, except where '
                              'mandatory consumer protections require otherwise.',
                        ),
                        const _PolicySection(
                          title: '15. Changes to These Terms',
                          body:
                              'We may update these Terms from time to time. When we do, we will revise '
                              'the "Last updated" date on this page. Material changes may also be communicated '
                              'through the app or by email. Continued use of Autobus after changes become '
                              'effective constitutes acceptance of the updated Terms.',
                        ),
                        const _PolicySection(
                          title: '16. Contact Us',
                          body:
                              'If you have questions about these Terms of Service, contact us at:\n\n'
                              'Autobus\n'
                              'Email: $_contactEmail\n'
                              'Website: https://useautobus.com\n\n'
                              'These Terms apply to the Autobus web platform and mobile applications, '
                              'including distribution via Google Play and other platforms.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 24, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: TermsOfServicePage._brand,
          ),
          const SizedBox(width: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AutobusMark(circleSize: 28),
              SizedBox(width: 8),
              AutobusWordmark(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                baseColor: TermsOfServicePage._brand,
                accentColor: CustColors.logodeep,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    required this.body,
    this.bullets = const [],
    this.footer,
  });

  final String title;
  final String body;
  final List<String> bullets;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: TermsOfServicePage._ink,
      height: 1.3,
    );
    final bodyStyle = GoogleFonts.montserrat(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: TermsOfServicePage._muted,
      height: 1.7,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 10),
          Text(body, style: bodyStyle),
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 10),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: CustColors.logodeep,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(child: Text(item, style: bodyStyle)),
                  ],
                ),
              ),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(footer!, style: bodyStyle),
          ],
        ],
      ),
    );
  }
}

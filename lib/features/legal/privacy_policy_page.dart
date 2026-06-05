import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/landing/landing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _bg = Color(0xFFF6F8FF);
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _brand = Color(0xFF2A1447);

  static const _lastUpdated = 'June 5, 2026';
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
                          'Privacy Policy',
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
                          title: '1. Introduction',
                          body:
                              'Autobus ("we", "our", or "us") operates the Autobus mobile '
                              'application and web platform (collectively, the "Service"). '
                              'Autobus is an AI-powered business management platform that '
                              'helps businesses manage customers, orders, products, marketing, '
                              'communications, analytics, and day-to-day operations.\n\n'
                              'This Privacy Policy explains how we collect, use, disclose, and '
                              'protect your information when you use the Autobus app or website. '
                              'By creating an account or using the Service, you agree to the '
                              'practices described in this policy.',
                        ),
                        const _PolicySection(
                          title: '2. Information We Collect',
                          body:
                              'We collect information you provide directly, information generated '
                              'through your use of the Service, and limited technical data from your device.',
                          bullets: [
                            'Account information: full name, email address, phone number, company name, and Ghana Card identification number (where required for registration).',
                            'Authentication data: account credentials such as your PIN/password and one-time verification codes used during sign-up or account recovery.',
                            'Business data: customer records, product catalogs, orders, invoices, marketing campaigns, email and SMS content, chat conversations, and other operational data you enter or upload into Autobus.',
                            'Payment information: subscription and billing details processed through our payment partner, Paystack. Autobus does not store full payment card numbers on our servers.',
                            'Files and media: images, documents, and other files you upload for products, marketing, intelligence, or business operations.',
                            'Communications: messages you send through Autobus features, including customer emails, SMS, and in-app notifications.',
                            'Usage and device data: app interactions, feature usage, IP address, browser or device type, operating system, and diagnostic logs used to maintain security and improve performance.',
                          ],
                        ),
                        const _PolicySection(
                          title: '3. How We Use Your Information',
                          body: 'We use collected information to:',
                          bullets: [
                            'Create, authenticate, and manage your Autobus account.',
                            'Provide AI-assisted business management features, including voice and chat-based assistance.',
                            'Process subscriptions, payments, and billing through authorized payment providers.',
                            'Send account, security, and service-related notifications (including SMS where enabled).',
                            'Operate customer management, order tracking, marketing, reporting, and analytics features.',
                            'Improve app reliability, troubleshoot issues, and develop new features.',
                            'Comply with legal obligations and enforce our terms of service.',
                          ],
                        ),
                        const _PolicySection(
                          title: '4. AI and Automated Processing',
                          body:
                              'Autobus uses artificial intelligence to help you manage business tasks, '
                              'generate content, analyze data, and respond to operational requests. '
                              'Information you submit through AI features may be processed to provide '
                              'responses and recommendations within your account. We do not use your '
                              'private business data to train public AI models without your consent.',
                        ),
                        const _PolicySection(
                          title: '5. How We Share Information',
                          body:
                              'We do not sell your personal information. We may share information only in these circumstances:',
                          bullets: [
                            'Service providers: trusted third parties that help us operate the Service, such as cloud hosting, payment processing (Paystack), SMS/email delivery, and analytics providers.',
                            'Integrated platforms: when you connect third-party services (for example, social media or messaging platforms), data is shared only as needed to provide that integration.',
                            'Legal requirements: when required by law, regulation, court order, or to protect the rights, safety, and security of Autobus, our users, or others.',
                            'Business transfers: in connection with a merger, acquisition, or sale of assets, subject to continued protection of your information.',
                          ],
                        ),
                        const _PolicySection(
                          title: '6. Data Storage and Security',
                          body:
                              'We store account and business data on secure servers and use industry-standard '
                              'measures to protect information in transit and at rest. Authentication tokens '
                              'are stored using secure device storage where supported.\n\n'
                              'No method of transmission or storage is completely secure. While we work to '
                              'protect your information, we cannot guarantee absolute security.',
                        ),
                        const _PolicySection(
                          title: '7. Data Retention',
                          body:
                              'We retain your information for as long as your account is active or as needed '
                              'to provide the Service. We may retain certain records after account closure '
                              'where required for legal, accounting, fraud prevention, or dispute resolution '
                              'purposes. You may request deletion of your account data subject to applicable law.',
                        ),
                        const _PolicySection(
                          title: '8. Your Rights and Choices',
                          body: 'Depending on your location, you may have the right to:',
                          bullets: [
                            'Access, update, or correct your account information through app settings.',
                            'Request deletion of your account and associated personal data.',
                            'Opt out of non-essential SMS or in-app notifications in notification settings.',
                            'Withdraw consent where processing is based on consent, without affecting prior lawful processing.',
                            'Request a copy of personal data we hold about you.',
                          ],
                          footer:
                              'To exercise these rights, contact us at $_contactEmail.',
                        ),
                        const _PolicySection(
                          title: '9. Children\'s Privacy',
                          body:
                              'Autobus is intended for business users and is not directed to children under '
                              '13 years of age (or the minimum age required in your jurisdiction). We do not '
                              'knowingly collect personal information from children. If you believe a child has '
                              'provided us personal information, please contact us and we will take steps to delete it.',
                        ),
                        const _PolicySection(
                          title: '10. International Users',
                          body:
                              'Autobus is operated from Ghana and may process data in countries where our '
                              'service providers are located. By using the Service, you understand that your '
                              'information may be transferred to and processed in jurisdictions that may have '
                              'different data protection laws than your country.',
                        ),
                        const _PolicySection(
                          title: '11. Third-Party Links and Services',
                          body:
                              'The Service may contain links to third-party websites or embedded content through '
                              'web views. We are not responsible for the privacy practices of those third parties. '
                              'We encourage you to review their privacy policies before providing personal information.',
                        ),
                        const _PolicySection(
                          title: '12. Changes to This Policy',
                          body:
                              'We may update this Privacy Policy from time to time. When we do, we will revise '
                              'the "Last updated" date at the top of this page. Material changes may also be '
                              'communicated through the app or by email. Continued use of Autobus after changes '
                              'become effective constitutes acceptance of the updated policy.',
                        ),
                        const _PolicySection(
                          title: '13. Contact Us',
                          body:
                              'If you have questions about this Privacy Policy or how Autobus handles your data, contact us at:\n\n'
                              'Autobus\n'
                              'Email: $_contactEmail\n\n'
                              'This policy is provided for use with the Autobus app on Google Play and other distribution platforms.',
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
            color: PrivacyPolicyPage._brand,
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
                baseColor: PrivacyPolicyPage._brand,
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
      color: PrivacyPolicyPage._ink,
      height: 1.3,
    );
    final bodyStyle = GoogleFonts.montserrat(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: PrivacyPolicyPage._muted,
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

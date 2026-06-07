import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/landing/landing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class AccountDeletionPage extends StatelessWidget {
  const AccountDeletionPage({super.key});

  static const _bg = Color(0xFFF6F8FF);
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _brand = Color(0xFF2A1447);

  static const _lastUpdated = 'June 7, 2026';
  static const _contactEmail = 'privacy@autobus.app';

  static final Uri _deletionRequestUri = Uri(
    scheme: 'mailto',
    path: _contactEmail,
    queryParameters: {
      'subject': 'Autobus account deletion request',
      'body':
          'Please delete my Autobus account and associated data.\n\n'
          'Registered email or phone:\n'
          'Company name (if applicable):\n'
          'Reason for deletion (optional):\n',
    },
  );

  Future<void> _requestDeletion() async {
    if (!await launchUrl(_deletionRequestUri)) {
      throw Exception('Could not open email client');
    }
  }

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
                          'Account Deletion',
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
                          title: 'About Autobus',
                          body:
                              'This page explains how users of Autobus — the AI-powered business '
                              'management app listed on Google Play under the developer name shown on '
                              'our store listing — can request deletion of their account and associated '
                              'personal data.',
                        ),
                        _PolicySection(
                          title: 'How to request account deletion',
                          body:
                              'To delete your Autobus account and associated data, follow these steps:',
                          bullets: const [
                            'Send an email to $_contactEmail from the email address linked to your Autobus account (or include the phone number you used to register if you signed up with SMS).',
                            'Use the subject line: "Autobus account deletion request".',
                            'In the message, include your full name, registered email or phone number, and company name if you registered a business account.',
                            'We may contact you to verify your identity before processing the request.',
                            'Once verified, we will delete your account and associated personal data within 30 days and send you a confirmation email when complete.',
                          ],
                          footer:
                              'If you cannot access the email or phone number on your account, contact '
                              '$_contactEmail with any information that can help us verify ownership '
                              '(for example, your company name and approximate registration date).',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 28),
                          child: FilledButton.icon(
                            onPressed: _requestDeletion,
                            icon: const Icon(Icons.mail_outline, size: 20),
                            label: Text(
                              'Request account deletion',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: _brand,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const _PolicySection(
                          title: 'Data that is deleted',
                          body:
                              'When your deletion request is approved and processed, we delete or '
                              'anonymize the following data associated with your Autobus account:',
                          bullets: [
                            'Account profile: full name, email address, phone number, company name, and Ghana Card identification number (where collected).',
                            'Authentication data: PIN/password hashes, session tokens, and one-time verification records.',
                            'Business data you stored in Autobus: customer records, product catalogs, orders, invoices, marketing campaigns, email and SMS content, chat conversations, and other operational data tied to your account.',
                            'Uploaded files and media: images, documents, and other files stored in your Autobus workspace.',
                            'AI interaction history: prompts, responses, and conversation logs linked to your account.',
                            'In-app preferences and notification settings.',
                          ],
                        ),
                        const _PolicySection(
                          title: 'Data that may be kept',
                          body:
                              'Some information may be retained after account deletion where we have a '
                              'legal obligation or legitimate business need. When retained, data is '
                              'restricted to authorized personnel and used only for the purposes below:',
                          bullets: [
                            'Billing and payment records: transaction history, subscription records, and invoices processed through Paystack, retained as required for accounting, tax, and regulatory compliance (typically up to 7 years, or longer if required by law).',
                            'Fraud prevention and security logs: limited technical records (such as IP addresses and authentication events) retained for up to 90 days to investigate abuse and protect the Service.',
                            'Legal and dispute records: information needed to comply with applicable law, respond to lawful requests, or resolve disputes.',
                            'Anonymized or aggregated analytics that can no longer be used to identify you.',
                          ],
                        ),
                        const _PolicySection(
                          title: 'Retention period after deletion',
                          body:
                              'Most account and business data is permanently deleted within 30 days of '
                              'a verified deletion request.\n\n'
                              'Encrypted backups containing your data may persist for up to an additional '
                              '90 days before being automatically purged from our systems.\n\n'
                              'Data we are legally required to retain (such as billing records) is kept '
                              'only for the minimum period required by applicable law and is not used for '
                              'marketing or to restore your account.',
                        ),
                        const _PolicySection(
                          title: 'Partial deletion',
                          body:
                              'Deleting your Autobus account removes all data associated with that account. '
                              'If you only want to remove specific customers, products, or files, you can '
                              'delete those items individually inside the app without closing your account.',
                        ),
                        const _PolicySection(
                          title: 'Questions',
                          body:
                              'If you have questions about account deletion or your data, contact:\n\n'
                              'Autobus\n'
                              'Email: $_contactEmail\n\n'
                              'This page is provided for the Autobus app on Google Play and other '
                              'distribution platforms.',
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
            color: AccountDeletionPage._brand,
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
                baseColor: AccountDeletionPage._brand,
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
      color: AccountDeletionPage._ink,
      height: 1.3,
    );
    final bodyStyle = GoogleFonts.montserrat(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AccountDeletionPage._muted,
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

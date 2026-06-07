import 'package:autobus/features/legal/account_deletion_page.dart';
import 'package:autobus/features/legal/privacy_policy_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Normalizes the browser path for legal route matching.
String normalizeWebPath(String path) {
  var normalized = path.toLowerCase();
  if (normalized.endsWith('/') && normalized.length > 1) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

bool isLegalWebPath(String path) {
  switch (normalizeWebPath(path)) {
    case '/privacy':
    case '/privacy-policy':
    case '/delete-account':
    case '/account-deletion':
      return true;
    default:
      return false;
  }
}

Widget? legalPageForWebPath(String path) {
  switch (normalizeWebPath(path)) {
    case '/privacy':
    case '/privacy-policy':
      return const PrivacyPolicyPage();
    case '/delete-account':
    case '/account-deletion':
      return const AccountDeletionPage();
    default:
      return null;
  }
}

Future<void> openLegalWebPath(String path) async {
  if (kIsWeb) {
    await launchUrl(
      Uri.parse(path),
      webOnlyWindowName: '_self',
    );
    return;
  }
}

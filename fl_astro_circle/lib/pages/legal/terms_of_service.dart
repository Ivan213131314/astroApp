import 'package:fl_astro_circle/pages/legal/legal_document_screen.dart';
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Terms of Service',
      sections: [
        LegalSection(
          heading: 'Acceptance of Terms',
          body:
              'By using Astro Circle, you agree to these terms and to the billing rules applied by Apple for subscriptions purchased through the App Store. If you do not agree, you should stop using the premium experience before confirming your purchase.',
        ),
        LegalSection(
          heading: 'Use of the Service',
          body:
              'The app provides entertainment and self-reflection content, including astrology, numerology, compatibility, and related guidance. You agree to use the service lawfully and not to misuse the app, interfere with its operation, or attempt to access features that are not available to your account.',
        ),
        LegalSection(
          heading: 'App Store Billing',
          body:
              'Payments are charged to your Apple ID after confirmation of purchase. Unless canceled at least 24 hours before the end of the current billing period, the subscription renews automatically under the pricing shown at checkout.',
        ),
        LegalSection(
          heading: 'Changes and Support',
          body:
              'We may update features, pricing presentation, and in-app flows from time to time. For billing issues, refund questions, or subscription management, Apple support tools and your App Store subscription settings remain the primary source of control.',
        ),
      ],
    );
  }
}

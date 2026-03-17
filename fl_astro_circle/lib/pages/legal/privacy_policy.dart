import 'package:fl_astro_circle/pages/legal/legal_document_screen.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Privacy Policy',
      sections: [
        LegalSection(
          heading: 'Information We Collect',
          body:
              'We may process account details, onboarding answers, app activity, and subscription status needed to provide premium content and improve the product experience. Payment credentials are processed by Apple and are not stored directly by the app.',
        ),
        LegalSection(
          heading: 'How Information Is Used',
          body:
              'Collected information may be used to personalize content, restore access, analyze app performance, troubleshoot errors, and communicate updates related to your subscription or account.',
        ),
        LegalSection(
          heading: 'Third-Party Services',
          body:
              'The app may rely on external services such as Apple App Store billing, analytics tools, and infrastructure providers. These services may process limited technical information required to complete purchases, measure performance, and maintain security.',
        ),
        LegalSection(
          heading: 'Your Choices',
          body:
              'You can manage subscriptions through your App Store settings, request account changes where available, and stop using premium features at any time. Where applicable, local privacy rights may allow access, correction, or deletion requests.',
        ),
      ],
    );
  }
}

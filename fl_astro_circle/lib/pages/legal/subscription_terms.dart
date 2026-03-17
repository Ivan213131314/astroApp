import 'package:fl_astro_circle/pages/legal/legal_document_screen.dart';
import 'package:flutter/material.dart';

class SubscriptionTermsScreen extends StatelessWidget {
  const SubscriptionTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Subscription Terms',
      sections: [
        LegalSection(
          heading: 'Subscription Options',
          body:
              'Premium access may be offered as weekly, monthly, or annual plans. The price, billing period, and any promotional labeling displayed on the paywall are shown before purchase and are subject to App Store confirmation.',
        ),
        LegalSection(
          heading: 'Automatic Renewal',
          body:
              'Subscriptions renew automatically unless auto-renew is turned off at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the active term.',
        ),
        LegalSection(
          heading: 'Managing and Restoring',
          body:
              'You can manage or cancel your subscription from Apple ID subscription settings after purchase. If you reinstall the app or switch devices, the Restore Purchase action can be used to re-check your App Store entitlement status.',
        ),
        LegalSection(
          heading: 'Trials and Eligibility',
          body:
              'Any introductory offer or free trial, if available, is limited by Apple eligibility rules. When a trial ends, the subscription converts to the paid plan unless canceled before the renewal date shown in the App Store.',
        ),
      ],
    );
  }
}

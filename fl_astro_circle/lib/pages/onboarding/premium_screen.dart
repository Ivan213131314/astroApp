import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/revenuecat_service.dart';
import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final RevenueCatService _revenueCatService = RevenueCatService.instance;
  bool _isOpeningPaywall = false;

  Future<void> _continueOnboarding() async {
    if (_isOpeningPaywall) {
      return;
    }

    setState(() {
      _isOpeningPaywall = true;
    });

    PaywallResult? result;

    try {
      result = await _revenueCatService.presentPaywall();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _revenueCatService.lastError ??
                  'Unable to open subscription options right now.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningPaywall = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    if (result == PaywallResult.error) {
      return;
    }

    Navigator.pushNamed(context, '/onboardingAlmostThere');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AstroCircle Premium',
          style: TextStyle(
            color: whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldBgColor,
              Color(0xFF301B87),
            ],
          ),
        ),
        child: Column(
          children: [
            const LinearProgressIndicator(
              value: 0.8,
              backgroundColor: Color(0xFF3D3761),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 3,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                children: [
                  heightSpace,
                  vipBadge(),
                  heightSpace,
                  heightSpace,
                  const Text(
                    'Unlock everything\nwith AstroCircle Premium',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  featureItem(
                    Icons.calendar_today,
                    'Be prepared for the future with horoscopes',
                  ),
                  heightSpace,
                  heightSpace,
                  featureItem(
                    Icons.account_circle,
                    'Understand yourself better with birth chart analysis',
                  ),
                  heightSpace,
                  heightSpace,
                  featureItem(
                    Icons.favorite,
                    'Improve your relationships with compatibility reading',
                  ),
                  heightSpace,
                  heightSpace,
                  featureItem(
                    Icons.chat_bubble_outline,
                    'Get personalized readings for your questions',
                  ),
                  heightSpace,
                  heightSpace,
                  featureItem(
                    Icons.block,
                    'Enjoy unlimited guidance with no interruptions and ads',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              child: nextButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget vipBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: fixPadding * 3,
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor,
            width: 2,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium,
              color: primaryColor,
              size: 28,
            ),
            widthSpace,
            Text(
              'VIP',
              style: TextStyle(
                color: whiteColor,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget featureItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 24,
          ),
        ),
        widthSpace,
        widthSpace,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: const TextStyle(
                color: whiteF4Color,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget nextButton() {
    return InkWell(
      onTap: _continueOnboarding,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ],
        ),
        alignment: Alignment.center,
        child: _isOpeningPaywall
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                ),
              )
            : const Text(
                'NEXT',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}

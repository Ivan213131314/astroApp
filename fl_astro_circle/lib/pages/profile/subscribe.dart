import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/services/revenuecat_service.dart';
import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../theme/theme.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final RevenueCatService _revenueCatService = RevenueCatService.instance;

  bool _hasPresentedInitialPaywall = false;
  bool _isHandlingAction = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareSubscriptionScreen();
    });
  }

  Future<void> _prepareSubscriptionScreen() async {
    try {
      await _revenueCatService.initialize();
      await _revenueCatService.refreshCustomerInfo();
      await _revenueCatService.refreshOfferings();
    } catch (_) {
      // Errors are exposed through RevenueCatService.lastError.
    }

    if (!mounted ||
        !_revenueCatService.isSupportedPlatform ||
        _revenueCatService.hasAstroCirclePro ||
        _hasPresentedInitialPaywall) {
      return;
    }

    _hasPresentedInitialPaywall = true;
    await _openPaywall();
  }

  Future<void> _openPaywall() async {
    await _runAction(() async {
      if (!_revenueCatService.isSupportedPlatform) {
        _showMessage('Subscriptions are available on iOS and Android only.');
        return;
      }

      try {
        final result = await _revenueCatService.presentPaywall();

        if (!mounted) {
          return;
        }

        if (result == PaywallResult.purchased) {
          _showMessage('AstroCircle Premium is now active.');
        } else if (result == PaywallResult.restored) {
          _showMessage('Purchases restored.');
        } else if (result == PaywallResult.error) {
          _showMessage(
            _revenueCatService.lastError ??
                'Unable to load subscription options right now.',
          );
        }
      } catch (_) {
        if (mounted) {
          _showMessage(
            _revenueCatService.lastError ??
                'Unable to load subscription options right now.',
          );
        }
      }
    });
  }

  Future<void> _restorePurchases() async {
    await _runAction(() async {
      try {
        await _revenueCatService.restorePurchases();

        if (!mounted) {
          return;
        }

        _showMessage(
          _revenueCatService.hasAstroCirclePro
              ? 'Purchases restored.'
              : 'No active purchases were found for this account.',
        );
      } catch (_) {
        if (mounted) {
          _showMessage(
            _revenueCatService.lastError ?? 'Unable to restore purchases.',
          );
        }
      }
    });
  }

  Future<void> _openCustomerCenter() async {
    await _runAction(() async {
      try {
        await _revenueCatService.presentCustomerCenter();
      } catch (_) {
        if (mounted) {
          _showMessage(
            _revenueCatService.lastError ??
                'Unable to open subscription management right now.',
          );
        }
      }
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isHandlingAction) {
      return;
    }

    setState(() {
      _isHandlingAction = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isHandlingAction = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _revenueCatService,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        final hasPremium = _revenueCatService.hasAstroCirclePro;

        return Scaffold(
          body: Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/auth/bgImage.png'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scaffoldBgColor,
                    const Color(0xFF301B87).withValues(alpha: 0),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _header(context),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          fixPadding * 2,
                          fixPadding,
                          fixPadding * 2,
                          fixPadding * 2,
                        ),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _statusCard(hasPremium),
                          const SizedBox(height: fixPadding * 2),
                          Text(
                            hasPremium
                                ? 'AstroCircle Premium is active'
                                : 'Unlock AstroCircle Premium',
                            style: bold24WhiteF4,
                            textAlign: TextAlign.center,
                          ),
                          heightSpace,
                          Text(
                            hasPremium
                                ? 'Use RevenueCat Customer Center to manage billing, renewals, and restores from the dashboard setup.'
                                : 'Plans are configured in RevenueCat dashboard. Open the paywall to see the latest products, offers, and experiments.',
                            style: medium14Grey,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: fixPadding * 2.5),
                          _benefitTile(
                            Icons.workspace_premium,
                            'Dashboard-managed paywall and pricing',
                          ),
                          heightSpace,
                          _benefitTile(
                            Icons.refresh,
                            'Restore purchases and sync entitlements',
                          ),
                          heightSpace,
                          _benefitTile(
                            Icons.settings_outlined,
                            'Manage subscription from RevenueCat Customer Center',
                          ),
                          if (_revenueCatService.lastError != null) ...[
                            const SizedBox(height: fixPadding * 2),
                            _errorCard(_revenueCatService.lastError!),
                          ],
                          const SizedBox(height: fixPadding * 3),
                          _primaryButton(
                            label: hasPremium
                                ? 'Manage Subscription'
                                : getTranslation(context, 'subscribe.subscribe'),
                            onTap: _isHandlingAction
                                ? null
                                : hasPremium
                                    ? _openCustomerCenter
                                    : _openPaywall,
                          ),
                          const SizedBox(height: fixPadding),
                          _secondaryButton(
                            label: 'Restore Purchases',
                            onTap:
                                _isHandlingAction ? null : _restorePurchases,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return AppBar(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20.0,
      title: Row(
        children: [
          _backButton(context),
          widthSpace,
          width5Space,
          Expanded(
            child: Text(
              getTranslation(context, 'profile.subscribe'),
              style: bold18White,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(bool hasPremium) {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: recBgColor,
        border: Border.all(
          color: hasPremium ? primaryColor : rec48BgColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              hasPremium ? Icons.verified_rounded : Icons.lock_open_rounded,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: fixPadding * 1.4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPremium ? 'Premium active' : 'Premium inactive',
                  style: bold16WhiteF4,
                ),
                const SizedBox(height: 4),
                Text(
                  hasPremium
                      ? 'Your entitlement is active and synced with RevenueCat.'
                      : 'Open the RevenueCat paywall to subscribe with the latest dashboard configuration.',
                  style: medium14Grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: recBgColor.withValues(alpha: 0.92),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 22,
          ),
          const SizedBox(width: fixPadding * 1.2),
          Expanded(
            child: Text(
              title,
              style: medium16WhiteF4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: redColor.withValues(alpha: 0.12),
        border: Border.all(
          color: redColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: lightredColor,
          ),
          const SizedBox(width: fixPadding),
          Expanded(
            child: Text(
              error,
              style: medium14WhiteF4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required Future<void> Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
        decoration: BoxDecoration(
          color: onTap == null ? primaryColor.withValues(alpha: 0.45) : primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isHandlingAction
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                ),
              )
            : Text(
                label,
                style: bold16WhiteF4,
              ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required Future<void> Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: fixPadding * 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap == null
                ? rec48BgColor.withValues(alpha: 0.5)
                : rec48BgColor,
          ),
          color: recBgColor.withValues(alpha: onTap == null ? 0.55 : 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: medium16WhiteF4,
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: recBgColor,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: whiteColor,
          size: 22,
        ),
      ),
    );
  }
}

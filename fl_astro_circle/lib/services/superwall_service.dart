import 'package:fl_astro_circle/config/debug_config.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

class SuperwallService {
  static final SuperwallService _instance = SuperwallService._internal();
  factory SuperwallService() => _instance;
  SuperwallService._internal();

  Future<void> showPaywall({
    required String placement,
    Function? onPurchased,
    Function? onDeclined,
    Function? onRestored,
  }) async {
    if (DebugConfig.skipPaywall) {
      DebugConfig.log('Skipping paywall and simulating purchase.');
      await Superwall.shared.setSubscriptionStatus(
        SubscriptionStatusActive(entitlements: {Entitlement(id: 'debug_test')}),
      );
      if (onPurchased != null) {
        onPurchased();
      }
      return;
    }

    await _logPresentationPreflight(placement);

    final handler = PaywallPresentationHandler();

    handler.onDismiss((paywallInfo, paywallResult) async {
      _logPaywallInfo('Paywall dismissed', placement, paywallInfo);

      switch (paywallResult) {
        case PurchasedPaywallResult(productId: var id):
          DebugConfig.log(
            'Purchase completed for placement="$placement". productId=$id',
          );
          await Superwall.shared.setSubscriptionStatus(
            SubscriptionStatusActive(entitlements: {Entitlement(id: id)}),
          );
          if (onPurchased != null) {
            onPurchased();
          }
          break;
        case DeclinedPaywallResult():
          DebugConfig.log('Purchase declined for placement="$placement".');
          if (onDeclined != null) {
            onDeclined();
          }
          break;
        case RestoredPaywallResult():
          DebugConfig.log('Purchases restored for placement="$placement".');
          await Superwall.shared.setSubscriptionStatus(
            SubscriptionStatusActive(entitlements: {}),
          );
          if (onRestored != null) {
            onRestored();
          }
          break;
      }
    });

    handler.onPresent((paywallInfo) async {
      _logPaywallInfo('Paywall presented', placement, paywallInfo);

      if (paywallInfo.productIds == null || paywallInfo.productIds!.isEmpty) {
        DebugConfig.log(
          'Paywall presented without productIds for placement="$placement".',
        );
      }

      if (paywallInfo.productsLoadFailTime?.isNotEmpty ?? false) {
        DebugConfig.log(
          'Paywall products failed to load for placement="$placement". '
          'failTime=${paywallInfo.productsLoadFailTime}, '
          'duration=${paywallInfo.productsLoadDuration}',
        );
      }
    });

    handler.onError((error) async {
      DebugConfig.log(
        'Paywall presentation error for placement="$placement": $error',
      );

      final latestPaywallInfo = await Superwall.shared.getLatestPaywallInfo();
      if (latestPaywallInfo != null) {
        _logPaywallInfo(
          'Latest paywall snapshot after error',
          placement,
          latestPaywallInfo,
        );
      } else {
        DebugConfig.log(
          'No latest paywall info available after error for placement="$placement".',
        );
      }
    });

    handler.onSkip((skipReason) {
      DebugConfig.log(
        'Paywall skipped for placement="$placement": '
        '${_describeSkipReason(skipReason)}',
      );
    });

    try {
      await Superwall.shared.registerPlacement(
        placement,
        handler: handler,
      );
    } catch (e, stackTrace) {
      DebugConfig.log(
        'registerPlacement failed for placement="$placement": $e\n$stackTrace',
      );
      rethrow;
    }
  }

  Future<void> _logPresentationPreflight(String placement) async {
    try {
      final configurationStatus = await Superwall.shared.getConfigurationStatus();
      final subscriptionStatus = await Superwall.shared.getSubscriptionStatus();
      final presentationResult =
          await Superwall.shared.getPresentationResult(placement);

      DebugConfig.log(
        'Superwall preflight for placement="$placement": '
        'configurationStatus=$configurationStatus, '
        'subscriptionStatus=$subscriptionStatus, '
        'presentationResult=${_describePresentationResult(presentationResult)}',
      );
    } catch (e, stackTrace) {
      DebugConfig.log(
        'Unable to fetch Superwall preflight diagnostics for '
        'placement="$placement": $e\n$stackTrace',
      );
    }
  }

  String _describePresentationResult(PresentationResult result) {
    if (result is PlacementNotFoundPresentationResult) {
      return 'placementNotFound';
    }
    if (result is NoAudienceMatchPresentationResult) {
      return 'noAudienceMatch';
    }
    if (result is HoldoutPresentationResult) {
      return 'holdout(experimentId=${result.experiment.id}, '
          'groupId=${result.experiment.groupId})';
    }
    if (result is PaywallPresentationResult) {
      return 'paywall(experimentId=${result.experiment.id}, '
          'groupId=${result.experiment.groupId})';
    }
    if (result is PaywallNotAvailablePresentationResult) {
      return 'paywallNotAvailable';
    }
    return result.runtimeType.toString();
  }

  String _describeSkipReason(PaywallSkippedReason skipReason) {
    if (skipReason is PaywallSkippedReasonHoldout) {
      return 'holdout';
    }
    if (skipReason is PaywallSkippedReasonNoAudienceMatch) {
      return 'noAudienceMatch';
    }
    if (skipReason is PaywallSkippedReasonPlacementNotFound) {
      return 'placementNotFound';
    }
    return skipReason.runtimeType.toString();
  }

  void _logPaywallInfo(String prefix, String placement, PaywallInfo paywallInfo) {
    final details = <String>[
      'placement="$placement"',
      if (paywallInfo.name?.isNotEmpty ?? false) 'name=${paywallInfo.name}',
      if (paywallInfo.identifier?.isNotEmpty ?? false)
        'identifier=${paywallInfo.identifier}',
      if (paywallInfo.presentedByPlacementWithName?.isNotEmpty ?? false)
        'presentedByPlacement=${paywallInfo.presentedByPlacementWithName}',
      if (paywallInfo.productIds != null) 'productIds=${paywallInfo.productIds}',
      if (paywallInfo.products != null)
        'productsLoaded=${paywallInfo.products!.length}',
      if (paywallInfo.productsLoadCompleteTime?.isNotEmpty ?? false)
        'productsLoadCompleteTime=${paywallInfo.productsLoadCompleteTime}',
      if (paywallInfo.productsLoadFailTime?.isNotEmpty ?? false)
        'productsLoadFailTime=${paywallInfo.productsLoadFailTime}',
      if (paywallInfo.productsLoadDuration != null)
        'productsLoadDuration=${paywallInfo.productsLoadDuration}',
      if (paywallInfo.responseLoadFailTime?.isNotEmpty ?? false)
        'responseLoadFailTime=${paywallInfo.responseLoadFailTime}',
      if (paywallInfo.webViewLoadFailTime?.isNotEmpty ?? false)
        'webViewLoadFailTime=${paywallInfo.webViewLoadFailTime}',
    ];

    DebugConfig.log('$prefix: ${details.join(', ')}');
  }

  Future<bool> isUserSubscribed() async {
    try {
      final status = await Superwall.shared.subscriptionStatus.first;
      return status is SubscriptionStatusActive;
    } catch (e) {
      DebugConfig.log('Subscription status check failed: $e');
      return false;
    }
  }

  Future<void> setUserAttributes(Map<String, Object> attributes) async {
    try {
      await Superwall.shared.setUserAttributes(attributes);
      DebugConfig.log('User attributes updated: $attributes');
    } catch (e) {
      DebugConfig.log('Unable to set user attributes: $e');
    }
  }

  Future<void> restorePurchases() async {
    try {
      await Superwall.shared.restorePurchases();
      DebugConfig.log('restorePurchases completed.');
    } catch (e) {
      DebugConfig.log('restorePurchases failed: $e');
    }
  }
}

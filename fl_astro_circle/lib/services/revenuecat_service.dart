import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'package:fl_astro_circle/config/revenuecat_config.dart';

class RevenueCatService extends ChangeNotifier {
  RevenueCatService._internal();

  static final RevenueCatService instance = RevenueCatService._internal();

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isLoadingOfferings = false;
  bool _isRefreshingCustomerInfo = false;
  String? _lastError;

  Offerings? _offerings;
  CustomerInfo? _customerInfo;

  bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  bool get isLoadingOfferings => _isLoadingOfferings;
  bool get isRefreshingCustomerInfo => _isRefreshingCustomerInfo;
  bool get isBusy =>
      _isInitializing || _isLoadingOfferings || _isRefreshingCustomerInfo;

  String? get lastError => _lastError;
  Offerings? get offerings => _offerings;
  CustomerInfo? get customerInfo => _customerInfo;
  Offering? get currentOffering => _offerings?.current;

  bool get hasAstroCirclePro =>
      _customerInfo?.entitlements.active
          .containsKey(RevenueCatConfig.astroCircleProEntitlementId) ??
      false;

  String? get appUserId => _customerInfo?.originalAppUserId;
  List<String> get activeSubscriptions =>
      _customerInfo?.activeSubscriptions ?? const <String>[];

  Package? get yearlyPackage =>
      _findConfiguredPackage(RevenueCatConfig.yearlyProductId) ??
      currentOffering?.annual;

  Package? get weeklyPackage =>
      _findConfiguredPackage(RevenueCatConfig.weeklyProductId) ??
      currentOffering?.weekly;

  Package? get threeMonthPackage =>
      _findConfiguredPackage(RevenueCatConfig.threeMonthProductId) ??
      currentOffering?.threeMonth;

  List<Package> get availableSubscriptionPackages {
    final orderedPackages = <Package?>[
      yearlyPackage,
      threeMonthPackage,
      weeklyPackage,
      ...?currentOffering?.availablePackages,
    ];

    final seen = <String>{};
    final result = <Package>[];

    for (final package in orderedPackages) {
      if (package == null) {
        continue;
      }

      if (seen.add(package.identifier)) {
        result.add(package);
      }
    }

    return result;
  }

  Future<void> initialize() async {
    if (!isSupportedPlatform || _isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    _clearError(notify: false);
    notifyListeners();

    try {
      await Purchases.configure(
        PurchasesConfiguration(RevenueCatConfig.publicSdkKey),
      );
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      _isInitialized = true;

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await logIn(firebaseUser);
      } else {
        await refreshCustomerInfo();
      }

      await refreshOfferings();
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> refreshOfferings() async {
    if (!_isInitialized || !isSupportedPlatform) {
      return;
    }

    _isLoadingOfferings = true;
    _clearError(notify: false);
    notifyListeners();

    try {
      _offerings = await Purchases.getOfferings();
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
    } finally {
      _isLoadingOfferings = false;
      notifyListeners();
    }
  }

  Future<void> refreshCustomerInfo() async {
    if (!_isInitialized || !isSupportedPlatform) {
      return;
    }

    _isRefreshingCustomerInfo = true;
    _clearError(notify: false);
    notifyListeners();

    try {
      _customerInfo = await Purchases.getCustomerInfo();
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
    } finally {
      _isRefreshingCustomerInfo = false;
      notifyListeners();
    }
  }

  Future<void> logIn(User user) async {
    if (!isSupportedPlatform) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return;
      }
    }

    _clearError(notify: false);
    notifyListeners();

    try {
      final logInResult = await Purchases.logIn(user.uid);
      _customerInfo = logInResult.customerInfo;
      await refreshOfferings();
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    if (!isSupportedPlatform || !_isInitialized) {
      return;
    }

    _clearError(notify: false);
    notifyListeners();

    try {
      _customerInfo = await Purchases.logOut();
      await refreshOfferings();
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    if (!isSupportedPlatform) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return;
      }
    }

    _isRefreshingCustomerInfo = true;
    _clearError(notify: false);
    notifyListeners();

    try {
      _customerInfo = await Purchases.restorePurchases();
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
      rethrow;
    } finally {
      _isRefreshingCustomerInfo = false;
      notifyListeners();
    }
  }

  Future<void> purchasePackage(Package package) async {
    if (!isSupportedPlatform) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return;
      }
    }

    _clearError(notify: false);
    notifyListeners();

    try {
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      _customerInfo = purchaseResult.customerInfo;
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<PaywallResult> presentPaywallIfNeeded({Offering? offering}) async {
    if (!isSupportedPlatform) {
      return PaywallResult.notPresented;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return PaywallResult.error;
      }
    }

    _clearError(notify: false);
    notifyListeners();

    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        RevenueCatConfig.astroCircleProEntitlementId,
        offering: offering ?? currentOffering,
      );

      if (result == PaywallResult.purchased ||
          result == PaywallResult.restored) {
        await refreshCustomerInfo();
      }

      return result;
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<PaywallResult> presentPaywall({Offering? offering}) async {
    if (!isSupportedPlatform) {
      return PaywallResult.notPresented;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return PaywallResult.error;
      }
    }

    _clearError(notify: false);
    notifyListeners();

    try {
      final result = await RevenueCatUI.presentPaywall(
        offering: offering ?? currentOffering,
      );

      if (result == PaywallResult.purchased ||
          result == PaywallResult.restored) {
        await refreshCustomerInfo();
      }

      return result;
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> presentCustomerCenter() async {
    if (!isSupportedPlatform) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return;
      }
    }

    _clearError(notify: false);
    notifyListeners();

    try {
      await RevenueCatUI.presentCustomerCenter(
        onRestoreCompleted: (customerInfo) {
          _customerInfo = customerInfo;
          notifyListeners();
        },
      );
    } catch (error) {
      _lastError = _toUserFacingMessage(error);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  String planLabel(Package package) {
    switch (package.storeProduct.identifier) {
      case RevenueCatConfig.yearlyProductId:
        return 'Yearly';
      case RevenueCatConfig.threeMonthProductId:
        return 'Three Month';
      case RevenueCatConfig.weeklyProductId:
        return 'Weekly';
      default:
        switch (package.packageType) {
          case PackageType.annual:
            return 'Yearly';
          case PackageType.threeMonth:
            return 'Three Month';
          case PackageType.weekly:
            return 'Weekly';
          default:
            return package.storeProduct.title;
        }
    }
  }

  String? renewalLabel(Package package) {
    final storeProduct = package.storeProduct;
    switch (package.storeProduct.identifier) {
      case RevenueCatConfig.yearlyProductId:
        return storeProduct.pricePerMonthString == null
            ? 'Billed yearly'
            : '${storeProduct.pricePerMonthString} / month equivalent';
      case RevenueCatConfig.threeMonthProductId:
        return storeProduct.pricePerMonthString == null
            ? 'Billed every 3 months'
            : '${storeProduct.pricePerMonthString} / month equivalent';
      case RevenueCatConfig.weeklyProductId:
        return 'Renews weekly';
      default:
        switch (package.packageType) {
          case PackageType.annual:
            return 'Billed yearly';
          case PackageType.threeMonth:
            return 'Billed every 3 months';
          case PackageType.weekly:
            return 'Renews weekly';
          default:
            return storeProduct.subscriptionPeriod;
        }
    }
  }

  bool isCurrentProductActive(Package package) {
    return activeSubscriptions.contains(package.storeProduct.identifier);
  }

  String _toUserFacingMessage(Object error) {
    if (error is PlatformException) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      switch (code) {
        case PurchasesErrorCode.purchaseCancelledError:
          return 'Purchase cancelled.';
        case PurchasesErrorCode.networkError:
          return 'Network error. Please try again.';
        case PurchasesErrorCode.purchaseNotAllowedError:
          return 'Purchases are not allowed on this device.';
        case PurchasesErrorCode.storeProblemError:
          return 'There is a store problem right now. Please try again later.';
        case PurchasesErrorCode.configurationError:
          return 'RevenueCat is not configured yet. Check products, offerings, and entitlements.';
        default:
          break;
      }

      if ((error.message ?? '').isNotEmpty) {
        return error.message!;
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  Package? _findConfiguredPackage(String productIdentifier) {
    final offering = currentOffering;
    if (offering == null) {
      return null;
    }

    for (final package in offering.availablePackages) {
      if (package.identifier == productIdentifier ||
          package.storeProduct.identifier == productIdentifier) {
        return package;
      }
    }

    return null;
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _customerInfo = customerInfo;
    notifyListeners();
  }

  void _clearError({bool notify = true}) {
    _lastError = null;
    if (notify) {
      notifyListeners();
    }
  }
}

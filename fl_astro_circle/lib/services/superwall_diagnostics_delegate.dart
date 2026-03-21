import 'package:fl_astro_circle/config/debug_config.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

class SuperwallDiagnosticsDelegate implements SuperwallDelegate {
  const SuperwallDiagnosticsDelegate();

  void _log(String message) {
    DebugConfig.log('[Superwall] $message');
  }

  String _describePaywall(PaywallInfo paywallInfo) {
    final details = <String>[
      if (paywallInfo.name?.isNotEmpty ?? false) 'name=${paywallInfo.name}',
      if (paywallInfo.identifier?.isNotEmpty ?? false)
        'identifier=${paywallInfo.identifier}',
      if (paywallInfo.presentedByPlacementWithName?.isNotEmpty ?? false)
        'placement=${paywallInfo.presentedByPlacementWithName}',
      if (paywallInfo.productIds != null) 'productIds=${paywallInfo.productIds}',
      if (paywallInfo.products != null)
        'productsLoaded=${paywallInfo.products!.length}',
      if (paywallInfo.productsLoadDuration != null)
        'productsLoadDuration=${paywallInfo.productsLoadDuration}',
      if (paywallInfo.productsLoadFailTime?.isNotEmpty ?? false)
        'productsLoadFailTime=${paywallInfo.productsLoadFailTime}',
      if (paywallInfo.responseLoadFailTime?.isNotEmpty ?? false)
        'responseLoadFailTime=${paywallInfo.responseLoadFailTime}',
    ];

    if (details.isEmpty) {
      return 'no paywall details available';
    }

    return details.join(', ');
  }

  @override
  void subscriptionStatusDidChange(SubscriptionStatus newValue) {
    _log('subscriptionStatusDidChange: $newValue');
  }

  @override
  void handleSuperwallEvent(SuperwallEventInfo eventInfo) {
    final details = <String>[
      'event=${eventInfo.event.type}',
      if (eventInfo.status != null) 'status=${eventInfo.status!.type.name}',
      if (eventInfo.reason != null) 'reason=${eventInfo.reason!.type.name}',
      if (eventInfo.params != null && eventInfo.params!.isNotEmpty)
        'params=${eventInfo.params}',
    ];

    _log(details.join(' | '));
  }

  @override
  void handleCustomPaywallAction(String name) {
    _log('handleCustomPaywallAction: $name');
  }

  @override
  void willDismissPaywall(PaywallInfo paywallInfo) {
    _log('willDismissPaywall: ${_describePaywall(paywallInfo)}');
  }

  @override
  void willPresentPaywall(PaywallInfo paywallInfo) {
    _log('willPresentPaywall: ${_describePaywall(paywallInfo)}');
  }

  @override
  void didDismissPaywall(PaywallInfo paywallInfo) {
    _log('didDismissPaywall: ${_describePaywall(paywallInfo)}');
  }

  @override
  void didPresentPaywall(PaywallInfo paywallInfo) {
    _log('didPresentPaywall: ${_describePaywall(paywallInfo)}');

    if (paywallInfo.productIds == null || paywallInfo.productIds!.isEmpty) {
      _log('didPresentPaywall: paywall has no productIds attached.');
    }

    if (paywallInfo.productsLoadFailTime?.isNotEmpty ?? false) {
      _log(
        'didPresentPaywall: products failed to load at ${paywallInfo.productsLoadFailTime}.',
      );
    }
  }

  @override
  void paywallWillOpenURL(Uri url) {
    _log('paywallWillOpenURL: $url');
  }

  @override
  void paywallWillOpenDeepLink(Uri url) {
    _log('paywallWillOpenDeepLink: $url');
  }

  @override
  void handleLog(
    String level,
    String scope,
    String? message,
    Map<dynamic, dynamic>? info,
    String? error,
  ) {
    final details = <String>[
      'sdkLog level=$level',
      'scope=$scope',
      if (message?.isNotEmpty ?? false) 'message=$message',
      if (info != null && info.isNotEmpty) 'info=$info',
      if (error?.isNotEmpty ?? false) 'error=$error',
    ];

    _log(details.join(' | '));
  }

  @override
  void handleSuperwallDeepLink(
    Uri fullURL,
    List<String> pathComponents,
    Map<String, String> queryParameters,
  ) {
    _log(
      'handleSuperwallDeepLink: fullURL=$fullURL path=$pathComponents query=$queryParameters',
    );
  }
}

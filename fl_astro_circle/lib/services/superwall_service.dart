import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:fl_astro_circle/config/debug_config.dart';

class SuperwallService {
  static final SuperwallService _instance = SuperwallService._internal();
  factory SuperwallService() => _instance;
  SuperwallService._internal();

  // Показать paywall с обработкой результата
  Future<void> showPaywall({
    required String placement,
    Function? onPurchased,
    Function? onDeclined,
    Function? onRestored,
  }) async {
    // DEBUG: Skip paywall and simulate purchase
    if (DebugConfig.skipPaywall) {
      DebugConfig.log('Skipping paywall - simulating purchase');
      await Superwall.shared.setSubscriptionStatus(
        SubscriptionStatusActive(entitlements: {Entitlement(id: 'debug_test')}),
      );
      if (onPurchased != null) {
        onPurchased();
      }
      return;
    }

    final handler = PaywallPresentationHandler();

    // Обработка закрытия paywall
    handler.onDismiss((paywallInfo, paywallResult) async {
      String name = (paywallInfo.name) ?? 'Unknown';
      print("Paywall закрыт: $name");

      switch (paywallResult) {
        case PurchasedPaywallResult(productId: var id):
          print('Покупка выполнена! ID продукта: $id');
          // Обновить статус подписки на активный
          await Superwall.shared.setSubscriptionStatus(
            SubscriptionStatusActive(entitlements: {Entitlement(id: id)}),
          );
          if (onPurchased != null) {
            onPurchased();
          }
          break;
        case DeclinedPaywallResult():
          print('Пользователь отклонил покупку');
          if (onDeclined != null) {
            onDeclined();
          }
          break;
        case RestoredPaywallResult():
          print('Покупки восстановлены');
          // Обновить статус подписки на активный
          await Superwall.shared.setSubscriptionStatus(
            SubscriptionStatusActive(entitlements: {}),
          );
          if (onRestored != null) {
            onRestored();
          }
          break;
      }
    });

    // Обработка показа paywall
    handler.onPresent((paywallInfo) async {
      String name = (paywallInfo.name) ?? 'Unknown';
      print("Paywall показан: $name");
    });

    // Обработка ошибок
    handler.onError((error) {
      print("Ошибка Paywall: $error");
      // При ошибке загрузки paywall - показать сообщение
      // В реальном приложении можно показать fallback экран подписки
    });

    // Обработка пропуска paywall
    handler.onSkip((skipReason) {
      if (skipReason is PaywallSkippedReasonHoldout) {
        print("Paywall пропущен: пользователь в контрольной группе (Holdout)");
      } else if (skipReason is PaywallSkippedReasonNoAudienceMatch) {
        print("Paywall пропущен: нет совпадения с аудиторией");
      } else if (skipReason is PaywallSkippedReasonPlacementNotFound) {
        print("Paywall пропущен: Placement не найден в Dashboard");
      } else {
        print("Paywall пропущен: $skipReason");
      }
    });

    // Регистрация placement
    await Superwall.shared.registerPlacement(
      placement,
      handler: handler,
    );
  }

  // Проверить статус подписки
  Future<bool> isUserSubscribed() async {
    try {
      // Получаем текущий статус подписки через Stream
      final status = await Superwall.shared.subscriptionStatus.first;
      // SubscriptionStatus это enum с вариантами: active, inactive, unknown
      return status is SubscriptionStatusActive;
    } catch (e) {
      print("Ошибка проверки подписки: $e");
      return false;
    }
  }

  // Установить пользовательские атрибуты
  Future<void> setUserAttributes(Map<String, Object> attributes) async {
    try {
      await Superwall.shared.setUserAttributes(attributes);
      print("Атрибуты пользователя установлены: $attributes");
    } catch (e) {
      print("Ошибка установки атрибутов: $e");
    }
  }

  // Восстановить покупки
  Future<void> restorePurchases() async {
    try {
      await Superwall.shared.restorePurchases();
      print("Покупки восстановлены");
    } catch (e) {
      print("Ошибка восстановления покупок: $e");
    }
  }
}


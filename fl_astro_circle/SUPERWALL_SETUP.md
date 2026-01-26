# Настройка Superwall

## Что уже сделано:

✅ Superwall SDK добавлен в проект  
✅ API ключ настроен  
✅ Код интегрирован в два места:
- Экран премиума в онбординге (`premium_screen.dart`)
- Экран подписки в профиле (`subscribe.dart`)
✅ Создан сервис `SuperwallService` для работы с Superwall

## Настройка в Superwall Dashboard:

### 1. Создайте Placements (События)

Зайдите в [Superwall Dashboard](https://superwall.com/dashboard) → **Campaigns** → **Create Campaign**

Создайте два placement:
- `onboarding_premium` - для показа paywall в онбординге
- `subscribe_button` - для показа paywall при нажатии на кнопку подписки

### 2. Создайте Paywall (Экран подписки)

Зайдите в **Paywalls** → **Create Paywall**

Создайте дизайн вашего paywall:
- Добавьте заголовок и описание
- Выберите цвета и шрифты
- Добавьте список преимуществ подписки
- Настройте кнопки подписки

### 3. Настройте Products (Продукты)

Зайдите в **Products**:

#### Для Android (Google Play):
1. Создайте продукты подписки в [Google Play Console](https://play.google.com/console)
2. Получите Product ID (например: `premium_monthly`, `premium_yearly`)
3. Добавьте эти ID в Superwall Dashboard

#### Для iOS (App Store):
1. Когда получите Apple Developer аккаунт
2. Создайте продукты в [App Store Connect](https://appstoreconnect.apple.com)
3. Добавьте Product ID в Superwall Dashboard

### 4. Настройте Campaign Rules (Правила показа)

Зайдите в **Campaigns** → выберите свою кампанию → **Rules**

Настройте правила когда показывать paywall:
- Всем пользователям
- Только новым пользователям
- После определенных действий
- На основе пользовательских атрибутов

## Как использовать в коде:

### Простой показ paywall:
```dart
await SuperwallService().showPaywall(
  placement: "subscribe_button",
);
```

### С обработкой результата:
```dart
await SuperwallService().showPaywall(
  placement: "subscribe_button",
  onPurchased: () {
    // Код после успешной покупки
    print("Подписка оформлена!");
  },
  onDeclined: () {
    // Код если пользователь отклонил
    print("Покупка отклонена");
  },
  onRestored: () {
    // Код если восстановили покупки
    print("Покупки восстановлены");
  },
);
```

### Проверить статус подписки:
```dart
bool isSubscribed = await SuperwallService().isUserSubscribed();
if (isSubscribed) {
  // Пользователь подписан
}
```

### Установить пользовательские атрибуты:
```dart
await SuperwallService().setUserAttributes({
  'user_id': '12345',
  'name': 'John Doe',
  'sign': 'Aries',
  'onboarding_completed': true,
});
```

### Восстановить покупки:
```dart
await SuperwallService().restorePurchases();
```

## Где интегрировано:

1. **Онбординг** (`lib/pages/onboarding/premium_screen.dart`):
   - Placement: `onboarding_premium`
   - Показывается при нажатии на кнопку NEXT
   - После покупки или пропуска переход на следующий экран

2. **Профиль** (`lib/pages/profile/subscribe.dart`):
   - Placement: `subscribe_button`
   - Показывается при нажатии на кнопку Subscribe
   - После покупки показывается уведомление и закрывается экран

3. **Universe Message** (`lib/pages/universeMessage/universe_message.dart`):
   - Placement: `subscribe_button`
   - Показывается при нажатии на кнопку "Decipher Message" в диалоге получения ответа

4. **Universe Sign** (`lib/pages/universeSign/universe_sign.dart` & `universe_sign_player_screen.dart`):
   - Placement: `subscribe_button`
   - Показывается при нажатии на "Decode the Sign" (в диалоге или на экране плеера)

## Тестирование:

### На Android эмуляторе:
1. Запустите приложение
2. Пройдите онбординг до экрана Premium
3. Нажмите NEXT - должен показаться Superwall paywall
4. Настройте тестовые продукты в Google Play Console для проверки покупок

### На iOS симуляторе:
1. Запустите приложение
2. Пройдите онбординг до экрана Premium
3. Нажмите NEXT - должен показаться Superwall paywall UI
4. Покупки не будут работать (только на реальном устройстве)

## Следующие шаги:

1. ✅ Создайте paywall дизайн в Superwall Dashboard
2. ✅ Настройте placements: `onboarding_premium` и `subscribe_button`
3. ⏳ Создайте продукты подписки в Google Play Console (для Android)
4. ⏳ Когда получите Apple Developer - создайте продукты в App Store Connect (для iOS)
5. ⏳ Протестируйте на эмуляторе/устройстве

## Полезные ссылки:

- [Superwall Dashboard](https://superwall.com/dashboard)
- [Superwall Documentation](https://docs.superwall.com)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com)

## Поддержка:

Если возникнут вопросы:
- Документация Superwall: https://docs.superwall.com/docs/flutter
- Support: support@superwall.com


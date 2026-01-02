# Модуль: Profile & Settings

**Responsibility:** Управление аккаунтом, настройками и подпиской.
**Spec file:** `specs/profile.md`

## Обзор
Раздел профиля позволяет пользователю редактировать личные данные, управлять подпиской и менять настройки приложения.

## Экраны
*   **Профиль** (`/profile`): Главное меню настроек.
*   **Редактирование** (`/editProfile`): Изменение имени, телефона, email.
*   **Подписка** (`/subscribe`): Управление планом.
*   **Язык** (`/language`): Смена языка приложения.
*   **О нас** (`/aboutUs`).

## Логика
1.  **Данные Пользователя:**
    *   Использует `UserService` для чтения/записи данных из Firestore.
2.  **Подписка (Monetization):**
    *   Интеграция с **Superwall** (`lib/services/superwall_service.dart`).
    *   `showPaywall()`: Показывает экран покупки.
    *   `isUserSubscribed()`: Проверяет статус активной подписки (Active Entitlement).
    *   Поддерживает Debug-режим (`DebugConfig.skipPaywall`), симулирующий покупку.
3.  **Платежи:**
    *   Экраны `PaymentMethodScreen`, `MasterCardScreen` присутствуют в роутах, но основная монетизация идет через Superwall (In-App Purchases).

## Локализация
Смена языка в `LanguageScreen` обновляет глобальный `Locale` в `MyApp` (`lib/main.dart`).

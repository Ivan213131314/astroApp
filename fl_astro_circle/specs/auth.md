# Модуль: Authentication

**Responsibility:** Управление доступом пользователей, регистрация и вход.
**Spec file:** `specs/auth.md`

## Обзор
Модуль обеспечивает вход пользователей через Email/Password, Google и Apple. Поддерживает регистрацию, подтверждение email и сброс пароля.

## Структура Экранов
**Путь:** `lib/pages/auth/`
*   `AuthChoiceScreen` (`/authChoice`): Стартовый экран выбора метода входа.
*   `LoginScreen` (`/login`): Форма входа по Email/Password.
*   `RegisterScreen` (`/register`): Форма регистрации.

## Функциональность (Логика)
Реализована в `AuthService` (`lib/services/auth_service.dart`).

### 1. Методы Входа
*   **Google Sign-In:** Использует нативный Google Sign-In SDK.
*   **Apple Sign-In:** Использует нативный Apple ID. Поддерживает `nonce` для безопасной аутентификации в Firebase.
*   **Email & Password:** Стандартная регистрация Firebase Auth.

### 2. Регистрация и Верификация
*   При регистрации по Email автоматически отправляется письмо подтверждения (`sendEmailVerification`).
*   Проверка верификации: `isEmailVerified()`.

### 3. Управление Сессией
*   **Выход (Logout):**
    *   Выход из Firebase Auth.
    *   Выход из Google Sign-In.
    *   Очистка локальных данных пользователя (`UserService.clearUserData`).
    *   Сброс кэша Firestore (`clearPersistence`) — критично для предотвращения утечки данных между пользователями на одном устройстве.
*   **Восстановление пароля:** Отправка письма сброса (`sendPasswordResetEmail`). (Только метод сервиса, UI для сброса отсутствует).

## Данные
Использует коллекцию `users` в Firestore (через `UserService`) для создания/обновления профиля при входе.

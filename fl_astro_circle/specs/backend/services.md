# Backend Services Specification

## Обзор
Взаимодействие с бэкендом (Firebase) и внешними API инкапсулировано в сервисных классах (`lib/services/`). Приложение использует подход BaaS (Backend-as-a-Service).

**Основные принципы:**
*   **Singleton-like:** Сервисы либо являются синглтонами, либо создаются по требованию (но хранят состояние).
*   **Direct Firestore Access:** Клиентское приложение напрямую читает/пишет в коллекции Firestore, используя SDK.
*   **Offline Support:** Используется персистентность Firestore для работы офлайн.
*   **Local Caching:** Критичные данные (имя пользователя, пути к фото) дублируются в `SharedPreferences` для мгновенного доступа без ожиданий БД.

## Список Сервисов

### 1. User Service
**Файл:** `lib/services/user_service.dart`
**Ответственность:** Управление данными профиля пользователя.

*   **Хранилище:**
    *   Firestore: Коллекция `users`. Документ ID = `uid`.
    *   Local: `SharedPreferences` (ключ `user_name`), Файловая система (фото профиля).
*   **Функции:**
    *   `saveUserName(name)`: Сохраняет имя в кэш и Firestore.
    *   `getUserName()`: Возвращает имя (приоритет: кэш -> Firestore).
    *   `updateUserProfile(...)`: Обновляет поля профиля (email, phone, birthDate, gender, updatedAt).
    *   `getUserProfileStream()`: Real-time подписка на изменения профиля.
    *   `saveLocalProfilePhoto(file)`: Сохраняет фото локально в папку приложения. Использует `path_provider`.
    *   `clearUserData()`: Очищает локальные данные при выходе (кроме фото, привязанных к ID).

### 2. Auth Service
**Файл:** `lib/services/auth_service.dart`
**Ответственность:** Аутентификация и управление сессией.

*   **Интеграции:**
    *   Authentication: Firebase Auth (Email/Password), Google Sign In, Sign In with Apple.
*   **Функции:**
    *   `signInWithGoogle()`, `signInWithApple()`.
    *   `registerWithEmailAndPassword()`, `signInWithEmailAndPassword()`.
    *   `signOut()`: Выходит из всех провайдеров, очищает локальные данные через `UserService` и сбрасывает кэш Firestore (`clearPersistence`).
    *   `generateNonce()`, `sha256ofString()`: Утилиты для Apple Auth.

### 3. Horoscope Service
**Файл:** `lib/services/horoscope_service.dart`
**Ответственность:** Получение астрологических прогнозов.

*   **Хранилище:**
    *   Firestore: Коллекция `horoscopes`.
    *   ID документа: `${zodiacSign}_${date}_${period}` (например: `aries_2024-01-01_daily`).
*   **Функции:**
    *   `getHoroscope(...)`: Получает прогноз по знаку, дате и периоду.
    *   `getTodayHoroscope(...)`: Утилита для получения прогноза на "сегодня/завтра/неделю" от текущей даты.
    *   `getAllPeriodsForToday(...)`: Получает все 3 вида прогнозов разом.
    *   `streamHoroscope(...)`: Real-time подписка на обновление прогноза.
    *   `getZodiacSignFromDate(...)`: Статический хелпер для определения знака зодиака.

## Структура Данных (Firestore Schema)

*На основе анализа кода доступа к данным.*

### Коллекция `users` (docId: uid)
*   `name` (string)
*   `email` (string)
*   `phoneNumber` (string)
*   `dateOfBirth` (string)
*   `gender` (string)
*   `updatedAt` (timestamp)

### Коллекция `horoscopes` (docId: composite)
*   Данные мапятся в модель `HoroscopeData` (поля зависят от модели, детали см. в `horoscope.md`).

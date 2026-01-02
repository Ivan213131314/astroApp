# Спецификация Проекта: Astro Circle

Этот документ является **КОРНЕВОЙ СПЕЦИФИКАЦИЕЙ** проекта. Он описывает высокоуровневую структуру, навигацию и основные правила работы с технической документацией.

## 1. Обзор Проекта

**Astro Circle** — это мобильное приложение на базе Flutter, предоставляющее пользователям комплекс астрологических и эзотерических сервисов.

**Целевая аудитория:** Пользователи, интересующиеся астрологией, нумерологией, хиромантией и духовным развитием.

**Основные возможности:**
*   Персональные гороскопы (ежедневные, натальные карты).
*   Анализ совместимости партнеров.
*   Нумерологические расчеты.
*   Хиромантия (анализ линий ладони).
*   Консультации с реальными астрологами (чат, аудио, видео).
*   "Знаки Вселенной" и аффирмации.

**Границы системы (Scope):**
*   **Входит:** Клиентское мобильное приложение (Android/iOS), взаимодействие с Firebase (хранение данных, аутентификация), интеграция платежей (Superwall/In-App).
*   **Не входит:** Админ-панель для астрологов (если не является частью этого же кодовой базы), сложная бэкенд-логика вне Firebase Functions.

## 2. Высокоуровневая Архитектура

Система построена по классической клиент-серверной архитектуре с использованием BaaS (Backend-as-a-Service).

*   **Frontend (Mobile App):** Приложение на Flutter. Использует локальное состояние и сервисные классы для общения с API.
*   **Backend (BaaS):** Firebase.
    *   **Auth:** Управление пользователями и вход через соцсети.
    *   **Firestore:** Основная база данных (профили, чаты, контент).
    *   **Functions:** Серверная логика (если применимо).

*   **External Services:**
    *   **Superwall:** Управление платным доступом (Paywalls).
    *   **Google Places:** Автозаполнение мест рождения.

## 3. Технологический Стек

*   **Язык:** Dart (SDK >=3.0.0 <4.0.0).
*   **Фреймворк:** Flutter.
*   **State Management:** Нативный `setState` + Service Layers (Singletone-like сервисы).
*   **Backend:** Firebase (Core, Auth, Firestore, Functions).
*   **Вспомогательные библиотеки:**
    *   `shared_preferences` (локальный кэш).
    *   `intl` (локализация).
    *   `page_transition` (навигация).
    *   `just_audio` (аудио).
    *   `superwallkit_flutter` (монетизация).

## 4. Структура Спецификаций

Все спецификации находятся в папке `specs/`.

```
specs/
 ├── frontend/           # Архитектура клиентской части
 │     └── architecture.md
 ├── backend/            # Архитектура серверной части и данных
 │     └── services.md
 ├── auth.md             # Аутентификация и регистрация
 ├── onboarding.md       # Процесс онбординга пользователя
 ├── horoscope.md        # Модуль гороскопов
 ├── palmistry.md        # Модуль хиромантии (Plam Reader)
 ├── compatibility.md    # Модуль совместимости
 ├── numerology.md       # Модуль нумерологии
 ├── natal_chart.md      # Модуль натальных карт
 ├── universe.md         # Знаки вселенной и сообщения
 ├── consultations.md    # Чат и звонки с астрологами
 └── profile.md          # Профиль пользователя и настройки
```

## 5. Маршрутизация Спецификаций

### Базовые Модули
- **Frontend Core**
  Responsibility: Общая структура UI, темизация, навигация `routes` и ассеты.
  Spec file: `specs/frontend/architecture.md`
  Consult this spec when: Меняете глобальные стили, добавляете новые роуты или меняете структуру папок `lib`.

- **Backend Services**
  Responsibility: Взаимодействие с Firebase и внешними API сервисами.
  Spec file: `specs/backend/services.md`
  Consult this spec when: Изменяете логику данных, добавляете новые поля в Firestore или меняете API-ключи.

### Функциональные Модули
- **Authentication**
  Responsibility: Вход, регистрация (Email, Socials), восстановление доступа.
  Spec file: `specs/auth.md`
  Consult this spec when: Меняете флоу логина или провайдеров аутентификации.

- **Onboarding**
  Responsibility: Сбор первичных данных пользователя (дата рождения, интересы) после установки.
  Spec file: `specs/onboarding.md`
  Consult this spec when: Изменяете шаги онбординга или вопросы анкеты.

- **Horoscope**
  Responsibility: Отображение ежедневных гороскопов и детальных прогнозов.
  Spec file: `specs/horoscope.md`
  Consult this spec when: Правки в экране гороскопа или логике получения прогнозов.

- **Palmistry (Plam Reader)**
  Responsibility: Сканирование/загрузка фото ладони и отображение анализа.
  Spec file: `specs/palmistry.md`
  Consult this spec when: Изменения в модуле хиромантии.

- **Compatibility**
  Responsibility: Расчет совместимости двух людей (по дате рождения).
  Spec file: `specs/compatibility.md`
  Consult this spec when: Правки в экранах совместимости.

- **Numerology**
  Responsibility: Нумерологические расчеты и отчеты.
  Spec file: `specs/numerology.md`
  Consult this spec when: Изменения в разделе нумерологии.

- **Natal Chart**
  Responsibility: Построение и расшифровка натальной карты.
  Spec file: `specs/natal_chart.md`
  Consult this spec when: Правки в логике или UI натальных карт.

- **Universe Services**
  Responsibility: "Знаки Вселенной" (Signs) и "Сообщения" (Messages/Deciphers).
  Spec file: `specs/universe.md`
  Consult this spec when: Изменения в развлекательных разделах с предсказаниями.

- **Consultations**
  Responsibility: Список астрологов, чат, аудио и видеозвонки.
  Spec file: `specs/consultations.md`
  Consult this spec when: Правки в логике общения с экспертами (RTC, Chat UI).

- **Profile & Settings**
  Responsibility: Управление профилем, подпиской (Superwall), языком и платежами.
  Spec file: `specs/profile.md`
  Consult this spec when: Изменяете настройки аккаунта, платежные шлюзы или экран профиля.

## 6. Правила Поддержки Спецификаций

1.  **Актуальность:** Спецификация должна отражать *текущее* состояние кода. Не описывайте желаемое поведение, если оно еще не реализовано.
2.  **Модульность:** При изменении логики конкретного модуля обновляйте только его MD-файл.
3.  **Язык:** Вся документация ведется на русском языке.

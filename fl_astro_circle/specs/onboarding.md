# Модуль: Onboarding

**Responsibility:** Сбор анкетных данных пользователя после первоначальной установки приложения.
**Spec file:** `specs/onboarding.md`

## Обзор
Онбординг — это длинная последовательность экранов, собирающая информацию для построения астрологического профиля. Он начинается с экрана "Welcome" и заканчивается предложением премиум-подписки.

## Флоу (Последовательность Экранов)
Маршрутизация определена в `lib/main.dart`. Переходы осуществляются справа налево.

1.  **Welcome** (`/onboarding`): Вход или старт нового.
2.  **Goals** (`/onboardingGoals`): Выбор целей.
3.  **Goals Info** (`/onboardingGoalsInfo`): Информационный экран.
4.  **Main Reason** (`/onboardingMainReason`): Основная причина использования.
5.  **Goal Together** (`/onboardingGoalTogether`): Социальное подтверждение.
6.  **Birth Chart Intro** (`/onboardingBirthChartIntro`): Введение в натальную карту.
7.  **Date of Birth** (`/onboardingDateOfBirth`): Ввод даты рождения.
8.  **Time of Birth** (`/onboardingTimeOfBirth`): Ввод времени рождения.
9.  **Place of Birth** (`/onboardingPlaceOfBirth`): Ввод места (Google Places).
10. **Horoscopes Question** (`/onboardingHoroscopesQuestion`): Интересует ли гороскоп?
11. **Gender** (`/onboardingGender`): Выбор пола.
12. **Name** (`/onboardingName`): Ввод имени.
13. **Birth Chart Question** (`/onboardingBirthChartQuestion`): Интересует ли натальная карта?
14. **Relationship Status** (`/onboardingRelationshipStatus`): Статус отношений.
15. **Interests** (`/onboardingInterests`): Выбор интересов.
16. **Compatibility Question** (`/onboardingCompatibilityQuestion`): Интересует ли совместимость?
17. **Premium Offer** (`/onboardingPremium`): Экран продажи подписки (Paywall).
18. **Almost There** (`/onboardingAlmostThere`): Завершающий экран, переход к аутентификации.



## UI Компоненты
*   Кнопки "Continue" внизу экрана.
*   Индикаторы прогресса (если есть).
*   Анимации переходов (`page_transition`).

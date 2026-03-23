# Frontend Architecture Specification

## Обзор
Приложение написано на Flutter. Использует Material Design с кастомной темой. Навигация построена на именованных маршрутах (Named Routes).

## Структура Проекта
Папка `lib/` организована по функциональному признаку (Feature-first) внутри `pages/`.

*   `main.dart`: Точка входа. Инициализация Firebase, локализации и роутера.
*   `pages/`: Экраны приложения. Каждая подпапка соответствует модулю (например, `horoscope`, `auth`).
*   `services/`: Логика взаимодействия с бэкендом (см. `backend/services.md`).
*   `theme/`: Глобальные стили.
*   `localization/`: Файлы локализации.
*   `config/`: Конфигурация (env, константы).

## Навигация и Роутинг

**Файл:** `lib/main.dart` (функция `routes`)
**Экспорт экранов:** `lib/pages/screens.dart`

Используется `Navigator 1.0` с именованными маршрутами. Для переходов применяется пакет `page_transition` (анимации слайда справа налево или фейд).

**Основные маршруты:**
*   `/`: Splash Screen.
*   `/onboarding*`: Серия экранов онбординга (см. `onboarding.md`).
*   `/authChoice`, `/login`, `/register`: Аутентификация.
*   `/home`: Главный экран (Dashboard).
*   `/bottombar`: Основной контейнер с навигацией (Scaffold with BottomNavigationBar).
*   Функциональные маршруты: `/horoscope`, `/palmReader`, `/compatibility`, `/numerology`, `/natalchart`, `/astrologers` и их детальные экраны.

## Темизация и UI
**Файл:** `lib/theme/theme.dart` (предполагаемый)

В `main.dart` задана глобальная `ThemeData`:
*   **Font Family:** Roboto.
*   **Colors:** Основные цвета заданы через переменные (`primaryColor`, `scaffoldBgColor`). Используется темная тема (`Brightness.dark`).
*   **Styles:** Глобальные стили для `AppBar`, `BottomSheet`, `InputDecoration`.
*   **System UI:** Прозрачный статус-бар (`SystemUiOverlayStyle`).

## Локализация
Поддержка языков: English (`en`), Hindi (`hi`), Indonesian (`id`), Chinese (`zh`), Arabic (`ar`).
Используется `flutter_localizations`.

## Управление Состоянием
Используется гибридный подход:
1.  **Local State:** `setState` внутри `StatefulWidget` для UI-логики.
2.  **Services:** Синглтоны (или статические методы) в `lib/services/` для бизнес-логики и данных.
3.  **InheritedWidget / Provider:** (Не явно видно в `main.dart`, но возможно использование для DI, если потребуется).

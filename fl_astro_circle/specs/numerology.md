# Модуль: Numerology

**Responsibility:** Расчет нумерологических показателей по дате рождения и AI-интерпретация.
**Spec file:** `specs/numerology.md`

## Обзор
Модуль рассчитывает "Число Судьбы" (Life Path Number) и предоставляет психологический портрет пользователя, генерируемый AI.

## Экраны
*   **Ввод:** Выбор даты рождения (если не взята из профиля).
*   **Loading:** Экран генерации (`/numerologyLoading`).
*   **Результат:** Сводка traits и тизеры (`/numerologyResult`).
*   **Детали:** Подробное описание (`/numerologyDeepDetail`).

## Логика (NumerologyService)
**Файл:** `lib/pages/numorology/numorology_service.dart`

### 1. Расчет Числа Судьбы
Метод `calculateLifePathNumber(DateTime birthDate)`:
*   Суммируются цифры дня, месяца и года по отдельности.
*   Результат редуцируется до цифры 1-9 (с учетом мастер-чисел 11, 22, 33, хотя финальный вывод сводится к 1-9).

### 2. Генерация Отчета (AI)
Используется OpenRouter API.

**Базовый отчет (`generateNumerology`):**
*   Возвращает JSON с характеристиками (`traits`) в диапазоне 0.5-0.99.
*   3 коротких тизера ("About Character", "About Behavior", "About Responsibility").
*   Промпт требует стиль "желтой прессы" (Yellow-press / teaser headline energy), создающий интригу.

**Детальный отчет (`generateNumerologyDetail`):**
*   Генерируется по запросу для конкретной категории (Character, Behavior, Responsibility).
*   Требование: 4 параграфа (Паттерн, Скрытое напряжение, Реальные ситуации, Советы).
*   Стиль: Прямой, психологически точный, без "воды".

## Данные
Результат содержит:
*   `luckyNumber` (int)
*   `traits` (Map: funny, obedient, honest, responsible, hard_working, smart)
*   Текстовые описания.

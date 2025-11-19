# Настройка Firebase для аутентификации

## Шаги настройки:

### 1. Создание проекта Firebase

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Создайте новый проект или выберите существующий
3. Включите Authentication в разделе Build > Authentication
4. В разделе Sign-in method включите:
   - **Google** (для Android и iOS)
   - **Apple** (только для iOS)

### 2. Настройка для Android

1. В Firebase Console перейдите в Project Settings > Your apps
2. Добавьте Android приложение (если еще не добавлено)
3. Скачайте файл `google-services.json`
4. Поместите файл в `android/app/google-services.json`
5. Убедитесь, что в `android/build.gradle` добавлен:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Убедитесь, что в `android/app/build.gradle` добавлено в конец файла:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 3. Настройка для iOS

1. В Firebase Console перейдите в Project Settings > Your apps
2. Добавьте iOS приложение (если еще не добавлено)
   - Укажите Bundle ID вашего приложения (можно найти в `ios/Runner.xcodeproj`)
3. Скачайте файл `GoogleService-Info.plist`
4. **Важно для Flutter**: Поместите файл в `ios/Runner/GoogleService-Info.plist`
   - Можно перетащить файл в Xcode в папку Runner
   - Или скопировать файл напрямую в папку `ios/Runner/`
5. Убедитесь, что файл добавлен в Target Membership для Runner:
   - Откройте `ios/Runner.xcworkspace` в Xcode
   - Выберите `GoogleService-Info.plist` в Project Navigator
   - В File Inspector убедитесь, что отмечен чекбокс "Runner" в Target Membership

**Примечание**: Flutter использует CocoaPods для управления зависимостями Firebase. После добавления `GoogleService-Info.plist` выполните:
```bash
cd ios
pod install
cd ..
```

### 4. Настройка Sign in with Apple (только iOS)

**Требования**: iOS 13.0+ для Sign in with Apple

1. **В Apple Developer Console**:
   - Перейдите на [developer.apple.com](https://developer.apple.com)
   - Выберите Certificates, Identifiers & Profiles
   - Найдите ваш App ID (по Bundle ID)
   - Включите "Sign in with Apple" capability
   - Сохраните изменения

2. **В Firebase Console**:
   - Перейдите в Authentication > Sign-in method
   - Включите "Apple"
   - Нажмите "Configure" и добавьте OAuth client ID (если требуется)
   - Сохраните настройки

3. **В Xcode**:
   - Откройте `ios/Runner.xcworkspace` (важно: используйте `.xcworkspace`, а не `.xcodeproj`)
   - Выберите проект "Runner" в Project Navigator
   - Выберите target "Runner"
   - Перейдите на вкладку "Signing & Capabilities"
   - Нажмите "+ Capability"
   - Добавьте "Sign in with Apple"
   - Убедитесь, что Signing настроен правильно (Team выбран)

**Важно**: Sign in with Apple работает только на реальных устройствах или симуляторах с iOS 13+. На более старых версиях кнопка не будет отображаться.

### 5. Настройка Google Sign-In

#### Android:
1. В Firebase Console перейдите в Project Settings > Your apps > Android app
2. Скопируйте SHA-1 fingerprint одним из способов:

   **Способ 1: Через Gradle (требует настроенный JAVA_HOME)**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Найдите в выводе строку с `SHA1:` и скопируйте значение.

   **Способ 2: Через keytool (если JAVA_HOME не настроен)**
   
   На Windows:
   
   Сначала найдите путь к Java. Попробуйте один из вариантов:
   ```powershell
   # Вариант 1: Через Flutter (если установлен)
   flutter doctor -v
   # Найдите строку "Java binary at: ..."
   
   # Вариант 2: Поиск через стандартные пути
   $javaPath = Get-ChildItem "C:\Program Files\Java" -Recurse -Filter "keytool.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
   if ($javaPath) { Write-Host "Найден keytool: $javaPath" }
   
   # Вариант 3: Через Android Studio (если установлен)
   # Обычно находится в: C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe
   ```
   
   Затем используйте полный путь к keytool:
   ```powershell
   # Замените путь на найденный выше
   "C:\Program Files\Java\jdk-XX\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   
   # Или если Android Studio установлен:
   "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   
   На macOS/Linux:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   
   Найдите в выводе строку `SHA1:` и скопируйте значение (формат: `AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE`)

3. Добавьте SHA-1 в Firebase Console в разделе Your apps > Android app > SHA certificate fingerprints

#### iOS:
1. В Firebase Console перейдите в Project Settings > Your apps > iOS app
2. Убедитесь, что Bundle ID совпадает с вашим приложением

### 6. Установка зависимостей

После добавления конфигурационных файлов выполните:

```bash
# Установка Flutter зависимостей
flutter pub get

# Для iOS: установка CocoaPods зависимостей
# ВАЖНО: CocoaPods работает только на macOS. На Windows/Linux пропустите этот шаг.
# Если вы на macOS и CocoaPods не установлен:
#   sudo gem install cocoapods
# Затем:
cd ios
pod install
cd ..

# Для Android: убедитесь, что google-services.json на месте
# Gradle автоматически подхватит конфигурацию при следующей сборке
```

### 7. Запуск приложения

```bash
# Запуск на Android
flutter run

# Запуск на iOS (требует Mac и Xcode)
flutter run
```

## Проверка настройки

### Android
- Убедитесь, что файл `android/app/google-services.json` существует
- Проверьте, что в `android/app/build.gradle` есть `apply plugin: 'com.google.gms.google-services'`
- Проверьте, что в `android/build.gradle` есть `classpath 'com.google.gms:google-services:4.4.0'`

### iOS
- Убедитесь, что файл `ios/Runner/GoogleService-Info.plist` существует
- Проверьте, что в Xcode файл добавлен в Target Membership для Runner
- Убедитесь, что Sign in with Apple capability добавлена в Xcode

## Примечания:

- **Для Flutter проектов**: Firebase SDK управляется автоматически через FlutterFire плагины. Не нужно добавлять Firebase SDK вручную через Swift Package Manager или CocoaPods напрямую.
- **Для тестирования на эмуляторе Android**: Может потребоваться добавить SHA-1 fingerprint в Firebase Console
- **Apple Sign-In**: Работает только на реальных iOS устройствах или симуляторах с iOS 13+. На более старых версиях кнопка не будет отображаться.
- **Официальная документация**: [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) - для Flutter используйте [FlutterFire документацию](https://firebase.flutter.dev/)

## Решение проблем

### iOS: "GoogleService-Info.plist not found"
- Убедитесь, что файл находится в `ios/Runner/GoogleService-Info.plist`
- Проверьте Target Membership в Xcode
- Выполните `cd ios && pod install && cd ..`

### Android: "google-services.json not found"
- Убедитесь, что файл находится в `android/app/google-services.json`
- Проверьте, что в `android/app/build.gradle` добавлен плагин в конце файла

### Android: "JAVA_HOME is not set" при получении SHA-1
- **Решение 1**: Используйте альтернативный способ через `keytool` (см. шаг 5.2)
- **Решение 2**: Настройте JAVA_HOME:
  - Найдите путь к Java (обычно в `C:\Program Files\Java\jdk-XX` или через Android Studio)
  - В PowerShell выполните:
    ```powershell
    $env:JAVA_HOME = "C:\Program Files\Java\jdk-XX"  # замените на ваш путь
    ```
  - Или установите переменную окружения через System Properties > Environment Variables

### iOS: "pod: command not found" или "pod не распознано"
- **Важно**: CocoaPods работает только на macOS. На Windows/Linux вы не можете установить iOS зависимости.
- Если вы на macOS:
  - Установите CocoaPods: `sudo gem install cocoapods`
  - Проверьте установку: `pod --version`
  - Затем выполните `cd ios && pod install`
- Если вы на Windows/Linux:
  - Пропустите шаг `pod install` - он нужен только для сборки iOS приложения
  - iOS приложение можно собрать только на macOS с установленным Xcode
  - Для разработки Android приложения CocoaPods не требуется

### Ошибки аутентификации
- Проверьте, что в Firebase Console включены методы входа (Google и Apple)
- Для iOS: убедитесь, что Bundle ID совпадает в Firebase и Xcode
- Для Android: проверьте SHA-1 fingerprint в Firebase Console

## Разработка на Windows

### Apple Sign-In на Windows

**Важно**: Код для Apple Sign-In уже реализован и работает корректно. Кнопка Apple Sign-In автоматически показывается только на iOS устройствах (проверка `Platform.isIOS`).

**Что можно делать на Windows:**
- ✅ Писать и редактировать код (уже готово)
- ✅ Разрабатывать Android версию (Apple Sign-In не нужен)
- ✅ Тестировать Google Sign-In на Android эмуляторе
- ✅ Настраивать Firebase Console

**Что нужно сделать на macOS для финального тестирования:**
1. Открыть проект в Xcode (`ios/Runner.xcworkspace`)
2. Добавить capability "Sign in with Apple" в Xcode (см. шаг 4)
3. Выполнить `cd ios && pod install`
4. Запустить на iOS симуляторе или реальном устройстве
5. Протестировать Apple Sign-In

**Варианты для тестирования iOS без собственного Mac:**
- Использовать CI/CD (GitHub Actions, Codemagic и т.д.)
- Попросить коллегу/друга с Mac протестировать
- Использовать облачные Mac сервисы (MacStadium, MacinCloud)
- Для Android версии Apple Sign-In не требуется - всё работает на Windows



# Инструкция по установке и запуску

## Системные требования

- Windows 10/11 или Linux, MacOS
- Python 3.7 или выше
- pip (Python package manager)
- Минимум 2 ГБ свободного места на диске
- Стабильное интернет-соединение

## 1) Системные требования симуляции через Android:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio (рекомендуется для Android)
- Git

Проверьте окружение:

```bash
flutter doctor -v
```

Исправьте все ошибки, помеченные как `✗`.

## 2) Клонирование и установка зависимостей

```bash
git clone https://github.com/GarryFerstein/MobileAIChat.git
cd MobileAIChat
flutter pub get
```

## 3) Настройка Android Studio

1. Установите Android Studio: [developer.android.com/studio](https://developer.android.com/studio)
2. Откройте `Settings -> Plugins`, установите плагины `Flutter` и `Dart`.
3. Откройте `Settings -> Languages & Frameworks -> Android SDK` и убедитесь, что установлены:
   - Android SDK Platform (рекомендуется API 33+)
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools
4. Перейдите в `Tools -> Device Manager`, создайте эмулятор (например, Pixel + API 33/34) и запустите его.

## 4) Файл `.env`

Приложение использует ввод API ключа на экране авторизации, но файл `.env` должен существовать в проекте (он подключен как asset).

Создайте его:

```bash
cp .env.example .env
```

Допустимое содержимое:

```env
OPENROUTER_API_KEY=
BASE_URL=
MAX_TOKENS=1000
TEMPERATURE=0.7
```

`OPENROUTER_API_KEY` и `BASE_URL` можно оставить пустыми, так как ключ вводится при первом входе прямо в приложении.

## 5) Запуск через Android Studio (подробно)

1. Откройте проект в Android Studio (`File -> Open`).
2. Дождитесь индексации и синхронизации.
3. Убедитесь, что эмулятор запущен (`Device Manager`).
4. В верхнем селекторе устройства выберите эмулятор.
5. Запустите проект кнопкой `Run` (или `Shift+F10`).

Если хотите запуск через терминал:

```bash
flutter run
```

## 6) Как протестировать новый auth flow

После старта приложения:

1. На первом входе введите API ключ.
   - OpenRouter: начинается с `sk-or-v1-...`
   - VseGPT: начинается с sk-or-vv-...
2. Приложение проверит баланс через API.
3. Если ключ валиден и баланс > 0:
   - генерируется 4-значный PIN,
   - PIN и ключ сохраняются в локальную БД.
4. Закройте и заново откройте приложение:
   - появится экран ввода PIN.
5. Введите правильный PIN -> вход в чат.
6. Введите неверный PIN -> ошибка.
7. Нажмите `Сбросить ключ` -> повторный ввод нового API ключа.

## 7) Сборка APK

Debug APK:

```bash
flutter build apk --debug
```

Release APK:

```bash
flutter build apk --release
```

## 8) Запуск и тест на iOS (Xcode + Simulator)


1. Убедитесь, что установлены Xcode и Flutter:

```bash
xcode-select -p
xcodebuild -version
flutter doctor -v
```

2. Если iOS-папка отсутствует, создайте платформенные файлы:

```bash
flutter create .
```

3. Установите зависимости проекта и iOS pods:

```bash
flutter pub get
cd ios
pod install
cd ..
```

4. Запустите симулятор:

```bash
open -a Simulator
```

5. Проверьте, что Flutter видит устройство:

```bash
flutter devices
```

6. Запустите приложение:

```bash
flutter run -d ios
```

или по конкретному device id:

```bash
flutter run -d <DEVICE_ID>
```

7. Альтернативный запуск через Xcode:
   - Откройте `ios/Runner.xcworkspace`
   - Выберите target `Runner`
   - Выберите симулятор (например, iPhone 16)
   - Нажмите `Run` (`Cmd+R`)

## 9) Что проверить после запуска

1. Первый вход:
   - введите API ключ OpenRouter (`sk-or-v1-...`) или VseGPT;
   - приложение проверит баланс.
2. При валидном ключе и положительном балансе:
   - сгенерируется PIN из 4 цифр;
   - PIN и ключ сохраняются локально.
3. Перезапустите приложение:
   - должен открыться экран входа по PIN.
4. Проверьте:
   - правильный PIN -> вход;
   - неправильный PIN -> ошибка;
   - `Сбросить ключ` -> повторный ввод API ключа.

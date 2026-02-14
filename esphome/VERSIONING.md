# Версионирование конфигураций

## Что такое версионирование конфигураций?

**Версионирование конфигураций** - это система управления версиями ваших конфигурационных файлов ESPHome. Оно помогает:

- 📝 Отслеживать изменения в конфигурациях
- 🔄 Откатываться к предыдущим версиям при проблемах
- 📊 Понимать, какая версия прошивки установлена на устройстве
- 👥 Синхронизировать изменения между несколькими разработчиками
- 🐛 Находить, когда и почему была внесена конкретная настройка

## Текущее состояние

В вашем проекте уже есть базовая система версионирования:

### ✅ Что уже есть:

1. **Git репозиторий** - отслеживает все изменения
2. **fw_version в substitutions** - версия прошивки в каждом устройстве
3. **CHANGELOG.md** - документирование изменений
4. **text_sensor с версией** - отображение версии в Home Assistant

### Пример из вашего проекта:

```yaml
# config/auto-watering-system-1.yaml
substitutions:
  device_name: auto-watering-system-1
  static_ip: 192.168.1.176
  fw_version: "1.0.0"  # ← Версия прошивки

text_sensor:
  - platform: template
    name: "Версия"
    entity_category: diagnostic
    lambda: |-
      return {"${fw_version}"};
```

## Как улучшить версионирование?

### 1. Семантическое версионирование

Используйте формат **Semantic Versioning** (MAJOR.MINOR.PATCH):

- **MAJOR** (1.0.0 → 2.0.0): Критические изменения, несовместимые с предыдущими версиями
- **MINOR** (1.0.0 → 1.1.0): Новые функции, обратно совместимые
- **PATCH** (1.0.0 → 1.0.1): Исправления ошибок, обратно совместимые

**Примеры:**
```yaml
fw_version: "1.0.0"  # Первая версия
fw_version: "1.0.1"  # Исправление бага
fw_version: "1.1.0"  # Добавлен новый сенсор
fw_version: "2.0.0"  # Полная переработка конфигурации
```

### 2. Git теги для версий

Создавайте теги в Git при выпуске новых версий:

```bash
# Создать тег для конкретного устройства
git tag -a "auto-watering-system-1-v1.0.1" -m "Исправлена обработка NaN значений"

# Создать тег для всего проекта
git tag -a "v1.0.0" -m "Первая стабильная версия проекта"

# Просмотр тегов
git tag -l

# Просмотр изменений между версиями
git diff auto-watering-system-1-v1.0.0..auto-watering-system-1-v1.0.1
```

### 3. Автоматическое обновление версий

Создайте скрипт для автоматического обновления версий:

```bash
#!/bin/bash
# update-version.sh - Обновление версии конфигурации

DEVICE=$1
NEW_VERSION=$2

if [ -z "$DEVICE" ] || [ -z "$NEW_VERSION" ]; then
    echo "Использование: ./update-version.sh <device-name> <new-version>"
    echo "Пример: ./update-version.sh auto-watering-system-1 1.0.1"
    exit 1
fi

CONFIG_FILE="config/${DEVICE}.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Файл не найден: $CONFIG_FILE"
    exit 1
fi

# Обновить версию в файле
sed -i "s/fw_version: \".*\"/fw_version: \"${NEW_VERSION}\"/" "$CONFIG_FILE"

echo "✅ Версия обновлена до ${NEW_VERSION} в $CONFIG_FILE"
echo "📝 Не забудьте:"
echo "   1. Проверить конфигурацию: ./validate-configs.sh $CONFIG_FILE"
echo "   2. Закоммитить изменения: git add $CONFIG_FILE"
echo "   3. Создать тег: git tag -a \"${DEVICE}-v${NEW_VERSION}\" -m \"Версия ${NEW_VERSION}\""
```

### 4. Расширенный CHANGELOG

Ведите детальный CHANGELOG для каждого устройства:

```markdown
# CHANGELOG.md

## [1.0.1] - 2025-01-22

### auto-watering-system-1
- Исправлена обработка NaN значений в датчике влажности
- Добавлена защита от деления на ноль

### garage-gate-distance
- Исправлена опечатка "Closeing" → "Closing"
- Улучшена обработка отсутствующих данных

## [1.0.0] - 2025-01-20

### auto-watering-system-1
- Первая версия
- Добавлен датчик влажности почвы
- Добавлено управление насосом
```

### 5. Версионирование в Home Assistant

Отображайте версию в Home Assistant для мониторинга:

```yaml
# Уже есть в ваших конфигурациях:
text_sensor:
  - platform: template
    name: "Версия"
    entity_category: diagnostic
    lambda: |-
      return {"${fw_version}"};
```

Можно добавить дату сборки:

```yaml
substitutions:
  fw_version: "1.0.1"
  build_date: "2025-01-22"

text_sensor:
  - platform: template
    name: "Версия"
    lambda: |-
      return {"${fw_version} (${build_date})"};
```

### 6. Резервное копирование версий

Используйте директорию `config/archive/` для старых версий:

```bash
# Архивировать старую версию
mkdir -p config/archive
cp config/auto-watering-system-1.yaml config/archive/auto-watering-system-1-v1.0.0.yaml
```

### 7. Проверка версий перед обновлением

Добавьте проверку версий в скрипт валидации:

```bash
# В validate-configs.sh можно добавить:
echo "📋 Версии устройств:"
for config in $CONFIGS; do
    version=$(grep "fw_version:" "$config" | head -1 | sed 's/.*fw_version: "\(.*\)".*/\1/')
    device=$(basename "$config" .yaml)
    echo "  - $device: v$version"
done
```

## Рекомендуемый workflow

### При изменении конфигурации:

1. **Обновите версию** в файле конфигурации:
   ```yaml
   fw_version: "1.0.1"  # PATCH для исправлений
   ```

2. **Проверьте конфигурацию**:
   ```bash
   ./validate-configs.sh device-name.yaml
   ```

3. **Закоммитьте изменения**:
   ```bash
   git add config/device-name.yaml
   git commit -m "device-name: v1.0.1 - Исправлена обработка ошибок"
   ```

4. **Создайте тег** (для важных версий):
   ```bash
   git tag -a "device-name-v1.0.1" -m "Версия 1.0.1"
   ```

5. **Обновите CHANGELOG.md**:
   ```markdown
   ## [1.0.1] - 2025-01-22
   ### device-name
   - Исправлена обработка ошибок
   ```

6. **Обновите устройство через OTA**:
   - Откройте ESPHome Dashboard
   - Выберите устройство
   - Нажмите "INSTALL" → "Wirelessly (OTA)"

## Примеры версионирования

### Пример 1: Исправление бага

```yaml
# Было: fw_version: "1.0.0"
# Стало: fw_version: "1.0.1"
# Причина: Исправлена обработка NaN значений
```

### Пример 2: Добавление нового сенсора

```yaml
# Было: fw_version: "1.0.0"
# Стало: fw_version: "1.1.0"
# Причина: Добавлен датчик температуры
```

### Пример 3: Критическое изменение

```yaml
# Было: fw_version: "1.0.0"
# Стало: fw_version: "2.0.0"
# Причина: Изменен формат конфигурации, требуется перепрошивка
```

## Полезные команды Git

```bash
# Просмотр истории изменений файла
git log config/auto-watering-system-1.yaml

# Просмотр изменений в конкретной версии
git show device-name-v1.0.1

# Сравнение версий
git diff device-name-v1.0.0..device-name-v1.0.1 config/device-name.yaml

# Откат к предыдущей версии
git checkout device-name-v1.0.0 -- config/device-name.yaml

# Список всех тегов
git tag -l "*-v*"
```

## Автоматизация

Можно создать GitHub Actions или GitLab CI для:
- Автоматической валидации при коммитах
- Создания тегов при изменении версий
- Генерации CHANGELOG из коммитов
- Автоматического резервного копирования

## Рекомендации

1. **Всегда обновляйте версию** при изменении конфигурации
2. **Используйте семантическое версионирование** для понятности
3. **Документируйте изменения** в CHANGELOG.md
4. **Создавайте теги** для стабильных версий
5. **Проверяйте конфигурацию** перед коммитом
6. **Тестируйте на одном устройстве** перед массовым обновлением

## Полезные ссылки

- [Semantic Versioning](https://semver.org/)
- [Git Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
- [ESPHome Version Component](https://esphome.io/components/text_sensor/version.html)

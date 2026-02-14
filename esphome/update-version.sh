#!/usr/bin/env bash
# Скрипт для обновления версии конфигурации устройства
# Использование: ./update-version.sh <device-name> <new-version>
# Пример: ./update-version.sh auto-watering-system-1 1.0.1

set -e

DEVICE=$1
NEW_VERSION=$2

if [ -z "$DEVICE" ] || [ -z "$NEW_VERSION" ]; then
    echo "❌ Ошибка: не указаны параметры"
    echo ""
    echo "Использование: ./update-version.sh <device-name> <new-version>"
    echo ""
    echo "Примеры:"
    echo "  ./update-version.sh auto-watering-system-1 1.0.1"
    echo "  ./update-version.sh garage-gate-distance 1.1.0"
    echo "  ./update-version.sh presence-1 2.0.0"
    echo ""
    echo "Формат версии: MAJOR.MINOR.PATCH (например, 1.0.1)"
    exit 1
fi

# Проверка формата версии (простая проверка)
if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Ошибка: неверный формат версии"
    echo "Используйте формат: MAJOR.MINOR.PATCH (например, 1.0.1)"
    exit 1
fi

CONFIG_FILE="config/${DEVICE}.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Файл не найден: $CONFIG_FILE"
    echo ""
    echo "Доступные устройства:"
    find config -maxdepth 1 -name "*.yaml" -not -name "secrets.yaml" | sed 's|config/||' | sed 's|\.yaml||' | sort
    exit 1
fi

# Получить текущую версию
OLD_VERSION=$(grep "fw_version:" "$CONFIG_FILE" | head -1 | sed 's/.*fw_version: "\(.*\)".*/\1/' || echo "не найдена")

if [ -z "$OLD_VERSION" ] || [ "$OLD_VERSION" = "не найдена" ]; then
    echo "⚠️  Предупреждение: текущая версия не найдена в файле"
    OLD_VERSION="неизвестна"
fi

echo "📝 Обновление версии для устройства: $DEVICE"
echo "   Текущая версия: $OLD_VERSION"
echo "   Новая версия:   $NEW_VERSION"
echo ""

# Обновить версию в файле
if sed -i "s/fw_version: \".*\"/fw_version: \"${NEW_VERSION}\"/" "$CONFIG_FILE"; then
    echo "✅ Версия обновлена в $CONFIG_FILE"
else
    echo "❌ Ошибка при обновлении версии"
    exit 1
fi

# Проверить, что версия действительно обновлена
VERIFIED_VERSION=$(grep "fw_version:" "$CONFIG_FILE" | head -1 | sed 's/.*fw_version: "\(.*\)".*/\1/')
if [ "$VERIFIED_VERSION" = "$NEW_VERSION" ]; then
    echo "✅ Версия подтверждена: $VERIFIED_VERSION"
else
    echo "⚠️  Предупреждение: версия в файле ($VERIFIED_VERSION) не совпадает с ожидаемой ($NEW_VERSION)"
fi

echo ""
echo "📋 Следующие шаги:"
echo "   1. Проверить конфигурацию:"
echo "      ./validate-configs.sh $CONFIG_FILE"
echo ""
echo "   2. Просмотреть изменения:"
echo "      git diff $CONFIG_FILE"
echo ""
echo "   3. Закоммитить изменения:"
echo "      git add $CONFIG_FILE"
echo "      git commit -m \"$DEVICE: v$NEW_VERSION - Описание изменений\""
echo ""
echo "   4. (Опционально) Создать тег:"
echo "      git tag -a \"$DEVICE-v$NEW_VERSION\" -m \"Версия $NEW_VERSION для $DEVICE\""
echo ""
echo "   5. Обновить CHANGELOG.md с описанием изменений"

#!/usr/bin/env bash
# Скрипт для валидации конфигураций ESPHome

set -e

echo "🔍 Проверка конфигураций ESPHome..."

# Проверка наличия secrets.yaml
if [ ! -f "config/secrets.yaml" ]; then
    echo "⚠️  ВНИМАНИЕ: config/secrets.yaml не найден!"
    echo "   Создайте его на основе config/secrets.yaml.example"
    exit 1
fi

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен"
    exit 1
fi

# Проверка запущенного контейнера
if ! docker ps | grep -q esphome; then
    echo "⚠️  ESPHome контейнер не запущен. Запускаю..."
    ./esphome-up
    sleep 3
fi

# Валидация всех конфигураций
ERRORS=0
CONFIGS=$(find config -name "*.yaml" -not -name "secrets.yaml" -not -path "config/.esphome/*" -not -path "config/archive/*")

for config in $CONFIGS; do
    echo -n "Проверка $config... "
    if docker exec esphome esphome config "$config" > /dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ ОШИБКА"
        docker exec esphome esphome config "$config" 2>&1 | head -20
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $ERRORS -eq 0 ]; then
    echo ""
    echo "✅ Все конфигурации валидны!"
    exit 0
else
    echo ""
    echo "❌ Найдено ошибок: $ERRORS"
    exit 1
fi

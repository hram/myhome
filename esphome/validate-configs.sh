#!/usr/bin/env bash
# Скрипт для валидации конфигураций ESPHome
# Использование: ./validate-configs.sh [файл.yaml]
# Если указан файл, валидируется только он, иначе - все конфигурации

set -e

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

# Если передан аргумент, валидируем только указанный файл
if [ $# -gt 0 ]; then
    CONFIG_FILE="$1"
    if [[ ! "$CONFIG_FILE" =~ ^config/.*\.yaml$ ]]; then
        if [[ "$CONFIG_FILE" =~ \.yaml$ ]]; then
            CONFIG_FILE="config/$CONFIG_FILE"
        else
            CONFIG_FILE="config/${CONFIG_FILE}.yaml"
        fi
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ Файл не найден: $CONFIG_FILE"
        exit 1
    fi
    
    echo "🔍 Проверка конфигурации: $CONFIG_FILE..."
    CONFIGS="$CONFIG_FILE"
else
    echo "🔍 Проверка всех конфигураций ESPHome..."
    # Валидация всех конфигураций
    # Ищем только конфигурационные файлы устройств, исключая служебные директории
    # Ищем только в корне config/ и в config/devices/, исключая все скрытые директории
    CONFIGS=$(find config -maxdepth 2 -name "*.yaml" \
        -not -name "secrets.yaml" \
        -not -path "config/.esphome/*" \
        -not -path "config/.cache/*" \
        -not -path "config/.platformio/*" \
        -not -path "config/.local/*" \
        -not -path "config/archive/*" \
        -not -path "config/common/*" \
        -not -path "*/.*" \
        -type f | sort)
fi

ERRORS=0
TOTAL=0

for config in $CONFIGS; do
    TOTAL=$((TOTAL + 1))
    # Преобразуем путь: config/file.yaml -> file.yaml (для работы из /config в контейнере)
    config_name="${config#config/}"
    if [ $# -eq 0 ]; then
        echo -n "[$TOTAL] "
    fi
    echo -n "Проверка $config_name... "
    if docker exec -w /config esphome esphome config "$config_name" > /dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ ОШИБКА"
        docker exec -w /config esphome esphome config "$config_name" 2>&1 | grep -E "(ERROR|WARNING|Failed)" | head -10
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
if [ $ERRORS -eq 0 ]; then
    if [ $# -eq 0 ]; then
        echo "✅ Все конфигурации валидны! (проверено: $TOTAL)"
    else
        echo "✅ Конфигурация валидна!"
    fi
    exit 0
else
    if [ $# -eq 0 ]; then
        echo "❌ Найдено ошибок: $ERRORS из $TOTAL"
    else
        echo "❌ Конфигурация содержит ошибки!"
    fi
    exit 1
fi

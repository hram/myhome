# Changelog

Все значимые изменения в проекте будут документироваться в этом файле.

## [Unreleased]

### Добавлено
- README.md с полной документацией проекта
- secrets.yaml.example как шаблон для настройки
- .gitignore в корне проекта для защиты секретов
- validate-configs.sh скрипт для валидации конфигураций
- DEVICES.md с документацией по устройствам
- common/mqtt_base.yaml для MQTT интеграции
- Healthcheck в docker-compose.yml

### Исправлено
- Опечатка "Closeing" → "Closing" в garage-gate-distance.yaml
- Улучшена обработка ошибок в конфигурациях:
  - Проверки на NaN значения
  - Проверки наличия состояния сенсоров
  - Защита от деления на ноль
  - Обработка отсутствующих данных

### Улучшено
- Обработка ошибок в auto-watering-system-1.yaml
- Обработка ошибок в garage-gate-distance.yaml
- Обработка ошибок в septic-monitor.yaml
- Обработка ошибок в garage-car-evgen.yaml
- Docker Compose конфигурация с healthcheck

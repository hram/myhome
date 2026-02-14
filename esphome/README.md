# ESPHome Home Automation Project

Проект управления IoT устройствами на базе ESP8266/ESP32 через ESPHome.

## 📋 Описание

Этот проект содержит конфигурации для различных умных устройств в доме:
- Датчики присутствия
- Система автополива
- Мониторинг гаража и ворот
- Аварийные сигнализации
- Мониторинг септика
- И другие устройства

## 🚀 Быстрый старт

### Требования

- Docker и Docker Compose
- Доступ к WiFi сети
- MQTT брокер (опционально, для интеграции с Home Assistant)

### Установка

1. Клонируйте репозиторий:
```bash
cd /home/hram/myhome/esphome
```

2. Настройте секреты:
```bash
cp config/secrets.yaml.example config/secrets.yaml
nano config/secrets.yaml  # Заполните реальными значениями
```

3. Запустите ESPHome Dashboard:
```bash
./esphome-up
```

4. Откройте в браузере: http://localhost:6052

### Остановка

```bash
./esphome-down
```

## 📁 Структура проекта

```
esphome/
├── docker-compose.yml          # Docker конфигурация
├── esphome-up                  # Скрипт запуска
├── esphome-down                # Скрипт остановки
├── .gitignore                 # Игнорируемые файлы
├── README.md                   # Документация
└── config/
    ├── secrets.yaml            # Секреты (НЕ коммитить в git!)
    ├── secrets.yaml.example    # Шаблон секретов
    ├── common/                 # Общие конфигурации
    │   ├── wifi_base.yaml      # Базовая WiFi конфигурация
    │   ├── api.yaml            # API для Home Assistant
    │   ├── ota.yaml            # OTA обновления
    │   ├── logger.yaml         # Настройки логирования
    │   ├── diagnostics_*.yaml  # Диагностика устройств
    │   ├── climate_dht.yaml    # DHT датчики
    │   └── status_led_heartbeat.yaml  # Индикатор статуса
    └── [устройства].yaml       # Конфигурации устройств
```

## 🔧 Устройства

### Автополив (`auto-watering-system-1.yaml`)
- **Платформа**: ESP8266 (D1 Mini)
- **Функции**: 
  - Датчик влажности почвы (емкостной)
  - Управление насосом через MOSFET
  - Автоматический полив на 5 секунд
- **IP**: 192.168.1.176

### Датчик присутствия (`presence-1.yaml`)
- **Платформа**: ESP32-C3 (Lolin C3 Mini)
- **Функции**:
  - Радар LD2410
  - GPIO датчик присутствия
- **IP**: 192.168.1.181

### Ворота гаража (`garage-gate-distance.yaml`)
- **Платформа**: ESP8266 (D1 Mini)
- **Функции**:
  - Датчик расстояния VL53L0X
  - Определение открытия/закрытия ворот
  - Настраиваемые пороги
- **IP**: 192.168.1.183

### Аварийная сирена (`bed-alarm.yaml`)
- **Платформа**: ESP8266 (D1 Mini)
- **Функции**:
  - Зуммер
  - WS2812 LED индикация
  - Кнопка отключения звука
  - DHT датчик температуры/влажности
- **IP**: 192.168.1.180

### Монитор септика (`septic-monitor.yaml`)
- **Платформа**: ESP8266 (D1 Mini)
- **Функции**:
  - Датчик освещённости BH1750
  - Определение аварийного состояния
- **IP**: 192.168.1.175

### Другие устройства
- `baxi-monitor.yaml` - Монитор котла
- `garage-car-evgen.yaml`, `garage-car-olga.yaml` - Датчики парковки
- `garage-went.yaml` - Вентиляция гаража
- `m5stack-atom-echo.yaml` - M5Stack устройство
- `rf-receiver-433.yaml` - Приёмник 433 МГц
- `septic-water-level.yaml` - Уровень воды в септике
- `stair-pir-bottom.yaml`, `stair-pir-top.yaml` - PIR датчики на лестнице

## 🔐 Безопасность

⚠️ **ВАЖНО**: Файл `config/secrets.yaml` содержит пароли и секреты. Он уже добавлен в `.gitignore` и не должен попадать в git.

Для генерации безопасных паролей используйте:
```bash
# OTA пароль
openssl rand -hex 16

# API пароль
openssl rand -hex 16
```

## 📡 Сеть

- **Шлюз**: 192.168.1.1
- **Подсеть**: 192.168.1.0/24
- **MQTT брокер**: 192.168.1.96
- **ESPHome Dashboard**: localhost:6052

Все устройства используют статические IP адреса для стабильной работы.

## 🔄 Обновление прошивок

1. Откройте ESPHome Dashboard: http://localhost:6052
2. Выберите устройство
3. Нажмите "INSTALL" → "Wirelessly (OTA)"
4. Дождитесь завершения обновления

## 🛠️ Разработка

### Добавление нового устройства

1. Создайте новый YAML файл в `config/`
2. Используйте общие пакеты из `config/common/`
3. Укажите уникальный статический IP
4. Добавьте описание в этот README

### Структура конфигурации устройства

```yaml
substitutions:
  device_name: my-device
  static_ip: 192.168.1.XXX
  fw_version: "1.0.0"

esphome:
  name: ${device_name}
  friendly_name: "Описание устройства"

packages:
  wifi: !include common/wifi_base.yaml
  api: !include common/api.yaml
  ota: !include common/ota.yaml
  logger: !include common/logger.yaml
  diagnostics: !include common/diagnostics_esp8266.yaml

esp8266:
  board: d1_mini

# Ваши сенсоры, переключатели и т.д.
```

## 📝 Логи

Логи доступны через Docker:
```bash
docker logs esphome
```

Или в реальном времени:
```bash
docker logs -f esphome
```

## 🐛 Устранение неполадок

### Устройство не подключается к WiFi
- Проверьте настройки в `secrets.yaml`
- Убедитесь, что IP адрес не занят
- Проверьте логи устройства

### OTA обновление не работает
- Проверьте пароль OTA в `secrets.yaml`
- Убедитесь, что устройство в той же сети
- Проверьте версию прошивки (OTA работает только с версиями ESPHome)

### Проблемы с MQTT
- Проверьте доступность брокера: `ping 192.168.1.96`
- Проверьте логин/пароль в `secrets.yaml`
- Убедитесь, что брокер запущен

## 📚 Полезные ссылки

- [ESPHome документация](https://esphome.io/)
- [ESPHome компоненты](https://esphome.io/components/index.html)
- [Home Assistant интеграция](https://www.home-assistant.io/integrations/esphome/)

## 📄 Лицензия

Личное использование.

## 👤 Автор

Проект для домашней автоматизации.

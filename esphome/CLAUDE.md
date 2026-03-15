# ESPHome Home Automation Project

## Обзор проекта
Домашняя автоматизация на ESPHome. Управляет IoT-устройствами (ESP8266/ESP32) через Docker-контейнер.

- **ESPHome Dashboard:** http://localhost:6052
- **Запуск/остановка:** `./esphome-up` / `./esphome-down`
- **Валидация конфигов:** `./validate-configs.sh`
- **Обновление версий:** `./update-version.sh`
- **Язык общения:** русский

## Структура
```
config/
  *.yaml          # конфигурации устройств (15+)
  common/         # переиспользуемые пакеты
  secrets.yaml    # секреты (не в git, шаблон: secrets.yaml.example)
*.md              # документация
docker-compose.yml
```

## Общие пакеты (config/common/)
| Файл | Назначение |
|---|---|
| `wifi_base.yaml` | Статический IP, fallback AP |
| `api.yaml` | Home Assistant native API |
| `ota.yaml` | OTA обновления |
| `logger.yaml` | INFO уровень, baud_rate: 0 |
| `diagnostics_esp8266.yaml` | Диагностика для ESP8266 |
| `diagnostics_esp32.yaml` | Диагностика для ESP32 |
| `climate_dht.yaml` | DHT11 (параметризованный) |
| `mqtt_base.yaml` | MQTT с HA discovery |
| `status_led_heartbeat.yaml` | Heartbeat LED на GPIO2 |

## Устройства
| Устройство | IP | Платформа | Назначение |
|---|---|---|---|
| baxi-monitor | 192.168.1.70 | ESP8266 | Котёл отопления |
| atom-echo | 192.168.1.137 | ESP32 | Голосовой ассистент |
| garage-car-evgen | 192.168.1.172 | ESP8266 | Парковка 1 |
| garage-car-olga | 192.168.1.174 | ESP8266 | Парковка 2 |
| septic-monitor | 192.168.1.175 | ESP8266 | Аварийная сигнализация септика |
| auto-watering-system-1 | 192.168.1.176 | ESP8266 | Автополив |
| rf-receiver-433 | 192.168.1.177 | ESP8266 | Приёмник 433 МГц |
| stair-pir-bottom | 192.168.1.178 | ESP8266 | Движение (низ лестницы) |
| stair-pir-top | 192.168.1.179 | ESP8266 | Движение (верх лестницы) |
| bed-alarm | 192.168.1.180 | ESP8266 | Аварийная сирена (пьезо + WS2812) |
| presence-1 | 192.168.1.181 | ESP32-C3 | Детектор присутствия LD2410 |
| garage-went | 192.168.1.182 | ESP8266 | Вентиляция гаража |
| garage-gate-distance | 192.168.1.183 | ESP8266 | Датчик расстояния ворот (VL53L0X) |
| septic-water-level | 192.168.1.184 | ESP8266 | Уровень воды в септике |
| presence-test | 192.168.1.200 | ESP8266 | Тестовый датчик присутствия |

## Сеть
- Подсеть: 192.168.1.0/24, шлюз: 192.168.1.1
- MQTT broker: 192.168.1.96
- Все устройства — статические IP

## Шаблон конфигурации устройства
```yaml
substitutions:
  device_name: my-device
  friendly_name: "My Device"
  static_ip: 192.168.1.XXX
  fw_version: "1.0.0"

esphome:
  name: ${device_name}
  friendly_name: ${friendly_name}

packages:
  wifi: !include common/wifi_base.yaml
  api: !include common/api.yaml
  ota: !include common/ota.yaml
  logger: !include common/logger.yaml
  diagnostics: !include common/diagnostics_esp8266.yaml  # или esp32

esp8266:
  board: esp01_1m
```

## Важные соглашения
- Секреты: `wifi_ssid`, `wifi_password`, `api_password`, `ota_password`, `mqtt_broker`, `mqtt_user`, `mqtt_pass`
- В lambda всегда проверять `.has_state()` и `isnan()` перед использованием значений сенсоров
- Версионирование: семантическое (`fw_version` в substitutions), теги в git
- Документация устройств: `config/DEVICES.md`

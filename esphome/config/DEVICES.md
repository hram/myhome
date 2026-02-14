# Список устройств

Документация по всем устройствам в проекте.

## 📍 IP адреса устройств

| Устройство | IP адрес | Платформа | Описание |
|-----------|----------|-----------|----------|
| auto-watering-system-1 | 192.168.1.176 | ESP8266 | Автополив фикуса |
| bed-alarm | 192.168.1.180 | ESP8266 | Аварийная сирена у кровати |
| presence-1 | 192.168.1.181 | ESP32-C3 | Датчик присутствия 1 |
| garage-gate-open | 192.168.1.183 | ESP8266 | Ворота статус |
| septic-monitor | 192.168.1.175 | ESP8266 | Септик авария |
| garage-car-evgen | 192.168.1.172 | ESP8266 | Парковка 1 |
| rf-receiver-433 | 192.168.1.177 | ESP8266 | Приемник команд 433 МГц |
| septic-water-level | 192.168.1.184 | ESP8266 | Септик уровень воды |

## 🔧 Общие компоненты

### WiFi (`common/wifi_base.yaml`)
- Статический IP адрес
- Fallback AP режим
- Настройки из `secrets.yaml`

### API (`common/api.yaml`)
- Интеграция с Home Assistant
- Пароль из `secrets.yaml`

### OTA (`common/ota.yaml`)
- Обновления по воздуху
- Пароль из `secrets.yaml`

### Logger (`common/logger.yaml`)
- Уровень логирования: INFO
- Отключен serial вывод (baud_rate: 0)

### Диагностика
- `common/diagnostics_esp8266.yaml` - для ESP8266
- `common/diagnostics_esp32.yaml` - для ESP32
- Включает: uptime, WiFi RSSI, Free Heap, версия ESPHome, IP адрес

### Status LED (`common/status_led_heartbeat.yaml`)
- Индикатор подключения к API
- Мигает каждые 5 секунд при подключении

## 📝 Примечания

- Все устройства используют статические IP адреса
- OTA обновления требуют пароль из `secrets.yaml`
- API пароль должен совпадать с настройками Home Assistant

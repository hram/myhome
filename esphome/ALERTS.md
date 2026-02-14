# Система алертов и уведомлений

## Что такое алерты?

**Алерты** - это автоматические уведомления о проблемах с устройствами ESPHome. Они помогают быстро узнать о:
- Недоступности устройств (потеря связи)
- Проблемах с WiFi (слабый сигнал, отключение)
- Критических значениях сенсоров (например, авария септика)
- Низкой памяти устройства
- Ошибках в работе датчиков

## Как это работает?

Алерты работают на двух уровнях:

### 1. На уровне ESPHome (в устройствах)
Создаются `binary_sensor` с `device_class: problem`, которые автоматически определяют проблемы.

### 2. На уровне Home Assistant
Создаются автоматизации, которые отслеживают эти сенсоры и отправляют уведомления (Telegram, email, push-уведомления и т.д.).

## Примеры реализации

### Пример 1: Алерт о слабом WiFi сигнале

Уже есть в `common/diagnostics_esp8266.yaml` - сенсор "WiFi качество". Можно добавить бинарный сенсор для алерта:

```yaml
# В common/diagnostics_esp8266.yaml можно добавить:
binary_sensor:
  - platform: template
    name: "${device_name} WiFi Проблема"
    device_class: problem
    lambda: |-
      if (!id(wifi_rssi).has_state()) {
        return true;  // Нет данных = проблема
      }
      float rssi = id(wifi_rssi).state;
      return rssi < -80;  // Сигнал хуже -80 dBm = проблема
```

### Пример 2: Алерт о низкой памяти

```yaml
binary_sensor:
  - platform: template
    name: "${device_name} Низкая память"
    device_class: problem
    lambda: |-
      return ESP.getFreeHeap() < 10000;  // Меньше 10KB = проблема
```

### Пример 3: Алерт о недоступности устройства

В Home Assistant создается автоматизация, которая отслеживает статус устройства:

```yaml
# В Home Assistant (automations.yaml):
- alias: "ESPHome устройство недоступно"
  trigger:
    - platform: state
      entity_id: binary_sensor.device_name_status
      to: 'off'
      for:
        minutes: 2
  action:
    - service: notify.telegram
      data:
        message: "⚠️ Устройство {{ trigger.to_state.attributes.friendly_name }} недоступно!"
```

### Пример 4: Алерт о критических значениях

Уже реализовано в `septic-monitor.yaml`:
- Сенсор "Авария септика" с `device_class: problem`
- Автоматически определяет проблему по уровню освещённости

### Пример 5: Алерт о проблемах с датчиками

```yaml
binary_sensor:
  - platform: template
    name: "${device_name} Проблема датчика"
    device_class: problem
    lambda: |-
      // Проверяем, что датчик не отвечает слишком долго
      if (!id(main_sensor).has_state()) {
        return true;
      }
      // Проверяем на NaN или нереальные значения
      float value = id(main_sensor).state;
      if (isnan(value) || value < -100 || value > 200) {
        return true;
      }
      return false;
```

## Готовый компонент для алертов

Можно создать общий компонент `common/alerts.yaml`:

```yaml
# common/alerts.yaml
# Общие алерты для всех устройств

binary_sensor:
  # Проблема с WiFi
  - platform: template
    name: "${device_name} WiFi Проблема"
    device_class: problem
    lambda: |-
      if (!id(wifi_rssi).has_state()) {
        return true;
      }
      float rssi = id(wifi_rssi).state;
      return rssi < -80;  # Сигнал хуже -80 dBm

  # Низкая память
  - platform: template
    name: "${device_name} Низкая память"
    device_class: problem
    lambda: |-
      return ESP.getFreeHeap() < 10000;  # Меньше 10KB

  # Устройство не отвечает (определяется в Home Assistant)
  - platform: status
    name: "${device_name} Статус"
    # Этот сенсор уже есть в diagnostics, но можно использовать для алертов
```

## Настройка уведомлений в Home Assistant

### 1. Через Telegram

```yaml
# configuration.yaml
notify:
  - platform: telegram
    name: telegram
    api_key: YOUR_BOT_TOKEN
    chat_id: YOUR_CHAT_ID

# automations.yaml
- alias: "Алерт: Проблема с устройством"
  trigger:
    - platform: state
      entity_id: binary_sensor.*_wifi_проблема
      to: 'on'
  action:
    - service: notify.telegram
      data:
        message: "⚠️ Проблема с WiFi: {{ states[trigger.entity_id].attributes.friendly_name }}"
```

### 2. Через Push-уведомления (Mobile App)

```yaml
- alias: "Алерт: Устройство недоступно"
  trigger:
    - platform: state
      entity_id: binary_sensor.*_status
      to: 'off'
      for:
        minutes: 5
  action:
    - service: notify.mobile_app_phone
      data:
        title: "⚠️ Устройство недоступно"
        message: "{{ states[trigger.entity_id].attributes.friendly_name }} не отвечает уже 5 минут"
        data:
          priority: high
```

### 3. Через Email

```yaml
- alias: "Алерт: Критическая проблема"
  trigger:
    - platform: state
      entity_id: binary_sensor.septic_monitor_авария_септика
      to: 'on'
  action:
    - service: notify.email
      data:
        title: "🚨 Авария септика!"
        message: "Обнаружена аварийная ситуация в септике"
```

## Рекомендации

1. **Не спамить**: Используйте задержки (`for:`) чтобы не получать уведомления при кратковременных проблемах
2. **Приоритеты**: Разделите алерты на критичные и информационные
3. **Группировка**: Создайте группу всех алертов в Home Assistant для удобного мониторинга
4. **Логирование**: Включите логирование алертов для анализа проблем

## Пример группы в Home Assistant

```yaml
# groups.yaml
alerts:
  name: Алерты устройств
  entities:
    - binary_sensor.auto_watering_system_1_wifi_проблема
    - binary_sensor.septic_monitor_авария_септика
    - binary_sensor.garage_gate_open_status
    - binary_sensor.*_низкая_память
```

## Полезные ссылки

- [ESPHome binary_sensor](https://esphome.io/components/binary_sensor/index.html)
- [Home Assistant Automations](https://www.home-assistant.io/docs/automation/)
- [Home Assistant Notifications](https://www.home-assistant.io/integrations/notify/)

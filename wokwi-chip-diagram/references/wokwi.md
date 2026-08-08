## Overview

Wokwi simulation projects use two files:
- `diagram.json` — defines the circuit (parts and connections)
- `wokwi.toml` — configures firmware paths and simulator settings

This reference focuses on `diagram.json` for projects using the **ESP32-C3-DevKitM-1** board.

## Common Parts Reference

### wokwi-led (Standard 5mm LED)
```json
{
  "id": "led1",
  "type": "wokwi-led",
  "left": 100,
  "top": 50,
  "attrs": { "color": "red", "label": "Status" }
}
```
**Pins:** A (anode/+), C (cathode/-)

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `color` | LED body color | `"red"` |
| `lightColor` | LED light color; defaults to a value based on `color` | Depends on `color` |
| `label` | Text shown below the LED | `""` |
| `gamma` | Gamma correction factor | `"2.8"` |
| `flip` | Flips the LED horizontally when set | `""` |
| `fps` | LED brightness update frame rate | `"80"` |

### wokwi-resistor
```json
{
  "id": "r1",
  "type": "wokwi-resistor",
  "left": 100,
  "top": 50,
  "attrs": { "value": "1000", "unit": "\u03a9" }
}
```
**Pins:** 1, 2

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `value` | Resistance in ohms | `"1000"` |

**Note:** Wokwi has basic analog simulation. Resistors work for pull-up/pull-down but not in analog voltage dividers.

### wokwi-pushbutton
```json
{
  "id": "btn1",
  "type": "wokwi-pushbutton",
  "left": 100,
  "top": 50,
  "attrs": { "color": "green", "label": "Reset" }
}
```
**Pins:** 1, 2 (connected when pressed)

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `color` | Pushbutton color | `"red"` |
| `xray` | Shows internal wiring when set to `"1"` | `""` |
| `label` | Text shown below the button | `""` |
| `key` | Keyboard shortcut that presses the button during simulation | `""` |
| `bounce` | Set to `"0"` to disable contact bounce simulation | `""` |

### wokwi-buzzer
```json
{
  "id": "bz1",
  "type": "wokwi-buzzer",
  "left": 100,
  "top": 50
}
```
**Pins:** 1 (GND), 2 (signal)

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `mode` | Buzzer operation mode: `"smooth"` or `"accurate"` | `"smooth"` |
| `volume` | Sound volume between `"0.01"` and `"1.0"` | `"1.0"` |

### wokwi-servo
```json
{
  "id": "servo1",
  "type": "wokwi-servo",
  "left": 100,
  "top": 50
}
```
**Pins:** VCC, GND, SIG
**Range:** 0-180 degrees

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `horn` | Horn type: `"single"`, `"double"`, or `"cross"` | `"single"` |
| `hornColor` | Servo horn color | `"#ccc"` |

### board-ssd1306 (OLED Display)
```json
{
  "id": "oled1",
  "type": "board-ssd1306",
  "left": 100,
  "top": 50,
  "attrs": { "i2cAddress": "0x3c" }
}
```
**Pins:** GND, VCC, SCL, SDA

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `i2cAddress` | I2C address of the display | `"0x3c"` |

### wokwi-hc-sr04 (Ultrasonic Sensor)
```json
{
  "id": "us1",
  "type": "wokwi-hc-sr04",
  "left": 100,
  "top": 50,
  "attrs": { "distance": "200" }
}
```
**Pins:** VCC, Trig, Echo, GND

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `distance` | Initial distance value in centimeters | `"400"` |

### wokwi-dht22
```json
{
  "id": "dht1",
  "type": "wokwi-dht22",
  "left": 100,
  "top": 50,
  "attrs": { "temperature": "25", "humidity": "50" }
}
```
**Pins:** VCC, Data, GND

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `temperature` | Initial temperature value in Celsius | `"24"` |
| `humidity` | Initial relative humidity percentage | `"40"` |

### wokwi-potentiometer
```json
{
  "id": "pot1",
  "type": "wokwi-potentiometer",
  "left": 100,
  "top": 50,
  "attrs": { "value": "50" }
}
```
**Pins:** SIG, GND, VCC

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `value` | Initial potentiometer value, between 0 and 1023 | `"0"` |

### wokwi-mpu6050
```json
{
  "id": "mpu1",
  "type": "wokwi-mpu6050",
  "left": 100,
  "top": 50
}
```
**Pins:** VCC, GND, SCL, SDA, XDA, XCL, AD0, INT

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `accelX` | Initial X acceleration value in g | `"0"` |
| `accelY` | Initial Y acceleration value in g | `"0"` |
| `accelZ` | Initial Z acceleration value in g | `"1"` |
| `rotationX` | Initial X rotation value in degrees per second | `"0"` |
| `rotationY` | Initial Y rotation value in degrees per second | `"0"` |
| `rotationZ` | Initial Z rotation value in degrees per second | `"0"` |
| `temperature` | Initial temperature value in Celsius | `"24"` |

### wokwi-microsd-card
```json
{
  "id": "sd1",
  "type": "wokwi-microsd-card",
  "left": 100,
  "top": 50
}
```
**Pins:** CD, DO (MISO), GND, SCK, VCC, DI (MOSI), CS

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| None | No documented diagram attributes | N/A |

### wokwi-logic-analyzer
```json
{
  "id": "la1",
  "type": "wokwi-logic-analyzer",
  "left": 100,
  "top": 50,
  "attrs": { "bufferSize": "1000000", "channelNames": "D0,D1,D2,D3" }
}
```
**Pins:** D0-D7, GND

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `bufferSize` | Maximum number of samples to collect | `"1000000"` |
| `channelNames` | Comma-separated list of channel names for the VCD file | `"D0,D1,D2,D3,D4,D5,D6,D7"` |
| `filename` | Recording file name without extension | `"wokwi-logic"` |
| `triggerMode` | Trigger mode: `"off"`, `"level"`, or `"edge"` | `"off"` |
| `triggerLevel` | Trigger level: `"high"` or `"low"` | `"high"` |
| `triggerPin` | Trigger input pin from `"D0"` through `"D7"` | `"D7"` |

### wokwi-breadboard
```json
{
  "id": "bb1",
  "type": "wokwi-breadboard",
  "left": 100,
  "top": 50,
  "attrs": { "size": "half" }
}
```
**Sizes:** mini, half, full

**Attributes:**
| Name | Description | Default |
|------|-------------|---------|
| `size` | Breadboard size: `"mini"`, `"half"`, or `"full"` | `"full"` |

## Connections Format

Each connection is an array: `[\"source\", \"target\", \"color\", [wire_instructions]]`

```json
"connections": [
  ["led1:A", "esp:IO2", "green", []],
  ["led1:C", "esp:GND.1", "black", []],
  ["r1:1", "btn1:1", "blue", ["v10", "h5", "*", "v-10"]]
]
```

**Wire placement mini-language:**
- `vN` — move N pixels vertically (positive = down)
- `hN` — move N pixels horizontally (positive = right)
- `*` — separator: instructions before apply to source, after apply to target (in reverse)

## Serial Monitor Configuration

```json
"serialMonitor": {
  "display": "terminal",
  "newline": "lf",
  "convertEol": true
}
```

## Validation

Use `wokwi-cli lint` to validate diagram.json files:
```bash
wokwi-cli lint
```

Checks for:
- Unknown part types
- Invalid pin connections
- Duplicate IDs
- Missing components

## Important Notes for ESP32-C3

1. **Strapping Pins:** IO2, IO8, and IO9 are strapping pins. Be careful with pull-up/down resistors on these pins during boot.
2. **RGB LED:** The DevKitM-1 has an onboard RGB LED connected to IO8.
3. **USB Serial/JTAG:** Set `serialInterface: "USB_SERIAL_JTAG"` to use USB CDC instead of UART.
4. **No Bluetooth:** ESP32-C3 Bluetooth is not simulated in Wokwi.
5. **I2C:** Master mode only, 10-bit addressing not supported.
6. **RMT:** Transmit-only, useful for WS2812 LED strips.
7. **Analog Simulation:** Very basic. Resistors don\'t work in voltage dividers with analog sensors.

## Example: Complete ESP32-C3 Blink Diagram

```json
{
  "version": 1,
  "author": "Your Name",
  "editor": "wokwi",
  "parts": [
    { "id": "esp", "type": "board-esp32-c3-devkitm-1", "left": 0, "top": 0 },
    { "id": "led1", "type": "wokwi-led", "left": 200, "top": 50, "attrs": { "color": "red" } },
    { "id": "r1", "type": "wokwi-resistor", "left": 150, "top": 50, "attrs": { "value": "330" } }
  ],
  "connections": [
    ["esp:IO2", "r1:1", "green", []],
    ["r1:2", "led1:A", "green", []],
    ["led1:C", "esp:GND.1", "black", []]
  ]
}
```

## Sources
- https://docs.wokwi.com/diagram-format
- https://docs.wokwi.com/guides/esp32
- https://docs.wokwi.com/parts/wokwi-led
- https://docs.wokwi.com/parts/wokwi-resistor
- https://docs.wokwi.com/parts/wokwi-buzzer
- https://docs.wokwi.com/parts/wokwi-servo
- https://docs.wokwi.com/parts/board-ssd1306
- https://docs.wokwi.com/wokwi-ci/cli-usage
- https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/hw-reference/esp32c3/user-guide-devkitm-1.html
""",

    "wokwi_esp32_c3_pinout.md": """# ESP32-C3-DevKitM-1 Pinout Reference

## J1 Header (Left Side, top to bottom)
| # | Pin | Type | Function |
|---|-----|------|----------|
| 1 | GND | G | Ground |
| 2 | 3V3 | P | 3.3V power supply |
| 3 | 3V3 | P | 3.3V power supply |
| 4 | IO2 | I/O/T | GPIO2, ADC1_CH2, FSPIQ (strapping pin) |
| 5 | IO3 | I/O/T | GPIO3, ADC1_CH3 |
| 6 | GND | G | Ground |
| 7 | RST | I | CHIP_PU (reset) |
| 8 | GND | G | Ground |
| 9 | IO0 | I/O/T | GPIO0, ADC1_CH0, XTAL_32K_P |
| 10 | IO1 | I/O/T | GPIO1, ADC1_CH1, XTAL_32K_N |
| 11 | IO10 | I/O/T | GPIO10, FSPICS0 |
| 12 | GND | G | Ground |
| 13 | 5V | P | 5V power supply |
| 14 | 5V | P | 5V power supply |
| 15 | GND | G | Ground |

## J3 Header (Right Side, top to bottom)
| # | Pin | Type | Function |
|---|-----|------|----------|
| 1 | GND | G | Ground |
| 2 | TX | I/O/T | GPIO21, U0TXD |
| 3 | RX | I/O/T | GPIO20, U0RXD |
| 4 | GND | G | Ground |
| 5 | IO9 | I/O/T | GPIO9 (strapping pin) |
| 6 | IO8 | I/O/T | GPIO8, RGB LED (strapping pin) |
| 7 | GND | G | Ground |
| 8 | IO7 | I/O/T | GPIO7, FSPID, MTDO |
| 9 | IO6 | I/O/T | GPIO6, FSPICLK, MTCK |
| 10 | IO5 | I/O/T | GPIO5, ADC2_CH0, FSPIWP, MTDI |
| 11 | IO4 | I/O/T | GPIO4, ADC1_CH4, FSPIHD, MTMS |
| 12 | GND | G | Ground |
| 13 | IO18 | I/O/T | GPIO18, USB_D- |
| 14 | IO19 | I/O/T | GPIO19, USB_D+ |
| 15 | GND | G | Ground |

## Strapping Pins
| GPIO | Default | Function | Pull-up | Pull-down |
|------|---------|----------|---------|-----------|
| IO2 | N/A | Booting Mode | See datasheet | See datasheet |
| IO9 | Pull-up | Booting Mode | SPI Boot | Download Boot |
| IO8 | N/A | Booting Mode | Don\'t Care | Download Boot |
| IO8 | Pull-up | Enabling/Disabling Log Print | See datasheet | See datasheet |

## Notes
- 22 programmable GPIOs total
- 3 x SPI, 2 x UART, 1 x I2C, 1 x I2S
- 2 x 12-bit SAR ADCs (up to 6 channels)
- LED PWM controller (up to 6 channels)
- Full-speed USB Serial/JTAG controller
- Source: https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/hw-reference/esp32c3/user-guide-devkitm-1.html
""",

    "wokwi_parts_catalog.md": """# Wokwi Parts Catalog

## Microcontrollers
| Type | Chip | Description | Attributes |
|------|------|-------------|------------|
| board-esp32-c3-devkitm-1 | ESP32-C3 | Entry-level ESP32-C3 development board | `flashSize` (`"4"`), `serialInterface` (`""`), `firmwareOffset` (`""`), `macAddress`, `cpuFrequency` (`"auto"`) |

## LEDs
| Type | Description | Pins | Attributes |
|------|-------------|------|------------|
| wokwi-led | Standard 5mm LED | A, C | `color` (`"red"`), `lightColor`, `label`, `gamma` (`"2.8"`), `flip`, `fps` (`"80"`) |
| wokwi-rgb-led | RGB LED (common anode/cathode) | R, G, B, COM | `common` (`"anode"`) |
| wokwi-led-bar-graph | 10-segment LED bar graph | A1-A10, C1-C10 | `color` (`"red"`) |
| wokwi-led-matrix | WS2812 NeoPixel matrix | DIN | `rows` (`"8"`), `cols` (`"8"`), `layout` (`""`), `brightness` (`"1"`), `pixelShape` (`""`), `pixelSize` (`"5050"`) |
| wokwi-neopixel | Single WS2812 LED | DIN | None documented |

## Passive Components
| Type | Description | Pins | Attributes |
|------|-------------|------|------------|
| wokwi-resistor | Resistor | 1, 2 | `value` (`"1000"`) |
| wokwi-capacitor | Capacitor | 1, 2 | `value` |
| wokwi-potentiometer | Potentiometer | SIG, GND, VCC | `value` (`"0"`) |

## Input Devices
| Type | Description | Pins | Attributes |
|------|-------------|------|------------|
| wokwi-pushbutton | Push button | 1, 2 | `color` (`"red"`), `xray` (`""`), `label` (`""`), `key`, `bounce` (`""`) |
| wokwi-slide-switch | Slide switch | 1, 2, 3 | `value` (`""` = left, `"1"` = right), `bounce` (`""`) |
| wokwi-rotary-encoder | Rotary encoder | CLK, DT, SW, +, GND | None documented |
| wokwi-joystick | Analog joystick | VRX, VRY, SW, VCC, GND | `bounce` (`""`) |
| wokwi-keypad | Membrane keypad | R1-R4, C1-C4 | `columns` (`"4"`), `keys` (4x4 labels) |

## Sensors
| Type | Description | Interface | Pins | Attributes |
|------|-------------|-----------|------|------------|
| wokwi-hc-sr04 | Ultrasonic distance sensor | Digital | VCC, Trig, Echo, GND | `distance` (`"400"`) |
| wokwi-dht22 | Temp/humidity sensor | 1-Wire | VCC, Data, GND | `temperature` (`"24"`), `humidity` (`"40"`) |
| wokwi-ds18b20 | Temperature sensor | 1-Wire | VCC, Data, GND | `temperature` (`"22"`), `deviceID` (`"010203040506"`), `familyCode` (`"28"`) |
| wokwi-bmp180 | Barometric pressure | I2C | VCC, GND, SCL, SDA | `temperature` (`"24"`), `pressure` (`"101325"`) |
| wokwi-mpu6050 | Accelerometer/gyro | I2C | VCC, GND, SCL, SDA, XDA, XCL, AD0, INT | `accelX` (`"0"`), `accelY` (`"0"`), `accelZ` (`"1"`), `rotationX/Y/Z` (`"0"`), `temperature` (`"24"`) |
| wokwi-pir-motion-sensor | PIR motion sensor | Digital | VCC, OUT, GND | `delayTime` (`"5"`), `inhibitTime` (`"1.2"`), `retrigger` (`""`) |
| wokwi-photoresistor | LDR sensor | Analog | VCC, SIG, GND | `lux` (`"500"`), `threshold` (`"2.5"`), `rl10` (`"50"`), `gamma` (`"0.7"`) |
| wokwi-mq2 | Gas sensor | Analog | VCC, GND, A0, D0 | `ppm` (`"400"`), `threshold` (`"4.4"`) |
| wokwi-hx711 | Load cell amplifier | Digital | VCC, GND, DT, SCK | `type` (`"50kg"`) |
| wokwi-mfrc522 | RFID reader | SPI | VCC, GND, SCK, MISO, MOSI, SDA, RST | None documented |
| wokwi-ds1307 | RTC module | I2C | VCC, GND, SCL, SDA, SQW | `year`, `month`, `day`, `hour`, `minute`, `second` |

## Displays
| Type | Description | Interface | Pins | Attributes |
|------|-------------|-----------|------|------------|
| board-ssd1306 | 128x64 OLED | I2C | GND, VCC, SCL, SDA | `i2cAddress` (`"0x3c"`) |
| wokwi-ili9341 | 2.4\" TFT LCD | SPI | VCC, GND, CS, RESET, DC, SDI, SCK, LED, SDO | `rotation` (`"0"`) |
| wokwi-lcd1602 | 16x2 character LCD | I2C/Parallel | VSS, VDD, V0, RS, RW, E, D0-D7, A, K | `pins` (`"i2c"`), `i2cAddress` (`"0x27"`), `background`, `color` |
| wokwi-max7219-matrix | LED dot matrix | SPI | VCC, GND, DIN, CS, CLK | `chain` (`"1"`), `layout` |
| wokwi-7segment | 7-segment display | Digital | Common, A-G, DP | `common` (`"cathode"`), `digits`, `colon` |

## Motors & Actuators
| Type | Description | Pins | Attributes |
|------|-------------|------|------------|
| wokwi-servo | Micro servo motor | VCC, GND, SIG | `horn` (`"single"`), `hornColor` (`"#ccc"`) |
| wokwi-dc-motor | DC motor | +, - | None documented |
| wokwi-stepper-motor | Bipolar stepper motor | A-, A+, B+, B- | None documented |
| wokwi-a4988 | Stepper motor driver | ENABLE, MS1, MS2, MS3, RESET, SLEEP, STEP, DIR, GND, VCC, 1A, 1B, 2A, 2B, VMOT, GND | None documented |
| wokwi-buzzer | Piezo buzzer | 1 (GND), 2 (SIG) | `mode` (`"smooth"`), `volume` (`"1.0"`) |
| wokwi-relay-module | Relay module | VCC, GND, IN | None documented |
| wokwi-dpdt-relay | DPDT relay | COIL1, COIL2, NC1, COM1, NO1, NC2, COM2, NO2 | None documented |

## Communication Modules
| Type | Description | Pins | Attributes |
|------|-------------|------|------------|
| wokwi-nokia-5110 | Nokia 5110 LCD | VCC, GND, SCE, RST, D/C, MOSI, SCK, LED | None documented |
| wokwi-microsd-card | microSD card | CD, DO, GND, SCK, VCC, DI, CS | None documented |
| wokwi-ir-receiver | IR receiver | VCC, GND, OUT | None documented |
| wokwi-ir-remote | IR remote control | (virtual) | `code` |

## Other Components
| Type | Description | Pins | Attributes |
|------|-------------|------|------------|
| wokwi-breadboard | Breadboard | (varies by size) | `size` (`"full"`) |
| wokwi-logic-analyzer | 8-channel logic analyzer | D0-D7, GND | `bufferSize` (`"1000000"`), `channelNames`, `filename` (`"wokwi-logic"`), `triggerMode` (`"off"`), `triggerLevel` (`"high"`), `triggerPin` (`"D7"`) |
| wokwi-clock-generator | Clock signal generator | OUT, GND | `frequency`, `dutyCycle` |
| wokwi-text | Text annotation | (none) | `text`, `fontSize`, `color` |

## Source
- https://docs.wokwi.com/getting-started/supported-hardware
- https://docs.wokwi.com/diagram-format
- https://github.com/wokwi/wokwi-elements

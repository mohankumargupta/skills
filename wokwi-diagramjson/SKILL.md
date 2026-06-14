---
name: wokwi-diagramjson
description:  User describes desired wokwi diagram circuit in natural language.
              Trigger phrases
              'Create wokwi diagram for device <device>'
---

# Wokwi Diagram Generator for ESP32-C3

## Description

Generate accurate `diagram.json` files for Wokwi circuit simulations. The microcontroller is **always** `board-esp32-c3-devkitm-1`. 
The skill produces complete, lint-ready circuit diagrams with proper pin connections, 
wire routing, and component attributes.

## References

Under references folder under this skill.

- `wokwi.md`
- `diagramjson.md`

You MUST read wokwi.md in full.

## Rules

-  **Microcontroller is fixed**: Always use `"type": "board-esp32-c3-devkitm-1"` with `"id": "esp"` (or user-specified ID). Never substitute other ESP32 variants.
-  **Part IDs are unique**: Use descriptive IDs like `led1`, `r1`, `btn1`, `us1`, `servo1`, `oled1`. Never duplicate IDs.
-  **Wire colors**: Use standard colors: `red` for VCC, `black` for GND, `green` for data/signal, `blue` for secondary signals, `orange` for control.
-  **Coordinates**: Place the ESP32-C3 at `(0, 0)` as the anchor. Place other parts to the right (`left: 150+`) or below (`top: 100+`) with ~50-100px spacing to avoid overlap. Use a grid layout.
-  **Connections format**: Every connection is `["source", "target", "color", [wire_instructions]]`. Use empty `[]` for wire instructions unless complex routing is needed.
-  **Serial Monitor**: Include `"serialMonitor": {"display": "terminal", "newline": "lf"}` when the project involves UART output.

## Workflow

### Step 1: Parse the Request
Identify all components the user wants to connect to the ESP32-C3. 

### Step 2: Select Pins
- Reference `wokwi_esp32_c3_pinout.md` for available GPIO pins.
- Prefer pins that are not strapping pins for general I/O.
- For I2C: use IO4 (SDA) and IO5 (SCL) or IO6 (SCL) and IO7 (SDA) — any GPIO works for I2C on ESP32-C3.
- For SPI: use IO6 (SCK), IO7 (MOSI), IO2 (MISO), IO10 (CS) for hardware SPI, or any GPIO for software SPI.
- For UART: use the default TX (GPIO21) and RX (GPIO20) pins.
- For PWM/LEDC: any GPIO works.

### Step 3: Build the Parts Array
For each component, create a part object with:
- `id`: unique descriptive ID
- `type`: from the parts catalog
- `left`, `top`: pixel coordinates (anchor ESP32-C3 at 0,0)
- `attrs`: part-specific attributes (value, color, i2cAddress, etc.)
- `rotate`: only if needed (90, 180, 270)

### Step 4: Build the Connections Array
Connect each component to the ESP32-C3 or to other components:
- Power connections: `VCC` → `esp:3V3` or `esp:5V`, `GND` → `esp:GND.1` (or any GND pin)
- Signal connections: component pin → `esp:IOx`
- Inter-component connections: e.g., resistor between LED and GPIO
- Use the wire placement mini-language only for complex routing

### Step 5: Add serialMonitor (if needed)
If the project uses `Serial.print()` or similar, add the `serialMonitor` section.

### Step 6: Output the JSON
Produce a complete, valid `diagram.json` object. Include comments in the markdown code block explaining key choices.

### Step 7: Validation Reminder
Always remind the user to run `wokwi-cli lint` to validate the diagram.

## Examples

### Example 1: ESP32-C3 + Resistor + LED (Blink)

**User request**: "Connect an LED to the ESP32-C3 with a current-limiting resistor."

**Analysis**:
- Use external LED + resistor (not onboard RGB LED, since user specifically asked for an LED)
- LED anode → resistor → GPIO2
- LED cathode → GND
- Resistor value: 330\u03a9 (standard for 3.3V logic)

**Generated diagram.json**:
```json
{
  "version": 1,
  "author": "Wokwi Skill",
  "editor": "wokwi",
  "parts": [
    {
      "id": "esp",
      "type": "board-esp32-c3-devkitm-1",
      "left": 0,
      "top": 0
    },
    {
      "id": "led1",
      "type": "wokwi-led",
      "left": 200,
      "top": 50,
      "attrs": {
        "color": "red",
        "label": "LED"
      }
    },
    {
      "id": "r1",
      "type": "wokwi-resistor",
      "left": 140,
      "top": 50,
      "attrs": {
        "value": "330",
        "unit": "\u03a9"
      }
    }
  ],
  "connections": [
    ["esp:IO2", "r1:1", "green", []],
    ["r1:2", "led1:A", "green", []],
    ["led1:C", "esp:GND.1", "black", []]
  ],
  "serialMonitor": {
    "display": "terminal",
    "newline": "lf"
  }
}
```

**Notes**:
- GPIO2 is used (not a strapping pin in the critical boot sense for this simple use, but IO2 is a strapping pin — acceptable for LED output)
- Resistor is placed between GPIO and LED anode
- LED cathode goes to GND.1 (J1 pin 1)
- Serial monitor included for `Serial.println()` debugging

---

### Example 2: ESP32-C3 + HC-SR04 Ultrasonic Sensor

**User request**: "Connect an HC-SR04 ultrasonic distance sensor to the ESP32-C3."

**Analysis**:
- HC-SR04 needs 4 pins: VCC, Trig, Echo, GND
- VCC → 5V (sensor is 5V tolerant, but ESP32-C3 is 3.3V logic — Wokwi simulates this fine)
- Trig → GPIO4 (output trigger pulse)
- Echo → GPIO5 (input echo pulse)
- GND → GND
- No resistor needed for digital signals in Wokwi

**Generated diagram.json**:
```json
{
  "version": 1,
  "author": "Wokwi Skill",
  "editor": "wokwi",
  "parts": [
    {
      "id": "esp",
      "type": "board-esp32-c3-devkitm-1",
      "left": 0,
      "top": 0
    },
    {
      "id": "us1",
      "type": "wokwi-hc-sr04",
      "left": 250,
      "top": 30,
      "attrs": {
        "distance": "200",
        "label": "Ultrasonic"
      }
    }
  ],
  "connections": [
    ["us1:VCC", "esp:5V.1", "red", []],
    ["us1:GND", "esp:GND.2", "black", []],
    ["us1:Trig", "esp:IO4", "green", []],
    ["us1:Echo", "esp:IO5", "blue", []]
  ],
  "serialMonitor": {
    "display": "terminal",
    "newline": "lf"
  }
}
```

**Notes**:
- GPIO4 and GPIO5 chosen (not strapping pins, available for general I/O)
- 5V.1 is J1 pin 13 (first 5V pin)
- GND.2 is J1 pin 6 (second GND pin from top)
- `distance` attribute set to 200cm (default); user can change it in Wokwi UI
- Serial monitor included to print distance readings

---

### Example 3: ESP32-C3 + Multiple Components (LED + Button + OLED)

**User request**: "Connect an LED, a push button, and an SSD1306 OLED display to the ESP32-C3."

**Analysis**:
- LED: GPIO2 with 330\u03a9 resistor (same as Example 1)
- Button: GPIO9 with internal pull-up (external pull-up not needed in Wokwi, but user may want one)
- OLED (SSD1306): I2C — SDA on GPIO6, SCL on GPIO7
- \u26a0\ufe0f GPIO9 is a strapping pin. If using it for a button, warn the user that it may affect boot if pulled low during reset.

**Generated diagram.json**:
```json
{
  "version": 1,
  "author": "Wokwi Skill",
  "editor": "wokwi",
  "parts": [
    {
      "id": "esp",
      "type": "board-esp32-c3-devkitm-1",
      "left": 0,
      "top": 0
    },
    {
      "id": "led1",
      "type": "wokwi-led",
      "left": 220,
      "top": 20,
      "attrs": { "color": "red" }
    },
    {
      "id": "r1",
      "type": "wokwi-resistor",
      "left": 160,
      "top": 20,
      "attrs": { "value": "330" }
    },
    {
      "id": "btn1",
      "type": "wokwi-pushbutton",
      "left": 220,
      "top": 100,
      "attrs": { "color": "green", "label": "Button" }
    },
    {
      "id": "oled1",
      "type": "board-ssd1306",
      "left": 220,
      "top": 180,
      "attrs": { "i2cAddress": "0x3c" }
    }
  ],
  "connections": [
    ["esp:IO2", "r1:1", "green", []],
    ["r1:2", "led1:A", "green", []],
    ["led1:C", "esp:GND.1", "black", []],
    ["btn1:1", "esp:IO9", "orange", []],
    ["btn1:2", "esp:GND.3", "black", []],
    ["oled1:GND", "esp:GND.4", "black", []],
    ["oled1:VCC", "esp:3V3.1", "red", []],
    ["oled1:SCL", "esp:IO7", "blue", []],
    ["oled1:SDA", "esp:IO6", "green", []]
  ],
  "serialMonitor": {
    "display": "terminal",
    "newline": "lf"
  }
}
```

**Warnings to include**:
- GPIO9 is a strapping pin. If the button is pressed during reset, the board may enter download mode. Consider using GPIO3 or GPIO10 instead for the button if boot reliability is critical.
- The OLED uses 3.3V (not 5V) to avoid damaging the display in real hardware.

---

## Pin Selection Guidelines

When the user does not specify which GPIO to use, follow this priority:

| Priority | GPIO | Reason |
|----------|------|--------|
| 1 | IO3, IO4, IO5, IO6, IO7 | General-purpose, no special restrictions |
| 2 | IO0, IO1 | Available but used for 32K crystal in some designs |
| 3 | IO10 | SPI CS pin, usable for general I/O |
| 4 | IO2 | Strapping pin, usable for output (LED) but avoid for input with pull-up/down |
| 5 | IO8 | Strapping pin + onboard RGB LED. Use only if user explicitly wants RGB or this pin |
| 6 | IO9 | Strapping pin. Avoid unless user specifically requests it |
| — | IO18, IO19 | USB pins. Avoid for general I/O unless doing USB-related projects |
| — | TX/RX (IO21/IO20) | UART0. Avoid if using serial communication |

## Common Mistakes to Avoid

1. **Wrong board type**: Using `wokwi-esp32-devkit-v1` instead of `board-esp32-c3-devkitm-1`
2. **Wrong pin names**: Using `D2`, `D4`, etc. (Arduino-style) instead of `IO2`, `IO4` (ESP32-C3 uses `IOx` naming)
3. **Duplicate IDs**: Two parts with the same `"id"` value
4. **Missing GND/VCC**: Forgetting to power components
5. **Analog voltage dividers**: Trying to use resistors with `wokwi-photoresistor` or `wokwi-ntc-temperature-sensor` — Wokwi cannot simulate this
6. **I2C address mismatch**: Using `0x3d` for SSD1306 when the module is `0x3c`
7. **Strapping pin issues**: Connecting buttons or pull resistors to IO8/IO9 without warning

## Output Format

When generating a diagram, always output:
1. A brief analysis of the requested circuit
2. The complete `diagram.json` in a fenced code block
3. Any warnings (strapping pins, analog limitations, etc.)
4. A reminder to run `wokwi-cli lint`
5. Optional: A `wokwi.toml` snippet if the user needs firmware configuration

## wokwi.toml (Optional Companion File)

If the user is building a custom firmware project, also generate `wokwi.toml`:

```toml
[wokwi]
version = 1
firmware = "build/project.bin"
elf = "build/project.elf"
```

For ESP-IDF/Arduino projects, the firmware path points to the compiled `.bin` or `.elf` file.


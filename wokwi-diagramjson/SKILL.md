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
- `esp32c3.md`

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
Connect each component to the ESP32-C3

### Step 6: Output the JSON
Produce a complete, valid `diagram.json` object. 

### Step 7: Validation Reminder
Always remind the user to run `wokwi-cli lint` to validate the diagram.



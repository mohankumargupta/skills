---
name: wokwi-diagramjson
description:  User describes desired wokwi diagram circuit in natural language.
              Trigger phrases
              'Create wokwi diagram for device <device>'
---

# Wokwi Diagram Generator for ESP32-C3

## Description

Generate accurate `diagram.json` files for Wokwi circuit simulations. 
The microcontroller is **always** `board-esp32-c3-devkitm-1`. 
the <device> is not in the builtin parts list but there is a custom chip for 
it that has been created previously, so add it like any other custom chip.

## Input
`artifacts/prompt2a/qa_test/tests/test.rs`: read this to help set defaults for wokwi custom chip attributes 
`artifacts/prompt1/<device>.chip.json`: read this file to set attributes defaults. Must 
explicitly set all attributes to values from test.rs file that make sense.

## References

Under references folder under this skill.

- `wokwi.md`
- `diagramjson.md`
- `esp32c3.md`


## Rules

-  **Microcontroller is fixed**: Always use `"type": "board-esp32-c3-devkitm-1"` with `"id": "esp"` (or user-specified ID). Never substitute other ESP32 variants.
-  **Part IDs are unique**: Use descriptive IDs like `led1`, `r1`, `btn1`, `us1`, `servo1`, `oled1`. Never duplicate IDs.
-  **Wire colors**: Use standard colors: `red` for VCC, `black` for GND, `green` for data/signal, `blue` for secondary signals, `orange` for control.
-  **Coordinates**: Place the ESP32-C3 at `(0, 0)` as the anchor. Place other parts to the right (`left: 150+`) or below (`top: 100+`) with ~50-100px spacing to avoid overlap. Use a grid layout.
-  **Connections format**:  Use empty `[]` for wire routing connections. the first two entries MUST
                            be [ "esp:TX", "$serialMonitor:RX", "", [] ], and     [ "esp:RX", "$serialMonitor:TX", "", [] ],



## Workflow

### Step 1: Parse the Request
Identify all components the user wants to connect to the ESP32-C3. 

### Step 2: Select Pins
- Reference `esp32c3.md` for available GPIO pins.
- Prefer pins that are not strapping pins for general I/O.
- For I2C: use IO4 (SDA) and IO5 (SCL) or IO6 (SCL) and IO7 (SDA) — any GPIO works for I2C on ESP32-C3.
- For SPI: use IO6 (SCK), IO7 (MOSI), IO2 (MISO), IO10 (CS) for hardware SPI, or any GPIO for software SPI.
- For UART: use the default TX (GPIO21) and RX (GPIO20) pins.

### Step 3: Build the Parts Array
For each component, create a part object with:
- `id`: unique descriptive ID
- `type`: for custom chip, this is important
- `left`, `top`: pixel coordinates (anchor ESP32-C3 at 0,0)
- `attrs`: part-specific attributes (value, color, i2cAddress, etc.)
- `rotate`: only if needed (90, 180, 270)

custom chip type should start with: chip
for attrs, need to read both <device>.chip.json for attributes
and test.rs for values that should be set.

### Step 4: Build the Connections Array
Connect each component to the ESP32-C3

### Step 5: Output the JSON
Produce a complete, valid `diagram.json` object. 

### Step 6: Validation
run `wokwi-cli lint` to validate the diagram.



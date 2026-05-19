---
name: wokwi-diagramjson
description:  User describes desired wokwi diagram circuit in natural language.
              Trigger phrases
              'Create wokwi diagram for bmp180 example from espforge'
---
# Skill: Wokwi ESP32-C3 Professional Diagram Generator

## Overview
Generate professional `diagram.json` files for Wokwi simulator with ESP32-C3-DevKitM-1 board. 

## Context Variables

`<device>`

## Output Files
`diagram.json` : wokwi diagram.json file, created in `examples/<device>_example` under working directory.
`<device>_WOKWI_IMPROVEMENTS.md`: feedback for improving skill.


## Validation

Once you create a `diagram.json`, validate it by running `bash -c wokwi_cli lint` in the 
directoy containing `diagram.json` . If you get errors, fix them, repeat until you don't get
errors. You can ignore warnings.

Once completed, if you had received errors, look at `ADR/wokwi` directory, you may find 
previous ADRs,if you do, add to them, 
if not please create one using the `references/WRITING-ADRS.md`
in this skill.


---

## ⚠️ CRITICAL RULES (Non-Negotiable)

### Rule 1: Wire Routing - Horizontal Exit First
```json
// ❌ FORBIDDEN - Cuts through board:
["esp:19", "led1:A", "green", ["v86.4"]]

// ✅ MANDATORY - Clean horizontal exit:
["esp:19", "led1:A", "green", ["v0", "h65", "v-16"]]
```
**Pattern**: `["v0", "h<50-100>", "v<small_adjustment>"]`

### Rule 2: Use Exact Pin Names from Database
Components and boards have SPECIFIC pin names. DO NOT guess, you MUST verify that they exist
and apply to this particular component or board.

---

## ESP32-C3-DevKitM-1 Board Specifications

### Physical Properties
- **Width**: 25.4 mm
- **Height**: 42.91 mm  
- **Default Position**: top: 18.9, left: -51.78
- **Right Edge X-coordinate**: approximately -26.4 (left + width)

### Complete Pin Map (Coordinates from top-left corner)

#### LEFT SIDE (x = 1.0mm) - Power/Reset Only
| Pin ID | Y (mm) | Target | Type |
|--------|--------|--------|------|
| GND.1 | 5.16 | GND | Ground |
| 3V3.1 | 7.7 | power(3.3) | Power |
| 3V3.2 | 10.24 | power(3.3) | Power |
| 2 | 12.78 | GPIO2 | GPIO/ADC |
| 3 | 15.32 | GPIO3 | GPIO/ADC |
| GND.2 | 17.86 | GND | Ground |
| RST | 20.4 | CHIP_PU | Reset |
| GND.3 | 22.94 | GND | Ground |
| 0 | 25.48 | GPIO0 | Boot/GPIO |
| 1 | 28.02 | GPIO1 | GPIO/ADC |
| 10 | 30.56 | GPIO10 | GPIO |
| GND.4 | 33.1 | GND | Ground |
| 5V.1 | 35.64 | power(5) | Power |
| 5V.2 | 38.18 | power(5) | Power |
| GND.5 | 40.72 | GND | Ground |

#### RIGHT SIDE (x = 24.2mm) - **Primary for External Components**
| Pin ID | Y (mm) | Target | Type | Rec. Comp. Top |
|--------|--------|--------|------|----------------|
| GND.6 | 40.72 | GND | Ground | 33-42 |
| **19** | **38.18** | **GPIO19** | **GPIO** | **30-38** ⭐ |
| **18** | **35.64** | **GPIO18** | **GPIO** | **27-35** ⭐ |
| GND.7 | 33.1 | GND | Ground | 25-33 |
| **4** | **30.56** | **GPIO4/ADC** | **GPIO** | **22-30** ⭐ |
| **5** | **28.02** | **GPIO5/ADC** | **GPIO** | **20-28** ⭐ |
| **6** | **25.48** | **GPIO6/ADC** | **GPIO** | **18-25** ⭐ |
| **7** | **22.94** | **GPIO7/ADC** | **GPIO** | **15-23** ⭐ |
| GND.8 | 20.4 | GND | Ground | 13-21 |
| **8** | **17.86** | **GPIO8** | **GPIO** | **10-18** ⭐ |
| **9** | **15.32** | **GPIO9** | **GPIO** | **8-16** ⭐ |
| GND.9 | 12.78 | GND | Ground | 6-14 |
| RX | 10.24 | GPIO20 | UART RX | 4-12 |
| TX | 7.7 | GPIO21 | UART TX | 1-9 |
| GND.10 | 5.16 | GND | Ground | -1-7 |

⭐ = Recommended for external digital components

---

## 📦 COMPLETE COMPONENT DATABASE

### Category 1: Passive Components

#### 1.1 Resistor
```
Type: wokwi-resistor
Size: 15.645mm × 3mm (W×H)
Pins: 1, 2
Attributes: value (e.g., "220", "1k", "4.7k")
Common Values: 220, 330, 470, 1k, 4.7k, 10k
Notes: Place horizontally between GPIO and LED
```

**Template**:
```json
{
  "type": "wokwi-resistor",
  "id": "r1",
  "top": <align_with_gpio>,
  "left": <board_edge + 120>,
  "attrs": { "value": "220" }
}
```

**Connections**:
- Pin 1 → GPIO or previous component
- Pin 2 → Next component (LED anode, etc.)

**Spacing**: Minimum 20 units from other components

---

#### 1.2 Potentiometer
```
Type: wokwi-potentiometer
Size: 20mm × 20mm (square)
Pins: GND, SIG, VCC
Attributes: value (e.g., "5k", "10k"), min, max, step
Notes: ADC input only (use GPIO0-5)
```

**Template**:
```json
{
  "type": "wokwi-potentiometer",
  "id": "pot1",
  "top": <align_with_adc_gpio>,
  "left": 90,
  "attrs": { "value": "10k" }
}
```

**Connections**:
- VCC → 3V3 (or 5V)
- GND → GND
- SIG → ADC-capable GPIO (0,1,2,3,4,5)

**Example (GPIO4)**:
```json
["pot1:VCC", "esp:3V3.2", "red", ["v0", "h155", "v-15"]],
["pot1:GND", "esp:GND.7", "black", ["v0", "h-75", "v8"]],
["pot1:SIG", "esp:4", "green", ["v0", "h50", "v5"]]
```

---

#### 1.3 Slide Potentiometer
```
Type: wokwi-slide-potentiometer
Size: Variable width × 29mm height
Pins: VCC, SIG, GND
Attributes: travelLength, value, min, max, step
Notes: Longer than rotary pot - needs more vertical space
```

**Template**:
```json
{
  "type": "wokwi-slide-potentiometer",
  "id": "slidepot1",
  "top": <align_with_adc_gpio>,
  "left": 90,
  "attrs": { "value": "50" }
}
```

---

### Category 2: LEDs & Lighting

#### 2.1 Single Color LED
```
Type: wokwi-led
Size: 40px × 50px
Pins: A (Anode), C (Cathode)
Attributes: 
  - color: "red"|"green"|"blue"|"yellow"|"white"|"orange"|"purple"|"pink"|"cyan"
  - brightness: 0-1
  - flip: true/false (mirror)
Notes: Always use current-limiting resistor (220Ω typical)
```

**Template**:
```json
{
  "type": "wokwi-led",
  "id": "led1",
  "top": <align_with_gpio>,
  "left": <resistor_left + 40>,
  "attrs": { "color": "red" }
}
```

**Complete Circuit Example (GPIO19)**:
```json
{
  "parts": [
    { "type": "board-esp32-c3-devkitm-1", "id": "esp", "top": 18.9, "left": -51.78 },
    { "type": "wokwi-resistor", "id": "r1", "top": 50, "left": 90, "attrs": { "value": "220" } },
    { "type": "wokwi-led", "id": "led1", "top": 50, "left": 140, "attrs": { "color": "blue" } }
  ],
  "connections": [
    ["esp:TX", "$serialMonitor:RX", "", []],
    ["esp:RX", "$serialMonitor:TX", "", []],
    ["esp:19", "r1:1", "green", ["v0", "h68", "v-1"]],
    ["r1:2", "led1:A", "green", ["h50"]],
    ["led1:C", "esp:GND.6", "black", ["v15", "h-105", "v-12"]]
  ]
}
```

---

#### 2.2 RGB LED (Common Cathode)
```
Type: wokwi-rgb-led
Size: 42.129px × 72.582px (TALLER than single LED!)
Pins: R, COM, G, B
Attributes: ledRed, ledGreen, ledBlue (true/false)
Notes: 
  - COM connects to GND (common cathode)
  - R/G/B need individual resistors (or PWM control)
  - Takes more vertical space due to height!
```

**Template**:
```json
{
  "type": "wokwi-rgb-led",
  "id": "rgb1",
  "top": <align_with_gpio - 10>,  // Taller, adjust position
  "left": 110,
  "attrs": {}
}
```

**Connections** (3 GPIOs needed):
```json
["rgb1:R", "esp:19", "red", ["v0", "h85", "v-26"]],   // Red pin
["rgb1:G", "esp:18", "green", ["v0", "h95", "v-23"]], // Green pin
["rgb1:B", "esp:4", "blue", ["v0", "h80", "v-8"]],   // Blue pin
["rgb1:COM", "esp:GND.7", "black", ["v0", "h-105", "v8"]] // Common ground
```

**Note**: Due to height (72px), increase vertical spacing to 30+ units from adjacent components

---

#### 2.3 NeoPixel / WS2812 (Addressable RGB)
```
Type: wokwi-neopixel
Size: 5.6631mm × 5mm (SMALL!)
Pins: VDD, DOUT, VSS, DIN
Attributes: r, g, b (color values 0-255)
Notes:
  - VDD = Power (3.3V or 5V)
  - VSS = Ground (NOT "GND"!)
  - DIN = Data Input from MCU
  - DOUT = Data Output (to next NeoPixel in chain)
  - Can chain multiple NeoPixels: DOUT→DIN
```

**Template**:
```json
{
  "type": "wokwi-neopixel",
  "id": "neo1",
  "top": <align_with_gpio>,
  "left": 90,
  "attrs": {}
}
```

**Single NeoPixel Example (GPIO9)**:
```json
{
  "type": "wokwi-neopixel",
  "id": "neo1",
  "top": 14,
  "left": 90,
  "attrs": {}
},
"connections": [
  ["neo1:DIN", "esp:9", "green", ["v0", "h58", "v-3"]],
  ["neo1:VDD", "esp:3V3.2", "red", ["v0", "h157", "v-21"]],
  ["neo1:VSS", "esp:GND.9", "black", ["v0", "h-57", "v-1.2"]]
]
```

**Chained NeoPixels (2 pixels)**:
```json
{ "type": "wokwi-neopixel", "id": "neo1", "top": 14, "left": 90, "attrs": {} },
{ "type": "wokwi-neopixel", "id": "neo2", "top": 14, "left": 120, "attrs": {} },

"connections": [
  ["neo1:DIN", "esp:9", "green", ["v0", "h58", "v-3"]],
  ["neo1:DOUT", "neo2:DIN", "green", ["h30"]],  // Chain connection
  ["neo1:VDD", "esp:3V3.2", "red", ["v0", "h157", "v-21"]],
  ["neo1:VSS", "esp:GND.9", "black", ["v0", "h-57", "v-1.2"]],
  ["neo2:VDD", "esp:3V3.2", "red", ["v0", "h187", "v-21"]],  // Share power
  ["neo2:VSS", "esp:GND.9", "black", ["v0", "h-87", "v-1.2"]]  // Share ground
]
```

---

#### 2.4 LED Ring (Circular Addressable Array)
```
Type: wokwi-led-ring
Size: Variable (depends on pixel count)
Pins: GND, VCC, DIN, DOUT
Attributes: 
  - pixels: number of LEDs
  - pixelSpacing: distance between pixels
  - background: true/false
  - animation: animation type
Notes: Large circular display - position far right (left: 140+)
```

**Template**:
```json
{
  "type": "wokwi-led-ring",
  "id": "ring1",
  "top": 20,
  "left": 150,  // Far right - it's BIG!
  "attrs": { "pixels": 12 }
}
```

---

#### 2.5 LED Bar Graph (10-Segment)
```
Type: wokwi-led-bar-graph
Size: 10.1mm × 25.5mm (narrow, tall)
Pins: A1-A10 (anodes), C1-C10 (cathodes)
Attributes: color, offColor, values (array of 10 booleans)
Notes: 
  - Requires 10 GPIOs for individual control (or use shift register)
  - Common cathodes can be tied together to save pins
  - Compact width but tall - stack vertically if multiple
```

---

### Category 3: Buttons & Switches

#### 3.1 Standard Pushbutton (17.8mm × 12mm)
```
Type: wokwi-pushbutton
Size: 17.802mm × 12mm
Pins: 1.l, 2.l (left side), 1.r, 2.r (right side)
Attributes: color, pressed, label, xray
Notes: 
  - Use INPUT_PULLUP in code
  - Connect one side to GPIO, other side to GND
  - .l = left pins, .r = right pins (either pair works)
```

**Template**:
```json
{
  "type": "wokwi-pushbutton",
  "id": "btn1",
  "top": <align_with_gpio>,
  "left": 90,
  "attrs": { "color": "blue" }
}
```

**Example (GPIO9)**:
```json
{
  "type": "wokwi-pushbutton",
  "id": "btn1",
  "top": 12,
  "left": 90,
  "attrs": {}
},
"connections": [
  ["btn1:1.l", "esp:9", "green", ["v0", "h56", "v-3"]],
  ["btn1:1.r", "esp:GND.9", "black", ["v0", "h-56", "v0.8"]]
]
```

---

#### 3.2 Small Pushbutton 6mm (7.4mm × 6mm)
```
Type: wokwi-pushbutton-6mm
Size: 7.413mm × 6mm (tiny!)
Pins: 1.l, 2.l, 1.r, 2.r (same as standard)
Attributes: color, pressed, label, xray
Notes: For tight spaces - PCB mount style button
```

---

#### 3.3 Slide Switch
```
Type: wokwi-slide-switch
Size: 8.5mm × 9.23mm (small square)
Pins: 1, 2, 3 (SPDT - single pole double throw)
Attributes: value (position: 1, 2, or 3)
Notes: 
  - Pin 1 = common
  - Pins 2,3 = outputs (only one connected at a time)
  - Useful for mode selection
```

---

#### 3.4 DIP Switch 8-Position
```
Type: wokwi-dip-switch-8
Size: 82.87px × 55.355px (WIDE!)
Pins: 1a-8a (one side), 8b-1b (other side, reversed order)
Attributes: values (array of 8 booleans)
Notes: 
  - Very wide - needs left: 120+ or place below board
  - Each switch is independent SPST
  - Good for address/configuration settings
```

**Template** (needs lots of space!):
```json
{
  "type": "wokwi-dip-switch-8",
  "id": "dip1",
  "top": 50,  // Below board area
  "left": 0,   // Centered under board
  "attrs": {}
}
```

---

### Category 4: Sensors

#### 4.1 Temperature & Humidity - DHT22
```
Type: wokwi-dht22
Size: 15.1mm × 30.885mm (tall, narrow)
Pins: VCC, SDA, NC, GND
Attributes: (none - auto-detects)
Notes:
  - Uses SINGLE-WIRE protocol on SDA pin (not I2C despite name!)
  - NC = No Connect (leave unconnected)
  - Requires 10k pull-up resistor (internal usually sufficient)
  - SDA pin name is misleading - it's actually a custom 1-wire protocol
```

**Template**:
```json
{
  "type": "wokwi-dht22",
  "id": "dht1",
  "top": <align_with_gpio>,
  "left": 90,
  "attrs": {}
}
```

**Example (GPIO4)**:
```json
{
  "type": "wokwi-dht22",
  "id": "dht1",
  "top": 25,
  "left": 90,
  "attrs": {}
},
"connections": [
  ["dht1:VCC", "esp:3V3.2", "red", ["v0", "h145", "v-12"]],
  ["dht1:SDA", "esp:4", "green", ["v0", "h55", "v5"]],  // Data pin
  ["dht1:GND", "esp:GND.7", "black", ["v0", "h-75", "v8"]]
  // dht1:NC - leave disconnected
]
```

---

#### 4.2 Ultrasonic Distance - HC-SR04
```
Type: wokwi-hc-sr04
Size: 45mm × 25mm (medium rectangle)
Pins: VCC, TRIG, ECHO, GND
Attributes: (none)
Notes:
  - VCC requires 5V (not 3.3V!) for reliable operation
  - TRIG = Trigger output from MCU (short pulse)
  - ECHO = Echo input to MCU (pulse width = distance)
  - Needs 2 GPIOs
```

**Template**:
```json
{
  "type": "wokwi-hc-sr04",
  "id": "ultrasonic1",
  "top": <align_with_gpio - 5>,  // Account for height
  "left": 100,  // Wider component
  "attrs": {}
}
```

**Example (TRIG=GPIO19, ECHO=GPIO18)**:
```json
{
  "type": "wokwi-hc-sr04",
  "id": "ultrasonic1",
  "top": 30,
  "left": 100,
  "attrs": {}
},
"connections": [
  ["ultrasonic1:VCC", "esp:5V.2", "red", ["v0", "h175", "v8"]],  // Use 5V!
  ["ultrasonic1:TRIG", "esp:19", "green", ["v0", "h75", "v-5"]],
  ["ultrasonic1:ECHO", "esp:18", "green", ["v0", "h70", "v0"]],
  ["ultrasonic1:GND", "esp:GND.6", "black", ["v0", "h-98", "v11"]]
]
```

---

#### 4.3 PIR Motion Sensor
```
Type: wokwi-pir-motion-sensor
Size: 24mm × 24.448mm (square-ish)
Pins: VCC, OUT, GND
Attributes: (none)
Notes:
  - Digital output (HIGH when motion detected)
  - Use any digital GPIO
  - Warm-up time required in real hardware (not simulated)
```

**Template**:
```json
{
  "type": "wokwi-pir-motion-sensor",
  "id": "pir1",
  "top": <align_with_gpio>,
  "left": 90,
  "attrs": {}
}
```

---

#### 4.4 Flame Sensor
```
Type: wokwi-flame-sensor
Size: 52.904mm × 16.267mm (wide, short)
Pins: VCC, GND, DOUT, AOUT
Attributes: ledPower, ledSignal
Notes:
  - DOUT = Digital output (threshold-based)
  - AOUT = Analog output (intensity)
  - Wide component - give extra horizontal space
```

---

#### 4.5 Gas Sensor (MQ-2 style)
```
Type: wokwi-gas-sensor
Size: 36.232mm × 16.617mm
Pins: AOUT, DOUT, GND, VCC
Attributes: ledPower, ledD0
Notes:
  - Similar to flame sensor layout
  - DOUT = Digital threshold, AOUT = Analog level
  - Heating element requires warm-up (simulated instantly)
```

---

#### 4.6 Sound Sensors

**Big Sound Sensor**:
```
Type: wokwi-big-sound-sensor
Size: 37.056mm × 13.346mm (wide, short)
Pins: AOUT, GND, VCC, DOUT
Attributes: led1, led2
Notes: Two LEDs indicate analog/digital activity
```

**Small Sound Sensor**:
```
Type: wokwi-small-sound-sensor
Size: 35.211mm × 13.346mm
Pins: AOUT, GND, VCC, DOUT
Attributes: ledPower, ledSignal
Notes: More compact version
```

---

#### 4.7 Light/Photo Sensors

**Photoresistor Sensor Module**:
```
Type: wokwi-photoresistor-sensor
Size: 45.95mm × 16.267mm (wide)
Pins: VCC, GND, DO, AO
Attributes: ledDO, ledPower
Notes: DO = Digital (threshold), AO = Analog (light intensity)
```

**NTC Temperature Sensor**:
```
Type: wokwi-ntc-temperature-sensor
Size: 35.826mm × 19mm
Pins: GND, VCC, OUT
Attributes: (none)
Notes: Analog output - connect to ADC pin (GPIO0-5)
```

---

#### 4.8 Heart Beat / Pulse Sensor
```
Type: wokwi-heart-beat-sensor
Size: 23.4mm × 20.943mm
Pins: GND, VCC, OUT
Attributes: (none)
Notes: Analog output - use ADC pin, requires signal processing in code
```

---

#### 4.9 Tilt Switch
```
Type: wokwi-tilt-switch
Size: 23.4mm × 14.7mm
Pins: GND, VCC, OUT
Attributes: (none)
Notes: Digital output - HIGH/LOW based on orientation
```

---

#### 4.10 Analog Joystick (2-axis)
```
Type: wokwi-analog-joystick
Size: 27.2mm × 31.8mm (square-ish)
Pins: VCC, VERT, HORZ, SEL, GND
Attributes: xValue, yValue, pressed
Notes:
  - VERT = Y-axis analog output (ADC required)
  - HORZ = X-axis analog output (ADC required)
  - SEL = Select button press (digital)
  - Needs 3 GPIOs (2 ADC + 1 digital)!
```

**Template** (uses GPIO4, GPIO5 for analog, GPIO9 for select):
```json
{
  "type": "wokwi-analog-joystick",
  "id": "joy1",
  "top": 23,
  "left": 100,
  "attrs": {}
},
"connections": [
  ["joy1:VCC", "esp:3V3.2", "red", ["v0", "h155", "v-15"]],
  ["joy1:VERT", "esp:4", "green", ["v0", "h60", "v-5"]],     // Y-axis
  ["joy1:HORZ", "esp:5", "green", ["v0", "h55", "v-8"]],      // X-axis
  ["joy1:SEL", "esp:9", "green", ["v0", "h68", "v-11"]],     // Button
  ["joy1:GND", "esp:GND.7", "black", ["v0", "h-75", "v8"]]
]
```

---

#### 4.11 Rotary Encoder (KY-040)
```
Type: wokwi-ky-040
Size: 30.815mm × 18.63mm
Pins: CLK, DT, SW, VCC, GND
Attributes: angle, stepSize
Notes:
  - CLK, DT = Quadrature outputs (rotation direction/speed)
  - SW = Push switch (press down on knob)
  - Needs 3 GPIOs (all digital)
  - Complex interrupt-based code required
```

---

### Category 5: Displays

#### 5.1 OLED I2C 128x64 (Raw Chip)
```
Type: wokwi-oled-i2c128x64  (NOTE: Different from SSD1306 chip!)
Size: ~150px × 116px (estimated from board-ssd1306)
Pins: SCL, SDA, VCC, GND (I2C interface)
Attributes: (none - controlled via code)
Notes:
  - I2C protocol - only 2 data lines needed!
  - Default I2C address: 0x3C (or 0x3D)
  - Use GPIO8 (SCL) and GPIO9 (SDA) for convenience
```

**Template**:
```json
{
  "type": "wokwi-oled-i2c128x64",
  "id": "oled1",
  "top": 5,  // High position for upper GPIOs
  "left": 120,  // Display is wide
  "attrs": {}
}
```

**Example (I2C on GPIO8/9)**:
```json
{
  "type": "wokwi-oled-i2c128x64",
  "id": "oled1",
  "top": 5,
  "left": 120,
  "attrs": {}
},
"connections": [
  ["oled1:SCL", "esp:8", "green", ["v0", "h125", "v9"]],
  ["oled1:SDA", "esp:9", "green", ["v0", "h135", "v7"]],
  ["oled1:VCC", "esp:3V3.2", "red", ["v0", "h175", "v-23"]],
  ["oled1:GND", "esp:GND.9", "black", ["v0", "h-145", "v7.8"]]
]
```

---

#### 5.2 SSD1306 OLED (Breakout Board - RECOMMENDED)
```
Type: board-ssd1306  (BREAKOUT BOARD, easier to use!)
Size: 27.7mm × 22.6mm
Pins: GND, VCC, SCL, SDA
Attributes: (none)
Notes:
  - Same OLED but on convenient breakout board
  - Simpler wiring than raw chip
  - Still uses I2C (SCL, SDA)
```

**Template**:
```json
{
  "type": "board-ssd1306",
  "id": "oled1",
  "top": 10,
  "left": 100,
  "attrs": {}
}
```

---

#### 5.3 LCD1602 Character Display
```
Type: wokwi-lcd1602
Size: Variable (depends on configuration)
Pins: VSS, VDD, V0, RS, RW, E, D0-D7, A, K (16 pins total!)
Attributes:
  - color: text color
  - background: background color
  - characters: initial text
  - font: font specification
  - cursor, blink: cursor options
  - backlight: true/false
  - pins: "4bit" or "8bit" (use 4-bit to save GPIOs!)
Notes:
  - In 4-pin mode: RS, E, D4, D5, D6, D7 (6 GPIOs)
  - In 8-pin mode: RS, E, D0-D7 (10 GPIOs - wasteful!)
  - V0 = Contrast adjustment (connect to potentiometer or GND)
  - A, K = Backlight LED anode/cathode
```

**4-Bit Mode Template** (recommended):
```json
{
  "type": "wokwi-lcd1602",
  "id": "lcd1",
  "top": 0,
  "left": 120,
  "attrs": {
    "pins": "4bit"
  }
}
```

**Connections (4-bit mode, 6 GPIOs used!)**:
```json
["lcd1:VSS", "esp:GND.10", "black", ["v0", "h-175", "v5"]],   // GND
["lcd1:VDD", "esp:3V3.2", "red", ["v0", "h175", "v-23"]],    // 3.3V
["lcd1:V0", "esp:GND.9", "black", ["v0", "h-165", "v7.8"]],   // Contrast to GND
["lcd1:RS", "esp:4", "green", ["v0", "h115", "v5"]],          // Register Select
["lcd1:RW", "esp:GND.8", "black", ["v0", "h-125", "v5"]],     // Write mode (GND)
["lcd1:E", "esp:5", "green", ["v0", "h110", "v-8"]],           // Enable
["lcd1:D4", "esp:6", "green", ["v0", "h105", "v-11"]],         // Data 4
["lcd1:D5", "esp:7", "green", ["v0", "h100", "v-14"]],         // Data 5
["lcd1:D6", "esp:18", "green", ["v0", "h95", "v-23"]],         // Data 6
["lcd1:D7", "esp:19", "green", ["v0", "h90", "v-26"]],         // Data 7
["lcd1:A", "esp:5V.1", "red", ["v0", "h175", "v-23"]],        // Backlight +
["lcd1:K", "esp:GND.6", "black", ["v0", "h-118", "v3.6"]]     // Backlight -
```

**Note**: LCD1602 uses MANY GPIOs! Consider using I2C adapter (not in Wokwi yet) or accept the pin cost.

---

#### 5.4 LCD2004 (20×4 Character Display)
```
Type: wokwi-lcd2004
Size: Variable (larger than 1602)
Pins: Same as LCD1602 (VSS, VDD, V0, RS, RW, E, D0-D7, A, K)
Attributes: Same as LCD1602
Notes: 4 lines instead of 2, otherwise identical wiring
```

---

#### 5.5 7-Segment Display
```
Type: wokwi-7segment
Size: Variable (depends on digit count)
Pins: A, B, C, D, E, F, G, DP, DIG1, DIG2, DIG3, DIG4, COM, CLN
Attributes:
  - color: segment color
  - offColor: unlit segment color
  - digits: number of digits (1-4)
  - colon: show colon (for clocks)
  - pins: "common-cathode" or "common-anode"
Notes:
  - Multi-digit requires multiplexing or shift register
  - Single digit manageable with 8-9 GPIOs
  - For multi-digit, recommend using driver IC (not shown here)
```

---

#### 5.6 Nokia 5110 LCD (PCD8544)
```
Type: board-nokia-5110 (Breakout board)
Size: 45.192mm × 45.101mm (square-ish)
Pins: RST, CE, DC, DIN, CLK, VCC, BL, GND (plus duplicate set .2)
Attributes: (none)
Notes:
  - SPI protocol (faster than I2C)
  - Small monochrome graphic display (84×48 pixels)
  - BL = Backlight control
  - Two sets of pins (.2 variants) for flexible routing
```

---

#### 5.7 TFT Color Displays

**ILI9341 (240×320 SPI TFT)**:
```
Type: wokwi-ili9341
Size: 46.5mm × 77.6mm (large rectangle!)
Pins: VCC, GND, CS, RST, D/C, MOSI, SCK, LED, MISO
Attributes: flipHorizontal, flipVertical
Notes:
  - Full-color touchscreen display
  - SPI interface (many GPIOs needed!)
  - LED = Backlight (PWM for brightness control)
  - MISO optional (read-only not commonly used)
```

**ILI9341 with Capacitive Touch**:
```
Type: board-ili9341-cap-touch
Size: 46.5mm × 77.6mm (same display + touch layer)
Pins: VCC, GND, CS, RST, D/C, MOSI, SCK, LED, MISO, SCL, SDA
Notes: Adds I2C touch controller (FT6206) - needs extra 2 GPIOs!
```

**ST7789 1.54" Round Display**:
```
Type: board-st7789
Size: 32mm × 44mm (compact round/rectangular)
Pins: GND, VCC, SCL, SDA, RST, DC, CS, BL
Notes: SPI interface, popular for smart watches
```

**E-Paper 2.9" Display**:
```
Type: board-epaper-2in9
Size: 89.5mm × 38mm (wide!)
Pins: BUSY, RST, DC, CS, CLK, DIN, VCC, GND
Notes: E-ink display, retains image without power, slow refresh
```

---

### Category 6: Motors & Actuators

#### 6.1 Servo Motor (SG90)
```
Type: wokwi-servo
Size: Variable (depends on horn setting)
Pins: GND, V+, PWM
Attributes:
  - angle: initial angle (0-180)
  - horn: horn style
  - hornColor: horn color
Notes:
  - V+ = Power (5V recommended for full torque, 3.3V works for light loads)
  - PWM = Signal (any GPIO, ESP32-C3 supports PWM on all pins)
  - Internal control circuitry - no external transistor needed
```

**Template**:
```json
{
  "type": "wokwi-servo",
  "id": "servo1",
  "top": <align_with_gpio>,
  "left": 120,  // Servo body extends left/right
  "attrs": { "angle": "90" }
}
```

**Example (GPIO18)**:
```json
{
  "type": "wokwi-servo",
  "id": "servo1",
  "top": 30,
  "left": 120,
  "attrs": { "angle": "0" }
},
"connections": [
  ["servo1:PWM", "esp:18", "green", ["v0", "h95", "v-23"]],
  ["servo1:V+", "esp:5V.2", "red", ["v0", "h175", "v8"]],
  ["servo1:GND", "esp:GND.6", "black", ["v0", "h-120", "v11"]]
]
```

---

#### 6.2 Stepper Motor (Bipolar 4-wire)
```
Type: wokwi-stepper-motor
Size: Variable
Pins: A-, A+, B+, B-
Attributes: angle, arrow, value, units, size
Notes:
  - Requires H-Bridge driver (L298N, A4988, etc.) - NOT direct GPIO!
  - A-, A+ = Coil A (pair)
  - B+, B- = Coil B (pair)
  - Needs 4 GPIOs for driver control
```

---

### Category 7: Communication Modules

#### 7.1 IR Receiver (Infrared Remote Control)
```
Type: wokwi-ir-receiver
Size: 16.178mm × 23.482mm
Pins: GND, VCC, DAT
Attributes: (none)
Notes:
  - Receives 38kHz modulated IR signals
  - DAT = Digital output (requires IRremote library in code)
  - Works with wokwi-ir-remote transmitter part
```

**Template**:
```json
{
  "type": "wokwi-ir-receiver",
  "id": "ir1",
  "top": <align_with_gpio>,
  "left": 90,
  "attrs": {}
}
```

---

#### 7.2 RF ID / NFC Reader (MFRC522)
```
Type: board-mfrc522
Size: 59.496mm × 39.964mm (credit card sized)
Pins: SDA, SCK, MOSI, MISO, IRQ, GND, RST, 3.3V
Attributes: (none)
Notes:
  - SPI communication (4 data + 2 control pins)
  - 3.3V device - DO NOT use 5V!
  - IRQ = Interrupt Request (optional, can leave unconnected)
  - SDA = Chip Select (confusingly named, it's CS not I2C SDA!)
```

**SPI Pin Mapping**:
```json
["mfrc522:SDA", "esp:4", "green", ["v0", "h80", "v-8"]],    // CS
["mfrc522:SCK", "esp:18", "green", ["v0", "h95", "v-23"]],   // Clock
["mfrc522:MOSI", "esp:7", "green", ["v0", "h85", "v-14"]],  // Master Out Slave In
["mfrc522:MISO", "esp:6", "green", ["v0", "h80", "v-11"]],   // Master In Slave Out
["mfrc522:RST", "esp:5", "green", ["v0", "h75", "v-8"]],     // Reset
["mfrc522:3.3V", "esp:3V3.2", "red", ["v0", "h155", "v-15"]], // Power
["mfrc522:GND", "esp:GND.7", "black", ["v0", "h-95", "v8"]]  // Ground
// mfrc522:IRQ - leave unconnected (optional)
```

---

#### 7.3 Real-Time Clock (DS1307)
```
Type: wokwi-ds1307
Size: 25.8mm × 22.212mm
Pins: GND, 5V, SDA, SCL, SQW
Attributes: (none)
Notes:
  - I2C communication (SDA, SCL)
  - 5V power (not 3.3V!)
  - SQW = Square Wave output (optional interrupt)
  - Battery-backed RTC keeps time without power
```

---

#### 7.4 6-Axis IMU (MPU6050)
```
Type: wokwi-mpu6050
Size: 21.6mm × 16.2mm (small!)
Pins: INT, AD0, XCL, XDA, SDA, SCL, GND, VCC
Attributes: led1 (activity LED)
Notes:
  - I2C primary (SDA, SCL)
  - Auxiliary I2C (XDA, XCL) for magnetometer daisy-chain
  - AD0 = Address select (tie to GND or VCC for I2C addr)
  - INT = Interrupt output (data ready, motion detect)
  - 3.3V compatible
```

**Basic I2C Connection**:
```json
{
  "type": "wokwi-mpu6050",
  "id": "mpu1",
  "top": 14,
  "left": 90,
  "attrs": {}
},
"connections": [
  ["mpu1:VCC", "esp:3V3.2", "red", ["v0", "h157", "v-21"]],
  ["mpu1:GND", "esp:GND.9", "black", ["v0", "h-57", "v-1.2"]],
  ["mpu1:SDA", "esp:9", "green", ["v0", "h58", "v-3"]],   // I2C Data
  ["mpu1:SCL", "esp:8", "green", ["v0", "h53", "v-4"]]    // I2C Clock
  // mpu1:INT, AD0, XCL, XDA - leave unconnected for basic use
]
```

---

#### 7.5 Temperature Sensor (DS18B20 - Breakout)
```
Type: board-ds18b20
Size: 8.564mm × 13.388mm (very small!)
Pins: GND, DQ, VCC
Attributes: chips: wokwi-ds18b20
Notes:
  - 1-Wire protocol (single data line + ground + power)
  - DQ = Data (requires 4.7k pull-up to VCC)
  - High accuracy (±0.5°C)
  - Unique 64-bit address allows multiple sensors on same bus
```

---

#### 7.6 Temperature Sensor (LM35 - Analog)
```
Type: board-lm35
Size: 8.564mm × 13.388mm (same small package)
Pins: VCC, OUT, GND
Attributes: chips: github:Droog71/LM35@0.0.2
Notes:
  - Analog output (10mV per degree Celsius)
  - Connect OUT to ADC pin (GPIO0-5)
  - Simple linear output - easy to use
  - No pull-up resistors needed
```

---

#### 7.7 Pressure Sensor (BMP180)
```
Type: board-bmp180
Size: 18.04mm × 12.38mm (small rectangle)
Pins: VCC, GND, SCL, SDA, 3.3V
Attributes: chips: wokwi-bmp180
Notes:
  - I2C communication (SCL, SDA)
  - Both VCC and 3.3V present (use 3.3V for ESP32)
  - Measures temperature and barometric pressure
  - Can calculate altitude from pressure
```

---

#### 7.8 Grove OLED 1.12" (SH1107)
```
Type: board-grove-oled-sh1107
Size: 44.94mm × 44.31mm (square)
Pins: GND.1, VCC, SDA, SCL.1
Attributes: chips: github:wokwi/chip-sh1107@0.1.0; displays: sh1107
Notes:
  - Grove connector system (4-pin standardized)
  - I2C interface
  - Small round OLED display
```

---

#### 7.9 Multiplexer (CD74HC4067 - 16-channel Analog)
```
Type: board-cd74hc4067
Size: 16.1mm × 40.343mm (tall narrow)
Pins: I0-I15 (16 inputs), COM (common output), S0-S3 (select), EN, VCC, GND
Attributes: chips: github:Droog71/CD74HC4067@0.0.3
Notes:
  - Expands 1 ADC pin into 16 analog inputs!
  - S0-S3 = Binary select (4 bits to choose which input is active)
  - EN = Enable (active low, tie to GND normally)
  - Saves GPIOs when you need many analog sensors
```

---

### Category 8: Storage

#### 8.1 MicroSD Card Module
```
Type: wokwi-microsd-card
Size: 21.6mm × 20.4mm
Pins: CD, DO, GND, SCK, VCC, DI, CS
Attributes: (none)
Notes:
  - SPI communication (not SD card protocol directly!)
  - CD = Card Detect (optional, tells if card inserted)
  - DO = MISO (Data Out from card)
  - DI = MOSI (Data In to card)
  - CS = Chip Select (required!)
  - Level shifting onboard (works with 3.3V and 5V)
  - Must initialize FAT filesystem in code before use
```

**SPI Connections**:
```json
{
  "type": "wokwi-microsd-card",
  "id": "sd1",
  "top": 25,
  "left": 100,
  "attrs": {}
},
"connections": [
  ["sd1:CS", "esp:4", "green", ["v0", "h80", "v-8"]],       // Chip Select
  ["sd1:SCK", "esp:18", "green", ["v0", "h95", "v-23"]],     // Clock
  ["sd1:DI", "esp:7", "green", ["v0", "h85", "v-14"]],      // MOSI
  ["sd1:DO", "esp:6", "green", ["v0", "h80", "v-11"]],      // MISO
  ["sd1:VCC", "esp:5V.2", "red", ["v0", "h175", "v-8"]],    // Power (5V preferred)
  ["sd1:GND", "esp:GND.7", "black", ["v0", "h-95", "v8"]]   // Ground
  // sd1:CD - leave unconnected (card detect optional)
]
```

---

### Category 9: Audio

#### 9.1 Buzzer (Passive Piezo)
```
Type: wokwi-buzzer
Size: 17mm × 20mm
Pins: 1, 2
Attributes: hasSignal
Notes:
  - Passive buzzer = needs PWM/tone signal to make sound
  - Active buzzers have internal oscillator
  - Connect pin 1 to GPIO (via transistor for loud sound), pin 2 to GND
  - Use tone() function in Arduino code
```

**Simple Connection** (direct to GPIO, quiet):
```json
{
  "type": "wokwi-buzzer",
  "id": "buzz1",
  "top": <align_with_gpio>,
  "left": 90,
  "attrs": {}
},
"connections": [
  ["buzz1:1", "esp:19", "green", ["v0", "h75", "v-23"]],
  ["buzz1:2", "esp:GND.6", "black", ["v0", "h-73", "v11"]]
]
```

---

### Category 10: Specialty Components

#### 10.1 Relay Module (KS2E-M-DC5 - Dual Relay)
```
Type: wokwi-ks2e-m-dc5
Size: 21mm × 10mm
Pins: NO2, NC2, P2, COIL2, NO1, NC1, P1, COIL1
Attributes: (none)
Notes:
  - Dual relay module (2 independent relays)
  - COIL1/COIL2 = Coil control (connect to GPIO via transistor)
  - NO1/NC1/P1 = Relay 1 contacts (Normally Open, Normally Closed, Common)
  - NO2/NC2/P2 = Relay 2 contacts
  - Isolates high-voltage circuits from MCU (safe!)
  - 5V coil voltage typically
```

---

#### 10.2 Load Cell Amplifier (HX711)
```
Type: wokwi-hx711
Size: Variable
Pins: VCC, DT, SCK, GND
Attributes: type (amplifier variant)
Notes:
  - 24-bit ADC for load cells / strain gauges
  - 2-wire serial protocol (DT=Data, SCK=Clock)
  - Used in kitchen scales, weight sensors
  - Very high resolution measurements
```

---

#### 10.3 Rotary Dialer (Vintage Phone Style)
```
Type: wokwi-rotary-dialer
Size: 266px × 286px (HUGE! - takes most of screen)
Pins: GND, DIAL, PULSE
Attributes: (none)
Notes: Nostalgia/demo component - very large footprint
```

---

#### 10.4 Membrane Keypad (4×4 Matrix)
```
Type: wokwi-membrane-keypad
Size: Variable (depends on key count)
Pins: R1-R4 (rows), C1-C4 (columns)
Attributes: columns, connector, keys
Notes:
  - Matrix scanning requires 8 GPIOs (4 rows + 4 columns)
  - Or use keypad library with fewer GPIOs (not always possible)
  - Common in security systems, DIY phones
```

---

#### 10.5 LED Matrix (NeoPixel Matrix)
```
Type: wokwi-neopixel-matrix
Size: Variable (rows × cols × spacing)
Pins: GND, VCC, DIN, DOUT
Attributes: rows, cols, rowSpacing, colSpacing, blurLight, animation
Notes:
  - Grid of addressable RGB LEDs
  - Chainable like regular NeoPixel ring
  - DIN/DOUT for data in/out
  - Can create animations, scrolling text, games
```

---

#### 10.6 Slide Potentiometer (Linear Fader)
```
Type: wokwi-slide-potentiometer
Size: Variable width × 29mm height
Pins: VCC, SIG, GND
Attributes: travelLength, value, min, max, step
Notes: Like rotary pot but slides in straight line (audio mixer style)
```

---

### Practical Placement Rules

**Rule 1: Small components (Resistor, NeoPixel, Button)**
- Horizontal gap: 35-45 units between centers
- Vertical gap: 30-40 units between tops

**Rule 2: Medium components (LED, DHT22, PIR, Buzzer)**
- Horizontal gap: 50-70 units between centers
- Vertical gap: 40-55 units between tops

**Rule 3: Large components (OLED, LCD, HC-SR04, Servo)**
- Horizontal gap: 80-120 units between centers
- Vertical gap: 60-90 units between tops
- Consider placing at `left: 140+` to avoid crowding

**Rule 4: HUGE components (LCD1602, Rotary Dialer, LED Ring)**
- Place far right: `left: 160+` or below board: `top: 50+`
- Give 100+ unit gaps to anything else

---

### Part 1: Component Bounding Box Database

Use these dimensions for overlap detection (from parts.csv):

```
COMPONENT_BOUNDING_BOXES = {
  // Format: "type": { width_units, height_units, pin_offsets }
  
  // Passive Components
  "wokwi-resistor":           { w: 16, h: 3,  pins: { "1": [-8,0], "2": [8,0] } },
  "wokwi-potentiometer":      { w: 20, h: 20, pins: { "SIG": [0,-10], "VCC": [-10,0], "GND": [10,0] } },
  "wokwi-slide-potentiometer":{ w: 40, h: 29, pins: { "SIG": [20,0], "VCC": [0,0], "GND": [40,0] } },
  
  // LEDs & Lighting
  "wokwi-led":                { w: 40, h: 50, pins: { "A": [0,-25], "C": [0,25] } },
  "wokwi-rgb-led":            { w: 42, h: 73, pins: { "R": [-15,25], "G": [0,25], "B": [15,25], "COM": [0,-25] } },
  "wokwi-neopixel":           { w: 6,  h: 5,  pins: { "DIN": [-3,0], "DOUT": [3,0], "VDD": [0,-2.5], "VSS": [0,2.5] } },
  "wokwi-led-ring":           { w: 80, h: 80, pins: { "GND": [-40,0], "VCC": [40,0], "DIN": [0,-40] } }, // Approximate
  "wokwi-led-bar-graph":      { w: 10, h: 26, pins: { "A1": [0,12], "C1": [0,-12] } }, // Simplified
  
  // Buttons & Switches
  "wokwi-pushbutton":         { w: 18, h: 12, pins: { "1.l": [-9,0], "1.r": [9,0] } },
  "wokwi-pushbutton-6mm":     { w: 7,  h: 6,  pins: { "1.l": [-3.5,0], "1.r": [3.5,0] } },
  "wokwi-slide-switch":       { w: 9,  h: 9,  pins: { "1": [0,3], "2": [0,0], "3": [0,-3] } },
  "wokwi-dip-switch-8":       { w: 83, h: 55, pins: { "1a": [-40,27], "8a": [40,27] } }, // Approximate
  
  // Sensors
  "wokwi-dht22":              { w: 15, h: 31, pins: { "VCC": [-5,15], "SDA": [0,15], "GND": [5,15] } },
  "wokwi-hc-sr04":            { w: 45, h: 25, pins: { "VCC": [-20,12], "TRIG": [-7,12], "ECHO": [7,12], "GND": [20,12] } },
  "wokwi-pir-motion-sensor":  { w: 24, h: 24, pins: { "VCC": [-8,12], "OUT": [0,12], "GND": [8,12] } },
  "wokwi-flame-sensor":       { w: 53, h: 16, pins: { "VCC": [-22,8], "DOUT": [0,8], "GND": [22,8] } },
  "wokwi-gas-sensor":         { w: 36, h: 17, pins: { "AOUT": [-12,8], "DOUT": [0,8], "GND": [12,8], "VCC": [24,8] } },
  "wokwi-big-sound-sensor":   { w: 37, h: 13, pins: { "AOUT": [-18,6], "VCC": [0,6], "DOUT": [12,6], "GND": [24,6] } },
  "wokwi-small-sound-sensor": { w: 35, h: 13, pins: { "AOUT": [-17,6], "VCC": [0,6], "DOUT": [11,6], "GND": [23,6] } },
  "wokwi-photoresistor-sensor": { w: 46, h: 16, pins: { "VCC": [-20,8], "DO": [-7,8], "AO": [7,8], "GND": [20,8] } },
  "wokwi-ntc-temperature-sensor": { w: 36, h: 19, pins: { "VCC": [-12,9], "OUT": [0,9], "GND": [12,9] } },
  "wokwi-heart-beat-sensor":  { w: 23, h: 21, pins: { "VCC": [-7,10], "OUT": [0,10], "GND": [7,10] } },
  "wokwi-tilt-switch":        { w: 23, h: 15, pins: { "VCC": [-7,7], "OUT": [0,7], "GND": [7,7] } },
  "wokwi-analog-joystick":    { w: 27, h: 32, pins: { "VCC": [-13,16], "VERT": [0,16], "HORZ": [13,16], "SEL": [13,-16], "GND": [-13,-16] } },
  "wokwi-ky-040":             { w: 31, h: 19, pins: { "CLK": [-10,9], "DT": [0,9], "SW": [10,9], "VCC": [-10,-9], "GND": [10,-9] } },
  
  // Displays
  "wokwi-oled-i2c128x64":     { w: 150, h: 116, pins: { "SCL": [-75,58], "SDA": [-65,58], "VCC": [75,-58], "GND": [65,-58] } },
  "board-ssd1306":            { w: 28, h: 23, pins: { "GND": [-14,11], "VCC": [-14,-11], "SCL": [14,-11], "SDA": [14,11] } },
  "wokwi-lcd1602":            { w: 160, h: 80, pins: { "VSS": [-70,40], "VDD": [-50,40] } }, // Simplified
  "board-nokia-5110":         { w: 45, h: 45, pins: { "RST": [-22,22], "VCC": [0,22], "GND": [22,22] } },
  "wokwi-ili9341":            { w: 47, h: 78, pins: { "VCC": [-23,39], "GND": [-23,-39], "CS": [-15,39] } },
  "board-st7789":             { w: 32, h: 44, pins: { "GND": [-16,22], "VCC": [-16,-22], "SCL": [16,-22], "SDA": [16,22] } },
  "board-epaper-2in9":        { w: 90, h: 38, pins: { "BUSY": [-45,19], "RST": [-30,19], "DC": [-15,19] } },
  "wokwi-7segment":           { w: 60, h: 80, pins: { "A": [0,40], "B": [20,35], "C": [25,20] } }, // Approximate
  
  // Motors & Actuators
  "wokwi-servo":              { w: 40, h: 50, pins: { "PWM": [0,-25], "V+": [-20,0], "GND": [20,0] } },
  "wokwi-stepper-motor":      { w: 50, h: 50, pins: { "A-": [-25,0], "A+": [25,0], "B+": [0,25], "B-": [0,-25] } },
  
  // Communication Modules
  "wokwi-ir-receiver":        { w: 16, h: 23, pins: { "GND": [-8,11], "VCC": [0,11], "DAT": [8,11] } },
  "board-mfrc522":            { w: 59, h: 40, pins: { "SDA": [-29,20], "SCK": [-15,20], "MISO": [0,20], "MOSI": [15,20] } },
  "wokwi-ds1307":             { w: 26, h: 22, pins: { "GND": [-13,11], "5V": [13,11], "SDA": [0,-11], "SCL": [13,-11] } },
  "wokwi-mpu6050":            { w: 22, h: 16, pins: { "INT": [-11,8], "SDA": [0,8], "SCL": [11,8], "GND": [0,-8], "VCC": [11,-8] } },
  "board-ds18b20":            { w: 9,  h: 13, pins: { "GND": [-4,6], "DQ": [0,6], "VCC": [4,6] } },
  "board-lm35":               { w: 9,  h: 13, pins: { "VCC": [-4,6], "OUT": [0,6], "GND": [4,6] } },
  "board-bmp180":             { w: 18, h: 12, pins: { "VCC": [-9,6], "GND": [9,6], "SCL": [9,-6], "SDA": [0,-6] } },
  "board-grove-oled-sh1107":  { w: 45, h: 44, pins: { "GND.1": [-22,22], "VCC": [0,22], "SDA": [22,22], "SCL.1": [22,-22] } },
  "board-cd74hc4067":         { w: 16, h: 40, pins: { "COM": [-8,20], "S0": [8,20], "VCC": [8,-20], "GND": [-8,-20] } },
  
  // Storage & Audio
  "wokwi-microsd-card":       { w: 22, h: 20, pins: { "CD": [-11,10], "DO": [0,10], "GND": [11,10] } },
  "wokwi-buzzer":             { w: 17, h: 20, pins: { "1": [0,-10], "2": [0,10] } },
  
  // Specialty
  "wokwi-ks2e-m-dc5":         { w: 21, h: 10, pins: { "NO1": [-10,5], "NC1": [0,5], "P1": [10,5] } },
  "wokwi-hx711":              { w: 30, h: 30, pins: { "VCC": [-15,15], "DT": [0,15], "SCK": [15,15], "GND": [0,-15] } },
  "wokwi-membrane-keypad":    { w: 80, h: 80, pins: { "R1": [-40,40], "C1": [40,40] } }, // Approximate
  "wokwi-neopixel-matrix":    { w: 100, h: 100, pins: { "GND": [-50,50], "VCC": [50,50], "DIN": [0,-50] } }
}
```

**Note**: Pin offsets are relative to component center `(left + width/2, top + height/2)`


---

## Validation Checklist (v4.0)

**Component Verification:**
- [ ] Every component type exists in database above
- [ ] Pin names match EXACTLY from database (case-sensitive!)

**Placement Verification:**
- [ ] No overlapping components (visualize bounding boxes)

**Connection Verification:**
- [ ] Serial monitor TX/RX included
- [ ] All wire paths start with `["v0", ...]` (horizontal-first rule!)
- [ ] No wire has large initial vertical movement from board pins
- [ ] GND connections use nearest available GND pin
- [ ] Power connections use correct rail pins
- [ ] All referenced part IDs exist in parts array


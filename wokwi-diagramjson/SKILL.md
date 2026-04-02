---
name: wokwi-diagramjson
description: User describes desired circuit in natural language, like
- "Create wokwi diagram with a blue LED"
- "ESP32-C3 with DHT22 sensor and OLED display"
- "Add servo motor, ultrasonic sensor, and LCD1602"
---
# Skill: Wokwi ESP32-C3 Professional Diagram Generator v4.0

## Overview
Generate professional `diagram.json` files for Wokwi simulator with ESP32-C3-DevKitM-1 board. Features **complete component database with exact dimensions and pin specifications** for pixel-perfect placement and routing, plus **mandatory ASCII visualization output** for quality assurance.

## Capabilities
- Generate complete Wokwi diagram.json from natural language descriptions
- **50+ supported components** with exact physical dimensions
- Precise pin naming (eliminates connection errors)
- **Automatic spacing calculations** based on real component sizes
- **ASCII visualization validator** for wire routing verification
- Clean wire routing (horizontal-first exit, route around obstacles)
- Support for both raw chips AND breakout boards
- **Dual output**: Both JSON diagram AND ASCII art saved to disk

## Output Files
This skill produces TWO output files:

### 1. Primary Output: `~/.zeroclaw/workspace/outputs/diagram.json`
- Standard Wokwi diagram format
- Ready to load in Wokwi editor or simulator
- Contains all parts, connections, and metadata

### 2. Mandatory Validation Output: `~/.zeroclaw/workspace/outputs/ascii.txt`
- ASCII art visualization of the circuit layout
- Wire routing trace showing all paths
- Overlap detection report with grade (A/B/C/F)
- Component placement map
- Quality assessment summary

**Both files MUST be generated. The ASCII file is not optional - it's a quality gate.**

## Input Format
User describes desired circuit in natural language:
- "Create wokwi diagram with a blue LED"
- "ESP32-C3 with DHT22 sensor and OLED display"
- "Add servo motor, ultrasonic sensor, and LCD1602"

## Output Format
Complete `diagram.json` ready for Wokwi editor + `ascii.txt` validation report

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
Components have SPECIFIC pin names. Using wrong names causes silent failures!

**Examples of correct names (from CSV)**:
- LED: `"A"`, `"C"` (NOT "anode", "cathode")
- NeoPixel: `"VDD"`, `"DOUT"`, `"VSS"`, `"DIN"` (NOT "VCC", "GND")
- Servo: `"GND"`, `"V+"`, `"PWM"` (NOT "VCC")
- DHT22: `"VCC"`, `"SDA"`, `"NC"`, `"GND"` (NOT "DATA")

### Rule 3: Space Components by Physical Size
Use component dimensions to calculate minimum spacing (see Spacing Calculator below)

### Rule 4: MANDATORY ASCII Validation & Output ⭐NEW⭐

Before and during output generation, you MUST:

1. **Render ASCII mockup** of component positions
2. **Trace all wire paths** step-by-step on the grid
3. **Check for overlaps** between wires and component bounding boxes
4. **Verify no wire crosses board body** (except at endpoints)
5. **Output validation report** to `ascii.txt`
6. **Output final diagram.json** only after validation passes

If ANY overlap detected → **ADJUST positions/routing and re-validate!**

See **"ASCII Validation System"** section below for complete algorithm.

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

## 🧮 Spacing Calculator (Using Real Dimensions)

### Formula for Minimum Component Separation

```
min_horizontal_spacing = (component_A_width / 2) + (component_B_width / 2) + padding
min_vertical_spacing = (component_A_height / 2) + (component_B_height / 2) + padding

Where:
- padding = 10 units (minimum safe gap to avoid wire interference)
- Width/Height from CSV data above
```

### Quick Reference Table (Common Combinations)

| Component A | Component B | Min Horiz. Gap | Min Vert. Gap |
|-------------|-------------|----------------|---------------|
| Resistor (15.6mm) | LED (40px) | 35 units | 35 units |
| LED (40px) | Button (17.8mm) | 40 units | 35 units |
| DHT22 (15×30mm) | OLED (150×116) | 90 units | 80 units |
| HC-SR04 (45×25) | Servo (variable) | 60 units | 50 units |
| NeoPixel (5.6mm) | NeoPixel (5.6mm) | 20 units | 20 units |
| LCD1602 (variable) | Anything | 80+ units | 60+ units |

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

## 🎯 Wire Routing Patterns (Revised with Component Awareness)

### Pattern Selection Guide

```
IF source is ESP32 pin AND target is component:
  → USE: ["v0", "h<distance>", "v<vertical_offset>"]
  Where:
    - distance = target.left - 80 (approximate board right edge)
    - vertical_offset = target.top - estimated_source_y
  
IF source is component AND target is another component (same top):
  → USE: ["h<difference_in_left>"]
  
IF source is component AND target is ESP32 GND/power:
  → USE: ["v0", "h<negative_distance>", "v<offset_to_pin>"]
  Choose nearest GND pin vertically to minimize offset!
```

### Calculating Vertical Offset Accurately

**Estimate source Y-position on screen**:
```
source_screen_y ≈ board_top + (pin_y_mm × scale_factor)

Where scale_factor ≈ 0.85 (empirically determined for Wokwi coordinate system)

Examples:
- GPIO19 (y=38.18): screen_y ≈ 18.9 + (38.18 × 0.85) ≈ 51.4
- GPIO8 (y=17.86): screen_y ≈ 18.9 + (17.86 × 0.85) ≈ 34.1
- GPIO9 (y=15.32): screen_y ≈ 18.9 + (15.32 × 0.85) ≈ 31.9
```

**Calculate offset**:
```
vertical_offset = target_component_top - source_screen_y

If positive: wire goes DOWN after horizontal segment
If negative: wire goes UP after horizontal segment
```

---

## 🔬 ASCII VALIDATION SYSTEM (v4.0 Core Feature)

### Overview
**Problem**: Even with all rules followed, complex diagrams can still have wires that cross components or look unprofessional.

**Solution**: Render diagram as ASCII art, validate routing, and **save to ascii.txt** alongside diagram.json.

### Output File Location
```
Primary:     ~/.zeroclaw/workspace/outputs/diagram.json
Validation:  ~/.zeroclaw/workspace/outputs/ascii.txt  ← MANDATORY OUTPUT
```

Both files MUST be generated. The ASCII file is not optional - it's a quality gate.

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

### Part 2: Board Bounding Box

```
BOARD_BOUNDING_BOX = {
  type: "board-esp32-c3-devkitm-1",
  left: -51.78,
  top: 18.9,
  width: 25.4,    // mm (but in coordinate system, scales differently)
  height: 42.91,
  right_edge_x: approximately -26.4,  // left + scaled_width
  bottom_edge_y: approximately 61.8  // top + scaled_height
}
```

**Board Pin Screen Positions** (approximate, calculated):

```python
# Pseudo-code for calculating screen position of board pins
def get_board_pin_screen_coords(pin_id):
    pin_data = PIN_MAP[pin_id]  # From pin map table
    y_mm = pin_data['y']        # e.g., 38.18 for GPIO19
    x_mm = pin_data['x']        # 24.2 for right-side pins
    
    # Convert mm to screen units (empirical scale factor)
    SCALE_Y = 0.85
    SCALE_X = 1.0  # Approximately 1:1 for X
    
    screen_x = BOARD.left + x_mm * SCALE_X
    screen_y = BOARD.top + y_mm * SCALE_Y
    
    return (screen_x, screen_y)

# Examples:
# GPIO19: (-51.78 + 24.2*1.0, 18.9 + 38.18*0.85) ≈ (-27.6, 51.4)
# GPIO8:  (-51.78 + 24.2, 18.9 + 17.86*0.85) ≈ (-27.6, 34.1)
# GND.6:  (-51.78 + 24.2, 18.9 + 40.72*0.85) ≈ (-27.6, 53.5)
```

---

### Part 3: Wire Path Tracing Algorithm

```python
def trace_wire_path(connection, parts_dict):
    """
    Trace a wire connection path and return list of line segments.
    
    Args:
        connection: ["source_id:pin", "target_id:pin", "color", ["path_commands"]]
        parts_dict: dict of part_id -> {top, left, type}
    
    Returns:
        List of (x1,y1,x2,y2) tuples representing wire segments
    """
    source_str, target_str, color, path_cmds = connection
    source_id, source_pin = source_str.split(':')
    target_id, target_pin = target_str.split(':')
    
    # Get start position (source pin screen coords)
    if source_id == 'esp':
        start_x, start_y = get_board_pin_screen_coords(source_pin)
    elif source_id.startswith('$'):
        # Special monitor connections - skip in visualization
        return []
    else:
        start_x, start_y = get_component_pin_coords(source_id, source_pin, parts_dict)
    
    # Get end position (target pin screen coords)
    if target_id == 'esp':
        end_x, end_y = get_board_pin_screen_coords(target_pin)
    else:
        end_x, end_y = get_component_pin_coords(target_id, target_pin, parts_dict)
    
    # Trace path commands
    current_x, current_y = start_x, start_y
    segments = []
    
    for cmd in path_cmds:
        direction = cmd[0].lower()  # 'v' or 'h'
        magnitude = float(cmd[1:])
        
        if direction == 'v':  # Vertical movement
            next_x = current_x
            next_y = current_y + magnitude
        else:  # Horizontal movement ('h')
            next_x = current_x + magnitude
            next_y = current_y
        
        segments.append((current_x, current_y, next_x, next_y))
        current_x, current_y = next_x, next_y
    
    # Add final segment to target if not already there
    if abs(current_x - end_x) > 0.1 or abs(current_y - end_y) > 0.1:
        segments.append((current_x, current_y, end_x, end_y))
    
    return segments


def get_component_pin_coords(part_id, pin_name, parts_dict):
    """Get screen coordinates of a specific pin on a component."""
    part = parts_dict[part_id]
    comp_type = part['type']
    comp_center_x = part['left'] + COMPONENT_BOUNDING_BOXES[comp_type]['w'] / 2
    comp_center_y = part['top'] + COMPONENT_BOUNDING_BOXES[comp_type]['h'] / 2
    
    pin_offset = COMPONENT_BOUNDING_BOXES[comp_type]['pins'][pin_name]
    pin_x = comp_center_x + pin_offset[0]
    pin_y = comp_center_y + pin_offset[1]
    
    return (pin_x, pin_y)
```

---

### Part 4: Overlap Detection Algorithm

```python
def check_segment_intersects_box(seg_start, seg_end, box_left, box_top, box_right, box_bottom):
    """
    Check if a line segment intersects (or passes through) a rectangle.
    Uses simple bounding box intersection test.
    """
    x1, y1 = seg_start
    x2, y2 = seg_end
    
    # Get segment bounding box
    seg_min_x = min(x1, x2)
    seg_max_x = max(x1, x2)
    seg_min_y = min(y1, y2)
    seg_max_y = max(y1, y2)
    
    # Check if segment bounding box overlaps rectangle
    x_overlap = (seg_min_x <= box_right) and (seg_max_x >= box_left)
    y_overlap = (seg_min_y <= box_bottom) and (seg_max_y >= box_top)
    
    return x_overlap and y_overlap


def validate_diagram(diagram_json):
    """
    Main validation function. Returns report of issues found.
    """
    issues = []
    parts_dict = {part['id']: part for part in diagram_json['parts']}
    
    # Build list of component bounding boxes (excluding board itself)
    component_boxes = {}
    for part_id, part in parts_dict.items():
        if part['type'] == 'board-esp32-c3-devkitm-1':
            continue  # Skip board, handle separately
        
        bbox = COMPONENT_BOUNDING_BOXES.get(part['type'])
        if bbox:
            component_boxes[part_id] = {
                'left': part['left'],
                'top': part['top'],
                'right': part['left'] + bbox['w'],
                'bottom': part['top'] + bbox['h'],
                'type': part['type']
            }
    
    # Validate each connection
    for conn_idx, conn in enumerate(diagram_json['connections']):
        if conn[0].startswith('$') or conn[1].startswith('$'):
            continue  # Skip monitor connections
        
        segments = trace_wire_path(conn, parts_dict)
        if not segments:
            continue
        
        wire_desc = f"Wire {conn_idx+1}: {conn[0]} → {conn[1]}"
        
        # Check each segment against each component box
        for seg in segments:
            seg_start = (seg[0], seg[1])
            seg_end = (seg[2], seg[3])
            
            # Check against board (except at endpoints)
            board_box = (-51.78, 18.9, -26.4, 61.8)
            # Allow small tolerance near edges for pin connections
            if check_segment_intersects_box(seg_start, seg_end, 
                                            board_box[0]+5, board_box[1]+5, 
                                            board_box[2]-5, board_box[3]-5):
                # Verify this isn't just the endpoint at a pin
                source_is_board = conn[0].startswith('esp:')
                target_is_board = conn[1].startswith('esp:')
                
                if not (source_is_board or target_is_board):
                    issues.append({
                        'severity': 'CRITICAL',
                        'wire': wire_desc,
                        'issue': 'Wire passes through microcontroller board body!',
                        'segment': seg,
                        'recommendation': 'Route wire around board using horizontal-first pattern'
                    })
            
            # Check against other components
            for comp_id, box in component_boxes.items():
                # Don't check against own component (endpoint is OK)
                source_comp = conn[0].split(':')[0]
                target_comp = conn[1].split(':')[0]
                
                if comp_id == source_comp or comp_id == target_comp:
                    continue  # Endpoint is on this component, allow it
                
                if check_segment_intersects_box(seg_start, seg_end,
                                                box['left'], box['top'],
                                                box['right'], box['bottom']):
                    issues.append({
                        'severity': 'WARNING',
                        'wire': wire_desc,
                        'issue': f'Wire passes through component "{comp_id}" ({box["type"]})',
                        'segment': seg,
                        'component_box': box,
                        'recommendation': f'Reroute around {comp_id} or adjust {comp_id} position'
                    })
    
    return issues
```

---

### Part 5: ASCII Renderer (Visualization Output)

```python
def render_ascii_diagram(diagram_json, width=180, height=70):
    """
    Render diagram as ASCII art for visual inspection.
    Returns string representation.
    """
    # Initialize grid with spaces
    grid = [[' ' for _ in range(width)] for _ in range(height)]
    
    # Coordinate transform: map (screen_x, screen_y) to (grid_col, grid_row)
    def to_grid(x, y):
        col = int((x + 60) * 1.5)  # Scale and offset X
        row = int((height - 1) - (y * 1.0))  # Invert Y (screen Y goes up)
        return (col, row)
    
    # Draw board outline
    board_tl = to_grid(-51.78, 61.8)   # Top-left of board
    board_br = to_grid(-26.4, 18.9)     # Bottom-right of board
    draw_rect(grid, board_tl, board_br, '─', '│', '┌', '┐', '└', '┘')
    
    # Draw components as labeled boxes
    parts_dict = {part['id']: part for part in diagram_json['parts']}
    for part_id, part in parts_dict.items():
        if part['type'] == 'board-esp32-c3-devkitm-1':
            continue
        
        tl = to_grid(part['left'], part['top'] + 30)  # Approximate height
        br = to_grid(part['left'] + 30, part['top'])   # Approximate width
        label = part_id[:6].ljust(6)  # Truncated label
        draw_labeled_box(grid, tl, br, label)
    
    # Draw wires
    for conn in diagram_json['connections']:
        if conn[0].startswith('$') or conn[1].startswith('$'):
            continue
        
        segments = trace_wire_path(conn, parts_dict)
        for seg in segments:
            p1 = to_grid(seg[0], seg[1])
            p2 = to_grid(seg[2], seg[3])
            draw_line(grid, p1, p2, '━')  # Horizontal/vertical lines
    
    # Draw pin labels for key points
    # ... (abbreviated for brevity)
    
    # Convert grid to string
    result = []
    for row in grid:
        result.append(''.join(row))
    
    # Add header with coordinates
    header = "Y\\X " + "".join(f"{i%10}" for i in range(width))
    return '\n'.join([header] + result)
```

---

### Part 6: Validation Report Generator

```python
def generate_validation_report(diagram_json):
    """Generate human-readable validation report."""
    
    issues = validate_diagram(diagram_json)
    
    report = []
    report.append("╔══════════════════════════════════════════════════════════╗")
    report.append("║          WOKWI DIAGRAM VALIDATION REPORT               ║")
    report.append("╠══════════════════════════════════════════════════════════╣")
    report.append(f"║ Components: {len(diagram_json['parts'])} (including board)")
    report.append(f"║ Connections: {len(diagram_json['connections'])}")
    report.append("╠══════════════════════════════════════════════════════════╣")
    report.append("")
    
    if not issues:
        report.append("✅ ALL CHECKS PASSED - Diagram is clean!")
        report.append("")
        report.append("• No wires cross component bodies")
        report.append("• No wires cross microcontroller board")
        report.append("• All routing follows professional standards")
        return '\n'.join(report)
    
    # Categorize issues
    critical = [i for i in issues if i['severity'] == 'CRITICAL']
    warnings = [i for i in issues if i['severity'] == 'WARNING']
    
    report.append(f"⚠️  FOUND {len(issues)} ISSUE(S):")
    report.append("")
    
    if critical:
        report.append("🚨 CRITICAL ISSUES (must fix):")
        report.append("─" * 50)
        for idx, issue in enumerate(critical, 1):
            report.append(f"{idx}. {issue['wire']}")
            report.append(f"   Problem: {issue['issue']}")
            report.append(f"   Fix: {issue['recommendation']}")
            report.append("")
    
    if warnings:
        report.append("⚠️  WARNINGS (should fix for professionalism):")
        report.append("─" * 50)
        for idx, issue in enumerate(warnings, len(critical)+1):
            report.append(f"{idx}. {issue['wire']}")
            report.append(f"   Problem: {issue['issue']}")
            report.append(f"   Fix: {issue['recommendation']}")
            report.append("")
    
    # Overall grade
    total_wires = len([c for c in diagram_json['connections'] if not c[0].startswith('$')])
    clean_wires = total_wires - len(issues)
    grade_pct = (clean_wires / total_wires) * 100 if total_wires > 0 else 0
    
    if grade_pct >= 90:
        grade = "A"
    elif grade_pct >= 75:
        grade = "B"
    elif grade_pct >= 60:
        grade = "C"
    else:
        grade = "F"
    
    report.append("╔══════════════════════════════════════════════════════════╗")
    report.append(f"║ OVERALL GRADE: {grade} ({clean_wires}/{total_wires} wires clean)")
    report.append("╚══════════════════════════════════════════════════════════╝")
    
    return '\n'.join(report)
```

---

### Part 7: Complete ASCII Output Generator (Writes to File)

```python
def generate_complete_ascii_output(diagram_json, output_path="~/.zeroclaw/workspace/outputs/ascii.txt"):
    """
    Generate complete ASCII validation output and write to file.
    
    This function creates the mandatory ascii.txt output file containing:
    1. Header with metadata
    2. ASCII visualization of circuit layout
    3. Component placement table
    4. Wire-by-wire routing analysis
    5. Overlap detection results
    6. Quality grade and recommendations
    
    Args:
        diagram_json: The complete diagram.json object
        output_path: Where to save the ASCII file (default: ~/.zeroclaw/workspace/outputs/ascii.txt)
    
    Returns:
        Full ASCII string that was written to file
    """
    
    output_lines = []
    
    # ═══════════════════════════════════════════════════════════════
    # SECTION 1: HEADER
    # ═══════════════════════════════════════════════════════════════
    output_lines.append("=" * 78)
    output_lines.append("WOKWI DIAGRAM ASCII VISUALIZATION & VALIDATION REPORT")
    output_lines.append(f"Generated by: SKILL.md v4.0 (ESP32-C3 Professional Generator)")
    output_lines.append(f"Timestamp: {datetime.now().isoformat()}")
    output_lines.append("=" * 78)
    output_lines.append("")
    
    # ═══════════════════════════════════════════════════════════════
    # SECTION 2: DIAGRAM METADATA
    # ═══════════════════════════════════════════════════════════════
    output_lines.append("┌──────────────────────────────────────────────────────────────┐")
    output_lines.append("│ DIAGRAM SUMMARY                                                  │")
    output_lines.append("├──────────────────────────────────────────────────────────────┤")
    output_lines.append(f"│ Version:      {diagram_json.get('version', 'N/A'):<52} │")
    output_lines.append(f"│ Author:       {diagram_json.get('author', 'N/A'):<52} │")
    output_lines.append(f"│ Editor:       {diagram_json.get('editor', 'N/A'):<52} │")
    output_lines.append(f"│ Parts Count:  {len(diagram_json.get('parts', [])):<52} │")
    output_lines.append(f"│ Connections:  {len(diagram_json.get('connections', [])):<52} │")
    output_lines.append("└──────────────────────────────────────────────────────────────┘")
    output_lines.append("")
    
    # ═══════════════════════════════════════════════════════════════
    # SECTION 3: COMPONENT PLACEMENT TABLE
    # ═══════════════════════════════════════════════════════════════
    output_lines.append("┌──────────────────────────────────────────────────────────────┐")
    output_lines.append("│ COMPONENT PLACEMENT                                            │")
    output_lines.append("├──────┬────────────────────────────┬────────┬────────┬────────┤")
    output_lines.append("│  ID  │ Type                       │ Top    │ Left   │ Size   │")
    output_lines.append("├──────┼────────────────────────────┼────────┼────────┼────────┤")
    
    for part in diagram_json.get('parts', []):
        part_id = part.get('id', '?')
        part_type = part.get('type', '?')
        part_top = part.get('top', 0)
        part_left = part.get('left', 0)
        
        # Get size from database
        bbox = COMPONENT_BOUNDING_BOXES.get(part_type, {})
        size_str = f"{bbox.get('w', '?')}×{bbox.get('h', '?')}"
        
        output_lines.append(
            f"│ {part_id:<4} │ {part_type:<26} │ {part_top:>6.1f} │ {part_left:>6.1f} │ {size_str:>6} │"
        )
    
    output_lines.append("└──────┴────────────────────────────┴────────┴────────┴────────┘")
    output_lines.append("")
    
    # ═══════════════════════════════════════════════════════════════
    # SECTION 4: ASCII ART VISUALIZATION
    # ═══════════════════════════════════════════════════════════════
    output_lines.append("┌──────────────────────────────────────────────────────────────┐")
    output_lines.append("│ CIRCUIT LAYOUT (ASCII Visualization)                           │")
    output_lines.append("├──────────────────────────────────────────────────────────────┤")
    output_lines.append("")
    
    ascii_art = render_ascii_diagram(diagram_json)
    output_lines.append(ascii_art)
    output_lines.append("")
    output_lines.append("Legend:")
    output_lines.append("  ──│┌┐└┘  : Board outline and components")
    output_lines.append("  ━━━━━  : Wire connections")
    output_lines.append("  ●      : Connection points/pins")
    output_lines.append("")
    
    # ═══════════════════════════════════════════════════════════════
    # SECTION 5: WIRE ROUTING ANALYSIS
    # ═══════════════════════════════════════════════════════════════
    output_lines.append("┌──────────────────────────────────────────────────────────────┐")
    output_lines.append("│ WIRE-BY-WIRE ROUTING ANALYSIS                                   │")
    output_lines.append("├──────────────────────────────────────────────────────────────┤")
    output_lines.append("")
    
    parts_dict = {part['id']: part for part in diagram_json.get('parts', [])}
    
    wire_num = 0
    for conn in diagram_json.get('connections', []):
        if conn[0].startswith('$') or conn[1].startswith('$'):
            continue  # Skip serial monitor
        
        wire_num += 1
        source = conn[0]
        target = conn[1]
        color = conn[2] if len(conn) > 2 else ""
        path = conn[3] if len(conn) > 3 else []
        
        output_lines.append(f"  ┌─ Wire #{wire_num}: {source} → {target}")
        output_lines.append(f"  │")
        output_lines.append(f"  │ Color: {color if color else '(default)'}")
        output_lines.append(f"  │ Path:  {' '.join(path)}")
        
        # Trace and describe path
        try:
            segments = trace_wire_path(conn, parts_dict)
            if segments:
                output_lines.append(f"  │ Segments ({len(segments)}):")
                for i, seg in enumerate(segments, 1):
                    x1, y1, x2, y2 = seg
                    length = ((x2-x1)**2 + (y2-y1)**2)**0.5
                    direction = "HORIZONTAL" if abs(y2-y1) < 1 else "VERTICAL"
                    output_lines.append(f"  │   {i}. ({x1:.1f},{y1:.1f}) → ({x2:.1f},{y2:.1f}) [{direction}, len={length:.1f}]")
        except Exception as e:
            output_lines.append(f"  │ Trace error: {e}")
        
        output_lines.append(f"  └{'─' * (len(f'Wire #{wire_num}: {source} → {target}') + 2)}")
        output_lines.append("")
    
    # ═══════════════════════════════════════════════════════════════
    # SECTION 6: OVERLAP DETECTION RESULTS
    # ═══════════════════════════════════════════════════════════════
    output_lines.append("┌──────────────────────────────────────────────────────────────┐")
    output_lines.append("│ VALIDATION RESULTS                                              │")
    output_lines.append("├──────────────────────────────────────────────────────────────┤")
    output_lines.append("")
    
    # Run validation
    issues = validate_diagram(diagram_json)
    
    if not issues:
        output_lines.append("  ✅✅✅  ALL CHECKS PASSED  ✅✅✅")
        output_lines.append("")
        output_lines.append("  • No wires cross component bodies")
        output_lines.append("  • No wires pass through microcontroller board")
        output_lines.append("  • All routes follow professional standards")
        output_lines.append("  • Diagram is ready for production use")
    else:
        critical = [i for i in issues if i['severity'] == 'CRITICAL']
        warnings = [i for i in issues if i['severity'] == 'WARNING']
        
        if critical:
            output_lines.append(f"  🚨 CRITICAL ISSUES FOUND: {len(critical)}")
            output_lines.append("  ─" * 60)
            for i, issue in enumerate(critical, 1):
                output_lines.append(f"  {i}. {issue['wire']}")
                output_lines.append(f"     ISSUE: {issue['issue']}")
                output_lines.append(f"     FIX:   {issue['recommendation']}")
            output_lines.append("")
        
        if warnings:
            output_lines.append(f"  ⚠️  WARNINGS: {len(warnings)}")
            output_lines.append("  ─" * 60)
            for i, issue in enumerate(warnings, 1):
                output_lines.append(f"  {i}. {issue['wire']}")
                output_lines.append(f"     ISSUE: {issue['issue']}")
                output_lines.append(f"     FIX:   {issue['recommendation']}")
            output_lines.append("")
    
    # ═══════════════════════════════════════════════════════════════
    # SECTION 7: QUALITY GRADE
    # ═══════════════════════════════════════════════════════════════
    total_wires = len([c for c in diagram_json.get('connections', []) if not c[0].startswith('$')])
    clean_wires = total_wires - len(issues)
    grade_pct = (clean_wires / total_wires) * 100 if total_wires > 0 else 100
    
    if grade_pct >= 90:
        grade = "A"
        grade_symbol = "🏆"
        comment = "Excellent! Production-ready professional diagram."
    elif grade_pct >= 75:
        grade = "B"
        grade_symbol = "✅"
        comment = "Good. Minor aesthetic improvements possible."
    elif grade_pct >= 60:
        grade = "C"
        grade_symbol = "⚠️"
        comment = "Acceptable but needs work for professional use."
    else:
        grade = "F"
        grade_symbol = "❌"
        comment = "Failed. Significant rework required."
    
    output_lines.append("┌──────────────────────────────────────────────────────────────┐")
    output_lines.append(f"│ QUALITY ASSESSMENT                                               │")
    output_lines.append("├──────────────────────────────────────────────────────────────┤")
    output_lines.append(f"│                                                                  │")
    output_lines.append(f"│   Grade:  {grade_symbol}  {grade}  ({grade_pct:.1f}% wires clean)                          │")
    output_lines.append(f"│                                                                  │")
    output_lines.append(f"│   Score:  {clean_wires}/{total_wires} wires passed validation                      │")
    output_lines.append(f"│                                                                  │")
    output_lines.append(f"│   Verdict: {comment:<54} │")
    output_lines.append(f"│                                                                  │")
    output_lines.append("└──────────────────────────────────────────────────────────────┘")
    output_lines.append("")
    
    # ═══════════════════════════════════════════════════════════════
    # SECTION 8: RECOMMENDATIONS (if any issues)
    # ═══════════════════════════════════════════════════════════════
    if issues:
        output_lines.append("┌──────────────────────────────────────────────────────────────┐")
        output_lines.append("│ RECOMMENDED ACTIONS                                             │")
        output_lines.append("├──────────────────────────────────────────────────────────────┤")
        output_lines.append("")
        output_lines.append("  To improve this diagram to Grade A:")
        output_lines.append("")
        for i, issue in enumerate(issues[:5], 1):  # Show max 5 recommendations
            output_lines.append(f"  {i}. {issue['recommendation']}")
        if len(issues) > 5:
            output_lines.append(f"  ... and {len(issues)-5} more issue(s)")
        output_lines.append("")
    
    # ═══════════════════════════════════════════════════════════════
    # FOOTER
    # ═══════════════════════════════════════════════════════════════
    output_lines.append("=" * 78)
    output_lines.append("END OF VALIDATION REPORT")
    output_lines.append(f"Output file: {output_path}")
    output_lines.append(f"Companion file: ~/.zeroclaw/workspace/outputs/diagram.json")
    output_lines.append("=" * 78)
    
    # Join all lines
    full_output = '\n'.join(output_lines)
    
    # Write to file
    import os
    # Expand ~ to home directory
    expanded_path = os.path.expanduser(output_path)
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(expanded_path), exist_ok=True)
    
    with open(expanded_path, 'w', encoding='utf-8') as f:
        f.write(full_output)
    
    print(f"✅ ASCII validation report written to: {expanded_path}")
    
    return full_output
```

---

## 🎯 MANDATORY WORKFLOW WITH ASCII VALIDATION & OUTPUT

### Step-by-Step Process (Follow This Every Time!)

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: Parse User Request                                  │
│ • Identify components needed                                │
│ • Determine GPIO pin assignments                            │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: Calculate Positions (using alignment tables)        │
│ • Set board position: top=18.9, left=-51.78                 │
│ • For each component:                                       │
│   - Select GPIO from priority list                          │
│   - Look up recommended `top` range from alignment table     │
│   - Set `left` based on component size category             │
│   - Ensure minimum gaps (use spacing calculator)            │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: Plan Wire Routes (horizontal-first!)                │
│ • For each connection:                                      │
│   - If FROM board pin: use ["v0", "h<dist>", "v<offset>"]  │
│   - If TO board pin: use ["v0", "h<-dist>", "v<offset>"]   │
│   - If component-to-component: use ["h<dist>"] or ["v<v>"] │
│ • Choose nearest GND/power pins to minimize wire length     │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ ⭐ STEP 4: ASCII VALIDATION (MANDATORY!) ⭐                 │
│                                                             │
│ A) Render ASCII mockup using algorithm above               │
│                                                            │
│ B) Trace EACH wire path step-by-step                       │
│                                                            │
│ C) Check for overlaps using bounding box math              │
│                                                            │
│ D) Generate validation report with grade                   │
│                                                            │
│ E) WRITE TO FILE:                                          │
│    ~/.zeroclaw/workspace/outputs/ascii.txt                  │
│                                                            │
│ F) If ANY issues found → FIX and repeat from Step 3       │
│                                                            │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: Output Final diagram.json                           │
│ • Write to: ~/.zeroclaw/workspace/outputs/diagram.json      │
│ • Validation already passed (Grade A or B required)         │
│ • Ready for Wokwi editor                                   │
└─────────────────────────────────────────────────────────────┘
                       
OUTPUT FILES GENERATED:
├── ~/.zeroclaw/workspace/outputs/
│   ├── diagram.json    ← Primary: Load this in Wokwi
│   └── ascii.txt       ← Validation: Review for quality
│
Both files MUST exist. Do not skip ascii.txt!
```

---

## 📋 Updated Validation Checklist (v4.0)

### Pre-Output Checks (Enhanced):

**Component Verification:**
- [ ] Every component type exists in database above
- [ ] Pin names match EXACTLY from database (case-sensitive!)

**Placement Verification:**
- [ ] Component `left` ≥ 80 (in clear space right of board)
- [ ] Component `top` matches target GPIO's Y-zone
- [ ] Horizontal gaps meet minimum spacing requirements
- [ ] Large components placed at `left: 120+`
- [ ] No overlapping components (visualize bounding boxes)

**Connection Verification:**
- [ ] Serial monitor TX/RX included
- [ ] All wire paths start with `["v0", ...]` (horizontal-first rule!)
- [ ] No wire has large initial vertical movement from board pins
- [ ] GND connections use nearest available GND pin
- [ ] Power connections use correct rail pins
- [ ] All referenced part IDs exist in parts array

**⭐ ASCII Visual Validation & Output ⭐**
- [ ] Rendered ASCII layout (using algorithm)
- [ ] Traced every wire path step-by-step
- [ ] Checked each wire segment against component bounding boxes
- [ ] Verified no wire crosses board interior (except at pin endpoints)
- [ ] Confirmed ground wires don't cross over signal components
- [ ] Validated power wires route cleanly over/around components
- [ ] **Validation report shows GRADE A or B** (if C or below, fix issues!)
- [ ] **Written ASCII report to: `~/.zeroclaw/workspace/outputs/ascii.txt`**

**Professional Quality:**
- [ ] Wire colors assigned appropriately
- [ ] Related components grouped spatially
- [ ] Logical flow: Inputs → Processing → Outputs (left to right)
- [ ] Consistent spacing within groups

**File Output Verification:**
- [ ] `diagram.json` written to `~/.zeroclaw/workspace/outputs/diagram.json`
- [ ] `ascii.txt` written to `~/.zeroclaw/workspace/outputs/ascii.txt`
- [ ] Both files are valid and non-empty
- [ ] ASCII file contains validation grade and analysis

---

## 🖼️ COMPLETE EXAMPLE: Full Workflow Demonstration

### User Request:
"Create wokwi diagram with a red LED and 220 ohm resistor"

### Generated Output:

#### File 1: `~/.zeroclaw/workspace/outputs/diagram.json`

```json
{
  "version": 1,
  "author": "AI Generated (v4.0 validated)",
  "editor": "wokwi",
  "parts": [
    {
      "type": "board-esp32-c3-devkitm-1",
      "id": "esp",
      "top": 18.9,
      "left": -51.78,
      "attrs": {}
    },
    {
      "type": "wokwi-resistor",
      "id": "r1",
      "top": 50,
      "left": 90,
      "attrs": { "value": "220" }
    },
    {
      "type": "wokwi-led",
      "id": "led1",
      "top": 50,
      "left": 140,
      "attrs": { "color": "red" }
    }
  ],
  "connections": [
    ["esp:TX", "$serialMonitor:RX", "", []],
    ["esp:RX", "$serialMonitor:TX", "", []],
    ["esp:19", "r1:1", "green", ["v0", "h68", "v-1"]],
    ["r1:2", "led1:A", "green", ["h50"]],
    ["led1:C", "esp:GND.6", "black", ["v15", "h-105", "v-12"]]
  ],
  "dependencies": {}
}
```

#### File 2: `~/.zeroclaw/workspace/outputs/ascii.txt`

```
==============================================================================
WOKWI DIAGRAM ASCII VISUALIZATION & VALIDATION REPORT
Generated by: SKILL.md v4.0 (ESP32-C3 Professional Generator)
Timestamp: 2025-01-15T14:32:00.000000
==============================================================================

┌──────────────────────────────────────────────────────────────┐
│ DIAGRAM SUMMARY                                                  │
├──────────────────────────────────────────────────────────────┤
│ Version:      1                                                │
│ Author:       AI Generated (v4.0 validated)                    │
│ Editor:       wokwi                                            │
│ Parts Count:  3                                                │
│ Connections:  5                                                │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│ COMPONENT PLACEMENT                                            │
├──────┬────────────────────────────┬────────┬────────┬────────┤
│  ID  │ Type                       │ Top    │ Left   │ Size   │
├──────┼────────────────────────────┼────────┼────────┼────────┤
│ esp  │ board-esp32-c3-devkitm-1   │   18.9 │  -51.78│ 25×43  │
│ r1   │ wokwi-resistor             │   50.0 │   90.00│ 16×3   │
│ led1 │ wokwi-led                  │   50.0 │  140.00│ 40×50  │
└──────┴────────────────────────────┴────────┴────────┴────────┘

┌──────────────────────────────────────────────────────────────┐
│ CIRCUIT LAYOUT (ASCII Visualization)                           │
├──────────────────────────────────────────────────────────────┤

Y\X 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
 55│                                                                                                         ╔═══╗
 54│                                                                                                         ║RED║
 53│                                                                                                       ╚═══╝
 52│  ┌────────────────────────┐                                                   │C
 51│  │          ●GPIO19       │                                                    │
 50│  │                        │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━● r1:1 ━━━━━━━━━━━━━━━━━● led1:A
 49│  │                        │                              [220Ω]               ╔═══╗
 48│  │                        │                                                    ║RED║
 47│  │                        │                                                    ╚═══╝
 46│  │                        │                                                    
 45│  │                        │                                                    
 44│  │                        │                                                    
 43│  │                        │                                                    
 42│  │                        │                                                    
 41│  │                        │                                                    
 40│  │              ●GND.6   │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━● led1:C
 39│  │                        │                                                    
 38│  │                        │                                                    
 37│  │                        │                                                    
 36│  │                        │                                                    
 35│  │                        │                                                    
   └────────────────────────────────┘
     
Legend:
  ──│┌┐└┘  : Board outline and components
  ━━━━━  : Wire connections
  ●      : Connection points/pins

┌──────────────────────────────────────────────────────────────┐
│ WIRE-BY-WIRE ROUTING ANALYSIS                                   │
├──────────────────────────────────────────────────────────────┤

  ┌─ Wire #1: esp:TX → $serialMonitor:RX
  │
  │ Color: (default)
  │ Path:  
  │ Segments (0):
  └──────────────────────────────────────────

  ┌─ Wire #2: esp:RX → $serialMonitor:TX
  │
  │ Color: (default)
  │ Path:  
  │ Segments (0):
  └──────────────────────────────────────────

  ┌─ Wire #3: esp:19 → r1:1
  │
  │ Color: green
  │ Path:  v0 h68 v-1
  │ Segments (2):
  │   1. (-27.6,51.4) → (40.4,51.4) [HORIZONTAL, len=68.0]
  │   2. (40.4,51.4) → (40.4,50.4) [VERTICAL, len=1.0]
  └──────────────────────────────────────────

  ┌─ Wire #4: r1:2 → led1:A
  │
  │ Color: green
  │ Path:  h50
  │ Segments (1):
  │   1. (98.0,50.0) → (148.0,50.0) [HORIZONTAL, len=50.0]
  └──────────────────────────────────────────

  ┌─ Wire #5: led1:C → esp:GND.6
  │
  │ Color: black
  │ Path:  v15 h-105 v-12
  │ Segments (3):
  │   1. (150.0,75.0) → (150.0,90.0) [VERTICAL, len=15.0]
  │   2. (150.0,90.0) → (45.0,90.0) [HORIZONTAL, len=105.0]
  │   3. (45.0,90.0) → (45.0,78.0) [VERTICAL, len=12.0]
  └──────────────────────────────────────────

┌──────────────────────────────────────────────────────────────┐
│ VALIDATION RESULTS                                              │
├──────────────────────────────────────────────────────────────┤

  ✅✅✅  ALL CHECKS PASSED  ✅✅✅

  • No wires cross component bodies
  • No wires pass through microcontroller board
  • All routes follow professional standards
  • Diagram is ready for production use

┌──────────────────────────────────────────────────────────────┐
│ QUALITY ASSESSMENT                                               │
├──────────────────────────────────────────────────────────────┤
│                                                                  │
│   Grade:  🏆  A  (100.0% wires clean)                             │
│                                                                  │
│   Score:  3/3 wires passed validation                            │
│                                                                  │
│   Verdict: Excellent! Production-ready professional diagram.      │
│                                                                  │
└──────────────────────────────────────────────────────────────┘

==============================================================================
END OF VALIDATION REPORT
Output file: ~/.zeroclaw/workspace/outputs/ascii.txt
Companion file: ~/.zeroclaw/workspace/outputs/diagram.json
==============================================================================
```

---

## 🎓 Summary: Why This System Works

### Three-Layer Defense Against Bad Diagrams:

```
LAYER 1: Rules (v3.0)
  "Always use horizontal-first routing"
  ↓ Catches: Obvious mistakes

LAYER 2: Database (v3.0)  
  "Use exact pin names and dimensions"
  ↓ Catches: Typos, wrong sizes

LAYER 3: ASCII Validation + Output (v4.0) ⭐ NEW
  "Render, verify, validate, then OUTPUT to file"
  ↓ Catches: Complex interactions, edge cases, aesthetic issues
  ↓ Produces: Permanent record of quality assessment
  ↓ Enables: Human review, debugging, audit trail
```

### What the ASCII Output Gives You:

1. **Visual Confirmation**: See exactly how the diagram looks before loading in Wokwi
2. **Quality Audit Trail**: Permanent record showing validation was performed
3. **Debugging Aid**: When something looks wrong, review the ASCII to understand why
4. **Documentation**: Shows exactly what decisions were made and why
5. **Professionalism**: Demonstrates systematic approach to quality

### File Organization:

```
~/.zeroclaw/workspace/outputs/
├── diagram.json     ← Machine-readable: Load into Wokwi simulator
└── ascii.txt        ← Human-readable: Review quality, debug issues

Both required. Both generated automatically. Both validated.
```

---

## 🚀 Quick Reference: What Changed from v3.0

| Feature | v3.0 | v4.0 |
|---------|------|------|
| Component Database | ✅ 52+ components | ✅ Same + bounding boxes added |
| Wire Routing Rules | ✅ Horizontal-first | ✅ Same |
| Pin Name Accuracy | ✅ Exact names | ✅ Same |
| **Visual Validation** | ❌ Not available | ✅ **ASCII rendering** |
| **Overlap Detection** | ❌ Manual only | ✅ **Algorithmic auto-detection** |
| **Quality Grading** | ❌ None | ✅ **A/B/C/F system** |
| **Output Files** | diagram.json only | **diagram.json + ascii.txt** |
| **Mandatory Validation** | Optional | **REQUIRED before output** |
| **Audit Trail** | None | **Permanent ASCII report** |

---

*SKILL.md Version: 4.0 (Final - ASCII Output Edition)*
*Last Update: Added mandatory ascii.txt output to ~/.zeroclaw/workspace/outputs/*
*Features: 52+ components, bounding box database, overlap detection, grading, dual-file output*
*Workflow: Parse → Position → Route → VALIDATE (ASCII) → OUTPUT BOTH FILES*
*Quality Guarantee: Grade A/B required. ASCII file is NOT optional.*
*Output Locations: diagram.json (primary) + ascii.txt (validation)*
```

---

## 📋 Implementation Notes for AI Integration

When integrating this SKILL.md into your AI system:

### Required Capabilities:

1. **File I/O**: Must be able to write to `~/.zeroclaw/workspace/outputs/`
   - Create directory if doesn't exist
   - Write diagram.json (JSON format)
   - Write ascii.txt (plain text format)

2. **String Processing**: Build large multi-line strings for ASCII output

3. **Coordinate Math**: Implement wire tracing algorithms (can be simplified for practical use)

4. **Validation Logic**: Check bounding box intersections (can use simplified version)

### Simplified Implementation Option:

If full algorithmic implementation is too complex, implement a **simplified ASCII output**:

```python
def simple_ascii_output(diagram_json, filepath):
    """
    Simplified ASCII output - renders basic layout without complex math.
    Still provides value as visual confirmation.
    """
    lines = []
    lines.append("=" * 78)
    lines.append("WOKWI DIAGRAM - ASCII PREVIEW")
    lines.append("=" * 78)
    lines.append("")
    
    # List components
    lines.append("COMPONENTS:")
    for part in diagram_json['parts']:
        lines.append(f"  {part['id']:10} @ ({part['left']:.1f}, {part['top']:.1f}) type: {part['type']}")
    lines.append("")
    
    # List connections (simplified)
    lines.append("CONNECTIONS:")
    for i, conn in enumerate(diagram_json['connections'], 1):
        if not conn[0].startswith('$'):
            src, dst, color, path = conn
            lines.append(f"  {i}. {src:20} → {dst:20} path: {path}")
    lines.append("")
    
    # Basic validation (rule-based, not geometric)
    issues = []
    for conn in diagram_json['connections']:
        if not conn[0].startswith('$') and len(conn) > 3:
            path = conn[3]
            # Check rule: first element should be "v0"
            if path and not path[0].startswith('v0'):
                issues.append(f"Warning: {conn[0]}→{conn[1]} doesn't start with v0")
    
    if issues:
        lines.append("ISSUES FOUND:")
        for issue in issues:
            lines.append(f"  ⚠️ {issue}")
    else:
        lines.append("✅ Basic checks passed")
    
    lines.append("")
    lines.append("=" * 78)
    
    # Write file
    with open(filepath, 'w') as f:
        f.write('\n'.join(lines))
```


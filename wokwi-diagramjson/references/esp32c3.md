## ESP32-C3 DevKitM-1 Board

**Type:** `board-esp32-c3-devkitm-1`

**Pin Names (J1 Header - left side):**
| Pin | Name | Function |
|-----|------|----------|
| 1 | GND | Ground |
| 2 | 3V3 | 3.3V power |
| 3 | 3V3 | 3.3V power |
| 4 | IO2 | GPIO2, ADC1_CH2, FSPIQ |
| 5 | IO3 | GPIO3, ADC1_CH3 |
| 6 | GND | Ground |
| 7 | RST | CHIP_PU (reset) |
| 8 | GND | Ground |
| 9 | IO0 | GPIO0, ADC1_CH0, XTAL_32K_P |
| 10 | IO1 | GPIO1, ADC1_CH1, XTAL_32K_N |
| 11 | IO10 | GPIO10, FSPICS0 |
| 12 | GND | Ground |
| 13 | 5V | 5V power |
| 14 | 5V | 5V power |
| 15 | GND | Ground |

**Pin Names (J3 Header - right side):**
| Pin | Name | Function |
|-----|------|----------|
| 1 | GND | Ground |
| 2 | TX | GPIO21, U0TXD |
| 3 | RX | GPIO20, U0RXD |
| 4 | GND | Ground |
| 5 | IO9 | GPIO9 (strapping pin) |
| 6 | IO8 | GPIO8, RGB LED (strapping pin) |
| 7 | GND | Ground |
| 8 | IO7 | GPIO7, FSPID, MTDO |
| 9 | IO6 | GPIO6, FSPICLK, MTCK |
| 10 | IO5 | GPIO5, ADC2_CH0, FSPIWP, MTDI |
| 11 | IO4 | GPIO4, ADC1_CH4, FSPIHD, MTMS |
| 12 | GND | Ground |
| 13 | IO18 | GPIO18, USB_D- |
| 14 | IO19 | GPIO19, USB_D+ |
| 15 | GND | Ground |

**Board Attributes:**
| Attribute | Description | Default |
|-----------|-------------|---------|
| `flashSize` | Flash size in MB (\"2\", \"4\", \"8\", \"16\", \"32\") | \"4\" |
| `serialInterface` | Set to \"USB_SERIAL_JTAG\" for USB CDC | \"\" |
| `firmwareOffset` | Custom firmware offset in bytes | \"\" |
| `macAddress` | WiFi MAC address | \"24:0a:c4:00:01:10\" |
| `cpuFrequency` | Max CPU freq (\"auto\", \"16\", \"max\") | \"auto\" |



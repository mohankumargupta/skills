---
name: wokwi-chipjson
description: Create wokwi chip.json from canonical test specification for device <device>
---

# Context Variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is <original_pwd>/artifacts/<device>/prompt2b, you will need to create this.
<name_of_esphome_component>: content of <original_pwd>/artifacts/<device>/prompt0b/esphome_component.txt 
<esphome_component_code>: <original_pwd>/artifacts/<device>/prompt0b/<name_of_esphome_component>
<spec>: <original_pwd>/artifacts/<device>/prompt2a/test_spec_<device>.md, this is the Canonical Test Specification.
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt2b.md

## schema file
you will find wokwi chip.json schema file in this skill under assets/chip.schema.json.
Copy this file to <artifacts_dir>

## example chip.json

```json
{
  "name": "chip",
  "author": "Raspberry Pi",
  "pins": [
    "SDA",
    "SCL"
  ],
  "controls": []
}
```

## parts to add to template

first read <spec> in full. Your chip.json will need to comply 100% with this specification.

Keep structure like this, only modify pins and controls.

controls: these will be environment variables that 
normally the sensor or device will pick up such as temperature.

pin names: you have access to esphome source code <esphome_component_code> for <device>
look at __init__.py and .c .cpp .h files for clues.

## System Rules & Parsing Instructions### 1. Extraction Strategy* **Python Engine Parsing:** Search for string schema keys conforming to `CONF_[A-Z0-9_]+_PIN`. Strip `CONF_` from the beginning and `_PIN` from the tail. Convert the remainder directly to uppercase (e.g., `CONF_DATA_PIN` becomes `"DATA"`).
* **C++ Header Parsing:** Identify pointer instances containing `GPIOPin*` or `InternalGPIOPin*`. Isolate the variable prefix by stripping the trailing underscore and conversion to uppercase (e.g., `InternalGPIOPin *miso_pin_;` becomes `"MISO"`).
### 2. Standardization & Hierarchy* **De-duplication:** Maintain unique string instances. If both Python and C++ source snippets are supplied, merge matching functions.
* **Array Ordering:** Sequence programmatic interfaces logically: Bus clocks/comms first (SCL/SDA, CLK/MOSI/MISO), control pins second (CS, RST, DC), followed by auxiliary alerts (IRQ, BUSY), ending with power vectors (`VCC`, `GND`).
## Prompting Context Example### Input Context```xml
<esphome_source_code>
// From dynamic_oled_display.h
class DynamicOLED : public Component {
 protected:
  InternalGPIOPin *cs_pin_;
  InternalGPIOPin *dc_pin_;
  InternalGPIOPin *reset_pin_;
};
</esphome_source_code>
```
### Expected Output Structure```json
{
  "name": "dynamic_oled_display",
  "author": "esphome_developer",
  "pins": [
    "CS",
    "DC",
    "RESET",
    "VCC",
    "GND"
  ],
  "controls": []
}
```


## validation

```sh
check-jsonschema --schemafile <artifacts_dir>/chip.schema.json <artifacts_dir>/chip.json
```

### Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.

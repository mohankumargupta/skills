---
name: wokwi-diagramjson
description: Create wokwi diagram diagram.json from canonical test specification for device <device>
---

## Context variables
<original_pwd>: run pwd, this is <original_pwd>
<outputs_dir>: <original_pwd>/artifacts/<device>/outputs
<test_spec>: <original_pwd>/artifacts/<device>/outputs/test_spec_<device>.md
<chip_json>: <original_pwd>/artifacts/<device>/outputs/chip.json
<diagram_json>: <outputs_dir>/diagram.json
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt2b.md

## Description

This skill has: assets/diagram.json, copy it to <diagram_json>

Build on it, don't remove anything from it. It has correct microcontroller and custom chip,
as well as serial connections.

## Input
<test_spec>: canonical test spec, single source of truth.

## Output
<diagram_json>: wokwi diagram.json. 

## Where source of truth comes from

| Information   | Source    |
| ------------- | --------- |
| protocol      | test_spec |
| address       | test_spec |
| chip pins     | chip_json |
| attrs         | chip_json |
| MCU           | template  |
| serial wiring | template  |


## References

Under references folder under this skill.

- `wokwi.md`
- `diagramjson.md`
- `esp32c3.md`


## Rules

-  **Wire colors**: Use standard colors: `red` for VCC, `black` for GND, `green` for data/signal, `blue` for secondary signals, `orange` for control.
-  **Connections format**:  Use empty `[]` for wire routing connections. the first two entries MUST

## Workflow

### Wokwi custom chip needs to connected to microcontroller  

Wokwi custom chip pin names can come from <chip_json>


### Add attrs atributes to existing wokwi custom chip 

add attrs from existing chip.
for attrs, need to read both <device>.chip.json for attributes

### Build the Connections Array
Connect the ESP32-C3 microcontroller to wokwi custom chip.

### Output the JSON
Produce a complete, valid <diagram_json> object. 

### Validation

run 

```sh
cd <outputs_dir>
wokwi-cli lint
```
### Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.

---
name: wokwi-chipjson
description: Create wokwi chip.json from canonical test specification for device <device>
---

# Context Variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: <original_pwd>/artifacts/<device>/prompt2a, need to create this directory
<outputs_dir>: <original_pwd>/artifacts/<device>/outputs
<test_spec>: <original_pwd>/artifacts/<device>/outputs/test_spec_<device>.md, this is the Canonical Test Specification.
<spec>: <original_pwd>/artifacts/<device>/outputs/spec_<device>.md
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt2a.md

## schema file
you will find wokwi chip.json schema file in this skill under assets/chip.schema.json.
Copy this file to <artifacts_dir>

## example chip json

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

first read <spec> and <test_spec> in full. Your chip.json will need to comply 100% with this specification.

Keep structure like this, only modify pins and controls.

controls: these will be environment variables that 
normally the sensor or device will pick up such as temperature.

pin names: use  <spec> 

## validation

```sh
check-jsonschema --schemafile <artifacts_dir>/chip.schema.json <artifacts_dir>/chip.json
```
then copy <artifacts_dir>/chip.json to <outputs_dir>


### Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.

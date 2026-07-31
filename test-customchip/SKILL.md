---
name: test-customchip
description: Assemble wokwi test harness for device <device>
---

# Context Variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is <original_pwd>/artifacts/<device>/prompt2g, you will need to create this.
<wokwi_custom_chip>: <original_pwd>/artifacts/<device>/prompt1
<chip_json>: <original_pwd>/artifacts/<device>/prompt2b/<device>.chip.json
<diagram_json>: <original_pwd>/artifacts/<device>/prompt2c/diagram.json
<esphome_yaml>: <original_pwd>/artifacts/<device>/prompt2d/<device>.yaml
<rust_test_program>: <original_pwd>/artifacts/<device>/prompt2e/qa_test
<firmware_dir>: <original_pwd>/artifacts/<device>/prompt2f/.esphome/build/dut/.pioenvs/dut
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt2g.md

## copy files

<chip_json> -> <artifacts_dir>/chip.json, make sure name is <device> case must match exactly
<diagram_json> -> <artifacts_dir>
<esphome_yaml> -> <artifacts_dir>
<rust_test_program> -> <artifacts_dir>
<firmware_dir>/firmware.bin -> <artifacts_dir>
<firmware_dir>/firmware.elf -> <artifacts_dir>

## create wokwi.toml
copy assets/wokwi.toml from this skill to <artifacts_dir> and 
replace <device>

### Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.


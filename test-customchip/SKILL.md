---
name: test-customchip
description: Assemble wokwi test harness for device <device>
---

# Context Variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is <original_pwd>/artifacts/<device>/prompt2f, you will need to create this.
<wokwi_custom_chip>: <original_pwd>/artifacts/<device>/prompt1
<chip_json>: <original_pwd>/artifacts/<device>/prompt2b/<device>.chip.json
<diagram_json>: <original_pwd>/artifacts/<device>/prompt2c/diagram.json
<esphome_yaml>: <original_pwd>/artifacts/<device>/prompt2d/<device>.yaml
<rust_test_program>: <original_pwd>/artifacts/<device>/prompt2e/qa_test
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt2f.md

## copy files

<chip_json> -> <artifacts_dir>/chip.json
<diagram_json> -> <artifacts_dir>
<esphome_yaml> -> <artifacts_dir>
<rust_test_program> -> <artifacts_dir>

## compile esphome firmware

run from <artifacts_dir>:

esphome compile <device>.yaml

## create wokwi.toml

Given <artifacts_dir>/diagram.json, 
and the previous command,

create <artifacts_dir>/wokwi.toml so 
that the wokwi custom chip matches what is in <artifacts_dir>/diagram.json
and firmware points to right location based on previous esphome command

### Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.


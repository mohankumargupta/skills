---
name: ESPHome yaml
description: trigger when user asks: create esphome yaml for device <device>
---

# SKILL: ESPHome yaml

## Reference 

`references/core-configuration.md`: esphome core configuration, particularly on_boot


## Input

Files are relative to current working directory

```artifacts/prompt2a/qa_test/tests/test.rs```: A std rust program run on the host machine 
during Wokwi simulation time.
This file reads from the tcp stream created by wokwi.toml rfc2217 tcp serial port.
You need to add to ```esphome``` section of the esphome yaml file, that prints
what this rust program expects in order to run test assertions.

## Ouput

Files are relative to current working directory

`artifacts/prompt2/<device>.yaml`: generated esphome yaml file



## Step 1: esphome components docs for <device>

run this command verbatim from current working directory, replacing <device>:

```bash
rg -i <device> components 
```

then read this file, from it, we need a typical happy path example.

## Step 2: Use ESPHome template

There is a file: `assets/template.yaml` inside this skill.

You MUST copy the contents of `assets/template.yaml` into the new YAML file 
`artifacts/prompt2/<device>.yaml` verbatim before adding anything else to this file.

Template preservation rules:
- Do not remove any line from the template.
- Do not reorder any line from the template.
- Do not edit existing values, comments, spacing, or blank lines from the template.
- Do not rename `esphome.name`; keep `name: dut` exactly as provided.
- Do not uncomment commented sections unless the user explicitly asks.
- Add the device-specific YAML only after the existing template content.

There is one and only one exception to this rule, and that is to add a on_boot to the core
esphome configuration. This is where you essentially would run an automation script to 
test behaviour, you MUST add this section such that if wokwi custom chip behaves correctly, 
then output from on_boot section would cause the tests to pass.


### Step 4: Validate esphome config

run from `artifacts/prompt2` 

```bash
esphome config <device>.yaml
```



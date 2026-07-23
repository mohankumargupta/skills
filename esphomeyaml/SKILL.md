---
name: ESPHome yaml
description: trigger when user asks: create esphome yaml for device <device>
---

# Context variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is `<original_pwd>/artifacts/prompt2b`, you will need to create this.
<testrs>: file <original_pwd>/artifacts/prompt2a/qa_test/tests/test.rs

## Befor starting - Task Tracking & Progress
- **Mandatory Checklist**: Always start every task by generating a detailed markdown checklist using `- [ ]` for pending steps and `- [x]` for completed steps.
- **Incremental Updates**: Update this checklist dynamically after completing every individual step. Do not skip printing or updating this progress log.
- **Workflow State**: If transitioning between multiple tools, output the updated todo list first so the user can track the pipeline execution.



## Input


```<testrs>```: A std rust program run on the host machine 
during Wokwi simulation time.
This file reads from the tcp stream created by wokwi.toml rfc2217 tcp serial port.
You need to add to ```esphome``` section of the esphome yaml file, that prints
what this rust program expects in order to run test assertions.

## Ouput

`<artifacts_dir>/<device>.yaml`: generated esphome yaml file


## Reference 

`references/core-configuration.md`: esphome core configuration, particularly on_boot

## Step 1: esphome components docs for <device>

run this command verbatim from current working directory, replacing <device>:

```bash
rg -i <device> components 
```

then read this file, from it, we need a typical happy path example.

## Step 2: Use ESPHome template

There is a file: `assets/template.yaml` inside this skill.

You MUST copy the contents of `assets/template.yaml` into the new YAML file 
`<artifacts_dir>/<device>.yaml` verbatim before adding anything else to this file.

Template preservation rules:
- Do not remove any line from the template.
- Do not reorder any line from the template.
- Do not edit existing values, comments, spacing, or blank lines from the template.
- Do not rename `esphome.name`; keep `name: dut` exactly as provided.
- Do not uncomment commented sections unless the user explicitly asks.
- Add the device-specific YAML only after the existing template content.

## One and only one exception template preservation rule

MUST add a on_boot to the coreesphome configuration. 

This is where you essentially would run an automation script to 
test behaviour, you MUST add this section such that if wokwi custom chip behaves correctly, 
then output from on_boot section would cause the tests to pass.

- add a item to the detailed markdown checklist that verifies that you added an on_boot section
to esphome core configuration as per this skill instructions

###

### Step 4: Validate esphome config

run from `<artifacts_dir>` 

```bash
esphome config <device>.yaml
```


### Step 5: create markdown doc

generate a file called <original_pwd>/<device>_esphomeyaml.md provide details of obstacles you 
faced and improvements you would make


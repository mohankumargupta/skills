---
name: ESPHome yaml
description: trigger when user asks: create esphome yaml for device <device>
---

# Context variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is `<original_pwd>/artifacts/<device>/prompt2d`, you will need to create this.
<narrator_contract>:  <original_pwd>/artifacts/<device>/prompt2a/narrator_contract.md
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt2d.md

## Befor starting - Task Tracking & Progress
- **Mandatory Checklist**: Always start every task by generating a detailed markdown checklist using `- [ ]` for pending steps and `- [x]` for completed steps.
- **Incremental Updates**: Update this checklist dynamically after completing every individual step. Do not skip printing or updating this progress log.
- **Workflow State**: If transitioning between multiple tools, output the updated todo list first so the user can track the pipeline execution.

## Input

<narrator_contract>: yaml needs to implement this in full, downstream consumers rely on this.

```<testrs>```: A std rust program run on the host machine 
during Wokwi simulation time.
This file reads from the tcp stream created by wokwi.toml rfc2217 tcp serial port.

## Output

`<artifacts_dir>/<device>.yaml`: generated esphome yaml file

## Mandatory Section in yaml file
You need to add on_boot section to ```esphome``` section of the esphome yaml file, that fulfills
most of narrator_contract.

## Reference 
this is located in this skill.
`references/core-configuration.md`: esphome core configuration, particularly on_boot

## Step 1: read narrator contractor

run this command verbatim from current working directory, replacing <device>:

read this file, from it, we need a typical happy path example.

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

MUST add a on_boot to the corresponding esphome configuration. 

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

generate a file called <feedback_file> provide details of obstacles you 
faced and improvements you would make


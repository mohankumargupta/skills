---
name: ESPHome yaml
description: create esphome yaml from Canonical Test Specification for device <device>
---

# Context variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is `<original_pwd>/artifacts/<device>/prompt2d`, you will need to create this.
<spec>:  <original_pwd>/artifacts/<device>/prompt2a/test_spec_<device>.md
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt2d.md

## Befor starting - Task Tracking & Progress
- **Mandatory Checklist**: Always start every task by generating a detailed markdown checklist using `- [ ]` for pending steps and `- [x]` for completed steps.
- **Incremental Updates**: Update this checklist dynamically after completing every individual step. Do not skip printing or updating this progress log.
- **Workflow State**: If transitioning between multiple tools, output the updated todo list first so the user can track the pipeline execution.

## Input

<spec>: Canonical Test Specification, esphome yaml needs full compliance with this.

<artifacts_dir>/<device>/prompt0/esphome_component.txt: contains name of esphome component for <device>

## Output

`<artifacts_dir>/<device>.yaml`: generated esphome yaml file

# copy files

copy assets/template.yaml in this skill to <artifacts_dir>/<device>.yaml

## Mandatory Section in yaml file
Add on_boot section to ```esphome``` section of the esphome yaml file. 
If possible, sensor values are read and printed here, according to <spec>,
prefer this to reading periodic values. 

## Reference 
this is located in this skill.
`references/core-configuration.md`: esphome core configuration, particularly on_boot

## find esphome docs and optionally source code for <device>

read <artifacts_dir>/<device>/prompt0b/esphome_component.txt. this tells the 
name where to find esphome docs for <device>, which will be
<artifacts_dir>/<device>/prompt0b/<name_of_esphome_component>.mdx

you must use the esphome component in the final yaml file


optionally, if needed, you can look at esphome source code for that component in 
<artifacts_dir>/<device>/prompt0/<name_of_esphome_component>


## add to yaml

<artifacts_dir>/<device>.yaml

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

### Validate esphome config

run from `<artifacts_dir>` 

```bash
esphome config <device>.yaml
```


### Step 5: create markdown doc

generate a file called <feedback_file> provide details of obstacles you 
faced and improvements you would make


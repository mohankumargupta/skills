---
name: ESPHome yaml
description: trigger when user asks: create esphome yaml for device <device>
---

# SKILL: ESPHome yaml

## Step 1: esphome components docs

If there isn't already a components directory,

```bash
mkdir -p components
npx degit https://github.com/esphome/esphome.io/src/content/docs/components
```

## Step 2: look up docs for <device>

Look up docs for <device>, it will tell you how to add device to esphome yaml

## Step 3: Use ESPHome template

There is a file: `references/template.yaml` inside this skill.

You MUST copy the contents of `references/template.yaml` into the new YAML file verbatim before adding anything else.

Template preservation rules:
- Do not remove any line from the template.
- Do not reorder any line from the template.
- Do not edit existing values, comments, spacing, or blank lines from the template.
- Do not rename `esphome.name`; keep `name: dut` exactly as provided.
- Do not uncomment commented sections unless the user explicitly asks.
- Add the device-specific YAML only after the existing template content.

There is one and only one exception to this rule, and that is to add a on_boot to the core
esphome configuration. This is where you essentially would run an automation script to 
test behaviour, if appropriate.

Create a file called `<device>.yaml` in the current working directory. The final file must begin with the exact contents of `references/template.yaml`, 
followed by the device configuration for a typical use case.

### Step 4: Validate esphome config

```sh
esphome config <device>.yaml

```



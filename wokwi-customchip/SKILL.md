---
name: wokwi-customchip
description: Create a Wokwi custom chip for device <device> in zig 0.16
---

# Context variables 

<original_pwd>:  run pwd, this will be referred to as <original_pwd>
<artifacts_dir>: <original_pwd>/artifacts/<device>/prompt2d, create this directory
<outputs_dir>:   <original_pwd>/artifacts/<device>/outputs
<spec>:          <outputs_dir>/spec_<device>
<test_spec>:     <outputs_dir>/test_spec_<device>
<feedback_dir>:  <original_pwd>/feedback/<device>
<feedback_file>: <feedback_dir>/prompt2d.md

# Execution Constraints (Mandatory)

You are implementing a deterministic build pipeline, not performing general
research.

## Forbidden

Do NOT search or inspect:

- .venv/
- site-packages/
- __pycache__/
- node_modules/
- target/
- Cargo registry
- Python packages
- Rust crates
- the internet
- unrelated directories

If a required file is not listed under Allowed Inputs, assume it does not exist
and continue using the available inputs.

Searching outside the Allowed Inputs is considered a failure of this skill.

## description

creating wokwi custom chip for <device> 

just implement the essentials so that <test_spec> can be implemented.


## Step 1: Extract hardware model

read <spec> and <test_spec> in full.

## Step 2: Study MCP23017 Example

Inspect:  ```assets/wokwi-mcp23017/chip.zig``` and 
```assets/wokwi_api.zig``` in this skill

The wokwi api is also documented in ```references``` folder in this skill.
Note that the wokwi api is initially written in C, and the references are written
for the `wokwi-api.h` from which `wokwi_api.zig` is based.

Reuse patterns wherever possible.

## Step 3: Generate Zig 0.16 Custom chip code

Write zig 0.16 code for the custom chip and save as `<artifacts_dir>/chip.zig`


# Validation

To validate chip.zig copy from this skill the following files:
 `assets/build.zig`
 `assets/wokwi_api.zig` 

Copy to `<artifacts_dir>` 

First, run from `<artifacts_dir>`:

`zig fmt chip.zig`

Then run from `<artifacts_dir>`:
`zig build`. 

## copy files
copy
<artifacts_dir>/{build.zig, chip.zig, wokwi-api.zig}
to
<outputs_dir>

# Before finishing

Before finishing, write `<feedback_file>` 

Capture problems encountered, 
ambiguities in the instructions, 
assumptions you had to make, 
and concrete suggestions for improving the skill.

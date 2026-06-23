---
name: wokwi-customchip
description: Create a Wokwi custom chip for device <device> in zig 0.16
---

# Input

`artifacts/prompt0/<device>.md`: Spec file for <device>


# Output

In current working directory, create a directory: `artifacts/prompt1`

Inside that directory, this skill will create the following files:

chip.zig: wokwi custom chip implementation in Zig 0.16
<device>.chip.json : wokwi custom chip controls

## Step 1: Extract hardware model

Convert the spec into:

internal state
registers
transport handlers
pin model
interrupt model
timing model

## Step 2: Study MCP23017 Example

Inspect:  ```assets/wokwi-mcp23017/chip.zig``` and 
```assets/wokwi-mcp23017/wokwi_api.zig``` in this skill

The wokwi api is also documented in ```references``` folder in this skill.
Note that the wokwi api is initially written in C, and the references are written
for the `wokwi-api.h` from which `wokwi_api.zig` is based.

Reuse patterns wherever possible.

## Step 3: Generate Zig 0.16 Custom chip code

Write zig 0.16 code for the custom chip and save as `artifacts/prompt1/chip.zig`


# Validation

To validate chip.zig and <device>.chip.json copy from this skill the following files:
 `assets/wokwi-mcp23017/build.zig`
 `assets/wokwi-mcp23017/wokwi_api.zig` 
 `assets/chip.schema.json`

Copy to
 `artifacts/prompt1` in current working directoy. 

Then run from `artifacts/prompt1`:
`zig build`. 

If successful, it should produce a dist/chip.wasm

now validate ```<device>.chip.json``` by running 

```jsonschema-cli validate chip.schema.json -i <device>.chip.json```


# Before finishing

Before finishing, write <device>_IMPROVEMENTS.md in the current working directory. 

Capture problems encountered, 
ambiguities in the instructions, 
assumptions you had to make, 
and concrete suggestions for improving the skill.

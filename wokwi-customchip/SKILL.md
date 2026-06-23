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

The wokwi api is also documented in ```references``` folder in this skill

Reuse patterns wherever possible.

## Step 3: Generate Zig 0.16 Custom chip code

MUST use the zig skill (called zig) to write zig 0.16 code. If you can't, tell the user
and exit with failure.


# Validation

To validate chip.json copy from ```assets/wokwi-mcp23017/build.zig```
and  ```assets/wokwi-mcp23017/wokwi-api.zig ``` from  this skill to devices/<device>.
and then from that directory run 

```zig build```. 

If successful, it should produce a dist/chip.wasm

now validate ```<device>.chip.json``` by running 

```jsonschema-cli validate <schema> -i <device>.chip.json```

Use the absolute path to `assets/chip.schema.json` 
from this skill directory when running validation.

# Before finishing

Before finishing, write <device>_IMPROVEMENTS.md in the current working directory. 

Capture problems encountered, 
ambiguities in the instructions, 
assumptions you had to make, 
and concrete suggestions for improving the skill.

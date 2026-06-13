---
name: Wokwi create custom chip
description: Trigger when user asks 
             create a Wokwi custom chip for device <device> in zig 0.16
---

# Skill: Create a wokwi custom chip

Steps:

## Step 1: Find spec markdown file in Periph directory

run in current working directory

```bash
git clone --depth 1 https://github.com/tuhde/Periph 
```

Identify:

category
spec file
communication protocol(I2C/SPI/UART)
register map
pin capabilities
initialization sequence
implementation notes
Extract all information.

## Step 2: Extract hardware model

Convert the spec into:

internal state
registers
transport handlers
pin model
interrupt model
timing model
Do not copy driver APIs.

Implement device behaviour.

## Step 3: Study MCP23017 Example

Inspect:  ```assets/wokwi-mcp23017/chip.zig``` and 
```assets/wokwi-mcp23017/wokwi-api.zig``` in this skill

The wokwi api is also documented in ```references``` folder in this skill

Reuse patterns wherever possible.

## Step 4: Generate Zig 0.16 Custom chip code

Use the zig skill to write zig 0.16 code

# Output

chip.zig in current working directory

# Validation

To validate copy from ```assets/wokwi-mcp23017/build.zig```
and  ```assets/wokwi-mcp23017/wokwi-api.zig ``` from  this skill to current working dir.

then run 

```zig build```. 

If successful, it should produce a dist/chip.wasm


# Before finishing

Before finishing, write <device>_IMPROVEMENTS.md in the current working directory. 

Capture problems encountered, 
ambiguities in the instructions, 
assumptions you had to make, 
and concrete suggestions for improving the skill.

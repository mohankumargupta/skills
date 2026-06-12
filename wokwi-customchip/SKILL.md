name: Wokwi create custom chip
description: When you need to create a Wokwi custom chip
---

# Skill: Create a wokwi custom chip

Steps:

## Step 1: Find spec markdown file in Periph directory

Identify:

category
spec file
transport
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

Inspect:

assets/wokwi-mcp23017/ in this skill

Specifically compare:

build.zig
chip.zig
wokwi.toml
wokwi-api.zig
Reuse patterns wherever possible.

## Step 4: Generate Zig 0.16 Custom chip code

# Output

chip.zig in current working directory

# Validation

To validate copy from assets/wokwi-mcp23017 folder in this skill to current working dir:

build.zig

then run zig build. If successful, it should produce a dist/chip.wasm


# Before finishing

Write a file called `<device>_IMPROVEMENTS.md` in current working directory which details
improvements you would make based on difficulties or amguities in instructions.

 


---
name: wokwi-customchip
description: Create a Wokwi custom chip for device <device> in zig 0.16
---

Do not add release builds, publishing steps, examples, README files, tests, CI, packaging, 
or extra generated files unless explicitly requested 
by the user or required for the validation steps above.


before proceeding, run 

```bash
tree .
``` 

in this skill directory to see file organisation

# Skill: Create a wokwi custom chip

Steps:

## Step 0: Create a spec markdown file

Run all scripts from current working directory.

Run this script if components directory does not exist:

```bash
mkdir -p components
npx -y degit -f https://github.com/esphome/esphome.io/src/content/docs/components
```

Then run:
```bash
fd -a -t f -e mdx . components | grep <device>
```

This will give you the full path to esphome docs for <device>.

Read this file and find the first datasheet url, then download it using wget or curl 
as `<device>.pdf`
 to 
`datasheets/<device>` directory in the current working directory. 

Then run this script, replacing <device>

```bash
cd datasheets/<device>
uv init
uv add pymupdf4llm
```

copy `assets/datasheet_device/main.py` from this skill and copy it to `datasheets/<device>`

the run

```bash
cd datasheets/<device>
uv run main.py <device>.pdf <device>_datasheet.md
```
Then I need to print out the following to the user:

Skill completed. Please open freebuff and write the following prompt:

Take datasheets/<device>/<device>_datasheet.md as the source of truth and 
path/to/Periph/spec/<device>.md as template and produce datasheets/<device>.md
which fills out template from source of truth.


## Step 1: Find spec markdown file in Periph directory

run in current working directory if Periph does not exist

```bash
git clone --depth 1 https://github.com/tuhde/Periph Periph 
```

Then run:

```bash
fd -t f . Periph/specs |grep <device>
```

This will identify the correct spec file

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

MUST use the zig skill (called zig) to write zig 0.16 code. If you can't, tell the user
and exit with failure.

# Output

In current working directory, create a directory: devices/<device>
this is the working directory for the output generated and files copied.

inside that directory create the following files:

chip.zig
<device>.chip.json : wokwi custom chip controls

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

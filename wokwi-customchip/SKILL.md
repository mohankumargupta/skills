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
<conversions_src>:    <original_pwd>/artifacts/<device>/prompt0c/src/main.zig, canonical register <-> real-world-value conversions produced by data-conversions-complex-logic
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


## Step 0: Reuse canonical conversions — do not re-derive encoding

If <conversions_src> exists, it already contains validated, unit-tested
functions for converting between real-world values (e.g. temperature in °C)
and raw register bit patterns for this device.

You MUST port those exact functions (bit shifts, sign extension, byte
order) into `chip.zig` verbatim, adapting only syntax as needed for the
no_std/WASM chip environment (e.g. replacing `std.testing` calls, keeping
the arithmetic identical). Do NOT re-derive the encoding from the datasheet
text a second time — the datasheet's register-map table and its bit-field
tables have previously been found to disagree with each other (see
`feedback/tmp102/prompt0c.md` for a documented example), and re-deriving
independently is how that ambiguity turns into a silent, undetected bug.

If <conversions_src> does not exist, flag this in <feedback_file> as a
missing dependency — do not silently proceed with a fresh derivation.

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

## Step 4: Add unit tests to chip.zig (mandatory)

`chip.zig` must contain `test { ... }` blocks that check its
register-encoding/decoding helper functions against concrete worked
examples — not just that the file compiles. At minimum, include one test
per observable default value listed in <test_spec>, asserting the exact
encoded register bytes/words match the value recorded in
`<conversions_manifest>` (produced by data-conversions-complex-logic) or,
if unavailable, computed by hand from the datasheet's Data Conversion
section and cited in a comment.

Example (adapt to the device's actual register layout):

```zig
test "tempToRegister encodes default observable per spec" {
    // 21.0 C -> 0x1500 (left-aligned 12-bit, LSB nibble reserved)
    try std.testing.expectEqual(@as(u16, 0x1500), tempToRegister(21.0));
}
```

A chip.zig that compiles but has no test coverage of its numeric
conversion functions does not satisfy this skill.


To validate chip.zig copy from this skill the following files:
 `assets/build.zig`
 `assets/wokwi_api.zig` 

Copy to `<artifacts_dir>` 

First, run from `<artifacts_dir>`:

`zig fmt chip.zig`

Then run from `<artifacts_dir>`:

`zig build`

`zig build test`

`zig build test` must pass with zero failures before proceeding. A green
`zig build` alone (compiles, but never exercised) is not sufficient
evidence of correctness and must not be treated as such.

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
Explicitly note whether <conversions_src> was reused as-is, adapted, or
unavailable (see Step 0), and why.

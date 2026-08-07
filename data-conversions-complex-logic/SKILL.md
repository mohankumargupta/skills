---
name: data-conversions-complex-logic
description: Create zig 0.16 std project that has data conversion functions and reference algorithms for device <device>
---

# Context Variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is <original_pwd>/artifacts/<device>/prompt0c, you will need to create this.
<spec>: <original_pwd>/artifacts/<device>/outputs/spec_<device>.md, Canonical Test Specification
<conversions_manifest>: <artifacts_dir>/conversions_manifest.md, you will need to create this
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt0c.md

# create zig 0.16 std project

run the following from <artifacts_dir>

zig init

# edit main zig file

read <spec> and where there are:
1.  data conversions happening eg. from register values to 
real-world values
2. complex logic such as calculating crc values or other algorithms 

then create seperate functions in the main zig file and accompany them 
with unit tests.

# zig build

verify correctness with zig build.

# Downstream reuse contract

The functions produced here are the single source of truth
for register-level bit layout (alignment, byte order, sign extension) for
this device.

Any other skill that later needs to encode or decode the same register
values MUST reuse or port these exact functions rather than re-deriving 
the encoding independently.Re-deriving the same conversion twice, 
in two different artifacts, with no shared reference, 
is how alignment/shift bugs are introduced silently.

Produce `<conversions_manifest>` listing, for each conversion function:

- function name and file
- one worked example input/output pair (e.g. `21.0 C -> 0x1500`)
- the exact bit layout assumption it encodes (e.g. "left-aligned in bits
  15:4, LSB nibble of byte 2 reserved for EM flag")

### Step 4: Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles 

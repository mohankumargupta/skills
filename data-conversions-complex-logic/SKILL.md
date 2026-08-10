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

### Zig 0.16 note

`std.testing.expect*` (`expectEqual`, `expectApproxEqRel`, etc.) return
error unions in Zig 0.16 and MUST be `try`'d — omitting `try` is a compile
error, not a warning. If the project also includes a fuzz test, note that
`std.testing.fuzz` takes a `*std.testing.Smith` in this version. Neither
of these is discoverable from `zig init`'s generated template; assume
they apply rather than rediscovering them per device.


# edit main zig file

read <spec> and where there are:
1.  data conversions happening eg. from register values to 
real-world values
2. complex logic such as calculating crc values or other algorithms 

then create seperate functions in the main zig file and accompany them 
with unit tests.

When a spec's worked-example table gives a raw register value (not a
signed decimal), derive the expected test value by calling the same
sign-extension/decode primitive under test on that raw value — do not
hand-compute a signed decimal and hardcode it as the expected result.
This keeps the test a genuine check of the function rather than a
restatement of the author's own arithmetic, and it means a bug in the
primitive can't accidentally cancel out against the same bug in the
test's hand-derivation.

### Overflow / out-of-range policy (mandatory, per encode function)

Every function that encodes a real-world value into a fixed-width
register field must have an explicit, stated policy for what happens
when the input is out of the representable range — clamp/saturate to
the min/max representable value, wrap, or return an error. This is a
judgment call the spec usually doesn't make for you, so document
whichever you choose directly in the function's doc comment AND in
`<conversions_manifest>` (see reuse contract below), not just implicitly
in the implementation. A downstream skill porting this function verbatim
inherits whatever policy you picked without re-deriving it — an
undocumented choice here becomes a silent, unreviewed decision two
artifacts later.


# zig build

verify correctness with zig build.

# Step 4: Create conversions manifest

Create `<conversions_manifest>`.

The manifest is mandatory. It MUST be created even when the
specification contains no conversions. In that case, state explicitly
that no register-level conversions were identified.

For every conversion function, record:

- function name and file
- one worked example input/output pair
  (e.g. `21.0 C -> 0x1500`)
- the exact bit layout assumption it encodes
  (e.g. "left-aligned in bits 15:4, LSB nibble of byte 2 reserved for EM flag")
- the out-of-range policy for encode functions
  (clamp/saturate, wrap, or error)

The functions produced here are the single source of truth for
register-level bit layout (alignment, byte order, and sign extension)
for this device.

Any other skill that later needs to encode or decode the same register
values MUST reuse or port these exact functions rather than
re-deriving the encoding independently.


# Step 5: Verify

Run:

zig build

Before finishing, verify that all of the following exist:

- `<artifacts_dir>/build.zig`
- `<artifacts_dir>/build.zig.zon`
- `<artifacts_dir>/src/main.zig`
- `<conversions_manifest>`


### Step 4: Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles 

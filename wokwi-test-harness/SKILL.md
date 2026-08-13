---
name: wokwi-test-harness
description: create test harness involving esphome yaml and rust std test project called qa_test for device <device> based on Canonical Test Specification
---

# Context Variables

<original_pwd>:        run pwd, this is <original_pwd>
<outputs_dir>:         <original_pwd>/artifacts/<device>/outputs, will need to create directory
<artifacts_dir>:       <original_pwd>/artifacts/<device>/prompt2c, will need to create directory
<spec>:                <outputs_dir>/test_spec_<device>.md, Canonical Test Specification
<feedback_dir>:        <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>:       <feedback_dir>/prompt2c.md

# Execution Constraints (Mandatory)

You are implementing a deterministic build pipeline, not performing general
research.

## Allowed Inputs

You may only read the following:

- <spec>
- <outputs_dir>/esphome_component.txt
- <outputs_dir>/<name_of_esphome_component>.mdx
- files under this skill's assets/
- files under this skill's references/
- files that you generate during this skill

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


# STEP 1: Create esphome yaml

## Description

The esphome yaml file together with rust std project forms the full test harness.
The glue between the two is a wokwi.toml file which when wokwi runs in vscode,
it starts a rfc2217 TCP server. When esphome yaml prints output in on_boot section of 
esphome yaml, the rust std project will listen to the serial output traffic and
make assertions based on that. For that reason, we have a Canonical Test Specification
so both parties can agree on what is sent and expected to be received.

## Input

<spec>: Canonical Test Specification, esphome yaml needs full compliance with this.

<outputs_dir>/esphome_component.txt: contains name of esphome component for <device>,
                                     referred to as <name_of_esphome_component>

## Output

`<artifacts_dir>/<device>.yaml`: generated esphome yaml file

## copy files

copy assets/template.yaml in this skill to <artifacts_dir>/<device>.yaml

## pin numbers

read assets/esp32c3.yaml from this skill

use the pin numbers suggested here for buses and other pins.


## Mandatory Section in yaml file
Add on_boot section to ```esphome``` section of the esphome yaml file. 
If possible, sensor values are read and printed here, according to <spec>,
prefer this to reading periodic values. 

### Race condition warning (critical)

`component.update` on a sensor is **asynchronous**: it starts the
read/conversion but does not block until the value is actually published.
A lambda placed immediately after `component.update` — even guarded by a
fixed `delay:` — can log a `nan` value because the driver has not yet
called `publish_state()`. 

*Never** generate an on_boot block that relies on a fixed `delay:` to
wait for a sensor read to complete. Instead:

1. **An `on_value` trigger** on the sensor itself, when the canonical
   observable in `<spec>` is naturally event-driven. `component.update`
   should still be issued in `on_boot` to force the first read rather than
   waiting for the sensor's normal `update_interval`, but the log line
   moves into the sensor's `on_value:` automation instead of `on_boot`.

the generated on_boot/on_value block MUST NOT
print the observable until the driver has actually published a non-NaN
value. A race here doesn't just produce a flaky log line — it silently
corrupts the ground-truth value that the paired `qa_test` rust harness
asserts against via `assert_serial!`, per the "Numeric ground truth for
assertions" rule in this same skill.

### Format-string translation (critical)

`<spec>`'s `presentation.<observable>.template` field (e.g.
`"Temperature = {:.1f} C"`) uses language-neutral notation for precision
and wording only. `ESP_LOGI`/`ESP_LOGD`/`ESP_LOGW` are C++ macros that use
**printf-style** format specifiers exclusively — `%.1f`, not `{:.1f}`.

When emitting the lambda that logs an observable, you MUST translate the
template's precision directive into the correct printf conversion
specifier before writing the `ESP_LOGx` call:

```yaml
# WRONG — {:.1f} is not a printf specifier; ESP_LOGI will print the
# literal characters "{:.1f}" instead of the value, and the value
# argument is silently dropped.
ESP_LOGI("<tag>", "Temperature = {:.1f} C", x);

# CORRECT
ESP_LOGI("<tag>", "Temperature = %.1f C", x);
```

**Literal `%` characters in the template must also be escaped.** If
`<spec>`'s `presentation.<observable>.template` contains a literal `%` (e.g.
`"Humidity = {:.2f} %"` or a `%%`-style unit), the printf-family format string
must escape it as `%%`, or the compiler will either misparse the following
character as a conversion specifier or silently drop output. Always grep the
generated yaml for a bare `%` inside an `ESP_LOGx`/lambda format string that
is not immediately followed by another `%` or a valid specifier, in addition
to the `{:` grep already required below.


After generating the yaml, grep the generated file for any `{:` sequence
inside a quoted `ESP_LOGx`/lambda string — its presence indicates this
translation step was skipped and must be



## Numeric ground truth for assertions

The exact numeric value asserted in `assert_serial!` for any observable
must be copied from <spec>'s Canonical
Presentation/observable default — never recomputed or approximated by the
test author. If the value that actually streams from the simulator differs
from the spec's default, this is a signal of a chip.zig encoding bug (see
wokwi-customchip Step 0/Step 4), not a reason to adjust the assertion to
match observed output. Do not "fix" a failing test by changing the
expected value to whatever the simulator happened to print.


## Reference 
this is located in this skill.
`references/core-configuration.md`: esphome core configuration, particularly on_boot

## find esphome docs and optionally source code for <device>

read <outputs_dir>/<name_of_esphome_component>.mdx

you must use the esphome component in the final yaml file

optionally, if needed, you can look at esphome source code for that component in 
<outputs_dir>/<name_of_esphome_component>


## add to yaml

<artifacts_dir>/<device>.yaml

Template preservation rules:
- Do not remove any line from the template.
- Do not reorder any line from the template.
- Do not edit existing values, comments, spacing, or blank lines from the template.
- Do not rename `esphome.name`; keep `name: dut` exactly as provided.
- Do not uncomment commented sections unless the user explicitly asks.
- Add the device-specific YAML only after the existing template content.

## One and only one exception template preservation rule

MUST add a on_boot to the corresponding esphome configuration. 

This is where you essentially would run an automation script to 
test behaviour, you MUST add this section such that if wokwi custom chip behaves correctly, 
then output from on_boot section would cause the tests to pass.

- add a item to the detailed markdown checklist that verifies that you added an on_boot section
to esphome core configuration as per this skill instructions


## Validate esphome config

run from `<artifacts_dir>` 

```bash
esphome config <device>.yaml
```
 
# STEP 2: create rust std project

We now will create a rust std project that will test this yaml file.

## Description 

Given a Canonical Test Specification, we need to create a rust test script that tests assertions of a wokwi 
custom chip running inside VSCode simulator.

A std rust test test.rs run on the host machine during Wokwi simulation time.
The program reads from the tcp stream created by wokwi.toml rfc2217 tcp serial port.
The rust test program runs test assertions against the stream coming to verify correct behaviour
of the wokwi custom chip. 

the serial output is coming from <esphome_yaml>, so make sure it matches 
expected results and the order in which serial output will stream in.

## Instructions

You are going to create test using the information 
in `<spec>` and with the example called 
`assets/_test_example.rs` in this skill as a guide. Also if you need to know definition of 
assert_serial,it is in 
`assets/qa_test/tests/assert_serial.rs` of this skill.
  
## create rust project

run from <artifacts_dir>

```bash
cargo new --vcs none --lib qa_test
```

## Step 2: Copy files from this skill

Copy the following files from this skill to path relative to current working directory:

`assets/qa_test/src/assert_serial.rs` -> `<artifacts_dir>/qa_test/src`
`assets/qa_test/src/lib.rs`           -> `<artifacts_dir>/qa_test/src`

## Step 3: Create test 

Generate `<artifacts_dir>/qa_test/tests/test.rs`. Remember we want happy path, no edge cases.

### Do not hardcode unverified framework log strings

Any `assert_serial!` string that quotes text the *framework itself* emits
(as opposed to text from the `<device>.yaml` on_boot/on_value lambda you
just wrote) — for example ESPHome's I2C bus-scan line, boot banners, or
component `dump_config` output — is NOT something to recall from training
data or copy from a prior run's feedback file. These strings vary across
ESPHome versions and build backends (esp-idf vs arduino), and differ even
between two log calls that look similar (`ESP_LOGI` "Found i2c device at
address" vs `ESP_LOGCONFIG` "Found device at address" are two distinct code
paths in the same component tree).

Before writing an assertion against framework-generated text:
1. Prefer asserting only against text your own on_boot/on_value lambda
   explicitly prints — that text is fully under this skill's control and
   its exact wording is guaranteed.
2. If a framework-emitted line is unavoidable (e.g. confirming I2C
   discovery), mark it in a comment as "framework-generated — verify
   against actual compile/simulator output before trusting" and prefer a
   shorter, less version-sensitive substring (e.g. `"address 0x48"` rather
   than the full log line) so minor wording differences across ESPHome
   versions don't break the assertion.
3. If actual simulator/serial output is available (e.g. from a prior run
   in this same session), assert against that observed text, not a
   remembered or assumed version of it.

## Step 3: Compile

Run from `<artifacts_dir>/qa_test`:

```bash
cargo build --target aarch64-unknown-linux-gnu
```

If there are errors, fix them and recompile.

If everything compiles, then copy:

<artifacts_dir>/qa_test -> <outputs_dir>

## Step 4 copy files

from this skill, copy assets/wokwi.toml to <outputs_dir>

copy <artifacts_dir>/qa_test to <outputs_dir>

copy <artifacts_dir>/<device>.yaml to <outputs_dir>

# Finishing up

Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.

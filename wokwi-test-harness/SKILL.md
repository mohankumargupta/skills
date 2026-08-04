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

# copy files

copy assets/template.yaml in this skill to <artifacts_dir>/<device>.yaml

## Mandatory Section in yaml file
Add on_boot section to ```esphome``` section of the esphome yaml file. 
If possible, sensor values are read and printed here, according to <spec>,
prefer this to reading periodic values. 

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
cargo new --lib qa_test
```

## Step 2: Copy files from this skill

Copy the following files from this skill to path relative to current working directory:

`assets/qa_test/src/assert_serial.rs` -> `<artifacts_dir>/qa_test/src`
`assets/qa_test/src/lib.rs`           -> `<artifacts_dir>/qa_test/src`

## Step 3: Create test 

Generate `<artifacts_dir>/qa_test/tests/test.rs`. Remember we want happy path, no edge cases.

## Step 3: Compile

Run from `<artifacts_dir>/qa_test`:

```bash
cargo build --target aarch64-unknown-linux-gnu
```

If there are errors, fix them and recompile.

If everything compiles, then copy:

<artifacts_dir>/qa_test -> <outputs_dir>


# Finishing up

Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.

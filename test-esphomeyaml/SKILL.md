---
name: test-esphomeyaml
description: trigger when user asks - create rust test file called test.rs for esphome yaml for device <device>
---

# Context variables
<original_pwd>: run pwd, this is <original_pwd>
<narrator_contract>: `<original_pwd>/artifacts/<device>/prompt2a`
<artifacts_dir>: `<original_pwd>/artifacts/<device>/prompt2b`, needs to be created
<feedback_dir>: <original_pwd>/feedback/<device>, needs to be created
<feedback_file>: <feedback_dir>/prompt2b.md

# Description 

Given a narrator contract, we need to create a rust test script that tests assertions of a wokwi 
custom chip running inside VSCode simulator.

A std rust test test.rs run on the host machine during Wokwi simulation time.
The program reads from the tcp stream created by wokwi.toml rfc2217 tcp serial port.
The rust test program runs test assertions against the stream coming to verify correct behaviour
of the wokwi custom chip. 

## Input

`<narrator_contract>`: narrator contract that test.rs will need to conform to.

## Ouput

Files are relative to current working directory

`<artifacts_dir>/qa_test/tests/test.rs`: rust std test file that contains tests

# Instructions

You are going to create test using the information 
in `<narrator_contract>` and with the example called 
`assets/_test_example.rs` in this skill as a guide. Also if you need to know definition of assert_serial,
it is in `assets/qa_test/tests/assert_serial.rs` of this skill.
  
## Step 1: create rust project

run from <original_pwd>

```bash
mkdir <artifacts_dir>
cd <artifacts_dir>
cargo new --lib qa_test
mkdir tests
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

## Step 4: Create improvement doc

Create a file called `<feedback_file>` with obstacles and limitations you came
across while completing this skill.

---
name: test-esphomeyaml
description: trigger when user asks: create rust test for esphome yaml for device <device>
---

# SKILL: Rust test for ESPHome yaml

Given a spec file, we need to create a rust test script that tests assertions of a wokwi 
custom chip running inside VSCode simulator.

A std rust test run on the host machine during Wokwi simulation time.
The program reads from the tcp stream created by wokwi.toml rfc2217 tcp serial port.
The rust test program runs test assertions against the stream coming to verify correct behaviour. 


## Input

Files are relative to current working directory

```artifacts/prompt0/<device>.md```: Spec file for device from which rust test it to be created.


## Ouput

Files are relative to current working directory

```artifacts/prompt2a/qa_test/tests/test.rs```: rust std test file that contains tests

# Instructions

You are going to create test using the information 
in `artifacts/prompt0/<device>.md` and with the example called 
`assets/_test_example.rs` as a guide. Also if you need to know definition of assert_serial,
it is in `assets/qa_test/tests/assert_serial.rs` of this skill.
  
## Step 1: create rust project

run in the current  working directory.

```bash
mkdir artifacts/prompt2a
cd prompt2a
cargo new --lib qa_test
mkdir tests
```

## Step 2: Copy files from this skill

Copy the following files from this skill to path relative to current working directory:

`assets/qa_test/src/assert_serial.rs` -> `artifacts/prompt2a/qa_test/src`
`assets/qa_test/src/lib.rs`           -> `artifacts/prompt2a/qa_test/src`


## Step 3: Create test 

Generate `artifacts/prompt2a/qa_test/tests/test.rs`. Remember we want happy path, no edge cases.

## Step 3: Compile

Run from `artifacts/prompt2a/qa_test`:

```bash
cargo build --target aarch64-unknown-linux-gnu
```

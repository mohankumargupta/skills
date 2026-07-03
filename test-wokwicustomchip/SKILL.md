---
name: test-wokwicustomchip
description: test wokwi custom chip for device <device> using esphome yaml example
---

## Step 1

run `scripts/prepare.sh <device>` from this skill. Run it in from current working directory.

## Step 2
run in artifacts/prompt4a

esphome compile <device>.yaml


## Step 3

run in artifacts/prompt4a/qa_test in current working directory
cargo build --target aarch64-unknown-linux-gnu

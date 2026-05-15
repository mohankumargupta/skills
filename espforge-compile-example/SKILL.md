---
name: espforge-compile-example
description: Use this skill when asked to create and compile espforge example 
              Trigger phrases 
              'Create and compile example for device X'
              
---

# SKILL: Create and compile espforge example

## Running first time around

Run `bash ~/.config/opencode/skills/espforge-compile-example/scripts/compile_example.sh` 

If it fails, it means there is an error in espforge rust driver for device X. 

You will find source code in `espforge` in the working directory.

## Subsequent runs
Run `bash ~/.config/opencode/skills/espforge-compile-example/scripts/compile_example.sh recompile` 

If you fail after 5 attempts at fixing errors, stop and write a document `<device>_COMPILE_EXAMPLE.txt`
explaining what you tried.


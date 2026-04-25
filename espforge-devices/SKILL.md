---
name: espforge-devices
description: Use this skill when asked add a hardware device or sensor to espforge. 
              Trigger phrases 'add device X to espforge'
---

# SKILL: Adding a Device to Espforge
To complete this skill, run the following sub-skills in order: 
    ADD_DEVICE.md
    GIT_STUFF.md
    COMPILE_ESPFORGE.md
    COMPILE_EXAMPLE.md
    GENERATE_DIFF.md

## Context variables
Two variables must be established and carried through every sub-skill:
- `<device>` — hardware device name, set by the user's initial request (e.g. `bmp180`)
- `<crate>`  — selected Rust crate name, set at the end of FIND_CRATES.md (e.g. `bmp085-180-rs`)

## Scripts location

`~/.config/opencode/skills/espforge-devices/scripts`

## Working directory

`~/Developer/espforge-ai`

All relative outputs are respect to this directory.

## espforge repository

After CLONEREPO.md subskill is run, espforge repo will be in `~/Developer/espforge-ai/espforge`


## Output

An agent MUST produce every item in this table before reporting completion. Locations are relative to working directory
`~/Developer/espforge-ai`

| Sub-skill | Produces | Required? |
|-----------|----------|-----------|
| COMPILE_EXAMPLE.md | `test/<example>` | always |
| GENERATE_DIFF.md | `<device>_changes.diff` | always |

When everything is completed, produce ~/Developer/espforge-ai/IMPROVEMENTS.md 
that lists improvements you would make to espforge-devices skill so that makes it easier next time it is run.
 

---
name: espforge-create-device
description: Use this skill when asked add a hardware device or sensor to espforge. 
              Trigger phrases 'add device X to espforge'
---

## Context variables
Two variables must be established and carried through every sub-skill:
- `<device>` — hardware device name, set by the user's initial request (e.g. `bmp180`)
- `<crate>`  — selected Rust crate name

Must read file `<device>_api.md` in full in the current working directory

The first line will tell you the name of the rust crate that will support the device requested. 

# SKILL: Adding a Device to Espforge
To complete this skill, run the following sub-skills in order: 
    ADD_DEVICE.md
    GIT_STUFF.md

## Scripts location

`~/.config/opencode/skills/espforge-devices/scripts`

## Working directory

`~/Developer/espforge-ai`

All relative outputs are respect to this directory.

## Input

`<device>_api.md` : This contains documentation for the rust crate that has been chosen for `<device>` requested by user.
This crate needs to be incorporated into espforge when adding support for `<device>`.

`espforge` directory: Contains source code of espforge repository. 

When everything is completed, produce ~/Developer/espforge-ai/<device>_driver_IMPROVEMENTS.md 
that lists improvements you would make to espforge-create-device skill so that makes it easier next time it is run.
 

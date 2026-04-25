---
name: espforge-devices
description: "Use this skill when asked add a rust crate for espforge. 
              Trigger phrases: 
              'find rust crate for device X to add to espforge', 
              
---

# SKILL: Adding a Device to Espforge
To complete this skill, run the following sub-skills in order: 
    SENSOR_CATEGORY.md
    CLONEREPO.md 
    FIND_CRATES.md
    REPO_EXAMPLES.md
    CRATE_API.md
   
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
| SENSOR_CATEGORY.md | `<device>_category.md` | always |
| FIND_CRATES.md | `<device>_crate.md` | always |
| CRATE_API.md | `<device>_api.md` | always |
| REPO_EXAMPLES.md | `artifacts/<crate>/examples/` | only if repo has examples |

When everything is completed, produce ~/Developer/espforge-ai/IMPROVEMENTS.md 
that lists improvements you would make to espforge-devices skill so that makes it easier next time it is run.
 
-In addition:
**Notes:**
- When running REPO_EXAMPLES.md, check exit status: 0 = examples fetched, 1 = none found


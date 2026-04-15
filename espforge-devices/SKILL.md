---
name: espforge-devices
description: "Use this skill when asked add a hardware device or sensor to espforge. 
              Trigger phrases: 
              'add device X to espforge', 
              'add sensor Y to espforge', 
              'integrate device Z', 
              'create a driver for espforge'."
---

# SKILL: Adding a Device to Espforge
To complete this skill, run four sub-skills in order: 
    CLONEREPO.md 
    FIND_CRATES.md
    REPO_EXAMPLES.md
    CREATE_API.md
    ADD_DEVICE.md
    GIT_STUFF.md
    COMPILE_ESPFORGE.md
    COMPILE_EXAMPLE.md
    GENERATE_DIFF.md

## Context variables
Two variables must be established and carried through every sub-skill:
- `<device>` — hardware device name, set by the user's initial request (e.g. `bmp180`)
- `<crate>`  — selected Rust crate name, set at the end of FIND_CRATES.md (e.g. `bmp085-180-rs`)

## Output

An agent MUST produce every item in this table before reporting completion.

| Sub-skill | Produces | Required? |
|-----------|----------|-----------|
| FIND_CRATES.md | `<device>_crate.md` | always |
| CREATE_API.md | `<device>_api.md` | always |
| REPO_EXAMPLES.md | `artifacts/<device>/examples/` | only if repo has examples |
| GENERATE_DIFF.md | `<device>_changes.diff` | always |
 
-In addition:
**Notes:**
- When running ADD_DEVICE.md, the espforge repo is in `./espforge`
- When running REPO_EXAMPLES.md, check exit status: 0 = examples fetched, 1 = none found


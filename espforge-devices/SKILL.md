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
To complete this skill, run three sub-skills in order: 
    CLONEREPO.md 
    FIND_CRATES.md
    CREATE_API.md
    ADD_DEVICE.md

## Output

I expect two files: 
 ~/.picoclaw/workspace/outputs/<device>_crate.md
 ~/.picoclaw/workspace/outputs/<device>_api.md

In addition when running subskill in ADD_DEVICE.md, you will find espforge repo in ~/.picoclaw/workspace/outputs/espforge, this is where you will add the new device requested.




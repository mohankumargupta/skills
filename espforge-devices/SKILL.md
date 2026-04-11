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
    CREATE_API.md
    REPO_EXAMPLES.md
    ADD_DEVICE.md
    COMPILE_ESPFORGE.md
    GENERATE_DIFF.md
    COMPILE_EXAMPLE.md
## Output

I expect three files: 
<device>_crate.md
<device>_api.md
<device>_changes.diff

In addition:

1. When running subskill in REPO_EXAMPLES.md, if we find examples in the github repo for crate, then there should
   be artifacts in artifacts/<device>/examples
2. When running subskill in ADD_DEVICE.md, 
     you will find espforge repo in ```./espforge```

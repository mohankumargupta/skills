---
name: espforge-find-crate
description: Use this skill to find the most suitable crate from crates.io
---

#SKILL: Find most suitable crate for espforge device on crates.io
To complete this skill, you must:

1. Run `bash ~/.config/opencode/skills/discover-crate/scripts/findcrates.sh` with the name of device as argument
   This returns a list of crates mentioning device.   
2. From the candidate list of crates found, priority is given to: 
     - dependency on embedded-hal v1 (10/10), 
     - dependency on embedded-hal-async v1 (8/10).
     - recently updated (6/10)
     - downloads (4/10) 
     - all other considerations (0/10)
   You must score each crate based on this priority. Score is just weighted sum of priority.
   The one with highest score is the selected crate.
3. When you find the selected crate, you must create a document 
    ```<device_name>_crate.md```

## Format of <device_name>_crate.md

Print out what you found, with the most suitable the first one with the asterisk.

| Crate          | Version | EHv1? |Sync+Async| Downloads | Updated   | Stable? | Score
|----------------|---------|-------|--------- |-----------|-----------|---------|-------
| *foo-driver    | 1.2.0   | ✅    |✅        | 45 230    | 3 mo ago  | ★       |
| bar-sensor     | 0.4.0   | ✅    | ✅       | 12 100    | 14 mo ago | ✗       |


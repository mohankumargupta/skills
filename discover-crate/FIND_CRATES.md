---
name: espforge-find-crate
description: Use this skill to find the most suitable crate from crates.io
---

#SKILL: Find most suitable crate for espforge device on crates.io
To complete this skill, you must:

1. Run `bash ~/.config/opencode/skills/discover-crate/scripts/findcrates.sh` with the name of device as argument
   This returns a list of crates mentioning device.   
2. Score each candidate crate on these criteria (weighted sum):

   | Criterion                          | Points |
   |------------------------------------|--------|
   | depends on embedded-hal ^1.x       | 10     |
   | depends on embedded-hal-async ^1.x |  8     |
   | updated_at < 6 months ago          |  6     |
   | updated_at 6–12 months ago         |  4     |
   | updated_at 12–24 months ago        |  2     |
   | updated_at > 24 months ago         |  0     |
   | downloads every 1000 downloads     |  1     |

   Today's date must be recorded at the top of the scoring table so the
   result is reproducible. Run `bash -c 'date -u +"%Y-%m-%d"'` and record the output as `<today>`

   Select the crate with the highest total score.
   
3. When you find the selected crate, you must create a document 
    ```<device>_crate.md```

## Format of <device>_crate.md

Print out what you found, with the most suitable the first one with the asterisk.

| Crate          | Version | EHv1? |Sync+Async| Downloads | Updated   | Stable? | Score
|----------------|---------|-------|--------- |-----------|-----------|---------|-------
| *foo-driver    | 1.2.0   | ✅    |✅        | 45 230    | 3 mo ago  | ★       |
| bar-sensor     | 0.4.0   | ✅    | ✅       | 12 100    | 14 mo ago | ✗       |


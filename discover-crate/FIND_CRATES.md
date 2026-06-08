---
name: espforge-find-crate
description: Use this skill to find the most suitable crate from crates.io
---

# SKILL: Find most suitable crate for espforge device on crates.io
To complete this skill, you must:

1. Run `bash ~/.config/opencode/skills/discover-crate/scripts/findcrates.sh` with the name of device as argument
   This returns a list of crates mentioning device.   

2. You must output a `<scratchpad>` block in your thought process where you 
calculate the score for each crate step-by-step. Use this exact scoring criteria:

 DEPENDENCIES:
 - **Does it depend on `embedded-hal` version `^1.x`?** 
   - If YES: +10 points. 
   - If NO: The crate is completely DISQUALIFIED. Stop calculating, mark its score as "DQ", and move to the next crate.
 - Depends on `embedded-hal-async` version `^1.x` = +8 points
 
 FRESHNESS (Compare last updated date to `<today>`):
   - Updated <= 1 year ago = +2 points
   - Updated > 1 year ago = 0 points
   
 ADOPTION:
   - Divide total downloads by 1000.0 (include one decimal point ). E.g., 45,230 downloads = +45.2 points.
     You can use ```bash -c 'python3 -c "print(f\"{45230 / 1000:.1f}\")"'``` to calculate
     
 TIE-BREAKER: 
   - If two or more crates have the exact same Total Score, the crate with the higher total `Downloads` wins.   

*Example scratchpad evaluation:*
`foo-driver: EHv1 (10) + Async (8) + 3mo old (2) + 45k DLs (45) = Total 65`
3. Score each candidate crate on these criteria (weighted sum):

   | Criterion                          | Points |
   |------------------------------------|--------|
   | depends on embedded-hal ^1.x       | 10     |
   | depends on embedded-hal-async ^1.x |  8     |
   | updated_at <= 1 year ago           |  2     |
   | updated_at > 1 year ago            |  0     |
   | downloads                          |  <downloads>/1000.0 (one decimal place)     |

   Today's date must be recorded at the top of the scoring table so the
   result is reproducible. Run `bash -c 'date -u +"%Y-%m-%d"'` and record the output as `<today>`

   Select the crate with the highest total score.

4. When you find the selected crate, you must create a document 
    ```<device>_crate.md```

## Format of <device>_crate.md

Print out what you found, with the most suitable the first one with the asterisk.

| Crate          | Version | EHv1? |Sync+Async| Downloads | Updated   | Score
|----------------|---------|-------|--------- |-----------|-----------|-------
| *foo-driver    | 1.2.0   | ✅    |✅        | 45 230    | 3 mo ago  |
| bar-sensor     | 0.4.0   | ✅    | ✅       | 12 100    | 14 mo ago | 


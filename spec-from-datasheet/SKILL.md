---
name: spec-from-datasheet
description: Create spec markdown from datasheet for <device>
---

run pwd this is the current working directory

All scripts are in the `scripts` folder of this skill.
They are to be run in the current working directory.


## Step 1 Download esphome.io components

run `component.sh` inside the current working directory

## Step 2 Find esphome.io docs markdown 

Then run this from current working directory:
```bash
rg -i <device>
```

This will give you a path relative to current directory to esphome docs for <device>.

## Step 2: Download datasheet

1. Open the component documentation file.
2. Find a datasheet URL for <device>.
   - once you found a url there is a script inside this skill called analog.sh
     datasheets with analog.com in their url are replaced by wayback machine url
     usage: analog.sh <device>
3. Create directory `datasheets/<device>`
4. Download the datasheet as `datasheets/<device>/<device>.pdf`


## Step 3: Prepare extraction environment

```bash
cd datasheets/<device>
uv init
uv add pymupdf4llm
```


copy `assets/datasheet_device/main.py` and `assets/datasheet_device/template_chip.md` from this skill 
and copy it to `datasheets/<device>` in the current directory.

## Step 4: convert pdf to mardown

```bash
cd datasheets/<device>
uv run main.py <device>.pdf <device>_datasheet.md
```

## Step 5: Produce finished markdown

Take `datasheets/<device>/<device>_datasheet.md` as the source of truth and 
`datasheets/<device>/template_chip.md` as template and produce `datasheets/<device>.md`
which fills out template from source of truth only.


## Step 6 Finishing up

Before finishing, write a doc called <device>_spec.md in original working directory for comments about this skill
including obstacles and improvements.


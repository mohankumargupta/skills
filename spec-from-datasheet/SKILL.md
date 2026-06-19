---
name: spec-from-datasheet
description: Create spec markdown from dataheet for <device>
---

before proceeding, run 

```bash
tree .
``` 

in this skill directory to see file organisation

## Step 1 Download esphome.io components

Run this script if components directory does not exist:

```bash
mkdir -p components
npx -y degit -f https://github.com/esphome/esphome.io/src/content/docs/components
```

Then run:
```bash
fd -a -t f -e mdx . components | grep <device>
```

This will give you the full path to esphome docs for <device>.

## Step 2: Download datasheet

1. Open the component documentation file.
2. Find the first datasheet URL.
3. Download the datasheet as:

```text
datasheets/<device>/<device>.pdf
```

Create the destination directory if required.

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

## Step 5: Final user output

Then I need to print out the following to the user:

```text
Skill completed. Please open freebuff and write the following prompt:

Take datasheets/<device>/<device>_datasheet.md as the source of truth and 
path/to/Periph/spec/<device>.md as template and produce datasheets/<device>.md
which fills out template from source of truth.
```

Before finishing, write a doc called <device>_spec.md for comments about this skill
including obstacles and improvements.


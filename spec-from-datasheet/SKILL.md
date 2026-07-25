---
name: spec-from-datasheet
description: Create spec markdown from datasheet for <device>
---

# Context variables

<original_pwd>:  run pwd, this is <original_pwd>
<artifacts_dir>: this directory is <original_pwd>/artifacts/<device>/prompt0, will need to be created
<datasheet_dir>: <artifacts_dir>/datasheet, need to create directory
<final_spec_file>: <artifacts_dir>/<device>.md
<feedback_dir>:  <original_pwd>/feedback/<device>, need to create directory
<feedback_file>: <feedback_dir>/prompt0.md

## Step 1 Download esphome.io components

run `components.sh` from this skill

## Step 2 Find esphome.io docs markdown 



Then run this from current working directory:
```bash
rg -i <device> components
```



This will give you a path relative to current directory to esphome docs for <device>.

If that returns empty,it means that the name of the device is not the same as name of
esphome component that we are looking for.
You will need to run this from current working directory.

```bash
rg -i <device> esphome
```

It is now important that based on what you found you now search again at components dir,
because it is the markdown doc we need

```bash
rg -i <name_of_component> components 
```

create a file called <artifacts_dir>/esphome_component.txt with the name of esphome component.

## Step 2: Download datasheet

1. Read the device documentation file (eg. `components/sensor/<device>.mdx`)
2. Find a datasheet URL for <device>.
3. once you found a datasheet url there is a script inside this skill called `analog.sh`
     usage: analog.sh <datasheet_url>
     this will return the actual url which you can download from.
4. Create directory `<datasheet_dir>`
5. Download the datasheet as `<datasheetr_dir>/<device>.pdf`
6. Ignore if `file name_of_datasheet` returns encypted, it is usually a false flag.
   qpdf is installed.

## Step 3: Prepare extraction environment

```bash
cd <datasheet_dir>
uv init
uv add pymupdf4llm
```


copy `assets/datasheet_device/main.py` and `assets/datasheet_device/template_chip.md` from this skill 
and copy it to `<datasheet_dir>` .

## Step 4: convert pdf to markdown

```bash
cd <datasheet_dir>
uv run main.py <device>.pdf <device>_datasheet.md
```

## Step 5: Produce finished markdown

Take `<datasheet_dir>/<device>_datasheet.md` as the source of truth and 
`<datasheet_dir>/template_chip.md` as template and produce `<final_spec_file>`
which fills out template from source of truth only.


## Step 6 Finishing up

Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.


---
name: collect-background-material
description: Collect background material for device <device>
---

# Context Variables

<original_pwd>: run pwd, this is <original_pwd>
<artifacts_dir>: directory is <original_pwd>/artifacts/<device>/prompt0b, you will need to create this.
<feedback_dir>: <original_pwd>/feedback/<device>, you will need to create this
<feedback_file>: <feedback_dir>/prompt0b.md

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

## Step 3: Copy the files to artifacts dir

need to copy the <name_of_component>.mdx you found in components and the source code in esphome 
folder for component eg. esphome/esphome/components/<name_of_component> to <artifacts_dir>

### Step 4: Feedback
 
Before finishing, write a doc called `<feedback_file>` 
for comments about this skill 
including obstacles and improvements.

---
name: datasheet-markdown
description: grab datasheet from esphome docs component dir and convert to markdown
---

## Steps:

### Step 1: Find markdown inside esphome docs markdown directory

If components directory doesnt already exist in the current working directory, run:

```bash
mkdir -p components
cd components
npx degit -f https://github.com/esphome/esphome.io/src/content/docs/components
```
### Step 2: Find markdown inside components

```
fd <device> -e mdx components
```

### Step 3: Look for datasheet URL in the markdown file

From previous step, look for datasheet URL(the first one). When you find it, use curl to 
download it to the datasheets folder in the current directory, if it doesn't exist, create it.
Save it as `<device>.pdf`
NOTE: If file command says it is password-protected, simply run it through this command:

```bash
qpdf --decrypt --replace-input <device>.pdf
```


### Step 4: Convert pdf to markdown

Use markitdown to convert to
`datasheets/<device>.md`. 

Run:

```bash
markitdown datasheets/<device>.pdf -o datasheets/<device>.md
```
  

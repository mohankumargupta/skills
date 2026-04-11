# Skill: Generate diff

run ```bash ~/.qwen/skills/espforge-devices/scripts/generate_diff.sh <device>```
````

## File: REPO_EXAMPLES.md
````markdown
# SKILL: Repo examples

Run ```bash ~/.qwen/skills/espforge-devices/scripts/check_examples.sh <owner/repository>``` where
<owner/repository> is the github repo for crate chosen. 



If this exit status of this script is 1, then it means the github repo doesn't have examples.
If this exit status of this script is 0, you will see a folder called artifacts/<repository>/examples

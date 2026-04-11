# SKILL: Repo examples

Run ```bash ~/.qwen/skills/espforge-devices/scripts/crate_repository.sh <crate>``` to find the owner/repository
of the github repo.

Run ```bash ~/.qwen/skills/espforge-devices/scripts/check_examples.sh <owner/repository>``` where
<owner/repository> represents github repo returned from previous script.



If this exit status of this script is 1, then it means the github repo doesn't have examples.
If this exit status of this script is 0, you will see a folder called artifacts/<repository>/examples


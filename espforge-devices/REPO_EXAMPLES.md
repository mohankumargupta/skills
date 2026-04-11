# SKILL: Repo examples

## Steps

1. Find the GitHub owner/repository for the selected crate:

Run ```bash ~/.qwen/skills/espforge-devices/scripts/crate_repository.sh <crate>``` to find the owner/repository
of the github repo.

2. Fetch examples using the returned `<owner/repository>`:

Run ```bash ~/.qwen/skills/espforge-devices/scripts/check_examples.sh <owner/repository>```

3. Check the exit status:
   - **Exit 0**: examples fetched into `artifacts/<repository>/examples/`
   - **Exit 1**: repo has no examples directory. Record this in `<device>_api.md` as
     "No upstream examples available." Do not treat this as a failure — continue to ADD_DEVICE.md.


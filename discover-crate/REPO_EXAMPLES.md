# SKILL: Fetch Crate Source and Examples

## Steps

1. Find the GitHub owner/repository for the selected crate:

   Run `bash ~/.config/opencode/skills/discover-crate/scripts/crate_repository.sh <crate>`
   to get the `<owner/repository>` string of the github repo.

2. Clone the crate source using the returned `<repo_url>`:

   Run `bash ~/.config/opencode/skills/discover-crate/scripts/check_crate_source.sh <repo_url> <crate>`

3. Check the exit status:
   - **Exit 0**: source fetched successfully. The following layout is now present
     under `artifacts/<repository>/`:

     ```
     artifacts/<repository>/
     ├── Cargo.toml          ← crate metadata, features, dependencies
     |---README.md     
     ├── src/
     │   └── lib.rs          ← crate root; may reference sub-modules in src/
     └── examples/           ← upstream usage examples (may be empty or absent)
         └── ...
     ```

     Must always read the crate project README.md in full.

     Confirm the three key paths exist before proceeding:
     - `artifacts/<repository>/Cargo.toml`
     - `artifacts/<repository>/src/lib.rs`
     - `artifacts/<repository>/examples/` (directory may be empty — that is fine)

   - **Exit 1**: repository could not be fetched. Record this in `<device>_api.md` as
     "No upstream source available." Do not treat this as a failure.

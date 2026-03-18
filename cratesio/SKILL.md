---
name: cratesio
description: Searches crates.io for no_std and embedded-hal v1 compatible Rust crates. Use when the user asks to "find rust crate for sensor X", "find a rust crate for i2c display", or "search for embedded-hal drivers".
---

# Skill: crates.io

Searches for embedded-hal v1 compatible crates from crates.io.

# Instructions

Follow this sequential workflow to identify compatible crates. Consult `references/crate-standards.md` for compatibility definitions.

## Step 1: Search for candidates

Run `bash scripts/search.sh --query {sensor_name}` to find candidate crates.

## Step 2: Check compatibility
For each candidate, run `bash scripts/check_crate.sh --crate {crate_name}` to verify `embedded-hal` v1 support and async capabilities.

## Step 3: Present Results
Present a shortlist table including the Crate Name, Version, EH v1 Support, and Async support. 
- ⭐ Highlight mature crates (version > 1.0.0).
- ⚠️ Flag crates with version < 1.0.0 as potentially unstable.

## Step 4: Offer Follow-up Actions
Always ask if the user wants to:
- Fetch README/docs for a specific crate.
- Check repository activity.
- See code examples.

# Troubleshooting

## crates.io API Failure
**Cause:** Network issues or rate limiting.
**Solution:** Consult `references/api-guidelines.md` for rate-limiting patterns. Inform the user: "Could not reach crates.io, please try again.".

## No Results Found
**Cause:** Search term is too specific or no driver exists.
**Solution:** Suggest broader search terms to the user.


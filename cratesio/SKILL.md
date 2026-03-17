---
name: cratesio
description: Search crates.io for no_std + embedded-hal v1 compatible Rust crates (e.g., "find rust crate for sensor mpu6050", "find a rust crate for i2c display")
---

# Skill: crates.io

Searches for embedded-hal v1 compatible crates from crates.io.

## What makes a crate suitable

1. **embedded-hal v1** dependency (`^1`, `>=1`, `~1`, or `1`)

## Workflow

User asks: "find rust crate for sensor ds18b20 from crates.io"

### Step 1: Search for candidates

```sh
SENSOR="ds18b20"
curl -s "https://crates.io/api/v1/crates?q=${SENSOR}&per_page=100" | \
  jq -r '.crates[].name'
```

Show output: "I found the following candidate crates:"

### Step 2: Check each candidate

For each crate, run these checks:

```sh
CRATE="ds18b20"

# Get latest stable version (fallback to newest if no stable)
VERSION=$(curl -s "https://crates.io/api/v1/crates/${CRATE}" | \
  jq -r '.crate.max_stable_version // .crate.newest_version // empty')

# Check for embedded-hal v1 dependency
HAS_EH1=$(curl -s "https://crates.io/api/v1/crates/${CRATE}/${VERSION}/dependencies" | \
  jq '.dependencies | any(
    .crate_id == "embedded-hal" and 
    (.req | test("^\\^?1\\.|^>=1\\.|^~1\\.|^1\\."))
  )')

# Check for embedded-hal-async (optional, for async crates)
HAS_EH_ASYNC=$(curl -s "https://crates.io/api/v1/crates/${CRATE}/${VERSION}/dependencies" | \
  jq '.dependencies | any(.crate_id == "embedded-hal-async")')
```

### Step 3: Build results table

```sh
echo "| Crate | Version | embedded-hal v1 | Async |"
echo "|-------|---------|-----------------|-------|"
echo "| ${CRATE} | ${VERSION} | ${HAS_EH1} | ${HAS_EH_ASYNC} |"
```

### Step 4: Present shortlist

Filter to only show crates where `HAS_EH1 == true`:

> "Here is the shortlist of crates with embedded-hal v1 support:"

Show the table. Add notes:
- ⭐ Highlight the most mature (highest version number)
- ⚠️ Flag crates with version < 1.0 as potentially unstable

### Step 5: Offer follow-up

Ask if user wants to:
- Fetch README/docs for a specific crate
- Check repository activity (last commit, open issues)
- See code examples
- Compare async vs sync variants

## Rate Limit Awareness

- crates.io allows ~60 requests/minute unauthenticated
- Batch checks when possible
- Cache results if checking many crates

## Error Handling

- If `curl` fails: "Could not reach crates.io, please try again"
- If no results: "No crates found for '{sensor}'. Try a different search term?"
- If version is null: "No published versions found"

## Constraints

- Follow this workflow step by step
- Always show the full shortlist table
- Always offer follow-up actions
- Prefer stable versions over pre-releases
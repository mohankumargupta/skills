#!/usr/bin/env sh
# fetch_crate_info.sh
# Usage: bash scripts/fetch_crate_info.sh <crate_name>
# Prints: name, description, latest stable version, repository URL, documentation URL.

set -e
CRATE="${1:?Usage: $0 <crate_name>}"

RESPONSE=$(curl -sf \
  -H "User-Agent: discover-crate-skill/1.0" \
  "https://crates.io/api/v1/crates/${CRATE}")

echo "$RESPONSE" | jq -r '
  "Crate      : " + .crate.name,
  "Description: " + (.crate.description // "N/A"),
  "Version    : " + (.crate.max_stable_version // .crate.newest_version // "unknown"),
  "Repository : " + (.crate.repository // "N/A"),
  "Docs       : " + ("https://docs.rs/" + .crate.name),
  "Downloads  : " + (.crate.downloads | tostring)
'


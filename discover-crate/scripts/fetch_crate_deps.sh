#!/usr/bin/env sh
# fetch_crate_deps.sh
# Usage: bash scripts/fetch_crate_deps.sh <crate_name> [version]
# Prints all dependencies with their requirement strings.
# Highlights embedded-hal, embedded-hal-async, embedded-io.

set -e
CRATE="${1:?Usage: $0 <crate_name> [version]}"

if [ -n "$2" ]; then
  VERSION="$2"
else
  VERSION=$(curl -sf \
    -H "User-Agent: discover-crate-skill/1.0" \
    "https://crates.io/api/v1/crates/${CRATE}" | \
    jq -r '.crate.max_stable_version // .crate.newest_version // empty')
fi

echo "Dependencies for ${CRATE} @ ${VERSION}:"
echo "---"

curl -sf \
  -H "User-Agent: discover-crate-skill/1.0" \
  "https://crates.io/api/v1/crates/${CRATE}/${VERSION}/dependencies" | \
  jq -r '
    .dependencies[] |
    [
      (if .crate_id == "embedded-hal" or
          .crate_id == "embedded-hal-async" or
          .crate_id == "embedded-io" then "*** " else "    " end),
      .kind,
      "\t",
      .crate_id,
      " ",
      .req,
      (if .optional then " (optional)" else "" end)
    ] | add
  ' | sort

echo ""
echo "*** = key embedded crate (check version compatibility)"


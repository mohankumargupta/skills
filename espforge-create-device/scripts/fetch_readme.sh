#!/usr/bin/env sh
# fetch_readme.sh
# Usage: bash scripts/fetch_readme.sh <crate_name> [version]
# Fetches the README from crates.io and prints it (Markdown).

set -e
CRATE="${1:?Usage: $0 <crate_name> [version]}"

if [ -n "$2" ]; then
  VERSION="$2"
else
  VERSION=$(curl -sf \
    -H "User-Agent: espforge-devices-skill/1.0" \
    "https://crates.io/api/v1/crates/${CRATE}" | \
    jq -r '.crate.max_stable_version // .crate.newest_version // empty')
fi

echo "=== README: ${CRATE} @ ${VERSION} ==="
curl -sf \
  -H "User-Agent: espforge-devices-skill/1.0" \
  "https://static.crates.io/readmes/${CRATE}/${VERSION}/readme.html" 2>/dev/null \
  || curl -sf \
    -H "User-Agent: espforge-devices-skill/1.0" \
    "https://crates.io/api/v1/crates/${CRATE}/${VERSION}/readme" 2>/dev/null \
  || echo "(README not available via API — check: https://docs.rs/${CRATE})"


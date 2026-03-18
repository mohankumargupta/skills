#!/usr/bin/env sh

# Checks a specific crate for EH v1 and async dependencies
CRATE=$1

# Get latest stable version
VERSION=$(curl -s "https://crates.io/api/v1/crates/${CRATE}" | \
  jq -r '.crate.max_stable_version // .crate.newest_version // empty')

# Check for embedded-hal v1 dependency
HAS_EH1=$(curl -s "https://crates.io/api/v1/crates/${CRATE}/${VERSION}/dependencies" | \
  jq '.dependencies | any(.crate_id == "embedded-hal" and (.req | test("^\\^?1\\.|^>=1\\.|^~1\\.|^1\\.")))')

# Check for embedded-hal-async
HAS_EH_ASYNC=$(curl -s "https://crates.io/api/v1/crates/${CRATE}/${VERSION}/dependencies" | \
  jq '.dependencies | any(.crate_id == "embedded-hal-async")')

echo "Crate: $CRATE | Version: $VERSION | EHv1: $HAS_EH1 | Async: $HAS_EH_ASYNC"

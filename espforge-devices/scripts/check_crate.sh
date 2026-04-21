#!/usr/bin/env bash
# check_crate.sh
# Usage: bash scripts/check_crate.sh <crate_name>
# Checks whether a crate supports embedded-hal v1 and embedded-hal-async.

set -e
CRATE="${1:?Usage: $0 <crate_name>}"

VERSION=$(curl -s \
  -H "User-Agent: espforge-devices-skill/1.0" \
  "https://crates.io/api/v1/crates/${CRATE}" | \
  jq -r '.crate.max_stable_version // .crate.newest_version // empty')

if [ -z "$VERSION" ]; then
  echo "Crate: $CRATE | NOT FOUND"
  exit 1
fi

DEPS=$(curl -s \
  -H "User-Agent: espforge-devices-skill/1.0" \
  "https://crates.io/api/v1/crates/${CRATE}/${VERSION}/dependencies")

HAS_EH1=$(echo "$DEPS" | jq '
  .dependencies | any(
    .crate_id == "embedded-hal" and
    (.req | test("^\\^?1\\.|^>=1\\.|^~1\\.|^1\\."))
  )')

HAS_EH_ASYNC=$(echo "$DEPS" | jq '
  .dependencies | any(.crate_id == "embedded-hal-async")')

echo "Crate: $CRATE | Version: $VERSION | EHv1: $HAS_EH1 | Async: $HAS_EH_ASYNC"


#!/usr/bin/env bash
set -e

SENSOR="${1:?Usage: $0 <sensor_name>}"
USER_AGENT="discover-crate-skill/1.0"

# Print standard CSV header
echo "crate,version,downloads,last_upload_date,hal_dependencies"

# Fetch top 100 crates silently
CRATES_JSON=$(curl -s -H "User-Agent: ${USER_AGENT}" \
  "https://crates.io/api/v1/crates?q=${SENSOR}&per_page=100")

# Exit silently if no crates are found
if [ -z "$CRATES_JSON" ] ||[ "$(echo "$CRATES_JSON" | jq '.crates | length')" -eq 0 ]; then
  exit 0
fi

# Parse crates, versions, downloads, and last update date as tab-separated values
echo "$CRATES_JSON" | jq -r '.crates[] |[
  .name, 
  (.max_stable_version // .newest_version // empty),
  .downloads,
  .updated_at
] | @tsv' | \
while IFS=$'\t' read -r CRATE VERSION DOWNLOADS UPLOAD_DATE; do
  if [ -z "$CRATE" ] ||[ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
    continue
  fi

  # Fetch dependencies silently
  DEPS_JSON=$(curl -s -f -H "User-Agent: ${USER_AGENT}" \
    "https://crates.io/api/v1/crates/${CRATE}/${VERSION}/dependencies" || true)

  if [ -z "$DEPS_JSON" ]; then
    continue
  fi

  # Filter for v1.x embedded-hal and embedded-hal-async
  # Multiple dependencies are joined by a semicolon
  HAL_DEPS=$(echo "$DEPS_JSON" | jq -r '
    [
      .dependencies[]? |
      select(
        (.crate_id == "embedded-hal" or .crate_id == "embedded-hal-async") 
        and (.req | test("^[\\^~=>\\s]*1\\."))
      ) |
      "\(.crate_id): \(.req)"
    ] | join("; ")
  ')

  # If a v1.x dependency is found, output as strict CSV
  if [ -n "$HAL_DEPS" ]; then
    echo "${CRATE},${VERSION},${DOWNLOADS},${UPLOAD_DATE},\"${HAL_DEPS}\""
  fi

  # Be polite to the crates.io API
  sleep 0.2
done


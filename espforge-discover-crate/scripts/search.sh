#!/usr/bin/env sh
# search.sh
# Usage: bash scripts/search.sh <sensor_name>
# Searches crates.io and returns top 100 candidate crate names.

SENSOR="${1:?Usage: $0 <sensor_name>}"

curl -s \
  -H "User-Agent: espforge-devices-skill/1.0" \
  "https://crates.io/api/v1/crates?q=${SENSOR}&per_page=100" \
  | jq -r '.crates[].name'


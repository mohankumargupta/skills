#!/usr/bin/env sh

# Searches crates.io for a query string and returns top 100 names
SENSOR=$1
curl -s "https://crates.io/api/v1/crates?q=${SENSOR}&per_page=100" | jq -r '.crates[].name'

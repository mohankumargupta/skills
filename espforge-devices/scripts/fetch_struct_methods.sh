#!/usr/bin/env sh
# fetch_struct_methods.sh
# Usage: bash scripts/fetch_struct_methods.sh <crate_name> <struct_name> [version]
#
# Fetches the docs.rs page for a specific struct and extracts:
#   - All public method signatures
#   - Constructor (new / new_with_address / etc.)
#   - Trait impls the struct satisfies
#
# Examples:
#   bash scripts/fetch_struct_methods.sh ssd1306 Ssd1306
#   bash scripts/fetch_struct_methods.sh bmp085-180-rs BMP 1.0.0
#   bash scripts/fetch_struct_methods.sh ds18b20 Ds18b20
#
# OUTPUT FORMAT (plain text, easy to read or pipe into generate_diff.py --device-struct):
#   === Methods on <StructName> (<crate_name> @ <version>) ===
#   pub fn new(...) -> Self
#   pub fn read_temperature(&mut self) -> Result<f32, E>
#   ...
#
# NOTES:
#   - docs.rs is available for every crate published to crates.io.
#   - The struct page URL is stable: docs.rs/<crate>/<version>/<rust_ident>/struct.<Struct>.html
#   - Hyphens in crate names become underscores in the URL path segment (handled automatically).
#   - If the struct is not found at the constructed URL, the script prints the URL so you
#     can check the crate's module structure manually.

set -e

CRATE="${1:?Usage: $0 <crate_name> <struct_name> [version]}"
STRUCT="${2:?Usage: $0 <crate_name> <struct_name> [version]}"
VERSION="${3:-latest}"

# Cargo allows hyphens; the URL path segment uses underscores.
RUST_IDENT=$(echo "$CRATE" | tr '-' '_')

URL="https://docs.rs/${CRATE}/${VERSION}/${RUST_IDENT}/struct.${STRUCT}.html"

echo "=== Methods on ${STRUCT} (${CRATE} @ ${VERSION}) ==="
echo "Source: ${URL}"
echo ""

# Fetch the page and extract method signatures.
# docs.rs renders method signatures inside <h4 class="code-header"> elements.
# We strip HTML tags and normalise whitespace to produce readable plain-text signatures.
RAW=$(curl -sf \
  -H "User-Agent: espforge-devices-skill/1.0" \
  -H "Accept: text/html" \
  "${URL}" 2>/dev/null) || {
  echo "(Could not fetch ${URL})"
  echo "Check the crate's module structure at: https://docs.rs/crate/${CRATE}/${VERSION}"
  exit 1
}

# Extract lines containing method signatures.
# Strategy: find all <h4 class="code-header"> content, strip tags.
echo "$RAW" \
  | grep -o '<h4 class="code-header">[^<]*\(<[^>]*>[^<]*\)*' \
  | sed 's/<[^>]*>//g' \
  | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&nbsp;/ /g; s/&#39;/'"'"'/g' \
  | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
  | grep -v '^$' \
  | sort -u \
  || echo "(No method signatures extracted — check ${URL} manually)"

echo ""
echo "=== Trait impls ==="
echo "$RAW" \
  | grep -o 'impl[^<]*<[^>]*>[^<]*' \
  | sed 's/<[^>]*>//g' \
  | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g' \
  | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
  | grep -v '^$' \
  | sort -u \
  | head -20 \
  || echo "(No trait impls extracted)"


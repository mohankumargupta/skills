#!/usr/bin/env bash
#set -x 
# Usage: ./check_crate_source.sh <repo_url> <crate> 

REPOSITORY="$1"
CRATE="$2"

#git clone --no-checkout --filter=blob:none https://github.com/marti157/bmp085-180-rs
#git sparse-checkout set --no-cone  "Cargo.toml" "src/" "examples/"
#git checkout

if [ -z "$REPOSITORY" ]; then
    echo "Usage: $0 repo_url crate"
    exit 1
fi

mkdir -p "artifacts"
cd artifacts
git clone --no-checkout --filter=blob:none "$REPOSITORY" "$CRATE"
cd "$CRATE"
git sparse-checkout set --no-cone  "Cargo.toml" "src/" "examples/"
git checkout


